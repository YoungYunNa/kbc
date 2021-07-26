//
//  PhonemeUtils.h
//  SmartM
//
//  Created by Park Jong Pil on 11. 9. 26..
//  Copyright (c) 2011년 Reciper. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HANGUL_START_CODE   0xAC00
#define HANGUL_END_CODE     0xD79F

@interface PhonemeUtils : NSObject
{
    NSArray *consonant;         // 초성(자음).
    NSArray *medial;            // 중성.
    NSArray *finalConsonant;    // 종성.
}

@property (nonatomic, retain) NSArray *consonant;
@property (nonatomic, retain) NSArray *medial;
@property (nonatomic, retain) NSArray *finalConsonant;

// 입력문자열를 초성과 비교해서 NSComparisonResult를 반환한다.
- (NSComparisonResult)compare:(NSString *)source withConsonantString:(NSString *)search;

// 입력문자열을 초성/중성/종성으로 변환시킨다.
- (NSString *)stringPhoneme:(NSString *)source; 

// 초성만...
- (NSString *)stringConsonant:(NSString *)source;
//한글의 초성만 가져감
- (NSString *)stringDiversionConsonant:(NSString *)source;

@end
