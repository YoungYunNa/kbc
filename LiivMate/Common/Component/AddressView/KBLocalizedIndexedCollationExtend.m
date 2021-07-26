//
//  KBLocalizedIndexedCollationExtend.m
//  kbbank-ios
//
//  Created by SeungTaeKim on 2016. 4. 5..
//  Copyright © 2016년 ATSolutions. All rights reserved.
//

#import "KBLocalizedIndexedCollationExtend.h"

#define START_LOCAL_SECTION_INDEX 26

#define KOREAN_COLLATIONEXTEND [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄴ",@"ㄷ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅅ",@"ㅇ",@"ㅈ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ", nil]


@implementation KBLocalizedIndexedCollationExtend

-(id) init
{
    if( self=[super init] )
    {
        UILocalizedIndexedCollation *collaction = [UILocalizedIndexedCollation currentCollation];
        
        sectionTitles_transPosition = [[NSMutableArray alloc] initWithCapacity:[[collaction sectionTitles] count]];
        sectionIndexTitles_transPosition = [[NSMutableArray alloc] initWithCapacity:[[collaction sectionIndexTitles] count]];
        
        [self isTransPositionCheck];
        [self transPositionSectionTitles];
        [self transPositionSectionIndexTitles];
    }
    return self;
}


-(void) isTransPositionCheck
{
    UILocalizedIndexedCollation *collaction = [UILocalizedIndexedCollation currentCollation];
    
    isTransPositionCheck = YES;
    
    if([[collaction sectionTitles] count] > START_LOCAL_SECTION_INDEX + 1)
    {
        for(int i = 0 ; i < START_LOCAL_SECTION_INDEX ; i++)
        {
            NSString *fstring = [[collaction sectionTitles] objectAtIndex:i];
            
            NSInteger cstringCode = [fstring characterAtIndex:0];
            
            if(!((cstringCode >= 65 && cstringCode <= 90) || (cstringCode >= 97 && cstringCode <= 122)))
            {
                isTransPositionCheck = NO;
                break;
            }
        }
        
    }
    else
    {
        isTransPositionCheck = NO;
    }
}

-(void) transPositionSectionTitles
{
    UILocalizedIndexedCollation *collaction = [UILocalizedIndexedCollation currentCollation];
    
    NSString *fstring = [[collaction sectionTitles] objectAtIndex:0];
    
    NSInteger cstringCode = [fstring characterAtIndex:0];
    
    if(([[collaction sectionTitles] count] > START_LOCAL_SECTION_INDEX + 1) && ((cstringCode >= 65 && cstringCode <= 90) || (cstringCode >= 97 && cstringCode <= 122)) && isTransPositionCheck)
    {
        for(int i = START_LOCAL_SECTION_INDEX ; i < [[collaction sectionTitles] count] - 1 ; i++)
        {
            [sectionTitles_transPosition addObject:[[collaction sectionTitles] objectAtIndex:i]];
        }
        
        for(int i = 0 ; i < START_LOCAL_SECTION_INDEX ; i++)
        {
            [sectionTitles_transPosition addObject:[[collaction sectionTitles] objectAtIndex:i]];
        }
        
        [sectionTitles_transPosition addObject:[[collaction sectionTitles] objectAtIndex:[[collaction sectionTitles] count] - 1]];
    }
    else
    {
        for(int i = 0 ; i < [[collaction sectionTitles] count] ; i++)
        {
            [sectionTitles_transPosition addObject:[[collaction sectionTitles] objectAtIndex:i]];
        }
    }
}

-(void) transPositionSectionIndexTitles
{
    UILocalizedIndexedCollation *collaction = [UILocalizedIndexedCollation currentCollation];
    
    NSString *fstring = [[collaction sectionIndexTitles] objectAtIndex:0];
    
    NSInteger cstringCode = [fstring characterAtIndex:0];
    
    if(([[collaction sectionTitles] count] > START_LOCAL_SECTION_INDEX + 1) && ((cstringCode >= 65 && cstringCode <= 90) || (cstringCode >= 97 && cstringCode <= 122))&& isTransPositionCheck)
    {
        int index = 0;
        
        for(index = 0 ; index < [[collaction sectionIndexTitles] count] ; index++)
        {
            NSString *currentString = [[collaction sectionIndexTitles] objectAtIndex:index];
            
            NSInteger currentStringCode = [currentString characterAtIndex:0];
            
            if((currentStringCode >= 65 && currentStringCode <= 90) || (currentStringCode >= 97 && currentStringCode <= 122))
            {
                if(index + 2 < [[collaction sectionIndexTitles] count])
                {
                    NSString *nextString = [[collaction sectionIndexTitles] objectAtIndex:index + 2];
                    
                    NSInteger nextStringCode = [nextString characterAtIndex:0];
                    
                    if(!((nextStringCode >= 65 && nextStringCode <= 90) || (nextStringCode >= 97 && nextStringCode <= 122)))
                    {
                        break;
                    }
                }
            }
        }
        
        if([[[collaction sectionIndexTitles] objectAtIndex:[[collaction sectionIndexTitles] count] - 1] isEqualToString:@"#"])
        {
            for(int i = index + 1 ; i < [[collaction sectionIndexTitles] count] - 1 ; i++)
            {
                [sectionIndexTitles_transPosition addObject:[[collaction sectionIndexTitles] objectAtIndex:i]];
            }
            
            for(int i = 0 ; i < index + 1 ; i++)
            {
                [sectionIndexTitles_transPosition addObject:[[collaction sectionIndexTitles] objectAtIndex:i]];
            }
            
            [sectionIndexTitles_transPosition addObject:[[collaction sectionIndexTitles] objectAtIndex:[[collaction sectionIndexTitles] count] - 1]];
        }
        else
        {
            for(int i = index + 1 ; i < [[collaction sectionIndexTitles] count] ; i++)
            {
                [sectionIndexTitles_transPosition addObject:[[collaction sectionIndexTitles] objectAtIndex:i]];
            }
            
            for(int i = 0 ; i < index + 1 ; i++)
            {
                [sectionIndexTitles_transPosition addObject:[[collaction sectionIndexTitles] objectAtIndex:i]];
            }
        }
    }
    else
    {
        for(int i = 0 ; i < [[collaction sectionIndexTitles] count] ; i++)
        {
            [sectionIndexTitles_transPosition addObject:[[collaction sectionIndexTitles] objectAtIndex:i]];
        }
    }
    
    BOOL isSharpCheck = NO;
    
    for(int i = 0 ; i < [sectionIndexTitles_transPosition count] ; i++)
    {
        if([[sectionIndexTitles_transPosition objectAtIndex:i] isEqualToString:@"#"])
        {
            isSharpCheck = YES;
            break;
        }
    }
    
    if(isSharpCheck == NO)
    {
        [sectionIndexTitles_transPosition addObject:@"#"];
    }
}

-(void) transPositionSharpFront
{
    [sectionTitles_transPosition removeLastObject];
    [sectionTitles_transPosition insertObject:@"#" atIndex:0];
    
    [sectionIndexTitles_transPosition removeLastObject];
    [sectionIndexTitles_transPosition insertObject:@"#" atIndex:0];
}

-(NSMutableArray*) sectionTitlesExtend
{
    return sectionTitles_transPosition;
}

-(NSMutableArray*) sectionIndexTitlesExtend
{
    return sectionIndexTitles_transPosition;
}

-(NSInteger) sectionForObjectExtend:(id)object collationStringSelector:(SEL)selector collationString:(NSString*)collationString
{
    UILocalizedIndexedCollation *collaction = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger index = [collaction sectionForObject:object collationStringSelector:selector];
    
    if([[collaction sectionTitles] count] == START_LOCAL_SECTION_INDEX + 1)
        return index;
    
    NSString *section = [[collaction sectionTitles] objectAtIndex:index];
    
    for(int i = 0 ; i < [[collaction sectionTitles] count] ; i++)
    {
        if([[sectionTitles_transPosition objectAtIndex:i] isEqualToString:section])
        {
            index =  i;
            break;
        }
    }
    
    if([[sectionTitles_transPosition objectAtIndex:index] isEqualToString:@"Z"])//한글..기타 다국어들...section이 z로 찾아지네..^^;#으로 가야 할듯...
    {
        NSRange range = NSMakeRange(0, 1);
        
        NSString *firstString = [collationString substringWithRange:range];
        
        if([[sectionTitles_transPosition objectAtIndex:index] isEqualToString:firstString] == NO)
        {
            index = [sectionTitles_transPosition count] - 1;
        }
    }
    
    return index;
}

-(NSInteger) sectionForObjectCountryCode:(id)object collationStringSelector:(SEL)selector collationString:(NSString*)collationString
{
    UILocalizedIndexedCollation *collaction = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger index = [collaction sectionForObject:object collationStringSelector:selector];
    
    NSString *section = [[collaction sectionTitles] objectAtIndex:index];
    
    for(int i = 0 ; i < [[collaction sectionTitles] count] ; i++)
    {
        if([[sectionTitles_transPosition objectAtIndex:i] isEqualToString:section])
        {
            index =  i;
            break;
        }
    }
    
    if([[sectionTitles_transPosition objectAtIndex:index] isEqualToString:@"Z"])//한글..기타 다국어들...section이 z로 찾아지네..^^;#으로 가야 할듯...
    {
        NSRange range = NSMakeRange(0, 1);
        
        NSString *firstString = [collationString substringWithRange:range];
        
        if([[sectionTitles_transPosition objectAtIndex:index] isEqualToString:firstString] == NO)
        {
            index = [sectionTitles_transPosition count] - 1;
        }
    }
    
    return index;
}

-(NSString*) sectionForObjectCoreData:(id)object collationStringSelector:(SEL)selector collationString:(NSString*)collationString
{
    UILocalizedIndexedCollation *collaction = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger index = [collaction sectionForObject:object collationStringSelector:selector];
    
    if([[collaction sectionTitles] count] == START_LOCAL_SECTION_INDEX + 1)
    {
        NSRange range = NSMakeRange(0, 1);
        
        if(index == [[collaction sectionTitles] count] - 1)
        {
            return [NSString stringWithFormat:@"2%@",[[[collaction sectionTitles] objectAtIndex:index] substringWithRange:range]];
        }
        else
        {
            return [NSString stringWithFormat:@"0%@",[[[collaction sectionTitles] objectAtIndex:index] substringWithRange:range]];
        }
    }
    

    if(IOS_VERSION_OVER_7)
    {
        if(collationString == nil || [collationString length] == 0)
        {
            index = [sectionIndexTitles_transPosition count] - 1;
        }
        else
        {
            NSString * _firstString = [[collationString uppercaseString] substringWithRange:NSMakeRange(0, 1)];
            
            NSInteger cstringCode = [_firstString characterAtIndex:0];
            
            if((cstringCode >= 65 && cstringCode <= 90) || (cstringCode >= 97 && cstringCode <= 122))
            {
                for(int i = 0 ; i < [sectionTitles_transPosition count] ; i++)
                {
                    if([[sectionTitles_transPosition objectAtIndex:i] isEqualToString:_firstString])
                    {
                        index =  i;
                        break;
                    }
                }
            }
        }
    }
    else
    {
        NSString *section = [[collaction sectionTitles] objectAtIndex:index];
        
        for(int i = 0 ; i < [[collaction sectionTitles] count] ; i++)
        {
            if([[sectionTitles_transPosition objectAtIndex:i] isEqualToString:section])
            {
                index =  i;
                break;
            }
        }
        
        if([[sectionTitles_transPosition objectAtIndex:index] isEqualToString:@"Z"])//한글..기타 다국어들...section이 z로 찾아지네..^^;#으로 가야 할듯...
        {
            NSRange range = NSMakeRange(0, 1);
            
            NSString *firstString = [collationString substringWithRange:range];
            
            if([[sectionTitles_transPosition objectAtIndex:index] isEqualToString:firstString] == NO)
            {
                index = [sectionTitles_transPosition count] - 1;
            }
        }
    }
    
    NSRange range = NSMakeRange(0, 1);
    
    if(index < [sectionTitles_transPosition count] - 1 - START_LOCAL_SECTION_INDEX)
    {
        return [NSString stringWithFormat:@"0%@",[[sectionTitles_transPosition objectAtIndex:index] substringWithRange:range]];
    }
    else if(index == [sectionTitles_transPosition count] - 1)
    {
        return [NSString stringWithFormat:@"2%@",[[sectionTitles_transPosition objectAtIndex:index] substringWithRange:range]];
    }
    else
    {
        return [NSString stringWithFormat:@"1%@",[[sectionTitles_transPosition objectAtIndex:index] substringWithRange:range]];
    }
}

-(NSArray*) sortedArrayFromArrayExtend:(NSArray *)array collationStringSelector:(SEL)selector
{
    return [[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:array collationStringSelector:selector];
}


@end
