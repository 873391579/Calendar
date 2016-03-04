//
//  ZJCalendarRange.m
//  T
//
//  Created by Jion on 15/11/13.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import "ZJCalendarRange.h"

@implementation ZJCalendarRange
{
    __strong NSDate   *_startDate;
    __strong NSDate   *_endDate;
}

#pragma mark--init
- (id)initWithStartDay:(NSDateComponents*)startDay endDay:(NSDateComponents *)endDay
{
    NSParameterAssert(startDay);
    NSParameterAssert(endDay);
    
    self = [super init];
    if (self != nil) {
        _startDay = [startDay copy];
        _startDate = _startDay.date;
        _endDay = [endDay copy];
        _endDate = _endDay.date;
    }
    return self;
}

#pragma mark--日期比较
- (BOOL)containsDate:(NSDate*)date
{
    //NSOrderedDescending降序，NSOrderedAscending升序
    if ([_startDate compare:date] == NSOrderedDescending) {
        return NO;
    }else if ([_endDate compare:date] == NSOrderedAscending)
    {
        return NO;
    }
    
    return YES;
}
- (BOOL)containsDay:(NSDateComponents*)day {
    return [self containsDate:day.date];
}

#pragma mark--Setter
- (void)setStartDay:(NSDateComponents *)startDay
{
    NSParameterAssert(startDay);
    _startDay = startDay;
}
- (void)setEndDay:(NSDateComponents *)endDay
{
    NSParameterAssert(endDay);
    _endDay = endDay;
}

@end
