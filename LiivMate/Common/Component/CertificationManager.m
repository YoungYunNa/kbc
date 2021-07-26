//
//  CertificationManager.m
//  LiivMate
//
//  Created by kbcard-macpro-a on 2019. 3. 12..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "CertificationManager.h"
#import "PwdCertViewController.h"
#import "MobileWeb.h"

@implementation CertificationManager
{
    NSData *pkcs12Data; //인증서 가져오기시 인증서 정보를 담는다
}
@synthesize certManagerFinish;


+ (CertificationManager *)shared {
    static CertificationManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self == [super init]) {
        failCnt = 0;
    }
    return self;
}

#pragma mark - 인증서 가져오기(인증번호 입력)
- (void)getCertWizvera:(NSString *)authCode completion:(CertManagerFinish)completion{
    certManagerFinish = completion;
    
    WizveraCertMove* wizveraCertMove = [WizveraCertMove create:WizveraAPI];
    WizveraCertMoveResult* wcmResult = [wizveraCertMove requestPKCS12:authCode];
    
    [IndicatorView hide];
    
    if(wcmResult.errorCode==WCME_Success){
        
        pkcs12Data = wcmResult.pkcs12;
        
        [self openSecureKeyboard:^(char * _Nonnull plainText, BOOL isCancel) {
            if (!isCancel) {
                [self saveCert:plainText];
            }else{
                //사용자 취소(보안 키패드 입력 취소, 닫기 시)
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"9004", @"rsltCode",
                                     @"", @"massage",
                                     @"7", @"linkType",
                                     nil];
                self->certManagerFinish(dic, NO);
            }
        }];
        
    }
    else {
        //나머지 에러
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%d", wcmResult.errorCode], @"rsltCode",
                             @"", @"massage",
                             @"2", @"linkType",
                             nil];
        certManagerFinish(dic, NO);
    }
}

- (void)getCertWizvera:(NSDictionary *)info authCode:(NSString *)authCode completion:(CertManagerFinish)completion{
    certManagerFinish = completion;
    
    WizveraCertMove* wizveraCertMove = [WizveraCertMove create:WizveraAPI];
    WizveraCertMoveResult* wcmResult = [wizveraCertMove requestPKCS12:authCode];
    
    [IndicatorView hide];
    
    if(wcmResult.errorCode==WCME_Success){
        
        pkcs12Data = wcmResult.pkcs12;
        
        [self openSecureKeyboard:info completion:^(char * _Nonnull plainText, BOOL isCancel) {
            if (!isCancel) {
                [self saveCert:plainText];
            }else{
                //사용자 취소(보안 키패드 입력 취소, 닫기 시)
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"9004", @"rsltCode",
                                     @"", @"massage",
                                     @"7", @"linkType",
                                     nil];
                self->certManagerFinish(dic, NO);
            }
        }];
    }
    else {
        //나머지 에러
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%d", wcmResult.errorCode], @"rsltCode",
                             @"", @"massage",
                             @"2", @"linkType",
                             nil];
        certManagerFinish(dic, NO);
    }
    
}

#pragma mark - 공인인증서 보안키패드 호출
- (void)openSecureKeyboard:(void (^ __nullable)(char *plainText, BOOL isCancel))completion {
    
    [PwdWrapper showCertPwd:^(id  _Nonnull vc) {
        
        [PwdWrapper setKeyPadTypeCert:vc];
        
    } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
        if (!isCancel) {
            PwdCertViewController *pwdVc = (PwdCertViewController *)vc;
            [pwdVc.raonTf getPlainText:^(char *plain) {
                completion(plain, NO);
            }];
        }else {
            completion(nil, YES);
        }
    }];
}

- (void)openSecureKeyboard:(NSDictionary *)info completion:(void (^ __nullable)(char *plainText, BOOL isCancel))completion {
    
    NSString * title = [info null_valueForKey:@"title"];
    
    [PwdWrapper showCertPwd:^(id  _Nonnull vc) {
        
        [PwdWrapper setKeyPadTypeCert:vc];
        
        if (!nilCheck(title)) {
            [PwdWrapper setTitle:vc value:title];
        }
    } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
        if (!isCancel) {
            PwdCertViewController *pwdVc = (PwdCertViewController *)vc;
            [pwdVc.raonTf getPlainText:^(char *plain) {
                completion(plain, NO);
            }];
        }else {
            completion(nil, YES);
        }
    }];
}

#pragma mark - 인증서 읽어오기
- (void)loadCertifiCation:(CertItem * _Nonnull)certItem pass:(char * _Nonnull)plainText completion:(CertManagerFinish)completion {
    
    certManagerFinish = completion;
    
    CERTIFICATE cert;
    IW_RETURN iw_ret = IW_CERTIFICATE_Create(&cert);
    if (iw_ret != IW_SUCCESS) {
        //error
        [self issacError:iw_ret];
        return;
    }
    
    PRIVATEKEY pkey;
    iw_ret = IW_PRIVATEKEY_Create(&pkey);
    if (iw_ret != IW_SUCCESS) {
        //error
        [self issacError:iw_ret];
        return;
    }
    
    // 아래 password에 넘어갈 인자값이 char* 형태로 내용을 지울 수 있는 데이터 유형이어야함.
    NSString *plainPwd = [[NSString alloc] initWithBytesNoCopy:plainText length:strlen(plainText) encoding:NSUTF8StringEncoding freeWhenDone:NO];
    
    IssacKeychainHandler *hIKC = [[IssacKeychainHandler alloc] initWithAccessGroup:@"GTW76X9FPW.com.kbcard.*"];
//    iw_ret = [hIKC loadCertItem:certItem certificate:&cert privateKey:&pkey pin:[NSString stringWithCString:plainText encoding:NSUTF8StringEncoding]];
    iw_ret = [hIKC loadCertItem:certItem certificate:&cert privateKey:&pkey pin:plainPwd]; // 메모리에 남을 가능성이 있는 코드로 (SASSecurData 가이드 적용 )
    
    if(iw_ret != IW_SUCCESS)
    {
        //error
        [self issacError:iw_ret];
        return;
    }
    char certBuff[4096];    //2048 -> 4096 변경 : 범용인증서 로드시 길이부족 에러남
    iw_ret = IW_CERTIFICATE_Write(certBuff, sizeof(certBuff), &cert);
    if(iw_ret != IW_SUCCESS) {
        //error
        [self issacError:iw_ret];
        return;
    }
    
    NSString *certBuffStr = [NSString stringWithCString:certBuff encoding:NSASCIIStringEncoding];
    NSData *certBase64 = [self dataFromBase64String:certBuffStr];
    
    char keyBuff[2048];
    
    iw_ret = IW_PRIVATEKEY_Write(keyBuff, sizeof(keyBuff), &pkey, plainText, 0);
    
    if(iw_ret != IW_SUCCESS) {
        //error
        [self issacError:iw_ret];
        return;
    }
    
    NSString *keyBuffStr = [NSString stringWithCString:keyBuff encoding:NSASCIIStringEncoding];
    NSData *keyBase64 = [self dataFromBase64String:keyBuffStr];
    
    WizveraPKCS12* pkcs12Util = [[WizveraPKCS12 alloc] init];
    WizveraPKCS12ErrorCode rc;
    pkcs12Util.signCert = certBase64;
    pkcs12Util.signPri = keyBase64;
    rc = [pkcs12Util create:[NSString stringWithCString:plainText encoding:NSUTF8StringEncoding] priKeyType:WPKT_EncPriKeyInfo];
    
    if(rc != WP12E_Success){
        //error
        [self wizveraError:iw_ret];
        return;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         certBase64, @"signCert",
                         keyBase64, @"signPri",
                         nil];
    certManagerFinish(dic, YES); //성공
}

#pragma mark - 선택된 인증서 가져오기(키체인)
- (CertItem * _Nullable)getCertItem:(NSDictionary * _Nonnull)param {
    NSArray *certList = [self getCertificationList];
    
    NSString *subject = [param objectForKey:@"subject"];
    NSString *expiryDate = [param objectForKey:@"expiryDate"];
    
    CertItem *certItem = nil;
    for(CertItem *item in certList){
        if ([item.strSubjectDN isEqualToString:subject] && [item.strExpireDate isEqualToString:expiryDate]) {
            certItem = item;
            break;
        }
    }
    return certItem;
}

#pragma mark - 인증서 저장하기(키체인)
- (void)saveCert:(char *)plainText{
    
    NSString *base64PFX_wiz = [self base64EncodedString:pkcs12Data];
    
    CERTIFICATE cert;
    IW_RETURN iw_ret = IW_CERTIFICATE_Create(&cert);
    if (iw_ret != IW_SUCCESS) {
        //error
        [self issacError:iw_ret];
        return;
    }
    EPRIVATEKEY epkey;
    iw_ret = IW_EPRIVATEKEY_Create(&epkey);
    if (iw_ret != IW_SUCCESS) {
        //error
        [self issacError:iw_ret];
        return;
    }
    PRIVATEKEY pkey;
    iw_ret = IW_PRIVATEKEY_Create(&pkey);
    if (iw_ret != IW_SUCCESS) {
        //error
        [self issacError:iw_ret];
        return;
    }
    
    NSData *pData = [self dataFromBase64String:base64PFX_wiz];
    
    WizveraPKCS12 *pkcs12Util = [[WizveraPKCS12 alloc] init];
    
    pkcs12Util.pkcs12 = pData;
    WizveraPKCS12ErrorCode p12InfoParse = [pkcs12Util parse:[NSString stringWithCString:plainText encoding:NSUTF8StringEncoding]];
    if(p12InfoParse != WP12E_Success){
        //error
        [self wizveraError:p12InfoParse];
        return;
    }
    NSData *pri = pkcs12Util.signPri;
    NSData *signCert = pkcs12Util.signCert;
    
    NSString *stringCert = [self base64EncodedString:signCert];
    NSString *stringPri = [self base64EncodedString:pri];
    
    const char *pszEncodedCertificate = [stringCert cStringUsingEncoding:NSUTF8StringEncoding];
    int ret = IW_CERTIFICATE_Read(&cert, pszEncodedCertificate);
    if (ret != IW_SUCCESS) {
        //error
        IW_CERTIFICATE_Delete(&cert);
        [self issacError:ret];
        return;
    }
    
    const char *pszEncodedPrivateKey = [stringPri cStringUsingEncoding:NSUTF8StringEncoding];
    ret = IW_EPRIVATEKEY_Read(&epkey, pszEncodedPrivateKey);
    if (ret != IW_SUCCESS) {
        //error
        IW_EPRIVATEKEY_Delete(&epkey);
        [self issacError:ret];
        return;
    }
    
    ret = IW_PRIVATEKEY_Read_From_EPRIVATEKEY(&pkey, &epkey, plainText);
    if (ret != IW_SUCCESS) {
        IW_PRIVATEKEY_Delete(&pkey);
        [self issacError:ret];
        return;
    }
    
    //저장
    IssacKeychainHandler *hIKC = [[IssacKeychainHandler alloc] initWithAccessGroup:@"GTW76X9FPW.com.kbcard.*"];
    
    char certInfoBuff[4096*2]={0};
    ret = IW_CERTIFICATE_GetInfo(&cert, IW_SUBJECT_NAME, certInfoBuff, sizeof(certInfoBuff));
    
    if(ret != IW_SUCCESS)
    {
        //error
        [self issacError:ret];
        return;
    }
    
    NSString *subject = [NSString stringWithCString:certInfoBuff encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_KR)];
    
    CertItem *item = nil;
    
    
    NSMutableArray *certList = [[NSMutableArray alloc] init];
    ret = [hIKC getCertificateList:certList];
    if(ret == IW_SUCCESS)
    {
        for(CertItem *certItem in certList)
        {
            NSString *sub = [certItem strSubjectDN];
            
            if([subject isEqualToString:sub])
            {
                item = certItem;
            }
        }
    }else {
        //error
        [self issacError:ret];
        return;
    }
    
    ret = [hIKC saveCertItem:item certificate:&cert privateKey:&pkey pin:[NSString stringWithCString:plainText encoding:NSUTF8StringEncoding]];
    if(ret != IW_SUCCESS)
    {
        //error
        [self issacError:ret];
        return;
    }
    certManagerFinish(nil, YES);//성공
}

#pragma mark - 저장된 인증서 리스트 가져오기(키체인)
- (NSArray<CertItem *> *)getCertificationList {
    NSMutableArray *certList = [[NSMutableArray alloc] init];
    
    IssacKeychainHandler *hIKC = [[IssacKeychainHandler alloc] initWithAccessGroup:@"GTW76X9FPW.com.kbcard.*"];
    NSMutableArray *certItems = [[NSMutableArray alloc] init];
    NSInteger ret;
    ret = [hIKC getCertificateList:certItems];
    if(ret == IW_SUCCESS)
    {
        for(CertItem *certItem in certItems)
        {
            CERTIFICATE cert;
            IW_RETURN iw_ret = IW_CERTIFICATE_Create(&cert);
            if (iw_ret != IW_SUCCESS) {
                //error
            }
            int ret = [hIKC loadCertItem:certItem certificate:&cert privateKey:nil pin:nil];
            if(ret == IW_SUCCESS)
            {
                [certList addObject:certItem];
            }
        }
    }
    return certList;
}

- (NSArray<NSDictionary *> *)getCertificationList2 {
    NSMutableArray *certList = [[NSMutableArray alloc] init];
    
    IssacKeychainHandler *hIKC = [[IssacKeychainHandler alloc] initWithAccessGroup:@"GTW76X9FPW.com.kbcard.*"];
    NSMutableArray *certItems = [[NSMutableArray alloc] init];
    NSInteger ret;
    ret = [hIKC getCertificateList:certItems];
    if(ret == IW_SUCCESS)
    {
        for(CertItem *certItem in certItems)
        {
            CERTIFICATE cert;
            IW_RETURN iw_ret = IW_CERTIFICATE_Create(&cert);
            if (iw_ret != IW_SUCCESS) {
                //error
            }
            int ret = [hIKC loadCertItem:certItem certificate:&cert privateKey:nil pin:nil];
            if(ret == IW_SUCCESS)
            {
                char certInfoBuff[4096*2]={0};
                ret = IW_CERTIFICATE_GetInfo(&cert, IW_CERT_POLICY, certInfoBuff, sizeof(certInfoBuff));
                if(ret != IW_SUCCESS)
                {
                    //error
                }
                NSString *policy = [NSString stringWithFormat:@"%s",certInfoBuff];
                policy = [policy componentsSeparatedByString:@"Policy Identifier = "][1];
                policy = [policy componentsSeparatedByString:@"\n"][0];
                
                
                NSDictionary *certDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         certItem.strSubjectDN, @"subject",
                                         certItem.strIssuerDN, @"issuer",
                                         certItem.strExpireDate, @"expiryDate",
                                         certItem.strSerial, @"serialNo",
                                         policy, @"policy",
                                         @"", @"keyPath",
                                         nil];
                [certList addObject:certDic];
            }
        }
    }
    return certList;
}

#pragma mark - 인증서 PW 검증
- (BOOL)verifyPassword:(NSString*)subjectID certPassword:(char*)plainText{
    NSArray *certList = [self getCertificationList];
    
    NSString *subject = subjectID;
    
    CertItem *certItem;
    for(CertItem *item in certList){
        if ([item.strSubjectDN isEqualToString:subject]) {
            certItem = item;
            break;
        }
    }
    
    return YES;
}

#pragma mark - 인증서 삭제
- (void)deleteCertification:(NSDictionary *)param completion:(CertManagerFinish)completion{
    
    certManagerFinish = completion;
    
    CertItem *certItem = [self getCertItem:param];
    IssacKeychainHandler *hIKC = [[IssacKeychainHandler alloc] initWithAccessGroup:@"GTW76X9FPW.com.kbcard.*"];
    
    int ret = [hIKC deleteCertItem:certItem];;
    
    if (ret == IW_SUCCESS) {
        certManagerFinish(nil, YES);
    }else {
        //error
        [self issacError:ret];
    }
}

#pragma mark - 리브메이트 3.0 자산연동 키패드
- (void)openSecureRaonKeyboard:(void (^ __nullable)(char *plainText, BOOL isCancel))completion title:(NSString *)title
{
    [PwdWrapper showCertPwd:^(id  _Nonnull vc) {
        
        [PwdWrapper setKeyPadTypeCert:vc];
        [PwdWrapper setTitle:vc value:title];       // 타이틀 + 설명
        
    } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
        if (!isCancel) {
            PwdCertViewController *pwdVc = (PwdCertViewController *)vc;
            [pwdVc.raonTf getPlainText:^(char *plain) {
                completion(plain, NO);
            }];
        }else {
            completion(nil, YES);
        }
    }];
}

#pragma mark - 자산연동 인증서 검증
- (NSMutableDictionary *)getCertVerify:(NSString *)subject epiryData:(NSString *)epiryData planText: (char * _Nonnull) plainText
{
    NSString *msg = @"";
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"Y", @"isCertVerify", msg, @"msg", nil];

    NSArray *certList = [self getCertificationList];

    CertItem *certItem;
    for(CertItem *item in certList){
        if ([item.strSubjectDN isEqualToString:subject] && [item.strExpireDate isEqualToString:epiryData]) {
            certItem = item;
            break;
        }
    }

    CERTIFICATE cert;
    IW_RETURN iw_ret = IW_CERTIFICATE_Create(&cert);
    if (iw_ret != IW_SUCCESS) {
        //error
        msg = [self issacVerifyError:iw_ret];
        [resultDic setValue:msg forKey:@"msg"];
        [resultDic setValue:@"N" forKey:@"isCertVerify"];
    }

    PRIVATEKEY pkey;
    iw_ret = IW_PRIVATEKEY_Create(&pkey);
    if (iw_ret != IW_SUCCESS) {
        //error
        msg = [self issacVerifyError:iw_ret];
        [resultDic setValue:msg forKey:@"msg"];
        [resultDic setValue:@"N" forKey:@"isCertVerify"];
    }

    IssacKeychainHandler *hIKC = [[IssacKeychainHandler alloc] initWithAccessGroup:@"GTW76X9FPW.com.kbcard.*"];
    
    // 메모리에 남을 가능성이 있는 코드로 (SASSecurData 가이드 적용 )
//    iw_ret = [hIKC loadCertItem:certItem certificate:&cert privateKey:&pkey pin:[NSString stringWithCString:plainText encoding:NSUTF8StringEncoding]];
    NSString *refStr = [[NSString alloc] initWithBytesNoCopy:plainText length:strlen(plainText) encoding:NSUTF8StringEncoding freeWhenDone:NO];
    iw_ret = [hIKC loadCertItem:certItem certificate:&cert privateKey:&pkey pin:refStr]; // isas keychain에서 인증서를 로드 할 때 NSStrint 형식으로 보내고 있어서 메모리에 남을 수 있는 경우의 수가 생김

    if(iw_ret != IW_SUCCESS)
    {
        //error
        msg = [self issacVerifyError:iw_ret];
        [resultDic setValue:msg forKey:@"msg"];
        [resultDic setValue:@"N" forKey:@"isCertVerify"];
    }
    char certBuff[4096];    //2048 -> 4096 변경 : 범용인증서 로드시 길이부족 에러남
    iw_ret = IW_CERTIFICATE_Write(certBuff, sizeof(certBuff), &cert);
    if(iw_ret != IW_SUCCESS) {
        //error
        msg = [self issacVerifyError:iw_ret];
        [resultDic setValue:msg forKey:@"msg"];
        [resultDic setValue:@"N" forKey:@"isCertVerify"];
    }

    return resultDic;
}

#pragma mark - 펜타 모듈 검증 에러코드 (issac=
- (NSString *)issacVerifyError:(IW_RETURN)ret {
    
    NSString *msg = @"";
    
    switch (ret) {
        case IW_SUCCESS:
            //성공
            break;
            
        case IW_ERR_INVALID_CERTIFICATE:
            msg = @"인증서가 유효하지 않습니다.";
            break;
            
        case IW_ERR_INVALID_PRIVATEKEY:
            msg = @"비밀번호가 유효하지 않습니다.";
            break;
            
        case IW_ERR_INVALID_INPUT:
            msg = @"입력값이 유효하지 않습니다.";
            break;
            
        case IW_ERR_FAIL_TO_GET_RANDNUM:
            msg = @"랜덤값 가져오기를 실패했습니다.";
            break;
            
        case IW_ERR_FAIL_TO_VERIFY_VID:
            msg = @"VID 검증을 실패했습니다.";
            break;
            
        case IW_ERR_BASE64_DECODE_FAIL:
            msg = @"base64 디코딩을 실패했습니다.";
            break;
            
        case IW_ERR_BASE64_ENCODE_FAIL:
            msg = @"base64 인코딩을 실패했습니다.";
            break;
            
        case IW_ERR_CERTIFICATE_READ_FAIL:
            msg = @"인증서 읽기를 실패했습니다.";
            break;
            
        case IW_ERR_INVALID_DATA:
            msg = @"데이터가 유효하지 않습니다.";
            break;
            
        case IW_ERR_WRONG_PIN:
            msg = @"옳바르지 않은 비밀번호 입니다.";
            break;
            
        case IW_ERR_CANNOT_MAKE_SIGNEDDATA:
            msg = @"서명 된 데이터를 만들지 않았습니다.";
            break;
            
        case IW_ERR_CANNOT_WRITE_FILE:
            msg = @"파일을 쓰지 않았습니다.";
            break;
            
        case IW_ERR_INSUFFICIENT_ALLOC_LEN:
            msg = @"할당된 길이가 부족합니다.";
            break;
            
        case IW_ERR_CANNOT_ENCRYPT_PRIVATEKEY:
            msg = @"개인키를 암호화하지 않았습니다.";
            break;
            
        case IW_ERR_INVALID_ALGORITHM:
            msg = @"유효하지 않은 알고리즘 입니다.";
            break;
            
        case IW_ERR_CANNOT_READ_FILE:
            msg = @"파일을 읽지 않았습니다.";
            break;
            
        case IW_ERR_ENCRYPT_FAIL:
            msg = @"암호화에 실패하였습니다.";
            break;
            
        case IW_ERR_DECRYPT_FAIL:
            msg = @"복호화에 실패하였습니다.";
            break;
            
        case IW_ERR_PRIVATEKEY_MISMATCH:
            msg = @"개인키가 일치하지 않습니다.";
            break;
            
        case IW_ERR_INVALID_SIGNATURE_FORMAT:
            msg = @"유효하지 않은 서명포멧 입니다.";
            break;
            
        case IW_ERR_VERIFYSIGNATURE_FAILURE:
            msg = @"서명값 인증에 실패하였습니다.";
            break;
            
        case IW_ERR_INPUTDATA_TOOSHORT_OR_TOOLONG:
            msg = @"입력 데이터의 길이가 옳바르지 않습니다.";
            break;
            
        case IW_ERR_PUBKEY_DECODE_FAIL:
            msg = @"공개키 복호화에 실패하였습니다.";
            break;
            
        case IW_ERR_INVALID_PUBKEY:
            msg = @"유효하지 않은 공개키 입니다.";
            break;
            
        case IW_ERR_PUB_FAIL_TO_ENC_MSG:
            msg = @"암호화 메세지 생성에 실패하였습니다.";
            break;
            
        case IW_ERR_PUB_FAIL_TO_DEC_MSG:
            msg = @"복호화 메세지 생성에 실패하였습니다.";
            break;
            
        case IW_ERR_LICENSE_EXPIRED:
            msg = @"라이센스가 만료되었습니다.";
            break;
            
        case IW_ERR_LICENSE_INVALID_CERT:
            msg = @"유효하지 않은 라이센스 인증서 입니다.";
            break;
            
        case IW_ERR_LICENSE_INVALID_IP:
            msg = @"유효하지 않은 라이센스 IP입니다.";
            break;
            
        case IW_ERR_LICENSE_INVALID_TYPE:
            msg = @"유효하지 않은 라이센스 타입입니다.";
            break;
            
        case IW_ERR_LICENSE_CANNOT_LOAD_CERT:
            msg = @"라이센스 인증서를 로드하지 않았습니다.";
            break;
            
        case IW_ERR_LICENSE_CANNOT_LOAD_CACERT:
            msg = @"라이센스 CA인증서를 로드하지 않았습니다.";
            break;
            
        case IW_ERR_WRONG_PIN_PFX:
            msg = @"옳바르지 않은 PFX PIN 입니다.";
            break;
            
        case IW_ERR_CANNOT_CREATE_PFX:
            msg = @"PFX를 생성하지 않았습니다.";
            break;
            
        case IW_ERR_CANNOT_MAKE_RESPONSE:
            msg = @"응답을 만들지 않았습니다.";
            break;
            
        case IW_ERR_MEMORY_ALLOCATION:
            msg = @"메모리 할당에 실패하였습니다.";
            break;
            
        default:
            break;
    }
    
    return msg;
}

#pragma mark - 펜타 모듈 에러코드
- (void)issacError:(IW_RETURN)ret {
    
    NSString *msg = @"";
    
    switch (ret) {
        case IW_SUCCESS:
            //성공
            break;
            
        case IW_ERR_INVALID_CERTIFICATE:
            msg = @"인증서가 유효하지 않습니다.";
            break;
            
        case IW_ERR_INVALID_PRIVATEKEY:
            msg = @"비밀번호가 유효하지 않습니다.";
            break;
            
        case IW_ERR_INVALID_INPUT:
            msg = @"입력값이 유효하지 않습니다.";
            break;
            
        case IW_ERR_FAIL_TO_GET_RANDNUM:
            msg = @"랜덤값 가져오기를 실패했습니다.";
            break;
            
        case IW_ERR_FAIL_TO_VERIFY_VID:
            msg = @"VID 검증을 실패했습니다.";
            break;
            
        case IW_ERR_BASE64_DECODE_FAIL:
            msg = @"base64 디코딩을 실패했습니다.";
            break;
            
        case IW_ERR_BASE64_ENCODE_FAIL:
            msg = @"base64 인코딩을 실패했습니다.";
            break;
            
        case IW_ERR_CERTIFICATE_READ_FAIL:
            msg = @"인증서 읽기를 실패했습니다.";
            break;
            
        case IW_ERR_INVALID_DATA:
            msg = @"데이터가 유효하지 않습니다.";
            break;
            
        case IW_ERR_WRONG_PIN:
            msg = @"옳바르지 않은 비밀번호 입니다.";
            break;
            
        case IW_ERR_CANNOT_MAKE_SIGNEDDATA:
            msg = @"서명 된 데이터를 만들지 않았습니다.";
            break;
            
        case IW_ERR_CANNOT_WRITE_FILE:
            msg = @"파일을 쓰지 않았습니다.";
            break;
            
        case IW_ERR_INSUFFICIENT_ALLOC_LEN:
            msg = @"할당된 길이가 부족합니다.";
            break;
            
        case IW_ERR_CANNOT_ENCRYPT_PRIVATEKEY:
            msg = @"개인키를 암호화하지 않았습니다.";
            break;
            
        case IW_ERR_INVALID_ALGORITHM:
            msg = @"유효하지 않은 알고리즘 입니다.";
            break;
            
        case IW_ERR_CANNOT_READ_FILE:
            msg = @"파일을 읽지 않았습니다.";
            break;
            
        case IW_ERR_ENCRYPT_FAIL:
            msg = @"암호화에 실패하였습니다.";
            break;
            
        case IW_ERR_DECRYPT_FAIL:
            msg = @"복호화에 실패하였습니다.";
            break;
            
        case IW_ERR_PRIVATEKEY_MISMATCH:
            msg = @"개인키가 일치하지 않습니다.";
            break;
            
        case IW_ERR_INVALID_SIGNATURE_FORMAT:
            msg = @"유효하지 않은 서명포멧 입니다.";
            break;
            
        case IW_ERR_VERIFYSIGNATURE_FAILURE:
            msg = @"서명값 인증에 실패하였습니다.";
            break;
            
        case IW_ERR_INPUTDATA_TOOSHORT_OR_TOOLONG:
            msg = @"입력 데이터의 길이가 옳바르지 않습니다.";
            break;
            
        case IW_ERR_PUBKEY_DECODE_FAIL:
            msg = @"공개키 복호화에 실패하였습니다.";
            break;
            
        case IW_ERR_INVALID_PUBKEY:
            msg = @"유효하지 않은 공개키 입니다.";
            break;
            
        case IW_ERR_PUB_FAIL_TO_ENC_MSG:
            msg = @"암호화 메세지 생성에 실패하였습니다.";
            break;
            
        case IW_ERR_PUB_FAIL_TO_DEC_MSG:
            msg = @"복호화 메세지 생성에 실패하였습니다.";
            break;
            
        case IW_ERR_LICENSE_EXPIRED:
            msg = @"라이센스가 만료되었습니다.";
            break;
            
        case IW_ERR_LICENSE_INVALID_CERT:
            msg = @"유효하지 않은 라이센스 인증서 입니다.";
            break;
            
        case IW_ERR_LICENSE_INVALID_IP:
            msg = @"유효하지 않은 라이센스 IP입니다.";
            break;
            
        case IW_ERR_LICENSE_INVALID_TYPE:
            msg = @"유효하지 않은 라이센스 타입입니다.";
            break;
            
        case IW_ERR_LICENSE_CANNOT_LOAD_CERT:
            msg = @"라이센스 인증서를 로드하지 않았습니다.";
            break;
            
        case IW_ERR_LICENSE_CANNOT_LOAD_CACERT:
            msg = @"라이센스 CA인증서를 로드하지 않았습니다.";
            break;
            
        case IW_ERR_WRONG_PIN_PFX:
            msg = @"옳바르지 않은 PFX PIN 입니다.";
            break;
            
        case IW_ERR_CANNOT_CREATE_PFX:
            msg = @"PFX를 생성하지 않았습니다.";
            break;
            
        case IW_ERR_CANNOT_MAKE_RESPONSE:
            msg = @"응답을 만들지 않았습니다.";
            break;
            
        case IW_ERR_MEMORY_ALLOCATION:
            msg = @"메모리 할당에 실패하였습니다.";
            break;
            
        default:
            break;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSString stringWithFormat:@"%d", ret], @"rsltCode",
                         @"", @"massage",
                         @"3", @"linkType",
                         nil];
    if (certManagerFinish) {
        certManagerFinish(dic, NO);
    }
}

#pragma mark - 위즈베라 모듈 에러코드
- (void)wizveraError:(WizveraPKCS12ErrorCode)ret {
    NSString *msg = @"";
    switch (ret) {
        case WP12E_Success:
            //성공
            break;
            
        case WP12E_Error:
            msg = @"PKCS12 에러.";
            break;
            
        case WP12E_InvalidPassword:
            msg = @"유효하지 않은 비밀번호 입니다.";
            break;
            
        case WP12E_IncorrectPassword:
            msg = @"옳바르지 않은 비밀번호 입니다.";
            break;
            
        case WP12E_InvalidSignCert:
            msg = @"SingCert 데이터가 유효하지 않습니다.";
            break;
            
        case WP12E_InvalidSignPri:
            msg = @"SingPri 데이터가 유효하지 않습니다.";
            break;
            
        case WP12E_InvalidKmCert:
            msg = @"KmCert 데이터가 유효하지 않습니다.";
            break;
            
        case WP12E_InvalidKmPri:
            msg = @"KmPri 데이터가 유효하지 않습니다.";
            break;
            
        case WP12E_CreatePKCS12Fail:
            msg = @"PKCS12 생성에 실패하였습니다.";
            break;
            
        case WP12E_InvalidPKCS12:
            msg = @"PKCS12 데이터가 유효하지 않습니다.";
            break;
            
        case WP12E_NotContainSignCert:
            msg = @"PKCS12 데이터가 포함되어있지 않습니다.";
            break;
            
        case WP12E_MallocFail:
            msg = @"메모리 할당에 실패하였습니다.";
            break;
            
        case WP12E_InsufficientBuffer:
            msg = @"메모리가 부족합니다.";
            break;
            
        default:
            break;
    }
    if (ret == WP12E_IncorrectPassword || ret == WP12E_InvalidPassword) {
        failCnt++;
    }
    if(failCnt == 5){
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"9002", @"rsltCode",
                             @"", @"message",
                             @"7", @"linkType",
                             nil];
        
        if (certManagerFinish) {
            certManagerFinish(dic, NO);
        }
        failCnt = 0;
        return ;
    }
    else {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%d", ret], @"rsltCode",
                             @"", @"massage",
                             @"2", @"linkType",
                             nil];
        if (certManagerFinish) {
            certManagerFinish(dic, NO);
        }
    }
}

#pragma mark - 인증서용 base64 인코딩 디코딩
- (NSData *)dataFromBase64String:(NSString *)aString
{
    NSData *data = [aString dataUsingEncoding:NSASCIIStringEncoding];
    size_t outputLength;
    void *outputBuffer = NewBase64Decode([data bytes], [data length], &outputLength);
    NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
    free(outputBuffer);
    return result;
}

#define xx 65
static unsigned char base64DecodeLookup[256] =
{
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, xx, xx, xx,
    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx,
    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
};
#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4

void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength)
{
    if (length == -1)
    {
        length = strlen(inputBuffer);
    }
    
    size_t outputBufferSize =
    ((length+BASE64_UNIT_SIZE-1) / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
    unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
    
    size_t i = 0;
    size_t j = 0;
    while (i < length)
    {
        //
        // Accumulate 4 valid characters (ignore everything else)
        //
        unsigned char accumulated[BASE64_UNIT_SIZE];
        memset(accumulated, 0, sizeof(accumulated));
        size_t accumulateIndex = 0;
        while (i < length)
        {
            unsigned char decode = base64DecodeLookup[inputBuffer[i++]];
            if (decode != xx)
            {
                accumulated[accumulateIndex] = decode;
                accumulateIndex++;
                
                if (accumulateIndex == BASE64_UNIT_SIZE)
                {
                    break;
                }
            }
        }
        
        //
        // Store the 6 bits from each of the 4 characters as 3 bytes
        //
        outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
        outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);
        outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
        j += accumulateIndex - 1;
    }
    
    if (outputLength)
    {
        *outputLength = j;
    }
    return outputBuffer;
}
- (NSString *)base64EncodedString:(NSData *)data
{
    //size_t outputLength;
    size_t outputLength = 0;
    char *outputBuffer = NewBase64Encode([data bytes], [data length], true, &outputLength);
    
    NSString *result = [[NSString alloc] initWithBytes:outputBuffer length:outputLength encoding:NSASCIIStringEncoding];
    free(outputBuffer);
    return result;
}
static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
char *NewBase64Encode(
                      const void *buffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength)
{
    const unsigned char *inputBuffer = (const unsigned char *)buffer;
    
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
    
    //
    // Byte accurate calculation of final buffer size
    //
    size_t outputBufferSize =
    ((length / BINARY_UNIT_SIZE)
     + ((length % BINARY_UNIT_SIZE) ? 1 : 0))
    * BASE64_UNIT_SIZE;
    if (separateLines)
    {
        outputBufferSize +=
        (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
    }
    
    //
    // Include space for a terminating zero
    //
    outputBufferSize += 1;
    
    //
    // Allocate the output buffer
    //
    char *outputBuffer = (char *)malloc(outputBufferSize);
    if (!outputBuffer)
    {
        return NULL;
    }
    
    size_t i = 0;
    size_t j = 0;
    const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
    size_t lineEnd = lineLength;
    
    while (true)
    {
        if (lineEnd > length)
        {
            lineEnd = length;
        }
        
        for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE)
        {
            //
            // Inner loop: turn 48 bytes into 64 base64 characters
            //
            outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                                   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                                                   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
            outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
        }
        
        if (lineEnd == length)
        {
            break;
        }
        
        //
        // Add the newline
        //
        outputBuffer[j++] = '\r';
        outputBuffer[j++] = '\n';
        lineEnd += lineLength;
    }
    
    if (i + 1 < length)
    {
        //
        // Handle the single '=' case
        //
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                               | ((inputBuffer[i + 1] & 0xF0) >> 4)];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
        outputBuffer[j++] =    '=';
    }
    else if (i < length)
    {
        //
        // Handle the double '=' case
        //
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
        outputBuffer[j++] = '=';
        outputBuffer[j++] = '=';
    }
    outputBuffer[j] = 0;
    
    //
    // Set the output length and return the buffer
    //
    if (outputLength)
    {
        *outputLength = j;
    }
    return outputBuffer;
}
@end
