//
//  AppInfo.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 20..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "AppInfo.h"
#import "PentaPinViewController.h"
#import "KCLCommonWidgetHeader.h"
#include <sys/sysctl.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <MPushLibrary/MPushLibrary.h>

// BuzzAd (버즈빌 보고쌓기)
#import <BuzzAdBenefit/BuzzAdBenefit.h>

static AppInfo *_sharedInfo = nil;
@implementation AppInfo 
{
	long long _benefitStTime;
}


+(AppInfo *)sharedInfo
{
	if(_sharedInfo == nil)
	{
		_sharedInfo = [[AppInfo alloc] init];
	}
	return _sharedInfo;
}

+(UserInfo *)userInfo
{
	return _sharedInfo.userInfo;
}

-(id)init
{
	self = [super init];
	if(self)
	{
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char * name = malloc(size);
		sysctlbyname("hw.machine", name, &size, NULL, 0);
		_platform = [[NSString alloc] initWithUTF8String:name];
		free(name);
		
//		_platform = [[UIDevice currentDevice].model copy];
		
		self.UUID = [UIDevice currentDevice].identifierForVendor.UUIDString;
		
		[self willEnterForeground:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	}
	return self;
}

-(void)willEnterForeground:(NSNotification*)noti
{
	_useBiometrics = UseBiometricsNone;
    _typeBiometrics = TypeTouchID;
    
	if(IOS_VERSION_OVER_8)
	{
		LAContext *context = [[LAContext alloc] init];
		NSError *error = nil;
        if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
			_useBiometrics = UseBiometricsEnabled;
            _lastBiometricsError = nil;
        } else {
			_useBiometrics = UseBiometricsDisabled;
			_lastBiometricsError = error;
			
			// 지문등록 후 기기에서 지문 지운 경우 처리 (지문등록 안된 걸로) - // ???? TODO : 확인 요망
			/*
			if (error.code == -7 || error.code == -5)	//  kLAErrorTouchIDNotEnrolled == -7, kLAErrorPasscodeNotSet == -5
			{
				[UserDefaults sharedDefaults].useFido = FidoUseSettingNone;
			}
			*/
		}
		
        if (@available(iOS 11.0, *)) {
            if (context.biometryType == LABiometryTypeFaceID ) {
                _typeBiometrics = TypeFaceID;
            } 
        }
        
        //FaceID 막음 처리
        // faceid 이고 서버가 disable일경우 사용불가!
        if (_typeBiometrics == TypeFaceID
            && ![@"Y" isEqualToString:_isFaceEnable]) {
            _useBiometrics = UseBiometricsServerDisableFaceID;
        }
        
		context = nil;
	}
}

-(NSString*)appVer
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

-(NSString*)managerVer
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

-(NSString*)osVer
{
	return [UIDevice currentDevice].systemVersion;
}

-(NSString*)sysNm
{
	return @"iOS";//[UIDevice currentDevice].systemName;
}

//알림함 혜택채널 보여줄 start시간
-(void)setBenefitStTime:(NSString*)benefitStTime
{
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat:@"yyyyMMddHHmm"];
	NSDate* newDate = [fmt dateFromString:benefitStTime];
	_benefitStTime = newDate.timeIntervalSince1970 * 1000.0;
}

-(long long)benefitStTime
{
	return _benefitStTime;
}

//자동로그인
-(void)setAutoLogin:(BOOL)autoLogin
{
	_autoLogin = autoLogin;
	
	NSUserDefaults *sharedUserDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	[sharedUserDefault setObject:(autoLogin ? @"Y" : @"N") forKey:WIDGET_AUTO_LOGIN];
	[sharedUserDefault setObject:(self.isLogin ? @"Y" : @"N") forKey:WIDGET_USER_LOGINED];
	[sharedUserDefault synchronize];
}

-(void)reloadPoint
{
	NSMutableDictionary *param = [NSMutableDictionary dictionary];
	[param setValue:[AppInfo userInfo].custNo forKey:@"custNo"];
    
    // ver.3 위젯 포인트리 조회(세션 없음) (KATPH01)
    [Request requestID:KATPH01
                  body:param
         waitUntilDone:NO
           showLoading:NO
             cancelOwn:self
              finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                  if(IS_SUCCESS(rsltCode))
                  {
                      NSString *point = [result null_valueForKey:@"searchPoint"];
                      [self setPoint:([point isKindOfClass:[NSNumber class]] ? ((NSNumber*)point).stringValue : point)];
                  }
              }];
}

-(void)setPoint:(NSString *)point
{
	_userInfo.point = point;
	[self savePointreeForWidget];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadPointNotification object:point];
}

-(NSString*)point
{
	return _userInfo.point;
}

// for widget
- (void)savePointreeForWidget
{
	if (_userInfo.point.length > 0)
	{
		NSString *string = _userInfo.point;
		//if (string.length == 0) string = @"0";
		
		NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
		[userDefault setObject:string forKey:WIDGET_POINTREE];
		[userDefault synchronize];
	}
}

//로그아웃시 리셋항목
-(void)logoutReset
{
//    self.pwdErrNotms = 0;
	self.point = nil;
	self.autoLogin = NO;
	self.openApiAuthTokens = nil;
	
	self.userInfo = nil;
		
	[self clearCookie];
    
    // BuzzAd (버즈빌 보고쌓기) - 로그아웃 후에 설정한 UserProfile, Preference 초기화
    [BuzzAdBenefit setUserProfile:nil];
    [BuzzAdBenefit setUserPreference:nil];
}

-(BOOL)isLogin
{
	return _userInfo && _isJoin;
}

- (void)clearCookie {
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:SERVER_URL]];
	
	for (NSHTTPCookie *cookie in cookies)
	{
		NSLog(@"%@",cookie);
        if ([cookie.name isEqualToString:@"SESSION"]) {
            NSLog(@"clearCookie %@",cookie);
            [cookieStorage deleteCookie:cookie];
        }
	}
}

-(void)performLogin:(SuccessLoginCallBack)loginCallback
{
	// ???? TODO : 회원가입, 비밀번호 초과 처리 등 확인 요망 (performLogin 수정 요망)

    //live메이트 3특정 페이지에서 login 호출해서 임시 리턴 처리함.
//    if(self.isLogin){
//        loginCallback(YES, nil, nil);
//        return;
//    }
    
	if(_isJoin == NO)
	{//회원가입이 안되었을시 본인인증 페이지로....
         // Ver. 3 회원가입(MYD_JO0100)

        [[AllMenu delegate] navigationWithMenuID:MenuID_V3_MateJoin
                                        animated:YES
                                          option:NavigationOptionPush
                                        callBack:nil];

        if(loginCallback)
            loginCallback(NO, nil, nil);
        
		return;
	}
	
	if(_pwdErrNotms >= 5)
	{//비밀번호 오류 5회 초과시 비밀번호 찾기 페이지로
		[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"고객님의 비밀번호 5회 입력 초과되어 본인인증이 필요합니다." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            // Ver. 3 MenuID_V3_PwdReset 코드 추가(MYD_LO0103)
            [[AllMenu delegate] navigationWithMenuID:MenuID_V3_PwdReset
                                            animated:YES
                                              option:NavigationOptionPush
                                            callBack:nil];
		} cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
        
        if(loginCallback)
            loginCallback(NO, nil, nil);
		return;
	}
    // Ver. 3 로그인 추가
//    if(NO) { // for test - Ver. 3 로그인 추가
        [PwdWrapper showPwd:^(id  _Nonnull vc) {
                [PwdWrapper setTitle:vc value:@"비밀번호 6자리를"];
                [PwdWrapper setSubTitle:vc value:@"입력해 주세요."];
                [PwdWrapper setMaxLen:vc value:PWD_PIN_MAX_LEN];
                [PwdWrapper setShowPwdResetBtn:vc value:YES];
        } target:KATL001 callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
            
            if(isCancel == NO)
            {
                if(dismiss)
                    (*dismiss) = NO;
                [self sendLoginRequestWithPwdDic:[PwdWrapper blockChainWithKeyNm:vc keyNm:@"pwd"] success:^(BOOL success, NSString *errCD, NSDictionary* result) {
                    if(success)
                    {
                        // BuzzAd (버즈빌 보고쌓기) - 개발 가이드 적용 (로그인 성공시에 버즈빌 유저 프로필 저장)
                        [self setBuzzAdUserProfile:result];
                        
                        //성공했을경우만 창을 닫는다
                        [vc dismissViewControllerAnimated:YES completion:^{
                            if(loginCallback) {
                                // 기회원에 대해 본인인증이 완료 후에 메인으로 이동하게 수정
                                loginCallback(YES, errCD, result);
                            }
                        }];
                    }
                    else
                    {
                        if(self->_pwdErrNotms >= 5)
                        {
                            [vc dismissViewControllerAnimated:YES completion:^{
                                if(loginCallback)
                                    loginCallback(NO, errCD, nil);
                            }];
                        }
                        else
                            [PwdWrapper resetPwd:vc];
                    }
                }];
            }
            else
            {
                if(loginCallback) {
                    // Ver. 3 MenuID_V3_PwdReset 코드 추가(MYD_LO0103)
                    loginCallback(NO, [PwdWrapper getResetPWClecked:vc]?MenuID_V3_PwdReset:nil, nil);
                }
            }
        }];
}

-(void)sendLoginRequestWithPwdDic:(NSDictionary *)pwdDic success:(SuccessLoginCallBack)callback
{
	if(_isJoin == NO || (pwdDic == nil && _autoLogin == NO))
	{
		if(callback)
			callback(NO, nil, nil);
		return;
	}

	NSMutableDictionary *body = [NSMutableDictionary dictionary];
	[body setValue:[UserDefaults sharedDefaults].appID forKey:@"appId"];
	[body setValue:self.UUID forKey:@"equipNo"];
	[body setValue:self.platform forKey:@"modelNm"];
	[body setValue:self.osVer forKey:@"osVer"];

    if(pwdDic)
		[body addEntriesFromDictionary:pwdDic]; 

        // Ver. 3 로그인 추가
        [Request requestID:KATL001
                      body:body
             waitUntilDone:NO
               showLoading:YES
                 cancelOwn:self
                  finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                      if(IS_SUCCESS(rsltCode))
                      {
                          self.userInfo = [[UserInfo alloc] init];
                          
                          
                          self.userInfo.custNo    = [result null_objectForKey:@"custNo"];
                          self.userInfo.custNm    = [result null_objectForKey:@"custNm"];
                          self.userInfo.mbspId    = [result null_objectForKey:@"mbspId"];
                          self.userInfo.kbPin     = [result null_objectForKey:@"kbPin"];
                          self.userInfo.age       = [result null_objectForKey:@"age"];
                          self.userInfo.moblNo    = [result null_objectForKey:@"moblNo"];
                          self.userInfo.gender    = [result null_objectForKey:@"gender"]; //성별추가
                          self.userInfo.semiMbrIdf = [result null_objectForKey:@"semiMbrIdf"]; // push 추가
                          self.userInfo.custGbnCd = [result null_objectForKey:@"custGbnCd"]; //회원정보구분값 (GA360 4번째 값)
                          
                          
                          //포인트리
                          self.userInfo.point = [[result null_objectForKey:@"bamt"] stringValue];
                          self.point = self.userInfo.point;
                          
                          
                          //ga360값 셋팅
                          self.userInfo.ga_custGbnCd = self.userInfo.custGbnCd;
                          self.userInfo.ga_age = [NSString stringWithFormat:@"%d", (int)self.userInfo.age.integerValue / 10 * 10];
                          self.userInfo.ga_gender = self.userInfo.gender;
                          self.userInfo.ga_starClubGrade = [result null_objectForKey:@"starClubGrade"];
                          self.userInfo.ga_bamt = self.point.integerValue > 0 ? @"1" : @"0";
                          self.userInfo.ga_scrpTgFiorMdulsYN = [@"Y" isEqualToString:[result null_objectForKey:@"scrpTgFiorMdulsYN"]] ? @"1" : @"0";
                          self.userInfo.ga_scrpTgFiorMduls = nil2Str([result null_objectForKey:@"scrpTgFiorMduls"]);
                          self.userInfo.ga_chrgWayRegYn = [@"Y" isEqualToString:[result null_objectForKey:@"chrgWayRegYn"]] ? @"1" : @"0";
                          self.userInfo.ga_autoChrgRegYn = [@"Y" isEqualToString:[result null_objectForKey:@"autoChrgRegYn"]] ? @"1" : @"0";
                          self.userInfo.ga_cardOwnGbnCd = [@"Y" isEqualToString:[result null_objectForKey:@"autoChrgRegYn"]] ? @"1" : @"0";
                          self.userInfo.ga_kbPinEnc = [result null_objectForKey:@"kbPinEnc"];
                          self.userInfo.ga_semiMbrIdfEnc = [result null_objectForKey:@"semiMbrIdfEnc"];
                          
                    
                          //푸시설정
                          self.userInfo.pushUseRecv = [result null_objectForKey:@"pushUseRecv"];
                          self.userInfo.pushEvtRecv = [result null_objectForKey:@"pushEvtRecv"];
                          self.userInfo.pushTermYn = [result null_objectForKey:@"pushTermYn"];
                          
                          
                          //샌드버드 관련정보
                          self.userInfo.chnlList = [result null_objectForKey:@"chnlList"];//샌드버드 알리미채널리스트
                          self.userInfo.sendBirdToken = [result null_objectForKey:@"msngToken"];//토큰
                          self.userInfo.cId        = [result null_objectForKey:@"cId"];//외부공개용ID - 샌드버드 ID

                          //가맹점 회원(pUser,mOwnr,mMng,mEmp)
                          self.userInfo.userAppMenuGbn = [result null_objectForKey:@"userAppMenuGbn"];
                          //가맹점 원장여부
                          self.userInfo.mbrmchJoinAblYn = [result null_objectForKey:@"mbrmchJoinAblYn"];
                          
                          self.autoLogin = [[result null_objectForKey:@"autoLogin"] boolValue];
                          //로그인에 성공할경우 비밀번호 오류횟수를 초기화한다.???
                          self->_pwdErrNotms = 0;
                          
                          // 자산연동 스크래핑 연동기관 유/무
                          self.userInfo.scrpTgFiorMdulsYN = [result null_objectForKey:@"scrpTgFiorMdulsYN"];
                          // 자산연동 스크래핑 PFM동의 유/무
                          self.userInfo.astTermYn = [result null_objectForKey:@"astTermYn"];
                          
                          // BuzzAd (버즈빌 보고쌓기) - 개발 가이드 적용 (로그인 성공시에 버즈빌 유저 프로필 저장)
                          [self setBuzzAdUserProfile:result];
                          
                          // 푸시 유저등록
                          if (self.userInfo.semiMbrIdf) { // push 추가
                              
                              UINavigationController *mainCon;
                              KCLAppMainNavigationController *navi = (id)[AllMenu delegate];
                              mainCon = navi;
                              
                              [[PushManager defaultManager] registerServiceAndUser:mainCon
                                                                                clientUID:self.userInfo.semiMbrIdf
                                                                               clientName:[UserDefaults sharedDefaults].appID
                                                                        completionHandler:^(BOOL success) {
                                         if (success) {NSLog(@"success registerServiceAndUser");}
                              }];
                          }
                          [[NSNotificationCenter defaultCenter] postNotificationName:LoginStatusChangedNotification object:nil];
                          
                          // cookie 복사
                          {
                              NSMutableArray *cookies = [[NSMutableArray alloc] init];
                              NSArray *allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
                              for (NSHTTPCookie *cookie in allCookies)
                              {
                                  if ([cookie.name isEqualToString:@"SESSION"])
                                  {
                                       NSLog(@"sendLoginRequestWithPwdDic 560 %@",cookie);
                                      [cookies addObject:cookie];
                                  }
                              }
                              
                              if (cookies.count > 0)
                              {
                                  NSLog(@"\[NSCOOKIE -> WKCOOKIE] (1.1) - LOGIN RESPONSE 쿠키 복사 %@", cookies);
                                  [[NSNotificationCenter defaultCenter] postNotificationName:MateRequestCookieNotification object:nil userInfo:@{@"cookies":cookies}];
                              }
                          }
                          
                          if(callback)
                              callback(YES, nil, result);
                          
                          // 위젯 처리 위해 저장
                          {
                              NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
                              [userDefault setObject:@"Y" forKey:WIDGET_USER_LOGINED];
                              [userDefault synchronize];
                          }
                          
                          // 로그인시 메인화면 리로드 위해 설정
                          [APP_DELEGATE mainViewController].menuID_main = MenuID_V4_MainPage;
                      }
                      else
                      {
                          //로그인 실패시 자동로그인 플레그를 NO로 셋팅한다. 오류팝업은 최초 자동로그인에는 적용하지 않는다.
                          if(self->_autoLogin == NO && message.length)
                          {
                              [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                                  if(callback)
                                      callback(NO, rsltCode, nil);
                              } cancelButtonTitle:AlertConfirm buttonTitles:nil];
                          }
                          else
                          {
                              if(callback)
                                  callback(NO, rsltCode, nil);
                          }
                          
                          self->_autoLogin = NO;
                          if([ERRCODE_PinErr isEqualToString:rsltCode])
                              self->_pwdErrNotms++;
                          
                      }
                  }];
    
}

-(void)performLogout:(SuccessCallBack)callback
{
	[self logoutReset];
    
    if(callback){
		callback(YES);
    }
    
	[[NSNotificationCenter defaultCenter] postNotificationName:LoginStatusChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:MenuViewReloadNotification object:nil];
}

- (void)setIsJoin:(BOOL)isJoin
{
	_isJoin = isJoin;
	
	if (!isJoin)
	{
		NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
		[userDefault removeObjectForKey:WIDGET_CUST_NO];
		[userDefault removeObjectForKey:WIDGET_AUTO_LOGIN];
		[userDefault removeObjectForKey:WIDGET_USER_LOGINED];
		[userDefault removeObjectForKey:WIDGET_POINTREE];
		[userDefault removeObjectForKey:WIDGET_PAYMENT_TYPE];
		[userDefault removeObjectForKey:WIDGET_HEADER];
		[userDefault removeObjectForKey:WIDGET_SERVER_URL];
		[userDefault removeObjectForKey:FAIL_MESSAGE];
        // for test - ver.3
        [userDefault removeObjectForKey:WIDGET_LIIVMATE3];
        
		[userDefault synchronize];
	}
}

// BuzzAd (버즈빌 보고쌓기)
- (void)setBuzzAdUserProfile:(NSDictionary *)loginDataDic {
    // 유저 프로파일 생성시 생년월일, 고객의 고유값, 성별이 필요
    NSString *birth = [loginDataDic objectForKey:@"birthDt"];
//    NSString *custNo = [loginDataDic objectForKey:@"custNo"];
    NSString *gender = [loginDataDic objectForKey:@"gender"]; // (BABUserGenderMale or BABUserGenderFemale)
    NSString *cID = [loginDataDic objectForKey:@"cId"];
    
    NSLog(@"birth == %@", birth);
    NSLog(@"gender == %@", gender);
    NSLog(@"cID == %@", cID);
    NSLog(@"AppInfo CID == %@", [AppInfo sharedInfo].userInfo.cId);
            
    NSString *birthYear = [birth substringToIndex:4];

    NSLog(@"birthYear == %@", birthYear);
    NSLog(@"birthYear integerValue == %ld", (long)[birthYear integerValue]);
    NSLog(@"[gender isEqualToString: == %i", [gender isEqualToString:@"1"]);
    
    // gender 서버에서 내려 오는 값에 공백이 존재 ("gender" = "1 " <- 강제 trim)
    BABUserProfile *userProfile = [[BABUserProfile alloc] initWithUserId:[AppInfo sharedInfo].userInfo.cId birthYear:[birthYear integerValue] gender: [gender.trim isEqualToString:@"1"] == YES ? BABUserGenderMale : BABUserGenderFemale]; // 유저 프로파일 버즈빌에 전달 (샘플에 있는 부분)ofile

    // 유저프로파일 생성자 두개가 있음 (가이드상에 있는 생년월일, 고객번호, 성별을 받아서 생성하는 부분은 확인 필요)
    [BuzzAdBenefit setUserProfile:userProfile];
    
    BABUserPreference *userPreference = [[BABUserPreference alloc] initWithAutoPlayType:BABVideoAutoPlayDisabled]; // 동영상 광고가 자동재생되지 않음
    [BuzzAdBenefit setUserPreference:userPreference];
    
    
    // 버즈빌에 확인 필요(가이드 확인 필요)
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBABAd) name:BABSessionRegisteredNotification object:nil];

}
@end
