//
//  UIImage+assets.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "UIImage+assets.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation UIImage (assets)

+ (UIImage *)animatedGIFWithData:(NSData *)data isCompress:(BOOL)isCompress {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            
            CGImageRef image = nil;
            
            if (isCompress) {
                NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithCapacity:3];
                [options setObject:[NSNumber numberWithBool:YES] forKey:(id)kCGImageSourceCreateThumbnailFromImageAlways];
                [options setObject:[NSNumber numberWithFloat:160] forKey:(id)kCGImageSourceThumbnailMaxPixelSize];
                [options setObject:[NSNumber numberWithBool:NO] forKey:(id)kCGImageSourceCreateThumbnailWithTransform];
                image = CGImageSourceCreateThumbnailAtIndex(source, i, (__bridge CFDictionaryRef)options);
            }
            else {
                image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            }
            
            duration += [self frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (NSData *)animatedDataWithGIF:(UIImage *)image
{
    if (!image.images) {
        return UIImageJPEGRepresentation(image, 1);
    }
    
    size_t frameCount = image.images.count;
    NSTimeInterval frameDuration = (/* DISABLES CODE */ (0) <= 0.0 ? image.duration / frameCount : 0);
    NSDictionary *frameProperties = @{
                                      (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                              (__bridge NSString *)kCGImagePropertyGIFDelayTime: @(frameDuration)
                                              }
                                      };
    
    NSMutableData *mutableData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);
    
    NSDictionary *imageProperties = @{ (__bridge NSString *)kCGImagePropertyGIFDictionary: @{
                                               (__bridge NSString *)kCGImagePropertyGIFLoopCount: @(0)
                                               }
                                       };
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
    
    for (size_t idx = 0; idx < image.images.count; idx++) {
        CGImageDestinationAddImage(destination, [[image.images objectAtIndex:idx] CGImage], (__bridge CFDictionaryRef)frameProperties);
    }
    
    BOOL success = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    if (!success) {
        
    }
    
    return [NSData dataWithData:mutableData];
}


-(UIImage*)scaleToSize:(CGSize)size
{
    CGSize oldsize = self.size;
    
    CGRect rect;
    
    if (size.width/size.height > oldsize.width/oldsize.height) {
        rect.size.width = size.width;
        rect.size.height = size.width*oldsize.height/oldsize.width;
        rect.origin.x = -(size.width - rect.size.width)/2;
        rect.origin.y = 0;
    }
    else{
        rect.size.width = size.height*oldsize.width/oldsize.height;
        rect.size.height = size.height;
        rect.origin.x = 0;
        rect.origin.y = -(size.height - rect.size.height)/2;
    }
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    UIRectFill(CGRectMake(0, 0, size.width, size.height));//clear background
    [self drawInRect:rect];
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimage;
}

+ (UIImage *)imageFromAssetBundle:(NSString *)name
{
    if (name) {
        NSString *file_name = [NSString stringWithFormat:@"%@/%@.png",@"XWAssetsResource.bundle",name];
        NSString *image_url = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file_name];
        
        return [UIImage imageWithContentsOfFile:image_url];
    }
    return nil;
}

//+ (UIImage *)assetImageFromColor:(UIColor *)color {
//    CGRect rect = CGRectMake(0, 0, 1, 1);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

@end
