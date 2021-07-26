//
//  ScrappingManager.m
//  LiivMate
//
//  Created by kbcard-macpro-a on 2019. 3. 15..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "ScrappingManager.h"
#import "PwdPinViewController.h"
#import "PwdCertViewController.h"
#import "PentaPinViewController.h"
#import "XMLReader.h"
#import "MobileWeb.h"
#import "GifProgress.h"

@implementation ScrappingManager
@synthesize scrappingFinish;

+ (ScrappingManager *)shared {
    static ScrappingManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self == [super init]) {
        resultDic = [[NSMutableDictionary alloc] init];
        failCnt = 0;
        scrappingErrCd = 0;
    }
    return self;
}

- (void)startScrapping:(NSDictionary *)param retry:(BOOL)retry completion:(ScrappingFinish)completion {
    scrappingFinish = completion;
    if (retry) {    //스크래핑 문서 발급 재시도의 경우
        if ([[PwdWrapper shared].pwdCertVC isKindOfClass:[PwdCertViewController class]]) {
            PwdCertViewController *vc = (PwdCertViewController *)[PwdWrapper shared].pwdCertVC;
            [vc.raonTf getPlainText:^(char *plain) {
                [self issueScrapping:plain param:param];
            }];
        }
    }else {
        scrappingErrCd = 0;
        [resultDic removeAllObjects];
        
        [[CertificationManager shared] openSecureKeyboard:param completion:^(char * _Nonnull plainText, BOOL isCancel) {
            if (!isCancel) {
                [self issueScrapping:plainText param:param];
            }else {
                //사용자 취소
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"9004", @"rsltCode",
                                     @"", @"massage",
                                     @"7", @"linkType",
                                     nil];
                self->scrappingFinish(dic, NO);
            }
        }];
    }
}
- (BOOL)checkLicense:(NSInteger)cnt {
    BOOL ret = NO;
    NSString *license = @"gXZ7YPvmC9jCZao/DHC/5MOCma1tBOWZrVUFc4lDFSRiXCngFHivac518wTSaOqm5XPaJCj9VwB7C5LlX+U0d2K+pLFq7tgNmpBlMOOTP0arvlq0Xcmg6cP/nB5h6UdIP88On9jmlTZJBzHFpP1mmXuKXBzxm45NvO9aAg226IwhvrPDWC0kwssJVbBDgI2N9BqIXL0pQ7tniypxHRPF82CrGdLCqNACh4PjAN2UK0D8RmO4CM3wgmY9UHMejHOTnh1I28BKrPTiYiXszvCLgg0qG5KlUqDLT4HrFe8LF6W1RJEhBqOJwmwALsQEmQgrn0YU+ksSrLSanRDvwZEgCg==";
    
    self->count = (int)cnt + 2;      // 발급하려는 문서의 갯수 +@ 발급하려는 문서 개수에 따라서 조절해 준다.
    self->omniDoc = [FHOmniDoc new];
    [self->omniDoc SetEnvValue:@"nhispdf" value:@"on"];
    
    self->handle = [self->omniDoc CertRequestStructInit:self->count];
    self->issueRes = nil;
    
    
    NSInteger licenseRes = [self->omniDoc SetLicense:license];
    
    NSString *msg = @"";
    
    switch(licenseRes) {
        case FH_E_F_NO_LICENSE:
            msg = @"라이선스가 없습니다.";
            break;
        case FH_E_F_LICENSE_CHECK:
            msg = @"잘못된 라이선스입니다.";
            break;
        case FH_E_F_LICENSE_EXPIRED:
            msg = @"만료된 라이선스입니다.";
            break;
        default:
            ret = YES;
            break;
    }
    if(!ret){
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%ld",(long)scrappingErrCd],@"rsltCode",
                             msg, @"massage",
                             @"4", @"linkType",
                             nil];
        
        scrappingFinish(dic, NO);
    }
    return ret;
}

-(void) updateProgress:(NSDictionary *)param {
    if(issueRes == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self updateProgress:param];
        });
    } else {
        
        
        if(stop[0] == 0) {
            
            NSArray *types = [param objectForKey:@"reportType"];
            
            NSMutableArray *errArr = [NSMutableArray new];
            
            BOOL isFail = NO;
            
            for(NSString *type in types){
                if ([type isEqualToString:@"101"]) {
                    //건강보험 납부확인서
                    NSString *res = [self getIssuedDoc:FH_NHIS_NABBU];
                    if (res != nil) {
                        [resultDic setObject:res forKey:@"101"];
                    }else{
                        [errArr addObject:@"101"];
                        isFail = YES;
                    }
                }
                else if ([type isEqualToString:@"102"]) {
                    //건강보험 자격득실확인서
                    NSString *res = [self getIssuedDoc:FH_NHIS_JAGEOK];
                    if (res != nil) {
                        [resultDic setObject:res forKey:@"102"];
                    }else{
                        [errArr addObject:@"102"];
                        isFail = YES;
                    }
                }
                else if ([type isEqualToString:@"211"]) {
                    //국세청 소득금액증명원 봉급생활자
                    NSString *res;
                    if (scrappingErrCd != -1) {
                        res = [self getIssuedDoc:FH_NTS_SODEUK_BONGGUP];
                    }else {
                        scrappingErrCd = 0;
                        res = [self getIssuedDoc:FH_NTS_SODEUK_JONGHAP];
                    }
                    if (res != nil) {
                        [resultDic setObject:res forKey:@"211"];
                    }else{
                        [errArr addObject:@"211"];
                        isFail = YES;
                    }
                }
                else if ([type isEqualToString:@"212"]) {
                    //국세청 소득금액증명원 사업소득자
                    NSString *res;
                    if (scrappingErrCd != -1) {
                        res = [self getIssuedDoc:FH_NTS_SODEUK_SAUP];
                    }else {
                        scrappingErrCd = 0;
                        res = [self getIssuedDoc:FH_NTS_SODEUK_JONGHAP];
                    }
                    if (res != nil) {
                        [resultDic setObject:res forKey:@"212"];
                    }else{
                        [errArr addObject:@"212"];
                        isFail = YES;
                    }
                }
                else if ([type isEqualToString:@"221"]) {
                    //국세청 사업자등록증명원
                    NSString *res = [self getIssuedDoc:FH_NTS_SAUPJA];
                    if (res != nil) {
                        [resultDic setObject:res forKey:@"221"];
                    }else{
                        [errArr addObject:@"221"];
                        isFail = YES;
                    }
                }
            }
            [omniDoc CertRequestStructTerm:handle count:count]; //구조체 초기화
            [omniDoc OmniDocReset]; //리셋(메모리 누수)
            
            if (isFail) {
                if (scrappingErrCd == -1 && errArr.count == 1) {
                    
                    NSMutableDictionary *reDic = [param mutableCopy];
                    [reDic setObject:errArr forKey:@"reportType"];
                    [self startScrapping:reDic retry:YES completion:scrappingFinish];
                    
                }else {
                    NSArray *resKeys = [resultDic allKeys];
                    //발급된 문서가 1개이상 있을 경우 전달해달라는 요건으로 수정
                    if (resKeys.count == 0) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%ld",(long)scrappingErrCd],@"rsltCode",
                                             @"",@"message",
                                             @"4",@"linkType",
                                             nil];
                        
                        scrappingFinish(dic, NO);
                    }else{
                        for(int i=0; i<errArr.count; i++){
                            NSString *key = [errArr objectAtIndex:i];
                            [resultDic setObject:@"" forKey:key];
                        }
                        scrappingFinish(resultDic, YES);// 스크래핑 성공 콜백
                    }
                }
                
                return;
            }else {
                scrappingFinish(resultDic, YES);// 스크래핑 성공 콜백
            }
            
        }
    }
}
-(NSString *)getIssuedDoc:(NSInteger) type {
    
    NSData *issuedDoc = [omniDoc CertRequestStructGetCert:handle count:count type:type];
    if(issuedDoc != nil) {
        // UTF-8
        NSString *result = [[NSString alloc] initWithData:issuedDoc encoding:NSUTF8StringEncoding];
        if(result != nil && ![result isEqualToString:@"(null)"]) {
        } else {
            // EUC-KR
            result = [[NSString alloc] initWithData:issuedDoc encoding:CFStringConvertEncodingToNSStringEncoding(0x0422)];
            if(result != nil) {
            }
        }
        NSError *parseError = nil;
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:result error:&parseError];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:xmlDictionary
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        NSLog(@"error == %@", error);
        NSString *base64 = [jsonData base64EncodedStringWithOptions:0];
        return base64;
    } else {
        if(scrappingErrCd == 0){
            scrappingErrCd = [omniDoc CertRequestStructGetErr:handle count:count type:type];
            if (scrappingErrCd != -4) {
                scrappingErrCd = scrappingErrCd & 0x00FFFFFF;
            }
        }
        
        
        if (type == FH_NTS_SODEUK_SAUP || type == FH_NTS_SODEUK_BONGGUP) {
            if (scrappingErrCd == FH_E_N_APPLIED) {
                scrappingErrCd = -1;
            }
        }
        return nil;
    }
}
- (void)issueScrapping:(char *)plainText param:(NSDictionary *)param {
    
    CertItem *certItem = [[CertificationManager shared] getCertItem:param];
    
    [[CertificationManager shared] loadCertifiCation:certItem pass:plainText completion:^(NSDictionary * _Nullable result, BOOL isSuccess) {
        
        if (!isSuccess) {
            int ret = [result[@"rsltCode"] intValue];
            if (ret == IW_ERR_WRONG_PIN) {
                self->failCnt++;
                
                if(self->failCnt == 5){
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"9002", @"rsltCode",
                                         @"", @"message",
                                         @"7", @"linkType",
                                         nil];
                    
                    self->scrappingFinish(dic, isSuccess);
                    self->failCnt = 0;
                    return ;
                }
            }
            self->scrappingFinish(result, isSuccess);
            return ;
        }
        
        NSArray *types = [param objectForKey:@"reportType"];
        
        if ([self checkLicense:types.count]) {  //라이센스 체크
            NSData *signCert = [result objectForKey:@"signCert"];
            NSData *signPri = [result objectForKey:@"signPri"];
            
            if ([self checkPass:signCert SignPri:signPri pass:plainText]) { //인증서 비밀번호 확인
                
                if ([[PwdWrapper shared].pwdPinVC isKindOfClass:[PwdPinViewController class]]) {
                    PwdPinViewController *vc = (PwdPinViewController *)[PwdWrapper shared].pwdPinVC;
                    [vc.raonTf getPlainText:^(char *plain) {
                        [self issue:signCert signPri:signPri plain:plain plainPass:plainText param:param];
                    }];
                }else {
                    PentaPinViewController *vc = (PentaPinViewController *)[PwdWrapper shared].pwdPinVC;
                    [vc getPlainText:^(char *plain) {
                        [self issue:signCert signPri:signPri plain:plain plainPass:plainText param:param];
                    }];
                }
                
            }else {
                //비밀번호 불일치 콜백은 checkPass에 있음
            }
        }else{
            //라이센스 에러
            //콜백은 checkLicense 에서 처리
        }
    }];
}

// 웹 반환 딕셔너리 패스워드 틀렸을때 linkType 3 으로 안드로이드랑 맞춤
- (BOOL)checkPass:(NSData *)signCert SignPri:(NSData *)signPri pass:(char *)pass {
    BOOL ret = NO;
    
    NSInteger res = [omniDoc CheckCertPassword:signCert keyData:signPri password:[NSString stringWithCString:pass encoding:NSUTF8StringEncoding]];
    
    if (res == 0) {
        ret = YES;
    }else {
        //비밀번호 불일치
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%ld",(long)res], @"rsltCode",
                             @"", @"message",
                             @"3", @"linkType", // 4->3으로 변경
                             nil];
        self->scrappingFinish(dic, NO);
    }
    
    return ret;
}
- (BOOL)checkRRN:(NSData *)signCert SignPri:(NSData *)signPri rrn1:(NSString *)rrn1 rrn2:(NSString *)rrn2 pass:(NSString *)pass {
    BOOL ret = NO;
    
    NSInteger res = [omniDoc CheckRRN:signCert keyData:signPri password:pass rrn1:rrn1 rrn2:rrn2];
    
    if (res == 0) {
        ret = YES;
    }else {
        //주민번호 불일치
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"9001", @"rsltCode",
                             @"", @"message",
                             @"7", @"linkType",
                             nil];
        self->scrappingFinish(dic, NO);
    }
    
    return ret;
}

- (void)issue:(NSData *)signCert signPri:(NSData *)signPri plain:(char *)ssno2 plainPass:(char *)pass param:(NSDictionary *)param{
    NSString *ssno = [param objectForKey:@"ssno"];
    
    __block NSString *encRRn1 = [omniDoc EncryptParams:[ssno dataUsingEncoding:NSUTF8StringEncoding]];
    __block NSString *encRRn2 = [omniDoc EncryptParams:[NSData dataWithBytes:ssno2 length:strlen(ssno2)]];
    __block NSString *encPass = [omniDoc EncryptParams:[NSData dataWithBytes:pass length:strlen(pass)]];
    
    if ([self checkRRN:signCert SignPri:signPri rrn1:encRRn1 rrn2:encRRn2 pass:encPass]) {
        __block NSString *name = [param objectForKey:@"name"];
        
        NSArray *types = [param objectForKey:@"reportType"];
        
        NSString *beforeDate_1 = [param objectForKey:@"beforeDate_1"];
        NSString *beforeDate_2 = [param objectForKey:@"beforeDate_2"];
        
        for(NSString *type in types){
            if ([type isEqualToString:@"101"]) {
                //건강보험 납부확인서
                [self->omniDoc CertRequestStructSet:self->handle count:self->count type:FH_NHIS_NABBU option1:@"Y" option2:(NSString *)FH_NHIS_USAGE_CHECK option3:@"1" option4:nil option5:nil option6:beforeDate_1 option7:@"00" option8:nil option9:nil option10:nil language:nil];
            }
            else if ([type isEqualToString:@"102"]) {
                //건강보험 자격득실확인서
                [self->omniDoc CertRequestStructSet:self->handle count:self->count type:FH_NHIS_JAGEOK option1:@"Y" option2:(NSString *)FH_NHIS_JAGEOK_ALL option3:nil option4:@"N" option5:nil option6:nil option7:nil option8:nil option9:nil option10:nil language:nil];
            }
            else if ([type isEqualToString:@"211"]) {
                if (scrappingErrCd == -1) {
                    //국세청 소득금액증명원 종합소득신고자
                    [self->omniDoc CertRequestStructSet:self->handle count:self->count type:FH_NTS_SODEUK_JONGHAP option1:nil option2:(NSString *)FH_NTS_USAGE_LOAN option3:(NSString *)FH_NTS_SUBMIT_GUMYOONG option4:@"N" option5:@"Y" option6:@"Y" option7:beforeDate_2 option8:nil option9:nil option10:nil language:nil];
                }else{
                    //국세청 소득금액증명원 봉급생활자
                    [self->omniDoc CertRequestStructSet:self->handle count:self->count type:FH_NTS_SODEUK_BONGGUP option1:nil option2:(NSString *)FH_NTS_USAGE_LOAN option3:(NSString *)FH_NTS_SUBMIT_GUMYOONG option4:@"N" option5:@"Y" option6:@"Y" option7:beforeDate_2 option8:nil option9:nil option10:nil language:nil];
                }
            }
            else if ([type isEqualToString:@"212"]) {
                if (scrappingErrCd == -1) {
                    //국세청 소득금액증명원 종합소득신고자
                    [self->omniDoc CertRequestStructSet:self->handle count:self->count type:FH_NTS_SODEUK_JONGHAP option1:nil option2:(NSString *)FH_NTS_USAGE_LOAN option3:(NSString *)FH_NTS_SUBMIT_GUMYOONG option4:@"N" option5:@"Y" option6:@"Y" option7:beforeDate_2 option8:nil option9:nil option10:nil language:nil];
                }else{
                    //국세청 소득금액증명원 사업소득자
                    [self->omniDoc CertRequestStructSet:self->handle count:self->count type:FH_NTS_SODEUK_SAUP option1:nil option2:(NSString *)FH_NTS_USAGE_LOAN option3:(NSString *)FH_NTS_SUBMIT_GUMYOONG option4:@"N" option5:@"Y" option6:@"Y" option7:beforeDate_2 option8:nil option9:nil option10:nil language:nil];
                }
            }
            else if ([type isEqualToString:@"221"]) {
                //국세청 사업자등록증명원
                NSString *businessNum = [param objectForKey:@"businessNum"];
                [self->omniDoc CertRequestStructSet:self->handle count:self->count type:FH_NTS_SAUPJA option1:businessNum option2:(NSString *)FH_NTS_USAGE_LOAN option3:(NSString *)FH_NTS_SUBMIT_GUMYOONG option4:@"N" option5:@"Y" option6:@"Y" option7:nil option8:nil option9:nil option10:nil language:nil];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [GifProgress showGifWithName:gifType_jump completion:nil];
                self->issueRes = [self->omniDoc CertIssue:signCert keyData:signPri password:encPass name:name rrn1:encRRn1 rrn2:encRRn2 count:self->count handle:self->handle progress:self->progress stop:self->stop];
                
                encRRn1 = nil;
                encRRn2 = nil;
                encPass = nil;
            });
        });
        [self updateProgress:param];
    }
}
@end
