//
//  HybridWebView.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 8. 9..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

//네비게이션및 웹뷰 밀어서 닫기모드		1 - 사용		0 - 사용안함
#define ScreenEdgeBackMode			0

#define IGNORE_UIWEBVIEW

#define Scheme_Action				@"liivmate"
#define Scheme_Internal				@"internal"
#define Scheme_External				@"external"
#define Scheme_Main					@"main"
#define Scheme_Back					@"back"
#define Scheme_Menu					@"menu"
#define Scheme_TablePay             @"liivmatetablepay"

@protocol WebView <NSObject>
@property (nonatomic, assign) BOOL KLUMode;
@property (nonatomic, unsafe_unretained) id _Nullable webViewDelegate;
@property (nonatomic) BOOL scalesPageToFit;
@property (nonatomic, readonly, strong) UIScrollView * _Nullable scrollView;
@property (nullable, nonatomic, readonly, strong) NSURLRequest *request;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

- (void)stringByEvaluatingJavaScriptFromString:(NSString *_Nullable)script completionHandler:(void (^ _Nullable)(NSString * _Nullable result))completionHandler;
- (void)stopLoading;
- (void)webViewLoadRequest:(NSURLRequest *_Nullable)request;
- (void)webViewGoBack;
- (void)webViewGoForward;
@optional
@property (nonatomic, assign) CGRect frame;
- (UIViewController*_Nullable)parentViewController;
//@property (nullable, nonatomic, readonly, strong) NSURLRequest *request;
@end
