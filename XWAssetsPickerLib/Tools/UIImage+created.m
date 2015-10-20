//
//  UIImage+XWExtend.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "UIImage+created.h"

@implementation UIImage (created)


+ (UIImage *)imageWithColor:(UIColor *)color {

    UIImage *image = [UIImage imageWithSize:CGSizeMake(1, 1) AndColor:color];
    
    return image;
}

+ (UIImage *)imageWithSize:(CGSize)size AndColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)circleImageWithParam:(CGFloat)inset AndColor:(UIColor *)color
{
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);

    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:inset] addClip];
    CGContextStrokePath(context);
    
    [self drawInRect:rect];

    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}


@end
