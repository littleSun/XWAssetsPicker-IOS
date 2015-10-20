//
//  UIImage+XWExtend.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (created)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithSize:(CGSize)size AndColor:(UIColor *)color;

- (UIImage *)circleImageWithParam:(CGFloat)inset AndColor:(UIColor *)color;

@end
