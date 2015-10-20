/*
 NSDateFormatter+timeIntervalFormatter.m
 */

#import "NSDateFormatter+timeIntervalFormatter.h"

@implementation NSDateFormatter (timeIntervalFormatter)

- (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval
{
    NSDateComponents *components = [self dateComponetsWithTimeInterval:timeInterval];
    NSInteger roundedSeconds = lround(timeInterval - (components.hour * 60 * 60) - (components.minute * 60));
    
    if (components.hour > 0)
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)roundedSeconds];
    
    else
        return [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)roundedSeconds];
}

- (NSString *)spellOutStringFromTimeInterval:(NSTimeInterval)timeInterval
{
    NSString *string = @"";
    
    NSDateComponents *components = [self dateComponetsWithTimeInterval:timeInterval];
    
    if (components.hour > 0)
        string = [string stringByAppendingFormat:@"%ld %@",
                  (long)components.hour,
                  (components.hour > 1) ?
                  (@"小时") :
                  (@"小时")];
    
    if (components.minute > 0)
        string = [string stringByAppendingFormat:@"%ld %@",
                  (long)components.minute,
                  (components.minute > 1) ?
                  (@"分钟") :
                  (@"分钟")];
    
    if (components.second > 0)
        string = [string stringByAppendingFormat:@"%ld %@",
                  (long)components.second,
                  (components.second > 1) ?
                  (@"秒") :
                  (@"秒")];
    
    return string;
}

- (NSDateComponents *)dateComponetsWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:date1];
    
    unsigned int unitFlags =
    NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour |
    NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    
    return [calendar components:unitFlags
                       fromDate:date1
                         toDate:date2
                        options:0];
}

@end
