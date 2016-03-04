//
//  NSDate+ZJSetCalendar.h
//  T
//
//  Created by Jion on 15/11/5.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ZJSetCalendar)

+(NSDate*)myDate;//获得本土时间

//首先需要知道这个月有多少天
- (NSUInteger)numberOfDaysInCurrentMonth;
//确定这个月的第一天是星期几。这样就能知道给定月份的第一周有几天
- (NSDate *)firstDayOfCurrentMonth;
- (NSUInteger)weeklyOrdinality;
//减去第一周的天数，剩余天数除以7，得到倍数和余数
- (NSUInteger)numberOfWeeksInCurrentMonth;

//上一个月份
-(NSDate *)getPreviousframDate:(NSDate *)date;
//下一个月份
-(NSDate *)getNextMonthframDate:(NSDate*)date;

-(int)getYear;
-(int)getMonth;
-(int)getDay;
@end
