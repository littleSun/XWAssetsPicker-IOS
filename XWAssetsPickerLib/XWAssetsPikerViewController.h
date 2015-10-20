//
//  XWAssetsPikerViewController.h
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

UIKIT_EXTERN NSString *const XWAssetsChangedNotificationKey;

/**
 @method
 @brief 以文件路径构造文件对象
 @discussion
 @param filePath 磁盘文件全路径
 @param displayName 文件对象的显示名
 @result 文件对象
 */

@interface XWAssetsPikerViewController : UIViewController

/**
 @brief 相册库
 @discussion
 */
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

/**
 @brief 筛选器
 @discussion
 */
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

/**
 @brief 已经选择的
 @discussion
 */
@property (nonatomic, strong ,readonly) NSMutableArray *selectedAssets;

/**
 @brief 按钮主题颜色
 @discussion
 */
@property (nonatomic, strong) UIColor *assetColor;

/**
 @brief 已经选择数组的操作入口
 @discussion
 */
- (void)insertObject:(NSObject *)object;
- (void)replaceObjectInArrAtIndex:(NSInteger)index withObject:(NSObject *)object;
- (void)removeObjectFromArrAtIndex:(NSInteger)index;
- (void)removeObjectFromArr:(NSObject *)object;

@end
