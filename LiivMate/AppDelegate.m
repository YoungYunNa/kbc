//
//  AppDelegate.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 18..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "AppDelegate.h"
#import "KCLIntroViewController.h"
#import "SplashMessageView.h"

#import "HybridActionManager.h"
#import "KCLCommonWidgetHeader.h"
#import "WebViewController.h"
#import "SplashScreenManager.h"
#import <MPushLibrary/MPushLibrary.h>
// BuzzAd (버즈빌 보고쌓기)
#import <BuzzAdBenefit/BuzzAdBenefit.h>
#import <sys/utsname.h>
#import "PushReceiver.h"
#import "KBFidoManager.h"
#import <UserNotifications/UserNotifications.h>

typedef void (^SendGaCampainUrlBlock)(void);

#pragma mark - SplashMessage (하단 토스트메시지)
@interface AppDelegate () <UNUserNotificationCenterDelegate> {
	SplashMessageView* _splashMessageView;
    SendGaCampainUrlBlock sendGaCampainUrlBlock;
}
- (void)showSplashMessage:(NSString*)message autohide:(BOOL)autohide withShowTop:(BOOL)showTop; // 하단토스트 메시지 (메시지내용, 자동사라짐, )

@end

void showSplashMessage(NSString *msg, BOOL autoHide, BOOL showTop) {
	([((AppDelegate*)[UIApplication sharedApplication].delegate) showSplashMessage:msg autohide:autoHide withShowTop:showTop]);
}


@implementation AppDelegate
#pragma mark - Push
//푸시토큰
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	[AppInfo sharedInfo].pushToken = devToken;
    [[PushManager defaultManager] application:application didRegisterForRemoteNotificationsWithDeviceToken:devToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //백그라운드 모드에서 호출하는 경우에 사용
    [[PushManager defaultManager] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushManager defaultManager] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSLog(@"userNotificationCenter Userinfo %@",response.notification.request.content.userInfo);
    
    [[PushManager defaultManager] application:[UIApplication sharedApplication] didReceiveRemoteNotification:response.notification.request.content.userInfo];
    completionHandler();
}

-(BOOL)showRemoteNotificationPopup:(NSDictionary *)userInfo {
	NSLog(@"showRemoteNotificationPopup %s - %@",__func__,userInfo); // SendBird 삭제 - start
    NSString * message = [userInfo null_valueForKey:@"aps"][@"alert"];
    NSString * ext = [userInfo null_valueForKey:@"mps"][@"ext"];
    NSArray *extList = [ext componentsSeparatedByString:@"|"];
    NSString * target = [extList lastObject];
    target = MenuID_V3_Notification; //UMS 전문에서 현재 지원치 않아 알림함으로 이동토록 함
    if( ([target isEqualToString:@""] == NO) & ([target rangeOfString:@"http"].location == 0 || [target rangeOfString:@"MYD_"].location == 0 || [target rangeOfString:@"MYD4_"].location == 0)){
                    [[AllMenu delegate] sendBirdDetailPage:target callBack:^(ViewController *vc){
                    }];
    } else {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            } cancelButtonTitle:AlertConfirm buttonTitles: nil];
    }
    
    NSDictionary *kbPush = [userInfo objectForKey:@"KBPush"];
    NSLog(@"kbPush == %@", kbPush);
    
	return NO;
}

#pragma mark - OpenURL
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
	TXLog(@"[OPEN URL] %@, ROOT = %@",url.absoluteString,self.window.rootViewController);
    
    if ([url.absoluteString.lowercaseString containsString:@"utm_source"]) {
        [WebViewController sendGa360Native:NO p1:@"" p2:@"" p3:@"" campainUrl:url.absoluteString];
    }

    // Cat Crush 인증 프로세스 설정
    NSString *hostNm = url.host;
    
    if([hostNm isEqualToString:@"tablepay"]) {
        [AppInfo sharedInfo].isTablePayCall = YES;
        [AppInfo sharedInfo].tablePayParamInfo = [EtcUtil parseUrlWithoutDecoding:url.query];
    }
	
	if(application.applicationState == UIApplicationStateActive) {
		[self schemeActionWithURL:url];
	} else {
        if([self.window.rootViewController isKindOfClass:[KCLIntroViewController class]]) {//인트로 화면인경우
			[AppInfo sharedInfo].launchOptions = [NSDictionary dictionaryWithObjectsAndKeys:url, UIApplicationLaunchOptionsURLKey, nil];
		} else {
			if(AppInfo.sharedInfo.isLogin && AppInfo.sharedInfo.userInfo.custNo) {//로그인상태였으면 킵얼라이브 체크후 처리해야함.
				[AppInfo sharedInfo].launchOptions = [NSDictionary dictionaryWithObjectsAndKeys:url, UIApplicationLaunchOptionsURLKey, nil];
				if([MateRequest isSendKeepAlive] == NO) {//어플을 백그라운드로 보내지 않고 위젯등에서 스킴액션을통해 들어온경우
					[Request sendKeepAlive:NO callback:^{
						[AppInfo sharedInfo].launchOptions = nil;
						[self schemeActionWithURL:url];
					}];
				}
				//else 어플이 백그라운드로 나가있다가 스킴액션으로 들어온경우 -> applicationWillEnterForeground: 에서 처리
			}
			else {
				[self schemeActionWithURL:url];
			}
		}
	}
	return YES;
}

#pragma mark - continueUserActivity Universal link(유니버셜 링크처리)
- (BOOL)application:(UIApplication *)app continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    NSLog(@"UniversalLink userActivity.webpageURL :%@", userActivity.webpageURL);
    BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL completion:^(FIRDynamicLink * _Nullable dynamicLink, NSError * _Nullable error) {
        NSLog(@"UniversalLink : %@", dynamicLink.url);
        NSString * url = [dynamicLink.url absoluteString];
        
        if ([url.lowercaseString containsString:@"utm_source"]) {
            [WebViewController sendGa360Native:NO p1:@"" p2:@"" p3:@"" campainUrl:url];
        }
    }];
    
    return handled;
}

#pragma mark - sendDynamicLink (Firebase 동적 링크 처리)
- (void)applcation:(UIApplication *)app sendDynamicLink:(NSURL *)url
{
    NSDictionary * param = [EtcUtil parseUrl:url.query];
    NSString * strUrl = url.absoluteString;
    NSString * titleNm = param[@"titleNm"];
    NSString * screanID = param[@"screnId"];
    NSString * cd14 = param[@"cd14"];
    
    if ([strUrl.lowercaseString containsString:@"utm_source"]) {

        sendGaCampainUrlBlock = ^(void) {
            [WebViewController sendGa360Native:NO p1:@"" p2:cd14 p3:titleNm campainUrl:strUrl.stringByUrlDecoding];
        };
    }
    
    if (screanID) {
        // 이동로직 구현
        NSURL * moveUrl = [NSURL URLWithString:[NSString stringWithFormat:@"liivmate://call?cmd=move_to&id=%@",screanID]];
        [self application:app openURL:moveUrl options:@{}];
    }
}

//스킴액션을 이용한 화면이동처리.
-(BOOL)schemeActionWithURL:(NSURL *)url {
	if(url.runAction)
	{
		return YES;
	}
	return NO;
}

#pragma mark - didFinishLaunchingWithOptions
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	antiDebugging();
    
    [WKWebsiteDataStore.defaultDataStore fetchDataRecordsOfTypes:WKWebsiteDataStore.allWebsiteDataTypes completionHandler:^(NSArray<WKWebsiteDataRecord *> * records) {
        for(WKWebsiteDataRecord *record in records){
            [WKWebsiteDataStore.defaultDataStore removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                //delete callback
            }];
        }
    }];
    
    // BuzzAd start
    // BuzzAd (버즈빌 보고쌓기) - 개발 가이드 적용 (최초 광고 요청(버즈빌 SDK 사용전에만 불리면 되나 앱이 실행 될 때 권장을 하여 현재 위치에 추가)
    NSLog(@"BUZZ_FEED_APP_ID %@", BUZZ_FEED_APP_ID);
    NSLog(@"BUZZ_FEED_UNIT_ID %@", BUZZ_FEED_UNIT_ID);
    BABConfig *config = [[BABConfig alloc] initWithAppId:BUZZ_FEED_APP_ID environment:BABEnvProduction logging:YES];
    [BuzzAdBenefit initializeWithConfig:config];

    
#ifdef DEBUG
    [NSClassFromString(@"CrashController") performSelector:@selector(start)];
#endif
    [FIRApp configure];
    
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
	
	// Override point for customization after application launch.
	application.statusBarHidden = NO;
	application.statusBarStyle = UIStatusBarStyleLightContent;
	[AppInfo sharedInfo].launchOptions = launchOptions;
	NSLog(@"%@",launchOptions);
	if ([UINavigationBar respondsToSelector:@selector(appearance)])
	{
		NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
								
												   FONTSIZE(18),NSFontAttributeName,
												   UIColorFromRGB(0x333333), NSForegroundColorAttributeName,
												   nil];
		
		[[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
	}
	
	//인트로뷰컨트롤러에서 위변조 체크후 노티피케이션
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLiivmateApplication) name:StartLiivMateNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pureAppSuccess:) name:PureAppSuccessNotification object:nil];
    // splash 다운로드 완료 노티피케이션
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSplashImage) name:SplashImageDownloadNotification object:nil];
    
    //Fido 설정
    [[KBFidoManager sharedInstance] initFido:FIDO_LICENSE];
    [[KBFidoManager sharedInstance] setFidoServiceName:FIDO_SERVICE_NAME];
    [[KBFidoManager sharedInstance] setFidoServerUrl:FIDO_SERVER_URL];
	
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];

    //ilyong.common.applaunch:3.0사용하려면 UserDefault init에 setIsLiveMate3:YES 로 설정
    [self startLiivmateApplication];
    [_window makeKeyAndVisible];
    
    [[PushManager defaultManager] application:application didFinishLaunchingWithOptions:launchOptions];
    [[PushManager defaultManager] initilaizeWithDelegate:[[PushReceiver alloc] init]];

    //GoogleAnalytics 초기화
    GAI *gai = [GAI sharedInstance];
    [gai trackerWithTrackingId:@"UA-65962490-15"];
    gai.trackUncaughtExceptions = YES;
    gai.logger.logLevel = kGAILogLevelVerbose;
    gai.dispatchInterval = 1;
    id<GAITracker>tracker = [[GAI sharedInstance] defaultTracker];
    tracker.allowIDFACollection = YES;

    // 자동 잠금 방지 코드 추가
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    return YES;
}


#pragma mark - startLiivmateApplication (서비스 시작 - IntroView)
-(void)startLiivmateApplication {
    NSLog(@"%s",__FUNCTION__);
    /*
     fabric 패치 로그인후 백그라운드에서 시간이 지나 앱 진입시 세션이 끊겼을때 해당 부분을 재호출하는데 만약 리퀘스트가 쌓여 연속으로 호출될시
     KCLIntroViewController에서 퓨어로직이 끝나지 않았음에도 재호출이 되어 퓨어 라이브러리에서 crash가 나기 떄문에
     이미 rootViewController이 KCLIntroViewController이라면 재실행 하지 않도록 패치
     
    Client.m line 359
    -[ReqVerifyCc toHttpReq:::]
     */
    
    if ([self.window.rootViewController isKindOfClass:[KCLIntroViewController class]] == NO) {
        
        [HybridActionManager cancelAllAction];
        
        _window.backgroundColor = [UIColor whiteColor];
        
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ETC" bundle:nil];
        ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"KCLIntroViewController"];
        _window.rootViewController = vc;
        
        NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
        [userDefault setObject:@"N" forKey:WIDGET_APP_TERMINATE];
    }
}

#pragma mark - pureAppSuccess (pure 위변조 통과 callback)
//위변조체크 통과후 구동전문 로직
-(void)pureAppSuccess:(NSNotification*)noti {
    NSLog(@"%s",__FUNCTION__);
	NSDictionary *result = noti.object;
	
	//앱아이디가 없으면 내려온 앱아이디를 저장한다.
	if([UserDefaults sharedDefaults].appID.length == 0)
	{
		NSString *appId = [result objectForKey:@"appID"];
		[UserDefaults sharedDefaults].appID = appId;
	}
	//서버상태 Y:정상 C:점검중
	NSString *sevrStus = [result objectForKey:@"sevrStus"];
	NSString *stusMsg = [result objectForKey:@"stusMsg"];
	if([sevrStus isEqualToString:@"C"])
	{//서버 점검중일시
		if(stusMsg.length == 0)
			stusMsg = @"더 나은 서비스를 위해 정기점검 중입니다.\n자세한 사항은 모바일 서비스 페이지\n공지사항을 이용해 주시기 바랍니다.";
		[BlockAlertView showBlockAlertWithTitle:@"알림" message:stusMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
			exit(0);
		} cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
		return;
	}
	
	//스토어 최신버전
	NSString *prsntVsn = [result objectForKey:@"prsntVsn"];
	//강제업데이트 여부
	BOOL cmplUdtYn = [[result objectForKey:@"cmplUdtYn"] boolValue];
    if(cmplUdtYn)
    {
        if(stusMsg.length == 0)
            stusMsg = [NSString stringWithFormat:@"최신 버전(v%@)이 있습니다.\n앱 스토어로 이동합니다.",prsntVsn];
        [BlockAlertView showBlockAlertWithTitle:@"알림" message:stusMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppInfo sharedInfo].updateUrl] options:@{} completionHandler:nil];
            exit(0);
        } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
        return;
    }
	
	//회원여부
    BOOL isJoin = [[result objectForKey:@"isJoin"] boolValue];
	//자동로그인여부
	BOOL autoLogin = [[result objectForKey:@"autoLoginYn"] boolValue];
	//비밀번호 오류횟수
	int pwdErrNotms = [[result objectForKey:@"pwdErrNotms"] intValue];
	[AppInfo sharedInfo].isJoin = isJoin;
	[AppInfo sharedInfo].autoLogin = autoLogin;
	[AppInfo sharedInfo].pwdErrNotms = pwdErrNotms;

    // ga campain url 이 있을경우 호출
    if (sendGaCampainUrlBlock) {
        sendGaCampainUrlBlock();
        sendGaCampainUrlBlock = nil;
    }
    
    // 서버에서 막는 코드가 적용되기 위해 앱실행시 pure.do이후 willEnterForeground 한번더 실행
    [[AppInfo sharedInfo] willEnterForeground:nil];
	
	NSString* appVersion = [AppInfo sharedInfo].appVer;
	BOOL appUpdatable = prsntVsn.length != 0 ? [appVersion isLowerThan:prsntVsn] : NO;
	if(appUpdatable)
	{//앱 업데이트 팝업
		stusMsg = [NSString stringWithFormat:@"최신 버전(v%@)이 있습니다.\n업데이트 하시겠습니까?",prsntVsn];
		[BlockAlertView showBlockAlertWithTitle:@"알림" message:stusMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
			if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:AlertConfirm])
			{
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppInfo sharedInfo].updateUrl] options:@{} completionHandler:nil];
				exit(0);
			}
			else
			{
				[self performSelectorOnMainThread:@selector(mateApplicationStartService) withObject:nil waitUntilDone:NO];
			}
		} cancelButtonTitle:AlertCancel buttonTitles:AlertConfirm, nil];
	}
	else
	{
		//모든로직 통과시 서비스 실행
		[self performSelectorOnMainThread:@selector(mateApplicationStartService) withObject:nil waitUntilDone:NO];
	}
}

#pragma mark - mateApplicationStartService (리브메이트시작 - 접근권한/푸쉬)
//서비스 시작로직
-(void)mateApplicationStartService {
    NSLog(@"%s",__FUNCTION__);
	//여기에서 앱아이디가 없으면 안됨
	if([UserDefaults sharedDefaults].appID.length == 0)
	{
		[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"앱 구동에 필요한 정보가 누락되었습니다." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
			exit(0);
		} cancelButtonTitle:nil buttonTitles:@"종료", nil];
		NSLog(@"===================앱아이디가 없음 체크바람=====================");
		return;
	}

	// 접근권한동의안내
	if([UserDefaults sharedDefaults].showDeviceUseAgreement == NO)
	{
        [(KCLIntroViewController *)(_window.rootViewController) showAgreementView];
        
        [UIView animateWithDuration:0.5 animations:^{
			self->_splashView.alpha = 0;
		} completion:^(BOOL finished) {
			self->_splashView.hidden = YES;
		}];
		return;
	}
	
    // 푸쉬 등록 (bugFix2 Merge) - Push 등록 위치 변경
    /*if([AppInfo sharedInfo].semiMbrId){
        // 푸시서비스 준회원식별자로 토큰 등록
        NSLog(@"[AppInfo sharedInfo].semiMbrId: %@",[AppInfo sharedInfo].semiMbrId);
        [[PushManager defaultManager] registerServiceAndUser:self.mdMainTabBar clientUID:[AppInfo sharedInfo].semiMbrId clientName:@"" phoneNumber:@"" completionHandler:^(BOOL success){
            
       }];
    }*/
    
	//푸시접근동의
    [self initializeRemoteNotification];

    self.appMainNavigationController = [[UIStoryboard storyboardWithName:@"KCLMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"KCLAppMainNavigationController"];
    
    _mainViewController = [[UIStoryboard storyboardWithName:@"KCLMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"KCLMainViewController"];
    
    if (!nilCheck([AppInfo sharedInfo].semiMbrId)) { // push 추가
        // 푸시서비스 준회원식별자로 토큰 등록
        [[PushManager defaultManager] registerServiceAndUser:_mainViewController
                                                   clientUID:[AppInfo sharedInfo].userInfo.semiMbrIdf
                                                  clientName:[UserDefaults sharedDefaults].appID
                                           completionHandler:^(BOOL success) {
            if (success) {NSLog(@"success registerServiceAndUser");}
        
        }];
    }

    [self showSplashView:YES];
	
	//회원가입이 안된상태는 벳지 초기화.
	if([AppInfo sharedInfo].isJoin == NO)
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    if([UserDefaults sharedDefaults].showTutorial == NO)
	{
        [self createMain];
		//튜토리얼을 한번도 안본상태이면 튜토리얼 페이지(이상태는 최초설치로 회원가입이 안된상태라고 판단함)
		[[AllMenu delegate] navigationWithMenuID:MenuID_Tutorial
										animated:NO
										  option:NavigationOptionPopRootAndPush
										callBack:^(ViewController *vc) {
											[self showSplashView:NO];
											[UserDefaults sharedDefaults].showTutorial = YES;
										}];
	}

	else if([AppInfo sharedInfo].isJoin && [AppInfo sharedInfo].autoLogin && [AppInfo sharedInfo].pwdErrNotms < 5 && ![AppInfo sharedInfo].mnpcLogoutYn)
	{
		//회원가입상태 자동로그인 설정 비밀번호 5회 오류가 아니면 자동로그인시킨후 메인화면진입
		[[AppInfo sharedInfo] sendLoginRequestWithPwdDic:nil success:^(BOOL success, NSString *errCD, NSDictionary* result) {
            
        [self createMain];
        [[AllMenu delegate] goMainViewControllerAnimated:NO];
        [self showSplashView:NO];
            
		}];
	}
	else
	{
        [self createMain];
		[[AllMenu delegate] goMainViewControllerAnimated:NO];
		[self showSplashView:NO];
	}
	[Request sendKeepAlive:nil];
#if 0 //DEBUG //(상단에 안내 페이지 안 나오게 수정)
    EdgeLabel *devLabel = [[EdgeLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame)+55, CGRectGetWidth(self.window.frame), 10)];
    devLabel.text = [NSString stringWithFormat:@"테스트모드 : %@ %@/ APPID : %@"
                     ,[SERVER_URL isEqualToString:SERVER_URL_REAL] ? @"운영서버" : [SERVER_URL hasPrefix:@"https://sm."] ? @"스테이징서버" : @"개발서버"
                     , [SERVER_URL rangeOfString:@":2222"].location == NSNotFound?@"(지정포트없음) ":@"(포트:2222)"
                     ,[UserDefaults sharedDefaults].appID];
    devLabel.textAlignment = NSTextAlignmentCenter;
    devLabel.adjustsFontSizeToFitWidth = YES;
    devLabel.isAccessibilityElement = NO;
    devLabel.textColor = [UIColor redColor];
    devLabel.font = FONTSIZE(10);

    CGRect devPageRect = devLabel.frame;
    devPageRect.origin.y = devPageRect.origin.y + 10;
    devPageRect.origin.x = 20;
    devPageRect.size.width = devPageRect.size.width-20;
    devPageRect.size.height = 30;
    self.devPageInfoLabel = [[UILabel alloc] initWithFrame:devPageRect];
    self.devPageInfoLabel.text = @"현재 url 정보가 표시됩니다.";
    self.devPageInfoLabel.numberOfLines = 0;
    self.devPageInfoLabel.font = FONTSIZE(10);
    [self.window addSubview:devLabel];
    [self.window addSubview:self.devPageInfoLabel];
#endif
}

#pragma mark - Main UI (네비게이션/탭바)
-(void)createMain {
    _window.rootViewController = self.appMainNavigationController;
    [self.appMainNavigationController setViewControllers:@[_mainViewController] animated:NO];
}

-(void)updateCurrentPageInfo:(NSString*)pageString {
    self.devPageInfoLabel.text = pageString;
}

//인트로를 보여주거나 삭제하는 함수.
-(void)showSplashView:(BOOL)show {
	if(show)
	{
		if(_splashView == nil)
		{
			UIView *view = [[[LaunchScreen alloc] init] getLaunchScreen];
			view.frame = self.window.bounds;
			self.splashView = view;
			[self.window addSubview:_splashView];
		}
		_splashView.alpha = 1;
		_splashView.hidden = NO;
        _isSplashViewShow = YES;
	}
	else
	{
//        if(self.mainController.mainViewController != nil && _splashView.tag != 999)
        if(_splashView.tag != 999)
		{
			[UIView animateWithDuration:0.5 animations:^{
				self->_splashView.alpha = 0;
			} completion:^(BOOL finished) {
				self->_splashView.hidden = YES;
			}];
            _isSplashViewShow = NO;
		}
	}
	[self.window bringSubviewToFront:_splashView];
}

- (void)showSplashMessage:(NSString*)message autohide:(BOOL)autohide withShowTop:(BOOL)showTop {
    NSLog(@"splash Message = [%@]", message);
	
	// 메시지 내용이 없다면 보여주지 않는다.
	if (nil == message || 0 == [[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length])
		return;
	
	if (nil == _splashMessageView)
	{
		_splashMessageView = [[SplashMessageView alloc] initWithFrame:CGRectZero];
	}
	[_splashMessageView showMessage:((AppDelegate*)[UIApplication sharedApplication].delegate).window message:message autohide:autohide withShowTop:showTop];
}

- (void)hideSplashMessage
{
	if (_splashMessageView && [_splashMessageView superview])
	{
		[_splashMessageView hideMessage];
	}
}

#pragma mark - processesDoKill (프로세스 킬 메소드)
-(void)processesDoKill:(NSString*)message {
    NSLog(@"%s",__FUNCTION__);
	[self showSplashView:YES];
	_splashView.tag = 999;
	_splashView.hidden = NO;
	_splashView.alpha = 1;
	_window.rootViewController.view.alpha = 0;
	[Request cancelRequestAll];
//    CLS_LOG(@"withEvent %@", message);
    NSDictionary * userInfo = @{@"withEvent": message};
    NSError * error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1001 userInfo:userInfo];
    [[FIRCrashlytics crashlytics] recordError:error];
	[BlockAlertView blockAlertWithTitle:@"알림" message:message cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
	exit(0);
}

#pragma mark - application state
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if([self.window.rootViewController isKindOfClass:[KCLIntroViewController class]] == NO && !_isSplashViewShow && ![AppInfo sharedInfo].isFidoActive) {
        [self showSplashView:YES];
    }
    [Request stopKeepAlive];
    [[FIRCrashlytics crashlytics] log:@"applicationWillResignActive"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if([self.window.rootViewController isKindOfClass:[KCLIntroViewController class]] == NO && !_isSplashViewShow) {
		[self showSplashView:YES];
	}
	[Request stopKeepAlive];
    [[FIRCrashlytics crashlytics] log:@"applicationDidEnterBackground"];
    
#ifdef DEBUG
//    For TEST
//    [[AppInfo sharedInfo] clearCookie];
//
//    [WKWebsiteDataStore.defaultDataStore fetchDataRecordsOfTypes:WKWebsiteDataStore.allWebsiteDataTypes completionHandler:^(NSArray<WKWebsiteDataRecord *> * records) {
//        for(WKWebsiteDataRecord *record in records){
//            [WKWebsiteDataStore.defaultDataStore removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
//                //delete callback
//            }];
//        }
//    }];
#endif
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[FIRCrashlytics crashlytics] log:@"applicationWillEnterForeground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (!_isSplashViewShow) {
        return;
    }
    
    [[FIRCrashlytics crashlytics] log:@"applicationDidBecomeActive"];
    
    [Request sendKeepAlive:^{
        [self showSplashView:NO];
        
        NSDictionary *pushInfo = [[AppInfo sharedInfo].launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSURL *urlInfo = [[AppInfo sharedInfo].launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        [AppInfo sharedInfo].launchOptions = nil;
        
        if(pushInfo)
            [self showRemoteNotificationPopup:pushInfo];
        else if(urlInfo)
            [self schemeActionWithURL:urlInfo];
    }];
    
    // ga campain url 이 있을경우 호출
    // - 앱이 살아있는 상태에서 백그라운드에서 호출되었고 sendGaCampainUrlBlock이 nil이 아니면 블럭을 호출해준다
    if (sendGaCampainUrlBlock) {
        sendGaCampainUrlBlock();
        sendGaCampainUrlBlock = nil;
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - 메시지 및 웹페이지 오픈
-(void)setBeforePasteMessage:(NSString *)beforePasteMessage {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	if(beforePasteMessage.length)
		[userDefault setValue:beforePasteMessage forKey:FAIL_MESSAGE];
	else
		[userDefault removeObjectForKey:FAIL_MESSAGE];
	[userDefault synchronize];
}

-(NSString*)beforePasteMessage {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSString *beforeMessage = [userDefault objectForKey:FAIL_MESSAGE];
	return beforeMessage;
}

+(BOOL)canOpenURL:(NSURL *)url {
    if ([[url.scheme lowercaseString] isEqualToString:@"http"] ||
         [[url.scheme lowercaseString] isEqualToString:@"https"]) {
        return YES;
    }
    
    return [[UIApplication sharedApplication] canOpenURL:url];
}

#pragma mark - Initialize Remote Notification
- (void)initializeRemoteNotification {
    
    UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
       
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
            
        }
    }];
}

// splash 다운로드 완료 노티피케이션
- (void)downloadSplashImage
{
    if (_splashView) {
        [_splashView removeFromSuperview];
        _splashView = nil;
        _isSplashViewShow = NO;
    }
}
@end
