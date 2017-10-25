//
//  UIImage+assets.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (assets)

+ (UIImage *)animatedGIFWithData:(NSData *)data isCompress:(BOOL)isCompress;

+ (NSData *)animatedDataWithGIF:(UIImage *)image;

+ (UIImage *)imageFromAssetBundle:(NSString *)name;

-(UIImage*)assetScaleToSize:(CGSize)size;

@end
