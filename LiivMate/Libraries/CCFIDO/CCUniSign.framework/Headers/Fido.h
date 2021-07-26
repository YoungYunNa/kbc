//
//  Fido.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 4. 5..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "USToolkitMgr.h"
#import "ConstantData.h"
@class USToolkitMgr;
@class USError;
@class FMDatabase;
@class USCertificate;
@class LicenseCheck;
@class ViewCertificate;
@class ConstantData;


/**
 @discussion 바이오 인증수단 변경 여부를 확인한다. : registration할때 사용된 바이오정보와 현재 바이오정보 일치 여부 확인
 
 */
#define BIO_METRICS_CHANGED        1 // 변경됨
#define BIO_METRICS_UNCHANGED      2 // 변경되지 않음

// FIDO용 서비스 타입
#define CCFIDO_OP_REG             @"Reg"
#define CCFIDO_OP_REG_WITH_INIT   @"InitReg"
#define CCFIDO_OP_AUTH            @"Auth"
#define CCFIDO_OP_DEREG           @"Dereg" // Auth 후 Dereg 실행
#define CCFIDO_OP_DIRECT_DEREG    @"DirectDereg" // 인증없이 Dereg 실행
#define CCFIDO_OP_REG_STATE       @"RegState"

@interface Fido : NSObject

+(instancetype _Nullable ) getInstance;

/**
 @discussion 'touchIDResult block object' is receive the results of 'Bio metrics authentication' with response message'.
 */
@property (nonatomic, copy) void(^ _Nullable touchIDResult)(NSDictionary * _Nullable responseMesage, NSError * _Nullable error);

/**
 @discussion 'Registration Check Block Object' receives 'FIDO Registration' check result from Fido Server.
 */
@property (nonatomic, copy) void (^ _Nullable registrationCheck)(NSString * _Nullable response);

#pragma mark 초기화 관련

/**
 @discussion Initialize Framework.
 @param error : Double pointer of error.
 @return YES : Succeed, NO : Failure.
 */
-(BOOL)initFidoLib:(USError *_Nullable*_Nullable)error;

/**
 @discussion Initialize Framework.
 @param appID : bundleID
 @param error : Double pointer of error.
 @return YES : Succeed, NO : Failure.
 */
-(BOOL)initFidoLib:(NSString *_Nullable)appID error:(USError *_Nullable*_Nullable)error;

/**
 @discussion Initialize Framework.(when used to PushToApp type.)
 @param appID : AppID of Customer's web page(caller_url_scheme)
 @param toolkitLicense : License for Library type.
 @param error : Double pointer of error.
 @return YES : Succeed, NO : Failure.
 */
-(BOOL)initFidoLib:(NSString *_Nullable)appID
    toolkitLicense:(NSString *_Nullable)toolkitLicense
             error:(USError *_Nullable*_Nullable)error;


/**
 //  If you don't have it send 'License Info' to 'Crosscert technical manager'.
 @discussion Set license that issued by 'crosscert'.
 @param license : license that issued by 'crosscert'.
 @param uuid : UUID string.
 */
-(void)setLicense:(NSArray *_Nullable)licenses
             uuid:(NSString *_Nullable)uuid;

#pragma mark 라이선스 관련
/**
 @discussion  get 'License Info'. That is information for issuing license.
 */
-(NSString *_Nullable)getLicenseInfo;

#pragma mark 초기화 및 설정 관련
/**
 @discussion Set whether to verify 'FacetID'.
 @param (BOOL)isSkip : YES - Skip verify 'FacetId' , NO - verify 'FacetId'
 */
-(void)setIsSkipToVerifyFacetID:(BOOL)isSkip;

/**
 @discussion Restricts operation of FIDO when bio information changes.
 @param (BOOL)isRestrict : YES - Restricts operation, NO- Not restricts operation
 */
-(void)setRestrictFidoWhenBioMetricsChanged:(BOOL)isRestrict;

/**
 @discussion 바이오인증 시도 가능 횟수를 설정한다.(K_FIDO용)
 20160921 : iOS에서 지문 입력 실패 3회시 에러코드를 리턴하며 다시 지문입력을 요청 후 2번 실패하게 되면 패스코드 입력 창으로 넘어가게 된다. 이것을 1 round라고 가정 하였을때 몇 round까지 시도 할 수 있는지 설정 한다.
 20200526 : iOS에서 5회 인증 실패 시 바이오 인증 락이되기 때문에 API를 사용하여 제어할 수 없는 상황이다. 이 때문에 시도 가능 획수 제어 기능을 제거 한다.

 @param availableCount : round 횟수
 */
//-(void)setAvailableCountOfBioAuthenticationForKFido:(NSString *_Nullable)availableCount;

/**
 @discussion 바이오인증 시도 가능 횟수를 설정한다.(NOT_K_FIDO용)
 20160921 : iOS에서 지문 입력 실패 3회시 에러코드를 리턴하며 다시 지문입력을 요청 후 2번 실패하게 되면 패스코드 입력 창으로 넘어가게 된다. 이것을 1 round라고 가정 하였을때 몇 round까지 시도 할 수 있는지 설정 한다.
 20200526 : iOS에서 5회 인증 실패 시 바이오 인증 락이되기 때문에 API를 사용하여 제어할 수 없는 상황이다. 이 때문에 시도 가능 획수 제어 기능을 제거 한다.
 @param availableCount : round 횟수
 */
//-(void)setAvailableCountOfBioAuthenticationForNotKFido:(NSString *_Nullable)availableCount;

/**
 @discussion 보이스인증 시도 가능 횟수를 설정한다.(K_FIDO용)
 20160921 : iOS에서 지문 입력 실패 3회시 에러코드를 리턴하며 다시 지문입력을 요청 후 2번 실패하게 되면 패스코드 입력 창으로 넘어가게 된다. 이것을 1 round라고 가정 하였을때 몇 round까지 시도 할 수 있는지 설정 한다.
 @param availableCount : round 횟수
 */
-(void)setAvailableCountOfBioAuthenticationForKFidoWithVoice:(NSString *_Nullable)availableCount;

/**
 @discussion 보이스인증 시도 가능 횟수를 설정한다.(NOT_K_FIDO용)
 20160921 : iOS에서 지문 입력 실패 3회시 에러코드를 리턴하며 다시 지문입력을 요청 후 2번 실패하게 되면 패스코드 입력 창으로 넘어가게 된다. 이것을 1 round라고 가정 하였을때 몇 round까지 시도 할 수 있는지 설정 한다.

 @param availableCount : round 횟수
 */
-(void)setAvailableCountOfBioAuthenticationForNotKFidoWithVoice:(NSString *_Nullable)availableCount;

/**
 @discussion 보이스 인증 시도 가능 횟수 초기화
 */
-(void)initAvailableCountOfVoiceAuthentication;



#pragma mark Framework - RPS간 통신
/**
 @discussion Run the Request Operation.
        // Request 오퍼레이션을 실행한다.
 @param serverUrl           : value to be used as the Fido Server URL.// 접속할 Fido Server URL
 @param operationType       : 'FidoOPType' for the 'FIDO Operation'. //오퍼레이션 타입에 따라 로직 분기
 @param aTarget                     : delegate
 @param completeSelector           : Registration 결과를 리턴받을 SEL
 @param registeredTypeCheckSelector: Auth 및 TC시 Registration의 타입을 체크하여 인증서를 사용하여 Registration한 경우 인증서 확인창을 보여준다. 아닌 경우 인증 진행
 @param registrationTypeSelector   : Registration시 touchId, passcode, passign등 타입을 리턴하여 준다
 @param userId              : 사용자 아이디
 @param certIndex                  : reg시 FidoFrameWork을 이용하여 저장된 인증서를 사용할 경우 인증서의 인덱스를 넘겨준다
 @param cert                  : reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서
 @param privateKey            : reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서 privateKey
 @param pw                  : reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서 비밀번호
 @param tCContent           : 'tcContent' is a strings used in 'Transaction Confirmation'. If 'tCContent' exists, FIDO_OPERATION is 'Transaction Confirmation' and not 'Authentication'.
                                        TC시 데이터
 @param extData       : Extra data to be included in 'requestMessage'. Default is empty strings. 'extData' is passed to the RPS.
     고객사에서 RPS로 전달할 임의 데이터
 */

-(void)executeTriggerWithRequest:(NSString *_Nullable)serverUrl
                   operationType:(FidoOPType)operationType
                         aTarget:(id _Nullable )aTarget
                completeSelector:(SEL _Nullable )completeSelector
          registeredTypeCheckSel:(SEL _Nullable )regTypeCheckSelector
             registrationTypeSel:(SEL _Nullable)registrationTypeSelector
                          userId:(NSString *_Nullable)userId
                       certIndex:(int)certIndex
                            cert:(NSData *_Nullable)cert
                      privateKey:(NSData *_Nullable)privateKey
                        password:(NSString *_Nullable)pw
                       tCContent:(NSString *_Nullable)tCContent
                         extData:(NSString *_Nullable)extData;

/**
 @discussion 터치 아이디 입력 화면(TouchId 성공시 Operation을 실행한다.)
 */
-(void)showTouchId;


/**
 @discussion BIOType별로(현재 Passsign, pincode)각화면에서 검증 후 Operation Type에 따라 Operation을 실행한다
 @param (int)bioType : 홍체, 지문, 패턴 등...
 */
-(void)executeTriggerWithResponse:(int)bioType;

/**
 @discussion Pincode타입일때 App에서 핀코드 확인 후 responseMsg를 생성하여 리턴한다.
 @param bioType : 홍체, 지문, 패턴 등...
 @param tcContent : 'tcContent' is a strings used in 'Transaction Confirmation'. If 'tCContent' exists, FIDO_OPERATION is 'Transaction Confirmation' and not 'Authentication'.
                          TC시 데이터
 @param isKFido : K-FIDO 여부
 @param error : 에러 객체 포인터
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateResponseMessage:(int)bioType
                                                                tcContent:(NSString *_Nullable)tcContent
                                                                  isKFido:(FIDOWithCert)isKFido
                                                                    error:(NSError *_Nullable*_Nullable)error;


/**
 @discussion 서버에 Registartion 확인
 @param url     : 서버 URL
 @param userId  : 유저아이디
 */
-(void)checkRegistrationToServer:(NSString *_Nullable)url
                          userId:(NSString *_Nullable)userId;


/**
 @discussion Check whether user registered on FIDO.
        Registration 확인
 @param userId      : The ID used when registering.
 @param isKFido  : Whether to use a certificate.
                           K-FIDO 여부(인증서 사용 여부)
 @param serviceName : The name of service used when registering.
                               여러개의 서비스에서 따로따로 등록 할 경우 구분하기 위한 값
 @return The result of checking if the user is registered with FIDO in Library.
 */
-(BOOL)checkRegistrationToLocal:(NSString *_Nullable)userId
                        isKFido:(FIDOWithCert)isKFido
                    serviceName:(NSString *_Nullable)serviceName;
#pragma mark -------------Framework - RPS간 통신 끝-------------


#pragma mark Sample - RPS간 통신

/**
 @discussion Perform bio-metrics.

 @param tcContent   : 'tcContent' is a string used in 'transaction Confirmation'.
 @param isKFido  : Whether to use a certificate.
 @return to block. Returns the result to ‘touchIDResult’. ‘touchIDResult’ contains response message for FIDO operation.
 */
//-(void)showTouchIdForWithMessage:(NSString *_Nullable)tcContent
//                         isKFido:(int)isKFido;

-(void)showTouchIdForWithMessage:(NSString *_Nullable)tcContent
                         isKFido:(FIDOWithCert)isKFido;

/**
 @discussion 서버에 Registartion 등록 여부 확인 URL을 리턴한다.
 @param url     : 서버 URL
 @param userId  : 유저아이디
 @return NSString   : Registartion 등록 여부 확인 URL
 */
-(NSString *_Nullable)getURLToCheckRegistrationToServer:(NSString *_Nullable)url
                                                 userId:(NSString *_Nullable)userId;

/**
 @discussion 서버에 Registartion 등록 여부 확인 URL을 리턴한다.
 @param url     : 서버 URL
 @param userId  : 유저아이디
 @param isKFido     : K-FIDO 여부(인증서 사용 여부)
 @return NSString   : Registartion 등록 여부 확인 URL
 */
-(NSString *_Nullable)getURLToCheckRegistrationToServer:(NSString *_Nullable)url
                                                 userId:(NSString *_Nullable)userId
                                                isKFido:(FIDOWithCert)isKFido;

/**
 @discussion 서버에 Registartion 등록 여부 확인 URL을 리턴한다.
 @param url     : 서버 URL
 @param userId  : 유저아이디
 @param isKFido     : K-FIDO 여부(인증서 사용 여부)
 @param serviceName : 여러개의 서비스에서 따로따로 등록 할 경우 구분하기 위한 값
 @return NSString   : Registartion 등록 여부 확인 URL
 */
-(NSString *_Nullable)getURLToCheckRegistrationToServer:(NSString *_Nullable)url
                                                 userId:(NSString *_Nullable)userId
                                                isKFido:(FIDOWithCert)isKFido
                                            serviceName:(NSString *_Nullable)serviceName;






/**
 @discussion Generate requestMessage for 'Registration'.
        Registration시 필요한 RequestMessage 를 생성한다.
 @param operationType : 'FidoOPType' to be used if generate request message for 'FIDO auth'.
                                 오퍼레이션 타입
 @param userId        : 'userId' to be used if generate request message for 'FIDO auth'.
                             사용자 아이디
 @param extData       : Extra data to be included in 'requestMessage'. Default is empty strings. 'extData' is passed to the RPS.
     고객사에서 RPS로 전달할 임의 데이터
 @return Returns 'NSDictionary'. 'NSDictionary' is the generated request message for 'Registration'.

 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForRegistration:(FidoOPType)operationType
                                                         userId:(NSString *_Nullable)userId
                                                        extData:(NSString *_Nullable)extData;

/**
 @discussion Generate requestMessage for'Registration'.
        Registration시 필요한 RequestMessage 를 생성한다.
 @param operationType : 'FidoOPType' to be used if generate request message for 'FIDO auth'.
                                 오퍼레이션 타입
 @param userId        : 'userId' to be used if generate request message for 'FIDO auth'.
                             사용자 아이디
 @param extData       : Extra data to be included in 'requestMessage'. Default is empty strings. 'extData' is passed to the RPS.
 고객사에서 RPS로 전달할 임의 데이터
 @param isKFido     : Whether to use a certificate
     K-FIDO 여부(인증서 사용 여부)
 @return Returns 'NSDictionary'. 'NSDictionary' is the generated request message for 'Registration'.
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForRegistration:(FidoOPType)operationType
                                                         userId:(NSString *_Nullable)userId
                                                        extData:(NSString *_Nullable)extData
                                                        isKFido:(FIDOWithCert)isKFido;

/**
 @discussion Generate requestMessage for 'Registration'.
        Registration시 필요한 RequestMessage 를 생성한다.
 @param operationType : 'FidoOPType' to be used if generate request message for 'FIDO auth'.
                                 오퍼레이션 타입
 @param userId        : 'userId' to be used if generate request message for 'FIDO auth'.
                             사용자 아이디
 @param extData       : Extra data to be included in 'requestMessage'. Default is empty strings. 'extData' is passed to the RPS.
 고객사에서 RPS로 전달할 임의 데이터
 @param isKFido     : Whether to use a certificate
                              K-FIDO 여부(인증서 사용 여부)
 @param serviceName : The name of service used when registering.
                               여러개의 서비스에서 따로따로 등록 할 경우 구분하기 위한 값
 @return The generated requestMessage for 'Registration'.
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForRegistration:(FidoOPType)operationType
                                                         userId:(NSString *_Nullable)userId
                                                        extData:(NSString *_Nullable)extData
                                                        isKFido:(FIDOWithCert)isKFido
                                                    serviceName:(NSString *_Nullable)serviceName;


/**
 @discussion Generate requestMessage for 'Authentication'.
        Authentication시 필요한 RequestMessage 를 생성한다.
 @param operationType : 'FidoOPType' to be used if generate request message for 'FIDO auth'.
                                오퍼레이션 타입
 @param userId        : 'userId' to be used if generate request message for 'FIDO auth'.
                            사용자 아이디
 @param tCContent     : 'tcContent' is a strings used in 'Transaction Confirmation'. If 'tCContent' exists, FIDO_OPERATION is 'Transaction Confirmation' and not 'Authentication'.
                            Transaction Content 데이터
 @param extData       : Extra data to be included in 'requestMessage'. Default is empty strings. 'extData' is passed to the RPS.
                            고객사에서 RPS로 전달할 임의 데이터
 @param error : Double pointer of error.
                         에러 객체 포인터
 @return The generated requestMessage for 'Authentication'.
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForAuthentication:(FidoOPType)operationType
                                                           userId:(NSString *_Nullable)userId
                                                        tCContent:(NSString *_Nullable)tCContent
                                                          extData:(NSString *_Nullable)extData
                                                            error:(NSError *_Nullable*_Nullable)error;

/**
 @discussion Generate requestMessage for 'Authentication'.
        Authentication시 필요한 RequestMessage 를 생성한다.
 @param operationType : 'FidoOPType' to be used if generate request message for 'FIDO auth'.
                             오퍼레이션 타입
 @param userId        : 'userId' to be used if generate request message for 'FIDO auth'.
                             사용자 아이디
 @param tCContent     : 'tCContent' to be used if generate request message for 'FIDO auth'. If 'tCContent' exists, FIDO_OPERATION is 'Transaction Confirmation' and not 'Authentication'.
                             Transaction Content 데이터
 @param extData       : Extra data to be included in 'requestMessage'. Default is empty strings. 'extData' is passed to the RPS.
                             고객사에서 RPS로 전달할 임의 데이터
 @param isKFido     : Whether to use a certificate
                             K-FIDO 여부(인증서 사용 여부)
 @param error : Double pointer of error.
                      에러 객체 포인터
 @return The generated requestMessage for 'Authentication'.
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForAuthentication:(FidoOPType)operationType
                                                           userId:(NSString *_Nullable)userId
                                                        tCContent:(NSString *_Nullable)tCContent
                                                          extData:(NSString *_Nullable)extData
                                                          isKFido:(FIDOWithCert)isKFido
                                                            error:(NSError *_Nullable*_Nullable)error;

/**
 @discussion Generate requestMessage for 'Authentication'.
        Authentication시 필요한 RequestMessage 를 생성한다.
 @param operationType : 'FidoOPType' to be used if generate request message for 'FIDO auth'.
                                오퍼레이션 타입
 @param userId        : 'userId' to be used if generate request message for 'FIDO auth'.
                            사용자 아이디
 @param tCContent     : 'tcContent' is a strings used in 'Transaction Confirmation'. If 'tCContent' exists, FIDO_OPERATION is 'Transaction Confirmation' and not 'Authentication'.
                            Transaction Content 데이터
 @param extData       : Extra data to be included in 'requestMessage'. Default is empty strings. 'extData' is passed to the RPS.
고객사에서 RPS로 전달할 임의 데이터
 @param isKFido     : Whether to use a certificate
                             K-FIDO 여부(인증서 사용 여부)
 @param serviceName : The name of service used when registering.
                          여러개의 서비스에서 따로따로 등록 할 경우 구분하기 위한 값
 @param error : Double pointer of error.
 @return The generated requestMessage for 'Authentication'.
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForAuthentication:(FidoOPType)operationType
                                                           userId:(NSString *_Nullable)userId
                                                        tCContent:(NSString *_Nullable)tCContent
                                                          extData:(NSString *_Nullable)extData
                                                          isKFido:(FIDOWithCert)isKFido
                                                      serviceName:(NSString *_Nullable)serviceName
                                                            error:(NSError *_Nullable*_Nullable)error;



/**
 @discussion Generate requestMessage for DeRegistration.
 DeRegistration시 필요한 RequestMessage 를 생성한다.

 @param operationType  :'FidoOPType' for the 'FIDO Operation'.
                             오퍼레이션 타입
 @param userId         : The ID used when registering.
                              사용자 아이디
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForDeregistration:(FidoOPType)operationType
                                                           userId:(NSString *_Nullable)userId;

/**
 @discussion Generate requestMessage for DeRegistration.
 DeRegistration시 필요한 RequestMessage 를 생성한다.

 @param operationType  :'FidoOPType' for the 'FIDO Operation'.
                             오퍼레이션 타입
 @param userId         : The ID used when registering.
                              사용자 아이디
 @param isKFido     : Whether to use a certificate
                              K-FIDO 여부(인증서 사용 여부)
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForDeregistration:(FidoOPType)operationType
                                                           userId:(NSString *_Nullable)userId
                                                          isKFido:(FIDOWithCert)isKFido;

/**
 @discussion Generate requestMessage for DeRegistration.
 DeRegistration시 필요한 RequestMessage 를 생성한다.

 @param operationType  : 'FidoOPType' used in the FIDO operation.
                              오퍼레이션 타입
 @param userId         : The ID used when registering.
                              사용자 아이디
 @param isKFido     : Whether to use a certificate
                              K-FIDO 여부(인증서 사용 여부)
 @param serviceName    : The name of service used when registering.
                              여러개의 서비스에서 따로따로 등록 할 경우 구분하기 위한 값
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)generateRequestMessageForDeregistration:(FidoOPType)operationType
                                                           userId:(NSString *_Nullable)userId
                                                          isKFido:(FIDOWithCert)isKFido
                                                      serviceName:(NSString *_Nullable)serviceName;

/**
 @discussion Parse the response that received by sending a request to the server.
        Trigger(Request요청, Response요청)중에서 Request를 서버로 요청 후 받은 RequestResult를 parsing한다.
 @param requestMessageResult   : The response that received by sending a request to the server.
                                              Request 결과 메세지
 @param operationType              : 'FidoOPType' used in the FIDO operation.
                                              오퍼레이션 타입
 @param aTarget                     : delegate target
 @param completeSelector           : 'completeSelector' to receive result of 'FIDO Operation'.
                                    Registration 결과를 리턴받을 SEL
 @param registeredTypeCheckSelector: 'registeredTypeCheckSelector' receives the certificate used when registering FIDO.
                                   Auth 및 TC시 Registration의 타입을 체크하여 인증서를 사용하여 Registration한 경우 인증서 확인창을 보여준다. 아닌 경우 인증 진행
 @param registrationTypeSelector   : 'registrationTypeSelector' receives biotype used during registration. (touchId, passcode, passign)
                                   Registration시 touchId, passcode, passign등 타입을 리턴하여 준다
 @param certIndex                  : Only use in Republic of Korea.
                                   reg시 FidoFrameWork을 이용하여 저장된 인증서를 사용할 경우 인증서의 인덱스를 넘겨준다
 @param cert                  : 'cert' is  binary of certificate(x.509). This is used on 'FIDO Registration'.
                                    reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서''
 @param privateKey            : 'privateKey' is binary. This is used on 'FIDO Registration'.
                                    reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서 privateKey
 @param pw                  : 'pw' is password of 'Certificate'
                                        reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서 비밀번호
 */
-(void)requestMessageResultParsing:(NSDictionary *_Nullable)requestMessageResult
                     operationType:(FidoOPType)operationType
                           aTarget:(id _Nullable )aTarget
                  completeSelector:(SEL _Nullable )completeSelector
            registeredTypeCheckSel:(SEL _Nullable)selBookedRegistrationTypeForAuth
               registrationTypeSel:(SEL _Nullable)selRegistrationTypeForReg
                         certIndex:(int)certIndex
                              cert:(NSData * _Nullable)cert
                        privateKey:(NSData * _Nullable)privateKey
                          password:(NSString * _Nullable)pw;

//**
// @discussion Operation시 필요한 ResponseMessage 를 생성한다.
// @param (int)bioType        : 바이오타입 e.g.USER_VERIFY_FINGERPRINT
// */
//-(NSDictionary *)generateResponseMessage:(int)bioType;


/**
 @discussion Parse the results received from the server. The result is a response to 'Reg Operation'.
 Registration ResponseMessage Result를 parsing 한다.

 @param responseMessageResult : 수신한 Registration ResponseMessage Result
 */
-(void)responseMessageResultParsingForRegistration:(NSDictionary *_Nullable)responseMessageResult;



/**
 @discussion Parse the results received from the server. The result is a response to 'Auth Operation'.
 Authentication ResponseMessage Result를 parsing 한다.
 @param responseMessageResult : 수신한 Authentication ResponseMessage Result
 */
-(void)responseMessageResultParsingForAuthentication:(NSDictionary *_Nullable)responseMessageResult;

/**
 @discussion TrustedFacets을 담아둔다.
 @param trustedFacets: RPS에서 수신한 trustedFacets(json data)
 */
-(void)putTrustedFacets:(NSDictionary *_Nullable)trustedFacets;

/**
 @discussion Registration Requset메세지를 RPS에서 생성하기 위한 param 생성
 @param userId 유저아이디
 @return 서버에서 생성한 Reg Req
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)getParamForRegistrationRequestCreateOnServer:(NSString *_Nullable)userId;

/**
 @discussion Authentication Requset메세지를 RPS에서 생성하기 위한 param 생성
 @param userId 유저아이디
 @return 서버에서 생성한 Auth Req
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)getParamForAuthenticationRequestCreateOnServer:(NSString *_Nullable)userId;

/**
 @discussion TransactionConfirmation Requset메세지를 RPS에서 생성하기 위한 param 생성
 @param userId 유저아이디
 @param tCContent     : Transaction Content 데이터
 @return 서버에서 생성한 TC Req
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)getParamForTransactionConfirmationRequestCreateOnServer:(NSString *_Nullable)userId
                                                                        tcContent:(NSString *_Nullable)tcContnet;

/**
 @discussion Deregistration Requset메세지를 RPS에서 생성하기 위한 param 생성
 @param userId 유저아이디
 @return 서버에서 생성한 Dereg Req
 */
-(NSDictionary <NSString *, NSString *>*_Nullable)getParamForDeregistrationRequestCreateOnServer:(NSString *_Nullable)userId;



#pragma mark -------------Sample - RPS간 통신 끝-------------
/**
 @discussion 인증서 가져오기에 성공한 인증서를 프레임워크 내부에 설정한다.
 @param certificate 인증서
 */
- (void) setCertificate:(USCertificate *_Nullable)certificate;

#pragma mark 인증서 이동 및 인증서 정보
/**
 @discussion 인증서 이동에 필요한 승인번호를 가져온다
 @param error : 에러 객체 포인터
 */
-(NSString *_Nullable)getGenerateNumber:(USError *_Nullable)error;

/**
 @discussion 인증서 사용자 정보
 */
-(NSString *_Nullable)getCertUserName;


/**
 @discussion 인증서 용도
 */
-(NSString *_Nullable)getCertPurpose;


/**
 @discussion 인증서 유효기간
 */
-(NSString *_Nullable)getCertExpirationDate;


/**
 @discussion 인증서 비밀번호 확인
 @param password  : 인증서 비밀번호
 @param aTarget           : delegate
 @param completeSelector : 결과를 리턴받을 SEL
 @param error : 에러 객체 포인터
 */
-(BOOL)checkPasswordOfCert:(NSString *_Nullable)password
                   aTarget:(id _Nullable )aTarget
          completeSelector:(SEL _Nullable )completeSelector
                     error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 인증서 목록을 불러온다
 */
-(NSArray <ViewCertificate *>*_Nullable)getViewCertificates;


/**
 @discussion 인증서 이동 중계서버와 연결
 @param importCertResultSelector   : 결과를 리턴받을 SEL
 @param aTarget                     : delegate

 */
-(void) isPCconnected:(SEL _Nullable )importCertResultSelector
              aTarget:(id _Nullable )aTarget;

/**
 @discussion 인증서 이동 중계서버와 연결 후 결과를 리턴한다.
 @param error : 에러 객체 포인터
 */
-(BOOL)transIsPCConnected:(USError *_Nullable)error;

/**
 @discussion 인증서 가져오기를 수행 한다. *transIsPCConnected가 YES일 경우 사용한다.
 @param error : 에러 객체 포인터
 */
-(USCertificate *_Nullable)transImportCert:(USError *_Nullable)error;

/**
 @discussion 등록된 인증서 삭제
 @param aTarget           : delegate
 @param completeSelector : 결과를 리턴받을 SEL
 @param certIndex        : 삭제할 DB 인덱스
 */
-(void)removalCert:(id _Nullable )aTarget
removalCertResultSelector:(SEL _Nullable )removalCertResultSelector
         certIndex:(int)certIndex;


#pragma mark Utility

/**
 @discussion 등록된 유저 전체 삭제
 */
-(void)deleteAllUser;

/**
 @discussion 등록된 유저 삭제
 @param userId      : 삭제할 UserId
 @param isKFido    : K-FIDO 여부(인증서 사용 여부)
 @param serviceName : 여러개의 서비스에서 따로따로 등록 할 경우 구분하기 위한 값
 */
-(void)deleteUserWithUserId:(NSString *_Nullable)userId
                    isKFido:(FIDOWithCert)isKFido
                serviceName:(NSString *_Nullable)serviceName;

/**
 @discussion Base64  Decoding
 @param string : Base64원문
 */
-(NSData *_Nullable)decBase64:(NSString *_Nullable)string;


/**
 @discussion FIDO 기능 사용 여부 체크
 @param policy Define된 policy를 xor하여 전달.
     사용가능 policy는 현재 다음과 같다.
     - USER_VERIFY_FINGERPRINT
     - USER_VERIFY_PASSCODE
 */
-(int)canEvaluateFidoPolicy:(int)policy;




/**
 @discussion It is extract available authentication means.
 @param requestMessageResult   : The response that received by sending a request to the server.

 @return Returns 'NSarray'. 'NSarray' is list of available authentication means.
 */
-(NSArray <NSString *>*_Nullable)getUserVerificationFromRequestResult:(NSDictionary *_Nullable)requestMessageResult;

/**
 @discussion Gets the registered certificate information.
 등록된(registration된) 인증서 정보를 가져온다.

 @param userId      : The ID used when registering.
 @param isKFido  : Whether to use a certificate
                           K-FIDO 여부(인증서 사용 여부)
 @param serviceName : The name of service used when registering.
                           여러개의 서비스에서 따로따로 등록 할 경우 구분하기 위한 값

 @return Returns `ViewCertificate`, `ViewCertificate`  is Certificate information Object.
 */
-(ViewCertificate *_Nullable)getCertificateInformationOfRegistered:(NSString *_Nullable)userId
                                                           isKFido:(FIDOWithCert)isKFido
                                                       serviceName:(NSString *_Nullable)serviceName;

/**
 @discussion TouchID 지원 가능 단말기 여부 판별
 */
-(BOOL)isAvailableTouchID;

/**
 @discussion TouchID 사용 가능 할 경우 등록 되어있는 지문이 있는지 확인
 */
-(BOOL)isTouchIDEnrolled;

/**
 @discussion Check if the device is an iPhone.
        단말기의 iPhone여부를 판별한다.
 @return Returns `true` if `Device` is iPhone.
 */
-(BOOL)isThisDeviceAniPhone;

/**
 @discussion Check the biometryType available on the device.
        단말기의 사용 가능한 BiometryType을 확인한다.
 @return
     BiometryNone : 0
     BiometryTypeTouchID : 1
     BiometryTypeFaceID : 2
 */
-(BiometryType)getBiometryType;


-(NSString *_Nullable)getVersion;

#pragma mark Sample - VOICE 관련
/**
 @discussion 바이오 인증시도 가능여부 확인 : 보이스인증의 경우 인증이 실패 하였을 경우 화면에서 델리게이트로 결과를 리턴 받기 때문에 FIDOFramework로 실패여부를 알려주어야 한다.
 @param isKFido    : K-FIDO 여부(인증서 사용 여부)
 */
-(BOOL)isAvailableBioVerificationForVoice:(FIDOWithCert)isKFido;


#pragma mark Sample - 핀코드 제어
/**
 @discussion 단말기내에 핀코드 등록여부 확인
 */
-(BOOL)isRegisteredPincodeToDevice;

/**
 @discussion 핀코드 등록
 @param pin :  등록할 PIN
 */
-(BOOL)insertPIN:(NSString *_Nullable)pin;

/**
 @discussion 입력된 핀코드와 저장된 핀코드를 비교한다.
 @param pin :  입력된 PIN
 */
-(BOOL)checkPincodeWithEnrolledPincode:(NSString *_Nullable)pincode;

/**
 @discussion 핀코드를 변경한다.
 @param pin :  변경할 PIN
 */
-(BOOL)changePincode:(NSString *_Nullable)pincode;

/**
 @discussion 핀코드를 삭제한다.
 */
-(BOOL)deletePincode;

/**
 @discussion 핀코드를 확인실패 횟수를 증가 시킨다.
 */
-(void)increasePasswordVerificationFailureCount;

/**
 @discussion 핀코드를 확인실패 횟수를 가져온다.
 */
-(int)getPasswordVerificationFailureCount;

/**
 @discussion 핀코드를 확인실패 횟수를 초기화 한다.
 */
-(void)resetPasswordVerificationFailureCount;

-(NSData *_Nullable)getVIDR;

-(void)deleteVIDR;

/**
 @discussion Registration 성공 시 FIDO PublicKey 추출 가능한 API
 @param userId        : 사용자 아이디
 @param isKFido     : Whether to use a certificate
                             K-FIDO 여부(인증서 사용 여부)
 @param serviceName : The name of service used when registering.
                              여러개의 서비스에서 따로따로 등록 할 경우 구분하기 위한 값
 @return 리턴 타입 : Bae64URL
 */
-(NSString *_Nullable)getFidoPublicKey:(NSString *_Nullable)userId
                      isKFido:(FIDOWithCert)isKFido
                  serviceName:(NSString *_Nullable)serviceName;

/**
 @discussion 인증용 이메일 파라미터 생성
 @param to : 이메일 주소
 @param randomCode : 랜덤코드
 @param contentType : 컨텐트 타입
 */
-(NSDictionary<NSString *, NSString *> *_Nullable)generateEmailParam:(NSString *_Nullable)to
                                     content:(NSString *_Nullable)randomCode
                                 contentType:(NSString *_Nullable)contentType;

#pragma mark Sample - 패턴 제어

/**
 @discussion 패턴 등록
 @param encPattern : 등록할 암호화된 페턴
 @return BOOL : 결과
 */
-(BOOL)insertPattern:(NSData *_Nullable)encPattern;

/**
 @discussion 단말기내에 패턴 등록여부 확인
 @return BOOL : 결과
 */
-(BOOL)isRegisteredPatternToDevice;

/**
 @discussion 입력된 패턴과 저장된 패턴를 비교한다.
 @param pattern : 입력된 페턴
 @return BOOL : 결과
 */
-(BOOL)comparePatternAndEnrolledPattern:(NSData *_Nullable)pattern;

/**
 @discussion 등록된 패턴 삭제
 @return BOOL : 결과
 */
-(BOOL)removePattern;

/**
 @discussion 패턴을 변경한다.
 @param pattern : 변결할 페턴
 @return BOOL : 결과
 */
-(BOOL)changePattern:(NSData *_Nullable)encPattern;

/**
 @discussion 패턴를 확인실패 횟수를 증가 시킨다.
 */
-(void)increasePatternVerificationFailureCount;

/**
 @discussion 패턴 확인실패 횟수를 초기화 한다.
 */
-(void)resetPatternVerificationFailureCount;

/**
 @discussion 패턴 확인실패 횟수를 가져온다.
 @return int : 결과
 */
-(int)getPatternVerificationFailureCount;

#pragma mark utility
/**
 @discussion 초기화된 Toolkit 객체 주소를 획득한다.
 @return USToolkit 객체 주소
 */
-(void)getUSToolkit:(USToolkitMgr *_Nullable*_Nullable)toolkit;

//-(void)deAllocation;

#pragma mark 보류 함수
/**
 @discussion Operation에 담겨 있는 TC Content를 가져온다.
 @return (NSString *) : 결과
 */
-(NSString *_Nullable)getTCContent;


@end
