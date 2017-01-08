//
//  CommonTool.h
//  Rate-iOS
//
//  Created by lidaye on 8/4/16.
//  Copyright © 2016 MuShare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DateFormatYearMonthDayHourMinutes @"yyyy-MM-dd HH:mm"
#define DateFormatYearMonthDayHourMinutesSecond @"yyyy-MM-dd HH:mm:ss"
#define DateFormatYearMonthDay @"yyyy-MM-dd"
#define DateFormatYearMonthDayShort @"yy/MM/dd"
#define DateFormatMonthDayShort @"MM/dd"
#define DateFormatLocalMonth @"MMMM"
#define DateFormatMonth @"MM"
#define DateFormatDay @"dd"
#define DateFormatYear @"yyyy"
#define DateFormatLocalMonthYear @"MMMM, yyyy"

@interface CommonTool : NSObject

//Validate Tool
+ (BOOL)isInteger:(NSString *)str;
+ (BOOL)isNumeric:(NSString *)str;
+ (BOOL)isAvailableEmail:(NSString *)email;

//Date Tool
+ (NSUInteger)getNumberOfDaysInThisMonth:(NSDate *)date;

+ (NSDate *)getADayOfLastYear:(NSDate *)date;
+ (NSDate *)getADayOfNextYear:(NSDate *)date;

+ (NSDate *)getThisYearStart:(NSDate *)date;
+ (NSDate *)getThisYearEnd:(NSDate *)date;
+ (NSDate *)getThisMonthStart:(NSDate *)date;
+ (NSDate *)getThisMonthEnd:(NSDate *)date;
+ (NSDate *)getThisWeekStart:(NSDate *)date;
+ (NSDate *)getThisWeekEnd:(NSDate *)date;
+ (NSDate *)getThisDayStart:(NSDate *)date;
+ (NSDate *)getThisDayEnd:(NSDate *)date;

+ (NSDate *)getDateAfterNextDays:(int)days fromDate:(NSDate *)date;

+ (NSString *)formateDate:(NSDate *)date withFormat:(NSString *)format;

+ (long long)getUnixTimestamp:(NSDate *)date;
+ (NSDate *)dateWithUnixTimestamp:(long long)timestamp;

//Device info Tool
+ (NSString *)deviceName;
@end
