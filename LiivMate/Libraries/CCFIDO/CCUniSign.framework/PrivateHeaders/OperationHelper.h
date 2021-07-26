//
//  OperationHelper.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 3. 31..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "USToolkitMgr.h"
#import "CCJSONModel.h"
//#import "CCJSONModel.h"
#import <UIKit/UIKit.h>
#import "AttestationData.h"
@class UafRequest;
@class USCertificate;
@class ResultMessage;
@class TableFido;
@class RequestRegistration;
@class RequestTC;
@class AuthenticatorApi;
@class TrustedFacets;

@interface OperationHelper: UIViewController

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selectorComplete;
@property (nonatomic, assign) SEL selectorRegistedTypeCheck;
@property (nonatomic, assign) SEL selectorRegistrationType;
@property (nonatomic, retain) UafRequest *mUafRequest;
//@property (nonatomic, strong) USToolkitMgr *toolkit;
/*RPC에서 Request시 넘겨준 데이터를 담아둔다. 바이오 인증수단을 사용하여 인증 성공한 경우 TC Content를 보여줄떄 사용*/
@property (nonatomic, strong) NSString * tCContent;

/*FIDO server URL(RP서버 또는 FIDO Server)*/
@property (nonatomic, strong)  NSString *mServerUrl;
/*Operation Type : 터치아이디, 핀코드, Reg, Auth, TC, 인증서사용등..*/
@property (nonatomic, assign) int mOperationType;
@property (nonatomic, assign) NSString *mCompanyId;
/**FIDOFramework을 이용하여 가져온 인증서 사용시 사용할 인증서 인덱스 */
@property (nonatomic, assign) int mSelectedCertIndex;
@property (nonatomic, strong) NSData *mUseCert;
@property (nonatomic, strong) NSData *mPrivateKey;
@property (nonatomic, strong) NSString *mUseCertPw;
/*
 isRegistered에서 등록 여부 DB 확인시 KeyID일치시 담아둔다.
 : Auth 및 TC에서 Assertion 생성시 rawkeyHandle이 필요하여 DB를 여러번 Open 하지않기 위하여
 */
@property (nonatomic, retain) TableFido *mSelectedItem;
@property (nonatomic, retain) RequestRegistration *mRequestRegistration;
@property (nonatomic, retain) RequestTC *mRequestTC;

/*FidoSampleWithMessage에서 사용
 Framework에서 RPS서버랑 통신하지 않고 Framework에서는 메세지만 생성 RPCSample에서 RPS랑 통신하기 떄문에 responseMesaage생성 부분과 responseMesaageResult함수가 따로 있어 아래의 변수를 생성 후 공통으로 사용함.*/
@property (nonatomic, strong) NSString *mHexKHAccessToken;
@property (nonatomic, strong) NSData *mCertificate;
@property (nonatomic, strong) AuthenticatorApi *mAapi;
/*-------------------------*/

/*테스트로 진행시 서버에 FacetId정보를 등록하지 않아도 실행 가능하도록 하기 위하여*/
@property (nonatomic) BOOL mIsSkipToVerifyFacetID;

@property (nonatomic, strong) TrustedFacets *mTrustedFacets;

#pragma mark Request메세지 생성

/**
 @discussion Registration시 필요한 RequestMessage 를 생성한다.
 @param (int)operationType        : 오퍼레이션 타입에 따라 로직 분기
        (NSString *)uuid          : FrameWork을 사용하는 앱에서 생성한 UUID
        (NSString *)userId        : 사용자 아이디
        (NSString *)extData       : 고객사에서 RPS로 전달할 임의 데이터
 */
-(NSDictionary *)generateRequestMessageForRegistration:(int)operationType
                                                  uuid:(NSString *)uuid
                                                userId:(NSString *)userId
                                               extData:(NSString *)extData;

/**
 @discussion Authentication시 필요한 RequestMessage 를 생성한다.
 @param (int)operationType        : 오퍼레이션 타입에 따라 로직 분기
 (NSString *)uuid          : FrameWork을 사용하는 앱에서 생성한 UUID
 (NSString *)userId        : 사용자 아이디
 (NSString *)extData       : 고객사에서 RPS로 전달할 임의 데이터
 */
-(NSDictionary *)generateRequestMessageForAuthentication:(int)operationType
                                                    uuid:(NSString *)uuid
                                                  userId:(NSString *)userId
                                               tCContent:(NSString *)tCContent
                                                 extData:(NSString *)extData;

/**
 @discussion DeRegistration시 필요한 RequestMessage 를 생성한다.
 @param (int)operationType        : 오퍼레이션 타입에 따라 로직 분기
 (NSString *)uuid          : FrameWork을 사용하는 앱에서 생성한 UUID
 (NSString *)userId        : 사용자 아이디
 */
-(NSDictionary *)generateRequestMessageForDeregistration:(int)operationType
                                                    uuid:(NSString *)uuid
                                                  userId:(NSString *)userId;

#pragma mark Request메세지 결과 파싱
/**
 @discussion Registration Trigger(Request요청, Response요청)중에서 Request를 서버로 요청 후 받은 RequestResult를 parsing한다.
 @param (NSDictionary *)requestMessageResult : Registration RequestResult
        (id)aTarget                          : delegate
        (SEL)completeSelector                : Registration 결과를 리턴받을 SEL
        (SEL)registrationTypeSelector        : Registration시 touchId, passcode, passign등 타입을 리턴하여 준다
 */
-(void)requestMessageResultParsingForRegistration:(NSDictionary *)requestMessageResult
                                          aTarget:(id)aTarget
                                 completeSelector:(SEL)completeSelector
                              registrationTypeSel:(SEL)registrationTypeSelector
                                         bundleId:(NSString *)bundleId
                                        certIndex:(int)certIndex
                                             cert:(NSData *)cert
                                       privateKey:(NSData *)privateKey
                                         password:(NSString *)pw;


/**
 @discussion Authentication Trigger(Request요청, Response요청)중에서 Request를 서버로 요청 후 받은 RequestResult를 parsing한다.
 @param (NSDictionary *)requestMessageResult : Authentication RequestResult
        (id)aTarget                          : delegate
        (SEL)completeSelector                : Registration 결과를 리턴받을 SEL
        (SEL)registeredTypeCheckSelector     : Auth 및 TC시 Registration의 타입을 체크하여 인증서를 사용하여 Registration한 경우 인증서 확인창을 보여준다. 아닌 경우 인증 진행
 */
-(void)requestMessageResultParsingForAuthentication:(NSDictionary *)requestMessageResult
                                            aTarget:(id)aTarget
                                   completeSelector:(SEL)completeSelector
                               regTypeCheckSelector:(SEL)regTypeCheckSelector;

/**
 @discussion DeRegistration Trigger(Request요청, Response요청)중에서 Request를 서버로 요청 후 받은 RequestResult를 parsing한다.

 @param (NSDictionary *)requestMessageResult    : DeRegistration RequestResult
 (id)aTarget                             : delegate
 (SEL)completeSelector                   : Registration 결과를 리턴받을 SEL
 (SEL)registeredTypeCheckSelector        : Auth 및 TC시 Registration의 타입을 체크하여 인증서를 사용하여 Registration한 경우 인증서 확인창을 보여준다. 아닌 경우 인증 진행
 */
-(void)requestMessageResultParsingForDeregistration:(NSDictionary *)requestMessageResult
                                            aTarget:(id)aTarget
                                   completeSelector:(SEL)completeSelector;

#pragma mark Response메세지 결과 파싱

/**
 @discussion Registration Trigger(Request요청, Response요청)중에서 Response를 서버로 요청 후 받은 ResponseResult를 parsing 후 Operation을 종료한다.
 @param (NSDictionary *)requestMessageResult : Registration ResponseResult
 */
-(void)responseMessageResultParsingForRegistration:(NSDictionary *)responseMessageResult;


/**
 @discussion Authentication Trigger(Request요청, Response요청)중에서 Response를 서버로 요청 후 받은 ResponseResult를 parsing 후 Operation을 종료한다.
 @param (NSDictionary *)requestMessageResult : Authentication ResponseResult
 */
-(void)responseMessageResultParsingForAuthentication:(NSDictionary *)responseMessageResult;

/**
 @discussion TC Trigger(Request요청, Response요청)중에서 Response를 서버로 요청 후 받은 ResponseResult를 parsing 후 Operation을 종료한다.
 @param (NSDictionary *)requestMessageResult : Authentication ResponseResult
 */
-(void)responseMessageResultParsingForTC:(NSDictionary *)responseMessageResult;





#pragma mark Response메세지 생성

/**
 @discussion operation시 필요한 ResponseMessage 를 생성한다.
 @param Application별 인증서 (defualt는 KB용 인증서 : KB는 CCFido.dat정책이 생기기전 배포 되었다.)
 */
-(NSDictionary *)generateResponseMessage:(int)bioType
                               tcContent:(NSString *)tcContent
                         attestationData:(AttestationData *)attestationData
                                 isKFido:(int)isKFido
                                 toolkit:(USToolkitMgr *)toolkit
                                   error:(NSError **)error;

#pragma mark Request Operation
/**
 @discussion Registration Request(Trigger) 요청 후 결과를 받아 파싱하여 사용할 바이오 타입을 호출한 delegate로 전달한다.
 @param (NSString *)serverUrl               : 접속할 Fido Server URL
        (int)operationType                  : 오퍼레이션 타입에 따라 로직 분기
        (id)aTarget                         : delegate
        (SEL)completeSelector               : Registration 결과를 리턴받을 SEL
        (SEL)registeredTypeCheckSelector    : Auth 및 TC시 Registration의 타입을 체크하여 인증서를 사용하여 Registration한 경우 인증서 확인창을 보여준다. 아닌 경우 인증 진행
        (SEL)registrationTypeSelector       : Registration시 touchId, passcode, passign등 타입을 리턴하여 준다
        (NSString *)uuid                    : FrameWork을 사용하는 앱에서 생성한 UUID
        (NSString *)userId                  : 사용자 아이디
        (int)certIndex                      : reg시 FidoFrameWork을 이용하여 저장된 인증서를 사용할 경우 인증서의 인덱스를 넘겨준다
        (NSData *)cert                      : reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서
        (NSData *)privateKey                : reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서 privateKey
        (NSString *)pw                      : reg시 FidoFrameWork이 아닌 다른 방법을 이용허여 저장된 인증서를 사용할 경우의 인증서 비밀번호
        (NSString *)tCContent               : TC시 데이터
        (NSString *)extData                 : 고객사에서 RPS로 전달할 임의 데이터
 */
-(void)requestRegistrationToServer:(NSString *)serverUrl
                     operationType:(int)operationType
                           aTarget:(id)aTarget
                  completeSelector:(SEL)completeSelector
               registrationTypeSel:(SEL)registrationTypeSelector
                              uuid:(NSString *)uuid
                            userId:(NSString *)userId
                          bundleId:(NSString *)bundleId
                         certIndex:(int)certIndex
                              cert:(NSData *)cert
                        privateKey:(NSData *)privateKey
                          password:(NSString *)pw
                           bioType:(int)bioType
                           extData:(NSString *)extData;



/**
 @discussion Authentication Request(Trigger) 요청 후 결과를 받아 파싱하여 사용할 바이오 타입을 호출한 delegate로 전달한다.
 @param (NSString *)serverUrl               : 접속할 Fido Server URL
        (int)operationType                  : 오퍼레이션 타입에 따라 로직 분기
        (id)aTarget                         : delegate
        (SEL)completeSelector               : TransactionConfirmation 결과를 리턴받을 SEL
        (SEL)registeredTypeCheckSelector    : Auth 및 TC시 Registration의 타입을 체크하여 인증서를 사용하여 Registration한 경우 인증서 확인창을 보여준다. 아닌 경우 인증 진행
        (NSString *)uuid                    : FrameWork을 사용하는 앱에서 생성한 UUID
        (NSString *)userId                  : 사용자 아이디
        (NSString *)tCContent               : TC시 데이터
        (NSString *)extData                 : 고객사에서 RPS로 전달할 임의 데이터
 */
-(void)requestTransationConfirmationToServer:(NSString *)serverUrl
                               operationType:(int)operationType
                                     aTarget:(id)aTarget
                            completeSelector:(SEL)completeSelector
                        regTypeCheckSelector:(SEL)regTypeCheckSelector
                                        uuid:(NSString *)uuid
                                      userId:(NSString *)userId
                                    bundleId:(NSString *)bundleId
                                   tCContent:(NSString *)tCContent
                                     extData:(NSString *)extData;

/**
 @discussion Deregistraion을 서버로 요청한다.
 @param (NSString *)serverUrl     : 접속할 Fido Server URL
        (int)operationType        : 오퍼레이션 타입에 따라 로직 분기
        (id)aTarget               : delegate
        (SEL)completeSelector     : Registration 결과를 리턴받을 SEL
        (NSString *)uuid          : FrameWork을 사용하는 앱에서 생성한 UUID
        (NSString *)userId        : 사용자 아이디
        (NSString *)bundleId      : 앱 번들 아이디
        (NSString *)extData       : 고객사에서 RPS로 전달할 임의 데이터
 */
-(void)requestDeregistrationToServer:(NSString *)serverUrl
                       operationType:(int)operationType
                             aTarget:(id)aTarget
                    completeSelector:(SEL)completeSelector
                                uuid:(NSString *)uuid
                              userId:(NSString *)userId
                            bundleId:(NSString *)bundleId
                             extData:(NSString *)extData;



#pragma mark response 트리거 실행

/**
 @discussion Operation Type에 따라 Response을 실행한다.
 @param bioType : 홍체, 지문, 패턴 등...
 */
-(void)executeTriggerWithResponse:(int)bioType
                  attestationData:(AttestationData *)attestationData;


@end
