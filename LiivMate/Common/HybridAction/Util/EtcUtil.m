//
//  EtcUtil.m
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 8. 16..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "EtcUtil.h"
#import <yMobileMonitor/YmmDeviceInfoUtil.h>

@implementation EtcUtil


/*!
 UIColor 값으로 이미지를 생성
 
 @param     color : 칼라
 @returns   이미지 UIImage
 */
#pragma mark - 칼라로 이미지 생성
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)centerCropImage:(UIImage *)image
{
    // Use smallest side length as crop square length
    CGFloat squareLength = MIN(image.size.width, image.size.height);
    // Center the crop area
    CGRect clippedRect = CGRectMake((image.size.width - squareLength) / 2, (image.size.height - squareLength) / 2, squareLength, squareLength);
    
    // Crop logic
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

#pragma mark - 이미지 사이즈에 따른 크롭 처리
+ (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double newCropWidth, newCropHeight;
    
    //=== To crop more efficently =====//
    if(image.size.width < image.size.height){
        if (image.size.width < size.width) {
            newCropWidth = size.width;
        }
        else {
            newCropWidth = image.size.width;
        }
        newCropHeight = (newCropWidth * size.height)/size.width;
    } else {
        if (image.size.height < size.height) {
            newCropHeight = size.height;
        }
        else {
            newCropHeight = image.size.height;
        }
        newCropWidth = (newCropHeight * size.width)/size.height;
    }
    //==============================//
    double x = image.size.width/2.0 - newCropWidth/2.0;
    double y = image.size.height/2.0 - newCropHeight/2.0;
    
    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    
    //    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

#pragma mark - 이미지 리사이즈 처리
+ (UIImage *)imageByResizeImage:(UIImage *)image toSize:(CGSize)size
{
    // 변경할 사이즈
    float resizeWidth = size.width;
    float resizeHeight = size.height;
    
    UIGraphicsBeginImageContext(CGSizeMake(resizeWidth, resizeHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, resizeHeight);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextDrawImage(context, CGRectMake(0.0, 0.0, resizeWidth, resizeHeight), [image CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage; // 사이즈가 300,300 으로 변경된 UIImage
}


#pragma mark - 전화번호 포맷 형식 생성
+ (NSString*)formatSecretPhoneNumber:(NSString*)simpleNumber
{
    if(simpleNumber.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length < 7)
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"$1-$2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    }
    else if(simpleNumber.length < 11)
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"$1-$2-****"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    }
    else
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{4})(\\d+)"
                                                               withString:@"$1-$2-****"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    }
    
    return simpleNumber;
}

+ (NSString*)formatSecretPhoneNumber2:(NSString*)simpleNumber
{
	if(simpleNumber.length==0) return @"";
	// use regex to remove non-digits(including spaces) so we are left with just the numbers
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
	simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
	
	
	// 123 456 7890
	// format the number.. if it's less then 7 digits.. then use this regex.
	if(simpleNumber.length < 7)
	{
		simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
															   withString:@"$1-$2"
																  options:NSRegularExpressionSearch
																	range:NSMakeRange(0, [simpleNumber length])];
	}
	else if(simpleNumber.length < 11)
	{
		simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
															   withString:@"$1-***-$3"
																  options:NSRegularExpressionSearch
																	range:NSMakeRange(0, [simpleNumber length])];
	}
	else
	{
		simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{4})(\\d+)"
															   withString:@"$1-****-$3"
																  options:NSRegularExpressionSearch
																	range:NSMakeRange(0, [simpleNumber length])];
	}
	
	return simpleNumber;
}


#pragma mark - 전화번호 포맷 형식 생성
+ (NSString*)formatPhoneNumber2:(NSString*)simpleNumber
{
	
    if(simpleNumber.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length < 7)
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"$1-$2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    }
    else if(simpleNumber.length < 10)
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"$1-$2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    }
    else if(simpleNumber.length == 10)
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{4})(\\d+)"
                                                               withString:@"$1-$2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    }
    else
    {
        
    }
    return simpleNumber;
}

+ (NSString*)formatPhoneNumber3:(NSString*)simpleNumber
{
    if(simpleNumber.length < 6) return simpleNumber;
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
	if(simpleNumber.length < 7)
    {
		if(simpleNumber.length >= 6)
		{
			simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
																   withString:@"$1-$2"
																	  options:NSRegularExpressionSearch
																		range:NSMakeRange(0, [simpleNumber length])];
		}
    }
    else if(simpleNumber.length < 10)
    {
		
        if(simpleNumber.length == 9 && [simpleNumber hasPrefix:@"02"]) {
            simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{2})(\\d{3})(\\d+)"
                                                                   withString:@"$1-$2-$3"
                                                                      options:NSRegularExpressionSearch
                                                                        range:NSMakeRange(0, [simpleNumber length])];
        } else {
            simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                                   withString:@"$1-$2-$3"
                                                                      options:NSRegularExpressionSearch
                                                                        range:NSMakeRange(0, [simpleNumber length])];
        }
    }
    else if(simpleNumber.length == 10)
    {
        if([simpleNumber hasPrefix:@"02"]) {
            simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{2})(\\d{4})(\\d+)"
                                                                   withString:@"$1-$2-$3"
                                                                      options:NSRegularExpressionSearch
                                                                        range:NSMakeRange(0, [simpleNumber length])];
        } else {
            simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{4})(\\d+)"
                                                                   withString:@"$1-$2-$3"
                                                                      options:NSRegularExpressionSearch
                                                                        range:NSMakeRange(0, [simpleNumber length])];
        }
    }
    else if(simpleNumber.length == 11)
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{4})(\\d+)"
                                                               withString:@"$1-$2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    } else {
        
    }
    return simpleNumber;
}

+ (NSString*)formatPhoneNumber:(NSString*)simpleNumber
{
	if(simpleNumber.length==0) return @"";
    
    simpleNumber = [simpleNumber getDecimalString];
    
	// use regex to remove non-digits(including spaces) so we are left with just the numbers
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
	simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
	
	
	// 123 456 7890
	// format the number.. if it's less then 7 digits.. then use this regex.
	if(simpleNumber.length < 8)
	{
		simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
															   withString:@"$1-$2"
																  options:NSRegularExpressionSearch
																	range:NSMakeRange(0, [simpleNumber length])];
	}
	else if(simpleNumber.length < 11)
	{
		simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
															   withString:@"$1-$2-$3"
																  options:NSRegularExpressionSearch
																	range:NSMakeRange(0, [simpleNumber length])];
	}
	else if(simpleNumber.length == 11)
	{
		simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{4})(\\d+)"
															   withString:@"$1-$2-$3"
																  options:NSRegularExpressionSearch
																	range:NSMakeRange(0, [simpleNumber length])];
	}
	else
	{
		
	}
	return simpleNumber;
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
	
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}


+ (UIColor *)colorWithRGBHexAlpha:(UInt32)hex {
    int r = (hex >> 24) & 0xFF;
    int g = (hex >> 16) & 0xFF;
    int b = (hex >> 8) & 0xFF;
    int a = (hex) & 0xFF;
	
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:a / 255.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
//    modify by kang
//    for #CDCDCD ==> CDCDCD
    
//    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
//    unsigned hexNum;
//    if (![scanner scanHexInt:&hexNum]) return nil;
//    
//    if(6 < [stringToConvert length]) {
//        return [EtcUtil colorWithRGBHexAlpha:hexNum];
//    }
//    else {
//        return [EtcUtil colorWithRGBHex:hexNum];
//    }
    
    NSString * colorString = [[stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]uppercaseString];
    
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    
    if(6 < [colorString length]) {
        return [EtcUtil colorWithRGBHexAlpha:hexNum];
    }
    else {
        return [EtcUtil colorWithRGBHex:hexNum];
    }
}

#pragma mark - 속성스트링의 폰드 속성 넣기
+ (NSMutableAttributedString *)setAttributeWithString:(NSMutableAttributedString *)attString subStr:(NSString *)subStr subFont:(float)subFont
{
    NSRange range = [attString.string rangeOfString:subStr];
    if( range.location != NSNotFound )
    {
        NSDictionary * attriDic = @{NSFontAttributeName:[UIFont systemFontOfSize:subFont]};
        [attString setAttributes:attriDic range:range];
    }
    
    return attString;
}

+ (NSMutableAttributedString *)setAttributeWithColorString:(NSMutableAttributedString *)attString subStr:(NSString *)subStr subColor:(UIColor *)subColor
{
	NSRange range = [attString.string rangeOfString:subStr];
	if( range.location != NSNotFound )
	{
		[attString removeAttribute:NSForegroundColorAttributeName range:range];
		[attString addAttribute:NSForegroundColorAttributeName value:subColor range:range];
	}
	
	return attString;
}

+ (NSMutableAttributedString *)setAttributeWithColorString:(NSMutableAttributedString *)attString subStr:(NSString *)subStr subColor:(UIColor *)subColor subFont:(UIFont *)subFont
{
    NSRange range = [attString.string rangeOfString:subStr];
    if( range.location != NSNotFound )
    {
        if( subColor != nil )
        {
            [attString addAttribute:NSForegroundColorAttributeName value:subColor range:range];
        }
        if( subFont != nil )
        {
            [attString addAttribute:NSFontAttributeName value:subFont range:range];
        }
    }
    
    return attString;
}

+ (void)layerBorder:(id)view {
	((UIView *)view).layer.borderColor = [UIColor redColor].CGColor;
	((UIView *)view).layer.borderWidth = 1;
}


+ (NSMutableArray *)searchWithGroupedNameArrayByData:(NSArray *)groupedArray andString:(NSString *)numString
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    NSString *patternString = [NSString stringWithFormat:@"%@", [EtcUtil makePattern:[numString getDecimalString]]];
    NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"%K MATCHES[c] %@", @"searchNum", patternString];     /* fullName을 기준으로 patternString란 패턴을 가진 baseArray중 data를 검색 */
    
    int iArrCnt = (int)[groupedArray count];
    for( int i=0 ; i<iArrCnt ; i++ )
    {
        NSArray *subArr = [groupedArray objectAtIndex:i];
        NSArray *findArray = [subArr filteredArrayUsingPredicate:findPredicate];
        
        if( [findArray count] > 0 )
        {
            NSString *groupNameStr = [[RegistedPersonsList sharedInstance].groupList objectAtIndex:i];
            if( ![resultArray containsObject:groupNameStr] )
            {
                [resultArray addObject:groupNameStr];
            }
        }
    }
    
    return resultArray;
}


+ (NSMutableArray *)searchWithGroupedNameArrayByData:(NSArray *)groupedArray andArray:(NSArray *)numArray
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    int iArrCnt = (int)[numArray count];
    
    for( int i=0 ; i<iArrCnt ; i++ )
    {
        NSString *numString = [numArray objectAtIndex:i];
        
        NSString *patternString = [NSString stringWithFormat:@"%@", [EtcUtil makePattern:[numString getDecimalString]]];
        NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"%K MATCHES[c] %@", @"searchNum", patternString];     /* fullName을 기준으로 patternString란 패턴을 가진 baseArray중 data를 검색 */
        
        int iArrCnt = (int)[groupedArray count];
        for( int j=0 ; j<iArrCnt ; j++ )
        {
            NSArray *subArr = [groupedArray objectAtIndex:j];
            NSArray *findArray = [subArr filteredArrayUsingPredicate:findPredicate];
            
            if( [findArray count] > 0 )
            {
                NSString *groupNameStr = [[RegistedPersonsList sharedInstance].groupList objectAtIndex:j];
                if( ![resultArray containsObject:groupNameStr] )
                {
                    [resultArray addObject:groupNameStr];
                }
            }
        }
    }
    
    return resultArray;
}


/*!
 fullName을 기준으로 patternString란 패턴을 가진 baseArray중 data를 검색
 
 @param
 @returns   baseArray : 연락처 NSArray , searchString : 검색할 NSString
 */
#pragma mark - 초성 검색
+ (NSMutableArray *)searchWithArrayData:(NSArray *)baseArray andString:(NSString *)searchString
{
    NSString *patternString = [NSString stringWithFormat:@".*(%@).*", [EtcUtil makePattern:searchString]];
    
    NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"(%K MATCHES[c] %@) OR (%K MATCHES[c] %@)", @"fullName", patternString, @"searchNum", patternString];     /* fullName을 기준으로 patternString란 패턴을 가진 baseArray중 data를 검색 */
    NSArray *findArray = [baseArray filteredArrayUsingPredicate:findPredicate];
    
    return [findArray mutableCopy];
}

+ (NSMutableArray *)searchWithCommunityArrayData:(NSArray *)baseArray andString:(NSString *)searchString
{
    NSString *patternString = [NSString stringWithFormat:@".*(%@).*", [EtcUtil makePattern:searchString]];
    
    NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"(%K MATCHES[c] %@)", @"metgBnkbkNm", patternString];     /* fullName을 기준으로 patternString란 패턴을 가진 baseArray중 data를 검색 */
    NSArray *findArray = [baseArray filteredArrayUsingPredicate:findPredicate];
    
    return [findArray mutableCopy];
}


/*!ㄱ 찾고자 하는 글자에 대한 패턴을 추가, 한글 초성 포함
 
 @param
 @returns   string : 검색할 NSString
 */
+ (NSString *)makePattern:(NSString *)string
{
    NSMutableString * patternString = [NSMutableString stringWithString:string];
    
    if(patternString.length >= 1)
    {
        for(NSUInteger insertPosition = patternString.length; insertPosition >=1 ; insertPosition--)
        {
            [patternString insertString:@"\\s*" atIndex:insertPosition];
        }
    }
    
    [patternString replaceOccurrencesOfString:@"|" withString:@"\\|" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"[" withString:@"\\[" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"]" withString:@"\\]" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"(" withString:@"\\(" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@")" withString:@"\\)" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"{" withString:@"\\{" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"}" withString:@"\\}" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"*" withString:@"\\*" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"?" withString:@"\\?" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"." withString:@"\\." options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"^" withString:@"\\^" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"$" withString:@"\\$" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"+" withString:@"\\+" options:NSLiteralSearch range:NSMakeRange(0, patternString.length)];
    
    /* 한글 초성 검사 추가 */
    [patternString replaceOccurrencesOfString:@"ㄱ" withString:@"[ㄱ가-깋]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㄲ" withString:@"([ㄲ까-낗]|([ㄱ가-깋][ㄱ가-깋]))" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㄴ" withString:@"[ㄴ나-닣]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㄷ" withString:@"[ㄷ다-딯]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㄸ" withString:@"([ㄸ따-띻]|([ㄷ다-딯][ㄷ다-딯]))" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㄹ" withString:@"[ㄹ라-맇]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅁ" withString:@"[ㅁ마-밓]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅂ" withString:@"[ㅂ바-빟]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅃ" withString:@"([ㅃ빠-삫]|([ㅂ바-빟][ㅂ바-빟]))" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅅ" withString:@"[ㅅ사-싷]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅆ" withString:@"([ㅆ싸-앃]|([ㅅ사-싷][ㅅ사-싷]))" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅇ" withString:@"[ㅇ아-잏]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅈ" withString:@"[ㅈ자-짛]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅉ" withString:@"([ㅉ짜-찧]|([ㅈ자-짛][ㅈ자-짛]))" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅊ" withString:@"[ㅊ차-칳]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅌ" withString:@"[ㅌ타-팋]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅍ" withString:@"[ㅍ파-핗]" options:0 range:NSMakeRange(0, patternString.length)];
    [patternString replaceOccurrencesOfString:@"ㅎ" withString:@"[ㅎ하-힣]" options:0 range:NSMakeRange(0, patternString.length)];
    /* */
    
    /* 화이트 스페이스 무시 검색 추가 */
    [patternString replaceOccurrencesOfString:@"\\\\s\\*" withString:@"\\s*" options:0 range:NSMakeRange(0, patternString.length)];
    
    
    return [NSString stringWithString:patternString];
}

/*!
 startDate와 endDate사이의 차이 month값을 구함
 @param
 @returns month
 */
+ (NSInteger)gapMonthOfStartDateAndEndDate:(NSString *)startDate endDate:(NSString *)endDate;
{
	if (nilCheck(startDate) || nilCheck(endDate)) return 0;
	
	NSDateFormatter *Formatter = [[NSDateFormatter alloc]init];
	[Formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[Formatter setDateFormat:@"yyyyMMdd"];
	
	NSDate *stDtDate = [Formatter dateFromString:startDate];
	NSDate *edDtDate = [Formatter dateFromString:endDate];
	
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
	NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:stDtDate toDate:edDtDate options:0];
	
	if ([breakdownInfo month] <= 0) return 0;
	
	return [breakdownInfo month];
}

+ (NSInteger)gapDaysOfStartDateAndEndDate:(NSString *)start endDate:(NSString *)end withFormatStr:(NSString*)format;
{
    if (nilCheck(start) || nilCheck(end)) return 0;
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:format];
    NSDate *startDate = [f dateFromString:start];
    NSDate *endDate = [f dateFromString:end];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    
    
    return [components day];
}


/**
 @var checkEmail:
 @brief email 유효성 체크
 @param email 주소
 @return 유효성 여부
 */
+ (BOOL)checkEmail:(NSString *)email{
    
    if(!email)
        return NO;
    
    NSString *check = @"([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\\.[0-9a-zA-Z_-]+){1,2}";
    
    NSRange match = [email rangeOfString:check options:NSRegularExpressionSearch];
    
    if (NSNotFound == match.location)
    {
        return NO;
    }
    
    return YES;

}

//로또번호색
+ (UIColor *)getLottoColorWithNumString:(NSString *)lottoNumStr
{
    int lottoNum = [lottoNumStr intValue];
    UIColor *resultColor = nil;
    if( lottoNum <= 10 )
    {
        resultColor = RGBA(255, 68, 73, 1);
    }
    else if( lottoNum > 10 && lottoNum <= 20 )
    {
        resultColor = RGBA(255, 138, 30, 1);
    }
    else if( lottoNum > 20 && lottoNum <= 30 )
    {
        resultColor = RGBA(123, 70, 171, 1);
    }
    else if( lottoNum > 30 && lottoNum <= 40 )
    {
        resultColor = RGBA(230, 73, 158, 1);
    }
    else
    {
        resultColor = RGBA(32, 156, 83, 1);
    }
    
    return resultColor;
}

#pragma mark - 날짜 형식 변환
+ (NSString *)getDateStringWithOrigin:(NSString *)dateStr from:(NSString *)fromFormat to:(NSString *)toFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fromFormat];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    [dateFormatter setDateFormat:toFormat];
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark - query 파싱 (키 , 밸류 디코딩)
+ (NSMutableDictionary *)parseUrl:(NSString*)url
{
    NSString *resultStr = [url stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    NSArray *pairs = [resultStr componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if ([pairs count] == 0) {
        return params;
    }
    
    for (NSString *pair in pairs) {
        if ([pair length] > 0) {
            NSRange equalRange = [pair rangeOfString:@"="];
            if( equalRange.location == NSNotFound ) {
                continue;
            }
            
            NSString *headStr = [pair substringToIndex:equalRange.location].stringByUrlDecoding;
            NSString *tailStr = [pair substringFromIndex:equalRange.location+1].stringByUrlDecoding;
            
            [params setObject:tailStr forKey:headStr];
        }
    }
    return params;
}

+ (NSMutableDictionary *)parseUrlWithoutDecoding:(NSString*)url
{
    NSString *resultStr = [url stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    NSArray *pairs = [resultStr componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if ([pairs count] == 0)
        return params;
    for (NSString *pair in pairs) {
        
        if ([pair length] > 0)
        {
            NSRange equalRange = [pair rangeOfString:@"="];
            if( equalRange.location == NSNotFound )
                continue;
            
            NSString *headStr = [pair substringToIndex:equalRange.location];
            NSString *tailStr = [pair substringFromIndex:equalRange.location+1];
            
            [params setObject:tailStr forKey:headStr];
        }
    }
    return params;
}

#pragma mark - EFDS Device
+ (NSString *)efdsDeviceInfo {
    YmmDeviceInfoUtil *ymmDeviceInfoUtil = [[YmmDeviceInfoUtil alloc] init];
    [ymmDeviceInfoUtil setEncKeyString:@"yhdb_ymobilemonitor_public_key01"];
    [ymmDeviceInfoUtil setChkAppUrlScheme:@""];
    NSDictionary *dict = [ymmDeviceInfoUtil getDeviceInfo];
    NSString *res = @"";
    if (!dict) return res;
    
    NSString *code = [dict objectForKey:@"code"];
    if ([code isEqualToString:@"0000"]) {
        // 정상
        res = [dict objectForKey:@"deviceInfo"];
    }
    
    return res;
}

@end

// 스크래핑 속도개선 
#pragma mark - Synchronized Dictionary, Array

@interface SyncArray()

@property (nonatomic,strong) NSMutableArray *encapsulatedArray;
@property (nonatomic,strong) dispatch_queue_t access_queue;

@end


@implementation SyncArray

- (id)init
{
    if ((self = [super init]))
    {
        self.encapsulatedArray = [NSMutableArray array];
        self.access_queue = dispatch_queue_create([[NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([self class]), self] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - Class Level

+ (id)array
{
    id retVal = [[self alloc] init];
    return retVal;
}

#pragma mark - Read Operations

- (NSUInteger)count
{
    __block NSUInteger retVal;
    dispatch_sync(self.access_queue, ^{
        retVal = self.encapsulatedArray.count;
    });
    return retVal;
}

- (id)objectForIndex:(NSUInteger)index
{
    __block id retValue;
    dispatch_sync(self.access_queue, ^{
        retValue = [self.encapsulatedArray objectAtIndex:index];
    });
                  
    return retValue;
}

- (BOOL)containsObject:(id)anObject
{
    __block BOOL retVal;
    dispatch_sync(self.access_queue, ^{
        retVal = [self.encapsulatedArray containsObject:anObject];
    });
    return retVal;
}

- (BOOL)isEqualToArray:(SyncArray *)otherArray
{
    BOOL retVal = [self isEqual:otherArray];
    if (!retVal)
    {
        NSArray *us = [self nonConcurrentArray];
        NSArray *them = [otherArray nonConcurrentArray];
        retVal = [us isEqualToArray:them];
    }
    
    return retVal;
}

#pragma mark - Augmentitive Operations

#pragma mark Augment

- (void)augmentWithBlock:(void(^)(NSMutableArray *array))block
{
    dispatch_barrier_async(self.access_queue, ^{
        if (block)
        {
            block(self.encapsulatedArray);
        }
    });
}

#pragma mark Add

- (void)addObject:(id)anObject
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray addObject:anObject];
    });
}

- (void)addObjectsFromArray:(NSArray *)otherArray;
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray addObjectsFromArray:otherArray];
    });
}

#pragma mark Remove

- (void)removeObject:(id)anObject
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray removeObject:anObject];
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray removeObjectAtIndex:index];
    });
}


- (void)removeAllObjects
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray removeAllObjects];
    });
}

- (void)removeObjectIdenticalTo:(id)anObject
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray removeObjectIdenticalTo:anObject];
    });
}

- (void)removeObjectsInArray:(NSArray *)otherArray
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray removeObjectsInArray:otherArray];
    });
}

#pragma mark Identity

- (void)setArray:(NSArray *)otherArray
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray setArray:otherArray];
    });
}

#pragma mark Sort

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray sortUsingFunction:compare context:context];
    });
}

- (void)sortUsingSelector:(SEL)comparator
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray sortUsingSelector:comparator];
    });
}

- (void)sortUsingComparator:(NSComparator)cmptr NS_AVAILABLE(10_6, 4_0)
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray sortUsingComparator:cmptr];
    });
}

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr NS_AVAILABLE(10_6, 4_0)
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray sortWithOptions:opts usingComparator:cmptr];
    });
}

#pragma mark Filter

- (void)filterUsingPredicate:(NSPredicate *)predicate
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedArray filterUsingPredicate:predicate];
    });
}

#pragma mark - Snapshot

- (NSArray *)nonConcurrentArray
{
    __block NSArray *retVal;
    dispatch_sync(self.access_queue, ^{
        retVal = [NSArray arrayWithArray:self.encapsulatedArray];
    });
    return retVal;
}

- (NSArray *)drainIntoNonConcurrentArray
{
    __block NSArray *retVal;
    dispatch_barrier_sync(self.access_queue, ^{
        retVal = [NSArray arrayWithArray:self.encapsulatedArray];
        [self.encapsulatedArray removeAllObjects];
    });
    
    return retVal;
}

#pragma mark - Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, count: %d encapsulatedArray: %@ >", NSStringFromClass([self class]), self, (int)self.count, self.encapsulatedArray];
}


@end

@interface SyncDictionary()

@property (nonatomic,strong) NSMutableDictionary *encapsulatedDict;
@property (nonatomic,strong) dispatch_queue_t access_queue;

@end

@implementation SyncDictionary {
    dispatch_queue_t isolationQueue_;
    NSMutableDictionary *storage_;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.encapsulatedDict = [NSMutableDictionary dictionary];
        self.access_queue = dispatch_queue_create([[NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([self class]), self] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - Class Level

+ (id)dictionary
{
    id retVal = [[self alloc] init];
    return retVal;
}

#pragma mark - Read Operations

- (NSUInteger)count
{
    __block NSUInteger retVal;
    dispatch_sync(self.access_queue, ^{
        retVal = self.encapsulatedDict.count;
    });
    return retVal;
}

- (id)objectForKey:(id)key
{
    __block id obj;
    dispatch_sync(self.access_queue, ^{
        obj = [self.encapsulatedDict objectForKey:key];
    });
    return obj;
}

- (BOOL)isEqualToDictionary:(SyncDictionary *)otherDictionary
{
    BOOL retVal = [self isEqual:otherDictionary];
    if (!retVal)
    {
        NSDictionary *us = [self nonConcurrentDictionary];
        NSDictionary *them = [otherDictionary nonConcurrentDictionary];
        retVal = [us isEqualToDictionary:them];
    }
    
    return retVal;
}

#pragma mark - Augmentitive Operations

#pragma mark Augment

- (void)augmentWithBlock:(void(^)(NSMutableDictionary *dictionary))block
{
    dispatch_barrier_async(self.access_queue, ^{
        if (block)
        {
            block(self.encapsulatedDict);
        }
    });
}

#pragma mark Add

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedDict addEntriesFromDictionary:dictionary];
    });
}

#pragma mark Set

- (void)setObject:(id)obj forKey:(id<NSCopying>)key
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedDict setObject:obj forKey:key];
    });
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0)
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedDict setObject:obj forKeyedSubscript:key];
    });
}

#pragma mark Remove

- (void)removeAllObjects
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedDict removeAllObjects];
    });
}

- (void)removeObjectForKey:(id)aKey
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedDict removeObjectForKey:aKey];
    });
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedDict removeObjectsForKeys:keyArray];
    });
}

#pragma mark Identity

- (void)setDictionary:(NSDictionary *)otherDictionary
{
    dispatch_barrier_async(self.access_queue, ^{
        [self.encapsulatedDict setDictionary:otherDictionary];
    });
}

#pragma mark - Snapshot

- (NSDictionary *)nonConcurrentDictionary
{
    __block NSDictionary *retVal;
    dispatch_sync(self.access_queue, ^{
        retVal = [NSDictionary dictionaryWithDictionary:self.encapsulatedDict];
    });
    return retVal;
}

- (NSDictionary *)drainIntoNonConcurrentDictionary
{
    __block NSDictionary *retVal;
    dispatch_barrier_sync(self.access_queue, ^{
        retVal = [NSDictionary dictionaryWithDictionary:self.encapsulatedDict];
        [self.encapsulatedDict removeAllObjects];
    });
    
    return retVal;
}

#pragma mark - Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, count: %d encapsulatedDict: %@ >", NSStringFromClass([self class]), self, (int)self.count, self.encapsulatedDict];
}
@end
