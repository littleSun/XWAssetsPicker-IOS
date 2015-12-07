//
//  XWAssetsViewCell.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class XWAssetsViewCell;
@protocol XWAssetsViewCellDelegate <NSObject>

//- (void)xwAssetsViewCellBegan:(XWAssetsViewCell *)target;
- (void)xwAssetsViewCellChecked:(XWAssetsViewCell *)target;
- (void)xwAssetsViewCellTap:(XWAssetsViewCell *)target;
@end


@interface XWAssetsViewCell : UICollectionViewCell

@property (nonatomic ,assign) id <XWAssetsViewCellDelegate> delegate;

@property (nonatomic ,strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

@property (nonatomic, assign, getter = isAssetSelected) BOOL assetSelected;

@property (nonatomic, assign, getter = isCanEdit) BOOL canEdit;

@property (nonatomic, strong) ALAsset *asset;

- (void)bind:(ALAsset *)asset;


@end
