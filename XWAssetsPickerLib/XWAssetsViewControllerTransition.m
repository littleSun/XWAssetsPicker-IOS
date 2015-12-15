//
//  CTAssetsViewControllerTransition.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.

#import "XWAssetsViewControllerTransition.h"
#import "XWAssetsGroupViewController.h"
#import "XWAssetsPageViewController.h"
#import "XWAssetsPikerEditViewController.h"

@implementation XWAssetsViewControllerTransition

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    UIView *containerView           = [transitionContext containerView];
    containerView.backgroundColor   = [UIColor whiteColor];
    
    if (self.operation == UINavigationControllerOperationPush)
    {
        XWAssetsGroupViewController *fromVC      = (XWAssetsGroupViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        XWAssetsPageViewController *toVC    = (XWAssetsPageViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        UIView *cellView = nil;
        
        if (!toVC.isPreview) {
            NSIndexPath *indexPath              = toVC.indexPath;
            cellView        = [fromVC.pickerCollectionView cellForItemAtIndexPath:indexPath];
        }
        else {
            
            cellView        = fromVC.assetToolBar.previewBtn;
        }
        
        UIImageView *imageView  = (UIImageView *)[((UIViewController *)toVC.viewControllers[0]).view viewWithTag:1];;
        CGSize size = imageView.frame.size;
        
        UIView *snapshot        = [self resizedSnapshot:imageView size:size];
        
        CGPoint cellCenter  = [fromVC.view convertPoint:cellView.center fromView:cellView.superview];
//        cellCenter = cellView.center;
        CGPoint snapCenter  = toVC.view.center;
        
        // Find the scales of snapshot
        float startScale    = MAX(cellView.frame.size.width / snapshot.frame.size.width,
                                  cellView.frame.size.height / snapshot.frame.size.height);
        
        float endScale      = MIN(toVC.view.frame.size.width / snapshot.frame.size.width,
                                  toVC.view.frame.size.height / snapshot.frame.size.height);
        
        // Find the bounds of the snapshot mask
        float width         = snapshot.bounds.size.width;
        float height        = snapshot.bounds.size.height;
        float length        = MIN(width, height);
        
        CGRect startBounds  = CGRectMake((width-length)/2, (height-length)/2, length, length);
        
        // Create the mask
        UIView *mask            = [[UIView alloc] initWithFrame:startBounds];
        mask.backgroundColor    = [UIColor blackColor];
        
        // Prepare transition
        snapshot.transform  = CGAffineTransformMakeScale(startScale, startScale);;
        snapshot.layer.mask = mask.layer;
        snapshot.center     = cellCenter;
        
        toVC.view.frame     = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha     = 0;
        
        // Add to container view
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapshot];
        
        // Animate
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromVC.view.alpha          = 0;
                             snapshot.transform         = CGAffineTransformMakeScale(endScale, endScale);
                             snapshot.layer.mask.bounds = snapshot.bounds;
                             snapshot.center            = snapCenter;
                         }
                         completion:^(BOOL finished){
                             toVC.view.alpha   = 1;
                             [snapshot removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
    
    else
    {
        XWAssetsPageViewController *fromVC  = (XWAssetsPageViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        XWAssetsGroupViewController *toVC        = (XWAssetsGroupViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
       
        UIView *cellView        = nil;
        
        if (!fromVC.isPreview) {
            NSIndexPath *indexPath              = fromVC.indexPath;
            
            // Scroll to index path
            [toVC.pickerCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            [toVC.pickerCollectionView layoutIfNeeded];
            
            cellView        = [toVC.pickerCollectionView cellForItemAtIndexPath:indexPath];
        }
        else {
            cellView       =   toVC.assetToolBar.previewBtn;
        }
        
        UIImageView *imageView  = (UIImageView *)[((UIViewController *)fromVC.viewControllers[0]).view viewWithTag:1];
         CGSize size = imageView.frame.size;

        
        UIView *snapshot        = [self resizedSnapshot:imageView size:size];
        
        CGPoint cellCenter  = [toVC.view convertPoint:cellView.center fromView:cellView.superview];
        CGPoint snapCenter  = fromVC.view.center;
        
        // Find the scales of snapshot
        float startScale    = MIN(fromVC.view.frame.size.width / snapshot.frame.size.width,
                                  fromVC.view.frame.size.height / snapshot.frame.size.height);
        
        float endScale      = MAX(cellView.frame.size.width / snapshot.frame.size.width,
                                  cellView.frame.size.height / snapshot.frame.size.height);
        
        // Find the bounds of the snapshot mask
        float width         = snapshot.bounds.size.width;
        float height        = snapshot.bounds.size.height;
        float length        = MIN(width, height);
        CGRect endBounds    = CGRectMake((width-length)/2, (height-length)/2, length, length);
        
        UIView *mask            = [[UIView alloc] initWithFrame:snapshot.bounds];
        mask.backgroundColor    = [UIColor whiteColor];
        
        // Prepare transition
        snapshot.transform      = CGAffineTransformMakeScale(startScale, startScale);
        snapshot.layer.mask     = mask.layer;
        snapshot.center         = snapCenter;
        
        toVC.view.frame         = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha         = 0;
        fromVC.view.alpha       = 0;
        
        // Add to container view
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapshot];
        
        // Animate
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             toVC.view.alpha            = 1;
                             snapshot.transform         = CGAffineTransformMakeScale(endScale, endScale);
                             snapshot.layer.mask.bounds = endBounds;
                             snapshot.center            = cellCenter;
                         }
                         completion:^(BOOL finished){
                             fromVC.view.alpha = 0;
                             [snapshot removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
}



#pragma mark - Snapshot

- (UIView *)resizedSnapshot:(UIImageView *)imageView size:(CGSize)size
{
//    CGSize size = imageView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    [imageView.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return (UIView *)[[UIImageView alloc] initWithImage:resized];
}

@end

@implementation XWAssetsViewControllerTransition2

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    UIView *containerView           = [transitionContext containerView];
    containerView.backgroundColor   = [UIColor whiteColor];
    
    if (self.operation == UINavigationControllerOperationPush)
    {
        XWAssetsGroupViewController *fromVC      = (XWAssetsGroupViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        XWAssetsPikerEditViewController *toVC    = (XWAssetsPikerEditViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        NSIndexPath *indexPath              = toVC.indexPath;
        UIView *cellView        = [fromVC.pickerCollectionView cellForItemAtIndexPath:indexPath];
        
        UIImageView *imageView  = [[toVC.view viewWithTag:100] viewWithTag:100];
        CGSize size = toVC.photoView.originalSize;
        
        UIView *snapshot        = [self resizedSnapshot:imageView size:size];
      
        CGPoint cellCenter  = [fromVC.view convertPoint:cellView.center fromView:cellView.superview];
        //        cellCenter = cellView.center;
        CGPoint snapCenter  = toVC.photoView.originalPoint;
        

        // Find the bounds of the snapshot mask
        float width         = snapshot.bounds.size.width;
        float height        = snapshot.bounds.size.height;
//        float length        = MIN(width, height);
        
        float scale_x       = width/cellView.frame.size.width;
        float scale_y       = height/cellView.frame.size.height;
        // Find the scales of snapshot
        CGRect startBounds  = [fromVC.view convertRect:cellView.frame fromView:fromVC.pickerCollectionView];
//        CGRect endBounds  = snapshot.frame;

        snapshot.center     = cellCenter;
        snapshot.frame = startBounds;
        
        toVC.view.frame     = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha     = 0;
        
        // Add to container view
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapshot];
        
        
        containerView.backgroundColor = [UIColor blackColor];
        
        // Animate
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromVC.view.alpha          = 0;
                             snapshot.transform         = CGAffineTransformMakeScale(scale_x, scale_y);
//                             snapshot.layer.mask.bounds = endBounds;
                             snapshot.center            = snapCenter;
                         }
                         completion:^(BOOL finished){
                             toVC.view.alpha   = 1;
                             [snapshot removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
    
    else
    {
        XWAssetsPikerEditViewController *fromVC  = (XWAssetsPikerEditViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        XWAssetsGroupViewController *toVC        = (XWAssetsGroupViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
 
        NSIndexPath *indexPath              = fromVC.indexPath;
        
        // Scroll to index path
        [toVC.pickerCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [toVC.pickerCollectionView layoutIfNeeded];
        
        UIView *cellView        = [toVC.pickerCollectionView cellForItemAtIndexPath:indexPath];
        cellView.backgroundColor = [UIColor blackColor];
        
        UIImageView *imageView  = [[fromVC.view viewWithTag:100] viewWithTag:100];
        CGSize size = fromVC.photoView.originalSize;
        
        UIView *snapshot        = [self resizedSnapshot:imageView size:size];
        
        CGPoint cellCenter  = [toVC.view convertPoint:cellView.center fromView:cellView.superview];
//        CGPoint snapCenter  = fromVC.view.center;
        
        // Find the bounds of the snapshot mask
        float width         = snapshot.bounds.size.width;
        float height        = snapshot.bounds.size.height;
        //        float length        = MIN(width, height);
        
        float scale_x       = cellView.frame.size.width*1.0/width;
        float scale_y       = cellView.frame.size.height*1.0/height;
        // Find the scales of snapshot
        CGRect startBounds  = snapshot.frame;
//        CGRect endBounds  = [toVC.view convertRect:cellView.frame fromView:toVC.pickerCollectionView];
        
        snapshot.center     = cellCenter;
        snapshot.frame = startBounds;
        
        toVC.view.frame     = [transitionContext finalFrameForViewController:toVC];
        toVC.view.alpha     = 0;
        
        // Add to container view
        [containerView addSubview:toVC.view];
        [containerView addSubview:snapshot];
        
        
        // Animate
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             toVC.view.alpha            = 1;
                             snapshot.transform         = CGAffineTransformMakeScale(scale_x, scale_y);
//                             snapshot.layer.mask.bounds = endBounds;
                             snapshot.center            = cellCenter;
                         }
                         completion:^(BOOL finished){
                             fromVC.view.alpha = 0;
                             [snapshot removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
}



#pragma mark - Snapshot

- (UIView *)resizedSnapshot:(UIImageView *)imageView size:(CGSize)size
{
    //    CGSize size = imageView.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    [[UIColor blackColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    [imageView.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return (UIView *)[[UIImageView alloc] initWithImage:resized];
}

@end
