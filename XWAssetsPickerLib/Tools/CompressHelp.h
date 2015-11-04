//
//  CompressHelp.h
//  XWAssetsPicker
//
//  Created by zengchao on 15/10/22.
//  Copyright © 2015年 com.xweisoft.xwtest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^CompressHelpDidEndBlock)(NSArray *compressResults);

@class XWAssetsPikerViewController;

@interface CompressHelp : NSObject
{
    dispatch_group_t compressGroup;
    dispatch_queue_t dispatchQueue;
}
@property (nonatomic ,weak) XWAssetsPikerViewController * picker;

@property (nonatomic ,assign) BOOL isCompressing;

@property (nonatomic ,strong) NSMutableArray *results;

@property (nonatomic ,strong) CompressHelpDidEndBlock complete;

- (BOOL)compressAssetInfo:(ALAsset *)asset execute:(BOOL)isExecuted;

- (void)beginCompress;
- (void)compressToEnd:(CompressHelpDidEndBlock)completed;

@end
