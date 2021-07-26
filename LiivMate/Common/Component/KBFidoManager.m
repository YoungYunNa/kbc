//
//  KBFidoManager.m
//  KBCardCommon
//
//  Created by 조휘준 on 2020/08/06.
//  Copyright © 2020 kbcard. All rights reserved.
//

#import "KBFidoManager.h"

@interface KBFidoManager() {
    Fido *ccFido;
    FidoCompletion complete;
    BiometryType biometryType;
    
    NSString *extData;
//    BOOL isRegAuth; //등록and인증 flag
}

@end

@implementation KBFidoManager

+ (instancetype)sharedInstance {
    
    static KBFidoManager *sInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sInstance = [[KBFidoManager alloc] init];
    });
    
    return sInstance;
}

- (instancetype)init {
    return [super init];
}
 
//MARK: --- init ---
- (void)initFido:(NSArray *)license {
    ccFido = Fido.getInstance;
    
    NSLog(@"License Info : %@", ccFido.getLicenseInfo);
    
    // Set license that issued by 'crosscert'. If you don't have it send 'License Info' to 'Crosscert technical manager'.
    NSString *kDeviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [ccFido setLicense:license uuid:kDeviceUUID];

    USError *error;
    // Lib를 초기화 한다.
    if(![ccFido initFidoLib:&error])
    {
        NSLog(@"------------------초기화 에러---------------");
        NSLog(@"errcode : %ld",(long)[error code]);
        NSLog(@"errMsg : %@",[error description]);
        NSLog(@"-----------------------------------------");
        return;
    }
    else
    {
        NSLog(@"------------------초기화 성공---------------");
        NSLog(@"FIDOFramework Version : %@",[ccFido getVersion]);
    }
    
    //Set whether to verify 'FacetID'.
    //FacetId 검증 건너뛰기 설정
    [ccFido setIsSkipToVerifyFacetID:YES];
    
    if (ccFido.isThisDeviceAniPhone) {
        NSLog(@"This device is iPhone");
    }
    else {
        NSLog(@"This device is NOT iPhone");
    }
    
    switch ([ccFido getBiometryType]) {
        case BIOMETRY_NONE:
            NSLog(@"BIOMETRY_NONE");
            biometryType = BIOMETRY_NONE;
            break;
        case BIOMETRY_TYPE_TOUCHID:
            NSLog(@"BIOMETRY_TYPE_TOUCHID");
            biometryType = BIOMETRY_TYPE_TOUCHID;
            break;
        case BIOMETRY_TYPE_FACEID:
            NSLog(@"BIOMETRY_TYPE_FACEID");
            biometryType = BIOMETRY_TYPE_FACEID;
            break;
        default:
            break;
    }
}

//MARK: --- FIDO Registration ---
/// FIDO등록 함수
/// @param completion  FIDO인증 결과 block (위의 블록 정의 함수 주석 참조)
- (void)registrationFido:(FidoCompletion)completion {
    
    self.isRegAuth = NO;
    
    //setting callback
    complete = completion;
    
    //FIDO REG 여부 체크
//    BOOL isRegistered = [ccFido checkRegistrationToLocal:self.userName isKFido:NOT_K_FIDO serviceName:self.fidoServiceName];
//    if (isRegistered) {
//        NSLog(@"> Already registered.");
//    }
    
    FidoOPType fidoOPType = REQ_REGISTRATION_BY_TOUCHID;
    switch (biometryType) {
        case BIOMETRY_TYPE_TOUCHID:
            fidoOPType = REQ_REGISTRATION_BY_TOUCHID;
            break;
        case BIOMETRY_TYPE_FACEID:
            fidoOPType = REQ_REGISTRATION_BY_FACEID;
            break;
        default:
            break;
    }

    NSDictionary *requestMassage = [ccFido generateRequestMessageForRegistration:fidoOPType
                                                                          userId:self.userName
                                                                         extData:@""
                                                                         isKFido:NOT_K_FIDO
                                                                     serviceName:self.fidoServiceName];
    
    NSLog(@"[requestMassage objectForKey:@REQUEST] : %@", [requestMassage objectForKey:@"REQUEST"]);
    [CCJSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
                                     params:requestMassage
                                 completion:^(NSDictionary *json, CCJSONModelError *err) {
                                    NSLog(@"json : %@", json);
        
                                    if (err) {
                                        ResultMessage *errMessage = [[ResultMessage alloc] init];
                                        errMessage.errorMessage = [err description];
                                        errMessage.errorCode = (int)[err code];
                                        
                                        self->complete(NO, errMessage, err);
                                        return;
                                    }
        
                                    [self showAvailableVerificationList:json
                                                              certIndex:-1
                                                                   cert:nil
                                                             privateKey:nil
                                                               password:nil];
                                 }
    ];
}

/// FIDO등록and인증 함수
/// @param completion  FIDO인증and인증 결과 block (위의 블록 정의 함수 주석 참조)
- (void)regAuthenticationFido:(FidoCompletion)completion {
    
    self.isRegAuth = YES;
    
    //setting callback
    complete = completion;
    
    //FIDO REG 여부 체크
//    BOOL isRegistered = [ccFido checkRegistrationToLocal:self.userName isKFido:NOT_K_FIDO serviceName:self.fidoServiceName];
//    if (isRegistered) {
//        NSLog(@"> Already registered.");
//    }
    
    FidoOPType fidoOPType = REQ_REGISTRATION_BY_TOUCHID;
    switch (biometryType) {
        case BIOMETRY_TYPE_TOUCHID:
            fidoOPType = REQ_REGISTRATION_BY_TOUCHID;
            break;
        case BIOMETRY_TYPE_FACEID:
            fidoOPType = REQ_REGISTRATION_BY_FACEID;
            break;
        default:
            break;
    }

    NSDictionary *requestMassage = [ccFido generateRequestMessageForRegistration:fidoOPType
                                                                          userId:self.userName
                                                                         extData:@""
                                                                         isKFido:NOT_K_FIDO
                                                                     serviceName:self.fidoServiceName];
    
    NSLog(@"[requestMassage objectForKey:@REQUEST] : %@", [requestMassage objectForKey:@"REQUEST"]);
    [CCJSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
                                     params:requestMassage
                                 completion:^(NSDictionary *json, CCJSONModelError *err) {
                                    NSLog(@"json : %@", json);
        
                                    if (err) {
                                        ResultMessage *errMessage = [[ResultMessage alloc] init];
                                        errMessage.errorMessage = [err description];
                                        errMessage.errorCode = (int)[err code];
                                        
                                        self->complete(NO, errMessage, err);
                                        return;
                                    }
        
                                    [self showAvailableVerificationList:json
                                                              certIndex:-1
                                                                   cert:nil
                                                             privateKey:nil
                                                               password:nil];
                                 }
    ];
}

//MARK: --- FIDO DeRegistration ---
/// FIDO해지 함수
/// @param completion  FIDO인증 결과 block (위의 블록 정의 함수 주석 참조)
- (void)deRegistrationFido:(FidoCompletion)completion {
    
    //setting callback
    complete = completion;
    
    NSDictionary *requestMassage = [ccFido generateRequestMessageForDeregistration:REQ_DEREGISTRATION
                                                                            userId:self.userName
                                                                           isKFido:NOT_K_FIDO
                                                                       serviceName:self.fidoServiceName];

    if(requestMassage == nil)
    {
        NSLog(@"requestMessage is nil");
        return;
    }

    [CCJSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
                                      params:requestMassage
                                  completion:^(NSDictionary *json, CCJSONModelError *err) {
                                        NSLog(@"requestMassage res: \n %@", json);
        
                                        if (err) {
                                            ResultMessage *errMessage = [[ResultMessage alloc] init];
                                            errMessage.errorMessage = [err description];
                                            errMessage.errorCode = (int)[err code];
                                            
                                            self->complete(NO, errMessage, err);
                                            return;
                                        }
        
                                        [self->ccFido requestMessageResultParsing:json
                                                                    operationType:REQ_DEREGISTRATION
                                                                          aTarget:self
                                                                 completeSelector:@selector(onResult:)
                                                           registeredTypeCheckSel:nil
                                                              registrationTypeSel:@selector(onResultRegRequestMsgParse:)
                                                                        certIndex:-1
                                                                             cert:nil
                                                                       privateKey:nil
                                                                         password:nil];
                                  }];
}

//MARK: --- FIDO Authentication ---
/// FIDO인증 함수
/// @param completion  FIDO인증 결과 block (위의 블록 정의 함수 주석 참조)
- (void)authenticationFido:(FidoCompletion)completion {
    
    if (!self.isRegAuth) {
        //setting callback
        complete = completion;
    }
    
    //FIDO REG 여부 체크
//    BOOL isRegistered = [ccFido checkRegistrationToLocal:self.userName isKFido:NOT_K_FIDO serviceName:self.fidoServiceName];
//    if (isRegistered) {
//        NSLog(@"> Already registered.");
//    }
    
    // 바이오인증수단 변경 감지시 진행 여부 설정
    [ccFido setRestrictFidoWhenBioMetricsChanged:YES];
    
    FidoOPType fidoOPType = REQ_AUTHENTICATION_BY_TOUCHID;
    switch (biometryType) {
        case BIOMETRY_TYPE_TOUCHID:
            fidoOPType = REQ_AUTHENTICATION_BY_TOUCHID;
            break;
        case BIOMETRY_TYPE_FACEID:
            fidoOPType = REQ_AUTHENTICATION_BY_FACEID;
            break;
        default:
            break;
    }
    
    NSError *error;
    NSDictionary *requestMassage = [ccFido generateRequestMessageForAuthentication:fidoOPType
                                                                            userId:self.userName
                                                                         tCContent:nil
                                                                           extData:nil
                                                                           isKFido:NOT_K_FIDO
                                                                       serviceName:self.fidoServiceName
                                                                             error:&error];
    
    if(requestMassage == nil)
    {
        NSLog(@"generateRequestMessageForAuthentication requestMessage is nil");
        NSLog(@"error code : %ld, error description : %@",(long)[error code], [error description]);
        
        ResultMessage *errMessage = [[ResultMessage alloc] init];
        errMessage.errorMessage = [error description];
        errMessage.errorCode = (int)[error code];
        
        complete(NO, errMessage, error);
        return;
    }
    
    [CCJSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
                                     params:requestMassage
                                 completion:^(NSDictionary *json, CCJSONModelError *err) {
                                        NSLog(@"requestMassage res: \n %@", json);
        
                                        if (err) {
                                            ResultMessage *errMessage = [[ResultMessage alloc] init];
                                            errMessage.errorMessage = [err description];
                                            errMessage.errorCode = (int)[err code];
                                            
                                            self->complete(NO, errMessage, err);
                                            return;
                                        }
                                        
                                        [self->ccFido requestMessageResultParsing:json
                                                                    operationType:fidoOPType
                                                                          aTarget:self
                                                                 completeSelector:@selector(onResult:)
                                                           registeredTypeCheckSel:@selector(onResultAuthRequestMsgParse:)
                                                              registrationTypeSel:nil
                                                                        certIndex:-1
                                                                             cert:nil
                                                                       privateKey:nil
                                                                         password:nil
                                         ];
                                 }
    ];
}

//MARK: --- FIDO Operation ---

- (void)showAvailableVerificationList:(NSDictionary *)requestResult certIndex:(NSInteger)certIndex cert:(NSData *)cert privateKey:(NSData *)privateKey password:(NSString *)password {
    
    NSLog(@"requestResult : %@", requestResult);
    NSArray *userVerificationList = [ccFido getUserVerificationFromRequestResult:requestResult];
    
    if (!userVerificationList) {
        NSLog(@"userVerificationList is nil");
        
        NSString *errorMessage = requestResult[@"description"] ? requestResult[@"description"] : @"";
        NSNumber* errorCodeNum = [requestResult valueForKey:@"statusCode"];
        int errorCode = errorCodeNum ? [errorCodeNum intValue] : 0;
        
        ResultMessage *errMessage = [[ResultMessage alloc] init];
        errMessage.errorMessage = errorMessage;
        errMessage.errorCode = errorCode;
        complete(NO, errMessage, nil);
        return;
    }
    
    for (NSString *type in userVerificationList) {

        NSLog(@"? Check bio type : %@", type);
        NSInteger bio = [type intValue];
        FidoOPType selectedOperationType;

        if ((bio & USER_VERIFY_FINGERPRINT) == USER_VERIFY_FINGERPRINT) {
            NSLog(@"> use TouchID ");
            selectedOperationType = REQ_REGISTRATION_BY_TOUCHID;
            [ccFido requestMessageResultParsing:requestResult
                                  operationType:selectedOperationType
                                        aTarget:self
                               completeSelector:@selector(onResult:)
                         registeredTypeCheckSel:nil
                            registrationTypeSel:@selector(onResultRegRequestMsgParse:)
                                      certIndex:(int)certIndex
                                           cert:cert
                                     privateKey:privateKey
                                       password:password];
        }
        else if ((bio & USER_VERIFY_FACEPRINT) == USER_VERIFY_FACEPRINT) {
            NSLog(@"> use FaceID ");
            selectedOperationType = REQ_REGISTRATION_BY_FACEID;
            [ccFido requestMessageResultParsing:requestResult
                                  operationType:selectedOperationType
                                        aTarget:self
                               completeSelector:@selector(onResult:)
                         registeredTypeCheckSel:nil
                            registrationTypeSel:@selector(onResultRegRequestMsgParse:)
                                      certIndex:(int)certIndex
                                           cert:cert
                                     privateKey:privateKey
                                       password:password];
        }
    }
    
}

//MARK: --- FIDO Result ---

- (void)onResult:(ResultMessage *)resultMessage {
    NSLog(@">> onResult");
    
    if (resultMessage.errorCode != 0) {
        NSLog(@"resultMessage.result : fail");
        NSLog(@"resultMessage.message : %@", resultMessage.message);
        NSLog(@"resultMessage.errorCode : %d", resultMessage.errorCode);
        NSLog(@"resultMessage.errorMessage : %@", resultMessage.errorMessage);
        
        self.isRegAuth = NO;

        // 실패
        complete(NO, resultMessage, nil);
        return;
    }
    
    switch (resultMessage.operationType) {
        case REQ_REGISTRATION_BY_TOUCHID:
        case REQ_REGISTRATION_BY_FACEID:
        case REQ_REGISTRATION_USE_INDEX:
        case REQ_REGISTRATION_USE_CERT:
        case REQ_REGISTRATION_BY_PASSSIGN:
        case REQ_REGISTRATION_BY_PASSCODE:
            NSLog(@"가입");
           
            //등록과 인증을 동시에
            if (self.isRegAuth) {
                [self authenticationFido:^(BOOL success, ResultMessage * _Nullable result, NSError * _Nullable error) {
                    self->complete(YES, result, error);
                    self.isRegAuth = NO;
                }];
                return;
            }
            
            complete(YES, resultMessage, nil);
            break;
        case REQ_AUTHENTICATION_BY_TOUCHID:
        case REQ_AUTHENTICATION_BY_FACEID:
        case REQ_AUTHENTICATION_BY_PASSSIGN:
        case REQ_AUTHENTICATION_BY_PASSCODE:
            NSLog(@"로그인");
            complete(YES, resultMessage, nil);
            break;
        case REQ_DEREGISTRATION:
            NSLog(@"탈퇴");
            complete(YES, resultMessage, nil);
            break;
        default:
            NSLog(@"resultMessage.result : fail");
            NSLog(@"resultMessage.message : %@", resultMessage.message);
            NSLog(@"resultMessage.errorCode : %d", resultMessage.errorCode);
            NSLog(@"resultMessage.errorMessage : %@", resultMessage.errorMessage);

            // 실패
            complete(NO, resultMessage, nil);
            break;
    }
}

- (void)onResultRegRequestMsgParse:(NSNumber *)type {
    NSLog(@">> onResultRegRequestMsgParse");
    
    __block KBFidoManager *blockSelf = self;
    switch ([type intValue]) {
        case REQ_REGISTRATION_BY_FACEID || REQ_REGISTRATION_BY_TOUCHID:
        {
            NSLog(@"> APP에서 바이오 인증 처리 진행");
            
            NSError *error = nil;
            LAContext *context = [[LAContext alloc] init];
            int bioType = USER_VERIFY_FINGERPRINT;

            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                 if (@available(iOS 11.0, *))
                 {
                     context.localizedFallbackTitle = @"";
                     switch (context.biometryType) {
                         case LABiometryTypeTouchID:
                         {
                             bioType = USER_VERIFY_FINGERPRINT;
                         }
                             break;
                         case LABiometryTypeFaceID:
                         {
                             bioType = USER_VERIFY_FACEPRINT;
                         }
                             break;

                         default:
                             break;
                    }
                }
            }

            NSString *localizedReason = self.localizedMsg.length > 0 ? self.localizedMsg : @"바이오 등록 요청";
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizedReason reply:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success)
                    {
                        USError *err;
                        NSDictionary *responseMessage= [blockSelf->ccFido generateResponseMessage:bioType
                                                                                tcContent:nil
                                                                                  isKFido:NOT_K_FIDO
                                                                                    error:&err];
                        
                        if (error != nil) {
                            NSLog(@"error : [%ld, %@]", (long)error.code, error.description);

                            ResultMessage *errMessage = [[ResultMessage alloc] init];
                            errMessage.errorMessage = [error description];
                            errMessage.errorCode = (int)[error code];

                            // 실패
                            blockSelf->complete(NO, errMessage, error);
                            return;
                        }
                        if (responseMessage == nil) {
                            NSLog(@"Failed");

                            // 실패
                            blockSelf->complete(NO, [blockSelf makeResultErrorMessage:@"Framework에서 생성된 responseMessage가 없습니다."], error);
                            return;
                        }

                        NSLog(@"responseMessage : %@",responseMessage);

                        [CCJSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
                                                          params:responseMessage
                                                      completion:^(NSDictionary *json, CCJSONModelError *err) {
                            NSLog(@"json : %@",json);
                            NSLog(@"err : %@",err);

                            [blockSelf->ccFido responseMessageResultParsingForRegistration:json];
                        }];
                    }
                    else
                    {
                        //3번 틀렸을 때 kLAErrorAuthenticationFailed
                        NSLog(@"onBooked error : %ld",(long)[error code]);
                        NSLog(@"onBooked error : %@",[error description]);
                        NSLog(@"error : [%ld] %@", (long)[error code], [error description]);

                        ResultMessage *errMessage = [[ResultMessage alloc] init];
                        errMessage.errorMessage = [error description];
                        errMessage.errorCode = (int)[error code];

                        // 실패
                        blockSelf->complete(NO, errMessage, error);
                        
                        return;
                    }
                });
            }];
            
            
//            ccFido.touchIDResult = ^(NSDictionary * _Nullable responseMessage, NSError * _Nullable error) {
//                NSLog(@"message : %@", responseMessage);
//
//                if (error != nil) {
//                    NSLog(@"error : [%ld, %@]", (long)error.code, error.description);
//
//                    ResultMessage *errMessage = [[ResultMessage alloc] init];
//                    errMessage.errorMessage = [error description];
//                    errMessage.errorCode = (int)[error code];
//
//                    // 실패
//                    blockSelf->complete(NO, errMessage, error);
//                    return;
//                }
//                if (responseMessage == nil) {
//                    NSLog(@"Failed");
//
//                    // 실패
//                    blockSelf->complete(NO, [blockSelf makeResultErrorMessage:@"Framework에서 생성된 responseMessage가 없습니다."], error);
//                    return;
//                }
//
//                [JSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
//                                                  params:responseMessage
//                                              completion:^(NSDictionary *json, JSONModelError *err) {
//                                                  NSLog(@"responseMessage json : %@",json);
//                                                  NSLog(@"err : %@",err);
//
//                                                if (err == nil) {
//                                                    NSLog(@"> Receive response for 'REG'");
//                                                    [blockSelf->ccFido responseMessageResultParsingForRegistration:json];
//                                                }
//                                                else {
//                                                    NSLog(@"onResultRegRequestMsgParse FIDO failure");
//                                                    // 실패
//                                                    blockSelf->complete(NO, [blockSelf makeResultErrorMessage:@"onResultRegRequestMsgParse FIDO failure"], error);
//                                                }
//
//
//                                              }];
//            };
//            [ccFido showTouchIdForWithMessage:nil isKFido:NOT_K_FIDO];
            break;
        }
        default:
            NSLog(@"Network Failure");
            // 실패
            complete(NO, [self makeResultErrorMessage:@"Network Failure"], nil);
            break;
    }
    
    
}

- (void)onResultAuthRequestMsgParse:(ViewCertificate *)viewCertificate {
    NSLog(@">> onResultAuthRequestMsgParse");
    NSLog(@"viewCertificate.subjectDN : %@", viewCertificate.subjectDN);
    NSLog(@"viewCertificate.keyUsage : %@", viewCertificate.keyUsage);
    NSLog(@"viewCertificate.validityBeginDate : %@", viewCertificate.validityBeginDate);
    NSLog(@"viewCertificate.validityEndDate : %@", viewCertificate.validityEndDate);
    NSLog(@"viewCertificate.mRegistrationType : %d", viewCertificate.mRegistrationType);
    NSLog(@"viewCertificate.includeCertInfo : %d", viewCertificate.includeCertInfo);
    
    //K_FIDO
    if (viewCertificate.includeCertInfo) {
        
    }
    //NOT_K_FIDO
    else {
        __block KBFidoManager *blockSelf = self;
        switch ([viewCertificate mRegistrationType]) {
            case REQ_REGISTRATION_BY_FACEID || REQ_REGISTRATION_BY_TOUCHID:
            {
                NSLog(@"> APP에서 바이오 인증 처리 진행");
                
                //앱에서 지문인증
                NSError *error = nil;
                LAContext *context = [[LAContext alloc] init];
                int bioType = USER_VERIFY_FINGERPRINT;

                if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                     if (@available(iOS 11.0, *))
                     {
                         context.localizedFallbackTitle = @"";
                         switch (context.biometryType) {
                             case LABiometryTypeTouchID:
                             {
                                 bioType = USER_VERIFY_FINGERPRINT;
                             }
                                 break;
                             case LABiometryTypeFaceID:
                             {
                                 bioType = USER_VERIFY_FACEPRINT;
                             }
                                 break;

                             default:
                                 break;
                        }
                    }
                }
                
                if (!self.isRegAuth) {
                    NSString *localizedReason = self.localizedMsg.length > 0 ? self.localizedMsg : @"바이오 인증 요청";
                    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizedReason reply:^(BOOL success, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (success)
                            {
                                USError *err;
                                NSDictionary *responseMessage= [blockSelf->ccFido generateResponseMessage:bioType
                                                                                        tcContent:nil
                                                                                          isKFido:NOT_K_FIDO
                                                                                            error:&err];

                                if(error != nil)
                                {
                                    NSLog(@"error : %ld",(long)[error code]);
                                    NSLog(@"error : %@",[error description]);
                                    return;
                                }

                                if(responseMessage == nil)
                                {
                                    NSLog(@"Framework에서 생성된 responseMessage가 없습니다.");
                                    return;
                                }

                                NSLog(@"responseMessage : %@",responseMessage);

                                [CCJSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
                                                                  params:responseMessage
                                                              completion:^(NSDictionary *json, CCJSONModelError *err) {
                                    NSLog(@"json : %@",json);
                                    NSLog(@"err : %@",err);

                                    [blockSelf->ccFido responseMessageResultParsingForAuthentication:json];
                                }];
                            }
                            else
                            {
                                //3번 틀렸을 때 kLAErrorAuthenticationFailed
                                NSLog(@"onBooked error : %ld",(long)[error code]);
                                NSLog(@"onBooked error : %@",[error description]);
                                NSLog(@"error : [%ld] %@", (long)[error code], [error description]);
        
                                ResultMessage *errMessage = [[ResultMessage alloc] init];
                                errMessage.errorMessage = [error description];
                                errMessage.errorCode = (int)[error code];
        
                                // 실패
                                blockSelf->complete(NO, errMessage, error);
                                
                                return;
                            }
                        });
                    }];
                    
                    // 라이브러리 내 지문인증
//                    NSLog(@"바이오 인증 요청");
//
//                    ccFido.touchIDResult = ^(NSDictionary * _Nullable responseMesage, NSError * _Nullable error) {
//
//                        if(error != nil)
//                        {
//                            NSLog(@"onBooked error : %ld",(long)[error code]);
//                            NSLog(@"onBooked error : %@",[error description]);
//                            NSLog(@"error : [%ld] %@", (long)[error code], [error description]);
//
//                            ResultMessage *errMessage = [[ResultMessage alloc] init];
//                            errMessage.errorMessage = [error description];
//                            errMessage.errorCode = (int)[error code];
//
//                            // 실패
//                            blockSelf->complete(NO, errMessage, error);
//                            return;
//                        }
//
//                        NSLog(@"responseMessage : %@", responseMesage);
//                        if(responseMesage == nil)
//                        {
//                            // 1. responseMesage == nil 이고 error != nil 이면 디바이스에 락이 걸린 상태
//                            // 2. responseMesage == nil 이고 error == nil 이면 디바이스에 락이 풀린 상태
//
//
//                            NSLog(@"FIDOFramework 락이 되어있습니다. responseMessage 생성 불가 상황 입니다. 또는 responseMessage 생성 불가 상황 입니다.");
//
//                            // 실패
//                            blockSelf->complete(NO, [blockSelf makeResultErrorMessage:@"FIDOFramework 락이 되어있습니다. responseMessage 생성 불가 상황 입니다. 또는 responseMessage 생성 불가 상황 입니다."], error);
//                            return;
//                        }
//
//                        NSLog(@"responseMessage: \n %@", responseMesage);
//                        [JSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
//                                                          params:responseMesage
//                                                      completion:^(NSDictionary *json, JSONModelError *err) {
//                                                          NSLog(@"json : %@",json);
//                                                          NSLog(@"err : %@",err);
//                                                          NSLog(@"responseMessage res: \n %@", json);
//
//                                                          [blockSelf->ccFido responseMessageResultParsingForAuthentication:json];
//                                                      }];
//                    };
//
//                    [ccFido showTouchIdForWithMessage:nil isKFido:NOT_K_FIDO];
                }
                else {
                    
                    self.isRegAuth = NO;
                    
                    USError *err;
                    NSDictionary *responseMessage= [blockSelf->ccFido generateResponseMessage:bioType
                                                                            tcContent:nil
                                                                              isKFido:NOT_K_FIDO
                                                                                error:&err];

//                    if(error != nil)
//                    {
//                        NSLog(@"error : %ld",(long)[error code]);
//                        NSLog(@"error : %@",[error description]);
//                        return;
//                    }

                    if(responseMessage == nil)
                    {
                        NSLog(@"Framework에서 생성된 responseMessage가 없습니다.");
                        return;
                    }

                    NSLog(@"responseMessage : %@",responseMessage);

                    [CCJSONHTTPClient getJSONFromURLWithString:self.fidoServerUrl
                                                      params:responseMessage
                                                  completion:^(NSDictionary *json, CCJSONModelError *err) {
                        NSLog(@"json : %@",json);
                        NSLog(@"err : %@",err);

                        [blockSelf->ccFido responseMessageResultParsingForAuthentication:json];
                    }];
                }
                break;
        }
            default:
                break;
        }
    }
}

//MARK: --- Utility ---
/**
 @discussion TouchID 지원 가능 단말기 여부 판별
 */
-(BOOL)isAvailableTouchID {
    return ccFido.isAvailableTouchID;
}

/**
 @discussion TouchID 사용 가능 할 경우 등록 되어있는 지문이 있는지 확인
 */
-(BOOL)isTouchIDEnrolled {
    return ccFido.isTouchIDEnrolled;
}

/**
 @discussion Check if the device is an iPhone.
        단말기의 iPhone여부를 판별한다.
 @return Returns `true` if `Device` is iPhone.
 */
-(BOOL)isThisDeviceAniPhone {
    return ccFido.isThisDeviceAniPhone;
}

/**
 @discussion Check the biometryType available on the device.
        단말기의 사용 가능한 BiometryType을 확인한다.
 @return
     BiometryNone : 0
     BiometryTypeTouchID : 1
     BiometryTypeFaceID : 2
 */
-(BiometryType)getBiometryType {
    return ccFido.getBiometryType;
}

-(NSString *)dictionaryToJSONString:(NSDictionary *)dic {
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonDataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonDataStr = [jsonDataStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    return jsonDataStr;
}

- (ResultMessage *)makeResultErrorMessage:(NSString *)errMessage {
    ResultMessage *resultMessage = [[ResultMessage alloc] init];
    resultMessage.errorMessage = errMessage;
    return resultMessage;
}

@end
