//
//  XWAssetsPikerEditViewController.h
//  XWAssetsPicker
//
//  Created by zengchao on 15/12/4.
//  Copyright © 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWAssetScrollView.h"

@interface XWAssetsPikerEditViewController : UIViewController

@property (nonatomic, weak) id<XWAssetScrollViewDelegate> delegate;

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL isPreview;

@end
