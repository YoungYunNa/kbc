//
//  WebViewController.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 21..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "WebViewController.h"
#import "HybridActionManager.h"
#import "MobileWeb.h"
#import "GifProgress.h"
#import "GoogleAnalyticsBuilder.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import <MPushLibrary/MPushLibrary.h>

// ???? for test
/*
NSString *testHtml =
@"<html> "
@"<head> "
@"<title> TEST HTML"
@"</title> "
@"</head> "
@"<body onload=\"myFunction()\"> "
@"Hello World! "
@"<input type=\"button\" id=\"button1\" onclick=\"button1_click();\" value=\"버튼1\" /> "
@"<input type=\"text\" id=\"nickname\" /> "
@"<script> "
@"function button1_click() { "
//@"	alert(\"버튼1을 누르셨습니다.\"); "
//@"	window.location.href = \"http://m.naver.com\"; "
//@"	window.location.href = \"main://\"; "
//@"	window.location.href = 'liivmate://call?cmd=external&name=Class.setTopMenu&params={\"menuBt\":\"Y\", \"preBt\":\"Y\", \"title\":\"리브메이트 Hybrid 인터페이스\", \"target\":\"http://m.naver.com\", \"preAction\":\"T\", \"topMenuTypeV3\":\"1\", \"dimm\": \"Y\" }&failCallback=testFail&successCallback=testSuccess'; "
@"	lm_wkwebview_ScalesPageToFit(true); "
@"}; "
@"function testSuccess() { "
@"	alert(\"처리 성공입니다.\"); "
@"}; "
@"function testFail() { "
@"	alert(\"처리 실패입니다.\"); "
@"}; "
@"function myFunction() { "
//@"	document.getElementById('nickname').focus(); "
@"}; "
@"</script> "
@"</body> "
@"</html> ";
*/



@interface WebViewController ()<UIScrollViewDelegate>
{
	id<WebView> _webView;
	
//	PreType _preType;
	NSString *_viewID;
	
	UIButton *_homeButton;
	UIButton *_backButton;
	UIButton *_forwardButton;
	NSMutableDictionary *_notiActionDic;
    
//    UIView *dimmView;
}
@property (nonatomic, strong) NSString *target;
@property (nonatomic, assign)NSInteger nPreviousScrollOffsetY;
@property (nonatomic, assign)NSInteger scrollOffsetY;

@end

@implementation WebViewController

- (void)addHistoryStack:(NSDictionary *)urlInfo
{
	if (_historyStack == nil) _historyStack = [[NSMutableArray alloc] init];
	
	NSDictionary *lastInfo = _historyStack.lastObject;
	
	// 이전과 URL 동일
	if ([lastInfo[@"url"] isEqualToString:urlInfo[@"url"]])
	{
		// 이전 useYN = Y
		if ([[lastInfo[@"useYN"] uppercaseString] isEqualToString:@"Y"])
		{
			// 스택에 쌓지 않는다.
		}
		// 이전 useYN = N
		else
		{
			// 이전 없앤다.
			[_historyStack removeLastObject];
			// 스택에 쌓는다.
			[_historyStack addObject:urlInfo];
		}
	}
	// 이전과 URL 틀림
	else
	{
		// 이전 useYN = Y
		if ([[lastInfo[@"useYN"] uppercaseString] isEqualToString:@"Y"])
		{
			// 스택에 쌓는다.
			[_historyStack addObject:urlInfo];
		}
		// 이전 useYN = N
		else
		{
			// 이전 없앤다.
			[_historyStack removeLastObject];
			// 스택에 쌓는다.
			[_historyStack addObject:urlInfo];
		}
	}
	
	NSLog(@"\n[HISTORY STACK] : %@", _historyStack);
	
	[self checkScreenEdgeBack];
}

- (void)removeHistoryStack:(NSInteger)cnt
{
    if (!_historyStack) return;
    if (_historyStack.count == 0) return;
    if (_historyStack.count < cnt) return;
    
    for (NSInteger i=0 ; i<cnt; i++) {
        [_historyStack removeLastObject];
    }
    
    [self checkScreenEdgeBack];
}

- (void)clearHistoryStack
{
	[_historyStack removeAllObjects];
	_historyStack = nil;
	
	[self checkScreenEdgeBack];
}

-(void)initSettings
{
	[super initSettings];
	self.enabledWKWebMode = YES;
	self.enableTfAutoScroll = NO;
	self.indicator = YES;
	self.defultTitle = APP_BUNDLE_NAME;
	self.menuHidden = YES;
	self.navigationItem.hidesBackButton = YES;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
    
    _webView = [[HybridWKWebView alloc] initWithFrame:CGRectZero];

	_webView.webViewDelegate = self;
	_webView.KLUMode = YES;
	_webView.scrollView.delegate = self;
	_webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
	
	[self.view addSubview:(UIView*)self.webView];
    
    // 알림함 진입시 뺏지 초기화
    if ([MenuID_V3_Notification isEqualToString:self.viewID]){
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [[PushManager defaultManager] update:nil badge:@(0) completionHandler:^(BOOL success) {
            NSLog(@"update : %@", @(success));
        }];
    }
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    [statusBarView setBackgroundColor:UIColor.whiteColor];
    [self.view addSubview:statusBarView];
    
    self.customNavigationBar = [KCLCustomNavigationBarView instance];
    [self.view addSubview:self.customNavigationBar];
    
//    if (self.customNavigationBar.dimmYN) {
//        dimmView = [[UIView alloc] initWithFrame:self.view.bounds];
//        dimmView.backgroundColor = UIColor.blackColor;
//        dimmView.alpha = 0.5f;
//        [self.view addSubview:dimmView];
//    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    AppDelegate *appdel = APP_DELEGATE;
    [appdel updateCurrentPageInfo:self.webView.request.URL.absoluteString];
    
    if(self.internalNavigationTitleString.length > 0){
        self.customNavigationBar.titleLabel.text = self.internalNavigationTitleString;
    }
}

-(void)dealloc
{
	[HybridActionManager cancelActionWithWebView:_webView];
	_webView.webViewDelegate = nil;
    _webView.scrollView.delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)mobileActionNoti:(NSNotification*)noti
{
	NSArray *actions = [_notiActionDic valueForKey:noti.name];
	for(MobileWeb *action in actions)
	{
		action.webView = (id)self.webView;
		[action run];
	}
}

-(void)setDefultTitle:(NSString *)defultTitle
{
	_defultTitle = defultTitle;
	if(self.title.length == 0)
		self.title = defultTitle;
}

-(void)setTitle:(NSString *)title
{
	[super setTitle:title];
}

- (void)goBasePage
{
	[self clearHistoryStack];
	[_webView webViewLoadRequest:_baseUrlRequest];
    
    // 메인에서는 항상 메뉴 버튼만을 띄워준다
    [_customNavigationBar mainHeaderViewSet];
}

-(void)setBaseUrlRequest:(WVRequest *)baseUrlRequest
{
	_baseUrlRequest = baseUrlRequest;
}

-(void)setTopMenu:(NSDictionary *)topMenu
{
	_topMenu = topMenu;

    // webView가 로딩중이면 webViewDidFinishLoad에서 설정함
    if ([_webView isLoading]) {
        return;
    }
    
    [self.customNavigationBar setTitle:[_topMenu null_valueForKey:@"title"]];
    NSString *backYN = [_topMenu null_valueForKey:@"preBt"];
    
    //탑페이지 에서는 back버튼 N으로 넘겨주도록 변경해야함.
    if ([backYN boolValue]) {
        self.customNavigationBar.leftBackButton.hidden = NO;
        self.customNavigationBar.leftBackButtonWidth.constant = 38;
    } else {
        self.customNavigationBar.leftBackButton.hidden = YES;
        self.customNavigationBar.leftBackButtonWidth.constant = 12;
    }
    
    NSString *action = [_topMenu null_valueForKey:@"preAction"];
    
    // Close 버튼 추가 (혜택찾기 업무단 추가 요청 인터페이스)
    _target = [_topMenu null_valueForKey:@"target"];
    NSString *closeYN = [_topMenu null_valueForKey:@"close"];
     [self.customNavigationBar setCloseBtn:closeYN action:action];
    
    //2019.04.22 수정 - 기존에 웹에서 preAction 미사용. preAction:B 또는 nil인 경우 기존처럼 백버튼 동작하도록 변경. - (void)backButtonAction:(UIButton*)sender 같이 수정
    if([action isEqualToString:@"C"])
        _preType = PreTypeClose;
    else if([action isEqualToString:@"T"])
        _preType = PreTypeTargetUrl;
    else if([action isEqualToString:@"F"])
        _preType = PreTypeTargetFunction;
    else
        _preType = PreTypeGoBack;
    
    
    // 2021.06.17 v4 메뉴버튼, dimm 처리 여부 추가
    NSString *menuYN = [_topMenu null_valueForKey:@"menuBt"];
    NSString *dimmYN = [_topMenu null_valueForKey:@"dimm"];
    
    if (nilCheck(menuYN)) {
        menuYN = @"N";
    }
    if (nilCheck(dimmYN)) {
        dimmYN = @"N";
    }
    
    [self.customNavigationBar setTotalMenuBtn:menuYN];
    [self.customNavigationBar setDimmYN:dimmYN];
    [self.customNavigationBar dimmViewSet:dimmYN];
}

- (void)checkScreenEdgeBack {
#if ScreenEdgeBackMode
	if(IS_USE_WKWEBVIEW && _enabledWKWebMode)
	{
		BOOL canGoBack = [self canGoBack];
		for(UIGestureRecognizer *ges in ((UIView*)self.webView).gestureRecognizers)
		{
			NSLog(@"ges %@ %d",ges,[self canGoBack]);
			if([ges isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
				ges.enabled = canGoBack;
		}
	}
#endif
}

- (UIButton*)setupLeftBarButtonItem
{
	UIButton *button =  [super setupLeftBarButtonItem];
	if(self.navigationController)
	{
		UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(performClose)];
		longGes.minimumPressDuration = 2;
		[button addGestureRecognizer:longGes];
	}
	return button;
}

- (void)performClose {
	[_webView stopLoading];
    
	if(self.navigationController.viewControllers.count > 1)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

/**
@var backButtonAction
@brief 공통헤더의 뒤로가기 버튼 액션
*/
- (void)backButtonAction:(UIButton*)sender
{
    if([AppInfo sharedInfo].isLogin){ // 로그인시 포인트 재조회 추가
        [[AppInfo sharedInfo] reloadPoint];
    }
    
    //2019.04.22 수정 - 기존 로직은 _historyStack이 nil인 경우에만 preAction 로직이 타도록 되어있어서 변경
    if(_preType == PreTypeGoBack)
    {
        if (_historyStack != nil)
        {
            if (_historyStack.count >= 2)
            {
                // 현재 URL 없앤다.
                NSDictionary *last = _historyStack.lastObject;
                NSDictionary *params = last[@"params"];
                NSString *jsonParams = params.jsonString;
                [_historyStack removeLastObject];
                
                // 이전 URL로 이동
                {
                    NSDictionary *lastInfo = _historyStack.lastObject;
                    NSString *url = lastInfo[@"url"];
                    NSDictionary *parameters = lastInfo[@"params"];
                    NSMutableDictionary *newPamas = [parameters mutableCopy];
                    [newPamas setObject:jsonParams forKey:@"prevInputInfo"];    //2019.04 뒤로가기시 이전 페이지에 데이터가 남아있게 해달라는 요청으로 추가
                    
#ifdef DEBUG
                    if ([SERVER_URL rangeOfString:@":2222"].location != NSNotFound
                        && [url rangeOfString:@":2222"].location == NSNotFound) {
                        // 차세대
                        
                        if ([url rangeOfString:@"/evnt"].location == NSNotFound) // 이벤트가 들어가 있으면 :2222 붙이지 않게 수정(베넷핏 요청사항)
                        url = [url stringByReplacingOccurrencesOfString:@".liivmate.com" withString:@".liivmate.com:2222"];
                    }
#endif
                    
        // wkwebview에서 10이하 버전일땐 포스트 파라메터가 웹뷰가 먹어버리는 현상이 발생함
        // 해결방법은 포스트로보낼 로컬 html파일을 사용하여 스크립트로 포스트를 날리거나, get로 날리는 방법이 있음
        // 두가지다 문제가 있는 방향이나 현재 서버쪽에서 지원을 받기로하고 get으로 변경해서 날리게 수정, 추후 post로 반드시 날려야 하는 경우가 생긴다면
        // 위에서 말한 로컬 html을 이용한 스크립트 방식으로 변경하거나 ios10이하 사용자는 버려야함....
        
                    if (@available(iOS 11.0, *)) {}
        
                    else {
                        if ([url rangeOfString:@"?"].location == NSNotFound)
                            url = [url stringByAppendingFormat:@"?%@", [NSString urlEncodedQueryString:newPamas]];
                        else
                            url = [url stringByAppendingFormat:@"&%@", [NSString urlEncodedQueryString:newPamas]];
                    }

                    WVRequest *rq = [WVRequest requestWithURL:[NSURL URLWithString:url]];
                    rq.timeoutInterval = TimeoutInterval;
                    
                    if ([newPamas isKindOfClass:[NSMutableDictionary class]])
                    {
                        [rq setbody:newPamas isPassEncoding:self.passEncoding isEnc:NO];
                    }
                    [rq setAllHTTPHeaderFields:[Request httpHeader]];
                    
                    // 해더 앱아이디 암호화
                    if([UserDefaults sharedDefaults].appID.length > 0) {
                        NSString * encAppid = [PwdWrapper encryptedDictionary:@{@"encStr" : [UserDefaults sharedDefaults].appID}];
                        [rq setValue:encAppid forHTTPHeaderField:@"appId"];
                    }
                    
                    [_webView webViewLoadRequest:rq];
                }
                return;
            }   // _historyStack 1개 있을 때 이전화면으로 이동하게 수정
            else if(self.navigationController.viewControllers.count > 1)
            {
                UINavigationController *nvc =  [[_webView parentViewController] navigationController];
                NSLog(@"viewControllers.count: %lu",(unsigned long)nvc.viewControllers.count );
                NSLog(@"viewControllers : %@", nvc.viewControllers);
                if(nvc.viewControllers.count > 1){
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else { // 2021.07.05 : 현재 메인페이지에서 addHistoryStack을 호출하지 않고 있어서 임시로 메인페이지로 이동 구문 추가함
                [self goBasePage];
            }
        } else {
            UINavigationController *nvc =  [[_webView parentViewController] navigationController];
            if(nvc.viewControllers.count > 1){
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    else if(_preType == PreTypeTargetUrl && _target.length != 0)
    {
        if([_target rangeOfString:Scheme_External].location == 0 || [_target rangeOfString:Scheme_Internal].location == 0)
        {
            [[AllMenu delegate] sendBirdDetailPage:_target callBack:^(ViewController *vc) {
                
            }];
            return;
        }
        else if([_target rangeOfString:@"http"].location == 0)
        {
            [_webView webViewLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_target]]];
            return;
        }
    }
    else if(_preType == PreTypeTargetFunction && _target.length != 0)
    {
        [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@();",_target] completionHandler:nil];
             return;
    }
    else if(_preType == PreTypeClose) {
        //2019.04.22 추가 - preAction : C 인 경우 기존에 브릿지(closeView)와 동일 기능 수행
        UIViewController *vc = _webView.parentViewController;
        if(vc.navigationController.viewControllers.count > 1)
            [vc.navigationController popViewControllerAnimated:YES];
        else if(vc.navigationController != (id)[AllMenu delegate])
            [vc dismissViewControllerAnimated:YES completion:nil];
        else
            [[AllMenu delegate] navigationWithMenuID:nil
                                            animated:YES
                                              option:NavigationOptionPopView
                                            callBack:nil];

        return;
    }
}

-(void)checkOpenUrlParamInfo{
    NSDictionary *actionMoveToParamDic = [[NSUserDefaults standardUserDefaults] valueForKey:ACTION_CALL_MOVE_TO_PARAM_INFO];
    if(actionMoveToParamDic){
        if(self.dicParam == nil){
            self.dicParam = actionMoveToParamDic;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACTION_CALL_MOVE_TO_PARAM_INFO];
        }
    }
    else if([AppInfo sharedInfo].openUrlParam){
        if(self.dicParam == nil){
            self.dicParam = [NSDictionary dictionaryWithDictionary:[AppInfo sharedInfo].openUrlParam];
            [AppInfo sharedInfo].openUrlParam = nil;
        }
    }
}

-(BOOL)canGoBack
{
	if(self.navigationItem.hidesBackButton) return NO;
	
	if (_historyStack != nil)
	{
		return (_historyStack.count >= 2);
	}
	else
	{
		if(_preType == PreTypeGoBack && _webView.canGoBack)
		{
			return YES;
		}
		else if(_preType == PreTypeTargetUrl && _target.length != 0)
		{
			if([_target rangeOfString:Scheme_External].location == 0 || [_target rangeOfString:Scheme_Internal].location == 0)
			{
				return YES;
			}
			else if([_target rangeOfString:@"http"].location == 0)
			{
				return YES;
			}
		}
		else if(_preType == PreTypeTargetFunction && _target.length != 0)
		{
			return YES;
		}
	}
	return NO;
}
-(void)webPageInit{
    
    if(_baseUrlRequest == nil && _firstOpenUrl)
        {
            
    #ifdef DEBUG
            // 초기구동 url에 2222가 붙었고 로드할 url에 2222가 없을경우 2222포트 붙여서 로드
            if ([SERVER_URL rangeOfString:@":2222"].location != NSNotFound
                && [_firstOpenUrl rangeOfString:@":2222"].location == NSNotFound) {
                // 차세대
                
                if ([_firstOpenUrl rangeOfString:@"/evnt"].location == NSNotFound) // 이벤트가 들어가 있으면 :2222 붙이지 않게 수정(베넷핏 요청사항)
                    _firstOpenUrl = [_firstOpenUrl stringByReplacingOccurrencesOfString:@".liivmate.com" withString:@".liivmate.com:2222"];
            }
    #endif
            
            [self checkOpenUrlParamInfo];
 
            // wkwebview에서 10이하 버전일땐 포스트 파라메터가 웹뷰가 먹어버리는 현상이 발생함
            // 해결방법은 포스트로보낼 로컬 html파일을 사용하여 스크립트로 포스트를 날리거나, get로 날리는 방법이 있음
            // 두가지다 문제가 있는 방향이나 현재 서버쪽에서 지원을 받기로하고 get으로 변경해서 날리게 수정, 추후 post로 반드시 날려야 하는 경우가 생긴다면
            // 위에서 말한 로컬 html을 이용한 스크립트 방식으로 변경하거나 ios10이하 사용자는 버려야함....
            if (@available(iOS 11.0, *)) {}
            else {
                if ([_firstOpenUrl rangeOfString:@"?"].location == NSNotFound)
                    _firstOpenUrl = [_firstOpenUrl stringByAppendingFormat:@"?%@", [NSString urlEncodedQueryString:self.dicParam]];
                else
                    _firstOpenUrl = [_firstOpenUrl stringByAppendingFormat:@"&%@", [NSString urlEncodedQueryString:self.dicParam]];
            }
            
            WVRequest *rq = [WVRequest requestWithURL:[NSURL URLWithString:_firstOpenUrl]];
            rq.timeoutInterval = TimeoutInterval;
            
            if(self.dicParam)
            {
                [rq setbody:self.dicParam isPassEncoding:self.passEncoding isEnc:NO];
            }
            
            [rq setAllHTTPHeaderFields:[Request httpHeader]];
            
            // 해더 앱아이디 암호화
            if([UserDefaults sharedDefaults].appID.length > 0) {
                NSString * encAppid = [PwdWrapper encryptedDictionary:@{@"encStr" : [UserDefaults sharedDefaults].appID}];
                [rq setValue:encAppid forHTTPHeaderField:@"appId"];
            }
            
            self.baseUrlRequest = rq;
            [self goBasePage];
        }
        else
        {
            if(_firstOpenUrl == nil && _baseUrlRequest)
            {
                self.firstOpenUrl = _baseUrlRequest.URL.absoluteString;
                [self goBasePage];
            }
            else
            {
                self.navigationItem.hidesBackButton = NO;
                [self setupLeftBarButtonItem];
            }
   
        }
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(_baseUrlRequest == nil && _firstOpenUrl)
	{
        _firstOpenUrl = _firstOpenUrl.trim;
        
#ifdef DEBUG
        // 초기구동 url에 2222가 붙었고 로드할 url에 2222가 없을경우 2222포트 붙여서 로드
        if ([SERVER_URL rangeOfString:@":2222"].location != NSNotFound
            && [_firstOpenUrl rangeOfString:@":2222"].location == NSNotFound) {
            // 차세대
            
            if ([_firstOpenUrl rangeOfString:@"/evnt"].location == NSNotFound) // 이벤트가 들어가 있으면 :2222 붙이지 않게 수정(베넷핏 요청사항)
            _firstOpenUrl = [_firstOpenUrl stringByReplacingOccurrencesOfString:@".liivmate.com" withString:@".liivmate.com:2222"];
        }
#endif
        
        [self checkOpenUrlParamInfo];
        
        // wkwebview에서 10이하 버전일땐 포스트 파라메터가 웹뷰가 먹어버리는 현상이 발생함
        // 해결방법은 포스트로보낼 로컬 html파일을 사용하여 스크립트로 포스트를 날리거나, get로 날리는 방법이 있음
        // 두가지다 문제가 있는 방향이나 현재 서버쪽에서 지원을 받기로하고 get으로 변경해서 날리게 수정, 추후 post로 반드시 날려야 하는 경우가 생긴다면
        // 위에서 말한 로컬 html을 이용한 스크립트 방식으로 변경하거나 ios10이하 사용자는 버려야함....
        if (@available(iOS 11.0, *)) {}
        else {
            if ([_firstOpenUrl rangeOfString:@"?"].location == NSNotFound)
                _firstOpenUrl = [_firstOpenUrl stringByAppendingFormat:@"?%@", [NSString urlEncodedQueryString:self.dicParam]];
            else
                _firstOpenUrl = [_firstOpenUrl stringByAppendingFormat:@"&%@", [NSString urlEncodedQueryString:self.dicParam]];
        }
        
		WVRequest *rq = [WVRequest requestWithURL:[NSURL URLWithString:_firstOpenUrl]];
        rq.timeoutInterval = TimeoutInterval;
        
		if(self.dicParam)
		{
            [rq setbody:self.dicParam isPassEncoding:self.passEncoding isEnc:NO];
		}
        
        [rq setAllHTTPHeaderFields:[Request httpHeader]];
        
        // 해더 앱아이디 암호화
        if([UserDefaults sharedDefaults].appID.length > 0) {
            NSString * encAppid = [PwdWrapper encryptedDictionary:@{@"encStr" : [UserDefaults sharedDefaults].appID}];
            [rq setValue:encAppid forHTTPHeaderField:@"appId"];
        }
        
        //[rq setValue:[NSString stringWithFormat:@"%@", [AppInfo sharedInfo].gaCid] forHTTPHeaderField:@"clientid"]; // GA - ClientId 포함 전송.
		self.baseUrlRequest = rq;
		[self goBasePage];
	}
	else
	{
		if(_firstOpenUrl == nil && _baseUrlRequest)
		{
			self.firstOpenUrl = _baseUrlRequest.URL.absoluteString;
			[self goBasePage];
		}
		else
		{
			self.navigationItem.hidesBackButton = NO;
			[self setupLeftBarButtonItem];
		}
	}
    
    [self.customNavigationBar setCustomNavigationBar:self];
    
    [AllMenu setStatusBarStyle:NO viewController:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.internalNavigationTitleString = @"";
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	CGRect rect = self.view.bounds;
    NSLog(@"%s",__FUNCTION__);
    
    CGRect statusBarRect = [UIApplication sharedApplication].statusBarFrame;
    NSInteger nStatusBarHeight = statusBarRect.size.height;
    NSInteger nTopHeight = self.customNavigationBar.frame.size.height + nStatusBarHeight;
    
    rect.origin.y = nTopHeight;
    rect.size.height = rect.size.height - nTopHeight;
    
    [self.webView setFrame:rect];
    
    // dimm 영역 설정
//    CGRect dimmRect = self.view.bounds;
//    dimmRect.origin.y = 0;
//    dimmRect.size.height = nTopHeight;
//    [dimmView setFrame:dimmRect];
}

- (id<WebView>)webView
{
	return _webView;
}

//////////////
- (void)loadPage:(NSString *)url method:(NSString *)method params:(NSDictionary *)params trxCd:(NSString *)trxCd isEnc:(BOOL)isEnc
{
    
#ifdef DEBUG
    if ([SERVER_URL rangeOfString:@":2222"].location != NSNotFound
        && [url rangeOfString:@":2222"].location == NSNotFound) {
        // 차세대
        
      if ([_firstOpenUrl rangeOfString:@"/evnt"].location == NSNotFound) // 이벤트가 들어가 있으면 :2222 붙이지 않게 수정(베넷핏 요청사항)
        url = [url stringByReplacingOccurrencesOfString:@".liivmate.com" withString:@".liivmate.com:2222"];
    }
#endif
    
    WVRequest *rq = [WVRequest requestWithURL:[NSURL URLWithString:url]];
    
    if ([[params allKeys] count] > 0)
    {
        if ([@"POST" isEqualToString:method]) {
            [rq setbody:params isPassEncoding:self.passEncoding isEnc:isEnc];
        } else {
            
            NSString * param = @"";
            
            // formSubmitCall에서 암호화 요청이 들어왔을때 암호화
            if (isEnc) {
                param = [rq getEncParam:params];
            } else {
                param = [NSString urlEncodedQueryString:params];
            }
            
            NSString * strUrl = [NSString stringWithFormat:@"%@?%@", url, param];
            rq = [WVRequest requestWithURL:[NSURL URLWithString:strUrl]]; 
        }
    }
    
    [rq setHTTPMethod:method];
    rq.timeoutInterval = TimeoutInterval;
    [rq setAllHTTPHeaderFields:[Request httpHeader]];
    
    // 해더 앱아이디 암호화
    if([UserDefaults sharedDefaults].appID.length > 0) {
        NSString * encAppid = [PwdWrapper encryptedDictionary:@{@"encStr" : [UserDefaults sharedDefaults].appID}];
        [rq setValue:encAppid forHTTPHeaderField:@"appId"];
    }
    
    [_webView webViewLoadRequest:rq];
    
}

// internal 백버튼 안나오는 부분수정
- (void)checkNavigationControllerPreButton {
    if(self.navigationController.viewControllers.count > 1){
        self.customNavigationBar.leftBackButton.hidden = NO;
        self.customNavigationBar.leftBackButtonWidth.constant = 38;
    }
}

// 웹뷰컨트롤러 상속받은 화면 로드시에는 ga안보냄
// 현재 웹은 따로보내는중. 추후 웹애서 스킴호출을통해(??) 요쳥할경우 앱에서 보내는것으로 수정될 예정
-(void)setViewID:(NSString *)viewID
{
    _viewID = viewID;
}

-(NSString *)viewID
{
	return _viewID;
}
////////////////////////////////////////////

//본인인증 완료 하이브리드 액션
- (void)successCertified:(NSDictionary*)param
{

}

#pragma mark - WebViewDelegate

- (BOOL)webView:(id<WebView>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    
	if(navigationType == WKNavigationTypeBackForward && !(_historyStack == nil && _preType == PreTypeGoBack && _webView.canGoBack))
	{
#ifdef DEBUG
        NSString * url = request.URL.absoluteString;
        NSString * msg = [NSString stringWithFormat:@"backForward호출 : %@", url];
        showSplashMessage(msg, YES, NO);
#endif
        
		return YES;
	}
	
	if([request.URL.scheme isEqualToString:@"kb-acp"])  // k-Motion
	{
        if([AppDelegate canOpenURL:request.URL])
		{
			NSString *urlStr = request.URL.absoluteString;
			if([urlStr rangeOfString:@"callback"].location == NSNotFound)
			{
				NSString *schemeStr = [Scheme_Action stringByAppendingFormat:@"://"];
//                urlStr = [urlStr stringByAppendingFormat:@"&callback=%@",schemeStr.stringByUrlEncoding]; // shimicity
                
                NSLog(@"%s, stringByUrlEncoding == %@", __FUNCTION__, schemeStr.stringByUrlEncoding);
                
                NSLog(@"%s, stringByAddingPercentEncodingWithAllowedCharacters == %@", __FUNCTION__, [schemeStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);

                
                urlStr = [urlStr stringByAppendingFormat:@"&callback=%@",[schemeStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
			}
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
		}
		else
		{
			[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"KBPay 앱이 설치되지 않았습니다.\n설치 화면으로 이동하시겠습니까?" dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
				if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:AlertConfirm])
				{
					NSURL *ispMobileAppDownloadURL = [NSURL URLWithString:STORE_LINK(@"id695436326")];
                    [[UIApplication sharedApplication] openURL:ispMobileAppDownloadURL options:@{} completionHandler:nil];
				}
			} cancelButtonTitle:AlertCancel buttonTitles:AlertConfirm, nil];
		}
		return NO;
	}
	else if([request.URL.scheme isEqualToString:@"ispmobile"])  // 모바일ISP 호출 처리
	{
		if([AppDelegate canOpenURL:request.URL])
		{
            [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
		}
		else
		{
			[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"모바일ISP 앱이 설치되지 않았습니다.\n설치 화면으로 이동하시겠습니까?" dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
				if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:AlertConfirm])
				{
					NSURL *ispMobileAppDownloadURL = [NSURL URLWithString:STORE_LINK(@"id369125087")];
                    [[UIApplication sharedApplication] openURL:ispMobileAppDownloadURL options:@{} completionHandler:nil];
				}
			} cancelButtonTitle:AlertCancel buttonTitles:AlertConfirm, nil];
		}
		return NO;
    }
    else if([request.URL.scheme isEqualToString:@"payco"])  // payco호출처리
    {
        if([AppDelegate canOpenURL:request.URL])
        {
            [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
        }
        else
        {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"PAYCO 앱이 설치되지 않았습니다.\n설치 화면으로 이동하시겠습니까?" dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:AlertConfirm])
                {
                    NSURL *ispMobileAppDownloadURL = [NSURL URLWithString:STORE_LINK(@"id924292102")];
                    [[UIApplication sharedApplication] openURL:ispMobileAppDownloadURL options:@{} completionHandler:nil];
                }
            } cancelButtonTitle:AlertCancel buttonTitles:AlertConfirm, nil];
        }
        return NO;
    }
    else { // PlusO2O에서 외부 앱 호출 처리
        NSURL *url = request.URL;
        NSString *requestString = url.absoluteString.stringByUrlDecoding;
		if (requestString.length > 0 && [requestString rangeOfString:@"plusO2O" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            //사파리, 앱, 스토어
            NSString *requestString2 = request.URL.absoluteString;
            NSString *jsonString = [self getParmaWithDict:requestString2];
            NSDictionary *d = [self getParameterKeyValue:jsonString];
            
            NSString *isOnlyWeb = [d objectForKey:@"isOnlyWeb"];
            if ([isOnlyWeb isEqualToString:@"Y"]) {
                NSString *webUrl = [d objectForKey:@"webUrl"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webUrl] options:@{} completionHandler:nil];
            }
            else {
                NSString *scheme = [d objectForKey:@"scheme"];
                NSString *packageName = [d objectForKey:@"packageName"];
                
                [self runApplication:scheme appId:packageName];
            }
            return NO;
        }
        else  {
            
            NSURL *requestedURL = [request URL];
            NSLog(@"pathExtension : %@", [requestedURL pathExtension]);
            NSString * extension = [requestedURL pathExtension];
            // 확장자가 xls이거나 xlsx일경우 페이지를 로드하지 않고 파일 다운로드를 한다.
            if (extension.length > 0 && ([@"xlsx" isEqualToString:extension] || [@"xls" isEqualToString:extension])) {
                // file down load url 주소
                NSData *fileData = [[NSData alloc] initWithContentsOfURL:requestedURL];
                // App Documents directory 경로
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder 경로
                
                [fileData writeToFile:[NSString stringWithFormat:@"%@/%@", documentsDirectory, [requestedURL lastPathComponent]] atomically:YES];
                
                showSplashMessage(@"다운로드가 완료되었습니다.", YES, NO);
                
                return NO;
            } else if (extension.length > 0 && ([@"pdf" isEqualToString:extension])) {
                if([AppDelegate canOpenURL:requestedURL]) {
                    [[UIApplication sharedApplication] openURL:requestedURL options:@{} completionHandler:nil];
                }
                return NO;
            }
        }
    }
    
	return YES;
}

- (void)webViewDidStartLoad:(id<WebView>)webView
{
    if (![webView isKindOfClass:[HybridWKWebView class]]) {
        return;
    }
    
    if(_indicator) {
        NSURLRequest *req;      //webview에서 request가 이전 request를 바라보고 있던 것 수정
        
         req = webView.request;

        if ([req.URL.absoluteString hasSuffix:@"KATFL10.do"]) {  // 중금리 대출 시 로딩화면 업무코드 변경(L01051 ->KATFL10)
            [GifProgress showGifWithName:gifType_jump completion:nil];
        }else {
            [IndicatorView show];
        }
    }
}

- (void)webViewDidFinishLoad:(id<WebView>)webView {
    // internal 백버튼 안나오는 부분수정
    [self checkNavigationControllerPreButton];
    
    if (![webView isKindOfClass:[HybridWKWebView class]]) {
        return;
    }
    
	_forwardButton.enabled = _webView.canGoForward;
	_backButton.enabled = _webView.canGoBack;
	if(_indicator)
		[IndicatorView hide];
	
	if([self.title isEqualToString:self.defultTitle])
	{
		[_webView stringByEvaluatingJavaScriptFromString:@"document.title;" completionHandler:^(NSString *result){
			NSString* documentTitle = result;
			NSLog(@"documentTitle = [%@]", documentTitle);
			if(documentTitle.length != 0)
				self.title = [[documentTitle componentsSeparatedByString:@"|"].firstObject trim];
		}];
	}
    
	if(_topMenu == nil)
	{
		self.menuHidden = NO;
		self.navigationItem.hidesBackButton = NO;
		[self setupLeftBarButtonItem];
	}
	
	if(self.performCallback)
	{
		self.performCallback(self);
		self.performCallback = nil;
	}
	
	[self checkScreenEdgeBack];
    
    
    // 메인의 자산/소비/톡톡/투데이 화면은 스크롤시 바운스 제거
    NSString *lastPathComponent = webView.request.URL.lastPathComponent;
    if (nil2Str(lastPathComponent)) {
        if ([lastPathComponent isEqualToString:@"ASTM102.do"] || // 자산
            [lastPathComponent isEqualToString:@"CNSM101.do"] || // 소비
            [lastPathComponent isEqualToString:@"SGSM101.do"] || // 톡톡
            [lastPathComponent isEqualToString:@"TODM100.do"]) { // 투데이
            [webView.scrollView setAlwaysBounceVertical:NO];
            [webView.scrollView setBounces:NO];
        }
    }
    
    // 페이지 로딩 완료 후 공통헤더 뷰 설정
    [self setTopMenu:_topMenu];
}

- (void)webView:(id<WebView>)webView didFailLoadWithError:(nullable NSError *)error {
    // internal 백버튼 안나오는 부분수정
    [self checkNavigationControllerPreButton];
    
    if (![webView isKindOfClass:[HybridWKWebView class]]) {
        return;
    }
    
	self.menuHidden = NO;
	self.navigationItem.hidesBackButton = NO;
	[self setupLeftBarButtonItem];
	if(_indicator)
        [GifProgress hideGif:nil];
		[IndicatorView hide];
	
	if (error.code == -2102 || error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorNotConnectedToInternet)
	{
		[BlockAlertView showBlockAlertWithTitle:@"알림" message:Net_Err_Msg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
			//exit(0);
		} cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
		return;
	}
}

#pragma mark - PlusO2O 외부 앱 호출 처리
- (NSString *)getParmaWithDict:(NSString *)requestString {
    NSString *body = [requestString substringFromIndex:9];
    NSRange range = [body rangeOfString:@"?"];
    NSString *functionName = nil, *jsonString = nil;
    if (range.location != NSNotFound) {
        functionName = [body substringToIndex:range.location];
        jsonString = [body substringFromIndex:range.location+1];
    }
    return jsonString;
}

- (NSMutableDictionary *)getParameterKeyValue:(NSString *)rtUrl {
    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc] init];
    NSArray *queryElements = [rtUrl componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        NSString *variableKey = [keyVal objectAtIndex:0];
        NSString *value = ((NSString *)[keyVal lastObject]).stringByUrlDecoding;
        
        [dictParam setObject:value forKey:variableKey];
    }
    return dictParam;
}

- (void)runApplication:(NSString *)scheme appId:(NSString *)appId {
    NSURL *schemeURL = [NSURL URLWithString:scheme];
    
    if ([AppDelegate canOpenURL:schemeURL]) {
        [[UIApplication sharedApplication] openURL:schemeURL options:@{} completionHandler:nil];
    } else {
        NSURL *installURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/kr/app/id%@?mt=8", appId]];
        [[UIApplication sharedApplication] openURL:installURL options:@{} completionHandler:nil];
    }
}

-(void)setShowToolBar:(BOOL)showToolBar
{
	_showToolBar = showToolBar;
	if(_showToolBar && _homeButton == nil)
	{
		_homeButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
		[_homeButton setExclusiveTouch:YES];
		[_homeButton setIsAccessibilityElement:YES];
		[_homeButton setAccessibilityLabel:@"홈"];
		[_homeButton setAccessibilityHint:@"홈화면으로 이동합니다."];
		[_homeButton addTarget:self action:@selector(goBasePage) forControlEvents:(UIControlEventTouchUpInside)];
		[_homeButton setImage:[UIImage imageNamed:@"btn_float_home.png"] forState:(UIControlStateNormal)];
		[_homeButton sizeToFit];
		
		_backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
		[_backButton setExclusiveTouch:YES];
		[_backButton setIsAccessibilityElement:YES];
		[_backButton setAccessibilityLabel:@"뒤로"];
		[_backButton setAccessibilityHint:@"이전화면으로 이동합니다."];
		[_backButton addTarget:self.webView action:@selector(goBack) forControlEvents:(UIControlEventTouchUpInside)];
		[_backButton setImage:[UIImage imageNamed:@"btn_float_arrow_l.png"] forState:(UIControlStateNormal)];
		[_backButton sizeToFit];
		
		_forwardButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
		[_forwardButton setExclusiveTouch:YES];
		[_forwardButton setIsAccessibilityElement:YES];
		[_forwardButton setAccessibilityLabel:@"다음"];
		[_forwardButton setAccessibilityHint:@"다음화면으로 이동합니다."];
		[_forwardButton addTarget:self.webView action:@selector(webViewGoForward) forControlEvents:(UIControlEventTouchUpInside)];
		[_forwardButton setImage:[UIImage imageNamed:@"btn_float_arrow_r.png"] forState:(UIControlStateNormal)];
		[_forwardButton sizeToFit];
		
		_forwardButton.enabled = _webView.canGoForward;
		_backButton.enabled = _webView.canGoBack;
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFixedSpace) target:nil action:nil];
		space.width = 50;
		self.toolbarItems = @[[[UIBarButtonItem alloc] initWithCustomView:_homeButton],
							  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:nil action:nil],
							  [[UIBarButtonItem alloc] initWithCustomView:_backButton],space,
							  [[UIBarButtonItem alloc] initWithCustomView:_forwardButton]];
	}
	else
	{
		self.toolbarItems = nil;
		_forwardButton = nil;
		_backButton = nil;
		_homeButton = nil;
	}
	
	if(self.isViewAppear)
	{
		self.navigationController.toolbarItems = self.toolbarItems;
		[self.navigationController setToolbarHidden:self.toolbarItems == nil animated:YES];
	}
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
}

//
-(UIView*)traverseSubViews:(UIView*)view{
 
    
    if ([[view description] hasPrefix:@"<UIWebFormAccessory"]){
        return view;
    }

    for(int i = 0 ; i < view.subviews.count; i++) {
        UIView *subView = view.subviews[i];
        if (subView.subviews.count > 0) {
            UIView *subvw = [self traverseSubViews:subView];
            if ([[subvw description] hasPrefix:@"<UIWebFormAccessory"]){
                return subvw;
            }
        }
    }
    return [[UIView alloc] init];
}

-(void)buttonAccessoryDoneAction:(UIButton*)sender{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)changeInputAccessoryView:(UIView *)inputAccessoryView toHeight:(CGFloat)height {
    for (NSLayoutConstraint *constraint in [inputAccessoryView constraints]) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = height;
            [inputAccessoryView layoutIfNeeded];
            break;
        }
    }
}

-(void)addNewAccessoryView:(UIView*)oldAccessoryView{
    CGRect frame = oldAccessoryView.frame;
    
    frame.size.height = 60;
    oldAccessoryView.frame = frame;
    
    
    UIView *newAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
    
    newAccessoryView.backgroundColor = [UIColor whiteColor];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
//    doneButton.frame = CGRectMake(5,5,frame.size.width-10,frame.size.height-10);
    doneButton.frame = newAccessoryView.frame;  //CGRectMake(5,5,frame.size.width-10,frame.size.height-10);
    [doneButton setTitle:@"충전하기" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneButton.titleLabel.font = BOLDFONTSIZE(15);
    doneButton.backgroundColor = [UIColor blueColor];
//    doneButton.cornerRadius = 5;
    
    [doneButton addTarget:self action:@selector(buttonAccessoryDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [newAccessoryView addSubview:doneButton];
    [oldAccessoryView addSubview:newAccessoryView];
        
    [self changeInputAccessoryView:oldAccessoryView toHeight:60];
    
//    [UIView setAnimationsEnabled:NO];
}

-(void)replaceKeyboardInputAccessoryView:(NSString *)buttonTitle buttonActionMethod:(NSString*)buttonAction{
    
    // locate accessory view
    
    long windowCount = [UIApplication sharedApplication].windows.count;
    if (windowCount < 2) {
        return;
    }

    UIWindow *tempWindow = [UIApplication sharedApplication].windows[1];
    
    UIView *accessoryView = [self traverseSubViews:tempWindow];
    if ([[accessoryView description] hasPrefix:@"UIWebFormAccessory"]) {
        // Found the inputAccessoryView UIView
        if (accessoryView.subviews.count > 0) {
            [self addNewAccessoryView:accessoryView];
            return;
        }
    }
    
    for (UIWindow* wind in [[UIApplication sharedApplication] windows]) {
        for (UIView* currView in wind.subviews) {
            if ([[currView description] containsString:@"UIInputSetContainerView"]) {
                for (UIView* perView in currView.subviews) {
                    for (UIView *subView in perView.subviews) {
                        
                        if ([[subView description] containsString:@"UIWebFormAccessory"]) {
//                            if(subView.frame.size.height != 60){
//                                for(UIView *AccessorySubView in subView.subviews){
//                                    [AccessorySubView removeFromSuperview];
//                                }
                                [self addNewAccessoryView:subView];
//                            }
                        }
                        
                    }
                }
            }
        }
    }
    
}

-(void)keyboardWillshow:(NSNotification*)notification{
    NSString * currentURL = self.webView.request.URL.absoluteString;
    if ([currentURL rangeOfString:@"liivmate.com"].location != NSNotFound) {
        CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
        
        CGFloat bottomPadding = 0.0f;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            bottomPadding = window.safeAreaInsets.bottom;
        }else{
            bottomPadding = 0;
        }

        CGRect keyboardResizedRect = self.webView.frame;
        keyboardResizedRect.size.height = [[UIScreen mainScreen] bounds].size.height - keyboardFrame.size.height - 50 - bottomPadding;

        //--------------------------------------------
        //프레임으로 처리
        //ios13에서 키보드 이벤트가 두번 먹고 있음. 그리고 두번째에서 키보드 높이가 50 이하로 작게 나와 해당 로직 추가
        if(keyboardFrame.size.height > 100){
            CGRect keyboardResizedRect2 = self.view.bounds;
            keyboardResizedRect2.size.height =  [[UIScreen mainScreen] bounds].size.height - keyboardFrame.size.height + 50 + bottomPadding;
            self.view.frame = keyboardResizedRect2;
            
            // Change the height dynamically of the UIWebView to match the html content
            self.webView.frame = keyboardResizedRect;
            //NSString *script = [NSString stringWithFormat:@"if($('body').prop('scrollHeight') <= %f){ $(window).scrollTop(0); }", orgHeight];
            //[self.webView stringByEvaluatingJavaScriptFromString:script completionHandler:^(NSString *result){ }];
        }
    }
}

-(void)keyboardWillHide:(NSNotification*)notification{
    NSString * currentURL = self.webView.request.URL.absoluteString;
    if ([currentURL rangeOfString:@"liivmate.com"].location != NSNotFound) {
        CGRect statusBarRect = [UIApplication sharedApplication].statusBarFrame;
        NSInteger nStatusBarHeight = statusBarRect.size.height;
        NSInteger nTopHeight = self.customNavigationBar.frame.size.height+nStatusBarHeight;

        CGRect rect2 = CGRectMake( 0, 0, self.view.bounds.size.width, self.view.bounds.size.height );
        rect2.size.height =  [[UIScreen mainScreen] bounds].size.height;
        self.view.frame = rect2;
        
        CGRect rect = self.view.bounds;
        rect.origin.y = nTopHeight;
        rect.size.height = rect.size.height - 50;
        [self.webView setFrame:rect];
    }
}

+ (void)sendGa360Native:(BOOL)isEvent p1:(NSString *)p1 p2:(NSString *)p2 p3:(NSString *)p3 campainUrl:(NSString *)url
{
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    NSMutableDictionary * dimension = [NSMutableDictionary dictionary];
    
    // ga360 로그인 정보에 따른 셋팅
    if ([AppInfo sharedInfo].isLogin) {
        [dimension setObject:@"1" forKey:@"dimension3"];                                       // 고객_로그인여부 (로그인 : 1, 비로그인 : 0)
#if DEBUG
        [dimension setObject:[AppInfo userInfo].ga_custGbnCd forKey:@"dimension4"];            // 고객_회원구분 (정회원 : 10, 준회원 : 20)
        [dimension setObject:[AppInfo userInfo].ga_age forKey:@"dimension5"];                  // 고객_연령대 (10, 20, 30 ...)
        [dimension setObject:[AppInfo userInfo].ga_gender forKey:@"dimension6"];               // 고객_성별 (남자 : 1, 여자 : 2)
        [dimension setObject:[AppInfo userInfo].ga_starClubGrade forKey:@"dimension7"];        // 고객_스타클럽 (mvp : 4, 로얄 : 3, 골드 : 2, 프리미엄 : 1, 등급없음 : 0)
        [dimension setObject:[AppInfo userInfo].ga_bamt forKey:@"dimension8"];                 // 고객_보유포인트 (보유 : 1, 미보유 : 0)
        [dimension setObject:[AppInfo userInfo].ga_scrpTgFiorMdulsYN forKey:@"dimension9"];    // 고객_자산연동여부 (연동 : 1, 미연동 : 0)
        [dimension setObject:[AppInfo userInfo].ga_scrpTgFiorMduls forKey:@"dimension10"];     // 고객_연동금융기관
        [dimension setObject:[AppInfo userInfo].ga_chrgWayRegYn forKey:@"dimension11"];        // 고객_충전수단등력여부 (등록 : 1, 미등록 : 0)
        [dimension setObject:[AppInfo userInfo].ga_autoChrgRegYn forKey:@"dimension12"];       // 고객_자동충전등록여부 (등록 : 1, 미등록 : 0)
        [dimension setObject:[AppInfo userInfo].ga_cardOwnGbnCd forKey:@"dimension13"];        // 고객_카드보유여부
#else // userInfo 값이 nil일 때 체크하는 코드 추가
        [dimension setObject:nil2Str([AppInfo userInfo].ga_custGbnCd) forKey:@"dimension4"];            // 고객_회원구분 (정회원 : 10, 준회원 : 20)
        [dimension setObject:nil2Str([AppInfo userInfo].ga_age) forKey:@"dimension5"];                  // 고객_연령대 (10, 20, 30 ...)
        [dimension setObject:nil2Str([AppInfo userInfo].ga_gender) forKey:@"dimension6"];               // 고객_성별 (남자 : 1, 여자 : 2)
        [dimension setObject:nil2Str([AppInfo userInfo].ga_starClubGrade) forKey:@"dimension7"];        // 고객_스타클럽 (mvp : 4, 로얄 : 3, 골드 : 2, 프리미엄 : 1, 등급없음 : 0)
        [dimension setObject:nil2Str([AppInfo userInfo].ga_bamt) forKey:@"dimension8"];                 // 고객_보유포인트 (보유 : 1, 미보유 : 0)
        [dimension setObject:nil2Str([AppInfo userInfo].ga_scrpTgFiorMdulsYN) forKey:@"dimension9"];    // 고객_자산연동여부 (연동 : 1, 미연동 : 0)
        [dimension setObject:nil2Str([AppInfo userInfo].ga_scrpTgFiorMduls) forKey:@"dimension10"];     // 고객_연동금융기관
        [dimension setObject:nil2Str([AppInfo userInfo].ga_chrgWayRegYn) forKey:@"dimension11"];        // 고객_충전수단등력여부 (등록 : 1, 미등록 : 0)
        [dimension setObject:nil2Str([AppInfo userInfo].ga_autoChrgRegYn) forKey:@"dimension12"];       // 고객_자동충전등록여부 (등록 : 1, 미등록 : 0)
        [dimension setObject:nil2Str([AppInfo userInfo].ga_cardOwnGbnCd) forKey:@"dimension13"];        // 고객_카드보유여부
#endif
    } else {
        [dimension setObject:@"0" forKey:@"dimension3"];
    }
    
    // 이벤트인지 화면인지에 따른 셋팅
    if(isEvent) {
        [dimension setObject:@"" forKey:@"dimension16"];            // 이벤트_이벤트코드 : 이벤트 페이지 eventid 값 전송
        [dimension setObject:nil2Str(p3) forKey:@"dimension15"];    // 사이트_메뉴경로 : 사용자가 유입된 메뉴 경로를 나타낸
        [dimension setObject:nil2Str(p3) forKey:@"dimension17"];    // 이벤트_이벤트상세명 : 이벤트 페이지 내 해당 이벤트명 전송
        
        [info setObject:nil2Str(p1) forKey:@"category"];
        [info setObject:nil2Str(p2) forKey:@"action"];
        [info setObject:nil2Str(p3) forKey:@"label"];
        [info setObject:@{} forKey:@"metric"];
        [info setObject:nil2Str(p3) forKey:@"title"];
        [info setObject:@"E" forKey:@"type"];
        [info setObject:nil2Str([AppInfo userInfo].custNo) forKey:@"userId"];
    } else {
        [dimension setObject:nil2Str(p2) forKey:@"dimension14"];    // 사이트_화면이름 : 사용자가 조회한 사이트 화면 코드값
        [dimension setObject:nil2Str(p3) forKey:@"dimension15"];    // 사이트_메뉴경로 : 사용자가 유입된 메뉴 경로
        
        [info setObject:@{} forKey:@"metric"];
        [info setObject:nil2Str(p3) forKey:@"title"];
        [info setObject:@"P" forKey:@"type"];
        [info setObject:nil2Str([AppInfo userInfo].custNo) forKey:@"userId"];
    }
    
    [info setObject:dimension forKey:@"dimension"];
    
    if (url) {
        [info setObject:url forKey:GAHitKey(CampaignUrl)];
    }
    
    [self sendGa360:info];
}

+(void)sendGa360:(NSDictionary*)infoDic{
    // 2020.5.14 최일용 구글 애널리틱스 추가.
    //----------------------------------------------------------
    //Golden Planet에서 받은 GoogleAnalyticsBuilder.h m파일 헤더추가후 호출할수 있음
    
    NSDictionary *dimensions =  [infoDic valueForKey:@"dimension"];
    
    NSLog(@"GACustomKey(Dimension1): %@",GACustomKey(Dimension1));
    NSMutableDictionary *screenView_dict = [[NSMutableDictionary alloc] init];
//    NSString *dimension1        = [AppInfo userInfo].cId; //@"UA-65962490-15";//기존코드로 바꿔달라고 골든플레닛 요청 0528
    id<GAITracker> mTracker = [[GAI sharedInstance] defaultTracker];
    NSString *dimension1 = [mTracker get:@"&cid"];  // 골든플레닛 요청 0728
    
    NSString *dimension2        = nil2Str([AppInfo userInfo].ga_kbPinEnc);      // kbpin 암호화값
    NSString *dimension20       = nil2Str([AppInfo userInfo].ga_semiMbrIdfEnc); // 준회원식별자 암호화값
    NSString *dimension19       = @"";
    
    if (![AppInfo sharedInfo].isIdfaDisable) {
        // IDFA(광고 식별자) 등록 - 최초/재가입시 서버와 통신(서버에서 최초 가입 판단해서 진행)
        NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        dimension19    = IDFA.UUIDString;
    }
    
//    NSString *dimension20    =  [AppInfo userInfo].kpinDes; // 로그인시 받아 온 kpin값 (DES 암호화 알고리즘 적용된 값 - 데이터혁신부 요청 사항(0720)
    
    [screenView_dict setValue:dimension1 forKey:GACustomKey(Dimension1)];
    [screenView_dict setValue:dimension2 forKey:GACustomKey(Dimension2)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension3)] forKey:GACustomKey(Dimension3)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension4)] forKey:GACustomKey(Dimension4)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension5)] forKey:GACustomKey(Dimension5)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension6)] forKey:GACustomKey(Dimension6)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension7)] forKey:GACustomKey(Dimension7)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension8)] forKey:GACustomKey(Dimension8)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension9)] forKey:GACustomKey(Dimension9)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension10)] forKey:GACustomKey(Dimension10)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension11)] forKey:GACustomKey(Dimension11)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension12)] forKey:GACustomKey(Dimension12)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension13)] forKey:GACustomKey(Dimension13)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension14)] forKey:GACustomKey(Dimension14)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension15)] forKey:GACustomKey(Dimension15)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension16)] forKey:GACustomKey(Dimension16)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension17)] forKey:GACustomKey(Dimension17)];
    [screenView_dict setValue:[dimensions valueForKey:GACustomKey(Dimension18)] forKey:GACustomKey(Dimension18)];
    [screenView_dict setValue:dimension19 forKey:GACustomKey(Dimension19)];
    [screenView_dict setValue:dimension20 forKey:GACustomKey(Dimension20)];

    [screenView_dict setValue:[infoDic valueForKey:@"title"] forKey:GAHitKey(Title)];
    [screenView_dict setValue:dimension2 forKey:GAHitKey(UserID)];
   
      
    NSString *type = [infoDic objectForKey:@"type"];
    
    NSString * campainUrl = [infoDic objectForKey:GAHitKey(CampaignUrl)];
    if (campainUrl) {
        [screenView_dict setValue:[infoDic objectForKey:GAHitKey(CampaignUrl)] forKey:GAHitKey(CampaignUrl)];
    }
    
    //화면
    if([type isEqualToString:@"P"]){
        GADataSend_Screen(screenView_dict);
        
    //이벤트
    }else{
        [screenView_dict setValue:[infoDic objectForKey:@"label"] forKey:GAHitKey(EventLabel)];
        [screenView_dict setValue:[infoDic objectForKey:@"action"] forKey:GAHitKey(EventAction)];
        [screenView_dict setValue:[infoDic objectForKey:@"category"] forKey:GAHitKey(EventCategory)];
        
        GADataSend_Event(screenView_dict);
    }
}
@end

@implementation HybridViewController
-(void)dealloc
{
    [HybridActionManager cancelActionWithWebView:self.webView];
    self.webView.webViewDelegate = nil;
    self.webView.scrollView.delegate = nil;
}
@end

@implementation WVRequest : NSMutableURLRequest

- (void)setbody:(NSDictionary *)dict isPassEncoding:(BOOL)isPassEncoding isEnc:(BOOL)isEnc
{
    [self setHTTPMethod:@"POST"];
    NSString *param = nil;
    
    if (isPassEncoding) {
        param = [NSString urlQueryString:dict];
    } else {
        param = [NSString urlEncodedQueryString:dict];
    }

    // 앱기동데이타에 url정보가 있으면 해더 암호화
    if (isEnc) {
        param = [self getEncParam:dict];
    }

    NSData *jsonData = [param dataUsingEncoding:(NSUTF8StringEncoding)];
    [self setHTTPBody:jsonData];
    [self setValue:[NSString stringWithFormat:@"%d", ((int)[jsonData length])] forHTTPHeaderField:@"Content-Length"];
    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
}

- (NSString *)getEncParam:(NSDictionary *)dict
{
    NSString *param = nil;
    NSMutableDictionary * encodeDic = [dict mutableCopy];
    
    for (NSString * key in dict) {
        NSString * value = dict[key];
        [encodeDic setObject:value.stringByUrlEncoding forKey:key];
    }
    NSLog(@"encodeDic : %@", encodeDic);
    
    NSString *encParam = [PwdWrapper encryptedDictionary:encodeDic] ? [PwdWrapper encryptedDictionary:encodeDic] : @"";
    param = [NSString stringWithFormat:@"params=%@",encParam.stringByUrlEncoding];
    
    return param;
}
@end
