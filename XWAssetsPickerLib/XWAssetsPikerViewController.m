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

NSString *const XWAssetsChangedNotificationKey = @"XWAssetsChangedNotificationKey";

@interface XWAssetsPikerViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

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
    
    [self setupNavigationController];
    
    [self addObserver:self forKeyPath:@"selectedAssets" options:NSKeyValueObservingOptionPrior context:NULL];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
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
}


//Lazy load assetsLibrary. User will be able to set his custom assetsLibrary
- (ALAssetsLibrary *)assetsLibrary
{
    if (nil == _assetsLibrary)
    {
        _assetsLibrary = [self.class defaultAssetsLibrary];
    }
    
    return _assetsLibrary;
}

- (void)dismiss:(id)sender
{
//    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
//        [self.delegate assetsPickerControllerDidCancel:self];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender
{
//    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
//        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
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
