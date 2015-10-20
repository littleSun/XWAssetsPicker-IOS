//
//  XWAssetsSupplementaryView.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "XWAssetsSupplementaryView.h"
#import "ALAssetsGroup+attribute.h"

@implementation XWAssetsSupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _imageView = [self supplementaryImageView];
        [self addSubview:_imageView];
        
        _titleLabel = [self supplementaryTitleLabel];
        [self addSubview:_titleLabel];
        
        _countLabel = [self supplementaryLabel];
        [self addSubview:_countLabel];
    }
    
    return self;
}

- (UILabel *)supplementaryTitleLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.height+4, 5, 120, self.frame.size.height-6)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18.0];
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];

    return label;
}

- (UILabel *)supplementaryLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-4-160, 5, 160, self.frame.size.height-6)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18.0];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor blackColor];

    return label;
}

- (UIImageView *)supplementaryImageView
{
    UIImageView *imagev = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.height-10, self.frame.size.height-10)];
    imagev.layer.masksToBounds = YES;
    imagev.layer.cornerRadius = (self.frame.size.height-10)*0.5;
    
    return imagev;
}



- (void)bind:(ALAssetsGroup *)group andAsset:(NSArray *)assets
{
    NSInteger numberOfVideos = [assets filteredArrayUsingPredicate:[self predicateOfAssetType:ALAssetTypeVideo]].count;
    NSInteger numberOfPhotos = [assets filteredArrayUsingPredicate:[self predicateOfAssetType:ALAssetTypePhoto]].count;
    
    if (numberOfVideos == 0)
        self.countLabel.text = [NSString stringWithFormat:@"%d 图片", (int)numberOfPhotos];
    else if (numberOfPhotos == 0)
        self.countLabel.text = [NSString stringWithFormat:@"%d 视频", (int)numberOfVideos];
    else
        self.countLabel.text = [NSString stringWithFormat:@"%d 图片, %d 视频", (int)numberOfPhotos, (int)numberOfVideos];
    
    self.titleLabel.text = group.title;
    self.imageView.image = [UIImage imageWithCGImage:group.posterImage];
}

- (NSPredicate *)predicateOfAssetType:(NSString *)type
{
    return [NSPredicate predicateWithBlock:^BOOL(ALAsset *asset, NSDictionary *bindings) {
        return [[asset valueForProperty:ALAssetPropertyType] isEqual:type];
    }];
}


@end
