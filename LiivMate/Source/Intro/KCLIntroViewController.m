//
//  KCLIntroViewController.m
//  LiivMate
//
//  Created by KB on 4/20/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLIntroViewController.h"
#import "CheckAlertView.h"
#import "CustomWaitView.h"

#import <Firebase/Firebase.h>

#import "PureAppLib.h"
#import "PwdWrapper.h"

#import "ServerChoiceView.h"
#import "SplashScreenManager.h"

#ifndef DEBUG
//주요 함수명 난독화
#define startIntro                  asfefgsd
#define startPureapp                sgewhwew
#define startAnimation              gqwwqfqf
#define checkPureApp                ksdgegewsd
#endif

// 리브메이트 2.0 Merge 안랩 jbscanner 라이브러리 업데이트 + 코드 적용
static NSString* JBScannerAPISecret = @"367AC6CC-AFEC-4C4D-A22F-FFFB8A77B763";

@interface KCLIntroViewController ()

@end

@implementation KCLIntroViewController
{
    UIImageView *_imageView;
    PureAppLib *pureAppLib;
    
    __weak IBOutlet UIView *_splashView;
    __weak IBOutlet UIButton *_agreeButton;
    __weak IBOutlet UIView *_agreeButtonLineView;
    __weak IBOutlet UIView *_agreeContaintView;
    __weak IBOutlet UIView *_fadeOutLaunchView;
    __weak IBOutlet UIImageView *_moveLogoImageView;
    
    __weak IBOutlet UIImageView *_imgSloganView;
    __weak IBOutlet UIImageView *_imgMainView;
    
    __weak IBOutlet NSLayoutConstraint * _logoHeight;
    __weak IBOutlet NSLayoutConstraint * _posYRatio;
    BOOL isAniFinished;
    BOOL isPureFinished;
    NSDictionary *appData;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBarHidden = YES;
    
    NSDictionary * splashData = [SplashScreenManager getSplashData:[UserDefaults sharedDefaults].splashVer];
    
    if (splashData) {
        // 스플래시 Data셋팅
       [SplashScreenManager setSplashDataToScreen:_splashView
                                           slogan:_imgSloganView
                                             main:_imgMainView
                                      settingData:splashData];
    }
    
    // 리브메이트 2.0 Merge 안랩 jbscanner 라이브러리 업데이트 + 코드 적용
//    앱 위변조 체크 (함수화해서 사용하면 안됨) -
#if !TARGET_OS_SIMULATOR
#ifndef DEBUG
    NSString * info = [NSString stringWithFormat:@"ams2Library / %@ / %@ / %@" , [AppInfo sharedInfo].platform
                       ,[AppInfo sharedInfo].osVer
                       , [AppInfo sharedInfo].appVer];
    

    // Step_01: secret 을 UUID 로 변환
    NSUUID* secret = [[NSUUID alloc] initWithUUIDString:JBScannerAPISecret];
    // Step_02: challenge 데이터로 사용할 secure random bytes 를 생성.
    NSMutableData* challenge = [NSMutableData dataWithLength:32];
    int status = SecRandomCopyBytes(kSecRandomDefault, challenge.length, challenge.mutableBytes);
    if (status != errSecSuccess) {
        arc4random_buf(challenge.mutableBytes, challenge.length);
    }
    NSLog(@"challenge = %@", challenge);
    // Step_03: AMSLFairPlayInspector instance 를 생성
    AMSLFairPlayInspector* fairPlay = [AMSLFairPlayInspector fairPlayInspector];
    // Step_04: responseForChallenge 호출
    NSData* response = [fairPlay responseForChallenge:challenge];
    NSLog(@"response = %@", response);
    
    @try {
        // Step_05: response ack 생성
        NSData* responseAck = [AMSLFairPlayInspector hmacWithSierraEchoCharlieRomeoEchoTango:secret andData:response];
        NSLog(@"responseAck = %@", responseAck);
        // Step_06: fairPlayInspectorWithResponseAck: 호출 및 응답값 검사
        NSData* fairPlayData = [fairPlay fairPlayWithResponseAck:responseAck]; NSLog(@"result = %@", fairPlayData);
        // Step_06-A: fairPlayResult 를 NSDictionary 변환
        NSDictionary* fairPlayDic = [AMSLFairPlayInspector unarchive:fairPlayData];
        NSLog(@"fairPlayDic = %@", fairPlayDic);
        
        // Step_06-B: fairPlayResult 에서 confirm, confirmValidation 을 추출
        NSData* confirm = fairPlayDic[kAMSFPKeyConfirm];
        NSData* confirmValidation = fairPlayDic[kAMSFPKeyConfirmValidation];
            // Setp_06-C: responseAck 와 confirm 이 같은지 검사
        if ([confirm isEqualToData:responseAck] == NO) {
        // 같지 않으면, 메소드 반환값 위변조 공격
            NSLog(@"Jailbroken device");
            
            [[FIRCrashlytics crashlytics] logWithFormat:@"리브메이트 탈옥체크 :%@", [NSString stringWithFormat:@"%@ : Setp_06-C: responseAck 와 confirm 이 같은지 검사",  info]];
            assert(NO);
            return;
        }
        // Step_06-D: responseAck validation 값 생성
        NSData* expectedResponseAckValidation = [AMSLFairPlayInspector
        hmacWithSierraEchoCharlieRomeoEchoTango:secret andData:responseAck];
        // Step_06_E: expectedResponseAckValidation 와 conformValidation 이 같은지 검사
        if ([expectedResponseAckValidation isEqualToData:confirmValidation] == NO) {
            // 같지 않으면, 메소드 반환값 위변조 공격
            NSLog(@"Jailbroken device");
            [[FIRCrashlytics crashlytics] logWithFormat:@"리브메이트 탈옥체크 :%@",   [NSString stringWithFormat:@"%@ : Step_06_E: expectedResponseAckValidation 와 conformValidation 이 같은지 검사",  info]];
            assert(NO);
        } else {
            // 같으면, 정상 단말
            NSLog(@"Normal device");
        }
    } @catch (AMSLFairPlayInspectorError *e) {
        // Step_08: Jail break 가 감지, License key 가 틀렸거나,
        // 또는 호출 순서가 틀렸으면, AMSLFairPlayInspectorException 발생
        NSNumber* reasonCode = e.userInfo[kAMSFPUserInfoKeyCode]; NSNumber* reason = e.userInfo[kAMSFPUserInfoKeyReason]; NSInteger why = e.code;
            NSLog(@"%ld, %@, %@", (long)why, reasonCode, reason);
        if (why == kAMSFPWrongSecret) { // 잘못된 Secret
            NSLog(@"Wrong Secret");
        } else if (why == kAMSFPWrongCallSequence) {
            // 메소드 호출 순선 오류
            NSLog(@"Wrong call sequence");
        } else {
        // Jail break 감지
            NSLog(@"Detected Jailbroken.");
            [[FIRCrashlytics crashlytics] logWithFormat:@"리브메이트 탈옥체크 :%@",   [NSString stringWithFormat:@"%@ : Detected Jailbroken",  info]];
            assert(NO);
            
        }
    } @finally {
        
    }
#endif
#endif
    
    [self showServerSetting];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.y = CGRectGetHeight(self.view.bounds)-CGRectGetHeight(rect);
    _imageView.frame = rect;
}

#pragma mark - Start IntroView (개발: 서버선택 팝업, 운영: 인트로)
// 외부 기관 제출용으로 서버설정 화면없이 STG서버 설정(서버 설정 Alert 필요시 0)
-(void)showServerSetting {
    // 유량제어 테스트 코드
//    CustomWaitView * alert = [[CustomWaitView alloc] initWithParentView:nil];
//    [alert show];
    
#ifdef SELECT_SERVER
    AppDelegate * delegate = APP_DELEGATE;

    if (!delegate.server) {
#ifdef DEBUGSTG // 외부 제출용으로 STG 강제 설정 (서버 설정화면 없음)
            NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
             [userDefault setObject:@"Y" forKey:@"WIDGET_LIIVMATE3"];
             [userDefault synchronize];
            
            delegate.server = STA_SERVER_URL;
            // for test - ver.3
            [userDefault setObject:delegate.server forKey:@"STG_DOMIN_LIIVMATE3"];
            [userDefault synchronize];
            
            [self startIntro];
#else   // 외부 제출용으로 STG 강제 설정 (서버 설정화면 없음) - else
    #if 0
            delegate.server = DEV_SERVER_URL;
             [self startIntro];
    #else
//            [[AllMenu menu] setLiveMate3];

            // for test - ver.3
            NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
             [userDefault setObject:@"Y" forKey:@"WIDGET_LIIVMATE3"];
             [userDefault synchronize];

              ServerChoiceView *serverChoiceView = [ServerChoiceView makeView];
              [serverChoiceView setSelPort:[UserDefaults sharedDefaults].isPort];

              [BlockAlertView showBlockAlertCustomView:serverChoiceView withTouchDisable:NO showClosedButton:NO dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {

                          // 서버설정
                          if (buttonIndex == 0) {
                              delegate.server = DEV_SERVER_URL;
                              // for test - ver.3
                          NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
                          [userDefault setObject:delegate.server forKey:@"STG_DOMIN_LIIVMATE3"];
                          [userDefault synchronize];
                          } else {
                              delegate.server = STA_SERVER_URL;
                              // for test - ver.3
                            NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
                            [userDefault setObject:delegate.server forKey:@"STG_DOMIN_LIIVMATE3"];
                            [userDefault synchronize];
                          }

                          [UserDefaults sharedDefaults].isPort = [serverChoiceView isExistPort];
            #ifdef DEBUG
                          if ([serverChoiceView isExistPort]) {

                              delegate.server = [delegate.server stringByReplacingOccurrencesOfString:@"liivmate.com" withString:@"liivmate.com:2222"];
                          }
            #endif
                          [self startIntro];

                      }];
    #endif
#endif  // 외부 제출용으로 STG 강제 설정 (서버 설정화면 없음) - end
        } else {
            [self startIntro];
        }
#else
        [self startIntro];
#endif
}

-(void)startIntro {
    scanJailBreak();
    // 탈옥체크값을 서버에서 확인하여 처리한다
    
    //Fido remoteConfig설정값 받아오기
    [self executeFidoFirebaseRemoteConfig];
    
    [self startMoveLogo];
    
    if([AppInfo sharedInfo].autoLogin){
        [IndicatorView show];
    }
   // Ver. 3 KeepAlive(KATA014)
//        M00901,KATA014
    [Request requestID:KATA014 body:nil waitUntilDone:NO showLoading:NO cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
               if(![ERRCODE_AbnormalStat isEqualToString:rsltCode])
               {
                   if(self->_imageView)
                   {
                       self->_imageView.tag = 0;
                       [self performSelector:@selector(startAnimation) withObject:nil afterDelay:0.3];
                   }
                   else
                       [self startPureapp];
               }
               else
               {
                   [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex){
                       exit(0);
                   } cancelButtonTitle:@"종료" buttonTitles:nil];
               }
           }];
}

#pragma mark - IntroView Animation
- (void)startMoveLogo {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        self->_logoHeight.constant = 25;
        self->_posYRatio.constant = 0.94 * (CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetMaxY(self->_moveLogoImageView.frame))  + 1;
        
        [UIView animateWithDuration:1.0f animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
        
        [UIView animateWithDuration:2.0f delay:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self->_fadeOutLaunchView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            self->isAniFinished = YES;
            [self finishedCallback];
        }];
    });
}

- (void)startZoomIn {
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [UIView animateWithDuration:0.3f animations:^{
            self->_moveLogoImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
        } completion:^(BOOL finished) {
            [self startZoomOut];
        }];
    });
}

- (void)startZoomOut {
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [UIView animateWithDuration:0.3f animations:^{
            self->_moveLogoImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        } completion:^(BOOL finished) {
            [self startMoveLogo];
        }];
    });
}

- (void)startFadeOut {
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [UIView animateWithDuration:1.0f animations:^{
             [self->_fadeOutLaunchView setAlpha:0.0f];
        } completion:^(BOOL finished) {}];
    });
}

-(void)startAnimation {
    _imageView.highlighted = YES;
    dispatch_main_after(0.2, ^{
        self->_imageView.tag += 1;
        self->_imageView.highlighted = NO;
        if(self->_imageView.tag < 2)
            [self performSelector:@selector(startAnimation) withObject:nil afterDelay:0.2];
        else
            [self startPureapp];
    });
}

#pragma mark - Agree View & Button
- (void)showAgreementView {
    [_agreeButton setBackgroundImage:[[_agreeButton backgroundImageForState:UIControlStateNormal] stretchableImageWithCapWidthRatio:0.5 capHeightRatio:0.5] forState:UIControlStateNormal];
    
    _agreeButtonLineView.hidden = ([UIScreen mainScreen].bounds.size.height >= 375);
    _agreeContaintView.hidden = NO;
    _splashView.hidden = YES;
}

- (IBAction)agreeButtonClicked:(id)sender {
    // 동의 버튼
    [UserDefaults sharedDefaults].showDeviceUseAgreement = YES;
    [APP_DELEGATE mateApplicationStartService];
}

#pragma mark - Pure App
-(void)startPureapp {
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    //앱구동전문
    NSString *appID = [UserDefaults sharedDefaults].appID ? [UserDefaults sharedDefaults].appID : @"";
    [body setValue:[AppInfo sharedInfo].appVer forKey:@"appVsn"];
    [body setValue:appID forKey:@"appID"];
    [body setValue:[AppInfo sharedInfo].sysNm forKey:@"os2"];
    [body setValue:[AppInfo sharedInfo].osVer forKey:@"osVsn"];
    [body setValue:[AppInfo sharedInfo].UUID forKey:@"deviSri"];
    [body setValue:[AppInfo sharedInfo].platform forKey:@"deviModel"];
    [body setValue:@"Y" forKey:@"camYn"];
    [body setValue:[NSString stringWithFormat:@"%dx%d",(int)CGRectGetWidth([UIScreen mainScreen].frame),(int)CGRectGetHeight([UIScreen mainScreen].frame)]
            forKey:@"rslt"];
    [body setValue:@"Y" forKey:@"gpsYn"];
    [body setValue:@"Y" forKey:@"cmpaYn"];
    [body setValue:@"N" forKey:@"extmYn"];
     
//    long lJBFlag = scanJailBreak();
//#ifdef DEBUG
//    lJBFlag = 209L; // if jailbreak 210 +- 1
//    //   lJBFlag = 210L; // if jailbreak 210 +- 1
//    //   lJBFlag = 211L; // if jailbreak 210 +- 1
//    //   lJBFlag = 200L; // if jailbreak 200 +- 1 NORNAL
//#endif
//    NSLog(@"\n=============>>> lJDFlag as jbValue == [%ld]", lJBFlag);
//    [body setValue:[NSString stringWithFormat:@"%ld", lJBFlag] forKey:@"jbValue"];

    [self performSelectorOnMainThread:@selector(checkPureApp:) withObject:body waitUntilDone:NO];
}

-(void)dealloc {
    pureAppLib = nil;
}

-(NSString*)requestPureAppData:(NSMutableDictionary*)jsonEntry {
    pureAppLib = [[PureAppLib alloc] init];
    
    NSString * pureAppMsgString;
     
    pureAppMsgString = [pureAppLib firstRequest:[NSString stringWithFormat:@"%@%@", SERVER_URL, @"/pure.do"] : jsonEntry];
    
    
    NSLog(@"pureAppLib getVerificationResponseDatas : %@", [pureAppLib getVerificationResponseDatas]);

    NSLog(@"pureAppMsg : %@", pureAppMsgString);
    NSLog(@"Service == %@ %@ %@ %@ \ntimestamp = %@\n%@\n%@\n%@\n\n%@",
          [[pureAppLib getVerificationResponseData:@"appData"].jsonObjectForBase64 jsonStringPrint],
          [[pureAppLib getVerificationResponseData:@"urlData"].jsonObjectForBase64 jsonStringPrint],
          [[pureAppLib getVerificationResponseData:@"noticeData"].jsonObjectForBase64 jsonStringPrint],
          pureAppLib.getToken,
          [pureAppLib getVerificationResponseData:@"timestamp"],
          [[pureAppLib getVerificationResponseData:@"appDataV2"].jsonObjectForBase64 jsonStringPrint],
          [[pureAppLib getVerificationResponseData:@"encUrlData"].jsonObjectForBase64 jsonStringPrint],
          [[pureAppLib getVerificationResponseData:@"appMenu"].jsonObjectForBase64 jsonStringPrint],
          [[pureAppLib getVerificationResponseData:@"error"].jsonObjectForBase64 jsonStringPrint]);
    
    
    [UserDefaults sharedDefaults].recentPureAppDataDecryptString = [NSString stringWithFormat:@"Service == %@ %@ %@ %@ \ntimestamp = %@\n%@\n%@\n%@\n\n%@",
    [[pureAppLib getVerificationResponseData:@"appData"].jsonObjectForBase64 jsonStringPrint],
    [[pureAppLib getVerificationResponseData:@"urlData"].jsonObjectForBase64 jsonStringPrint],
    [[pureAppLib getVerificationResponseData:@"noticeData"].jsonObjectForBase64 jsonStringPrint],
    pureAppLib.getToken,
    [pureAppLib getVerificationResponseData:@"timestamp"],
    [[pureAppLib getVerificationResponseData:@"appDataV2"].jsonObjectForBase64 jsonStringPrint],
    [[pureAppLib getVerificationResponseData:@"encUrlData"].jsonObjectForBase64 jsonStringPrint],
    [[pureAppLib getVerificationResponseData:@"appMenu"].jsonObjectForBase64 jsonStringPrint],
    [[pureAppLib getVerificationResponseData:@"error"].jsonObjectForBase64 jsonStringPrint]];
                                                                    
    return pureAppMsgString;
}

-(void)checkPureApp:(NSMutableDictionary*)jsonEntry {
#if !(TARGET_IPHONE_SIMULATOR) //시뮬레이터가 아닐경우
#if 0 // nonePure mode
    [Request requestID:nonePure
                  body:jsonEntry
         waitUntilDone:NO
           showLoading:YES
             cancelOwn:self
              finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                  if(IS_SUCCESS(rsltCode)) {
                      //@"정상정인 앱입니다";
                      NSString * appData64Str = [pureAppLib getVerificationResponseData:@"appData"];
                      NSString * urlData64Str = [pureAppLib getVerificationResponseData:@"urlData"];
                      NSString * noticeData64Str = [pureAppLib getVerificationResponseData:@"noticeData"];
                      NSString *appDataV264Str =  [pureAppLib getVerificationResponseData:@"appDataV2"];
                      NSString *menuData =  [pureAppLib getVerificationResponseData:@"appMenu"];
                      NSString * encUrlDatatStr = [pureAppLib getVerificationResponseData:@"encUrlData"];
                      
                      
                      //메뉴
                      [AllMenu menu].appMenu = menuData.jsonObjectForBase64;
                      
                      //토큰
                      [AppInfo sharedInfo].pureAppToken = pureAppLib.getToken;
                      
                      //최초 timestamp
                      [PwdWrapper setTimeStamp:[[pureAppLib getVerificationResponseData:@"timestamp"] doubleValue]];
                
                      
                      //app Data
                      appData = appData64Str.jsonObjectForBase64;
                      
                      [AppInfo sharedInfo].ktCloudApiKey = [appData null_valueForKey:@"ktCloudApiKey"];
                      [AppInfo sharedInfo].ktCloudAuthUser = [appData null_valueForKey:@"ktCloudAuthUser"];
                      [AppInfo sharedInfo].ktCloudAuthKey = [appData null_valueForKey:@"ktCloudAuthKey"];
                      
                      //연계 url정보
                      NSDictionary *urlDic = urlData64Str.jsonObjectForBase64;
                      [AppInfo sharedInfo].updateUrl = [urlDic null_valueForKey:@"updateUrl"];
                      
                      [AppInfo sharedInfo].LGVODApi = [urlDic null_valueForKey:@"LGVODApi"];
                      [AppInfo sharedInfo].LGPrdtSrchAPI = [urlDic null_valueForKey:@"LGPrdtSrchAPI"];
                      [AppInfo sharedInfo].LGPayHisAPI = [urlDic null_valueForKey:@"LGPayHisAPI"];
                      [AppInfo sharedInfo].tablePayUrl = [urlDic null_valueForKey:@"tablePayUrl"];
                      
                      //공지정보
                      [AppInfo sharedInfo].notice = noticeData64Str.jsonObjectForBase64;
                      
                      // 암호화 api리스트 정보
                      NSMutableDictionary * encUrlData = [[NSMutableDictionary alloc] init];
                      if (encUrlDatatStr) {
                          [encUrlData addEntriesFromDictionary: encUrlDatatStr.jsonObjectForBase64];
                      }
                      [AppInfo sharedInfo].encUrlData = encUrlData;
                      
                      NSDictionary *appDataV2 = appDataV264Str.jsonObjectForBase64;
                      if (appDataV2) {
                          //속성 추가
                          @try{[AppInfo sharedInfo].isFaceEnable = appDataV2[@"appAttrData"][@"isFaceEnable"][@"val"];}@catch(NSException *exception){};
                          @try{[AppInfo sharedInfo].tablePayShowGbn = appDataV2[@"appAttrData"][@"tablePayShowGbn"][@"val"];}@catch(NSException *exception){};
                          @try{[AppInfo sharedInfo].isBlockChainEnable = appDataV2[@"appAttrData"][@"isBlockChainEnable"][@"val"];}@catch(NSException *exception){};
                          @try{[AppInfo sharedInfo].CONNCTLUSEYN = appDataV2[@"appAttrData"][@"CONNCTLUSEYN"][@"val"];}@catch(NSException *exception){};
                          
                          // url추가
                          @try{[AppInfo sharedInfo].tablePayUrl = appDataV2[@"urlData"][@"tablePayUrl"][@"val"];}@catch(NSException *exception){};
                          
                          // wkwebview 버전, 로그아웃 여부
                          [AppInfo sharedInfo].iosWkWebviewVsn = [appDataV2 null_valueForKey:@"iosWkWebviewVsn"];
                          [AppInfo sharedInfo].mnpcLogoutYn = [[appDataV2 null_valueForKey:@"mnpcLogoutYn"] boolValue];
                      }
                      
                      NSLog(@"Service == %@ %@ %@ %@ \ntimestamp = %@",
                            [appData jsonStringPrint],
                            [urlDic jsonStringPrint],
                            [(NSDictionary *)noticeData64Str.jsonObjectForBase64 jsonStringPrint],
                            [AppInfo sharedInfo].pureAppToken,
                            [result objectForKey:@"timestamp"]);
                      
                      if(appData == nil)
                      {
                          [BlockAlertView showBlockAlertWithTitle:@"알림" message:Net_Err_Msg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                              exit(0);
                          } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
                          return;
                      }
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:PureAppSuccessNotification object:appData];
                  } else {
                      [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                          exit(0);
                      } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
                  }
              }];
#else // pure mode(PureAppLib 사용)
    
    NSString * pureAppMsgString;
    
    pureAppMsgString = [self requestPureAppData:jsonEntry];
    
    if (pureAppMsgString == nil)
    {
        //토큰
        [AppInfo sharedInfo].pureAppToken = pureAppLib.getToken;
        
        //@"정상정인 앱입니다";
        NSString * appData64Str = [pureAppLib getVerificationResponseData:@"appData"];
        NSString * urlData64Str = [pureAppLib getVerificationResponseData:@"urlData"];
        NSString * noticeData64Str = [pureAppLib getVerificationResponseData:@"noticeData"];
        NSString * appDataV264Str =  [pureAppLib getVerificationResponseData:@"appDataV2"];
        NSString * menuData =  [pureAppLib getVerificationResponseData:@"appMenu"];
        NSString * encUrlDatatStr = [pureAppLib getVerificationResponseData:@"encUrlData"];
        NSString * theme = [pureAppLib getVerificationResponseData:@"theme"];
        
        NSString *semiMbrId = [pureAppLib getVerificationResponseData:@"semiMbrIdf"];
        
        //app Data
        appData = appData64Str.jsonObjectForBase64;
        if(appData == nil)
        {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:Net_Err_Msg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                exit(0);
            } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
            return;
        }
        
        if(semiMbrId){
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:semiMbrId options:0];
                    NSString *decodedSemiMbrIdString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            //        NSLog(@"%@", decodedSemiMbrIdString); // foo
                    //준회원 식별자로 푸시토큰 바로 등록한다.
                    [AppInfo sharedInfo].semiMbrId = decodedSemiMbrIdString;
        }
        
        //메뉴
        [AllMenu menu].appMenu = menuData.jsonObjectForBase64;
        
        [AppInfo sharedInfo].ktCloudApiKey = [appData null_valueForKey:@"ktCloudApiKey"];
        [AppInfo sharedInfo].ktCloudAuthUser = [appData null_valueForKey:@"ktCloudAuthUser"];
        [AppInfo sharedInfo].ktCloudAuthKey = [appData null_valueForKey:@"ktCloudAuthKey"];
        [AppInfo sharedInfo].setEfdsDataYn = [appData null_valueForKey:@"setEfdsDataYn"];
        
        //연계 url정보
        NSDictionary *urlDic = urlData64Str.jsonObjectForBase64;
        [AppInfo sharedInfo].updateUrl = [urlDic null_valueForKey:@"updateUrl"];
        
        [AppInfo sharedInfo].LGVODApi = [urlDic null_valueForKey:@"LGVODApi"];
        [AppInfo sharedInfo].LGPrdtSrchAPI = [urlDic null_valueForKey:@"LGPrdtSrchAPI"];
        [AppInfo sharedInfo].LGPayHisAPI = [urlDic null_valueForKey:@"LGPayHisAPI"];
        
        //공지정보
        [AppInfo sharedInfo].notice = noticeData64Str.jsonObjectForBase64;
        
        // 암호화 api리스트 정보
        NSMutableDictionary * encUrlData = [[NSMutableDictionary alloc] init];
        if (encUrlDatatStr) {
            [encUrlData addEntriesFromDictionary: encUrlDatatStr.jsonObjectForBase64];
        }
        [AppInfo sharedInfo].encUrlData = encUrlData;
        
        // 스플레시 테마 정보
        NSMutableDictionary * themeData = [[NSMutableDictionary alloc] init];
        if (theme) {
            [themeData addEntriesFromDictionary: theme.jsonObjectForBase64];
        }
        [AppInfo sharedInfo].themeData = themeData;
        
#ifdef DEBUG
        /*
        // for test
        NSDictionary * testTheme = @{
            @"ver" : @"1",
            @"color" : @"#ebe3db",
            @"img" : @{
                    @"2x" : @{
                            @"top" : @"https://img2.kbcard.com/img/PlatformApp/admin/apps/iOS/2x/imgSlogan@2x.png",
                            @"middle" : @"https://img2.kbcard.com/img/PlatformApp/admin/apps/iOS/2x/imgWinter360@2x.png",
                            @"bottom" : @"https://img2.kbcard.com/img/PlatformApp/admin/apps/iOS/2x/liivmateBi@2x.png",
                    },
                    @"3x" : @{
                            @"top" : @"https://img2.kbcard.com/img/PlatformApp/admin/apps/iOS/3x/imgSlogan@3x.png",
                            @"middle" : @"https://img2.kbcard.com/img/PlatformApp/admin/apps/iOS/3x/imgWinter360@3x.png",
                            @"bottom" : @"https://img2.kbcard.com/img/PlatformApp/admin/apps/iOS/3x/liivmateBi@3x.png",
                    }
                    
            }
        };
        [AppInfo sharedInfo].themeData = [NSMutableDictionary dictionaryWithDictionary:testTheme];
         
        */
        
#endif
        
        NSDictionary *appDataV2 = appDataV264Str.jsonObjectForBase64;
        if (appDataV2)
        {
            // url추가
            NSDictionary *urlData = [appDataV2 null_valueForKey:@"urlData"];
            [AppInfo sharedInfo].tablePayUrl = [urlData null_valueForKey:@"tablePayUrl"][@"val"];
            [AppInfo sharedInfo].ntsHomepageUrl = [urlData null_valueForKey:@"ntsHomepageUrl"][@"val"];
            
            //속성 추가
            NSDictionary *appAttrData = [appDataV2 null_valueForKey:@"appAttrData"];
            [AppInfo sharedInfo].isFaceEnable = [appAttrData null_valueForKey:@"isFaceEnable"][@"val"];
            [AppInfo sharedInfo].tablePayShowGbn = [appAttrData null_valueForKey:@"tablePayShowGbn"][@"val"];
            [AppInfo sharedInfo].isBlockChainEnable = [appAttrData null_valueForKey:@"isBlockChainEnable"][@"val"];
            [AppInfo sharedInfo].CONNCTLUSEYN = [appAttrData null_valueForKey:@"CONNCTLUSEYN"][@"val"];
            [AppInfo sharedInfo].benefitStTime = [appAttrData null_valueForKey:@"benefitStTime"][@"val"];
            [AppInfo sharedInfo].appBarUseYn = [appAttrData null_valueForKey:@"appBarUseYn"][@"val"];
            [AppInfo sharedInfo].keypadType = [appAttrData null_valueForKey:@"keypadType"][@"val"];
            [AppInfo sharedInfo].isIdfaDisable = [[appAttrData null_valueForKey:@"isIdfaDisable"][@"val"] boolValue];
            
            if (@available(iOS 14.0, *)) {
            } else {
                [AppInfo sharedInfo].isIdfaDisable = NO;
            }
            
            // 기본값 라온처리
            [AppInfo sharedInfo].keypadType = [AppInfo sharedInfo].keypadType? [AppInfo sharedInfo].keypadType : @"1";
            
#if 0
            //wkwebview 버전
            [AppInfo sharedInfo].iosWkWebviewVsn = [appAttrData null_valueForKey:@"iosWkWebviewVsn"][@"val"];
            //로그아웃 여부
            [AppInfo sharedInfo].mnpcLogoutYn = [[appAttrData null_valueForKey:@"mnpcLogoutYn"][@"val"] boolValue];
#else
            // wkwebview 버전, 로그아웃 여부
            [AppInfo sharedInfo].iosWkWebviewVsn = [appDataV2 null_valueForKey:@"iosWkWebviewVsn"];
            [AppInfo sharedInfo].mnpcLogoutYn = [[appDataV2 null_valueForKey:@"mnpcLogoutYn"] boolValue];
#endif


            //최초 timestamp(키페드타입까지 다 파싱후에 값을 셋팅해야함)
            [PwdWrapper setTimeStamp:[[pureAppLib getVerificationResponseData:@"timestamp"] doubleValue]];
        }
        
        isPureFinished = YES;
        
        [self finishedCallback];
    }
    else
    {
        
        NSString * info = [NSString stringWithFormat:@"pure 실패: %@ / %@ / %@ / %@ / %@"
                           , pureAppMsgString
                           , [AppInfo sharedInfo].platform
                           , [AppInfo sharedInfo].osVer
                           , [AppInfo sharedInfo].appVer
                           , [UserDefaults sharedDefaults].appID];
                   
//        CLS_LOG(@"리브메이트 탈옥체크 :%@", info);
        [[FIRCrashlytics crashlytics] logWithFormat:@"탈옥체크:[%@]",info];
        
        if ([pureAppMsgString compare:ERR_AUTH_MSG] == NSOrderedSame)
        {
            //@"인증 오류"
            pureAppMsgString = JB_Err_Msg;
        }
        else
        {
            //@"네트워크 오류";
            pureAppMsgString = Net_Err_Msg;
        }
        
        ProcessesDoKill(pureAppMsgString);
    }
#endif
#else    //!(TARGET_IPHONE_SIMULATOR)
#endif    //!(TARGET_IPHONE_SIMULATOR)
    
}

#pragma mark - Finish Call Back (Ani & Pure)
- (void)finishedCallback {
    if(isAniFinished && isPureFinished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PureAppSuccessNotification object:self->appData];
        });
        
    }
}

#pragma mark - FidoFirebase Remote Config
- (void)executeFidoFirebaseRemoteConfig {
    
    // default서버 = 한국전자인증
    [[UserDefaults sharedDefaults] setIsFidoTestTOBE:YES];
    
    // FireBase remote config
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    
    long expirationDuration = 0;
    
    [remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"Config fetched!");
            [remoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
                
            }];
            
            if ([remoteConfig[@"fido_ios_lib_type"].stringValue isEqualToString:@"kb"]) {
                NSLog(@"Fido kb");
                [[UserDefaults sharedDefaults] setIsFidoTestTOBE:YES];
            }
            else {
                NSLog(@"Fido vp");
                [[UserDefaults sharedDefaults] setIsFidoTestTOBE:NO];
            }
            
        } else {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error.localizedDescription);
            
        }
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
