//
//  WizveraPKCS12.h
//  WizveraCertMove
//
//  Copyright © 2017년 wizvera. All rights reserved.
//

#ifndef WizveraPKCS12_h
#define WizveraPKCS12_h

typedef NS_ENUM(int, WizveraPKCS12ErrorCode) {
    WP12E_Success = 0,
    WP12E_Error = 100,
    WP12E_InvalidPassword = 101,
    WP12E_IncorrectPassword = 102,
    WP12E_InvalidSignCert = 103,
    WP12E_InvalidSignPri = 104,
    
    WP12E_InvalidKmCert = 105,
    WP12E_InvalidKmPri = 106,
    
    
    WP12E_CreatePKCS12Fail = 107,
    
    WP12E_InvalidPKCS12 = 108,
    
    WP12E_NotContainSignCert = 109,
    WP12E_MallocFail = 110,
    WP12E_InsufficientBuffer = 111,
    
};

typedef NS_ENUM(int, WizveraPriKeyType) {
    WPKT_EncPriKeyInfo = 0,
    WPKT_RawPriKeyInfo = 1
};

@interface WizveraPKCS12 : NSObject

@property NSData* signCert;
@property NSData* signPri;
@property NSData* kmCert;
@property NSData* kmPri;
@property NSData* pkcs12;

- (WizveraPKCS12ErrorCode)create:(NSString*)password priKeyType:(WizveraPriKeyType)priKeyType;
- (WizveraPKCS12ErrorCode)parse:(NSString*)password;

@end

#endif /* WizveraPKCS12_h */
