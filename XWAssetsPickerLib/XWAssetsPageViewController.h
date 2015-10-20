//
//  XWAssetsPageViewController.h
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
 

#import <UIKit/UIKit.h>

@interface XWAssetsPageViewController : UIPageViewController
{
    UIButton *barButton;
}
/**
 *  The index of the photo or video with the currently showing item.
 */
@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, assign) BOOL isPreview;

- (id)initWithAssets:(NSArray *)assets;

@end