//
//  PhonemeUtils.m
//  SmartM
//
//  Created by Park Jong Pil on 11. 9. 26..
//  Copyright (c) 2011년 Reciper. All rights reserved.
//

#import "PhonemeUtils.h"

@implementation PhonemeUtils

@synthesize consonant;
@synthesize medial;
@synthesize finalConsonant;

- (id)init
{
    self = [super init];
    if (self)
    {
        // 초기화 
        consonant = [NSArray arrayWithObjects:
                      @"ㄱ", @"ㄲ", @"ㄴ", @"ㄷ", @"ㄸ", @"ㄹ", @"ㅁ", 
                      @"ㅂ", @"ㅃ", @"ㅅ", @"ㅆ", @"ㅇ", @"ㅈ", @"ㅉ", 
                      @"ㅊ", @"ㅋ", @"ㅌ", @"ㅍ", @"ㅎ" ,nil];
        
        medial = [NSArray arrayWithObjects:
                   @"ㅏ", @"ㅐ", @"ㅑ", @"ㅒ", @"ㅓ", @"ㅔ", 
                   @"ㅕ", @"ㅖ", @"ㅗ", @"ㅘ", @"ㅙ", @"ㅚ", 
                   @"ㅛ", @"ㅜ", @"ㅝ", @"ㅞ", @"ㅟ", @"ㅠ", 
                   @"ㅡ", @"ㅢ", @"ㅣ", nil];
        
        finalConsonant = [NSArray arrayWithObjects:
                           @"", @"ㄱ", @"ㄲ", @"ㄳ", @"ㄴ", @"ㄵ", @"ㄶ", 
                           @"ㄷ", @"ㄹ", @"ㄺ", @"ㄻ", @"ㄼ", @"ㄽ", @"ㄾ", 
                           @"ㄿ", @"ㅀ", @"ㅁ", @"ㅂ", @"ㅄ", @"ㅅ", @"ㅆ", 
                           @"ㅇ", @"ㅈ", @"ㅊ", @"ㅋ", @"ㅌ", @"ㅍ", @"ㅎ", nil];
    }
    
    return self;
}

- (NSComparisonResult)compare:(NSString *)source withConsonantString:(NSString *)search
{
    return [[self stringConsonant:source] compare:search];
}

// 초성/중성/종성 모두 사용.
- (NSString *)stringPhoneme:(NSString *)source
{
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [source length]; i++) 
    {
        NSInteger unicodeChar = [source characterAtIndex:i];
        
        // 한글인지 확인.
        if (HANGUL_START_CODE <= unicodeChar && unicodeChar <= HANGUL_END_CODE)
        {
            NSInteger consonantIndex  = (NSInteger)((unicodeChar - HANGUL_START_CODE) / (28 * 21));
            NSInteger medialIndex = (NSInteger)((unicodeChar - HANGUL_START_CODE) % (28*21) / 28);
            NSInteger finalConsonantIndex = (NSInteger)((unicodeChar - HANGUL_START_CODE) % 28);
            
            [result appendFormat:@"%@%@%@", 
            [consonant objectAtIndex:consonantIndex], [medial objectAtIndex:medialIndex], [finalConsonant objectAtIndex:finalConsonantIndex]];
        }
    }
    
    return result;
}

// 초성만 사용.
- (NSString *)stringConsonant:(NSString *)source
{
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [source length]; i++) 
    {
        NSInteger unicodeChar = [source characterAtIndex:i];
        
        // 한글인지 확인.
        if (HANGUL_START_CODE <= unicodeChar && unicodeChar <= HANGUL_END_CODE)
        {
            NSInteger consonantIndex  = (NSInteger)((unicodeChar - HANGUL_START_CODE) / (28 * 21));
            
            [result appendFormat:@"%@", [consonant objectAtIndex:consonantIndex]];
        }
    }
    
    return result;
}

- (NSString *)stringDiversionConsonant:(NSString *)source
{
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [source length]; i++)
    {
        NSInteger unicodeChar = [source characterAtIndex:i];
        
        // 한글인지 확인.
        if (HANGUL_START_CODE <= unicodeChar && unicodeChar <= HANGUL_END_CODE)
        {
            NSInteger consonantIndex  = (NSInteger)((unicodeChar - HANGUL_START_CODE) / (28 * 21));
            
            [result appendFormat:@"%@", [consonant objectAtIndex:consonantIndex]];
        }
		else
		{
			[result appendFormat:@"%@", [source substringWithRange:NSMakeRange(i, 1)]];
		}
    }
    
    return result;
}

/*
 PhonemeUtils *phoneme = [[PhonemeUtils alloc] init];
 NSMutableArray *tmpArray = [NSMutableArray array];
 
 for (NSMutableDictionary *dict in self.stockCodes)
 {
 // 종목명과 종목코드 그리고 초성 동시 검색.
 NSString *stockName = [[dict objectForKey:kNameKey] lowercaseString];
 NSString *stockCode = [dict objectForKey:kCodeKey];
 NSString *consonant = [phoneme stringDiversionConsonant:stockName];
 
 NSRange rangeName = [stockName rangeOfString:searchText];
 NSRange rangeCode = [stockCode rangeOfString:searchText];
 NSRange rangeConsonant = [consonant rangeOfString:searchText];
 
 if (([consonant hasPrefix:searchText] || [stockName hasPrefix:searchText] || [stockCode hasPrefix:searchText]) ||
 (rangeName.location != NSNotFound || rangeCode.location != NSNotFound || rangeConsonant.location != NSNotFound))
 
 {
 [tmpArray addObject:dict];
 }
 }
 */

@end

