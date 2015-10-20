//
//  XWAssetsGroupViewController.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XWToolBar.h"

@interface XWAssetsGroupViewController : UIViewController

@property (nonatomic ,strong) UICollectionView *pickerCollectionView;

@property (nonatomic ,strong) XWToolBar *assetToolBar;

@end
