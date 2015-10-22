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

#import "CompressHelp.h"

NSString *const XWAssetsChangedNotificationKey = @"XWAssetsChangedNotificationKey";

@interface XWAssetsPikerViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
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
    XWAssetsGroupViewController *vc = [[XWAssetsGroupViewController alloc] init];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    // Enable iOS 7 back gesture
    if ([nav respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        nav.interactivePopGestureRecognizer.enabled  = YES;
        nav.interactivePopGestureRecognizer.delegate = nil;
        nav.delegate = self;
    }
    
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
    activityView.color = self.assetColor;
    [nav.view addSubview:activityView];
    
    activityView.hidesWhenStopped = YES;
}


//Lazy load assetsLibrary. User will be able to set his custom assetsLibrary
- (ALAssetsLibrary *)assetsLibrary
{
    if (nil == _assetsLibrary)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];;
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
            if ([self.delegate assetsPickerController:self shouldCompressAsset:asset]) {
                [compressHelp compressAssetInfo:asset];
            }
        }
    }
    else {
        
        for (ALAsset *asset in self.selectedAssets) {
            [compressHelp compressAssetInfo:asset];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
        [self.delegate assetsPickerController:self didFinishPickingAssets:infos];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -- ArrayUtil
- (void)insertObject:(NSObject *)object
{
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
    else
    {
        return nil;
    }
}



@end
