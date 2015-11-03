//
//  XWAssetsPikerViewController.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+assets.h"

UIKIT_EXTERN NSString *const XWAssetsChangedNotificationKey;

#define XWASSET_TITLE           @"相册"
#define PREVIEW_BTN_TITLE       @"预览"
#define SEND_BTN_TITLE          @"发送"

#define XWASSET_PIC_TAG         @"图片"
#define XWASSET_VIDEO_TAG       @"视频"

@class XWAssetsPikerViewController;

@protocol XWAssetsPickerControllerDelegate <NSObject>

@required
- (void)assetsPickerController:(XWAssetsPikerViewController *)picker didFinishPickingAssets:(NSArray *)assets;

@optional

- (void)assetsPickerControllerDidCancel:(XWAssetsPikerViewController *)picker;

/// @brief是否显示group
- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldShowAssetsGroup:(ALAssetsGroup *)group;

/// @brief是否显示asset
- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldShowAsset:(ALAsset *)asset;

/// @brief是否将要选择asset
- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldSelectAsset:(ALAsset *)asset;

/// @brief是否将要压缩asset
- (BOOL)assetsPickerController:(XWAssetsPikerViewController *)picker shouldCompressAsset:(ALAsset *)asset;


@end;

@interface XWAssetsPikerViewController : UIViewController


/**
 @brief 相册库,Library
 @discussion
 */
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;


/**
 @brief 筛选器,assetsFilter
 @discussion
 */
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

/**
 @brief 已经选择的,Selected Files
 @discussion
 */
@property (nonatomic, strong ,readonly) NSMutableArray *selectedAssets;

/**
 @brief 按钮主题颜色,ThemeColor
 @discussion
 */
@property (nonatomic, strong) UIColor *assetColor;

/**
 @brief 委托,delegate
 @discussion
 */
@property (nonatomic, assign) id <XWAssetsPickerControllerDelegate> delegate;

/**
 @brief 文件缓存地址,the file cache path
 @discussion
 */
@property (nonatomic, copy) NSString *cachePath;

/**
 @brief 是否打开滑动选择手势, default = YES
 @discussion
 */
@property (nonatomic, assign) BOOL openSlideSelectGesture;

/**
 @brief 标签, tag
 @discussion
 */
@property (nonatomic, assign) NSInteger tag;

/**
 @brief 是否自动写入缓存文件, isImageWriteToPath
 @discussion
 */
@property (nonatomic, assign) BOOL isImageWriteToPath;

/**
 @brief 已经选择数组的操作入口
 @discussion
 */
- (void)insertObject:(NSObject *)object;
- (void)replaceObjectInArrAtIndex:(NSInteger)index withObject:(NSObject *)object;
- (void)removeObjectFromArrAtIndex:(NSInteger)index;
- (void)removeObjectFromArr:(NSObject *)object;

@end
