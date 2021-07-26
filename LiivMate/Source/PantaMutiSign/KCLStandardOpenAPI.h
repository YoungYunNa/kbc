//
//  KCLStandardOpenAPI.h
//  LiivMate
//
//  Created by KB on 6/15/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLStandardOpenAPI
@date 2021.06.15
@brief 표준 Open API 
*/

#import <Foundation/Foundation.h>

#import "CertificationManager.h"

#import <wasdk/IssacCMS.h>
#import <wasdk/IssacUCPIDREQUESTINFO.h>
#import <wasdk/IssacCERTIFICATE.h>
#import <wasdk/IssacPRIVATEKEY.h>

NS_ASSUME_NONNULL_BEGIN

@interface KCLStandardOpenAPI : NSObject {
    IssacCERTIFICATE *signerCert;   // 인증서 Certificate 값
    IssacPRIVATEKEY *signerPriKey;  // 인증서 Private Key 값
}


typedef void (^OpenAPISignedFinish)(NSDictionary * _Nullable result, BOOL isSuccess);   // Complication 원형 정의
@property (strong, nonatomic) OpenAPISignedFinish signedFinish;  // Complication 객체

// SingleTon 생성
+ (KCLStandardOpenAPI *)sharedInstance;

// 선택된 인증서를 가지고 Multi Signed 진행
- (void)startOpenApiSinged:(NSDictionary *)param completion:(OpenAPISignedFinish)completion;


@end

NS_ASSUME_NONNULL_END
