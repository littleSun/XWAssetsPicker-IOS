//
//  XWAssetsPikerViewController.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.

#import "XWAssetsPikerViewController.h"
#import "XWAssetsGroupViewController.h"
#import "XWAssetsPageViewController.h"
#import "XWAssetsViewControllerTransition.h"
#import "XWAssetsPikerEditViewController.h"
#import "CompressHelp.h"
#import <MobileCoreServices/MobileCoreServices.h>

NSString *const XWAssetsChangedNotificationKey = @"XWAssetsChangedNotificationKey";

@interface XWAssetsPikerViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,XWAssetsGroupVCDelegate>
{
    CompressHelp *compressHelp;
    
    UIActivityIndicatorView *activityView;
}

@end

@implementation XWAssetsPikerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        //
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectedAssets"];
}

/**
 @method
 @brief 初始化缺省数据
 @discussion
 @param
 @result
 */
- (void)setup
{
    _openSlideSelectGesture = YES;
    _multiSelect = YES;
    _canEdit = NO;
    
    _assetColor = [UIColor redColor];
    _assetsFilter = [ALAssetsFilter allAssets];
    _selectedAssets = [[NSMutableArray alloc] init];
    
    compressHelp = [[CompressHelp alloc] init];
    compressHelp.picker = self;
    
    [self setupNavigationController];
    
    [self addObserver:self forKeyPath:@"selectedAssets" options:NSKeyValueObservingOptionPrior context:NULL];
}

#pragma mark - Setup Navigation Controller

- (void)setupNavigationController
{
    
    if (@available(iOS 7.0 , *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
    
    XWAssetsGroupViewController *vc = [[XWAssetsGroupViewController alloc] init];
    vc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

    
    if (@available(iOS 7.0 , *)) {
        [nav.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    }
    
    // Enable iOS 7 back gesture
    if ([nav respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        nav.interactivePopGestureRecognizer.enabled  = YES;
        nav.interactivePopGestureRecognizer.delegate = nil;
        nav.delegate = self;
    }
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    nav.delegate = self;
    [nav willMoveToParentViewController:self];
    
    // Set frame origin to zero so that the view will be positioned correctly while in-call status bar is shown
    [nav.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:nav.view];
    [self addChildViewController:nav];
    [nav didMoveToParentViewController:self];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(0, 0, 60, 60);
    activityView.layer.masksToBounds = YES;
    activityView.layer.cornerRadius = 5;
    activityView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    activityView.center = nav.view.center;
    [nav.view addSubview:activityView];
    
    activityView.hidesWhenStopped = YES;
}


//Lazy load assetsLibrary. User will be able to set his custom assetsLibrary
- (ALAssetsLibrary *)assetsLibrary
{
    if (nil == _assetsLibrary) {
        static ALAssetsLibrary *assetsLibrary_ = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            assetsLibrary_ = [[ALAssetsLibrary alloc] init];
        });
        _assetsLibrary = assetsLibrary_;
    }
    return _assetsLibrary;
}

- (NSString *)cachePath
{
    if (nil == _cachePath) {
        _cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"XWAsset"];
        [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    return _cachePath;
}

- (void)dismiss:(id)sender
{
    if (compressHelp.isCompressing) {
        return;
    }
    
    if (_delegate && [self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
        [self.delegate assetsPickerControllerDidCancel:self];
    
    if (@available(iOS 7.0 , *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender
{
    if (compressHelp.isCompressing) {
        return;
    }
    
    [compressHelp beginCompress];
    [activityView startAnimating];
    
    if (_delegate && [_delegate respondsToSelector:@selector(assetsPickerController:shouldCompressAsset:)]) {
        
        for (ALAsset *asset in self.selectedAssets) {
            //...
            BOOL iscompress = [self.delegate assetsPickerController:self shouldCompressAsset:asset];
            [compressHelp compressAssetInfo:asset execute:iscompress];
        }
    }
    else {
        for (ALAsset *asset in self.selectedAssets) {
            [compressHelp compressAssetInfo:asset execute:YES];
        }
    }
    
    __weak XWAssetsPikerViewController *weakSelf = self;
    [compressHelp compressToEnd:^(NSArray *compressResults) {
        //
        __strong XWAssetsPikerViewController *strongSelf = weakSelf;
        
        [strongSelf->activityView stopAnimating];
        [strongSelf finishToSend:compressResults];
    }];
}

- (void)finishToSend:(NSArray *)infos
{
    
    if (@available(iOS 7.0 , *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    
    __weak XWAssetsPikerViewController *weakSelf = self;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
            [weakSelf.delegate assetsPickerController:weakSelf didFinishPickingAssets:infos];

    }];
}

- (void)assetsGroupViewControllerEditOutput:(UIImage *)image
{
    NSString *imagePath = self.cachePath;
    
    if (image.images.count > 1) {
        imagePath = [imagePath stringByAppendingFormat:@"/%@-image.gif", [[NSUUID UUID] UUIDString]];
    }
    else {
        imagePath = [imagePath stringByAppendingFormat:@"/%@-image.jpg", [[NSUUID UUID] UUIDString]];
    }

    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:(NSString *)kUTTypeImage forKey:UIImagePickerControllerMediaType];
    [info setObject:image forKey:UIImagePickerControllerOriginalImage];
    
    if (self.isImageWriteToPath) {
        [info setObject:[NSURL fileURLWithPath:imagePath] forKey:UIImagePickerControllerMediaURL];
        NSData *data = [UIImage animatedDataWithGIF:image];
        [data writeToFile:imagePath atomically:YES];
    }
    
//    UIImageWriteToSavedPhotosAlbum(image, nil, NULL, NULL);
    
    [self finishToSend:@[info]];
}

#pragma mark -- ArrayUtil
- (void)insertObject:(NSObject *)object
{
    if (_delegate && [_delegate respondsToSelector:@selector(assetsPickerController:shouldSelectAsset:)]) {
        if (![self.delegate assetsPickerController:self shouldSelectAsset:(ALAsset *)object]) {
            return;
        }
    }
    
    NSInteger index = self.selectedAssets.count;
    
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"selectedAssets"];
    [self.selectedAssets addObject:object];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"selectedAssets"];
}

- (void)replaceObjectInArrAtIndex:(NSInteger)index withObject:(NSObject *)object
{
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"selectedAssets"];
    [self.selectedAssets replaceObjectAtIndex:index withObject:object];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"selectedAssets"];
}

- (void)removeObjectFromArrAtIndex:(NSInteger)index
{
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"selectedAssets"];
    [self.selectedAssets removeObjectAtIndex:index];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"selectedAssets"];
}

- (void)removeObjectFromArr:(NSObject *)object
{
    NSInteger index = [self.selectedAssets indexOfObject:object];
    
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"selectedAssets"];
    [self.selectedAssets removeObject:object];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:@"selectedAssets"];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"selectedAssets"] && ![change.allKeys containsObject:@"notificationIsPrior"] )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:XWAssetsChangedNotificationKey object:nil];
    }
}

#pragma mark - Accessors

- (UINavigationController *)childNavigationController
{
    return (UINavigationController *)self.childViewControllers.firstObject;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if ((operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[XWAssetsPageViewController class]]) ||
        (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[XWAssetsPageViewController class]]))
    {
        XWAssetsViewControllerTransition *transition = [[XWAssetsViewControllerTransition alloc] init];
        transition.operation = operation;
        
        return transition;
    }
    else if ((operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[XWAssetsPikerEditViewController class]]) ||
                 (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[XWAssetsPikerEditViewController class]]))
    {
        
//        return nil;
        
        XWAssetsViewControllerTransition2 *transition = [[XWAssetsViewControllerTransition2 alloc] init];
        transition.operation = operation;
        
        return transition;
    }
    else
    {
        return nil;
    }
}

+ (BOOL)checkStatusOk
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        //无权限
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法使用相册" message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    return YES;
}


@end
