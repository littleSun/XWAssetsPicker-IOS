/*
 NSDateFormatter+timeIntervalFormatter.h
 */

#import <Foundation/Foundation.h>

@interface NSDateFormatter (timeIntervalFormatter)

- (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval;
- (NSString *)spellOutStringFromTimeInterval:(NSTimeInterval)timeInterval;

@end
