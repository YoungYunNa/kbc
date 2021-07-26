//
//  NSDate+Utils.m
//  MOBILE002
//
//  Created by Lee SeungWoo on 13. 10. 16..
//  Copyright (c) 2013년 woohaha. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (NSInteger)numDaysInMonth
{
    NSCalendar* cal = [NSCalendar currentCalendar];
	
    NSRange rng = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    NSUInteger numberOfDaysInMonth = rng.length;
	
    return numberOfDaysInMonth;
}

- (NSInteger)firstWeekDayInMonth
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    
    NSDateComponents* comps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:self];
    [comps setDay:1];
    NSDate* newDate = [cal dateFromComponents:comps];
	
    return [cal ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:newDate];
}

- (NSInteger)year
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comps = [cal components:NSCalendarUnitYear fromDate:self];
    return [comps year];
}

- (NSInteger)month
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comps = [cal components:NSCalendarUnitMonth fromDate:self];
    return [comps month];
}

- (NSInteger)day
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comps = [cal components:NSCalendarUnitDay fromDate:self];
    return [comps day];
}

- (NSDate*)offsetMonth:(int)numMonths
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    [cal setFirstWeekday:1];
    
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:numMonths];
	
    return [cal dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate*)offsetDay:(int)numDays
{
	NSCalendar* cal = [NSCalendar currentCalendar];
	[cal setFirstWeekday:1];
	
	NSDateComponents* comps = [[NSDateComponents alloc] init];
	[comps setDay:numDays];
	
	return [cal dateByAddingComponents:comps toDate:self options:0];
}

@end
