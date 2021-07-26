//
//  WebViewController.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 21..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "ViewController.h"
#import "HybridWebView.h"
#import "HybridWKWebView.h"
#import "KCLCustomNavigationBarView.h"

typedef NS_ENUM(NSUInteger, PreType) {
    PreTypeClose = 0,
    PreTypeGoBack,
    PreTypeTargetUrl,
    PreTypeTargetFunction,
};


@interface WVRequest : NSMutableURLRequest
- (void)setbody:(NSDictionary *)dict isPassEncoding:(BOOL)isPassEncoding isEnc:(BOOL)isEnc;
- (NSString *)getEncParam:(NSDictionary *)dict;
@end


@interface WebViewController : ViewController
@property (nonatomic, readonly) id<WebView> webView;
@property (nonatomic, strong) NSDictionary *topMenu;
@property (nonatomic, strong) NSString *firstOpenUrl;
@property (nonatomic, strong) NSString *internalNavigationTitleString;
@property (nonatomic, assign) BOOL indicator;
@property (nonatomic, strong) NSString *defultTitle;
@property (nonatomic, assign) BOOL showToolBar;
@property (nonatomic, assign) BOOL passEncoding;
@property (nonatomic, assign) BOOL enabledWKWebMode; //defult = YES;
@property (nonatomic, strong) WVRequest *baseUrlRequest;
@property (nonatomic, strong) NSMutableArray *historyStack;    // back history 관리 (hybrid interface 'addHistoryStack' 으로 넘어온 url 관리 스택
@property (nonatomic, strong) KCLCustomNavigationBarView *customNavigationBar;
@property (nonatomic, assign) PreType preType;
@property (nonatomic, assign) BOOL bUseCustomInputAccessoryView;

- (BOOL)webView:(id<WebView>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType;
- (void)webViewDidStartLoad:(id<WebView>)webView;
- (void)webViewDidFinishLoad:(id<WebView>)webView;
- (void)webView:(id<WebView>)webView didFailLoadWithError:(NSError *)error;
- (void)successCertified:(NSDictionary*)param;
- (void)setBaseUrlRequest:(WVRequest *)baseUrlRequest;
- (void)goBasePage;
- (BOOL)canGoBack;
- (void)addHistoryStack:(NSDictionary *)urlInfo;
- (void)removeHistoryStack:(NSInteger)cnt;
- (void)clearHistoryStack;
- (void)webPageInit;

- (void)backButtonAction:(UIButton*)sender;
- (void)loadPage:(NSString *)url method:(NSString *)method params:(NSDictionary *)params trxCd:(NSString *)trxCd isEnc:(BOOL)isEnc;
+ (void)sendGa360:(NSDictionary*)infoDic;
+ (void)sendGa360Native:(BOOL)isEvent p1:(NSString *)p1 p2:(NSString *)p2 p3:(NSString *)p3  campainUrl:(NSString *)url;
@end

//프로젝트의 일반적인 웹화면을 보여줄때 사용하는 class (상속된 Class간 비교를 위하여)
@interface HybridViewController : WebViewController
@end



