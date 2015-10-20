//
//  XWAssetsSupplementaryView.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface XWAssetsSupplementaryView : UICollectionReusableView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)bind:(ALAssetsGroup *)group andAsset:(NSArray *)assets;


@end
