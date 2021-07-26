//
//  KCLMyDataMultiSign.m
//  LiivMate
//
//  Created by KB on 2021/06/15.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCLMyDataMultiSign.h"
#import <wasdk/IssacCERTIFICATE.h>
#import <wasdk/IssacCMS.h>
#import <wasdk/IssacPRIVATEKEY.h>
#import <wasdk/IssacUCPIDREQUESTINFO.h>

@implementation KCLMyDataMultiSign {
}

-(id)initWithSignerCert:(IssacCERTIFICATE *)signerCert
           signerPriKey:(IssacPRIVATEKEY *)signerPriKey {
    self = [super init];
    if (self != nil) {
        self->signerCert = signerCert;
        self->signerPriKey = signerPriKey;
    }
    return self;
}

-(void)dealloc
{
}

-(NSString *)encodeUrl:(NSString *)str {
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}


/*
@var genSignedPersonInfoReq
@brief 마이데이터 사이닝 서버로부터 받은 Nonce와 마이데이터앱에서 사용자가 입력한 본인확인 이용동의
        등을 이용하여 마이데이터 전자서명요청데이터를 생성한다.
@param requestInfo : 정보제공자 기관코드
@return 사이닝된 데이터
*/
-(NSString *)genSignedPersonInfoReq:(NSDictionary *)requestInfo
                           signTime:(NSDate *)signTime
{
    IssacUCPIDREQUESTINFO *ucpidRequestInfo = [[IssacUCPIDREQUESTINFO alloc] init];
    
    //마이데이터 서버가 생성한 Nonce (128bit 숫자)
    NSData *ucpidNonce = [[NSData alloc] initWithBase64EncodedString:requestInfo[@"ucpidNonce"] options:0];
    [ucpidRequestInfo setUCPIDNonce:ucpidNonce];
    
    // 본인확인 이용 동의내역 문자열 (UTF-8)
    [ucpidRequestInfo setUserAgreement:requestInfo[@"userAgreement"]];
    
    //요청하고자 하는 본인확인정보
    NSDictionary *userAgreeInfo = requestInfo[@"userAgreeInfo"];
    {
        id realName = [userAgreeInfo objectForKey:@"realName"]; // 실명
        if (realName != nil && [realName boolValue] == true) {
            [ucpidRequestInfo addUserAgreeInfo:UserAgreeInfo_realName];
        }
        id gender = [userAgreeInfo objectForKey:@"gender"]; // 성별
        if (gender != nil && [gender boolValue] == true) {
            [ucpidRequestInfo addUserAgreeInfo:UserAgreeInfo_gender];
        }
        id nationalInfo = [userAgreeInfo objectForKey:@"nationalInfo"]; // 국적
        if (nationalInfo != nil && [nationalInfo boolValue] == true) {
            [ucpidRequestInfo addUserAgreeInfo:UserAgreeInfo_nationalInfo];
        }
        id birthDate = [userAgreeInfo objectForKey:@"birthDate"]; // 생년월일
        if (birthDate != nil && [birthDate boolValue] == true) {
            [ucpidRequestInfo addUserAgreeInfo:UserAgreeInfo_birthDate];
        }
        id ci = [userAgreeInfo objectForKey:@"ci"]; // CI 정보
        if (ci != nil && [ci boolValue] == true) {
            [ucpidRequestInfo addUserAgreeInfo:UserAgreeInfo_ci];
        }
    }
    
    // 마이데이터 서비스 도메인 정보
    [ucpidRequestInfo setIspUrlInfo:requestInfo[@"ispUrlInfo"]];
    
    NSData *signedPersonInfoReq = [ucpidRequestInfo genSignedPersonInfoReq:signerPriKey signerCert:signerCert signTime:signTime hashNid:NID_SHA256];
    if (signedPersonInfoReq == nil) {
        NSLog(@"cannot generate SignedPersonInfoReq");
        return nil;
    }
    
    NSString *signedPersonInfoReqB64 = [signedPersonInfoReq base64EncodedStringWithOptions:0];
    return [self encodeUrl:signedPersonInfoReqB64];
}


/*
@var genSignedConsent
@brief 전송요구내역을 이용하여 마이데이터 전자서명요청 데이터 생성
@param consentInfo : 전송요구 내역
@return 사이닝된 데이터
*/
-(NSString *)genSignedConsent:(NSDictionary *)consentInfo
                     signTime:(NSDate *)signTime
{
    NSError *error = nil;
    NSData *consentInfoData = [NSJSONSerialization dataWithJSONObject:consentInfo options:0 error:&error];
    
    IssacCMS *cms = [[IssacCMS alloc] init];
    NSData *signedConsent = [cms genSignedData:consentInfoData signerPriKey:signerPriKey signerCert:signerCert signTime:signTime hashNid:NID_SHA256];
    if (signedConsent == nil) {
        NSLog(@"cannot generate SignedConsent");
        return nil;
    }
    NSString *signedConsentB64 = [signedConsent base64EncodedStringWithOptions:0];
    return [self encodeUrl:signedConsentB64];
}


/*
@var genResponse
@brief 마이데이터 전자서명 결과데이터 생성
@param  caOrg : 전자서명에 사용된 고객 인증서 발급기관명
@return 사이닝된 데이터
*/
-(NSData *)genResponse:(NSString *)caOrg
           requestData:(NSData *)requestData
{
    NSError *error = nil;
    NSArray *requestList = [NSJSONSerialization JSONObjectWithData:requestData options:0 error:&error];
    NSDate *now = [NSDate date];
    
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    
    // 전자서명에 사용된 고객 인증서 발급기관명
    response[@"caOrg"] = caOrg;
    
    NSMutableArray *signedDataList = [[NSMutableArray alloc] init];
    for (NSDictionary *request in requestList) {
        NSMutableDictionary *signedData = [[NSMutableDictionary alloc] init];
        
        
        //정보제공자 기관코드
        signedData[@"orgCode"] = request[@"orgCode"];
        
        // UCPID 가이드라인의 UCPIDReqeustInfo를 서명한 CMS SignedData
        signedData[@"signedPersonInfoReq"] = [self genSignedPersonInfoReq:request[@"ucpidRequestInfo"] signTime:now];
        
        // 전송요구내역을 서명한 CMS SingedData
        signedData[@"signedConsent"] = [self genSignedConsent:request[@"consentInfo"] signTime:now];
        [signedDataList addObject:signedData];
    }
    response[@"signedDataList"] = signedDataList;
    
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:response options:0 error:&error];
    return responseData;
}

@end
