//
//  USToolkitMgr.h
//  UniSignLibrary
//
//  Created by 근영 최 on 13. 6. 18..
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OBJCUSToolkit.h"
#import "USCertificate.h"

#define ERR_NO_CERTIFICATE                  10000
#define ERR_NO_SIGN_CERT                    10001
#define ERR_NO_SIGN_PRI_KEY                 10002
#define ERR_NO_SIGNED_DATA_VERIFY_FAILURE   10003
#define ERR_NO_PLAIN_DATA                   10004
#define ERR_NO_HASH_DATA                    10005
#define ERR_NO_PW                           10006
#define ERR_CHANGE_PASSWORD_FAILURE         10007
#define ERR_ADD_AUHENTICATION_MEANS_FAILURE 10008
#define ERR_NO_SIGNATURE                    10009
#define ERR_NO_VIDR                         10010
#define ERR_ENC_FAILURE                     10011
#define ERR_EXIST_CERTIFICATE               10012
#define ERR_WRONG_PASSWORD                  10013
#define ERR_NO_SIGN_PRI_KEY_FOR_PIN         10014
#define ERR_NO_SIGN_PRI_KEY_FOR_BIO         10015


@class LicenseCheck;

typedef enum AutenticationMeans {
    PIN = 0,
    BIO = 1
} AutenticationMeans;

typedef enum MoveCertTypeForV1 {
    IMPORT = 0,
    EXPORT = 1
} MoveCertTypeForV1;





@interface USToolkitMgr : OBJCUSToolkit

/*
 2017.06.08
 전자서명 사용시 업체 분기
 //전자서명 사용시 라온시큐어의 보안 키보드를 사용하여 암호화된 비밀번호를 파라미터로 사용
 */
typedef enum USCompanyType {
    RAON_SECURE = 0x01, //라온시큐어
    HANCOM_SECURE = 0x02, // 한컴시큐어
} USCompanyType;

+ (void) setLicense:(NSString *_Nullable)license;
+ (id _Nullable) getInstance:(USError *_Nullable*_Nullable)error;
+ (NSString *_Nullable) getApiInfo:(USError *_Nullable*_Nullable)error;

- (NSString *_Nullable) getVersion;

/**
 @brief Toolkit 메모리 해제
 */
- (void) deAllocation;


#pragma mark 라이선스 관련
/**
 @discussion  Library 라이선스 발급을 위한 정보를 가져온다.
 @return LicenseInfo 추출
 */
-(NSString *_Nullable)getLicenseInfo;



#pragma mark 인증서 발급
-(void)logicIssueCertFor3yearsOr1years:(NSString *_Nullable)refNumber
                              authCode:(NSString *_Nullable)authCode
                              password:(NSString *_Nullable)password
                                 error:(USError *_Nullable*_Nullable)error;

- (USCertificate *_Nullable) logicIssueCertWithIPandPort:(NSString *_Nullable)caIp
                                           port:(int)port
                                         refNum:(NSString *_Nullable)refNum
                                       authCode:(NSString *_Nullable)authCode
                                       password:(NSString *_Nullable)password
                                          error:(USError *_Nullable*_Nullable)error;

- (USCertificate *_Nullable) logicIssueCertWithIPandPortByNoConf:(NSString *_Nullable)caIp
                                                   port:(int)port
                                                 refNum:(NSString *_Nullable)refNum
                                               authCode:(NSString *_Nullable)authCode
                                               password:(NSString *_Nullable)password
                                                  error:(USError *_Nullable*_Nullable)error;

- (BOOL) logicIssueCertWithIPandPortBySendConf;

- (void) logicIssueCerClose;

- (void) logicIssueCertCloseForHSM;

- (USCertificate *_Nullable) logicIssueCertForClient:(NSString *_Nullable)refNum
                                   authCode:(NSString *_Nullable)authCode
                                   password:(NSString *_Nullable)password
                                     isTest:(BOOL)isTest
                                      error:(USError *_Nullable*_Nullable)error;

/**
 @brief 인증서 발급
 @param USCompanyType 업체코드
        refNum 참조번호
        authCode 인가코드
        password 한컴시큐어 보안 키보드 적용된 비밀번호
        ranKeyForPBKDF2
        isTest 테스트 인증서 발급 서버 사용 여부
        error 에러객체
 */
- (USCertificate *_Nullable) logicIssueCertForClientCompany:(USCompanyType) companyType
                                            refNum:(NSString *_Nullable)refNum
                                          authCode:(NSString *_Nullable)authCode
                                          password:(NSString *_Nullable)password
                                   ranKeyForPBKDF2:(NSString *_Nullable)ranKey
                                            isTest:(BOOL)isTest
                                             error:(USError *_Nullable*_Nullable)error;

- (USCertificate *_Nullable) logicIssueCert:(NSString *_Nullable)refNum
                                   authCode:(NSString *_Nullable)authCode
                                   password:(NSString *_Nullable)password error:(USError *_Nullable*_Nullable)error;

#pragma mark 인증서 발급 (외부에서 키쌍 생성)
/**
 @brief 인증서 발급 GenMGenP, 외부에서 키쌍 생성 용
 @param caIp CA ip
 @param port CA port
 @param refNum 참조번호
 @param authCode 인가코드
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 */
-(void)logicGenmGenpForIssueWithHSM:(NSString *_Nullable)caIp
                               port:(int)port
                          refNumber:(NSString *_Nullable)refNumber
                           authCode:(NSString *_Nullable)authCode
                              error:(USError *_Nullable*_Nullable)error;

/**
@brief 인증서 발급 POP sign, 외부에서 키쌍 생성 용
*/
-(NSData *_Nullable)logicMakePOPOTbsMsg:(NSData *_Nullable)pubkey
                         error:(USError *_Nullable*_Nullable)error;

/**
@brief 인증서 발급 irip, 외부에서 키쌍 생성 용
*/
-(NSDictionary *_Nullable)logicIssueIrIp:(NSData *_Nullable)pubkey
                   popSignValue:(NSData *_Nullable)popSignValue
                          error:(USError *_Nullable*_Nullable)error;
/**
@brief 인증서 발급 confirm, 외부에서 키쌍 생성 용
*/
-(void)logicIssueResult;


#pragma mark 전자 인증서 발급 with Whitebox (쿤택)

/**
 @discussion 한국전자인증 전자 인증서 발급 (화이트 박스 이용)
 @param
 @param serverIP        : 인증서 발급서버 IP
 @param port            : 인증서 발급서버 포트
 @param refNumber       : 참조번호
 @param authCode        : 인가코드
 @param pw              : 비밀번호
 @param means           : 인증수단
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 인증서 발급 결과 YES : 성공, NO : 실패
 */

-(bool)issueElectronicCertificateUseWhiteBox:(NSString *_Nullable)serverIP
                                        port:(int)port
                                   refNumber:(NSString *_Nullable)refNumber
                                    authCode:(NSString *_Nullable)authCode
                                    password:(NSData *_Nullable)pw
                                       means:(AutenticationMeans)means
                                       error:(USError *_Nullable*_Nullable)error;

#pragma mark 전자 인증서 발급 with Whitebox (mSafeBox)
///**
//@discussion 전자인증서 발급 완료 처리
// */
//-(void)issueResultWithHSM;
//
///**
//@discussion 인증서 발급 IR/IP, 외부에서 키쌍 생성 용
//@param pubkey 공개키
//@param popSignValue HSM에서 생성된 popSignValue
//@param error 에러객체
//*/
//
//-(NSDictionary *_Nullable)irIpForIssueWithHSM:(NSData *_Nullable)pubkey
//                                 popSignValue:(NSData *_Nullable)popSignValue
//                                        error:(USError *_Nullable*_Nullable)error;
//
///**
// @discussion 인증서 발급 GenMGenP, 외부에서 키쌍 생성 용
// @param caIp CA ip
// @param port CA port
// @param refNum 참조번호
// @param authCode 인가코드
// @param error 에러객체
// */
//-(BOOL)genmGenpForIssueWithHSM:(NSString *_Nullable)caIp
//                          port:(int)port
//                     refNumber:(NSString *_Nullable)refNumber
//                      authCode:(NSString *_Nullable)authCode
//                         error:(USError *_Nullable*_Nullable)error;
//
//
///**
//@discussion POP 원문 데이터 생성, 외부에서 키쌍 생성 용
//@param pubkey 공개키
//@param error 에러객체
//*/
//-(NSData *_Nullable)makePOPOTbsMsgWithHSM:(NSData *_Nullable)pubkey
//                                    error:(USError *_Nullable*_Nullable)error;
//
///**
//@discussion 인증서 발급 실패 시 서버와 강제 연걀 해제, 외부에서 키쌍 생성 용
//*/
//- (void) issueCertCloseForHSM;



#pragma mark 인증서 갱신
- (USCertificate *_Nullable) logicRenewCert:(USCertificate *_Nullable)cert password:(NSString *_Nullable)password error:(USError *_Nullable*_Nullable)error;

/**
 @brief 인증서 갱신
 @param USCompanyType 업체코드
        cert 인증서
        encPW 한컴시큐어 보안 키보드 적용된 비밀번호
        ranKeyForPBKDF2 랜덤키
        isTest 테스트 인증서 발급 서버 사용 여부
        error 에러객체
 */
- (USCertificate *_Nullable) logicRenewCertForClientCompany:(USCompanyType) companyType
                                                       cert:(USCertificate *_Nullable)cert
                                                      encPW:(NSString *_Nullable)encPw
                                            ranKeyForPBKDF2:(NSString *_Nullable)ranKey
                                                     isTest:(BOOL)isTest
                                                      error:(USError *_Nullable*_Nullable)error;

#pragma mark 인증서 폐지
- (BOOL) logicRevokeCert:(USCertificate *_Nullable)cert
                password:(NSString *_Nullable)password
                   error:(USError *_Nullable*_Nullable)error;

/**
 @brief 인증서 폐지

 @param USCompanyType 업체코드
        encPW 한컴시큐어 보안 키보드 적용된 비밀번호
        ranKeyForPBKDF2 랜덤키
        cert 인증서
        isTest 테스트 인증서 발급 서버 사용 여부
        error 에러객체
 */
- (BOOL) logicRevokeCertForClientCompany:(USCompanyType) companyType
                                   encPW:(NSString *_Nullable)encPw
                         ranKeyForPBKDF2:(NSString *_Nullable)ranKey
                                    cert:(USCertificate *_Nullable)cert
                                  isTest:(BOOL)isTest
                                   error:(USError *_Nullable*_Nullable)error;


#pragma mark  인증서 개인키 복호화
- (NSData *_Nullable) certDecryptPriKey:(NSString *_Nullable)password
                              encPrikey:(NSData *_Nullable)encPrikey
                                  error:(USError *_Nullable*_Nullable)error;


#pragma mark  인증서 관리

/**
@brief 인증서 비밀번호 변경
*/
- (NSData *_Nullable) certChangePrikeyPassword:(NSString *_Nullable)oldPassword
                                   newPassword:(NSString *_Nullable)newPassword
                                     encPrikey:(NSData *_Nullable)encPrikey
                                         error:(USError *_Nullable*_Nullable)error;

- (BOOL) logicVerifyCert:(USCertificate *_Nullable)cert
                   error:(USError *_Nullable*_Nullable)error;


- (BOOL) isCorrectCert:(USCertificate *_Nullable)cert
              password:(NSString *_Nullable)password
                 error:(USError *_Nullable*_Nullable)error;


/**
@discussion 공인인증서 리스트 불러오기
@return 인증서 리스트 (USCertificate)
*/
- (NSArray * _Nullable) getCertificates;



/**
@discussion 공인인증서 삭제
@param cert : 삭제할 인증서
*/
- (BOOL) removeCertificate:(USCertificate *_Nullable)cert;


/**
@discussion 공인인증서 비밀번호 변경
@param cert : 삭제할 인증서
*/
- (USCertificate *_Nullable) logicChangeCert:(USCertificate *_Nullable)cert
                             currentPassword:(NSString *_Nullable)password
                                 newPassword:(NSString *_Nullable)newPassword
                                       error:(USError *_Nullable*_Nullable)error;


/**
 @discussion 공인인증서 비밀번호 확인
 @param cert : 공인인증서
 @param password : 비밀번호
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 */
-(BOOL)isCorrectPasswordOfCertificate:(USCertificate *_Nullable)cert
                             password:(NSString *_Nullable)password
                                error:(USError *_Nullable*_Nullable)error;


#pragma mark  인증서 이동 v1

/**
 @discussion 인증서 이동에 필요한 승인번호를 가져온다 V1
 @param moveCertTypeForV1 : 인증서 이동 타입
 @param failure  : 인증서 내보내기 실패 블럭 객체
 @param succeed  : 인증서 내보내기 성공 블럭 객체
 */
- (void)generateApprovalNumberForV1:(MoveCertTypeForV1)moveCertTypeForV1
                            succeed:(void (^_Nullable)(NSString* _Nonnull approvalNumber))succeed
                            failure:(void(^_Nonnull)(USError *_Nullable error))failure;


/**
 @discussion 인증서 이동 중계서버와 연결 V1
 @param failure  : 인증서 내보내기 실패 블럭 객체
 @param succeed  : 인증서 내보내기 성공 블럭 객체
 */

-(void) isPCconnectedForV1:(void (^_Nullable)(void))succeed
                   failure:(void(^_Nonnull)(USError *_Nullable error))failure;


/**
@discussion 인증서 가져오기 V1
@param succeed  : 인증서 가져오기 성공 블럭 객체
@param failure  : 인증서 가져오기 실패 블럭 객체
*/
-(void) importCertificateForV1:(void (^_Nullable)(void))succeed
                       failure:(void(^_Nonnull)(USError *_Nullable error))failure;

/**
@discussion 인증서 내보내기 V1
 @param succeed  : 인증서 내보내기 성공 블럭 객체
 @param failure  : 인증서 내보내기 실패 블럭 객체
*/
-(void) exportCertificateForV1:(USCertificate *_Nonnull)cert
                       succeed:(void (^_Nullable)(void))succeed
                       failure:(void(^_Nonnull)(USError *_Nullable error))failure;

-(void) terminateTransV1;


#pragma mark  인증서 이동 v2

/**
@discussion 공인인증서 가져오기
@param
firstApprovalNumber     : 승인번호 OOOO-****-*****
secondAApprovalNumber   : 승인번호 ****-OOOO-*****
thirdAApprovalNumber    : 승인번호 ****-****-OOOOO
completionBlock         : 인증서 가져오기 완료 블럭 객체
*/
//- (void)importCertificate:(NSString *_Nullable)firstApprovalNumber
//    secondAApprovalNumber:(NSString *_Nullable)secondAApprovalNumber
//     thirdAApprovalNumber:(NSString *_Nullable)thirdAApprovalNumber
//          completionBlock:(ImportCertCompletionBlock _Nullable)completionBlock;


/**
@discussion 공인인증서 가져오기 V2
@param firstApprovalNumber     : 승인번호 OOOO-****-*****
@param secondAApprovalNumber   : 승인번호 ****-OOOO-*****
@param thirdAApprovalNumber    : 승인번호 ****-****-OOOOO
@param succeed         : 인증서 가져오기 성공 블럭 객체
@param failure         : 인증서 가져오기 실패 블럭 객체
*/
- (void)importCertificate:(NSString *_Nullable)firstApprovalNumber
     secondApprovalNumber:(NSString *_Nullable)secondAApprovalNumber
      thirdApprovalNumber:(NSString *_Nullable)thirdAApprovalNumber
                  succeed:(void (^_Nullable)(NSString* _Nonnull message))succeed
                  failure:(void(^_Nonnull)(USError *_Nullable error))failure;


/**
@discussion 공인인증서 내보내기 승인번로 생성 V2
@param cert : 내보내야할 인증서
@param password : 내보내야할 인증서 비밀번호
@param succeed  : 승인번호 수신 블럭
@param failure  : 승인번호 생성 실패 블럭 객체
*/
- (void)generateApprovalNumber:(USCertificate *_Nonnull)cert
                      password:(NSString *_Nonnull)password
                       succeed:(void (^_Nullable)(NSString* _Nonnull approvalNumber))succeed
                       failure:(void(^_Nonnull)(USError *_Nullable error))failure;




/**
@discussion 공인인증서 내보내기 수신자 접속 대기 V2
@param failure  : 인증서 내보내기 실패 블럭 객체
@param succeed  : 인증서 내보내기 성공 블럭 객체
*/

- (void)waitingForRecipintAccess:(void (^_Nullable)(NSDictionary * _Nonnull succeed))succeed
                         failure:(void(^_Nonnull)(USError *_Nullable error))failure;

/**
@discussion 공인인증서 내보내기 V2
@param cert     : 인증서 객체
@param password : 인증서 비밀번호
@param failure  : 인증서 내보내기 실패 블럭 객체
@param succeed  : 인증서 내보내기 성공 블럭 객체
*/
- (void)exportCertificate:(USCertificate *_Nonnull)cert
                  succeed:(void (^_Nullable)(NSString* _Nonnull succeed))succeed
                  failure:(void(^_Nonnull)(USError *_Nullable error))failure;

/**
@discussion 공인인증서 내보내기 시간이 완료 되었을때 강제 종료  V2
*/
-(void)terminateExportCert;


#pragma mark  HASH
- (NSData *_Nullable) cryptGenerateHashSHA256:(NSData *_Nullable)data
                                        error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) cryptGenerateMacSHA256:(NSData *_Nullable)data
                                         key:(NSData *_Nullable)key
                                       error:(USError *_Nullable*_Nullable)error;



#pragma mark  VID
/**
 @brief 개인키 R값 추출
 */
- (NSData *_Nullable) logicVIDR:(USCertificate *_Nullable)cert
                      passworkd:(NSString *_Nullable)password
                          error:(USError *_Nullable*_Nullable)error;


- (BOOL) logicVerifySSN:(USCertificate *_Nullable)cert password:(NSString *_Nullable)password ssn:(NSString *_Nullable)ssn error:(USError *_Nullable*_Nullable)error;

/**
 @brief 개인키 R값 추출
 */
- (NSData *_Nullable) certGetVIDRandomWithPrikey:(NSString *_Nullable)password encPrikey:(NSData *_Nullable)encPrikey error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) certGetVIDRandomWithPrikeyByClientCompany:(USCompanyType)companyType
                                                       password:(NSString *_Nullable)password
                                                ranKeyForPBKDF2:(NSString *_Nullable)ranKey
                                                      encPrikey:(NSData *_Nullable)encPrikey
                                                          error:(USError *_Nullable*_Nullable)error;


#pragma mark  대칭키 생성
-(NSData *_Nullable) generateSymmetricKey:(USError *_Nullable*_Nullable)error;

#pragma mark  대칭키 암/복호화 AES
- (NSData *_Nullable) cryptAES128CBC:(NSData *_Nullable)data
                                 key:(NSData *_Nullable)key
                                  iv:(NSData *_Nullable)iv
                               error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) decryptAES128CBC:(NSData *_Nullable)data
                                   key:(NSData *_Nullable)key
                                    iv:(NSData *_Nullable)iv
                                 error:(USError *_Nullable*_Nullable)error;

#pragma mark  대칭키 암/복호화 SEED

- (NSData *_Nullable) cryptSeed:(NSData *_Nullable)data
                            key:(NSData *_Nullable)key
                             iv:(NSData *_Nullable)iv
                          error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) decryptSeed:(NSData *_Nullable)data
                              key:(NSData *_Nullable)key
                               iv:(NSData *_Nullable)iv
                            error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) decryptSeed:(NSData *_Nullable)data
                              key:(NSData *_Nullable)key
                               iv:(NSData *_Nullable)iv
                      paddingType:(int)paddingType
                            error:(USError *_Nullable*_Nullable)error;


#pragma mark  비대칭키 암/복호화 RSA

- (NSData *_Nullable) cryptRSA:(NSInteger)alg
                        pubkey:(NSData *_Nullable)pubkey
                          data:(NSData *_Nullable)data
                         error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) cryptRSA:(NSInteger)keyAlg
                        encAlg:(NSInteger)encAlg
                        pubkey:(NSData *_Nullable)pubkey
                        prikey:(NSData *_Nullable)prikey
                          data:(NSData *_Nullable)data
                         error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) cryptRSA:(NSData *_Nullable)serverCert
                          data:(NSData *_Nullable)data
                         error:(USError *_Nullable*_Nullable)error;


#pragma mark  암복화 모듈
- (NSData *_Nullable) cryptoGenerateRandom:(NSInteger)randomSize
                                     error:(USError *_Nullable*_Nullable)error;

- (NSDictionary *_Nullable) generateKeyPair:(USError *_Nullable*_Nullable)error;




#pragma mark - 전자서명 (PKCS#7)

- (NSData *_Nullable) logicCMSSignedData:(USCertificate *_Nullable)cert
                                    data:(NSData *_Nullable)data
                                password:(NSString *_Nullable)password
                                   error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicSignedData:(USCertificate *_Nullable)cert
                                 data:(NSData *_Nullable)data
                             password:(NSString *_Nullable)password
                                error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicSignedData:(NSData *_Nullable)signCert
                           signPrikey:(NSData *_Nullable)signPrikey
                                 data:(NSData *_Nullable)data
                             password:(NSString *_Nullable)password
                                error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicDetachedSignedDataWithHash:(NSData *_Nullable)signCert
                                           signPrikey:(NSData *_Nullable)signPrikey
                                                 data:(NSData *_Nullable)data
                                             password:(NSString *_Nullable)password
                                                error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicSignedDataWithClientCompany:(USCompanyType) companyType
                                                  cert:(USCertificate *_Nullable)cert
                                                  data:(NSData *_Nullable)data
                                              password:(NSString *_Nullable)password
                                       ranKeyForPBKDF2:(NSString *_Nullable)ranKey
                                                 error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicSignedDataNoContnetWithHash:(USCertificate *_Nullable)cert
                                              password:(NSString *_Nullable)password
                                              hashData:(NSData *_Nullable)hashData
                                               hashAlg:(NSInteger)hashAlg
                                                 error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicSignedDataNoContnetWithHash:(NSData *_Nullable)signCert
                                            signPrikey:(NSData *_Nullable)signPrikey
                                              password:(NSString *_Nullable)password
                                              hashData:(NSData *_Nullable)hashData
                                               hashAlg:(NSInteger)hashAlg
                                                 error:(USError *_Nullable*_Nullable)error;


/**
@discussion 전자서명 (PKCS#7)
@param signCert certificate
@param signature HSM에서 생성된 signature
@param inputData PlainText
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터
*/
- (NSData *_Nullable) logicSignedDataWithSignature:(NSData *_Nullable)signCert
                                         signature:(NSData *_Nullable)signature
                                         inputData:(NSData *_Nullable)inputData
                                             error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicGenSignatureValueWithDigest:(USCertificate *_Nullable)cert
                                              password:(NSString *_Nullable)password
                                              hashData:(NSData *_Nullable)hashData
                                               hashAlg:(NSInteger)hashAlg
                                                 error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicSignature:(USCertificate *_Nullable)cert
                            password:(NSString *_Nullable)password
                                data:(NSData *_Nullable)data
                               error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicSignature:(USCertificate *_Nullable)cert
                            password:(NSString *_Nullable)password
                                data:(NSData *_Nullable)data
                           algorithm:(NSInteger)alg
                               error:(USError *_Nullable*_Nullable)error;

- (NSData *_Nullable) logicSignature:(USCertificate *_Nullable)cert
                  unEncryptionPrikey:(NSData *_Nullable)unEncryptionPrikey
                                data:(NSData *_Nullable)data
                               error:(USError *_Nullable*_Nullable)error;

/**
 @brief 전자서명 검증
 */
- (NSData *_Nullable) logicVerifySignedData:(NSData *_Nullable)signedData
                                      error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 전자서명 (PKCS#7)
 @param cert certificate
 @param data PlainText
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자서명 데이터
 */
- (NSData *_Nullable) logicSignedDataWithCert:(USCertificate *_Nullable)cert
                                         data:(NSData *_Nullable)data
                                     password:(NSString *_Nullable)password
                                        error:(USError *_Nullable*_Nullable)error;

#pragma mark 전자 인증서 관련 (Lv0, Lv1)

/**
 @discussion 전자서명 (PKCS#7) : 전자 인증서 사용
 @param data    : PlainText
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자서명 데이터
 */
- (NSData *_Nullable) logicSignedData:(NSData *_Nullable)data
                                error:(USError *_Nullable*_Nullable)error;


/**
 @discussion 전자서명 (PKCS#7) : 전자 인증서 사용
 @param data      : PlainText
 @param password  : 비밀번호
 @param means     : 인증수단
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자서명 데이터
 */
- (NSData *_Nullable) logicSignedData:(NSData *_Nullable)data
                             password:(NSData *_Nullable)pw
                                means:(AutenticationMeans)means
                                error:(USError *_Nullable*_Nullable)error;


/**
 @discussion 전자서명 + R(PKCS#7)
 @param data      : PlainText
 @param password  : 비밀번호
 @param means     : 인증수단
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자서명 데이터 + R
 */
- (NSDictionary *_Nullable) logicSignedDataWithVIDR:(NSData *_Nullable)data
                                           password:(NSData *_Nullable)pw
                                              means:(AutenticationMeans)means
                                              error:(USError *_Nullable*_Nullable)error;

/**
@discussion 전자서명 (PKCS#7+Attribute) With Hash
@param hashData  : Sha2 hashData
@param password  : 비밀번호
@param means     : 인증수단
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터
*/
- (NSData *_Nullable) logicDetachedSignedDataWithHash:(NSData *_Nullable)hashData
                                             password:(NSData *_Nullable)pw
                                                means:(AutenticationMeans)means
                                                error:(USError *_Nullable*_Nullable)error;

/**
@discussion 전자서명 + R (PKCS#7+Attribute) With Hash
@param hashData  : Sha2 hashData
@param password  : 비밀번호
@param means     : 인증수단
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터 + R
*/
- (NSDictionary *_Nullable) logicDetachedSignedDataAndVIDRWithHash:(NSData *_Nullable)hashData
                                                          password:(NSData *_Nullable)pw
                                                             means:(AutenticationMeans)means
                                                             error:(USError *_Nullable*_Nullable)error;

/**
@discussion 전자서명 (PKCS#7+Attribute)
@param plainData : 전자서명 원문
@param password  : 비밀번호
@param means     : 인증수단
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터
*/
- (NSData *_Nullable) logicSignedDataWithSign:(NSData *_Nullable)plainData
                                     password:(NSData *_Nullable)pw
                                        means:(AutenticationMeans)means
                                        error:(USError *_Nullable*_Nullable)error;

/**
@discussion 전자서명 + R (PKCS#7+Attribute)
@param plainData : 전자서명 원문
@param password  : 비밀번호
@param means     : 인증수단
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터 + R
*/
- (NSDictionary *_Nullable) logicSignedDataWithSignAndVIDR:(NSData *_Nullable)plainData
                                                  password:(NSData *_Nullable)pw
                                                     means:(AutenticationMeans)means
                                                     error:(USError *_Nullable*_Nullable)error;


/**
 @discussion 전자서명 (PKCS#7) no content type
 @param hashData : h(plainText)
 @param hashAlg  : 알고리즘
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자서명 데이터
 */
- (NSData *_Nullable) logicSignedDataNoContnetWithHash:(NSData *_Nullable)hashData
                                               hashAlg:(NSInteger)hashAlg
                                                 error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 전자서명 (PKCS#7) no content type
 @param hashData : 원문에 대한 해쉬 값. h(plainText)
 @param hashAlg : hashAlg 알고리즘
 @param password : 인증서 발급시 사용한 비밀번호
 @param means : 인증서 발급시 사용한 인증 수단
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자서명 데이터
 */
- (NSData *_Nullable) logicSignedDataNoContnetWithHash:(NSData *_Nullable)hashData
                                               hashAlg:(NSInteger)hashAlg
                                              password:(NSData *_Nullable)pw
                                                 means:(AutenticationMeans)means
                                                 error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 전자서명 (PKCS#7) + R :  no content type
 @param hashData : 원문에 대한 해쉬 값. h(plainText)
 @param hashAlg : hashAlg 알고리즘
 @param password : 인증서 발급시 사용한 비밀번호
 @param means : 인증서 발급시 사용한 인증 수단
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자서명 데이터
 */
- (NSDictionary *_Nullable) logicSignedDataAndVIDRNoContnetWithHash:(NSData *_Nullable)hashData
                                                            hashAlg:(NSInteger)hashAlg
                                                           password:(NSData *_Nullable)pw
                                                              means:(AutenticationMeans)means
                                                              error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 한국전자인증 전자 인증서 발급
 @param serverIP  : 인증서 발급서버 IP
 @param port      : 인증서 발급서버 포트
 @param refNumber : 참조번호
 @param authCode  : 인가코드
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 인증서 발급 결과 YES : 성공, NO : 실패
 */
-(bool)issueManagementCertificate:(NSString *_Nullable)serverIP
                             port:(int)port
                        refNumber:(NSString *_Nullable)refNumber
                         authCode:(NSString *_Nullable)authCode
                            error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 한국전자인증 전자 인증서 발급
 @param
 @param serverIP        : 인증서 발급서버 IP
 @param port            : 인증서 발급서버 포트
 @param refNumber       : 참조번호
 @param authCode        : 인가코드
 @param pw              : 비밀번호
 @param means           : 인증수단
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 인증서 발급 결과 YES : 성공, NO : 실패
 */
-(bool)issueManagementCertificate:(NSString *_Nullable)serverIP
                             port:(int)port
                        refNumber:(NSString *_Nullable)refNumber
                         authCode:(NSString *_Nullable)authCode
                         password:(NSData *_Nullable)pw
                            means:(AutenticationMeans)means
                            error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 인증 수단 추가
 @param previousMeans  : 기존 인증 수단
 @param previousPassword         : 기존 인증수단 비밀번호
 @param newMeans       : 신규 인증 수단
 @param newPassword              : 신규 인증 수단 비밀번호
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 인증 수단 추가 결과 YES : 성공, NO : 실패
 */
-(bool)addAuthenticationMeans:(AutenticationMeans)previousMeans
             previousPassword:(NSData *_Nullable)previousPassword
                     newMeans:(AutenticationMeans)newMeans
                  newPassword:(NSData *_Nullable)newPassword
                        error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 전자 인증서 비밀번호 변경
 @param means      : 인증서 발급시 사용한 인증 수단
 @param previousPassword     : 기존 비밀번호
 @param newPassword          : 신규 인증 수단 비밀번호
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 비밀 번호 변경 결과 YES : 성공, NO : 실패

 20200305 : 공인인증서 함수 추가로 구분을 위해 함수명 변경
 -(bool)changePassword:(AutenticationMeans)means
      previousPassword:(NSData *_Nullable)previousPassword
           newPassword:(NSData *_Nullable)newPassword
                 error:(USError *_Nullable*_Nullable)error;
 */
-(bool)managementCertChangePassword:(AutenticationMeans)means
                   previousPassword:(NSData *_Nullable)previousPassword
                        newPassword:(NSData *_Nullable)newPassword
                              error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 전자 인증서 발급 여부 확인
 @return 인증서 유무 확인 YES, NO
 */
-(bool)isExistManagementCert;

/**
 @discussion 전자 인증서 발급 여부 확인
 @param means : 인증수단
 @return 인증서 유무 확인 YES, NO
 */
-(bool)isExistManagementCertWithPW:(AutenticationMeans)means;

/**
 @discussion 발급된 전자 인증서 삭제
 */
-(void)removeManagementCertificate;

/**
 @discussion 발급된 전자 인증서 삭제(패스워드를 사용하여 발급된 인증서)
 */
-(void)removeManagementCertificateWithPW;

/**
 @discussion 발급된 전자 인증서 삭제(패스워드를 사용하여 발급된 인증서)
 @param means :  사용한 인증수단
 */
-(void)removeManagementCertificateWithPW:(AutenticationMeans)means;


/**
 @discussion 전자 인증서 발급 여부 확인
 */
-(bool)isIssueCertificateForDevice;

/**
 @discussion 전자 인증서 추출(pem 형식)
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴

 20200305 : 공인인증서 함수 추가로 구분을 위해 함수명 변경
 -(NSString *_Nullable)getCertificateByPem:(USError *_Nullable*_Nullable)error;
 */
-(NSString *_Nullable)getManagementCertificateByPem:(USError *_Nullable*_Nullable)error;

/**
 @discussion 전자 인증서 추출(pem 형식) (패스워드를 사용하여 발급된 인증서)
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return PEM 형식의 전자 인증서
 20200305 : 공인인증서 함수 추가로 구분을 위해 함수명 변경
 -(NSString *_Nullable)getCertificateByPemWithPW:(USError *_Nullable*_Nullable)error;
 */
-(NSString *_Nullable)getManagementCertificateByPemWithPW:(USError *_Nullable*_Nullable)error;

/**
 @discussion 발급된 전자 인증서 유효기간 종료일 조회 (패스워드를 사용하여 발급된 인증서)
 @return 전자 인증서 유효기간 종료일
 20200305 : 공인인증서 함수 추가로 구분을 위해 함수명 변경
 -(NSString *_Nullable)getCertificateExpirationDateWithPW:(AutenticationMeans)means;
 */
-(NSString *_Nullable)getManagementCertificateExpirationDateWithPW:(AutenticationMeans)means;


#pragma mark 전자 인증서 관련 (Lv2) : 화이트박스 이용한 인증서 발급
/**
 @discussion 화이트박스솔루션을 이용하여 발급한 전자 인증서 삭제
 */
-(void)removeElectronicCertificateUseWhiteBox;

/**
 @discussion Lv2 전자 인증서 발급 여부 확인
 @return 인증서 유무 확인 YES, NO
 */
-(bool)isExistElectronicCertificate:(AutenticationMeans)means;

/**
@discussion Lv2 전자 인증서 추출(pem 형식)
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
*/
-(NSString *_Nullable)getElectronicCertificateByPem:(USError *_Nullable*_Nullable)error;

/**
@discussion Lv2 인증 수단 추가
@param previousMeans        : 기존 인증 수단
@param previousPassword     : 기존 인증수단 비밀번호
@param newMeans             : 신규 인증 수단
@param newPassword          : 신규 인증 수단 비밀번호
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 인증 수단 추가 결과 YES : 성공, NO : 실패
*/
-(bool)addAuthenticationMeansToElectronicCertificate:(AutenticationMeans)previousMeans
                                    previousPassword:(NSData *_Nullable)previousPassword
                                            newMeans:(AutenticationMeans)newMeans
                                         newPassword:(NSData *_Nullable)newPassword
                                               error:(USError *_Nullable*_Nullable)error;


/**
@discussion 전자서명 (PKCS#7) : Lv2 전자 인증서 사용
@param data      : PlainText
@param password  : 비밀번호
@param means     : 인증수단
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터
*/
- (NSData *_Nullable) logicSignedDataUsingElectronicCert:(NSData *_Nullable)data
                                                password:(NSData *_Nullable)password
                                                   means:(AutenticationMeans)means
                                                   error:(USError *_Nullable*_Nullable)error;

/**
@discussion 전자서명 (PKCS#7) + VIDR : Lv2 전자 인증서 사용
@param data      : PlainText
@param password  : 비밀번호
@param means     : 인증수단
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터
*/
- (NSDictionary *_Nullable) logicSignedDataAndVIDRUsingElectronicCert:(NSData *_Nullable)data
                                                             password:(NSData *_Nullable)password
                                                                means:(AutenticationMeans)means
                                                                error:(USError *_Nullable*_Nullable)error;

/**
@discussion 전자서명 (PKCS#7+Attribute) : Lv2 전자 인증서 사용
@param hashData  : Sha2 hashData
@param password  : 비밀번호
@param means     : 인증수단
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터
*/
- (NSData *_Nullable) logicDetachedSignedDataWithHashUsingElectronicCert:(NSData *_Nullable)hashData
                                                                password:(NSData *_Nullable)password
                                                                   means:(AutenticationMeans)means
                                                                   error:(USError *_Nullable*_Nullable)error;

/**
@discussion 전자서명 + R (PKCS#7+Attribute) : Lv2 전자 인증서 사용
@param hashData  : Sha2 hashData
@param password  : 비밀번호
@param means     : 인증수단
@param error :  에러 객체 포인터, 실패시 에러 코드 리턴
@return 전자서명 데이터
*/
- (NSDictionary *_Nullable) logicDetachedSignedDataAndVIDRWithHashUsingElectronicCert:(NSData *_Nullable)hashData
                                                                             password:(NSData *_Nullable)password
                                                                                means:(AutenticationMeans)means
                                                                                error:(USError *_Nullable*_Nullable)error;

/**
 @discussion 전자서명 (PKCS#7) no content type : Lv2 전자 인증서 사용
 @param hashData h(plainText)
 @param hashAlg 알고리즘
 @param password 비밀번호
 @param means 인증수단
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자서명 데이터
 */
- (NSData *_Nullable) logicSignedDataNoContnetWithHashUsingElectronicCert:(NSData *_Nullable)hashData
                                                                  hashAlg:(NSInteger)hashAlg
                                                                 password:(NSData *_Nullable)password
                                                                    means:(AutenticationMeans)means
                                                                    error:(USError *_Nullable*_Nullable)error;

- (NSDictionary *_Nullable) logicSignedDataAndVIDRNoContnetWithHashUsingElectronicCert:(NSData *_Nullable)hashData
                                                                               hashAlg:(NSInteger)hashAlg
                                                                              password:(NSData *_Nullable)password
                                                                                 means:(AutenticationMeans)means
                                                                                 error:(USError *_Nullable*_Nullable)error;

/**
 @discussion Lv2 발급된 전자 인증서 유효기간 종료일 조회 (패스워드를 사용하여 발급된 인증서)
 @param means 인증수단
 @param error :  에러 객체 포인터, 실패시 에러 코드 리턴
 @return 전자 인증서 유효기간 종료일
 */
-(NSString *_Nullable)getElectronicCertExpirationDate:(AutenticationMeans)means
                                                error:(USError *_Nullable*_Nullable)error;

#pragma mark 보안 키보드 확인
- (BOOL) isCorrectCertForClientCompany:(USCompanyType)companyType
                                  cert:(USCertificate *_Nullable)cert
                              password:(NSString *_Nullable)password
                       ranKeyForPBKDF2:(NSString *_Nullable)ranKey
                                 error:(USError *_Nullable*_Nullable)error;

#pragma mark  UTIL
/*
 - (NSString *_Nullable) utilBase64Encode:(NSData *_Nullable)data error:(USError *_Nullable*_Nullable)error;
 - (NSData *_Nullable) utilBase64Decode:(NSString *_Nullable)string error:(USError *_Nullable*_Nullable)error;
 - (NSString *_Nullable) utilBinToHexString:(NSData *_Nullable)data error:(USError *_Nullable*_Nullable)error;
 - (NSData *_Nullable) utilHexStringToBin:(NSString *_Nullable)string error:(USError *_Nullable*_Nullable)error;
 - (NSData *_Nullable) utilHTTPDownloadFile:(NSString *_Nullable)url error:(USError *_Nullable*_Nullable)error;

 */

/**
 @discussion base64Encode
 @param data plainText
 @return 인코딩된 데이터
 */
- (NSString *_Nullable) base64Encode:(NSData *_Nullable)data;

@end
