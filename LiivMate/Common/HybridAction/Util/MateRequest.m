//
//  Request.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 20..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "MateRequest.h"
#import "KCLCommonWidgetHeader.h"
#import "MobileWeb+NetFunnel.h"

#define KEEP_ALIVE_TIMEOUT 300

// 통신시 메세지 처리관련 define
typedef NS_ENUM(NSUInteger, responseMsgCBOrderType) {
    responseMsgCBOrderTypePrev = 1,     // callback를 alert 전에 처리
    responseMsgCBOrderTypeNext = 2,     // callback를 alert 확인버튼 클릭후 처리
    responseMsgCBOrderTypeNoExcute = 9, // callback를 처리하지 않음
};

typedef NS_ENUM(NSUInteger, responseMsgAlertType) {
    responseMsgAlertTypeAlert = 1,
    responseMsgAlertTypeConfirm,
};

@interface MateRequest ()
{
	RequestFinish _callBack;
	NSMutableDictionary *_sendParam;
	BOOL _runLoop;
}
@end

@implementation MateRequest

static NSMutableArray *showLoadingRequests = nil;
static NSMutableArray *noneLoadingRequests = nil;
static NSString* uaProfile = nil;
static Request *keepAliveRq = nil;

+(void)requestID:(NSString*)requestID
			body:(NSDictionary*)body
		pinKeyNm:(NSString*)keyNm
	 showLoading:(BOOL)show cancelOwn:(id)own
		finished:(RequestFinish)finished
{
    [self requestID:requestID
               body:body
           pinKeyNm:keyNm
            setting:^(id vc) {
                [PwdWrapper setTitle:vc value:@"비밀번호"];
                [PwdWrapper setSubTitle:vc value:@"6자리를 입력해 주세요."];
                [PwdWrapper setShowPwdResetBtn:vc value:YES];
            }
        showLoading:show
          cancelOwn:own
           finished:finished];
}

+(void)requestID:(NSString*)requestID
            body:(NSDictionary*)body
        pinKeyNm:(NSString*)keyNm
         setting:(PwdWrapperSetting)settingCallBack
     showLoading:(BOOL)show cancelOwn:(id)own
        finished:(RequestFinish)finished
{
    if(keyNm)
    {
        [PwdWrapper showPwd:settingCallBack
                     target:requestID
                   callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
                       if(isCancel == NO)
                       {
                           NSMutableDictionary *sendBody = [NSMutableDictionary dictionary];
                           if(body)
                               [sendBody addEntriesFromDictionary:body];
                           
                           //블럭체인을 사용할경우
                           [sendBody addEntriesFromDictionary:[PwdWrapper blockChainWithKeyNm:vc keyNm:keyNm]];
                           
                           [self requestID:requestID
                                   message:nil
                                      body:sendBody
                             waitUntilDone:NO
                               showLoading:show cancelOwn:own finished:finished];
                       }
                   }];
    }
    else
    {
        [self requestID:requestID
                message:nil
                   body:body
          waitUntilDone:NO
            showLoading:show cancelOwn:own finished:finished];
    }
}

+(void)requestID:(NSString*)requestID
			body:(NSDictionary*)body
   waitUntilDone:(BOOL)wait
	 showLoading:(BOOL)show
	   cancelOwn:(id)own
		finished:(RequestFinish)finished
{
	[self requestID:requestID
			message:nil
			   body:body
	  waitUntilDone:wait
		showLoading:show cancelOwn:own finished:finished];
}

#ifdef Single_Task_Mode
static NSMutableArray *waitingRequests = nil;
static BOOL singleRunTask = NO;
#endif

+(void)requestID:(NSString*)requestID
		 message:(NSString *)message
			body:(NSDictionary*)body
   waitUntilDone:(BOOL)wait showLoading:(BOOL)show cancelOwn:(id)own
		finished:(RequestFinish)finished
{
    
    BOOL isEnc = [[AppInfo sharedInfo].encUrlData null_valueForKey:requestID]? YES : NO;
    NSString * trxCd =  !nilCheck([[AppInfo sharedInfo].encUrlData null_valueForKey:requestID][@"trxCd"]) ? [[AppInfo sharedInfo].encUrlData null_valueForKey:requestID][@"trxCd"] : nil;
    
    [self requestID:requestID
            message:message
               body:body
      waitUntilDone:wait
        showLoading:show
          cancelOwn:own
       isJsCallback:NO
              isEnc:isEnc
              trxCd:trxCd
           finished:finished];
}

+(void)requestID:(NSString*)requestID
         message:(NSString *)message
            body:(NSDictionary*)body
   waitUntilDone:(BOOL)wait showLoading:(BOOL)show cancelOwn:(id)own
    isJsCallback:(BOOL)isJsCallback
           isEnc:(BOOL)isEnc
           trxCd:(NSString *)trxCd
        finished:(RequestFinish)finished
{
    if(requestID == nil) finished(nil,nil,nil);
    Request *rq = [[Request alloc] init];
    rq.isEnc = isEnc;
    rq.message = message;
    rq.isJsCallback = isJsCallback;
    rq.trxCd = trxCd;
    rq.requestID = requestID;
    rq.param = body;
    rq.wait = wait;
    rq.showLoading = show;
    rq.own = own;

    [rq setCallback:finished];
#ifdef Single_Task_Mode
    if(singleRunTask && wait == NO)
    {
        if(waitingRequests == nil)
            waitingRequests = [[NSMutableArray alloc] init];
        [waitingRequests addObject:rq];
        return;
    }
    singleRunTask = YES;
#endif
    
    //유량제어 체크
    [CheckNetFunnel checkNetFunnelActionID:requestID params:body callback:^(NSDictionary *result, BOOL success) {
        if(success)
        {
            [rq send];
        }
        else
        {
            finished(result,ERRCODE_NETFUNNEL_BLOCK,nil);
            [rq remove];
        }
    }];
}

+(void)requestServer:(NSString*)serverUrl
         message:(NSString *)message
            body:(NSDictionary*)body
   waitUntilDone:(BOOL)wait showLoading:(BOOL)show cancelOwn:(id)own
    isJsCallback:(BOOL)isJsCallback
           isEnc:(BOOL)isEnc
           trxCd:(NSString *)trxCd
        finished:(RequestFinish)finished
{
    if(serverUrl == nil) finished(nil,nil,nil);
    Request *rq = [[Request alloc] init];
    rq.isEnc = isEnc;
    rq.message = message;
    rq.isJsCallback = isJsCallback;
    rq.trxCd = trxCd;
    rq.requestServer = serverUrl;
    rq.param = body;
    rq.wait = wait;
    rq.showLoading = show;
    rq.own = own;

    [rq setCallback:finished];
#ifdef Single_Task_Mode
    if(singleRunTask && wait == NO)  {
        if(waitingRequests == nil)
            waitingRequests = [[NSMutableArray alloc] init];
        [waitingRequests addObject:rq];
        return;
    }
    singleRunTask = YES;
#endif
    
    [rq send];
    
    //유량제어 체크
//    [CheckNetFunnel checkNetFunnelActionID:requestID params:body callback:^(NSDictionary *result, BOOL success) {
//        if(success)
//        {
//            [rq send];
//        }
//        else
//        {
//            finished(result,ERRCODE_NETFUNNEL_BLOCK,nil);
//            [rq remove];
//        }
//    }];
}

static BOOL sendKeepAlive = NO;

+(BOOL)isSendKeepAlive {
	return sendKeepAlive;
}

+(void)sendKeepAlive:(void (^)(void))callback {
	[self sendKeepAlive:YES callback:callback];
}

+(void)sendKeepAlive:(BOOL)showLaunchImage callback:(void (^)(void))callback {
	NSLog(@"sendKeepAlive");
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendKeepAlive:) object:nil];
	scanJailBreak();
    if([AppInfo sharedInfo].isLogin) {
		if(keepAliveRq == nil) {
			keepAliveRq = [[Request alloc] init];
            keepAliveRq.requestID = KATA014;
		}
		[keepAliveRq cancel];
		keepAliveRq.param = @{@"custNo":([AppInfo sharedInfo].isLogin ? [AppInfo userInfo].custNo : @"")};
        
		if(callback) {
			sendKeepAlive = YES;
			keepAliveRq.showLoading = YES;
			keepAliveRq.message = showLaunchImage ? @"showLaunchImage" : nil;
			[keepAliveRq setCallback:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
				sendKeepAlive = NO;
				callback();
			}];
			[keepAliveRq send];
		}
		else {
			keepAliveRq.showLoading = NO;
			keepAliveRq.message = nil;
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:keepAliveRq.param
															   options:NSJSONWritingPrettyPrinted
																 error:nil];
			[keepAliveRq setValue:[NSString stringWithFormat:@"%.0f",[PwdWrapper timeStamp]] forHTTPHeaderField:@"lts"];
			[keepAliveRq setValue:[NSString stringWithFormat:@"%d", ((int)[jsonData length])] forHTTPHeaderField:@"Content-Length"];
			[keepAliveRq setHTTPBody:jsonData];
			[keepAliveRq sendDataTask:^(NSData *data, NSURLResponse *response, NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if(keepAliveRq)
					{
						[keepAliveRq remove];
					}
				});
			}];
		}
    } else {
        if(callback) {
            callback();
        }
    }
	[self performSelector:@selector(sendKeepAlive:) withObject:nil afterDelay:KEEP_ALIVE_TIMEOUT];
}


+(void)stopKeepAlive {
	NSLog(@"stopKeepAlive");
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendKeepAlive:) object:nil];
	[keepAliveRq cancel];
	keepAliveRq = nil;
}

-(id)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
	self = [super initWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
	if(self) {
		[self initSetting];
	}
	return self;
}

-(id)init {
	self = [super init];
	if(self) {
		[self initSetting];
		self.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
		self.timeoutInterval = TimeoutInterval;
	}
	return self;
}

+(NSDictionary*)httpHeader {
	NSMutableDictionary *header = [NSMutableDictionary dictionary];
	if(uaProfile == nil) {
		NSString *appNm = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
        NSString *appVer = [AppInfo sharedInfo].appVer;
        NSString *osVer = [AppInfo sharedInfo].osVer;
        NSString *devModel = [AppInfo sharedInfo].platform;
		//LiivMate_I/1;
		uaProfile = [NSString stringWithFormat:@"%@_I/%@|AppVer=%@|OsVer=%@|OS=I|DeviModel=%@", appNm, User_Agent_Ver, appVer, osVer, devModel];
        
        if ([AppInfo sharedInfo].setEfdsDataYn.boolValue) {
            uaProfile = [uaProfile stringByAppendingFormat:@"|efds=%@;" ,[EtcUtil efdsDeviceInfo]];
        } else {
            uaProfile = [uaProfile stringByAppendingString:@";"];
        }
	}
	[header setValue:uaProfile forKey:@"User-Agent"];
	NSString *appId = [UserDefaults sharedDefaults].appID;
    if(appId.length != 0) {
		[header setValue:appId forKey:@"appId"];
    }
    
    if([AppInfo sharedInfo].pureAppToken.length) {
		[header setValue:[AppInfo sharedInfo].pureAppToken forKey:@"token"];
    }
	
	[header setValue:[AppInfo sharedInfo].platform forKey:@"modelNm"];
    [header setValue:[AppInfo sharedInfo].osVer forKey:@"OsVer"];
    [header setValue:[AppInfo sharedInfo].appVer forKey:@"appVer"];
	
	long lJBFlag = scanJailBreakValueToServer();
	NSLog(@"\n=============>>> lJDFlag as jbValue == [%ld]", lJBFlag);
	[header setValue:[NSString stringWithFormat:@"%ld", lJBFlag] forKey:@"jbValue"];
	
	//단말정보 : IP - 아이폰
	[header setValue:@"IP" forKey:@"chnlCd"];
	[header setValue:[NSString stringWithFormat:@"%.0f",[PwdWrapper timeStamp]] forKey:@"lts"];
    
    NSString *uuidString4 = [[NSUUID UUID].UUIDString substringToIndex:4];
    NSString *uuidString6 = [[NSUUID UUID].UUIDString substringToIndex:6];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateTimeString = [format stringFromDate:[NSDate date]];
    
    //헤더추가20200313.
    NSString *guidKeyValue = [NSString stringWithFormat:@"KC0UAAAPS%@%@%@000",uuidString4,dateTimeString,uuidString6];
    [header setValue:guidKeyValue forKey:@"guid"];
      
	return header;
}

-(void)initSetting {
	_sendParam = [[NSMutableDictionary alloc] init];
	
	[self setAllHTTPHeaderFields:[[self class] httpHeader]];
	[self setHTTPMethod:@"POST"];
	[self setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self setValue:@"application/json" forHTTPHeaderField:@"Accept"];
}

-(void)dealloc {
	_param = nil;
	_sendParam = nil;
	_callBack = nil;
	_own = nil;
	_requestID = nil;
	_message = nil;
}

#pragma mark  - 전문 send
-(void)setCallback:(RequestFinish)callBack {
	_callBack = nil;
	_callBack = callBack;
}

-(void)setOwn:(id)own {
	_own = own;
}

-(void)setRequestServer:(NSString *)requestServerUrl {
    _requestServer = requestServerUrl;
    
    // 하이브리드엑션 콜일경우 해더셋팅
    if(_isJsCallback) {
        [self setValue:@"XMLHttpRequest" forHTTPHeaderField:@"x-requested-with"];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",_requestServer];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    self.URL = url;
}
    
-(void)setRequestID:(NSString *)requestID {
	_requestID = requestID;
    
	[self setValue:[_requestID stringByReplacingOccurrencesOfString:NONE_SESSION withString:@""] forHTTPHeaderField:@"trxCd"];
    
    // 앱아이디는 모든 리퀘스트에 다 암호화
    if([UserDefaults sharedDefaults].appID.length > 0) {
        NSString * encAppid = [PwdWrapper encryptedDictionary:@{@"encStr" : [UserDefaults sharedDefaults].appID}];
        [self setValue:encAppid forHTTPHeaderField:@"appId"];
    }
    
    //trxCd가 있는 경우는 받아온 파라메타 값으로 셋팅해야함!!!
    if (!nilCheck(_trxCd)) {
        [self setValue:_trxCd forHTTPHeaderField:@"trxCd"];
    }
    
    // 하이브리드엑션 콜일경우 해더셋팅
    if(_isJsCallback) {
        [self setValue:@"XMLHttpRequest" forHTTPHeaderField:@"x-requested-with"];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@.do",SERVER_URL,_requestID];
    if([_requestID containsString:@""]) {
        urlStr = _requestID;
    }
    
	NSURL *url = [NSURL URLWithString:urlStr];
	self.URL = url;
}

-(BOOL)send {
	if(self.URL == nil) return NO;
	
	NSMutableDictionary *sendDic = [NSMutableDictionary dictionaryWithDictionary:_sendParam];
	[sendDic addEntriesFromDictionary:_param];
    
    // 앱기동데이타에 url정보가 있으면 해더 암호화
    if (_isEnc) {
        NSMutableDictionary * encodeDic = [sendDic mutableCopy];
        
        for (NSString * key in sendDic) {
    
            NSString * value = sendDic[key];
            [encodeDic setObject:value.stringByUrlEncoding forKey:key];
        }
        NSLog(@"encodeDic : %@", encodeDic);
        
        NSString *encParam = [PwdWrapper encryptedDictionary:encodeDic] ? [PwdWrapper encryptedDictionary:encodeDic] : @"";
        sendDic = [NSMutableDictionary dictionaryWithDictionary:@{@"params" : encParam}];
    }

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDic
													   options:NSJSONWritingPrettyPrinted
														 error:&error];
	[self setValue:[NSString stringWithFormat:@"%.0f",[PwdWrapper timeStamp]] forHTTPHeaderField:@"lts"];
	[self setValue:[NSString stringWithFormat:@"%d", ((int)[jsonData length])] forHTTPHeaderField:@"Content-Length"];
	[self setHTTPBody:jsonData];
	
	[self sendDataTask:^(NSData *data, NSURLResponse *response, NSError *error) {
		
        self->_responseStatusCode = ((NSHTTPURLResponse *)response).statusCode;
		//NSLog(@"\n[RESPONSE URL] : %@, \n[RESPONSE HEADER] : %@", response.URL.absoluteString, ((NSHTTPURLResponse *)response).allHeaderFields);
        if(data) {
			[self performSelectorOnMainThread:@selector(requestFinished:) withObject:data waitUntilDone:NO];
        }
        else {
			[self performSelectorOnMainThread:@selector(requestFail:) withObject:error waitUntilDone:NO];
        }
	}];
	return YES;
}

-(void)sendDataTask:(CompletionHandler)completionHandler {
	TXLog(@"\nSend = %@\nHeader = %@\nBody = %@",self.URL,self.allHTTPHeaderFields,[[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding]);
	[self performSelectorOnMainThread:@selector(regist) withObject:nil waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(sendData:)
						   withObject:completionHandler waitUntilDone:_wait];
}

-(void)sendData:(CompletionHandler)completionHandler {
	@autoreleasepool {
        
		NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:self completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			
			// for wkwebview cookie
			{
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
				NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields forURL:httpResponse.URL];
                NSLog(@"httpResponse : %@",httpResponse);
				if (cookies.count > 0) {
					NSLog(@"\[NSCOOKIE -> WKCOOKIE] (1) - RESPONSE 쿠키 받음 %@", cookies);
					[[NSNotificationCenter defaultCenter] postNotificationName:MateRequestCookieNotification object:nil userInfo:@{@"cookies":cookies}];
				}

				//for (NSHTTPCookie *cookie in cookies)
				//{
				//	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
				//}
			}

			completionHandler(data,response,error);
		}];
		[task resume];
		
		if(_wait) {
			_runLoop = _wait;
			while(_runLoop) {
				[[NSRunLoop currentRunLoop] acceptInputForMode:NSDefaultRunLoopMode beforeDate:[[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode]];
			}
		}
	}
}

-(void)requestFail:(NSError*)error {
	TXLog(@"%@",error);
    
	NSString *errMsg = error.localizedDescription;
    if(error.code == -2102 || error.code == kCFURLErrorTimedOut) {
		errMsg = Req_Timeout_Msg;
    }
    
    if(errMsg.length == 0 || error.code == kCFURLErrorNotConnectedToInternet) {
		errMsg = Net_Err_Msg;
    }
#if 0//def DEBUG
	if(error.code == -2102 || error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorNotConnectedToInternet) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.numberOfLines = 0;
		label.text = error.description;
		label.font = FONTSIZE(12);
		[BlockAlertView showBlockAlertWithTitle:@"디버그 통신에러" message:label dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            if(alertView.cancelButtonIndex != buttonIndex) {
				[self send];
            }
			else {
                if(self->_callBack) {
					self->_callBack(nil,nil,errMsg);
                }
                
				[self remove];
			}
		} cancelButtonTitle:@"취소" buttonTitles:@"재시도", nil];
	}
	else {
        if(self->_callBack) {
			self->_callBack(nil,nil,errMsg);
        }
        
		[self remove];
	}
#else
    if(_callBack) {
		_callBack(nil,nil,errMsg);
    }
    
	[self remove];
#endif
}

-(void)requestFinished:(NSData*)result {
    
	NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:result
															  options:NSJSONReadingMutableContainers
																error:NULL];
    
	NSDictionary* header = [resultDic null_objectForKey:@"header"];
	NSDictionary* body = [resultDic null_objectForKey:@"body"];
	
	[PwdWrapper setTimeStamp:[[header null_objectForKey:@"timestamp"] doubleValue]];
	NSString *rsltCode = [header null_objectForKey:@"rsltCode"];
	rsltCode = rsltCode == nil ? @"9999" : rsltCode;
	NSString *message = [[header null_objectForKey:@"message"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
	
    NSString *logStr = [NSString stringWithFormat:@"\n%@\nresultDic = %@",self.URL, resultDic ? resultDic.jsonStringPrint : [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]];
    NSLog(@"%@",logStr);
	
    if([rsltCode isEqualToString:@"200"]) {
        rsltCode = @"";
    }
    
	if([ERRCODE_AppExitErr rangeOfString:rsltCode].location != NSNotFound) {//앱종료 에러코드
		[BlockAlertView dismissAllAlertViews];
		[Request cancelRequestAll];
		[BlockAlertView showBlockAlertWithTitle:[rsltCode isEqualToString:ERRCODE_AppExitNotic] ? @"Liiv Mate 긴급공지" : @"알림"
										message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
											exit(0);
										} cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
	}
	else if([ERRCODE_UserCertiErr rangeOfString:rsltCode].location != NSNotFound) {//사용자가 재인증을 해야만하는경우 에러
		[[AppInfo sharedInfo] logoutReset];
		[AppInfo sharedInfo].isJoin = NO;
		[BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            // Ver. 3 회원가입(MYD_JO0100)
            [[AllMenu delegate] navigationWithMenuID:MenuID_V3_MateJoin
                                                animated:YES
                                                  option:NavigationOptionPush
                                                callBack:nil];

		} cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
	}
	else if([ERRCODE_PinMaxErr rangeOfString:rsltCode].location != NSNotFound) {//비밀번호 오류 초과시 코드...
		[AppInfo sharedInfo].pwdErrNotms = 99;
		RequestFinish savedCallBack = _callBack;
		[BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            // Ver. 3 MenuID_V3_PwdReset 코드 추가(MYD_LO0103)
            [[AllMenu delegate] navigationWithMenuID:MenuID_V3_PwdReset
                                            animated:YES
                                              option:NavigationOptionPush
                                            callBack:nil];

            if (savedCallBack) {
				savedCallBack(body, rsltCode, nil);
            }
		} cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
	}
	else if([ERRCODE_AppLogOut rangeOfString:rsltCode].location != NSNotFound
			||[ERRCODE_AppReset rangeOfString:rsltCode].location != NSNotFound) {//로그아웃 처리후 인트로(위변조)화면으로
        
		if([AppInfo sharedInfo].isLogin
		   && [ERRCODE_AppLogOut rangeOfString:rsltCode].location != NSNotFound
		   && [AppInfo sharedInfo].autoLogin) {//자동로그인 설정상태면 팝업없이 자동로그인
			[BlockAlertView dismissAllAlertViews];
			[Request cancelRequestAll];
            [HybridActionManager cancelAllAction];
		}
		else {
			[[AppInfo sharedInfo] performLogout:^(BOOL success){}];
			[BlockAlertView dismissAllAlertViews];
			[Request cancelRequestAll];
            [HybridActionManager cancelAllAction];
			[BlockAlertView blockAlertWithTitle:@"알림" message:message cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:StartLiivMateNotification object:nil];
	}
    else if([ERRCODE_AbnormalStat rangeOfString:rsltCode].location != NSNotFound) {  // 비정상 접근 종료
        [BlockAlertView dismissAllAlertViews];
        [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            ProcessesDoKill(message);
            exit(0);
        }cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
    }
	else {
		if([ERRCODE_BlockChain rangeOfString:rsltCode].location != NSNotFound) {//블럭체인 에러, 키쌍삭제
			[PwdWrapper deleteBlockChain];
        }
        
        body = [body isEqual:[NSNull null]] ? nil : body;
        NSMutableDictionary *resultValue = [NSMutableDictionary dictionary];
        if([body isKindOfClass:[NSDictionary class]] && body != nil) {
            [resultValue addEntriesFromDictionary:body];
        } else{
            NSLog(@"body설정 오류 : %@",body);
        }
		
        [self commonMessageProcess:header postCallBack:^{
            @try {
                if(self->_callBack) {
                    NSLog(@"responseStatusCode : %d", (int)self->_responseStatusCode);
                    
                    if (self->_isJsCallback) {
                        self->_callBack(resultDic, [NSString stringWithFormat:@"%d",(int)self->_responseStatusCode], message);
                    } else {
                            self->_callBack(resultValue, rsltCode, message);
                    }
                }
            } @catch (NSException *exception) {
                NSLog(@"callBack exception");
            } @finally {
                NSLog(@"callBack final");
            }
        } finished:^{
            // 통신 header 저장후 위젯에서 사용
            if ([AppInfo sharedInfo].isLogin) {
                if ([self allHTTPHeaderFields].count > 0) {
                    NSMutableDictionary *headerInfo = [[NSMutableDictionary alloc] initWithDictionary:[self allHTTPHeaderFields]];
                    headerInfo[@"lts"] = [NSString stringWithFormat:@"%.0f", [PwdWrapper timeStamp]];
                    NSLog(@"\n[HTTP HEADER] : %@", headerInfo);
                    
                    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
                    [userDefault setObject:headerInfo forKey:WIDGET_HEADER];
                    [userDefault setObject:SERVER_URL forKey:WIDGET_SERVER_URL];
                    [userDefault synchronize];
                }
            }
            
            [self remove];
        }];
        return;
	}
    
    [self remove];
}

-(void)regist {
	[Request registRequest:self];
}

-(void)remove {
	if(_callBack) {
		_callBack = nil;
	}
	_runLoop = NO;
	[Request removeRequest:self];
}

-(BOOL)cancel {
	NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:self];
	if(task) {
		[task cancel];
	}
	[self performSelectorOnMainThread:@selector(remove) withObject:nil waitUntilDone:YES];
	return YES;
}


#pragma mark  - 인스턴트 Request의 라이프사이클 관련.

+(void)chackedEmpty {
#ifdef Single_Task_Mode
	if(waitingRequests.count != 0) {
		Request *rq = waitingRequests.firstObject;
		[rq send];
		[waitingRequests removeObject:rq];
	}
    else {
		waitingRequests = nil;
    }
#endif
	[self cancelPreviousPerformRequestsWithTarget:self selector:@selector(chackedEmpty) object:nil];
	if(showLoadingRequests.count == 0) {
		if(showLoadingRequests != nil) {
			[IndicatorView hide];
		}
		showLoadingRequests = nil;
	}
    
	if(noneLoadingRequests.count == 0) {
		noneLoadingRequests = nil;
	}
	//통신이 모두 끝나면 Cache.db를 삭제한다. (취약성 지적사항)
	if(noneLoadingRequests == nil && showLoadingRequests == nil) {
		static NSString *cachesDbPath = nil;
		if(cachesDbPath == nil) {
			NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
			cachesDbPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@/Cache.db",bundleIdentifier];
		}
		[[NSFileManager defaultManager] removeItemAtPath:cachesDbPath error:nil];
	}
#ifdef Single_Task_Mode
	if(noneLoadingRequests == nil && showLoadingRequests == nil && waitingRequests == nil)
		singleRunTask = NO;
#endif
}

+(void)cancelRequestAll {
#ifdef Single_Task_Mode
	[waitingRequests removeAllObjects];
	waitingRequests = nil;
#endif
    
     @synchronized (showLoadingRequests) {
        @try{
            for(Request *rq in showLoadingRequests)
                [rq cancel];
            
            [showLoadingRequests removeAllObjects];
        }@catch(NSException * exception){}
     }
    
    @synchronized (noneLoadingRequests) {
        @try{
            for(Request *rq in noneLoadingRequests)
                [rq cancel];
            
            [noneLoadingRequests removeAllObjects];
        }@catch(NSException * exception){}
    }
        
	[Request chackedEmpty];
}

+(void)cancelRequestWithOwn:(id)own {
	if(own == nil) return;
    @try {
        if(showLoadingRequests) {
            @synchronized (showLoadingRequests) {
                NSMutableArray *removeArr = [NSMutableArray array];
                for(Request * rq in showLoadingRequests) {
                    if(rq.own == own) {
                        if([rq cancel] == NO) {
                            [removeArr addObject:rq];
                        }
                    }
                }
                [showLoadingRequests removeObjectsInArray:removeArr];
                removeArr = nil;
            }
        }
    } @catch(NSException * exception) {}
    
    @try {
        if(noneLoadingRequests) {
            @synchronized (noneLoadingRequests) {
                NSMutableArray *removeArr = [NSMutableArray array];
                for(Request * rq in noneLoadingRequests) {
                    if(rq.own == own) {
                        if([rq cancel] == NO) {
                            [removeArr addObject:rq];
                        }
                    }
                }
                [noneLoadingRequests removeObjectsInArray:removeArr];
                removeArr = nil;
            }
        }
        
    } @catch(NSException * exception) {}
	
	[Request chackedEmpty];
}

+(void)removeRequest:(Request*)request {
    if(request.showLoading) {
        @synchronized (showLoadingRequests) {
            if ([showLoadingRequests containsObject: request]) {
                [showLoadingRequests removeObject:request];
            }
        }
    } else {
         @synchronized (noneLoadingRequests) {
            if ([noneLoadingRequests containsObject: request]) {
                [noneLoadingRequests removeObject:request];
            }
         }
    }
	
	[self cancelPreviousPerformRequestsWithTarget:self selector:@selector(chackedEmpty) object:nil];
	[self performSelector:@selector(chackedEmpty) withObject:nil afterDelay:0.01];
}

+(void)registRequest:(Request*)request {
	if(request.showLoading) {
         @synchronized (showLoadingRequests) {
            if(showLoadingRequests == nil) {
                showLoadingRequests = [NSMutableArray array];
            }
            
            [IndicatorView showMessage:request.message];
            [showLoadingRequests addObject:request];
         }
	}
	else
	{
         @synchronized (noneLoadingRequests) {
             if(noneLoadingRequests == nil) {
                noneLoadingRequests = [NSMutableArray array];
             }
            [noneLoadingRequests addObject:request];
         }
	}
}

- (void)commonMessageProcess:(NSDictionary *)header
                postCallBack:(void (^)(void))postCallback
                    finished:(void (^)(void))finishedRequest {
    NSDictionary * actionInfo = [header null_valueForKey:@"actionInfo"];
    NSString * postAction = [actionInfo null_valueForKey:@"postAction"];
    NSInteger alertGbn = [[actionInfo null_valueForKey:@"alertGbn"] integerValue];  //1: alert, 2: confirm
    NSInteger order = [[actionInfo null_valueForKey:@"order"] integerValue];    //1: callback을 alert앞에 처리, 2: callback을 alert확인클릭 후 처리, 9:콜백 호출안함
    NSString * alertMsg = [actionInfo null_valueForKey:@"alertMsg"];    // "메시지||타이틀||확인버튼명||취소버튼명" - 타이틀 확인버튼 취소버튼명이 없는경우 기본값사용
    alertMsg = alertMsg ? alertMsg.trim : alertMsg;
    
    NSArray * msgData = [alertMsg split:@"||"];
    NSString * strTitle = msgData.count >= 2 ? msgData[1] : @"알림";
    NSString * strConfirm = nil;
    NSString * strCancel = nil;
    
    // 메시지가 없을땐 기존로직 수행
    if(alertMsg.length == 0) {
        postCallback();
        finishedRequest();
        return;
    }
        
    /*************** 메시지가 있을경우*****************/
    if (order == responseMsgCBOrderTypePrev) {
        postCallback();
    }
    
    if (alertGbn == responseMsgAlertTypeAlert) {
        strConfirm = msgData.count >= 3 ? msgData[2] : @"확인";
        strCancel = nil;
    } else if(alertGbn == responseMsgAlertTypeConfirm) {
        strConfirm = msgData.count >= 3 ? msgData[2] : @"확인";
        strCancel = msgData.count >= 4 ? msgData[3] : @"취소";
    }
        
    [BlockAlertView showBlockAlertWithTitle:strTitle message:msgData[0] dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        
        if (order == responseMsgCBOrderTypeNext) {
            postCallback();
        }
        
        // 이동 액션이 있고 confirm 이나 alert의 확인버튼을 눌렀을떄
        if (postAction.length !=0
            && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:strConfirm] ) {
            
            [[AllMenu delegate] sendBirdDetailPage:postAction callBack:^(ViewController *vc) {}];
        }
        
        finishedRequest();
        
    } cancelButtonTitle:strCancel buttonTitles:strConfirm, nil];
}

@end
