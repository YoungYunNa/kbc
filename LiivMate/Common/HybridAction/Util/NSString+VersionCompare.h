//
//  NSString+VersionCompare.h
//  NewKBCardShop
//
//  Created by Lee SeungWoo on 13. 2. 15..
//

#import <Foundation/Foundation.h>


@interface NSString (VersionCompare)

- (NSComparisonResult)versionCompare:(NSString*)versionString;
- (BOOL)isHigherThan:(NSString*)versionString;
- (BOOL)isLowerThan:(NSString*)versionString;
- (BOOL)isSameWith:(NSString*)versionString;

@end
