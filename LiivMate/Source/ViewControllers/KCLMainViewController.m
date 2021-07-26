//
//  KCLMainViewController.m
//  LiivMate
//
//  Created by KB on 2021/05/17.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLMainViewController.h"
#import "NoticeAlertView.h"
#import "SplashScreenManager.h"
#import "HybridActionManager.h"

@interface KCLMainViewController () {
    
    BOOL _didFinishLoad;
}

@end

@implementation KCLMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 키페드 속도개선을 위해 리소스를 미리 로드
    [PwdWrapper loadResource];
    
    if ([AppInfo sharedInfo].themeData) {
        if (![[AppInfo sharedInfo].themeData[@"ver"] isEqualToString:[UserDefaults sharedDefaults].splashVer]) {
            // 다운로드 시작
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SplashScreenManager downloadData:[AppInfo sharedInfo].themeData];
            });
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needsLoginStatusChanged) name:LoginStatusChangedNotification object:nil];
    [self loginStatusChanged];
    [self checkBaseUrl];
    
    [APP_DELEGATE setMainViewController:self];
    _menuID_main = @"";
    
    // 메인에서는 항상 메뉴 버튼만을 띄워준다
    [self.customNavigationBar mainHeaderViewSet];
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)checkBaseUrl {
    if(self.firstOpenUrl == nil) {
        NSDictionary *menuDic = [AllMenu menuForID:MenuID_V4_MainPage];
        self.viewID = MenuID_V4_MainPage;
        self.menuItem = menuDic;
        self.firstOpenUrl = [menuDic null_objectForKey:K_URL_ADDR];
        [self webPageInit];
    }
}

/**
@var reloadMain
@brief 자산/소비/톡톡 메뉴 선택시 메인 리로드
@param 메뉴 ID
*/
- (void)reloadMain:(NSString *)menuID {

    NSDictionary *menuDic = [AllMenu menuForID:menuID];
    self.viewID = menuID;
    self.menuItem = menuDic;
    self.firstOpenUrl = [menuDic null_objectForKey:K_URL_ADDR];
//    [self webPageInit];
    
    [self clearHistoryStack];
    [self.webView webViewLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.firstOpenUrl]]];
}

- (void)viewWillAppear:(BOOL)animated {
    //2.0 viewcontroller viewWillAppear 상속무시 : 탭바 설정,
    [super viewWillAppear:animated];
    
    if([AppInfo sharedInfo].isLogin)
        [[AppInfo sharedInfo] reloadPoint];
    
    if (_menuID_main.length > 0) {
        [self reloadMain:_menuID_main];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkedPopUpMessage];
    [AllMenu menu].gnbType = GNBType_Normal;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    _menuID_main = @"";
}

- (void)checkedPopUpMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        //공지사항 처리
        if([AppInfo sharedInfo].notice) {
            NSString *noticeNo = [[AppInfo sharedInfo].notice null_valueForKey:@"noticeNo"];
            NSString *noticeTitle = [[AppInfo sharedInfo].notice null_valueForKey:@"noticeTitle"];
            NSString *noticeCont = [[AppInfo sharedInfo].notice null_valueForKey:@"noticeCont"];
            NSString *noticeYn = [[AppInfo sharedInfo].notice null_valueForKey:@"noticeYn"];
            NSString *noticeCloseType = [[AppInfo sharedInfo].notice null_valueForKey:@"noticeCloseType"];
            NSString *noticeCamYn = [[AppInfo sharedInfo].notice null_valueForKey:@"noticeCamYn"]; // 이벤트 캠페인 팝업 추가
            
            [AppInfo sharedInfo].notice = nil;
            if([noticeCloseType isEqualToString:@"1"]) { // 오늘 하루 안보기
                if([[UserDefaults sharedDefaults] checkDayNoticeNo:noticeNo update:NO] && noticeYn.boolValue)
                {
                    [NoticeAlertView showNoticeTitle:noticeTitle message:noticeCont dismissTitle:@"오늘 하루 안보기" isFullPopup:noticeCamYn.boolValue dissmiss:^(BOOL checked) {
                        if(checked)
                            [[UserDefaults sharedDefaults] checkDayNoticeNo:noticeNo update:YES];
                        [self checkedPopUpMessage];
                    }];
                    return;
                }
            } else { // 더이상 안보기
                if([[UserDefaults sharedDefaults] checkNoticeNo:noticeNo update:NO] && noticeYn.boolValue)
                {
                    [NoticeAlertView showNoticeTitle:noticeTitle message:noticeCont dismissTitle:@"더이상 안보기" isFullPopup:noticeCamYn.boolValue dissmiss:^(BOOL checked) {
                        if(checked)
                            [[UserDefaults sharedDefaults] checkDayNoticeNo:noticeNo update:YES];
                        [self checkedPopUpMessage];
                    }];
                    return;
                }
            }
        }
        
        if([AppInfo sharedInfo].launchOptions) {
            NSLog(@"main_launchOptions ==> %@",[AppInfo sharedInfo].launchOptions);
            NSDictionary *pushInfo = [[AppInfo sharedInfo].launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            
            NSURL *urlInfo = [[AppInfo sharedInfo].launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
            [AppInfo sharedInfo].launchOptions = nil;
            
            if(pushInfo)
            {
                if([APP_DELEGATE showRemoteNotificationPopup:pushInfo])
                    return;
            }
            else if(urlInfo)
            {
                if([APP_DELEGATE schemeActionWithURL:urlInfo])
                    return;
            }
        }
    });
}

- (void)needsLoginStatusChanged {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loginStatusChanged) object:nil];
    [self performSelector:@selector(loginStatusChanged) withObject:nil afterDelay:0.05];
}

- (void)loginStatusChanged {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loginStatusChanged) object:nil];
    
    if (@available(iOS 12.0, *)) {
        return;;
    } else {
        if(_didFinishLoad) {
            NSMutableString* script = [[NSMutableString alloc] init];
            
            // Get the currently set cookie names in javascriptland
            [script appendString:@"var cookieNames = document.cookie.split('; ').map(function(cookie) { return cookie.split('=')[0] } );\n"];
            
            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
                // Skip cookies that will break our script
                if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
                    continue;
                }
                // Create a line that appends this cookie to the web view's document's cookies
                
                [script appendFormat:@" document.cookie='%@';\n", [self wn_javascriptString:cookie]];
            }
            
            NSLog(@"\[NSCOOKIE -> WKCOOKIE] (3) - 메인 화면 javascript 실행");
            [self.webView stringByEvaluatingJavaScriptFromString:script completionHandler:^(NSString *result) {
                NSLog(@"[NSCOOKIE -> WKCOOKIE] (3) - 메인 화면 document.cookie [ %@ ]", result);
            }];
        }
    }
}

- (NSString *)wn_javascriptString:(NSHTTPCookie *)cookie {
    NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",
                        cookie.name,
                        cookie.value,
                        cookie.domain,
                        cookie.path ?: @"/"];
    
    if (cookie.secure) {
        string = [string stringByAppendingString:@";secure=true"];
    }
    
    return string;
}

- (void)setTitle:(NSString *)title {
    //webviewcontroller 타이틀 설정 무시
    //    self.title = @"투데이";
}

- (void)setFirstOpenUrl:(NSString *)firstOpenUrl {
    if ([firstOpenUrl rangeOfString:@"?"].location == NSNotFound)
        firstOpenUrl = [firstOpenUrl stringByAppendingFormat:@"?appId=%@", [UserDefaults sharedDefaults].appID];
    else
        firstOpenUrl = [firstOpenUrl stringByAppendingFormat:@"&appId=%@", [UserDefaults sharedDefaults].appID];
    
    [super setFirstOpenUrl:firstOpenUrl];
}

- (void)setBaseUrlRequest:(NSMutableURLRequest *)baseUrlRequest {
    _didFinishLoad = NO;
    [super setBaseUrlRequest:(id)baseUrlRequest];
}

- (BOOL)webView:(id<WebView>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType {
    BOOL isNext = [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
    if([request.URL.absoluteString isEqualToString:@"about:blank"])
        return NO;

    return isNext;
}

- (void)webViewDidFinishLoad:(id<WebView>)webView {
    [super webViewDidFinishLoad:webView];
    _didFinishLoad = YES;
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)webView:(id<WebView>)webView didFailLoadWithError:(nullable NSError *)error {
    [super webView:webView didFailLoadWithError:error];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - buttonActions

- (void)dealloc {
    //메모리 참조된곳 nil처리.
    [HybridActionManager cancelActionWithWebView:self.webView];
    self.webView.webViewDelegate = nil;
    self.webView.scrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onClickedLoginButton:(id)sender {
    if ([AppInfo sharedInfo].isJoin) {
        //로그인이후 가맹점회원이면 가맹점 메인화면으로 이동시킨다. 일반유저일경우는 현상유지.
        //(pUser,mOwnr,mMng,mEmp)
        if (AppInfo.sharedInfo.isLogin) {
//            if ([[AppInfo userInfo].userAppMenuGbn isEqualToString:ShopMember_mOwnr]
//               || [[AppInfo userInfo].userAppMenuGbn isEqualToString:ShopMember_mMng]) {
//                [AllMenu.delegate navigationWithMenuID:MenuID_ShopHome animated:YES option:NavigationOptionSetRoot callBack:^(ViewController *vc) {
//                }];
//            }
        }
        else {
            [AppInfo.sharedInfo performLogin:^(BOOL success, NSString *errCD, NSDictionary *result) {
                if (success) {
//                    if ([[AppInfo userInfo].userAppMenuGbn isEqualToString:ShopMember_mOwnr]
//                       || [[AppInfo userInfo].userAppMenuGbn isEqualToString:ShopMember_mMng]) {
//                        [AllMenu.delegate navigationWithMenuID:MenuID_ShopHome animated:YES option:NavigationOptionSetRoot callBack:^(ViewController *vc) {
//                        }];
//                    }
                }
            }];
        }
    }
    else {
        // Ver. 3 회원가입(MYD_JO0100)
        [AllMenu.delegate navigationWithMenuID:MenuID_V3_MateJoin animated:YES option:NavigationOptionPush callBack:nil];
    }
}

@end
