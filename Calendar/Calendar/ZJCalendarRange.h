//
//  ZJCalendarRange.h
//  T
//
//  Created by Jion on 15/11/13.
//  Copyright © 2015年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJCalendarRange : NSObject
@property (nonatomic,copy)NSDateComponents *startDay;
@property (nonatomic,copy)NSDateComponents *endDay;

- (id)initWithStartDay:(NSDateComponents*)startDay endDay:(NSDateComponents *)endDay;
- (BOOL)containsDate:(NSDate*)date;
- (BOOL)containsDay:(NSDateComponents*)day;
@end
