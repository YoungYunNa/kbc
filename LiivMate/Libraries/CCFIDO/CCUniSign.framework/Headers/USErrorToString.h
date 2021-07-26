/**
 * @file USErrorToString.h
 * @date 2010/10/26
 * @author 송상일(danox@europa.snu.ac.kr)
 * @brief 에러코드를 문자열로 변환
 * @warning
 */

//#import "UST_Error.h"
#import <Foundation/Foundation.h>

@interface USErrorToString : NSObject {

}

+(NSString *) lastError;
+(NSString *) errorToString:(int)errorCode;
+(BOOL)isVerificationError:(NSString *)errorMessage;
+(BOOL)isVerificationRevokedError:(int)errorCode;
+(BOOL)isVerificationExpiredError:(int)errorCode;
+(NSString *)alertMessage:(NSString*)errorMessage;

@end
