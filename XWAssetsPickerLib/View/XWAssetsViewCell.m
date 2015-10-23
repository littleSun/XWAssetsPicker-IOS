//
//  XWAssetsViewCell.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "XWAssetsViewCell.h"
#import "ALAsset+assetType.h"
#import "ALAsset+accessibilityLabel.h"
#import "NSDateFormatter+timeIntervalFormatter.h"
#import "UIImage+created.h"
#import <Photos/Photos.h>

@interface XWAssetsViewCell ()
{

    UIImageView *imageView;
    
    UIImageView *tagIcon;
    UIImageView *checkedImageView;
    UILabel *durationLb;
    
}
@end

@implementation XWAssetsViewCell

- (void)setup
{
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageView.layer.masksToBounds = YES;
    [self.contentView addSubview:imageView];
    
    durationLb = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20)];
    durationLb.textColor = [UIColor whiteColor];
    durationLb.font = [UIFont systemFontOfSize:13];
    durationLb.textAlignment = NSTextAlignmentRight;
    durationLb.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self.contentView addSubview:durationLb];
    
    tagIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.frame.size.height-20, 20, 20)];
    tagIcon.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:tagIcon];
    
    checkedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-35, 0, 35, 35)];
    checkedImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:checkedImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.contentView addGestureRecognizer:tap];
//    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _selectBtn.userInteractionEnabled = NO;
//    self.selectBtn.exclusiveTouch = YES;
//    self.selectBtn.frame = CGRectMake(self.frame.size.width-40, 0, 40, 40);
//    [self.contentView addSubview:self.selectBtn];
//    [self.selectBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick:(id)sender
{
    if (self.delegate && [_delegate respondsToSelector:@selector(xwAssetsViewCellChecked:)]) {
        [self.delegate xwAssetsViewCellChecked:self];
    }
}

- (id)init
{
    if (self = [super init])
    {
        self.opaque                 = YES;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits    = UIAccessibilityTraitImage;
        self.enabled                = YES;
        
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                 = YES;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits    = UIAccessibilityTraitImage;
        self.enabled                = YES;
        
        [self setup];
    }
    
    return self;
}

- (void)tap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];

    CGRect rect = CGRectMake(self.frame.size.width-35, 0, 35, 35);
    
    if (CGRectContainsPoint(rect, point)) {
        //
        if (self.delegate && [_delegate respondsToSelector:@selector(xwAssetsViewCellChecked:)]) {
            [self.delegate xwAssetsViewCellChecked:self];
        }
    }
    else {
        if (self.delegate && [_delegate respondsToSelector:@selector(xwAssetsViewCellTap:)]) {
            [self.delegate xwAssetsViewCellTap:self];
        }
    }
    
}

///@brief 绑定Asset
- (void)bind:(ALAsset *)asset
{    
    self.asset  = asset;
    imageView.image  = [UIImage imageWithCGImage:asset.thumbnail];
    
    if ([self.asset isVideo]) {
        durationLb.hidden   = NO;
        tagIcon.image = [UIImage imageFromBundle:@"asset_video_icon"];
        
        static NSDateFormatter *df = nil;
        if (!df) {
            df = [[NSDateFormatter alloc] init];
        }
        
        durationLb.text = [df stringFromTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
        tagIcon.image       = [UIImage imageFromBundle:@"asset_video_icon"];
    }
    else if ([self.asset isGIF]) {
        durationLb.hidden   = YES;
        tagIcon.image       = [UIImage imageFromBundle:@"asset_gif_icon"];
    }
    else {
        durationLb.hidden = YES;
        tagIcon.image = nil;
    }
    
    if (self.isAssetSelected) {
        checkedImageView.image = [UIImage imageFromBundle:@"asset_select_icon"];
    }
    else {
        checkedImageView.image = [UIImage imageFromBundle:@"asset_unselect_icon"];
    }
}

#pragma mark - Accessibility Label

- (NSString *)accessibilityLabel
{
    return self.asset.accessibilityLabel;
}


@end
