//
//  ALAsset+assetType.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>



@interface ALAsset (assetType)

- (BOOL)isPhoto;
- (BOOL)isVideo;
- (BOOL)isGIF;

@end
