//
//  IssacUCPIDREQUESTINFO.h
//  wasdk
//
//  Created by 하지윤 on 2021/05/11.
//

#ifndef IssacUCPIDREQUESTINFO_h
#define IssacUCPIDREQUESTINFO_h

#import <wasdk/IssacCERTIFICATE.h>
#import <wasdk/IssacPRIVATEKEY.h>

@interface IssacUCPIDREQUESTINFO : NSObject {
}

@property(class, readonly) int userAgreeInfo_realName;
@property(class, readonly) int userAgreeInfo_gender;
@property(class, readonly) int userAgreeInfo_nationalInfo;
@property(class, readonly) int userAgreeInfo_birthDate;
@property(class, readonly) int userAgreeInfo_ci;

@property(class, readonly) int nid_SHA1;
@property(class, readonly) int nid_SHA256;

/// 비표(Nonce) 값을 설정한다.
/// @param nonce 비표(Nonce) 값
-(int)setUCPIDNonce:(NSData *)nonce;

/// 개인정보제공 및 활용동의 약관을 설정한다.
/// @param userAgreement 개인정보 제공 및 활용동의 약관
-(int)setUserAgreement:(NSString *)userAgreement;

/// 개인정보활용 동의 항목을 추가한다.
/// @param userAgree 개인정보활용 동의 항목 [UserAgreeInfo_realName, UserAgreeInfo_gender, UserAgreeInfo_nationalInfo, UserAgreeInfo_birthDate, UserAgreeInfo_ci]
-(int)addUserAgreeInfo:(int)userAgree;

/// ISP URL Info 를 설정한다.
/// @param ispUrlInfo ISP URL Info (scheme 정의부와 uri 정의부를 제외한 url)
-(int)setIspUrlInfo:(NSString *)ispUrlInfo;

/// ucpidAttributes 를 설정한다. (확장성을 위해 필요한 값으로 현재는 사용하지 않음)
/// @param ucpidAttributes ucpidAttributes
-(int)setUCPIDAttributes:(NSData *)ucpidAttributes;


/// signedPersonInfoReq (버전 2 의 경우 서명된 UCPIDRequestInfo) 를 생성한다.
/// @param signerPriKey 이용자의 서명용 개인키
/// @param signerCert 이용자의 서명용 인증서
/// @param signTime 서명 시각
/// @param hashNid 서명에 사용할 해시 알고리즘 [SHA1(134), SHA256(385)]
-(NSData *)genSignedPersonInfoReq:(IssacPRIVATEKEY *)signerPriKey
                       signerCert:(IssacCERTIFICATE *)signerCert
                         signTime:(NSDate *)signTime
                          hashNid:(int)hashNid;

@end

#endif /* IssacUCPIDREQUESTINFO_h */
