//
//  XWAssetItemViewController.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class XWAssetScrollView;
@protocol XWAssetScrollViewDelegate;

@protocol XWAssetItemViewControllerDataSource <NSObject>
@required
- (ALAsset *)assetAtIndex:(NSUInteger)index;

@end
@interface XWAssetItemViewController : UIViewController

+ (XWAssetItemViewController *)assetItemViewControllerForPageIndex:(NSInteger)pageIndex;

//@property (nonatomic, strong) XWAssetScrollView *scrollView;
@property (nonatomic, weak) id<XWAssetScrollViewDelegate> delegate;
@property (nonatomic, weak) id<XWAssetItemViewControllerDataSource> dataSource;
@property (nonatomic, assign) NSInteger pageIndex;

@end






