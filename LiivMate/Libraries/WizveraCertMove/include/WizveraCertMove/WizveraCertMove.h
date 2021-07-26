/*  WizveraCertMove.h
    Copyright © 2016년 wizvera. All rights reserved.
    version: 1.3.0
 */


#ifndef WIZVERACERTMOVE_H
#define WIZVERACERTMOVE_H

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, WizveraCertMoveErrorCode) {
    WCME_Success = 0,
    WCME_InvalidURL	= 1,
    WCME_ConnectFail = 2,
    WCME_HttpStatusError = 3,
    WCME_HttpReadError = 4,
    WCME_ProtocolError = 5,
    WCME_IllegalCalled = 6,
    WCME_VerifyPubKeyFail = 7,
    WCME_InvalidAuthCode = 8,
    WCME_Timeout = 9,
    WCME_Cancel = 10,
    WCME_InternalError = 11,
    WCME_ResponseError = 12
};

@interface WizveraCertMoveResult : NSObject

@property WizveraCertMoveErrorCode errorCode;
@property int detailErrorCode;
@property NSString* errorMessage;
@property NSString* authCode;
@property NSData* pkcs12;

@end


@interface WizveraCertMove : NSObject
+ (NSString*) version;
+ (WizveraCertMove*)create:(NSString*) url;
+ (void)allowsAnyHTTPSCertificate;
+ (void)setLogLevel:(int)level;

- (WizveraCertMoveResult*)requestAuthCode;
- (WizveraCertMoveResult*)sendPKCS12:(NSData*)pkcs12;
- (WizveraCertMoveResult*)cancelSendPKCS12;

- (WizveraCertMoveResult*)requestPKCS12:(NSString*)authCode;

@end

 
#endif // WIZVERACERTMOVE_H
