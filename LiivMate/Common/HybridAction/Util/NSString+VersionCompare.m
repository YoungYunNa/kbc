//
//  NSString+VersionCompare.m
//  NewKBCardShop
//
//  Created by Lee SeungWoo on 13. 2. 15..
//

#import "NSString+VersionCompare.h"


@implementation NSString (VersionCompare)

//////////////////////////////////////////////////////////////////////////////////
/*
enum {
	NSOrderedAscending = -1,	// The left operand is smaller than the right operand.	<
	NSOrderedSame,				// The two operands are equal.							==
	NSOrderedDescending			// The left operand is greater than the right operand.	>
};
typedef NSInteger NSComparisonResult;
*/
//////////////////////////////////////////////////////////////////////////////////

- (NSComparisonResult)versionCompare:(NSString*)versionString
{
	NSArray* componentLeft = [self componentsSeparatedByString:@"."];
	NSArray* componentRight = [versionString componentsSeparatedByString:@"."];
	
	if ([componentLeft count] == 1 && [componentRight count] == 1)
		return [[NSNumber numberWithInt:[self intValue]] compare:[NSNumber numberWithInt:[versionString intValue]]];
	
	NSInteger nCount = MIN([componentLeft count], [componentRight count]);
	for (int i = 0; i < nCount; ++i)
	{
		NSComparisonResult compResult = [[NSNumber numberWithInt:[[componentLeft objectAtIndex:i] intValue]] compare:[NSNumber numberWithInt:[[componentRight objectAtIndex:i] intValue]]];
		if (NSOrderedSame != compResult)
			return compResult;
	}
	
	if ([componentLeft count] != [componentRight count])
	{
		if ([componentLeft count] < [componentRight count])
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (BOOL)isHigherThan:(NSString*)versionString
{
	return (NSOrderedDescending == [self versionCompare:versionString]);
}

- (BOOL)isLowerThan:(NSString*)versionString
{
	return (NSOrderedAscending == [self versionCompare:versionString]);
}

- (BOOL)isSameWith:(NSString*)versionString
{
	return (NSOrderedSame == [self versionCompare:versionString]);
}

@end
