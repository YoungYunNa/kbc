//
//  IssacCMS.h
//  wasdk
//
//  Created by 하지윤 on 2021/05/11.
//

#ifndef IssacCMS_h
#define IssacCMS_h

#import <wasdk/IssacCERTIFICATE.h>
#import <wasdk/IssacPRIVATEKEY.h>


@interface IssacCMS : NSObject {
}

/// PKCS#7 SignedData 메시지를 생성한다.
/// @param message 서명할 원문 메시지
/// @param signerPriKey 서명자의 개인키
/// @param signerCert 서명자의 인증서
/// @param signTime 서명 시각
/// @param hashNid 서명에 사용할 해시 알고리즘 [SHA1(134), SHA256(385)]
-(NSData *)genSignedData:(NSData *)message
            signerPriKey:(IssacPRIVATEKEY *)signerPriKey
              signerCert:(IssacCERTIFICATE *)signerCert
                signTime:(NSDate *)signTime
                 hashNid:(int)hashNid;

/// PKCS#7 SignedData 를 검증한다.
/// @param signedData PKCS#7 SignedData 메시지
-(BOOL)verifySignedData:(NSData *)signedData;

@end

#endif /* IssacCMS_h */
