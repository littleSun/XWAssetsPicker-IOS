//
//  CompressHelp.m
//  XWAssetsPicker
//
//  Created by zengchao on 15/10/22.
//  Copyright © 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import "CompressHelp.h"
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+assets.h"
#import "ALAsset+assetType.h"
#import "XWAssetsPikerViewController.h"

@implementation CompressHelp

- (id)init
{
    if (self = [super init]) {
        //...
        self.results = [NSMutableArray array];
        dispatchQueue = dispatch_queue_create("compress.queue.next", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

//compress
- (BOOL)compressAssetInfo:(ALAsset *)asset execute:(BOOL)isExecuted
{
    if ([asset isGIF]) {
        
        dispatch_group_enter(compressGroup);
        
        dispatch_async(dispatchQueue, ^(){
            [self compressGIF:asset execute:isExecuted];
        });
        return YES;
    }
    else if ([asset isPhoto]) {
        
        dispatch_group_enter(compressGroup);
        
        dispatch_async(dispatchQueue, ^(){
            [self compressPNG:asset execute:isExecuted];
        });
        return YES;
    }
    else if ([asset isVideo]) {
        
        dispatch_group_enter(compressGroup);
        
        dispatch_async(dispatchQueue, ^(){
            
            [self convertToMp4:asset execute:isExecuted];
        });
        
        return YES;
    }
    return NO;
}

- (UIImage *)zoomFileSize:(UIImage *)image
{
    CGFloat scale = 1.0;
    
    NSData *tmpData = UIImagePNGRepresentation(image);
    
    if (tmpData.length > 0.5*1024*1024) {
        scale = (0.5*1024*1024)/tmpData.length;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, scale);
    
    UIImage *imaged = [UIImage imageWithData:data];
    
    return imaged;
}

- (void)compressGIF:(ALAsset *)asset execute:(BOOL)isExecuted
{
    //    __weak XWAssetsPikerViewController *weakSelf = self;
    //    __block NSMutableDictionary *info_ = info;
    ALAssetRepresentation *rep = asset.defaultRepresentation;
    
    Byte *imageBuffer = (Byte*)malloc((size_t)rep.size);
    NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:(long)rep.size error:nil];
    NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
    
    UIImage *imaged = [UIImage animatedGIFWithData:imageData isCompress:isExecuted];
    
    if (imaged) {
        NSString *imagePath = self.picker.cachePath;
        imagePath = [imagePath stringByAppendingFormat:@"/%@-image.gif", [[NSUUID UUID] UUIDString]];
        
        [imageData writeToFile:imagePath atomically:YES];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:(NSString *)kUTTypeImage forKey:UIImagePickerControllerMediaType];
        [info setObject:imaged forKey:UIImagePickerControllerOriginalImage];
        
        if (self.picker.isImageWriteToPath) {
            [info setObject:[NSURL fileURLWithPath:imagePath] forKey:UIImagePickerControllerMediaURL];
            NSData *data = [UIImage animatedDataWithGIF:imaged];
            [data writeToFile:imagePath atomically:YES];
        }
        
        [self.results addObject:info];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        dispatch_group_leave(compressGroup);
    });
}

- (void)compressPNG:(ALAsset *)asset execute:(BOOL)isExecuted
{
    
    UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    
    if (image) {
        
        UIImage *imaged = nil;
        
        CGFloat widthScale = image.size.width/[UIScreen mainScreen].bounds.size.width;
        CGFloat heightScale = image.size.height/[UIScreen mainScreen].bounds.size.height;
        
        if (widthScale > 1.0 && heightScale > 1.0) {
            //
            CGFloat minScale = MIN(widthScale, heightScale);
            imaged = [image scaleToSize:CGSizeMake(image.size.width/minScale, image.size.height/minScale)];
        }
        else {
            imaged = image;
        }
        
        if (isExecuted) {
            imaged = [self zoomFileSize:imaged];
        }
        
        NSString *imagePath = self.picker.cachePath;
        imagePath = [imagePath stringByAppendingFormat:@"/%@-image.jpg", [[NSUUID UUID] UUIDString]];
        
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:(NSString *)kUTTypeImage forKey:UIImagePickerControllerMediaType];
        [info setObject:imaged forKey:UIImagePickerControllerOriginalImage];
        
        if (self.picker.isImageWriteToPath) {
            [info setObject:[NSURL fileURLWithPath:imagePath] forKey:UIImagePickerControllerMediaURL];
            NSData *data = [UIImage animatedDataWithGIF:imaged];
            [data writeToFile:imagePath atomically:YES];
        }
        
        [self.results addObject:info];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        dispatch_group_leave(compressGroup);
    });
}

- (void)convertToMp4:(ALAsset *)asset execute:(BOOL)isExecuted
{
    __weak CompressHelp *weakSelf = self;
    
    NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    if ([url.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
        
        NSString *mp4Path = self.picker.cachePath;
        mp4Path = [mp4Path stringByAppendingFormat:@"/%@-video.mp4", [[NSUUID UUID] UUIDString]];
        
        //        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtURL:url toURL:[NSURL fileURLWithPath:mp4Path] error:NULL];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:(NSString *)kUTTypeMovie forKey:UIImagePickerControllerMediaType];
        [info setObject:[NSURL fileURLWithPath:mp4Path] forKey:UIImagePickerControllerMediaURL];
        
        [weakSelf.results addObject:info];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            dispatch_group_leave(compressGroup);
        });
        
        return;
    }
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    
    NSString *mp4Path = self.picker.cachePath;
    mp4Path = [mp4Path stringByAppendingFormat:@"/%@-video.mp4", [[NSUUID UUID] UUIDString]];
    
    exportSession.outputURL = [NSURL fileURLWithPath: mp4Path];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                break;
            case AVAssetExportSessionStatusCancelled:
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                [info setObject:(NSString *)kUTTypeMovie forKey:UIImagePickerControllerMediaType];
                [info setObject:[NSURL fileURLWithPath:mp4Path] forKey:UIImagePickerControllerMediaURL];
                
                [weakSelf.results addObject:info];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //
                    dispatch_group_leave(compressGroup);
                });
                
            }
                break;
            default:
                break;
        }
    }];
}

- (void)beginCompress
{
    [self.results removeAllObjects];
    
    self.isCompressing = YES;
    
    if (compressGroup) {
        compressGroup = NULL;
    }
    compressGroup = dispatch_group_create();
}

- (void)compressToEnd:(CompressHelpDidEndBlock)completed
{
    self.complete = completed;
    
    __weak CompressHelp *weakSelf = self;
    
    
    dispatch_group_notify(compressGroup, dispatch_get_main_queue(), ^{
        //
        __strong CompressHelp *strongSelf = weakSelf;
        
        strongSelf.isCompressing = NO;
        
        if (strongSelf.complete) {
            strongSelf.complete(strongSelf.results);
        }
    });
}

@end
