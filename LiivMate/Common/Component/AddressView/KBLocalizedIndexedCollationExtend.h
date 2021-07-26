//
//  KBLocalizedIndexedCollationExtend.h
//  kbbank-ios
//
//  Created by SeungTaeKim on 2016. 4. 5..
//  Copyright © 2016년 ATSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBLocalizedIndexedCollationExtend : NSObject
{
    NSMutableArray * sectionTitles_transPosition;
    NSMutableArray * sectionIndexTitles_transPosition;
    BOOL isTransPositionCheck;
}

-(NSMutableArray *)sectionTitlesExtend;
-(NSMutableArray *)sectionIndexTitlesExtend;
-(NSInteger)sectionForObjectExtend:(id)object collationStringSelector:(SEL)selector collationString:(NSString*)collationString;
-(NSInteger)sectionForObjectCountryCode:(id)object collationStringSelector:(SEL)selector collationString:(NSString*)collationString;
-(NSString*)sectionForObjectCoreData:(id)object collationStringSelector:(SEL)selector collationString:(NSString*)collationString;
-(NSArray *)sortedArrayFromArrayExtend:(NSArray *)array collationStringSelector:(SEL)selector;
-(void)transPositionSharpFront;
-(void)isTransPositionCheck;

@end
