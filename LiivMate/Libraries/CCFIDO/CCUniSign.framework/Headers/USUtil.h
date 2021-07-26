//
//  USUtil.h
//  UniSign
//
//  Created by gychoi on 13. 6. 7..
//  Copyright 2013 Crosscert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "USError.h"

#define DEPRECATED  __attribute__ ((deprecated))
#define UNAVAILABLE __attribute__ ((unavailable))

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [LINE:%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#   define ULog(fmt, ...) { UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [LINE:%d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##_VA_ARGS__] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease]; [alert show]; }
#else
#   define DLog(...)
#   define ULog(fmt, ...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [LINE:%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define kUSUtilTimeFormatUTC    @"YYYY-MM-dd HH:mm:ss"
#define kUSUtilTimeFormat       @""

#define kUSUtilTimeZoneUTC      @"UTC"

#define	kUSANSIEncoding	0x80000422

#define IS_4_INCH CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(320.0f, 568.0f)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(568.0f, 320.0f))

typedef enum _USScreenSize {
    kUSScreenSize320X480        = 1,
    kUSScreenSize320X568        = 2,
    kUSScreenSize768X1024       = 10,
    kUSScreenSizeUnknown        = 0
} USScreenSize;

typedef struct _USBin {
    unsigned char*  val;
    unsigned int    len;
} USBin;

@interface USUtil : NSObject {
}

+ (NSString *) deviceName;
+ (NSString *) serial;
+ (NSString *) appID;
+ (NSArray *) urlScheme;

+ (USScreenSize) screenSize;

+ (NSDate *) toDate:(NSString *)date format:(NSString *)format;
+ (NSInteger) remainDaysFromToday:(NSDate *)day;
+ (NSString *) toString:(NSDate *)date;

+ (id) convertTo:(CFTypeRef)ref;

+ (void) store:(id)value name:(NSString *)name;
+ (id) load:(NSString *)name;
+ (void) remove:(NSString *)name;

+ (NSDictionary *) uriParameters:(NSString *)uri;
+ (NSString *) keyFromKVP:(NSString *)kvp;
+ (NSString *) valueFromKVP:(NSString *)kvp;

+ (BOOL) compareWithCurrent:(NSDate *)target;

@end

@interface USUtil (USToolkit)
@end

@interface NSString (USToolkit)

+ (NSString *) utf8String:(const char *)str;
+ (NSString *) ansiString:(const char *)str;
- (const char *) ansiCharsForOutput;
- (const char *) asciiCharsForInput;
- (const char *) ansiCharsWithLoss;
//+ (NSString *) hexString:(NSData *)data;

+ (NSString *) base64Encode:(NSData *)data error:(USError **)error;
+ (NSString *) binToHexString:(NSData *)data error:(USError **)error;
+ (NSString *) integerToString:(NSInteger)integer;
+ (NSString *) urlEncode:(NSString *)str;

//+ (NSString *) intToString:(int)data;
+ (NSString *) intToHexString:(NSNumber *)num;

@end

@interface NSData (USToolkit)

+ (NSData *) base64Decode:(NSString *)string error:(USError **)error;
+ (NSData *) hexStringToBin:(NSString *)string error:(USError **)error;
+ (NSData *) intToNSData:(NSInteger)data;
+ (NSData *) intToNSDataWith2byte:(NSInteger)data;
@end

@interface NSValue (USToolkit)
@end

@interface NSNumber (USToolkit)

+ (NSNumber *)hexStringToDecimal:(NSString *)hexString;

@end
