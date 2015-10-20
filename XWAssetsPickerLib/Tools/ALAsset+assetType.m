//
//  ALAsset+assetType.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "ALAsset+assetType.h"



@implementation ALAsset (assetType)

- (BOOL)isPhoto
{
    return [[self valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto];
}

- (BOOL)isVideo
{
    return [[self valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo];
}

- (BOOL)isGIF
{
    if ([self isPhoto]) {
        //
        NSURL *url = [self valueForProperty:ALAssetPropertyAssetURL];
        
        if ([url.pathExtension.uppercaseString isEqualToString:@"GIF"]) {
            return YES;
        }
    }
    return NO;
}

@end
