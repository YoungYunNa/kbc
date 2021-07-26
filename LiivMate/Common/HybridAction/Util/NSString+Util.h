//
//  NSString+Util.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 19..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSArray (Util)
-(NSString*)jsonString;
-(NSString*)jsonStringPrint;
@end

@interface NSDictionary (Util)
-(NSString*)jsonString;
-(NSString*)jsonStringPrint;
@end

@interface NSString (Util)

- (id)jsonObjectForBase64;

- (id)jsonObject;

// URL 인코딩.
- (NSString *)stringByUrlEncoding;

// URL 디코딩.
- (NSString *)stringByUrlDecoding;

// 숫자 포맷팅(콤마).
- (NSString *)formatNumber;

// 실수형 포맷팅(콤마).
- (NSString *)formatDoubleNumber;
- (NSString*)delComma;

//날짜 string포멧변환.
- (NSString *)dateStringWithType:(int)dateType;

//String날짜 day계산 (index만큼 더하기)
- (NSString *)dateStringWithAddDay:(int)index;

//trim
- (NSString *)trim;

//trim
- (NSString *)hyphenTrim;

//split
- (NSArray *)split:(NSString *)separator;

//OTCNum
- (NSString *)formatOtcNum;

//카드번호 형식으로 포멧변환.
- (NSString *)formatCardNum;
- (NSString *)formatCardNum2;
- (NSString *)formatSecretCardNum;

//계좌번호 마스킹 처리 포멧변환
- (NSString *)formatSecretAccountNum;
- (NSString *)formatSecretAccountNum2;

//문자열에서 숫자형 문자만 뽑아줌.
- (NSString *)getDecimalString;

//폰트, 최대사이즈, 줄바꿈 모드로 글자 사이즈 가져오기
- (CGSize)sizeWithText:(UIFont *)font maxSize:(CGSize)maxSize lineBreakMode:(NSLineBreakMode)lineBreakMode;
//계좌번호 마스크 포멧
- (NSString*)accountMaskFormat;
//이름 마스크포멧
- (NSString*)nameMaskFormat;
+(NSString*) urlEncodedQueryString:(NSDictionary *)dic;
+(NSString*) urlQueryString:(NSDictionary *)dic;

//FIDO resultMessage 내 statusCode 가져오기
+(int)getFidoStatusCode:(NSString *)errorMessage;

@end

@interface NSString (SchemeString)

- (BOOL)isSchemeStringAction;
- (BOOL)isSchemeStringInternal;
- (BOOL)isSchemeStringExternal;
- (BOOL)isSchemeStringMain;
- (BOOL)isSchemeStringBack;
- (BOOL)isSchemeStringMenu;
- (BOOL)isSchemeStringTablePay;

- (BOOL)isNotNil;

@end
