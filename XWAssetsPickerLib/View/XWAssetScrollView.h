//
//  XWAssetScrollView.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "XWAssetItemViewController.h"

@class XWAssetScrollView;
@protocol XWAssetScrollViewDelegate <NSObject>

- (void)xwAssetScrollViewTap:(XWAssetScrollView *)target;
//- (void)xwAssetScrollViewDoubleTap:(XWAssetScrollView *)target;;
@end


extern NSString * const CTAssetScrollViewTappedNotification;



@interface XWAssetScrollView : UIScrollView

@property (nonatomic, weak) id <XWAssetScrollViewDelegate> adelegate;
@property (nonatomic, weak) id <XWAssetItemViewControllerDataSource> dataSource;
@property (nonatomic) NSUInteger index;

@end