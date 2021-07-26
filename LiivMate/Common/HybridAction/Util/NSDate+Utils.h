//
//  NSDate+Utils.h
//  MOBILE002
//
//  Created by Lee SeungWoo on 13. 10. 16..
//  Copyright (c) 2013년 woohaha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

- (NSInteger)numDaysInMonth;
- (NSInteger)firstWeekDayInMonth;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSDate*)offsetMonth:(int)numMonths;
- (NSDate*)offsetDay:(int)numDays;

@end
