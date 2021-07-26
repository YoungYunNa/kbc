//
//  OBJCCertTransfer.h
//  USXToolkit
//
//  Created by gychoi on 12. 4. 10..
//  Copyright 2012 Crosscert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "USError.h"

#import "USCertificate.h"

#define UST_ERR_WRONG_VERSION   -1070
#define UST_ERR_WRONG_VERSION_MSG   @"Version is wrong"

typedef enum _USTransVersion {
    kUSTransV1_0    = 0x0100,
    kUSTransV2_0    = 0x0200
} USTransVersion;

typedef enum _USTransDirection {
    kUSTransImport      = 0x10,
    kUSTransExport      = 0x20
} USTransDirection;

typedef enum _USTransRole {
    kUSTransSender      = 0x10,
    kUSTransReceiver    = 0x20
} USTransRole;

typedef enum _USTransAuthType {
    kUSTransAuthNumber  = 0x10,
    kUSTransQRCode      = 0x20
} USTransAuthType;

typedef enum _USTransUserType {
    kUSTransOwn         = 0x00,
    kUSTransOther       = 0x01,
    kUSTransPC          = 0x02
} USTransUserType;

typedef enum _USTransDeviceOSType {
    kUSTransIOS         = 0x10,
    kUSTransWindowsMobile   = 0x20,
    kUSTransAndroid     = 0x30,
    kUSTransWindows     = 0x40,
    kUSTransLinux       = 0x50,
    kUSTransMac         = 0x60
} USTransDeviceOSType;

@interface OBJCCertTransfer : NSObject {
    
}

/* Transfer --------------------------------------------------------------------- */
- (id) TRANS_Init:(NSString *)ipAddr
             port:(NSInteger)port
            appID:(NSString *)appID
           appKey:(NSString *)appKey
             type:(USTransUserType)type
            error:(USError **)error;

- (NSString *) TRANS_GenerateCertNum:(USTransDeviceOSType)type direction:(USTransDirection)direction serial:(NSString *)serial error:(USError **)error;

// for PC, not used on smartphone
//CERTTRANSFER_API int UST_TRANS_IsSmartPhoneConnected(void *pContext, char *szCertNum,
//													 char **ppPhoneHash, char **ppPhoneInfo,
//													 int *pnPhoneKind, int *pnDirection, char **ppErrorMsg);
- (USCertificate *) TRANS_VeriSign_ImportCert:(NSString *)appID deviceID:(NSString *)deviceID error:(USError **)error;
- (NSData *) TRANS_VeriSign_SignedData:(NSString *)appID deviceID:(NSString *)deviceID cert:(USCertificate *)cert data:(NSData *)data error:(USError **)error;
- (NSData *) TRANS_Password_GenOut:(NSString *)appID deviceID:(NSString *)deviceID error:(USError **)error;
- (BOOL) TRANS_IsPCConnected:(USError **)error;
- (USCertificate *) TRANS_ImportCert:(USError **)error;
- (BOOL) TRANS_Exportcert:(USCertificate *)cert encAlg:(NSInteger)encAlg error:(USError **)error;
- (BOOL) TRANS_Finalize;
- (void) TRANS_Free:(void **)data;

/* Transfer v2.0 ---------------------------------------------------------------- */

- (id) TRANS_V2_Init:(NSString *)ipAddr port:(NSInteger)port appID:(NSString *)appID appKey:(NSString *)appKey type:(USTransUserType)transUserType error:(USError **)error;
- (NSString *) TRANS_V2_GenerateCertNum:(USTransDeviceOSType)type serial:(NSString *)serial password:(NSString *)password certificate:(USCertificate *)cert error:(USError **)error;
- (BOOL) TRANS_V2_IsReceiverConnected:(USTransRole *)role deviceUID:(NSString **)uid deviceName:(NSString **)name os:(USTransDeviceOSType *)os error:(USError **)error;
- (BOOL) TRANS_V2_Exportcert:(USCertificate *)cert encAlg:(NSInteger)encAlg error:(USError **)error;
- (BOOL) TRANS_V2_SendReceiverInfo:(NSString *)uid deviceName:(NSString *)name os:(USTransDeviceOSType)os connectKey:(NSString *)connectKey authType:(USTransAuthType)type error:(USError **)error;
- (USCertificate *) TRANS_V2_ImportCert:(USError **)error;
- (void) TRANS_V2_AbnormalError;
- (BOOL) TRANS_V2_Finalize;
- (void) TRANS_V2_Free:(void **)data;

- (NSString *) TRANS_V2_AuthURLForQRCode:(NSString *)authnum error:(USError **)error;
- (BOOL) TRANS_V2_VerifyQRCodeCheckSum:(NSString *)uri error:(USError **)error;

- (NSData *) TRANS_V2_GenerateCertNumEx1:(NSString *)serial authNum:(NSString **)authnum error:(USError **)error;
- (NSString *) TRANS_V2_GenerateCertNumEx2:(NSData *)signedData authNum:(NSString*)authnum error:(USError **)error;

@end
