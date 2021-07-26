//
//  NSString+Util.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 19..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSArray (Util)
-(NSString*)jsonString {
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
													   options:0
														 error:nil];
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSString*)jsonStringPrint {
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
													   options:NSJSONWritingPrettyPrinted
														 error:nil];
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@implementation NSDictionary (Util)
-(NSString*)jsonString {
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
													   options:0
														 error:nil];
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSString*)jsonStringPrint {
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
													   options:NSJSONWritingPrettyPrinted
														 error:nil];
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end

@implementation NSNumber (Util)

- (NSString *)formatNumber {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithLongLong:[self longLongValue]]];
	
	return formattedOutput;
}

-(NSInteger)length {
	return self.stringValue.length;
}

@end

@implementation NSNull (Util)
- (NSString *)formatNumber {
	return @"";
}

-(NSInteger)length {
	return 0;
}

-(BOOL)isEqualToString:(NSString *)string {
	return NO;
}
@end

@implementation NSString (Util)
-(id)jsonObjectForBase64 {
	NSData *queryData = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
	return [NSJSONSerialization JSONObjectWithData:queryData
										   options:NSJSONReadingMutableContainers
											 error:nil];
}

-(id)jsonObject {
	NSData *queryData = [self dataUsingEncoding:(NSUTF8StringEncoding)];
	return [NSJSONSerialization JSONObjectWithData:queryData
										   options:NSJSONReadingMutableContainers
											 error:nil];
}

// URL 인코딩.
- (NSString *)stringByUrlEncoding
{
    NSMutableCharacterSet *charset = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [charset removeCharactersInString:@"!*'();:@&=+$,/?%#[]"];
    
    return [self stringByAddingPercentEncodingWithAllowedCharacters:charset];
}

// URL 디코딩.
- (NSString *)stringByUrlDecoding
{
    return [self stringByRemovingPercentEncoding];
}

-(NSString *)stringValue {
	return self;
}

// 숫자 포맷팅(콤마).
- (NSString *)formatNumber {
	if([self rangeOfString:@","].location != NSNotFound)
	{
		NSString *str = [self stringByReplacingOccurrencesOfString:@"," withString:@""];
		return str.formatNumber;
	}
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithLongLong:[self longLongValue]]];
	
	return formattedOutput;
}

// 실수형 포맷팅(콤마).
- (NSString *)formatDoubleNumber {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithDouble:[self doubleValue]]];
	
	return formattedOutput;
}

- (NSString*)delComma {
	return [self stringByReplacingOccurrencesOfString:@"," withString:@""];
}

//날짜 string포멧변환.
- (NSString *)dateStringWithType:(int)dateType {
	NSString *string = self;
	string = [string trim];
	if (string.length == 0) return string;
	
	//string input type
	NSString* DateFormat = [@"yyyyMMddHHmmss" substringToIndex:string.length];
	
	NSDateFormatter *Formatter = [[NSDateFormatter alloc]init];
	[Formatter setDateFormat:DateFormat];
	
	NSDate *date = [Formatter dateFromString:string];
	if(date == nil) return string;
	//string return type
	if(dateType == 0)	DateFormat = @"yyyy-MM-dd HH:mm:ss";
	if(dateType == 1)	DateFormat = @"yyyy-MM-dd";
	if(dateType == 2)	DateFormat = @"HH:mm:ss";
	if(dateType == 3)	DateFormat = @"yyyy";
	if(dateType == 4)	DateFormat = @"MM";
	if(dateType == 5)	DateFormat = @"dd";
	if(dateType == 6)	DateFormat = @"HH";
	if(dateType == 7)	DateFormat = @"mm";
	if(dateType == 8)	DateFormat = @"ss";
	if(dateType == 9)	DateFormat = @"yyyyMMddHHmmss";
	if(dateType == 10)	DateFormat = @"yyyyMMdd";
	if(dateType == 11)	DateFormat = @"yyyy.MM.dd HH:mm";
	if(dateType == 12)	DateFormat = @"yyyy.MM.dd";
	if(dateType == 13)	DateFormat = @"yy.MM.dd";
    if(dateType == 14)	DateFormat = @"HHmm";
	if(dateType == 15)	DateFormat = @"yyyy.MM.dd | HH:mm:ss";
	if(dateType == 16)	DateFormat = @"yyyy.MM.dd HH:mm:ss";
	
	[Formatter setDateFormat:DateFormat];
	NSString* returnString = [Formatter stringFromDate:date];
	return [NSString stringWithString:returnString];
}

//String날짜 day계산 (index만큼 더하기)
- (NSString *)dateStringWithAddDay:(int)index {
	NSString *string = self;
	string = [string trim];
	if (!string) return @"";
	
	//string input type
	NSString* DateFormat = [@"yyyyMMdd" substringToIndex:string.length];
	
	NSDateFormatter *Formatter = [[NSDateFormatter alloc]init];
	[Formatter setDateFormat:DateFormat];
	
	NSDate *selfDate = [Formatter dateFromString:string];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *components = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday) fromDate:selfDate];
	
	components.day = [components day]+index;
	NSDate *setDate = [gregorian dateFromComponents:components];
	
	string = [Formatter stringFromDate:setDate];
	
	return string;
}

// trim
- (NSString *)trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// hyphen trim
- (NSString *)hyphenTrim {
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

// split
- (NSArray *)split:(NSString *)separator {
    return [self componentsSeparatedByString:separator];
}

//OTCNum
- (NSString *)formatOtcNum {
    if(self.length <= 16) {
        return self;
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
            [self substringWithRange:NSMakeRange(0, 4)],
            [self substringWithRange:NSMakeRange(4, 4)],
            [self substringWithRange:NSMakeRange(8, 4)],
            [self substringWithRange:NSMakeRange(12, 4)],
            [self substringWithRange:NSMakeRange(16, self.length - 16)]];
}

//카드번호 형식으로 포멧변환.
- (NSString *)formatCardNum {
	NSString *cardNum = [self hyphenTrim];
	NSMutableString *tempStr = [[NSMutableString alloc] init];
	
	for (int i = 0; i < cardNum.length; i++) {
		[tempStr appendString:[cardNum substringWithRange:NSMakeRange(i, 1)]];
		
		//4자리마다 -추가
		if ((i+1)%4 == 0) {
			[tempStr appendString:@"-"];
		}
	}
	
	//마지막이 -일 경우 -삭제
	if ([[tempStr substringWithRange:NSMakeRange(tempStr.length-1, 1)] isEqualToString:@"-"]) {
		[tempStr setString:[tempStr substringWithRange:NSMakeRange(0, tempStr.length-1)]];
	}
	
	return tempStr;
}

//카드번호 형식으로 포멧변환.
- (NSString *)formatCardNum2 {
	NSString *cardNum = [self hyphenTrim];
	NSMutableString *tempStr = [[NSMutableString alloc] init];
	
	for (int i = 0; i < cardNum.length; i++) {
		[tempStr appendString:[cardNum substringWithRange:NSMakeRange(i, 1)]];
		
		//4자리마다 -추가
		if ((i+1)%4 == 0) {
			[tempStr appendString:@" "];
		}
	}
	
	//마지막이 -일 경우 -삭제
	if ([[tempStr substringWithRange:NSMakeRange(tempStr.length-1, 1)] isEqualToString:@" "]) {
		[tempStr setString:[tempStr substringWithRange:NSMakeRange(0, tempStr.length-1)]];
	}
	
	return tempStr;
}

//카드번호 형식으로 포멧변환. 1234-****-****-1234
- (NSString *)formatSecretCardNum {
	if ([self length] < 12) return self;
	
	int length = 4;
	NSString *cardNum = [[self stringByReplacingOccurrencesOfString:@"-" withString:@""] trim];
	NSMutableString *star = [[NSMutableString alloc] init];
	for (int i = 0; i < 8; i++) [star appendString:@"*"];
	
	cardNum = [NSString stringWithFormat:@"%@%@%@", [cardNum substringWithRange:NSMakeRange(0, 4)], star, [cardNum substringWithRange:NSMakeRange(12, [cardNum length]-4-star.length)]];
	
	return [NSString stringWithFormat:@"%@-%@-%@-%@", [cardNum substringWithRange:NSMakeRange(0, length)],
			[cardNum substringWithRange:NSMakeRange(4, length)],
			[cardNum substringWithRange:NSMakeRange(8, length)],
			[cardNum substringWithRange:NSMakeRange(12, [cardNum length]-12)]];
}

// 계좌번호 마지막 세자리 *로 치환(590602-34-111***)
- (NSString *)formatSecretAccountNum {
    if ([self length] < 3) return self;
    
    NSString *accountTrimStr = [self trim];
    if (accountTrimStr.length == 14) {
        accountTrimStr = [NSString stringWithFormat:@"%@-%@-%@", [accountTrimStr substringWithRange:NSMakeRange(0, 6)], [accountTrimStr substringWithRange:NSMakeRange(6, 2)], [accountTrimStr substringWithRange:NSMakeRange(8, 6)]];
    } else if (accountTrimStr.length == 12) {
        accountTrimStr = [NSString stringWithFormat:@"%@-%@-%@-%@", [accountTrimStr substringWithRange:NSMakeRange(0, 2)], [accountTrimStr substringWithRange:NSMakeRange(2, 2)], [accountTrimStr substringWithRange:NSMakeRange(4, 4)], [accountTrimStr substringWithRange:NSMakeRange(8, 3)]];
    }
    
    NSMutableString *accountNum = [NSMutableString stringWithString:accountTrimStr];
    [accountNum replaceCharactersInRange:NSMakeRange(accountTrimStr.length - 3, 3) withString:@"***"];
    
    return accountNum;
}

// 등록된 계좌번호에 마스킹 처리, 계좌번호 마지막 구간 네자리 *로 치환(59060234****10)
- (NSString *)formatSecretAccountNum2 {
    if ([self length] < 4) return self;
    
    NSString *accountTrimStr = [self trim];
    
    NSMutableString *accountNum = [NSMutableString stringWithString:accountTrimStr];
    [accountNum replaceCharactersInRange:NSMakeRange(accountTrimStr.length - 6, 4) withString:@"****"];
    
    return accountNum;
}

//문자열에서 숫자형 문자만 뽑아줌.
- (NSString *)getDecimalString {
    NSArray *arr = [self componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *moneyStr = [arr componentsJoinedByString:@""];
    
    if([moneyStr length] < 1)
        return @"0";
    
    return moneyStr;
}

//폰트, 최대사이즈, 줄바꿈 모드로 글자 사이즈 가져오기
- (CGSize)sizeWithText:(UIFont *)font maxSize:(CGSize)maxSize lineBreakMode:(NSLineBreakMode)lineBreakMode {
	CGSize result;
	
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    result = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
	
	return result;
}

-(NSString*)accountMaskFormat {
	NSString *string = [self trim];
	if(string.length > 5)
	{
		NSMutableString *formatNm = [NSMutableString stringWithString:[string substringToIndex:string.length-5]];
		for(int i = (int)(string.length-5); i < string.length; i++)
			[formatNm appendString:@"*"];
		return formatNm;
	}
	return string;
}

-(NSString*)nameMaskFormat {
	if(self.length > 1)
	{
		NSMutableString *formatNm = [NSMutableString stringWithString:[self substringToIndex:1]];
		for(int i = 1; i < self.length; i++)
			[formatNm appendString:@"*"];
		return formatNm;
	}
	return self;
}

// helper function: get the string form of any object
static NSString *toString(id object) {
	return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
	NSString *string = toString(object);
	return [string stringByUrlEncoding];
}

+(NSString*) urlEncodedQueryString:(NSDictionary *)dic {
	NSMutableArray *parts = [NSMutableArray array];
	for (id key in dic) {
		id value = [dic objectForKey: key];
		NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
		[parts addObject: part];
	}
	return [parts componentsJoinedByString: @"&"];
}

+(NSString*) urlQueryString:(NSDictionary *)dic {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in dic) {
        id value = [dic objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", key, value];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

//FIDO resultMessage 내 statusCode 가져오기
+(int)getFidoStatusCode:(NSString *)errorMessage {
    
    NSString *statusCodeStr = @"";
    int statusCode = 0;
    NSString *errorMsg = errorMessage.trim;

    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@";"];
    NSArray *errorMsgArray = [errorMsg componentsSeparatedByCharactersInSet:set];
    
    for (NSString *msg in errorMsgArray) {
        if ([msg rangeOfString:@"statusCode"].location != NSNotFound) {
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"="];
            NSArray *statusArray = [msg componentsSeparatedByCharactersInSet:set];
            statusCodeStr = statusArray.lastObject;
            break;
        }
    }
    
    if (statusCodeStr && statusCodeStr.length > 0) {
        statusCode = statusCodeStr.intValue;
    }
    
    return statusCode;
}
@end


@implementation NSString (SchemeString)


//#define Scheme_Action                @"liivmate"
//#define Scheme_Internal                @"internal"
//#define Scheme_External                @"external"
//#define Scheme_Main                    @"main"
//#define Scheme_Back                    @"back"
//#define Scheme_Menu                    @"menu"
//#define Scheme_TablePay             @"liivmatetablepay"

-(BOOL)isNotNil {
    return (self != nil && self != NULL);
}
- (BOOL)isSchemeStringAction {
    return ([self isEqualToString:@"liivmate"] && [self isNotNil]);
}
- (BOOL)isSchemeStringInternal {
    return ([self containsString:@"internal"] && [self isNotNil]);
}
// external.
- (BOOL)isSchemeStringExternal {
    return ([self containsString:@"external"] && [self isNotNil]);
}
// external.
- (BOOL)isSchemeStringMain {
    return ([self isEqualToString:@"main"] && [self isNotNil]);
}
// external.
- (BOOL)isSchemeStringBack {
    return ([self isEqualToString:@"back"] && [self isNotNil]);
}
- (BOOL)isSchemeStringMenu {
    return ([self isEqualToString:@"menu"] && [self isNotNil]);
}
- (BOOL)isSchemeStringTablePay {
    return ([self isEqualToString:@"liivmatetablepay"] && [self isNotNil]);
}

@end
