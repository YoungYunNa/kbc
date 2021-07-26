//
//  DataTypeConvertUtil.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 3. 31..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#ifndef ConvertUtil_h
#define ConvertUtil_h


#endif /* ConvertUtil_h */

@interface DataTypeConvertUtil : NSObject

+(instancetype) getInstance;

#pragma mark url safe
-(NSString *)applyUrlsafe:(NSData *)secretKey;
-(NSString *)applyUrlsafeByStr:(NSString *)str;
-(NSString *)decodeUrlsafe:(NSString *)secretKey;
#pragma mark no padding
-(NSString *)applyNonPadding:(NSString *)str;
-(NSString *)decodeNonPadding:(NSString *)str;

/*
 NSData(by json) -> NSDictionary(by json)
 */
-(NSDictionary *)convertNSDataToNSDictionary:(NSData *)jsonData;

/*
 NSData(by json) -> NSString(by json)
 */
-(NSString *)convertNSDataToNSString:(NSData *)jsonData;


/*
 NSDictionary(by json) -> NSData(by json)
 */
-(NSData *)convertNSDictionaryToNSData:(NSDictionary *)jsonDictionary;

/*
 NSDictionary(by json) -> NSString(by json)
 */
-(NSString *)convertNSDictionaryToNSString:(NSDictionary *)jsonDictionary;

/*
 NSString(by json) -> NSData(by json)
 */
-(NSData *)convertNSStringToNSData:(NSString *)jsonString;

/*
 NSString(by json) -> NSDictionary(by json)
 */
-(NSDictionary *)convertNSStringToNSDictionary:(NSString *)jsonString;


@end
