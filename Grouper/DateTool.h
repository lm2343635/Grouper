//
//  DateTool.h
//  AccountManagement
//
//  Created by 李大爷 on 15/5/23.
//  Copyright (c) 2015年 李大爷. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DateFormatYearMonthDayHourMinutes @"yyyy-MM-dd HH:mm"
#define DateFormatYearMonthDayHourMinutesSecond @"yyyy-MM-dd HH:mm:ss"
#define DateFormatYearMonthDay @"yyyy-MM-dd"
#define DateFormatLocalMonth @"MMMM"
#define DateFormatMonth @"MM"
#define DateFormatDay @"dd"
#define DateFormatYear @"yyyy"
#define DateFormatLocalMonthYear @"MMMM, yyyy"

@interface DateTool : NSObject

+(NSUInteger)getNumberOfDaysInThisMonth:(NSDate *)date;

+(NSDate *)getADayOfLastYear:(NSDate *)date;
+(NSDate *)getADayOfNextYear:(NSDate *)date;

+(NSDate *)getThisYearStart:(NSDate *)date;
+(NSDate *)getThisYearEnd:(NSDate *)date;
+(NSDate *)getThisMonthStart:(NSDate *)date;
+(NSDate *)getThisMonthEnd:(NSDate *)date;
+(NSDate *)getThisWeekStart:(NSDate *)date;
+(NSDate *)getThisWeekEnd:(NSDate *)date;
+(NSDate *)getThisDayStart:(NSDate *)date;
+(NSDate *)getThisDayEnd:(NSDate *)date;

+(NSDateComponents *)getDateComponents:(NSDate *)date;

+(NSString *)formateDate:(NSDate *)date withFormat:(NSString *)format;

@end
