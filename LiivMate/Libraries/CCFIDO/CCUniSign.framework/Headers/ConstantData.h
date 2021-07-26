//
//  ConstantData.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 4. 4..
//  Copyright © 2016년 jwchoi. All rights reserved.
//


//#define NOT_K_FIDO 0
//#define K_FIDO 1

@interface ConstantData : NSObject

/*
 API Result에 사용될 결과코드(FidoFrameWork -> 타사앱)
 enum {
 RESULT_OK = 1,
 RESULT_FAIL = -1,
 USER_CANCEL = 3
 };
 */

typedef enum FIDOWithCert{
    NOT_K_FIDO = 0,
    K_FIDO     = 1
}FIDOWithCert;




typedef enum FidoResult{
    NONE                             = -1,
    COMPLETE                         = 1200,
    MESSAGE_ACCEPTED                 = 1202,
    SERVER_NOT_UNDERSTAND_MESSAGE    = 1400,
    UNAUTHORIZED                     = 1401,
    FORBIDDEN                        = 1403,
    NOT_FOUND                        = 1404,
    REQUEST_TIMEOUT                  = 1408,
    UNKNOWN_AAID                     = 1480,
    UNKNOWN_KEYID                    = 1481,
    CHANNEL_BINDING_REFUSED          = 1490,
    REQUEST_INVALID                  = 1491,
    UNACCEPTABLE_AUTHENTICATOR       = 1492,
    REVOKED_AUTHENTICATOR            = 1493,
    UNACCEPTABLE_KEY                 = 1494,
    UNACCEPTABLE_ALGORITHM           = 1495,
    UNACCEPTABLE_ATTESTATION         = 1496,
    UNACCEPTABLE_CLIENT_CAPABILITIES = 1497,
    UNACCEPTABLE_COUNTENT            = 1498,
    INTERNAL_SERVER_ERROR            = 1500
}FidoResult;


/**Operation Type*/
typedef enum FidoOPType{

    REQ_REGISTRATION_BY_TOUCHID     = 1,
    REQ_REGISTRATION_USE_INDEX      = 2,
    REQ_REGISTRATION_USE_CERT       = 3,
    REQ_REGISTRATION_BY_PASSSIGN    = 4,
    REQ_REGISTRATION_BY_PASSCODE    = 5,
    REQ_REGISTRATION_BY_EYEPRINT    = 6,
    REQ_REGISTRATION_BY_VOICEPRINT  = 7,
    REQ_REGISTRATION_BY_FACEID      = 8,
    REQ_REGISTRATION_BY_PATTERN     = 9,
    REQ_REGISTRATION_BY_FACEPHI     = 10,
    REQ_REGISTRATION_LIMIT          = 19,

    REQ_AUTHENTICATION_BY_TOUCHID   = 20,
    REQ_AUTHENTICATION_BY_PASSSIGN  = 21,
    REQ_AUTHENTICATION_BY_PASSCODE  = 22,
    REQ_AUTHENTICATION_BY_VOICEPRINT= 23,
    REQ_AUTHENTICATION_BY_FACEID    = 24,
    REQ_AUTHENTICATION_BY_PATTERN   = 25,
    REQ_AUTHENTICATION_BY_FACEPHI   = 26,

    REQ_TC_BY_TOUCHID               = 30,
    REQ_TC_BY_PASSSIGN              = 31,
    REQ_TC_BY_PASSCODE              = 32,
    REQ_TC_BY_VOICEPRINT            = 33,
    REQ_TC_BY_FACEID                = 34,
    REQ_TC_BY_PATTERN               = 35,
    REQ_TC_BY_FACEPHI   = 36,

    REQ_DEREGISTRATION              = 50,

    REQ_ERR                         = 100

} FidoOPType;

/**
 Pincode TYPE
 */
typedef enum PinType{
    PINCODE_ENROLL = 1,
    PINCODE_CHANGE = 2,
    PINCODE_DELETE = 3,
    PINCODE_VERIFY = 4
}PinType;

/**
 Biometry TYPE
 */
typedef enum BiometryType{
    BIOMETRY_NONE = 0,
    BIOMETRY_TYPE_TOUCHID = 1,
    BIOMETRY_TYPE_FACEID = 2
}BiometryType;


+(NSString *)getAAID;
+(void)setAAID:(NSString *)aaid;

/*
 +(NSString *)getOPERATION_REG;
 +(NSString *)getOPERATION_REG_WITH_INIT;
 +(NSString *)getOPERATION_AUTH;
 +(NSString *)getOPERATION_DEREG;

 */

//+(NSString *)getFIDOLibLicense;
+(NSString *)getToolkitLicense;
+(void)setToolkitLicense:(NSString *)str;

#pragma mark 고객사 정보
+(NSString *)getRPS_ID;
+(NSString *)getRPS_CODE;
+(void)setRPS_CODE:(NSString *)str;
@end
