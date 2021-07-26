//
//  HybridWKWebView.m
//  LiivMate
//
//  Created by kbcard on 2018. 5. 23..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "HybridWKWebView.h"
#import "HybridActionManager.h"
#import "WebViewController.h"
#import "KCLIntroViewController.h"
#import "NoticeAlertView.h"
#import <objc/runtime.h>
#import "NSString+Cookie.h"
#import <Firebase/Firebase.h>




@interface NSHTTPCookie (JavaScriptString)
- (NSString *)wn_javascriptString;
@end

@implementation NSHTTPCookie (JavaScriptString)

- (NSString *)wn_javascriptString
{
	NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",
						self.name,
						self.value,
						self.domain,
						self.path ?: @"/"];
	
	if (self.secure) {
		string = [string stringByAppendingString:@";secure=true"];
	}
	
	return string;
}

@end

@interface NSString (Swizzle)

@end

@implementation NSString (Swizzle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        NSOperatingSystemVersion iOS_13_0_0 = (NSOperatingSystemVersion){13, 0, 0};
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_13_0_0]) {

            SEL originalSelector = @selector(stringByReplacingCharactersInRange:withString:);
            SEL swizzledSelector = @selector(swizzle_stringByReplacingCharactersInRange:withString:);

            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

            BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
            if (success) {
                class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

- (NSString *)swizzle_stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement
{
    return [self swizzle_stringByReplacingCharactersInRange:range withString:replacement ?: @""];
}

@end

@interface HybridWKWebViewConfigurationManager : NSObject <WKHTTPCookieStoreObserver>

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@end


static HybridWKWebViewConfigurationManager *sharedManager = nil;

inline static HybridWKWebViewConfigurationManager* getSharedManager()
{
	if(sharedManager == nil)
		sharedManager = [[HybridWKWebViewConfigurationManager alloc] init];
	return sharedManager;
}

@interface HybridWKWebView () <WKUIDelegate, WKNavigationDelegate>
{
	
}

@property (nonatomic, strong) HybridWKWebViewConfigurationManager *configurationManager;

@end





@implementation HybridWKWebViewConfigurationManager

- (id)init
{
	self = [super init];
	if (self)
	{
		self.configuration = [[WKWebViewConfiguration alloc] init];
		[self setupConfiguration:self.configuration];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mateRequestCookieChanged:) name:MateRequestCookieNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionCookieChanged:) name:LoginStatusChangedNotification object:nil];
	}
	
	return self;
}

// for cookie
-(void)mateRequestCookieChanged:(NSNotification*)noti
{
	if (@available(iOS 11.0, *))
	{
		NSLog(@"\[NSCOOKIE -> WKCOOKIE] (2) - 웹뷰 cookie Notification 실행");
		NSArray *cookies = noti.userInfo[@"cookies"];
		dispatch_async(dispatch_get_main_queue(), ^{
            
			for (NSHTTPCookie *cookie in cookies)
			{
				[self.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:^{
					NSLog(@"\[NSCOOKIE -> WKCOOKIE] (2.0) - 웹뷰 httpCookieStore 저장 완료");
				}];
			}
		});
    }  else {
        
        [self.configuration.userContentController removeAllUserScripts];
        [HybridWKWebViewConfigurationManager addViewPortMetaWithScalePageToFit:self.configuration.userContentController];
        
        if (!IS_USE_WKWEBVIEW) {
            // ios11이하에서는 쿠키스토리지를 접근할수 없으므로 강제로 쿠키를 밀어넣어야함
            [HybridWKWebViewConfigurationManager addCookieInScriptWithController:self.configuration.userContentController];
        }

    }
}

- (void)sessionCookieChanged:(NSNotification*)noti
{
    if (@available(iOS 11.0, *))
    {
        if([AppInfo sharedInfo].isLogin == NO) {
            
            [self.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * cookies) {
                
                for (NSHTTPCookie *cookie in cookies)
                {
                    NSLog(@"%@",cookie);
                    NSLog(@"%@",cookie);
                    if ([cookie.name isEqualToString:@"SESSION"])
                    [self.configuration.websiteDataStore.httpCookieStore deleteCookie:cookie completionHandler:^{}];
                }
            }];
        }
    }
}

// for cookie (ver.3)
- (void)cookiesDidChangeInCookieStore:(WKHTTPCookieStore *)cookieStore	API_AVAILABLE(macosx(10.13), ios(11.0))
{
	NSLog(@"cookiesDidChangeInCookieStore");
	
	[cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
		NSLog(@"\n[HTTP REQUEST COOKIE] : %@", cookies);
		for (NSHTTPCookie *cookie in cookies)
		{
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
		}
	}];
}

- (void)setupConfiguration:(WKWebViewConfiguration *)configuration
{
	// for cookie (ver.3)
	if (@available(iOS 11.0, *))
	{
		WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
		configuration.websiteDataStore = dataStore;

		NSArray *allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
		for (NSHTTPCookie *cookie in allCookies)
		{
			[configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:^{
				NSLog(@"[SET-COOKIE] : %@", cookie);
			}];
		}

		//NSLog(@"[SET-COOKIE] FINISHED");

		// cookie sync
		/*
		[dataStore.httpCookieStore addObserver:self];
		*/
	}
	
	WKPreferences *preferences = configuration.preferences;
	preferences.javaScriptCanOpenWindowsAutomatically = YES;
	preferences.javaScriptEnabled = YES;
	
	WKUserContentController *userContentController = configuration.userContentController;
    [HybridWKWebViewConfigurationManager addViewPortMetaWithScalePageToFit:userContentController];
    
    if (!IS_USE_WKWEBVIEW) {
        // ios11이하에서는 쿠키스토리지를 접근할수 없으므로 강제로 쿠키를 밀어넣어야함
        [HybridWKWebViewConfigurationManager addCookieInScriptWithController:userContentController];
    }
}

+ (void)addViewPortMetaWithScalePageToFit:(WKUserContentController*)userContentController
{
    NSString *script =
    @"var lm_wkwebview_meta_viewport_tag_id;  "
    @"var lm_wkwebview_meta_viewport_tag_content;  "
    
    @"function lm_wkwebview_SetupViewPortMeta() {  "
    @"    var shouldAdd = true;  "
    @"    var x = document.getElementsByTagName('META');  "
    @"    var i;  "
    @"    for (i = 0; i < x.length; i++) {  "
    @"        if (x[i].name.toLowerCase() == 'viewport') {  "
    @"            shouldAdd = false;  "
    @"            if (x[i].id == null || x[i].id.length == 0) {  "
    @"                lm_wkwebview_meta_viewport_tag_id = 'lm_wkwebview_meta_viewport';  "
    @"                lm_wkwebview_meta_viewport_tag_content = x[i].content;  "
    @"                x[i].setAttribute('id', lm_wkwebview_meta_viewport_tag_id);  "
    @"            }  "
    @"            else {  "
    @"                lm_wkwebview_meta_viewport_tag_id = x[i].id;  "
    @"                lm_wkwebview_meta_viewport_tag_content = x[i].content;  "
    @"            }  "
    @"            break;  "
    @"        }  "
    @"    }  "
    @"    if (shouldAdd) {  "
    @"        lm_wkwebview_meta_viewport_tag_id = 'lm_wkwebview_meta_viewport';  "
    @"        lm_wkwebview_meta_viewport_tag_content = 'width=device-width, initial-scale=1.0, user-scalable=no';  "
    @"        var meta = document.createElement('META');  "
    @"        meta.setAttribute('name', 'viewport');  "
    @"        meta.setAttribute('content', lm_wkwebview_meta_viewport_tag_content);  "
    @"        meta.setAttribute('id', lm_wkwebview_meta_viewport_tag_id);  "
    @"        document.getElementsByTagName('HEAD')[0].appendChild(meta);  "
    @"    }  "
    @"};  "
    
    @"function lm_wkwebview_ScalesPageToFit(shouldFit) {  "
    @"    var viewport_meta = document.getElementById(lm_wkwebview_meta_viewport_tag_id);  "
    @"    if (viewport_meta != null) {  "
    @"        var content = viewport_meta.getAttribute('content');  "
    @"        var new_content;  "
    @"        if (shouldFit == true) {  "
    @"            new_content = 'width=device-width, initial-scale=1.0, user-scalable=yes';  "
    @"            viewport_meta.setAttribute('content', new_content);  "
    @"        }  "
    @"        else {  "
    @"            new_content = lm_wkwebview_meta_viewport_tag_content;  "
    @"            if (new_content.toLowerCase().includes('user-scalable') == false) {  "
    @"                new_content = new_content + ', user-scalable=no';  "
    @"            }  "
    @"            viewport_meta.setAttribute('content', new_content);  "
    @"        }  "
    @"    }  "
    @"    else {  "
    @"        var x = document.getElementsByTagName('META');  "
    @"        var i;  "
    @"        for (i = 0; i < x.length; i++) {  "
    @"            if (x[i].name.toLowerCase() == 'viewport') {  "
    @"                viewport_meta = x[i];  "
    @"            }  "
    @"        }  "
    @"    }  "
    @"};  "
    
    @"lm_wkwebview_SetupViewPortMeta(); "
    @"window.webkit.messageHandlers.initial.postMessage('ScalesPageToFit'); ";
    
    WKUserScript *viewportScript = [[WKUserScript alloc] initWithSource:script
                                                          injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                       forMainFrameOnly:YES];
    [userContentController addUserScript:viewportScript];
}

+ (void)addCookieInScriptWithController:(WKUserContentController*)userContentController
{
    NSMutableString* script = [[NSMutableString alloc] init];

    // Get the currently set cookie names in javascriptland
    [script appendString:@"var cookieNames = document.cookie.split('; ').map(function(cookie) { return cookie.split('=')[0] } );\n"];

    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // Skip cookies that will break our script
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        // Create a line that appends this cookie to the web view's document's cookies
//        [script appendFormat:@"if (cookieNames.indexOf('%@') == -1) { document.cookie='%@'; };\n", cookie.name, [cookie wn_javascriptString]];
        
        [script appendFormat:@" document.cookie='%@';\n", [cookie wn_javascriptString]];

    }
    WKUserScript *cookieInScript = [[WKUserScript alloc] initWithSource:script
                                                          injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                       forMainFrameOnly:YES];
    [userContentController addUserScript:cookieInScript];
}

@end






@implementation HybridWKWebView
@synthesize parentNotice;
+ (void)load
{
	if (IS_USE_WKWEBVIEW)
	{
		// for focus
		{
			[self allowDisplayingKeyboardWithoutUserAction];
		}
	}
}

// for focus
+ (void)allowDisplayingKeyboardWithoutUserAction
{
    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPad"] )
    {
        // ios14 ipad 에서 웹 포커스를 이동시키면 앱 crash.. iphone, ipod일 떄만 포커스 이동코드 적용
        Class class = NSClassFromString(@"WKContentView");
        NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
        NSOperatingSystemVersion iOS_12_2_0 = (NSOperatingSystemVersion){12, 2, 0};
        NSOperatingSystemVersion iOS_13_0_0 = (NSOperatingSystemVersion){13, 0, 0};
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_13_0_0]) {
            SEL selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:");
            Method method = class_getInstanceMethod(class, selector);
            IMP original = method_getImplementation(method);
            IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
                ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
            });
            method_setImplementation(method, override);
        }
        else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_12_2_0]) {
            SEL selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
            Method method = class_getInstanceMethod(class, selector);
            IMP original = method_getImplementation(method);
            IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
                ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
            });
            method_setImplementation(method, override);
        }
        else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
            SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
            Method method = class_getInstanceMethod(class, selector);
            IMP original = method_getImplementation(method);
            IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
                ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
            });
            method_setImplementation(method, override);
        } else {
            SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
            Method method = class_getInstanceMethod(class, selector);
            IMP original = method_getImplementation(method);
            IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
                ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
            });
            method_setImplementation(method, override);
        }
    }
    
    
//
//    Class class = NSClassFromString(@"WKContentView");
//    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
//
//    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
//        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
//        Method method = class_getInstanceMethod(class, selector);
//        IMP original = method_getImplementation(method);
//        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
//            ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
//        });
//        method_setImplementation(method, override);
//    } else {
//        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
//        Method method = class_getInstanceMethod(class, selector);
//        IMP original = method_getImplementation(method);
//        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
//            ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
//        });
//        method_setImplementation(method, override);
//    }
}

WKWebView *__GLOBAL_webView = nil;
//+ (void)initialize
//{
//	[super initialize];
//
//    if (IS_USE_WKWEBVIEW && __GLOBAL_webView == nil)
//	{
//		__GLOBAL_webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:getSharedManager().configuration];
//		[__GLOBAL_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//			if (!error)
//			{
//				NSString *secretAgent = result;
//				NSString *appNm = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
//                NSString *appVer = [AppInfo sharedInfo].appVer;
//                NSString *osVer = [AppInfo sharedInfo].osVer;
//                NSString *devModel = [AppInfo sharedInfo].platform;
//				//Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13E230/LiivMate_I/1/1.0.0/uWPtUPsQ+AIdF79aI84JqRMdGrAs2hmY3D9j6u8tHhA=
//                NSString * webUaProfile = [NSString stringWithFormat:@"%@|%@_I/%@|AppVer=%@|OsVer=%@|OS=I|DeviModel=%@|efds=%@;",secretAgent, appNm ,User_Agent_Ver, appVer, osVer, devModel,[EtcUtil efdsDeviceInfo]];
//
//				[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : webUaProfile}];
//				[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"User-Agent" : webUaProfile}];
//				[[NSUserDefaults standardUserDefaults] synchronize];
//			}
//
//			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//				__GLOBAL_webView = nil;
//			});
//		}];
//	}
//}


- (void)dealloc
{
}


- (id)initWithFrame:(CGRect)frame
{
	HybridWKWebViewConfigurationManager *configurationManager = getSharedManager();
	
	self = [super initWithFrame:frame configuration:configurationManager.configuration];
	if (self)
	{
		self.configurationManager = configurationManager;
		
		[self setupNext];
		[super setUIDelegate:self];
		[super setNavigationDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(under11OsCookieChanged:) name:MateRequestCookieNotification object:nil];
	}
	return self;
}

//- (id)init
//{
//	return [self initWithFrame:CGRectZero];
//}


- (id)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
	HybridWKWebViewConfigurationManager *configurationManager = getSharedManager();

	self = [super initWithFrame:frame configuration:configurationManager.configuration];
	if (self)
	{
		self.configurationManager = configurationManager;

		[self setupNext];
		[super setUIDelegate:self];
		[super setNavigationDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(under11OsCookieChanged:) name:MateRequestCookieNotification object:nil];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		HybridWKWebViewConfigurationManager *configurationManager = getSharedManager();
		//configurationManager.configuration = self.configuration;
		[configurationManager setupConfiguration:self.configuration];
		
		self.configurationManager = configurationManager;
		
		[self setupNext];
		[super setUIDelegate:self];
		[super setNavigationDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(under11OsCookieChanged:) name:LoginStatusChangedNotification object:nil];
	}
	return self;
}


- (void)setupNext
{
	self.allowsLinkPreview = NO;
#if ScreenEdgeBackMode
	self.allowsBackForwardNavigationGestures = YES;
#endif
    
    [self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        if (!error)
        {
            NSString *secretAgent = result;
            NSString *appNm = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
            NSString *appVer = [AppInfo sharedInfo].appVer;
            NSString *osVer = [AppInfo sharedInfo].osVer;
            NSString *devModel = [AppInfo sharedInfo].platform;
            //Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13E230/LiivMate_I/1/1.0.0/uWPtUPsQ+AIdF79aI84JqRMdGrAs2hmY3D9j6u8tHhA=
            NSString * webUaProfile = [NSString stringWithFormat:@"%@|%@_I/%@|AppVer=%@|OsVer=%@|OS=I|DeviModel=%@",secretAgent, appNm ,User_Agent_Ver, appVer, osVer, devModel];
            
            if ([AppInfo sharedInfo].setEfdsDataYn.boolValue) {
                webUaProfile = [webUaProfile stringByAppendingFormat:@"|efds=%@;" ,[EtcUtil efdsDeviceInfo]];
            } else {
                webUaProfile = [webUaProfile stringByAppendingString:@";"];
            }
            
            self.customUserAgent = webUaProfile;
        }
    }];
}

// for viewport
- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
	_scalesPageToFit = scalesPageToFit;
	[self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"lm_wkwebview_ScalesPageToFit(%@);", scalesPageToFit ? @"true" : @"false"] completionHandler:nil];
}

- (void)webViewLoadRequest:(NSURLRequest *)request
{
	if(request == nil) return;
	self.request = request;
	[self loadRequest:request];
}
- (void)webViewGoBack
{
	[self goBack];
}
- (void)webViewGoForward
{
	[self goForward];
}

-(id)loadRequest:(NSURLRequest *)originalRequest
{
	NSMutableURLRequest *request = [originalRequest mutableCopy];
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	
	NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL]];
	for (NSString *key in headers.allKeys)
	{
		[request setValue:headers[key] forHTTPHeaderField:key];
	}

	return [super loadRequest:request];
}


-(void)stringByEvaluatingJavaScriptFromString:(NSString *)script completionHandler:(void (^ _Nullable)(NSString * _Nullable result))completionHandler
{
	//NSLog(@"callJavaScript %@",script);
	[self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
		if (!error)
		{
			if (completionHandler)
			{
                if (result) {
                    completionHandler([NSString stringWithFormat:@"%@", result]);
                }else{
                  completionHandler(nil);
                }
			}
		}
		else
		{
			if (completionHandler) completionHandler(nil);
		}
	}];
}

- (void)under11OsCookieChanged:(NSNotification *)noti
{
    if (@available(iOS 11.0, *)) {}
    else {
//        NSArray *cookies = noti.userInfo[@"cookies"];
        
        NSMutableString* script = [[NSMutableString alloc] init];

        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            
            [script appendFormat:@" document.cookie='%@';\n", [cookie wn_javascriptString]];

        }
        [self stringByEvaluatingJavaScriptFromString:script completionHandler:nil];
    }
}


#pragma mark - WKWebView UIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    // 백그라운드에서 세션이끊긴채 돌아왔을때 KCLIntroViewController부터 다시타는데
    // 아직 메모리에 있는 메인뷰에서 웹알럿이 떴을경우 완료핸들러를 호출할 방법이 없어 앱이 크래시 나는경우가 발생
    // 윈도우의 루트뷰가 인트로일경우 알럿을 띄우지 않고 바로 핸들러를 호출해준다. 어차피 이후 메인뷰를 새로 생성하기떄문에
    // 이렇게 패치해도 위험도는 없어보임
    UIViewController * vc = [APP_DELEGATE window].rootViewController;

    if ([vc isKindOfClass:[KCLIntroViewController class]]) {
         if (completionHandler) completionHandler();
        return;
    }
    
	dispatch_async(dispatch_get_main_queue(), ^{
//		NSLog(@"ALERT:[%@]",message);
//		CLS_LOG(@"ALERT:[%@]",message);
        [[FIRCrashlytics crashlytics] logWithFormat:@"ALERT:[%@]",message];
		[BlockAlertView showBlockAlertWithTitle:nil message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
			if (completionHandler) completionHandler();
        } wkCancleCallback:^{
            if (completionHandler) completionHandler();
        }  cancelButtonTitle:nil buttonTitles:@"확인", nil];
	});
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    // 백그라운드에서 세션이끊긴채 돌아왔을때 KCLIntroViewController부터 다시타는데
    // 아직 메모리에 있는 메인뷰에서 웹알럿이 떴을경우 완료핸들러를 호출할 방법이 없어 앱이 크래시 나는경우가 발생
    // 윈도우의 루트뷰가 인트로일경우 알럿을 띄우지 않고 바로 핸들러를 호출해준다. 어차피 이후 메인뷰를 새로 생성하기떄문에
    // 이렇게 패치해도 위험도는 없어보임
    UIViewController * vc = [APP_DELEGATE window].rootViewController;

    if ([vc isKindOfClass:[KCLIntroViewController class]]) { 
        if (completionHandler) completionHandler(NO);
        return;
    }
    
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@"CONFIRM:[%@]",message);
//		CLS_LOG(@"CONFIRM:[%@]",message);
        [[FIRCrashlytics crashlytics] logWithFormat:@"CONFIRM:[%@]",message];
		[BlockAlertView showBlockAlertWithTitle:@"" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            if (completionHandler){
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"취소"]){
                    self.javascriptAlertResultYn = @"취소";
                }else{
                    self.javascriptAlertResultYn = @"";
                }
                completionHandler([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"확인"]);
            }
        } wkCancleCallback:^{
            if (completionHandler){
                completionHandler(NO);
            }
        } cancelButtonTitle:@"취소" buttonTitles:@"확인", nil];
	});
}
/*
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    _wkWebviewPop = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    _wkWebviewPop.navigationDelegate = self;
    _wkWebviewPop.UIDelegate = self;
    
    [self addSubview:_wkWebviewPop];
    
    return _wkWebviewPop;
}

- (void)webViewDidClose:(WKWebView *)webView
{
    if (webView == _wkWebviewPop) {
        [_wkWebviewPop removeFromSuperview];
        _wkWebviewPop.navigationDelegate = nil;
        _wkWebviewPop.UIDelegate = nil;
        _wkWebviewPop = nil;
    }
}
*/

#pragma mark - WKWebView NavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
	NSURLRequest *request = navigationAction.request;
	if(request == nil)
	{
		decisionHandler(WKNavigationActionPolicyAllow);
		return;
	}
    
    if (webView == _wkWebviewPop) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
	
    if (((HybridWKWebView *)webView).parentNotice) {
        
        if ([_webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        {
            NSInteger navigationType = navigationAction.navigationType;
            BOOL allow = [_webViewDelegate webView:(id)webView shouldStartLoadWithRequest:request navigationType:navigationType];
            if (!allow)
            {
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    
	if ([HybridActionManager registActionWithWebView:(id<WebView>)webView request:request])
	{
        decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}
	
	if (([request.URL.scheme rangeOfString:Scheme_External].location == 0 || [request.URL.scheme rangeOfString:Scheme_Internal].location == 0)
		&& request.URL.scheme != nil)
	{
		[[AllMenu delegate] sendBirdDetailPage:request.URL.absoluteString callBack:^(ViewController *vc) {}];
		
		decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}
	
	if ([request.URL.scheme isEqualToString:Scheme_Back])
	{
		[self.parentViewController.navigationController popViewControllerAnimated:YES];
		
		decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}
	
	if ([request.URL.scheme isEqualToString:Scheme_Main])
	{
        // 로그인 인증화면에서 메인 화면이 pop되는 문제 방어 코드 처리
        if ([AppInfo sharedInfo].isJoin == YES) {
            [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
            decisionHandler(WKNavigationActionPolicyCancel);
        
            return;
        }
	}
	
	if ([request.URL.scheme isEqualToString:Scheme_Menu])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:MenuOpenNotification object:nil];
		
		decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}
	
    if ([request.URL.scheme isEqualToString:@"file"])
    {
        
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
	if ([_webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
	{
		NSInteger navigationType = navigationAction.navigationType;
		BOOL allow = [_webViewDelegate webView:(id)webView shouldStartLoadWithRequest:request navigationType:navigationType];
		if (!allow)
		{
			decisionHandler(WKNavigationActionPolicyCancel);
			return;
		}
	}
	
	// for wkwebview not supported url scheme
    if (!([[request.URL.scheme lowercaseString] isEqualToString:@"http"] ||
          [[request.URL.scheme lowercaseString] isEqualToString:@"https"] ||
          [[request.URL.scheme lowercaseString] isEqualToString:@"about"]))
    {
        if ([AppDelegate canOpenURL:request.URL])
        {
            [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

	decisionHandler(WKNavigationActionPolicyAllow);
	if([navigationAction.request.URL.absoluteString isEqualToString:@"about:blank"] == NO)
		self.request = navigationAction.request;
	return;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
	if ([_webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
	{
		[_webViewDelegate webViewDidStartLoad:(id)webView];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
	/// 링크를 오래 눌렀을 때 ActionSheet 가 나타나는 현상 방지
	[webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
	//텍스트 선택방지.
	[webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
	
	if ([_webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
	{
		[_webViewDelegate webViewDidFinishLoad:(id)webView];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
	NSLog(@"didFailNavigation");
	if ([_webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
	{
		[_webViewDelegate webView:(id)webView didFailLoadWithError:error];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
	NSLog(@"didFailProvisionalNavigation");
	if ([_webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
	{
		[_webViewDelegate webView:(id)webView didFailLoadWithError:error];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
	// for cookie (ver.2) (ver.3)
	///*
	{
		NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
		NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:response.URL];
		for (NSHTTPCookie *cookie in cookies)
		{
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
		}
        
        // 502 or 504 일 때 오류 웹페이지 로딩하게 수정
        NSInteger status = response.statusCode;

        if (status == 502 || status == 504) {

            if (decisionHandler) decisionHandler(WKNavigationResponsePolicyCancel);
              
            NSURL * url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"error" ofType:@"html"] isDirectory:NO];
            [webView loadFileURL:url allowingReadAccessToURL:url];

            return;
        }
	}
	//*/
	
	// ???? for test
	/*
	{
		BOOL isMainFrame = navigationResponse.isForMainFrame;
		NSLog(@"\n\t %@, url = [%@]", (isMainFrame ? @"Main" : @"Sub"), navigationResponse.response.URL.absoluteString);
	}
	*/
    
    

	if (decisionHandler) decisionHandler(WKNavigationResponsePolicyAllow);
}

//- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
//{
//    // ios9 웹킷 크래시 방어코드
//    [webView reload];
//}

#if DEBUG
// 사설 인증서 웹페이지 설정으로 인한 skip
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}
#endif

@end
