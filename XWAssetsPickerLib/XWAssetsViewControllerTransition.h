//
//  XWAssetsViewControllerTransition
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.

#import <UIKit/UIKit.h>

@interface XWAssetsViewControllerTransition : NSObject
<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) UINavigationControllerOperation operation;

@end

@interface XWAssetsViewControllerTransition2 : NSObject
<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) UINavigationControllerOperation operation;

@end
