//
//  KCLStandardOpenAPI.m
//  LiivMate
//
//  Created by KB on 6/15/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLStandardOpenAPI.h"

@implementation KCLStandardOpenAPI 

@synthesize signedFinish;

// SingleTon
+ (KCLStandardOpenAPI *)sharedInstance {
    static KCLStandardOpenAPI *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

// init 초기화
- (id)init {
    if (self == [super init]) {
        signerCert = nil;       
        signerPriKey = nil;     
    }
    return self;
}

#pragma mark - Start Multi Signed
// Multi Signed 시작
- (void)startOpenApiSinged:(NSDictionary *)param completion:(OpenAPISignedFinish)completion {
    signedFinish = completion;
    
    [[CertificationManager shared] openSecureKeyboard:param completion:^(char * _Nonnull plainText, BOOL isCancel) {
        if (!isCancel) {
            [self pentaMultiSigned:plainText param:param]; // 인증서 암호 입력 후 확인
        }else {
            //사용자 취소
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"9004", @"rsltCode",
                                 @"", @"massage",
                                 @"7", @"linkType",
                                 nil];
            
            self->signedFinish(dic, NO);
        }
    }];
}

#pragma mark - Penta WaSDK Signed
- (void)pentaMultiSigned:(char *)plainText param:(NSDictionary *)param {
    
    CertItem *certItem = [[CertificationManager shared] getCertItem:param];
    
    if (certItem != nil ) { // 선택한 인증서 일치
        [[CertificationManager shared] loadCertifiCation:certItem pass:plainText completion:^(NSDictionary * _Nullable result, BOOL isSuccess) { // 인증서 로드
            if (!isSuccess) {
                NSLog(@"인증서 검증 실패 result == %@", result);
                self->signedFinish(result, NO);
                return;
            }
            
            NSLog(@"%s cert == %@", __FUNCTION__, [[result objectForKey:@"signCert"] base64EncodedStringWithOptions:0]);
            NSLog(@"%s priKey == %@", __FUNCTION__, [[result objectForKey:@"signPri"] base64EncodedStringWithOptions:0]);
            
            int ret = -1;
            self->signerCert = [[IssacCERTIFICATE alloc] init];
            ret = [self->signerCert readData:[result objectForKey:@"signCert"]]; // Open API용 Cert
            if (ret != 0) {
                NSLog(@"readData ret = %d", ret);
                [self pentaSignedError];
                return;
            }
            
            self->signerPriKey = [[IssacPRIVATEKEY alloc] init];
            ret = [self->signerPriKey readData:[result objectForKey:@"signPri"] pin:[NSString stringWithUTF8String:plainText]]; // Open API용 PriKey
            if (ret != 0) {
                NSLog(@"IssacPRIVATEKEY.read ret = %d", ret);
                [self pentaSignedError];
                return;
            }

            NSLog(@"%s myDataSignInfoList== %@", __FUNCTION__, [param objectForKey:@"myDataSignInfoList"]);
            
            NSMutableArray *multiSignReqData = [param objectForKey:@"myDataSignInfoList"]; // Multi Signed을 하기 위한 데이터 목록
            NSData *reqData = [NSJSONSerialization dataWithJSONObject:multiSignReqData options:0 error:nil];

            NSString *caOrg = [param objectForKey:@"caOrg"]; // 인증서 발급기관
            NSDictionary *multiSign = [self genResponse:caOrg requestData:reqData]; // Multi Signed 된 데이터
            
            NSLog(@"%s resultSign == %@", __FUNCTION__, multiSign);
            
            if (multiSign != nil) {
                self->signedFinish(multiSign, YES);
            } else {
                [self pentaSignedError];
                return;
            }
        }];
    }
}

#pragma mark - pentaSignedError Code
- (void)pentaSignedError {
    // Multi Signed Error
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"4003", @"rsltCode",
                         @"", @"massage",
                         @"3", @"linkType",
                         nil];
    self->signedFinish(dic, NO);
}

#pragma mark - MultiSigned Response Data
// MultiSigned Response 데이터 만듬
- (NSDictionary *)genResponse:(NSString *)caOrg
           requestData:(NSData *)requestData {
    
    NSError *error = nil;
    NSArray *requestList = [NSJSONSerialization JSONObjectWithData:requestData options:0 error:&error]; // Array 데이터로 변경
    NSDate *now = [NSDate date]; // Signed 요청한 현재 시간
    
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init]; // 결과 값을 받을 Dictionary 데이터
    response[@"caOrg"] = caOrg; // caOrg (인증서 발급기관 - yessign, SignKorea, KICA, CrossCert 등)
    NSMutableArray *signedDataList = [[NSMutableArray alloc] init]; // signed 데이터 Array
    
    for (NSDictionary *request in requestList) { // MultiSigned 결과 데이터 만듬
        NSMutableDictionary *signedData = [[NSMutableDictionary alloc] init];
        signedData[@"signedPersonInfoReq"] = [self genSignedPersonInfoReq:request[@"ucpidRequestInfo"] signTime:now];  // UCPID signedPersonInfoReq 결과 값
        if (signedData[@"signedPersonInfoReq"] == nil) {
            signedDataList = nil;
            break;
        }
        
        signedData[@"signedConsent"] = [self genSignedConsent:request[@"consentInfo"] signTime:now]; // Consent signedConsent 결과 값
        if (signedData[@"signedConsent"] == nil) {
            signedDataList = nil;
            break;
        }
        
        signedData[@"orgCode"] = request[@"orgCode"];   // 정보제공자 기관코드
        
        [signedDataList addObject:signedData];
    }

    response[@"signedDataList"] = signedDataList;

    // 결과 데이터 리턴
    NSDictionary *signedDatasDic = [NSDictionary dictionaryWithObjectsAndKeys:
                         response, @"signedDatas",
                         nil];
    
    return signedDatasDic;
}

// PersonInfoReq Signed Data
- (NSString *)genSignedPersonInfoReq:(NSDictionary *)requestInfo
                           signTime:(NSDate *)signTime {
    
    IssacUCPIDREQUESTINFO *ucpidRequestInfo = [[IssacUCPIDREQUESTINFO alloc] init];

    NSString *reqUcpidNonce = requestInfo[@"ucpidNonce"];
    
    NSData *ucpidNonce = [[NSData alloc] initWithBase64EncodedString:reqUcpidNonce.stringByUrlDecoding options:0];  
    NSLog(@"ucpidNonce == %@", [ucpidNonce base64EncodedStringWithOptions:0]);
    
    [ucpidRequestInfo setUCPIDNonce:ucpidNonce];                                    // ucpid Nonce

    [ucpidRequestInfo setUserAgreement:requestInfo[@"userAgreement"]];              // 개인정보 동의 또는 이용약관

    NSDictionary *userAgreeInfo = requestInfo[@"userAgreeInfo"];                    // 개인정보 허용범위
        
    BOOL realName = [[userAgreeInfo objectForKey:@"realName"] boolValue];           // 실명사용 유/무
    if (realName) {
        [ucpidRequestInfo addUserAgreeInfo:IssacUCPIDREQUESTINFO.userAgreeInfo_realName];
    }
    
    BOOL gender = [[userAgreeInfo objectForKey:@"gender"] boolValue];               // 성별사용 유/무
    if (gender) {
        [ucpidRequestInfo addUserAgreeInfo:IssacUCPIDREQUESTINFO.userAgreeInfo_gender];
    }
    
    BOOL nationalInfo = [[userAgreeInfo objectForKey:@"nationalInfo"] boolValue];   // 국적사용 유/무
    if (nationalInfo) {
        [ucpidRequestInfo addUserAgreeInfo:IssacUCPIDREQUESTINFO.userAgreeInfo_nationalInfo];
    }
    
    BOOL birthDate = [[userAgreeInfo objectForKey:@"birthDate"] boolValue];         // 생년월일사용 유/무
    if (birthDate) {
        [ucpidRequestInfo addUserAgreeInfo:IssacUCPIDREQUESTINFO.userAgreeInfo_birthDate];
    }
    
    BOOL ci = [[userAgreeInfo objectForKey:@"ci"] boolValue];                       // CI사용 유/무
    if (ci) {
        [ucpidRequestInfo addUserAgreeInfo:IssacUCPIDREQUESTINFO.userAgreeInfo_ci];
    }
    

    [ucpidRequestInfo setIspUrlInfo:requestInfo[@"ispUrlInfo"]];                    // isp url 정보

    // UCPID Request Signed
    NSData *signedPersonInfoReq = [ucpidRequestInfo genSignedPersonInfoReq:signerPriKey signerCert:signerCert signTime:signTime hashNid:IssacUCPIDREQUESTINFO.nid_SHA256];
    if (signedPersonInfoReq == nil) {
        NSLog(@"cannot generate SignedPersonInfoReq");
        return nil;
    }

    // UCPID signedPersonInfoReq 결과 값
    NSString *signedPersonInfoReqB64 = [signedPersonInfoReq base64EncodedStringWithOptions:0];
    return signedPersonInfoReqB64.stringByUrlEncoding;
}

// ConsentInfo Signed Data
-(NSString *)genSignedConsent:(NSDictionary *)consentInfo
                     signTime:(NSDate *)signTime {
    NSError *error = nil;
    NSData *consentInfoData = [NSJSONSerialization dataWithJSONObject:consentInfo options:0 error:&error];
    
    IssacCMS *cms = [[IssacCMS alloc] init];
    
    // Consent Request Signed
    NSData *signedConsent = [cms genSignedData:consentInfoData signerPriKey:signerPriKey signerCert:signerCert signTime:signTime hashNid:IssacUCPIDREQUESTINFO.nid_SHA256];
    if (signedConsent == nil) {
        NSLog(@"cannot generate SignedConsent");
        return nil;
    }
    
    // Consent signedConsent 결과 값
    NSString *signedConsentB64 = [signedConsent base64EncodedStringWithOptions:0];
    return signedConsentB64.stringByUrlEncoding;
}

@end
