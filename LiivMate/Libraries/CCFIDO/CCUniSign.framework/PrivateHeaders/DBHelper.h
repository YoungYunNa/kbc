//
//  DBHelper.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 4. 5..
//  Copyright © 2016년 jwchoi. All rights reserved.
//



#import <Foundation/Foundation.h>
@class FMDatabase;
@class TableCert;

/*
 BioMetricsState : TouchID, FaceID의 경우 해당 BioMetricsState 값을 사용하고 아래의 인증 수단의 경우 BioMetricsState가 없기 때문에 아래와 같이 명시한다.
 */
#define BIOSTATE_NOTHING    @"NOTHING"
#define BIOSTATE_PATTERN    @"PATTERN"
#define BIOSTATE_VOICE      @"VOICE"
#define BIOSTATE_PIN        @"PIN"
#define BIOSTATE_FACEPHI    @"FACEPHI"
/* -------------------- */

@interface DBHelper : NSObject

@property (nonatomic, retain) FMDatabase *fmDb;

+(instancetype) getInstance;

-(void)databaseCreate;

-(void)deleteRowKeyId:(NSString *)KeyId;

/**
@discussion FIDO에 등록된 사용자 삭제
@param UserId    : 사용자 아이디
@param isKFido   : K-FIDO 여부
@param companyId :
*/
-(void)deleteUserId:(NSString *)UserId
            isKFido:(int)isKFido
          companyId:(NSString *)companyId;
/**
@discussion FIDO에 등록된 모든 사용자 삭제(K-FIDO, FIDO 포함)
*/
-(void)deleteAllUser;

-(BOOL)deleteCertByIndex:(int)index;

-(void)saveRowUserId:(NSString *)UserId
               keyId:(NSString *)keyId
              rawkey:(NSString *)rawkey
             khtoken:(NSString *)khtoken
         certificate:(NSString *)certificate
       operationType:(int)operationType
           companyId:(NSString *)companyId
            bioState:(NSString *)bioState
              pubKey:(NSString *)pubKey;

-(BOOL)insertCert:(NSString *)signCert
          signPri:(NSString *)signPri
      signPriUUID:(NSString *)signPriUUID
           kmCert:(NSString *)kmCert
            kmPri:(NSString *)kmPri
        kmPriUUID:(NSString *)kmPriUUID
               pw:(NSString *)pw
             hash:(NSString *)hash;

//-(NSArray <TableCert *> *)getCerts;
-(NSArray *)getFidoDbData;
-(NSArray *)getFidoDbDataWith:(NSString *)userId
                    companyId:(NSString *)companyId
                  includeCert:(BOOL)includeCert;

-(NSMutableArray <TableCert *> *)getCertDbDatas:(int)index;
-(TableCert *)getCertDbData:(NSString *)signCert;

-(BOOL)isRegisteredPincode;

-(BOOL)insertPincode:(NSString *)key
                salt:(NSString *)salt;

-(BOOL)changePincode:(NSString *)key
                salt:(NSString *)salt;

-(BOOL)deletePincode;
-(NSMutableDictionary *)getPincode;

/**
 @discussion 기존 사용자가 존재할시(개발된 Framework 를 업데이트 후 이전 사용자) 초기화 함수 추가 : 현재의 BioMetricsState로 초기화
 */
-(BOOL)initUserInfo;

/**
 @discussion 사용자가 FIDO Regstration할 당시의 BioMetricState와 현재의 BioMetricState와 비교하여 변경 되었는지 감지
 @param userID : 사용자 아이디
 evaluatedPolicyDomainState : 현재 바이오 상태
 @return BIO_METRICS_UNCHANGED : 바이오정보 변경 되지 않음
 BIO_METRICS_CHANGED : 바이오정보 변경됨
 */
-(int)detectWhetherChangeBiometrics:(NSString *)userID
         evaluatedPolicyDomainState:(NSString *)evaluatedPolicyDomainState;

/**
 @discussion 사용자별 PublicKey를 획득한다.
 @param userID : 사용자 아이디
 @return publicKey
 */
-(NSString *)getFidoPublicKey:(NSString *)userId;
@end
