//
//  DateTool.m
//  AccountManagement
//
//  Created by 李大爷 on 15/5/23.
//  Copyright (c) 2015年 李大爷. All rights reserved.
//

#import "DateTool.h"

@implementation DateTool

+(NSDate *)getADayOfLastYear:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear
                                             fromDate:date];
    components.day=-1;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getADayOfNextYear:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear
                                             fromDate:date];
    components.month=12;
    components.day=32;
    return [calendar dateFromComponents:components];
}

+(NSUInteger)getNumberOfDaysInThisMonth:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSRange daysRange=[calendar rangeOfUnit:NSCalendarUnitDay
                                     inUnit:NSCalendarUnitMonth
                                    forDate:date];
    return daysRange.length;
}

+(NSDate *)getThisYearStart:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear
                                             fromDate:date];
    components.day=1;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisYearEnd:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear
                                             fromDate:date];
    components.month=12;
    components.day=31;
    components.hour=23;
    components.minute=59;
    components.second=59;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisMonthStart:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear|NSCalendarUnitMonth
                                             fromDate:date];
    components.day=1;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisMonthEnd:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear|NSCalendarUnitMonth
                                             fromDate:date];
    components.day=[self getNumberOfDaysInThisMonth:date];
    components.hour=23;
    components.minute=59;
    components.second=59;
    return [calendar dateFromComponents:components];
}

+(NSDate *)getThisWeekStart:(NSDate *)date {
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *components=[calendar components:NSCalendarUnitYear|
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

@end
