//
//  CommonTool.m
//  Rate-iOS
//
//  Created by lidaye on 8/4/16.
//  Copyright © 2016 MuShare. All rights reserved.
//

#import "CommonTool.h"
#import <sys/utsname.h>

@implementation CommonTool

+ (BOOL)isInteger:(NSString *)str {
    NSScanner *scanner = [NSScanner scannerWithString:str];
    int val;
    return [scanner scanInt:&val] && [scanner isAtEnd];
}

+ (BOOL)isNumeric:(NSString *)str {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    return !!number;
}

+ (BOOL)isAvailableEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(NSDate *)getADayOfLastYear:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                               fromDate:date];
    components.day = -1;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getADayOfNextYear:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                               fromDate:date];
    components.month = 12;
    components.day = 32;
    return [calendar dateFromComponents:components];
}

+(NSUInteger)getNumberOfDaysInThisMonth:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange daysRange = [calendar rangeOfUnit:NSCalendarUnitDay
                                       inUnit:NSCalendarUnitMonth
                                      forDate:date];
    return daysRange.length;
}

+(NSDate *)getThisYearStart:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                               fromDate:date];
    components.day=1;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisYearEnd:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                               fromDate:date];
    components.month = 12;
    components.day = 31;
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisMonthStart:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth
                                               fromDate:date];
    components.day = 1;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisMonthEnd:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth
                                               fromDate:date];
    components.day = [self getNumberOfDaysInThisMonth:date];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisWeekStart:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|
                                    NSCalendarUnitMonth|
                                    NSCalendarUnitDay|
                                    NSCalendarUnitWeekday
                                               fromDate:date];
    components.day-=components.weekday-1;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisWeekEnd:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear|
                                  NSCalendarUnitMonth|
                                  NSCalendarUnitDay|
                                  NSCalendarUnitWeekday
                                             fromDate:date];
    components.day+=7-components.weekday;
    components.hour=23;
    components.minute=59;
    components.second=59;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisDayStart:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear|
                                  NSCalendarUnitMonth|
                                  NSCalendarUnitDay
                                             fromDate:date];
    
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisDayEnd:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear|
                                  NSCalendarUnitMonth|
                                  NSCalendarUnitDay
                                             fromDate:date];
    components.hour=23;
    components.minute=59;
    components.second=59;
    return [calendar dateFromComponents:components];
}

+ (NSDate *)getDateAfterNextDays:(int)days fromDate:(NSDate *)date {
    return [date dateByAddingTimeInterval:60 * 60 * 24 * days];
}


+(NSDateComponents *)getDateComponents:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear|
                                  NSCalendarUnitMonth|
                                  NSCalendarUnitDay|
                                  NSCalendarUnitHour|
                                  NSCalendarUnitMinute|
                                  NSCalendarUnitSecond
                                             fromDate:date];
    return components;
}

+(NSString *)formateDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat: format];
    return [formatter stringFromDate:date];
}

+ (long long)getUnixTimestamp:(NSDate *)date {
    return (long long)([date timeIntervalSince1970] * 1000);
}

+ (NSDate *)dateWithUnixTimestamp:(long long)timestamp {
    
    return nil;
}


+ (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}
@end
