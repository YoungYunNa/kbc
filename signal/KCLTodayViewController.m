//
//  TodayViewController.m
//  signal
//
//  Created by kbcard on 2018. 7. 4..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "KCLTodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "KCLCommonWidgetHeader.h"
#import "KCLServerSetting.h"
#import "NSString+Security.h"
#import "NSString+Util.h"
#import "NSDictionary+NSNull.h"
#import "AllMenu.h"

#ifdef DEBUG
#define NSLog( s, ... ) NSLog( @"[%@ %s(%d)] %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define NSLog(...)
#endif

#define bundleKey           @"com.kbcard.kat.liivmate"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface KCLTodayViewController () <NCWidgetProviding>

@property (assign, nonatomic) BOOL isRefreshing;						        // 조회중 flag

@property (weak, nonatomic) IBOutlet UIVisualEffectView *backgroundEffectView;	// iOS8,9 백그라운드 뷰

@property (weak, nonatomic) IBOutlet UILabel *signalDescLabel;			        // 소비매니저 문자 라벨

// shared info
@property (strong, nonatomic) NSString *customerNo;						        // 사용자 번호
@property (assign, nonatomic) BOOL isAutoLogin;							        // Auto Login 여부
@property (assign, nonatomic) BOOL isUserLogined;						        // 사용자 Login 여부
@property (assign, nonatomic) BOOL isBarcodePayment;					        // 간편결제 타입 (바코드, QR)
@property (strong, nonatomic) NSDictionary *httpHeaderFields;			        // 통신 HADER
@property (strong, nonatomic) NSString *serverURL;						        // 서버 URL
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic) NSString *beforePasteMessage;

// Ver. 3 위젯 변경
@property (weak, nonatomic) IBOutlet UIView *loginView;                         // 로그인 뷰
@property (weak, nonatomic) IBOutlet UIView *pointreeView;                      // 포인트리 뷰
@property (weak, nonatomic) IBOutlet UILabel *pointreeLabel;                    // 포인트리 잔액 (100,000,000P)
@property (weak, nonatomic) IBOutlet UILabel *refreshDescriptionLabel;          // 조회중...

@end


@implementation KCLTodayViewController
#pragma mark - Ui View load (기본 뷰 로드)
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	[NSString setAesBaseKey:bundleKey keySha384Hash:YES ivSet:YES];
    
    // content height 확장 가능 여부 -> 확장 안되도록
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeCompact;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// 공유 정보 조회
	[self updateSharedData];

	// 화면 업데이트 (cashed data 사용)
	[self updateUI];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

#pragma mark - Udpate UI Infomation (Widget 표시 정보 업데이트)
/**
@var updateSharedData
@brief 공유 정보 조회
*/
- (void)updateSharedData {
	// 사용자 번호
	self.customerNo = [self getCustomerNo];
	// Auto Login 여부
	self.isAutoLogin = [self getIsAutoLogin];
	// 사용자 Login 여부
	self.isUserLogined = [self getIsUserLogined];
	// 간편결제 타입 (바코드, QR)
	self.isBarcodePayment = [self getIsBarcodePayment];
	// 통신 HADER
	self.httpHeaderFields = [self getHTTPHeaderFields];
	// 서버 URL
	self.serverURL = [self getServerURL];
}

/**
@var hasCustomerNo
@brief 로그인 한번이라도 하면 세팅됨
@return 로그인 세팅 (YSE : 로그인 세팅, NO : 로그인 미 세팅)
*/
- (BOOL)hasCustomerNo {
	// 로그인 한번이라도 하면 세팅됨
	return (self.customerNo.length > 0);
}

/**
@var updateUI
@brief 위젯 화면 업데이트
*/
- (void)updateUI {
	// 화면 업데이트 (cashed data 사용)
	BOOL isExpanded = NO;

    if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeExpanded) isExpanded = YES;

    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    NSString *widgetAppTerminate = [userDefault objectForKey:WIDGET_APP_TERMINATE];
    
    // 앱기동중, 로그인 되어 있을 때
	if ([widgetAppTerminate isEqualToString:@"N"] == YES && [self hasCustomerNo] && self.isUserLogined )
	{
        [self viewPointree];
    }
    // 앱 비기동중, autologin 설정시
    else if ([widgetAppTerminate isEqualToString:@"Y"] == YES && self.isAutoLogin ){
        [self viewPointree];
    }
    // 로그인 되어 있지 않을 때
    else
	{
        [self viewLoginArea];
	}
}

/**
@var viewPointree
@brief 위젯 포인트리 화면 설정
*/
- (void)viewPointree {
    self.loginView.hidden = YES;    // 로그인 뷰 숨김
    self.pointreeView.hidden = NO;  // 포인트리 뷰 보임
    
    if (self.isRefreshing)          // 리플레쉬 중
    {
        self.pointreeLabel.hidden = YES;
        self.refreshDescriptionLabel.hidden = NO;
    }
    else
    {
        self.pointreeLabel.hidden = NO;
        self.refreshDescriptionLabel.hidden = YES;
        
        // 포인트리 표시
        self.pointreeLabel.text = [NSString stringWithFormat:@"%@P", [[self getPointree] formatNumber]];
    }
}

/**
@var viewLoginArea
@brief 위젯 로그인 화면 설정
*/
- (void)viewLoginArea {
    self.loginView.hidden = NO; // 로그인 뷰 나옴
    self.pointreeLabel.hidden = YES; // 포인트리 슘김
    self.refreshDescriptionLabel.hidden = YES; // 재조회 라벨 숨김
    self.pointreeView.hidden = YES; // 포인트리 뷰 숨김
}

/**
@var widgetPerformUpdateWithCompletionHandler
@brief data 업데이트  업데이트 후 화면 업데이트 완료
*/
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
	// If implemented, the system will call at opportune times for the widget to update its state, both when the Notification Center is visible as well as in the background.
	// An implementation is required to enable background updates.
	// It's expected that the widget will perform the work to update asynchronously and off the main thread as much as possible.
	// Widgets should call the argument block when the work is complete, passing the appropriate 'NCUpdateResult'.
	// Widgets should NOT block returning from 'viewWillAppear:' on the results of this operation.
	// Instead, widgets should load cached state in 'viewWillAppear:' in order to match the state of the view from the last 'viewWillDisappear:', then transition smoothly to the new data when it arrives.
	
	// Perform any setup necessary in order to update the view.
	
	// If an error is encountered, use NCUpdateResultFailed
	// If there's no update required, use NCUpdateResultNoData
	// If there's an update, use NCUpdateResultNewData
	
	// data 업데이트 -> 화면 업데이트 -> completionHandler 호출
    // 공유 정보 조회
    [self updateSharedData];
		
    // data 업데이트 안함
    [self updateUI];
    completionHandler(NCUpdateResultNewData);
}

/**
@var widgetActiveDisplayModeDidChange
@brief 위젯 레이아웃 확장
@param activeDisplayMode (NCWidgetDisplayModeExpanded : 확장모드)
*/
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize API_AVAILABLE(ios(10.0)) {
	// If implemented, called when the active display mode changes.
	// The widget may wish to change its preferredContentSize to better accommodate the new display mode.
	
	if (activeDisplayMode == NCWidgetDisplayModeExpanded) {
		// 확장 content height
		CGSize newSize = maxSize;
		newSize.height = 300;
		self.preferredContentSize = newSize;
	}
	else {
		self.preferredContentSize = maxSize;
	}
}

#pragma mark - Widget Data Set/get
/**
@var setPointree
@brief 포인트리 저장
@param 위젯 포인트리
*/
- (void)setPointree:(NSString *)string {
    if (string.length == 0) {
        string = @"0";
    }
	
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	[userDefault setObject:string forKey:WIDGET_POINTREE];
	[userDefault synchronize];
}

/**
@var getPointree
@brief 포인트리 조회
@return 위젯 포인트리
*/
- (NSString *)getPointree {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSString *pointree = [userDefault objectForKey:WIDGET_POINTREE];
	
	pointree = pointree.length > 0 ? pointree : @"0";
	return pointree;
}

/**
@var getCustomerNo
@brief 사용자 번호 조회
@return 사용자 번호
*/
- (NSString *)getCustomerNo {
	NSString *ret = nil;
	
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSString *custNo = [userDefault objectForKey:WIDGET_CUST_NO];
	if (custNo != nil) {
		NSString *encryptedStr = custNo;
		if ([encryptedStr respondsToSelector:@selector(decryptAes128)]) {
			ret = [encryptedStr decryptAes128];
		}
	}
	
	return ret;
}

/**
@var getIsAutoLogin
@brief Auto Login 여부 조회
@return 오토로그인 유/무
*/
- (BOOL)getIsAutoLogin {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSString *autoLogin = [userDefault objectForKey:WIDGET_AUTO_LOGIN];
	BOOL ret = [autoLogin isEqualToString:@"Y"];
	return ret;
}

/**
@var getIsUserLogined
@brief 사용자 Login 여부 조회
@return 사용자 로그인 유/무
*/
- (BOOL)getIsUserLogined {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSString *userLogined = [userDefault objectForKey:WIDGET_USER_LOGINED];
	BOOL ret = [userLogined isEqualToString:@"Y"];
	return ret;
}

/**
@var getIsBarcodePayment
@brief 간편결제 방법 조회
@return 바코드 결제 유/무
*/
- (BOOL)getIsBarcodePayment {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSString *paymentType = [userDefault objectForKey:WIDGET_PAYMENT_TYPE];
	
	BOOL ret = ![paymentType isEqualToString:@"QR"];
	return ret;
}

/**
@var getHTTPHeaderFields
@brief 통신 HADER 조회
@return 통신 헤더 정보 (NSDictionary : ""WIDGET_HEADER"": "APP_GROUP_ID" )
*/
- (NSDictionary *)getHTTPHeaderFields {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSDictionary *headerInfo = [userDefault objectForKey:WIDGET_HEADER];
	return headerInfo;
}

/**
@var getServerURL
@brief 서버 URL 조회
@return 서버 url
*/
- (NSString *)getServerURL {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSString *serverURL = [userDefault objectForKey:WIDGET_SERVER_URL];
	return serverURL;
}

/**
@var setBeforePasteMessage
@brief 함수 기능요약
@param 파라미터로 들어오는 객체에 대한 설명
@return 리턴되는 객체에 대한 설명
*/
-(void)setBeforePasteMessage:(NSString *)beforePasteMessage {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	if(beforePasteMessage.length)
		[userDefault setValue:beforePasteMessage forKey:FAIL_MESSAGE];
	else
		[userDefault removeObjectForKey:FAIL_MESSAGE];
	[userDefault synchronize];
}

/**
@var 함수명
@brief 함수 기능요약
@param 파라미터로 들어오는 객체에 대한 설명
@return 리턴되는 객체에 대한 설명
*/
-(NSString*)beforePasteMessage {
	NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
	NSString *beforeMessage = [userDefault objectForKey:FAIL_MESSAGE];
	return beforeMessage;
}

#pragma mark - Button Click Action (버튼 액션)
/**
@var pointreeRefreshButtonClicked
@brief 포인트리 재조회 버튼
*/
- (IBAction)pointreeRefreshButtonClicked:(id)sender {
	// 화면 update
	self.isRefreshing = YES;
	[self updateUI];
	
	// data update
	[self updateData:^(BOOL success) {
		
		// 화면 update
		self.isRefreshing = NO;
		[self updateUI];
	}];
}

/**
@var loginButtonClicked
@brief 로그인 버튼
@param 파라미터로 들어오는 객체에 대한 설명
@return 리턴되는 객체에 대한 설명
*/
- (IBAction)loginButtonClicked:(id)sender {
    // 로그인 위젯 key 추가
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    [userDefault setObject:@"Y" forKey:WIDGET_LOGIN];
    
	[self.extensionContext openURL:[NSURL URLWithString:[NSString stringWithFormat:@"liivmate://call?cmd=move_to&id=%@",MenuID_Login]] completionHandler:nil];
}

/**
@var paymentButtonClicked
@brief 간편결제 버튼 (바코드 결제만 지원)
*/
- (IBAction)paymentButtonClicked:(id)sender {
    [self.extensionContext openURL:[NSURL URLWithString:[NSString stringWithFormat:@"liivmate://call?cmd=move_to&id=%@",MenuID_SimplePayment]] completionHandler:nil];
}

/**
@var moneyButtonClicked
@brief 통합조회 버튼
*/
- (IBAction)moneyButtonClicked:(id)sender {
    [self.extensionContext openURL:[NSURL URLWithString:[NSString stringWithFormat:@"liivmate://call?cmd=move_to&id=%@",MenuID_V4_MainPage]] completionHandler:nil];
}

/**
@var updateData
@brief Data 업데이트
*/
- (void)updateData:(void (^)(BOOL success))completionHandler {
	// Data 업데이트
	
	NSLog(@"updateData");
	
	if (self.customerNo && self.serverURL) {
        // ver.3 위젯 포인트리 조회(세션 없음) (KATPH01)
        // 서버 전송
        [self sendToServerWithrequestID:@"KATPH01"
                                   body:@{@"custNo":self.customerNo}
                      completionHandler:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                          
                          // 성공
                          if ([@"0000" isEqualToString:rsltCode]) {
                              // 포인트리 저장
                              NSString *pointree = [result null_objectForKey:@"searchPoint"];
                              
                              [self setPointree:pointree];
                              if (completionHandler) {
                                  completionHandler(YES);
                              }
                          }
                          // 실패
                          else {
                              if (completionHandler) {
                                  completionHandler(NO);
                              }
                          }
                      }];
	}
	else {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(NO);
            }
		});
	}
}

/**
@var sendToServerWithrequestID
@brief 서버 통신(포인트리 재조회)
@param requestID(KATPH01), body (customerNo)
*/
- (void)sendToServerWithrequestID:(NSString*)requestID
							 body:(NSDictionary*)body
				completionHandler:(void (^)(NSDictionary *result, NSString *rsltCode, NSString *message))completionHandler {
	NSMutableURLRequest *request = [self makeRequestWithrequestID:requestID body:body];
	if (request == nil) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			if (completionHandler) completionHandler(nil, nil, @"Request 생성 실패!");
		});
		return;
	}

	// ???? for test
	///*
	{
		NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
		[userDefault setObject:[NSString stringWithFormat:@"\n\turl = %@ reqBody = %@ \nHeaders = %@", request.URL.absoluteString, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], request.allHTTPHeaderFields] forKey:@"POINTREE_REQUEST_"];
		[userDefault synchronize];
	}
	//*/
	
	NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request
																  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (data) {
				// ???? for test
				///*
				{
					NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
					[userDefault setObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:@"POINTREE_RESPONSE_"];
					[userDefault synchronize];
				}
				//*/

				NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data
																		  options:NSJSONReadingMutableContainers
																			error:NULL];
				
				if (resultDic) {
					NSLog(@"\n[SERVER RESPONSE] SUCCESS : %@", resultDic.jsonStringPrint);
					
					NSDictionary *header = [resultDic null_objectForKey:@"header"];
					
					// ???? 어떻게 하지
					//[PentaPinViewController setTimeStamp:[[header null_objectForKey:@"timestamp"] doubleValue]];
					
					NSString *rsltCode = [header null_objectForKey:@"rsltCode"];
					rsltCode = rsltCode == nil ? @"9999" : rsltCode;
					
					NSString *message = [[header null_objectForKey:@"message"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
					
					NSDictionary *body = [resultDic null_objectForKey:@"body"];
					body = ([body isEqual:[NSNull null]] || nil) ? @{} : body;

					if (completionHandler) completionHandler(body, rsltCode, message);
				}
				else {
					NSLog(@"\n[SERVER RESPONSE] FAIL : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

					if (completionHandler) completionHandler(nil, nil, @"Response Parsing Error");
				}
			}
			else {
				NSLog(@"\n[SERVER RESPONSE] ERROR : %@", error.localizedDescription);
				
				// ???? for test
				///*
				{
					NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
					[userDefault setObject:error.localizedDescription forKey:@"POINTREE_RESPONSE_"];
					[userDefault synchronize];
				}
				//*/
				
                if (completionHandler) {
                    completionHandler(nil, nil, error.localizedDescription);
                }
			}
		});
	}];
	[task resume];
}

/**
@var makeRequestWithrequestID
@brief request 를 위한 헤더 필드 및 바디를 만듬
@param requestID(거래코드),body(고객번호)
@return request 값
*/
- (NSMutableURLRequest *)makeRequestWithrequestID:(NSString*)requestID
											 body:(NSDictionary*)body {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	request.timeoutInterval = 30;
	request.HTTPMethod = @"POST";
	
	request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.do", self.serverURL, requestID]];
	
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
													   options:NSJSONWritingPrettyPrinted
														 error:&error];
	request.HTTPBody = jsonData;

	NSDictionary *savedHeaderFields = self.httpHeaderFields;
	for (NSString *key in savedHeaderFields.allKeys) {
		[request setValue:savedHeaderFields[key] forHTTPHeaderField:key];
	}
	// ???? TODO : 바꿔야 하나 - lts
	[request setValue:requestID forHTTPHeaderField:@"trxCd"];
	[request setValue:[NSString stringWithFormat:@"%d", ((int)[jsonData length])] forHTTPHeaderField:@"Content-Length"];

	// ???? TODO : 넣어야 하나 - cookie
	/*
	{
		NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL]];
		for (NSString *key in headers.allKeys)
		{
			[request setValue:headers[key] forHTTPHeaderField:key];
		}
	}
	*/

	NSLog(@"[REQUEST HEADER] : \n%@", [request allHTTPHeaderFields]);

	return request;
}

@end
