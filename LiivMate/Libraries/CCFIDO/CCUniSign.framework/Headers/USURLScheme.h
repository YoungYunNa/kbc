//
//  USURLScheme.h
//  UniSignLibrary
//
//  Created by 근영 최 on 13. 8. 22..
//
//

#import <Foundation/Foundation.h>

#define kUSSchemeKeylanguageType       @"language"
#define kUSSchemeKeyProductType        @"product_type"
#define kUSSchemeKeyCommand            @"cmd"
#define kUSSchemeKeyRequestCode        @"requestCode"
#define kUSSchemeKeyReturnURL          @"retURL"
#define kUSSchemeKeyAppKey             @"appkey"
#define kUSSchemeKeyData               @"data"
#define kUSSchemeKeyOption             @"option"
#define kUSSchemeKeyRtnParam           @"rtnParam"
#define kUSSchemeKeySIDOption          @"sidOption"
#define kUSSchemeKeySIDValue           @"sidValue"
#define kUSSchemeKeySIDCheck           @"sidCheck"
#define kUSSchemeKeySIDResult          @"sidResult"
#define kUSSchemeKeyProcURL            @"procURL"
#define kUSSchemeKeyP12                @"p12"
#define kUSSchemeKeyP12Key             @"p12key"
#define kUSSchemeKeyCaller             @"caller"
#define kUSSchemeKeyCallerActivity     @"callerActivity"
#define kUSSchemeKeyCallerURLScheme    @"caller_url_scheme"
#define kUSSchemeKeyResult             @"result"
#define kUSSchemeKeyErrorCode          @"errCode"
#define kUSSchemeKeyErrorMessage       @"errMsg"
#define kUSSchemeKeyRelayErrorCode     @"relayErrCode"
#define kUSSchemeKeyRelayErrorMessage  @"relayErrMsg"
#define kUSSchemeKeyFilter             @"flt"
#define kUSSchemeKeyCallback           @"callback"
#define kUSSchemeKeyRefNum             @"refnum"
#define kUSSchemeKeyAuthNum            @"authnum"
#define kUSSchemeKeyEncVID             @"encVid"
#define kUSSchemeKeyDebug              @"debug"
#define kUSSchemeKeyCert               @"cert"
#define kUSSchemeKeyFIDOProtocol       @"json_protocol"
#define kUSSchemeKeyUUID               @"uuid"
#define kUSSchemeKeyCertDN             @"certdn"
#define kUSSchemeKeycertOIDs           @"certOIDs"
#define kUSSchemeKeyTID                @"tid"
#define kUSSchemeKeyMrsUrl             @"mrsUrl"


//------------------Language Type - language------------------
#define CCLANGUAGE_KO        @"ko"
#define CCLANGUAGE_EN        @"en"
//------------------end-------------------------------

//------------------ProductType - productType------------------
#define kUSSchemeProductTypeFIDO        @"FIDO"
#define kUSSchemeProductTypeCloudSign   @"CS"
#define kUSSchemeProductTypeUniSign     @"US"
#define kUSSchemeProductTypeFIDO_PINPAD @"FIDO_PINPAD"
#define kUSSchemeProductTypeUniDocSign  @"UDS"
//------------------end-------------------------------

//------------------ServieType - cmd------------------
// unisign용 서비스 타입
#define kUSSchemeCMDManagement      @"ManageCert"
#define kUSSchemeCMDLicenseInfo     @"LicenseInfo"
#define kUSSchemeCMDImport          @"ImportCert"
#define kUSSchemeCMDImportWithOlleh @"ImportCertEx"
#define kUSSchemeCMDExport          @"ExportCert"
#define kUSSchemeCMDExportWithOlleh @"ExportCertEx"
#define kUSSchemeCMDIssue           @"IssueCert"
#define kUSSchemeCMDRenew           @"UpdateCert"
#define kUSSchemeCMDDisuse          @"RevokeCert"
#define kUSSchemeCMDESign           @"SignedData"
#define kUSSchemeCMDESignWithOlleh  @"SignedDataEx"

#define kUSSchemeCMDESignWithEncVID @"SignedDataWithEncVID"
#define kUSSchemeCMDVerifySign      @"VerifySignedData"
#define kUSSchemeCMDEtax            @"Etax"
#define kUSSchemeCMDVidr            @"VIDR"
#define kUSSchemeCMDBackupStore     @"BackupStore"
#define kUSSchemeCMDBackupLoad      @"BackupLoad"
// FIDO용 서비스 타입
#define CCFIDO_OP_REG             @"Reg"
#define CCFIDO_OP_REG_WITH_INIT   @"InitReg"
#define CCFIDO_OP_AUTH            @"Auth"
#define CCFIDO_OP_DEREG           @"Dereg" // Auth 후 Dereg 실행
#define CCFIDO_OP_DIRECT_DEREG    @"DirectDereg" // 인증없이 Dereg 실행
#define CCFIDO_OP_REG_STATE       @"RegState"
//------------------end-------------------------------

// FIDO-PIN 서비스 타입
#define OPERATION_PIN_REG       @"Reg"
#define OPERATION_PIN_MODIFY    @"Modify"
#define OPERATION_PIN_DEREG     @"Dereg"
//------------------end-------------------------------

//-------UniSign + MessageRelay-------------
#define kUSSchemeCMDESignWithMessageRelay @"SignedDataWithMR"
//-------end-------------

//#define kUSSchemeVersion    @"ver"
//#define kUSSchemeAuthNumber @"num"
//#define kUSSchemeIV         @"iv"
//#define kUSSchemeChecksum   @"chk"
//#define kUSSchemeCallback   @"cb"
//#define kUSSchemeReturn     @"rtn"
//#define kUSSchemeLicense    @"lic"

//#define kUSSchemeCMDMove        @"mvCert"


#define kUSSchemeVER2_0     @"2_0"

#define kUSSchemeHTTP       @"http"
#define kUSSchemeHTTPS      @"https"


typedef enum _USSchemeType {
    kUSSchemeTypeWeb            = 1,
    kUSSchemeTypeApplication    = 2,
    kUSSchemeTypeHybrid         = 3,
    kUSSchemeTypeUnknown        = 99,
} USSchemeType;

typedef enum _USSchemeFilterCA {
    kUSSchemeFilterCAAll        = 0x0F00,
    kUSSchemeFilterCrossCert    = 0x0000,
    kUSSchemeFilterYesSign      = 0x0100,
    kUSSchemeFilterSignKorea    = 0x0200,
    kUSSchemeFilterKICA         = 0x0400,
    kUSSchemeFilterTradeSign    = 0x0800,
    kUSSchemeFilterIniPass      = 0x1000,
} USSchemeFilterCA;

typedef enum _USSchemeFilterCertState {
    kUSSchemeFilterCertAll              = 0x00,
    kUSSchemeFilterCertValidDuration    = 0x01,
    kUSSchemeFilterCertValidState       = 0x02,
} USSchemeFilterCertState;

typedef enum _USServiceType {
    //-------Unisign-------------
    kUSServiceDefault       = 0,
    kUSServiceManage        = 1,
    kUSServiceLicenseInfo   = 2,
    kUSServiceImport        = 3,
    kUSServiceExport        = 4,
    kUSServiceIssue         = 5,
    kUSServiceRenew         = 6,
    kUSServiceDisuse        = 7,
    kUSServiceESign         = 8, // 전자서명
    //    kUSServiceESignWithEncVID   = 9,
    //    kUSServiceSignAndVID    = 3,
    kUSServiceEtax          = 10,
    kUSServiceVidr          = 12,
    kUSServiceBackupStore   = 13,
    kUSServiceBackupLoad    = 14,
    kUSServiceVerificationESign = 15, // 전자서명 검증
    //    kUSServiceMove      = 7,
    //    kUSServiceQRImport  = 10,
    //    kUSServiceQRExport  = 11,
    //-------end-------------

    //-------FIDO-------------
    kUSServiceReg           = 100,
    kUSServiceAuth          = 101,
    kUSServiceTC            = 102,
    kUSServiceDeReg         = 103,
    //-------end-------------

    //-------PINCODE-------------
    kUSServicePinReg        = 200,
    kUSServicePinModify     = 201,
    kUSServicePinDereg      = 202,
    //-------end-------------

    //-------UniSign + MessageRelay-------------
    kUSServiceESignWithMessageRelay       = 300,
    //-------end-------------

    kUSServiceUnknown   = -1,
} USServiceType;

typedef enum _USProductType {
    kUSProductUniSign       = 1,
    kUSProductFIDO          = 2,
    kUSProductCloudSign     = 3,
    kUSProductFIDO_PINPAD   = 4,
    kUSProductUniDocSign    = 5,
} USProductType;

typedef enum _USServiceOption {
    kUSServiceOptionDefault                     = 1,
    kUSServiceOptionImportByOllehCertificate    = 2,
    kUSServiceOptionExportByOllehCertificate    = 3,
    kUSServiceOptionSignByOllehCertificate      = 4,
    kUSServiceOptionSignWithVIDR                = 5,//전자서명 + 개인키R
    kUSServiceOptionSignWithVerifySSN           = 6,//전자서명 + 본인확인
    kUSServiceOptionSignWithVIDRByProcURL       = 7,
    kUSServiceOptionSignWithVerifySSNByProcURL  = 8,
    kUSServiceOptionSignWithEncVID              = 9,
    kUSServiceOptionVIDR                        = 10,
    kUSServiceOptionVIDVerifySSN                = 11,
    kUSServiceOptionSignWithNoContent           = 12,
    kUSServiceOptionSignWithUUID                = 13,//전자서명 + UUID
    kUSServiceOptionSignWithDN                  = 14,//전자서명 + 인증서 DN
    kUSServiceOptionSignWithDN_R                = 15,//전자서명 + 인증서 DN + R
    
    kUSServiceOptionUnknown                     = -1,
} USServiceOption;

typedef enum _USServiceVIDOption {
    kUSServiceVIDR               = 1,
    kUSServiceVIDVerifySSN       = 2,
    kUSServiceSignWithNoContent  = 3,
    kUSServiceSignWithUUID       = 4,
    kUSServiceSignWithDN         = 5,
    kUSServiceSignWithDN_R       = 6,
    kUSServiceVIDUnknown         = -1,
} USServiceVIDOption;

@interface USURLScheme : NSObject {
    NSString    *_url;
}

+ (id) getInstance;
//+ (BOOL) isSupportedVersion:(NSString *)ver;
- (BOOL) setRequest:(NSString *)uri;
- (NSString *) getURL;
//- (BOOL) isVersion:(const NSString *)ver;
- (void) clearRequest;
- (BOOL) isAvailable;
- (BOOL) hasRequest;
- (NSString *) getParameter:(const NSString *)key;
- (NSString *) getResponse:(NSDictionary *)params error:(NSString *)error;
+ (NSString *) makeWebResponse:(NSString *)customScheme url:(NSString *)url params:(NSDictionary *)params;

/**
 @brief
 제품 세팅 언어

 @return
 한글(CCLANGUAGE_KO) : ko
 영어(CCLANGUAGE_EN) : en
 */
- (NSString *)getLanguage;
/**
 @brief 제품 타입 추출
 */
- (USProductType) getProductType;
- (USServiceType) getServiceType;
- (USServiceOption) getServiceOption;
- (NSString *) getFIDOProtocol;
+ (NSString *) makeRequest:(const NSString *)cmd callback:(NSString *)callback params:(NSDictionary *)params;

+ (USServiceType) serviceType:(NSString *)cmd;
- (USSchemeType) getCallerType;
- (NSString *) getCallerID;
- (NSInteger) getDebugLevel;

+ (BOOL) hasNoHost:(NSString *)url;
+ (BOOL) hasNoQuery:(NSString *)url;


@end
