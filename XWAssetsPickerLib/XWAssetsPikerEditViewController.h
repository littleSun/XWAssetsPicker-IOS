//
//  XWAssetsPikerEditViewController.h
//  XWAssetsPicker
//
//  Created by zengchao on 15/12/4.
//  Copyright © 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWAssetScrollView.h"

@class XWAssetsPikerEditViewController;
@protocol XWAssetsPikerEditVCDelegate <NSObject>

- (void)assetsPikerEditViewController:(XWAssetsPikerEditViewController *)target output:(UIImage *)image;

@end


@interface XWAssetsPikerEditViewController : UIViewController

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL isPreview;

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) id <XWAssetsPikerEditVCDelegate> delegate;

@end
