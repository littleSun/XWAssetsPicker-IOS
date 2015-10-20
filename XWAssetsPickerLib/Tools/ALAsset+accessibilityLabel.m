//
//  ALAsset+accessibilityLabel.m
//  XWAssetsPicker
//
//  Created by 曾超 on 15/8/20.
//  Copyright (c) 2015年 小微软件. All rights reserved.
//

#import "ALAsset+accessibilityLabel.h"
#import "ALAsset+assetType.h"
#import "NSDateFormatter+timeIntervalFormatter.h"

@implementation ALAsset (accessibilityLabel)

- (NSString *)accessibilityLabel
{
    NSMutableArray *accessibilityLabels = [[NSMutableArray alloc] init];
    
    [accessibilityLabels addObject:[self typeAccessibilityLabel]];
    
    if ([self isVideo])
        [accessibilityLabels addObject:[self durationAccessibilityLabel]];
    
    [accessibilityLabels addObject:[self orientationAccessibilityLabel]];
    [accessibilityLabels addObject:[self dateAccessibilityLabel]];
    
    if (!self.defaultRepresentation)
        [accessibilityLabels addObject:@"不可用"];
    
    return [accessibilityLabels componentsJoinedByString:@", "];
}


- (NSString *)typeAccessibilityLabel
{
    if ([self isVideo]) {
        return @"视频";
    }

    return @"照片";
}

- (NSString *)durationAccessibilityLabel
{
    NSTimeInterval duration = [[self valueForProperty:ALAssetPropertyDuration] doubleValue];
    NSDateFormatter *df     = [[NSDateFormatter alloc] init];
    return [df spellOutStringFromTimeInterval:duration];
}

- (NSString *)orientationAccessibilityLabel
{
    CGSize dimension = self.defaultRepresentation.dimensions;
    
    if (dimension.height >= dimension.width) {
        return @"纵向";
    }
    
    return @"横向";
}

- (NSString *)dateAccessibilityLabel
{
    NSDate *date = [self valueForProperty:ALAssetPropertyDate];
    
    NSDateFormatter *df             = [[NSDateFormatter alloc] init];
    df.locale                       = [NSLocale currentLocale];
    df.dateStyle                    = NSDateFormatterMediumStyle;
    df.timeStyle                    = NSDateFormatterShortStyle;
    df.doesRelativeDateFormatting   = YES;
    
    return [df stringFromDate:date];
}

@end
