//
//  CertMovementHelper.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 4. 14..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#ifndef CertMovementHelper_h
#define CertMovementHelper_h


#endif /* CertMovementHelper_h */

#import <Foundation/Foundation.h>
#import "OBJCUSToolkit.h"
@class USToolkitMgr;
@class USTransferMgr;
@class USCertificate;
@class ResultMessage;


@interface CertMovementHelper:OBJCUSToolkit

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL importCertResultSelector;
@property (nonatomic, assign) SEL checkPasswordResult;
@property (nonatomic, assign) SEL deleteCertResult;
//@property (nonatomic, strong) USToolkitMgr *toolkit;
@property (nonatomic, strong) USTransferMgr *transfer;
@property (nonatomic, strong) USCertificate *cert;

+(instancetype) getInstance;

-(void) isPCconnected:(SEL)importCertResultSelector
              aTarget:(id)aTarget;


//-(NSString *)getGenerateNumber:(NSString *)transferLicense
//                         error:(USError *)error;
-(NSString *)getGenerateNumber:(USError *)error;

/**
 @discussion 인증서 이동 중계서버와 연결 후 결과를 리턴한다.
 */
-(BOOL)transIsPCConnected:(USError *)error;

/**
 @discussion 인증서 가져오기를 수행 한다. *transIsPCConnected가 YES일 경우 사용한다.
 */
-(USCertificate *)transImportCert:(USError *)error;

/**
 @discussion 입력된 비밀번호가 인증서의 비밀번호인지 체크
 @param (NSString *)password
        (id)aTarget
        (SEL)completeSelector
        (USError **)error;
 */
-(BOOL)checkPasswordOfCert:(NSString *)password
                   aTarget:(id)aTarget
          completeSelector:(SEL)completeSelector
                     error:(USError **)error;


-(void)setLicenseBundleId:(NSString *)bundleId
                     uuid:(NSString *)uuid
                    error:(USError **)error;

/**
 @discussion 등록된 인증서 삭제
 @param (id)aTarget           : delegate
        (SEL)completeSelector : 결과를 리턴받을 SEL
        (int)certIndex        : 삭제할 DB 인덱스
 */
-(void)removalCertByIndex:(id)aTarget
         completeSelector:(SEL)completeSelector
                certIndex:(int)certIndex;


@end
