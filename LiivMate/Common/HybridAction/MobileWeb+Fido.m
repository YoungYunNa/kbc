//
//  MobileWeb+Fido.m
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2019. 3. 19..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "MobileWeb+Fido.h"
#import "FidoLib.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface MobileWeb (Fido) <VPFidoLibDelegate>

@end

@implementation MobileWeb (Fido)

#pragma mark - TO-BE FidoAction Delegate
- (void)responseFidoAction:(FIDOType)type success:(BOOL)success resultMessage:(ResultMessage *)resultMessage error:(NSError *)error {
    
    [IndicatorView hide];
    
    switch (type) {
        case FIDOTypeReg:
        {
            if (success)
            {
                // 저장
                [UserDefaults sharedDefaults].isRegistedFido = YES;
                                
                //결과 전송 (성공)
                [self finishedActionWithResult:nil success:YES];
            }
            else
            {
                LAContext *context = [[LAContext alloc] init];
                NSError * lockError;
                if(![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&lockError]){
                    error = lockError;
                }
                
                if (!(error.code == kLAErrorUserCancel || error.code == kLAErrorSystemCancel))    // -2: Canceled by user, -4: UI canceled by system
                {
                    //바이오인증 락이 걸렸을 경우
                    if (resultMessage.errorCode == 0 && error == nil) {
                        [BlockAlertView showBlockAlertWithTitle:nil message: isFaceID() ? FaceIdLockoutMsg : TouchIdLockoutMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                            
                        } cancelButtonTitle:nil buttonTitles:@"확인", nil];
                        break;
                    }
                    else {
                        if (!(resultMessage.errorCode == USER_CANCEL || resultMessage.errorCode == SYSTEM_CANCEL))    // 10021: Canceled by user, 10023: UI canceled by system
                        {
                            // 10025 LOCK_OUT - 바이오인증 락이 걸렸을 경우 발생한다.
                            // kLAErrorBiometryLockout
                            if (resultMessage.errorCode == LOCK_OUT || error.code == kLAErrorBiometryLockout) {
                                [BlockAlertView showBlockAlertWithTitle:nil message: isFaceID() ? FaceIdLockoutMsg : TouchIdLockoutMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                                    
                                } cancelButtonTitle:nil buttonTitles:@"확인", nil];
                            }
                            // 지문인증 3회 오류
                            else if ( error.code == kLAErrorAuthenticationFailed ) {
                                [BlockAlertView showBlockAlertWithTitle:nil message: isFaceID() ? FaceIdDiffMsg : TouchIdDiffMsg dismissedCallback:nil cancelButtonTitle:nil buttonTitles:@"확인", nil];
                            }
                            else {
                                [self OnFidoError:(int)error.code];
                            }
                        }
                    }
                }
            }
        }
            break;
        case FIDOTypeDeReg:
        {
            [UserDefaults sharedDefaults].isRegistedFido =NO;
            [self finishedActionWithResult:nil success:YES];
            
            NSString * authType = @"";
            if ([AppInfo sharedInfo].typeBiometrics == TypeTouchID) {
                authType = @"1";
            } else if([AppInfo sharedInfo].typeBiometrics == TypeFaceID) {
                authType = @"2";
            }
            
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setValue:[UserDefaults sharedDefaults].appID forKey:@"appId"];
            [param setValue:@"Dereg" forKey:@"certGbn"];
            [param setValue:success ? @"1" : @"0" forKey:@"certRslt"];
            [param setValue:authType forKey:@"certMethodGbn"];
            [Request requestID:KATWA19      //P01209
                          body:param
                 waitUntilDone:NO
                   showLoading:YES
                     cancelOwn:APP_DELEGATE
                      finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                      }];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - AS-IS
// Result Registration(등록)
- (void)result_Register:(BOOL)success
{
    [IndicatorView hide];
    if (success)
    {
        // 저장
//        [UserDefaults sharedDefaults].useFido = FidoUseSettingDisabled;
        [UserDefaults sharedDefaults].isRegistedFido =YES;
                
        // ???? TODO : 결과 전송 (성공)
        [self finishedActionWithResult:nil success:YES];
    }
    else
    {
        [self mAlertView:@"바이오 인증 등록에 실패 하였습니다."];
    }
}

// Result Authentication(인증)
-(void)result_Auth:(BOOL)success postData:(NSString*)postData userId:(NSString*)userId;
{
    NSLog(@"result_Auth - success / postData : %d / %@", success, postData);
}

// Result Deregistration(해지)
- (void)result_Deregister:(BOOL)success
{
    NSLog(@"result_Deregister - success : %d", success);
    
    [IndicatorView hide];
    if (success)
    {
        // 저장
       [UserDefaults sharedDefaults].isRegistedFido =NO;
        

        [self finishedActionWithResult:nil success:YES];
    }
    else
    {
        [self mAlertView:@"바이오 인증 해제에 실패 하였습니다."];
    }
    
    NSString * authType = @"";
    if ([AppInfo sharedInfo].typeBiometrics == TypeTouchID) {
        authType = @"1";
    } else if([AppInfo sharedInfo].typeBiometrics == TypeFaceID) {
        authType = @"2";
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[UserDefaults sharedDefaults].appID forKey:@"appId"];
    [param setValue:@"Dereg" forKey:@"certGbn"];
    [param setValue:success ? @"1" : @"0" forKey:@"certRslt"];
    [param setValue:authType forKey:@"certMethodGbn"];
    [Request requestID:KATWA19      //P01209
                  body:param
         waitUntilDone:NO
           showLoading:YES
             cancelOwn:APP_DELEGATE
              finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
              }];
    
}

// Fido Error
- (void)OnFidoError:(int)reason
{
    NSLog(@"OnFidoError - reason : %d", reason);
    [IndicatorView hide];
    switch(reason)
    {
        case 1500 :
            [self mAlertView:@"서버 내부 오류가 발생하였습니다."];
            break;
        case 1481 :
            [self mAlertView:@"등록 정보에 오류가 있습니다."];
            break;
        case 1480 :
            [self mAlertView:@"해당 인증장치 정보가 없습니다."];
            break;
        case 1408 :
            [self mAlertView:@"요청 시간이 초과되었습니다."];
            break;
        case 1404 ://@"이미 등록된 정보입니다."
        {
            // 저장
            [UserDefaults sharedDefaults].useFido = FidoUseSettingDisabled;
            
            //[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"지문인증 등록에 성공하였습니다." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {} cancelButtonTitle:AlertConfirm buttonTitles: nil];
            
            // ???? TODO : 결과 전송 (성공)
            [self finishedActionWithResult:nil success:YES];
        }
            break;
        case 1405 :
        {
            [self mAlertView:@"등록 후 사용이 가능합니다."];// auth // original
            break;
        }
        case 1403 :
            [self mAlertView:@"현재 사용자가 수행할 수 없는 동작입니다."];
            break;
        case 1401 :
            [self mAlertView:@"인증되지 않은 사용자입니다."];
            break;
        case 1400 :
            [self mAlertView:@"잘못된 요청입니다."];
            break;
        case 1202 :
            [self mAlertView:@"제한 시간 내 처리되지 못했습니다."];
            break;
        case 1496 :
            [self mAlertView:@"Unacceptable Attestation."];
            break;
        case 1494 :
            [self mAlertView:@"Unacceptable Key."];
            break;
        case 1492 :
            [self mAlertView:@"정책에 부합하는 인증장치가 없습니다."];
            break;
        default:
            [self mAlertView:@"바이오인식 등록에 실패하셨습니다."];
            break;
    }
}

-(void)mAlertView:(NSString *)message
{
    //[BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {} cancelButtonTitle:AlertConfirm buttonTitles: nil];
    
    // ???? TODO : 결과 전송 (실패)
    NSDictionary *errorDic = (message.length > 0 ? @{@"errorMessage":message} : nil);
    [self finishedActionWithResult:errorDic success:NO];
}

-(void)mAlertView:(NSString *)message resultCode:(NSString *)resultCode
{
    //[BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {} cancelButtonTitle:AlertConfirm buttonTitles: nil];
    
    message = message ? message : @"";
    resultCode = resultCode ? resultCode : [NSString stringWithFormat:@"-1"];
    
    // ???? TODO : 결과 전송 (실패)
    NSMutableDictionary * errorDic = [NSMutableDictionary dictionary];
    [errorDic setObject:message forKey:@"errorMessage"];
    [errorDic setObject:resultCode forKey:@"resultCode"];
    
    [self finishedActionWithResult:errorDic success:NO];
}

@end



//인증방식 설정
@implementation setAuthenticationType
-(void)run
{
    // ???? TODO : 저장
    BOOL fidoUse = [self.paramDic[@"authenticationType"] isEqualToString:@"FIDO"];
    [UserDefaults sharedDefaults].useFido =  fidoUse ? FidoUseSettingEnabled : FidoUseSettingDisabled;
    
    // ???? TODO : 이전 화면 이동
    //[self.navigationController popViewControllerAnimated:YES];
    
    // ???? TODO : 결과 전송 (성공)
    [self finishedActionWithResult:nil success:YES];
}
@end


@interface registerFido()
{
    FidoLib* _fidoLib;
}
@end

//지문인식 등록
@implementation registerFido
-(void)run
{
    if([AppInfo sharedInfo].useBiometrics == UseBiometricsEnabled)
    {
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        if( [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error] )
        {
            // 한국전자인증 FIDO
            if ([UserDefaults sharedDefaults].isFidoTestTOBE) {
                [IndicatorView showMessage:nil];
                
                // showSplashView setting
                [AppInfo sharedInfo].isFidoActive = YES;
                
                [[KBFidoManager sharedInstance] setUserName:[UserDefaults sharedDefaults].appID];
                [[KBFidoManager sharedInstance] registrationFido:^(BOOL success, ResultMessage * _Nonnull result, NSError * _Nullable error) {
                    
                    [IndicatorView hide];
                    
                    // showSplashView setting
                    [AppInfo sharedInfo].isFidoActive = NO;
                   
                    NSString * authType = @"";
                    if ([AppInfo sharedInfo].typeBiometrics == TypeTouchID) {
                        authType = @"1";
                    } else if([AppInfo sharedInfo].typeBiometrics == TypeFaceID) {
                        authType = @"2";
                    }
                    // HA서버에 지문인증 사용 기록을 위해 전달
                    NSMutableDictionary *param = [NSMutableDictionary dictionary];
                    [param setValue:[UserDefaults sharedDefaults].appID forKey:@"appId"];
                    [param setValue:@"Reg" forKey:@"certGbn"];
                    [param setValue:success ? @"1" : @"0" forKey:@"certRslt"];
                    [param setValue:authType forKey:@"certMethodGbn"];
                    [Request requestID:KATWA19    // P01209
                                  body:param
                         waitUntilDone:NO
                           showLoading:YES
                             cancelOwn:APP_DELEGATE
                              finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                              }];
                    
                    [self responseFidoAction:FIDOTypeReg success:success resultMessage:result error:error];
                }];
            }
            // 브이피 FIDO
            else {
                context.localizedFallbackTitle = @"";
                [AppInfo sharedInfo].isFidoActive = YES;
                [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                        localizedReason: isFaceID() ? @"Face ID 인증 등록" : @"지문인증등록"
                                  reply:^(BOOL success, NSError *error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [AppInfo sharedInfo].isFidoActive = NO;
                                          if (success)
                                          {
                                              [IndicatorView showMessage:nil];
                                              if(self->_fidoLib == nil)
                                              {
                                                  self->_fidoLib = [[FidoLib alloc] init];
//                                                  [self->_fidoLib SetDelegate:self];
                                                  [self->_fidoLib setDelegate:self withKBType:KBType02];
#ifdef DEBUG
//                                                  [self->_fidoLib setIsLogOn:YES];
#endif
                                              }
                                              
                                              NSString * authType = @"";
                                              if ([AppInfo sharedInfo].typeBiometrics == TypeTouchID) {
                                                  authType = @"finger";
                                              } else if([AppInfo sharedInfo].typeBiometrics == TypeFaceID) {
                                                  authType = @"face";
                                              }
                                            
                                              [self->_fidoLib fido_Registration:FidoTypeETC server:FidoMode];
                                              
                                              // 인증성공시에 마지막 에러 초기화
                                              [AppInfo sharedInfo].lastBiometricsError = nil;
                                          }
                                          else
                                          {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  NSLog(@"error.code : %ld", (long)error.code);
                                                  if (error.code == kLAErrorUserCancel)
                                                  {
                                                      //회원가입과 그외에 user가 취소시 문구 변경
                                                      if([AppInfo sharedInfo].isJoin == NO){
                                                           [self mAlertView: isFaceID() ? FaceIdSkipMsg : TouchIdSkipMsg resultCode:@"9999"];
                                                      }else{
                                                           [self mAlertView: isFaceID() ? FaceIdRegFailMsg : TouchIdRegFailMsg resultCode:@"9999"];
                                                      }
                                                     
                                                  }else if(error.code == kLAErrorSystemCancel){
                                                      [self mAlertView: isFaceID() ? FaceIdRegFailMsg : TouchIdRegFailMsg];
                                                  }else
                                                  {
                                                      if (error.code == kLAErrorBiometryLockout)
                                                      {
                                                          [AppInfo sharedInfo].useBiometrics = UseBiometricsDisabled;
                                                          [AppInfo sharedInfo].lastBiometricsError = error;
                                                      }
                                                      
                                                      [self mAlertView: isFaceID() ? FaceIdDiffMsg : TouchIdDiffMsg];
                                                  }
                                              });
                                          }
                                          
                                          NSString * authType = @"";
                                          if ([AppInfo sharedInfo].typeBiometrics == TypeTouchID) {
                                              authType = @"1";
                                          } else if([AppInfo sharedInfo].typeBiometrics == TypeFaceID) {
                                              authType = @"2";
                                          }
                                          // HA서버에 지문인증 사용 기록을 위해 전달
                                          NSMutableDictionary *param = [NSMutableDictionary dictionary];
                                          [param setValue:[UserDefaults sharedDefaults].appID forKey:@"appId"];
                                          [param setValue:@"Reg" forKey:@"certGbn"];
                                          [param setValue:success ? @"1" : @"0" forKey:@"certRslt"];
                                          [param setValue:authType forKey:@"certMethodGbn"];
                                          [Request requestID:KATWA19    // P01209
                                                        body:param
                                               waitUntilDone:NO
                                                 showLoading:YES
                                                   cancelOwn:APP_DELEGATE
                                                    finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                                                    }];
                                      });
                                  }];
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == kLAErrorBiometryLockout)
                {
                    [BlockAlertView showBlockAlertWithTitle:nil message:isFaceID() ? FaceIdLockoutMsg : TouchIdLockoutMsg dismisTitle:AlertConfirm];
                }
                else if (error.code == kLAErrorBiometryNotEnrolled
                         || error.code == kLAErrorPasscodeNotSet)
                {
                    [BlockAlertView showBlockAlertWithTitle:nil message:isFaceID() ? FaceIdPasscodeNotSetMsg : TouchIdPasscodeNotSetMsg dismisTitle:AlertConfirm];
                }
                else //if (error.code == m /*kLAErrorTouchIDNotAvailable*/)
                {
                    [BlockAlertView showBlockAlertWithTitle:nil message:isFaceID() ? FaceIdNotAvailableMsg : TouchIdNotAvailableMsg dismisTitle:AlertConfirm];
                }
            });
        }
    }
    else if ([AppInfo sharedInfo].useBiometrics == UseBiometricsDisabled)
    {
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error.code == kLAErrorBiometryLockout /*kLAErrorTouchIDLockout*/)
            {
                [self mAlertView: isFaceID() ? FaceIdLockoutMsg : TouchIdLockoutMsg];
            }
            else if (error.code == kLAErrorBiometryNotEnrolled
                     || error.code == kLAErrorPasscodeNotSet)
            {
                [self mAlertView:isFaceID() ? FaceIdPasscodeNotSetMsg : TouchIdPasscodeNotSetMsg];
            }
            else //if (error.code == kLAErrorBiometryNotAvailable /*kLAErrorTouchIDNotAvailable*/)
            {
                [self mAlertView: isFaceID() ? FaceIdNotAvailableMsg : TouchIdNotAvailableMsg];
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self mAlertView: isFaceID() ? FaceIdNotAvailableMsg : TouchIdNotAvailableMsg];
        });
    }
}


@end

@interface deregisterFido()
{
    FidoLib* _fidoLib;
}
@end
//지문인식 등록
@implementation deregisterFido

-(void)run
{
    // 한국전자인증 FIDO
    if ([UserDefaults sharedDefaults].isFidoTestTOBE) {
        [IndicatorView showMessage:nil];
        
        // showSplashView setting
        [AppInfo sharedInfo].isFidoActive = YES;
        
        [[KBFidoManager sharedInstance] setUserName:[UserDefaults sharedDefaults].appID];
        [[KBFidoManager sharedInstance] deRegistrationFido:^(BOOL success, ResultMessage * _Nonnull result, NSError * _Nullable error) {
            
            [IndicatorView hide];
            
            // showSplashView setting
            [AppInfo sharedInfo].isFidoActive = NO;
            
            [self responseFidoAction:FIDOTypeDeReg success:success resultMessage:result error:error];
        }];
    }
    // 브이피 FIDO
    else {
        [IndicatorView showMessage:nil];
        if(self->_fidoLib == nil)
        {
            self->_fidoLib = [[FidoLib alloc] init];
//            [self->_fidoLib SetDelegate:self];
            [self->_fidoLib setDelegate:self withKBType:KBType02];
        }
        
        NSString * authType = @"";
        if ([AppInfo sharedInfo].typeBiometrics == TypeTouchID) {
            authType = @"finger";
        } else if([AppInfo sharedInfo].typeBiometrics == TypeFaceID) {
            authType = @"face";
        }
        
        [self->_fidoLib fido_Deregistration:FidoTypeETC server:FidoMode];
    }
}

@end

