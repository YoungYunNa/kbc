//
//  MobileWeb.m
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 8. 31..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "MobileWeb.h"

#import "CertificationManager.h"
#import "CustomAdViewHolder.h"
#import "GifProgress.h"
#import "KBAddressView.h"
#import "PwdPinViewController.h"
#import "PwdWrapper.h"
#import "ScrappingManager.h"
#import "WebViewController.h"
#import "KCLStandardOpenAPI.h"
#import "KCLPopupViewController.h"

#import "KCLMateTalkShareView.h"
#import "KCLBarcodeZoomViewController.h"
#import "KCLQRScannerViewController.h"
#import "KCLPaymentViewController.h"
#import "KCLPaymentCancelPopupView.h"
#import "KCLIntroViewController.h"

#import <AdSupport/ASIdentifierManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <BuzzAdBenefit/BuzzAdBenefit.h>
#import <BuzzAdBenefitNative/BuzzAdBenefitNative.h>
#import <BuzzAdBenefitInterstitial/BuzzAdBenefitInterstitial.h>
#import <BuzzAdBenefitFeed/BuzzAdBenefitFeed.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <KakaoLink/KakaoLink.h>
#import <KakaoMessageTemplate/KakaoMessageTemplate.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <MessageUI/MessageUI.h>
#import <SafariServices/SafariServices.h>
#import <Social/Social.h>
#import <sys/utsname.h>
#import <UserNotifications/UserNotifications.h>

// 비밀번호 키
#define KEY_PWD             @"pwd"          // 현재 비번
#define KEY_NEW_PWD         @"newPwd"       // 신규 비번
#define KEY_NEW_PWD_CFRM    @"newPwdCfrm"   // 신규 비번 확인
#define HDTV_NAME           @"비디오포털"
#define HDTV_SCHEME         @"hdtvexternalcall://"
#define HDTV_STORE_ID       @"id663697257"
#define HDTV_DEF_INTENT     @"&main_run=Y&auth_check=Y&backkey_finish=Y&is_splash=Y"

//baseAction
@implementation MobileWeb {
	void (^_finishedCallback) (NSDictionary *result, BOOL success);
}

+(instancetype)runWithParam:(NSDictionary*)param callback:(void (^)(NSDictionary *result, BOOL success))finishedCallback {
	MobileWeb *action = [[self alloc] init];
	[action runWithParam:param callback:finishedCallback];
	return action;
}

-(void)dealloc {
	_webView = nil;
	_finishedCallback = nil;
}

-(void)run {
	
}

-(void)cancel {
	_finishedCallback = nil;
	[HybridActionManager finishedAction:self];
}

-(void)runWithParam:(NSDictionary *)param callback:(void (^)(NSDictionary *result, BOOL success))finishedCallback {
	self.paramDic = param;
	_finishedCallback = finishedCallback;
	[HybridActionManager regestAction:self];
	[self run];
}

-(void)finishedActionWithResult:(NSDictionary*)result success:(BOOL)success {
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		@try {
			if(self->_finishedCallback)
				self->_finishedCallback(result,success);
			
			NSString *callBack = success ? self.successCallback : self.failCallback;
#ifdef DEBUG
            TXLog(@">> %@(%@);",callBack,(result ? (result.jsonString.length <= 2000 ?result.jsonString:[result.jsonString substringToIndex:2000]) : @""));
#endif
			if(callBack.length) {
                
				NSString *argumentsStr = (result ? result.jsonString : @"");
				NSString *script = [NSString stringWithFormat:@"%@(%@);",callBack,argumentsStr];
                NSLog(@"argumentsStr:%@(%@)",callBack,argumentsStr);
				if([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:completionHandler:)])
					[self.webView stringByEvaluatingJavaScriptFromString:script completionHandler:^(NSString *result){
						TXLog(@"returnVal = %@",result);
					}];
			}
			[self cancel];
		} @catch (NSException *exception) {
			[self cancel];
		}
	});
}
@end

//전화번호부 전달
@implementation requestAddressBook4MobileWeb
- (void)run {
	BOOL isMemberOnly = [[self.paramDic objectForKey:@"isMemberOnly"] isEqualToString:@"Y"];
	NSInteger mCount = [[self.paramDic objectForKey:@"mCount"] integerValue];
    NSString * filterType = nil2Str([self.paramDic objectForKey:@"filterType"]);
    NSString * mTitle = nil2Str([self.paramDic objectForKey:@"mTitle"]);
    
    if ([@"undefined" isEqualToString:filterType]) {
        filterType = @"";
    }
        
    KBAddressView *addView = [KBAddressView initWithLimitedType:mCount filterType:filterType title:mTitle dismissAnimated:NO completeBlock:^(BOOL success, CONTACTS_TYPE typeContact, NSArray *result) {
        
        if (success) {
            NSLog(@"---- result %@", result);
            
            NSMutableArray * numsArray = [[NSMutableArray alloc] init];
            for( NSDictionary *subDic in result ) {
				[numsArray addObject:@{@"name" : [subDic objectForKey:KEY_NAME],
									   @"phone" : [[subDic objectForKey:KEY_NUM] stringByReplacingOccurrencesOfString:@"-" withString:@""], // 보험쿠폰선물->외부업체에서 전화번호 가져 올 때 "-"붙어서 오류가 나오는 문제로 추가
									   }];
            }
			
            NSDictionary *selectedDic = @{@"contactsList" : numsArray};
            
            [self finishedActionWithResult:selectedDic success:YES];
			
        } else {
            [self finishedActionWithResult:nil success:NO];
        }
        
	} menues:(isMemberOnly ? TYPE_MEMBER_PHONE : TYPE_PHOHE),/*TYPE_PHOHE,([AppInfo sharedInfo].isLogin ? TYPE_FRIEND : nil),*/ nil];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:addView];
    [nvc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    UIViewController *topController = [APP_DELEGATE window].rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController presentViewController:nvc animated:YES completion:nil];
}
@end

//포인트리 전달
@implementation requestPoint
- (void)run {
	if([AppInfo userInfo].point) {
		NSMutableDictionary * result = [NSMutableDictionary dictionary];
		[result setValue:[AppInfo userInfo].point forKey:@"point"];
		[self finishedActionWithResult:result success:YES];
	} else {
		[self finishedActionWithResult:nil success:NO];
    }
}
@end

//포인트리 변동알림
@implementation refreshPoint
- (void)run {
	[[AppInfo sharedInfo] reloadPoint];
	[self finishedActionWithResult:nil success:YES];
}
@end

//회원가입 완료
@implementation joinSuccess
- (void)run {
	[AppInfo sharedInfo].isJoin = YES;
	ViewController *webVc = (id)self.webView.parentViewController;
	NSString *encText = [webVc.dicParam valueForKey:@"encText"];
	
    NSString *pwd = encText;
	if(pwd.length != 0) {
		[[AppInfo sharedInfo] sendLoginRequestWithPwdDic:@{@"pwd":pwd} success:^(BOOL success, NSString *errCD, NSDictionary* result) {
			if(success) {
                NSString *strIDFA = @"";
                if (![AppInfo sharedInfo].isIdfaDisable) {
                    // IDFA(광고 식별자) 등록 - 최초/재가입시 서버와 통신(서버에서 최초 가입 판단해서 진행)
                    NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
                    strIDFA    = IDFA.UUIDString;
                }

                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:[AppInfo userInfo].custNo forKey:@"custNo"];
                [param setValue:strIDFA forKey:@"adId"];
                [Request requestID:P00908
                              body:param
                     waitUntilDone:NO showLoading:YES cancelOwn:self
                          finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                          }];
                
				[PwdWrapper deleteBlockChain];
                
				[self finishedActionWithResult:nil success:YES];
            } else {
				[self finishedActionWithResult:nil success:NO];
            }
		}];
	} else {
		[self finishedActionWithResult:nil success:NO];
	}
}
@end

//앱아이디 조회
@implementation requestAppId
- (void)run {
	if([UserDefaults sharedDefaults].appID.length) {
		NSMutableDictionary * result = [NSMutableDictionary dictionary];
		[result setValue:[UserDefaults sharedDefaults].appID forKey:@"appId"];
		[self finishedActionWithResult:result success:YES];
    } else {
		[self finishedActionWithResult:nil success:NO];
    }
}
@end

//앱버전 조회
@implementation requestAppVsn
- (void)run {
	NSMutableDictionary * result = [NSMutableDictionary dictionary];
	[result setValue:[AppInfo sharedInfo].appVer forKey:@"appVsn"];
	[self finishedActionWithResult:result success:YES];
}
@end

//보안키패드 호출
@implementation requestKeyPad
- (void)run {
	NSString *keyNm = [self.paramDic objectForKey:@"keyname"];
	if (keyNm.length == 0) {
		[self finishedActionWithResult:@{@"errorMessage":@"파라미터 이상"} success:NO];
		return;
	}
	
    if([@"4" isEqualToString:[self.paramDic objectForKey:@"length"]]) {
        [PwdWrapper showPwd:^(id  _Nonnull vc) {
            
            if([@"Y" isEqualToString:[self.paramDic objectForKey:@"cardFlag"]]) {   // 카드를 선택한 경우
                [PwdWrapper setTitle:vc value:@"카드 비밀번호"];
                [PwdWrapper setSubTitle:vc value:@"카드 4자리를 입력해 주세요."];
            } else{
                [PwdWrapper setTitle:vc value:@"계좌 비밀번호 4자리를"];
                [PwdWrapper setSubTitle:vc value:@"입력해 주세요."];
            }
            [PwdWrapper setMaxLen:vc value:4];
            
        } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
            if(isCancel == NO) {
                NSMutableDictionary * result = [NSMutableDictionary dictionary];
                [result setValue:keyNm forKey:@"keyname"];
                [result setValue:[PwdWrapper doublyEncrypted:vc keyNm:keyNm] forKey:@"value"];
                
                [self finishedActionWithResult:result success:YES];
            } else {
                [self finishedActionWithResult:nil success:NO];
            }
        }];
    } else {
        [PwdWrapper showPwd:^(id  _Nonnull vc) {
                [PwdWrapper setTitle:vc value:@"비밀번호 6자리를"];
                [PwdWrapper setSubTitle:vc value:@"입력해 주세요."];
                [PwdWrapper setMaxLen:vc value:PWD_PIN_MAX_LEN];
        } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
            if(isCancel == NO) {
                //////////////////////////////////////////////////////////////
                //회원가입시 회원가입 완료(joinSuccess)액션에서 로그인 전문에 사용하려고 저장...
                ViewController *webVc = (id)self.webView.parentViewController;
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                if(webVc.dicParam) {
                    [dic setDictionary:webVc.dicParam];
                }
                // pwd만 저장하게 (회원가입 로그인전문에서 pwd값을 사용)
                if ([@"pwd" isEqualToString:keyNm]) {
                    [dic setValue:[PwdWrapper doublyEncrypted:vc keyNm:keyNm] forKey:@"encText"];
                }
                
                webVc.dicParam = dic;
                ///////////////////////////////////////////////////////////////
                NSMutableDictionary * result = [NSMutableDictionary dictionary];
                [result setValue:keyNm forKey:@"keyname"];
                [result setValue:[PwdWrapper doublyEncrypted:vc keyNm:keyNm] forKey:@"value"];
                
                [self finishedActionWithResult:result success:YES];
            } else {
                [self finishedActionWithResult:nil success:NO];
            }
        }];
    }
}
@end

//보안키패드 호출(블럭체인및 FIDO 모드 사용)
@implementation requestKeyPad2
- (void)run {
	NSString *keyNm = [self.paramDic objectForKey:@"keyname"];
	if (keyNm.length == 0) {
		[self finishedActionWithResult:@{@"errorMessage":@"파라미터 이상"} success:NO];
		return;
	}
    
    [PwdWrapper showPwd:^(id  _Nonnull vc) {
            [PwdWrapper setTitle:vc value:@"비밀번호 6자리를"];
            [PwdWrapper setSubTitle:vc value:@"입력해 주세요."];
            [PwdWrapper setMaxLen:vc value:PWD_PIN_MAX_LEN];
            [PwdWrapper setShowPwdResetBtn:vc value:YES];
    } target:@"HybridCall" callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
        if(isCancel == NO) {
            NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:[PwdWrapper blockChainWithKeyNm:vc keyNm:keyNm]];
            
            //[result removeObjectForKey:keyNm];
            [result setValue:nil forKey:keyNm];
            [result setValue:keyNm forKey:@"keyname"];
            [result setValue:[PwdWrapper doublyEncrypted:vc keyNm:keyNm] forKey:@"value"];
            
            [self finishedActionWithResult:result success:YES];
        } else {
            [self finishedActionWithResult:nil success:NO];
        }
    }];
}
@end

//라온키패드 호출
@implementation requestRaonKeyPad
- (void)run {
    NSString *title = [self.paramDic objectForKey:@"title"];
    NSString *description = [self.paramDic objectForKey:@"description"];
    NSString *minLen = [self.paramDic objectForKey:@"minLen"];
    NSString *maxLen = [self.paramDic objectForKey:@"maxLen"];
    NSString *keyNm = [self.paramDic objectForKey:@"keyname"];
    
    NSString *type = [self.paramDic objectForKey:@"type"]; //Q:쿼티, N:넘버
    
    if ([type isEqualToString:@"Q"]) {
        [PwdWrapper showCertPwd:^(id  _Nonnull vc) {
            [PwdWrapper setTitle:vc value:title];
            [PwdWrapper setMaxLen:vc value:maxLen.intValue];
            [PwdWrapper setMinLen:vc value:minLen.intValue];
        } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
            if(isCancel == NO) {
                NSMutableDictionary * result = [NSMutableDictionary dictionary];
                [result setValue:keyNm forKey:@"keyname"];
                [result setValue:[vc doublyEncrypted:keyNm] forKey:@"value"];
                
                [self finishedActionWithResult:result success:YES];
            } else {
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"9004", @"rsltCode",
                                     @"", @"massage",
                                     @"7", @"linkType",
                                     nil];
                [self finishedActionWithResult:dic success:NO];
            }
        }];
    } else {
        [PwdPinViewController showPwd:^(PwdPinViewController *vc) {
            [PwdWrapper shared].pwdPinVC = vc;
            [vc setTitle:title];
            [vc setSubTitle:description];
            [vc setMaxLen:maxLen.intValue];
            
        } callBack:^(PwdPinViewController *vc, BOOL isCancel, BOOL *dismiss) {
            if(isCancel == NO) {
                ////////////////////////////////////////////////////////////// 3.0 마이그 팀에서 키패드 타이틀명 변경을 위해 keypad 인터페이스 변경하여 코드 추가
                //회원가입시 회원가입 완료(joinSuccess)액션에서 로그인 전문에 사용하려고 저장...
                ViewController *webVc = (id)self.webView.parentViewController;
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                if(webVc.dicParam) {
                    [dic setDictionary:webVc.dicParam];
                }
                // pwd만 저장하게 (회원가입 로그인전문에서 pwd값을 사용)
                if ([@"pwd" isEqualToString:keyNm]) {
                    [dic setValue:[PwdWrapper doublyEncrypted:vc keyNm:keyNm] forKey:@"encText"];
                }
                
                webVc.dicParam = dic;
                ///////////////////////////////////////////////////////////////
                
                NSMutableDictionary * result = [NSMutableDictionary dictionary];
                [result setValue:keyNm forKey:@"keyname"];
                [result setValue:[vc doublyEncrypted:keyNm] forKey:@"value"];
                
                [self finishedActionWithResult:result success:YES];
            } else {
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"9004", @"rsltCode",
                                     @"", @"massage",
                                     @"7", @"linkType",
                                     nil];
                [self finishedActionWithResult:dic success:NO];
            }
        }];
    }
}
@end

//네이티브 화면이동
@implementation go2Page
- (void)run {
    NSString *page = [self.paramDic objectForKey:@"page"];
    
    [[AllMenu delegate] existPage:page parent:self successCb:^(id mobileWeb, NSString *page) {
        
        MobileWeb * mw = (MobileWeb *)mobileWeb;
        
        [[AllMenu delegate] sendBirdDetailPage:page callBack:^(ViewController *vc) {
            id param = [mw.paramDic objectForKey:@"params"];
            if([param isKindOfClass:[NSDictionary class]] == NO) {
                if([param isKindOfClass:[NSString class]])
                    param = [param jsonObject];
                else
                    param = nil;
            }
            vc.dicParam = param;
        }];
        
        [self finishedActionWithResult:nil success:YES];
        
    } failCb:^{
        
        [self finishedActionWithResult:@{@"resCd":@"8888"} success:NO];
    }];
}
@end

//네이티브 화면닫기
@implementation closeView
- (void)run {
	UIViewController *vc = self.webView.parentViewController;
	if(vc.navigationController.viewControllers.count > 1)
		[self.webView.parentViewController.navigationController popViewControllerAnimated:YES];
	else if(vc.navigationController != (id)[AllMenu delegate])
		[vc dismissViewControllerAnimated:YES completion:nil];
	else
		[[AllMenu delegate] navigationWithMenuID:nil
										animated:YES
										  option:NavigationOptionPopView
										callBack:nil];
	[self finishedActionWithResult:nil success:YES];
}
@end

//네비게이션 상단 버튼및 타이틀 셋팅
@implementation setTopMenu
- (void)run {
	WebViewController *webVc = (id)self.webView.parentViewController;
    if([webVc respondsToSelector:@selector(setTopMenu:)]) {
		webVc.topMenu = self.paramDic;
    }
	[self finishedActionWithResult:nil success:YES];
}
@end

//로그인요청
@implementation requestLogin
- (void)run {
	[[AppInfo sharedInfo] performLogin:^(BOOL success, NSString *errCD, NSDictionary* result) {
		if(success) {
             [(HybridWKWebView *)self.webView reload];
		}
		[self finishedActionWithResult:nil success:success];
	}];
}
@end

@implementation getRecommendCd
-(void)run {
    NSString *strIDFA = @"";
    if (![AppInfo sharedInfo].isIdfaDisable) {
        // IDFA(광고 식별자) 등록 - 최초/재가입시 서버와 통신(서버에서 최초 가입 판단해서 진행)
        NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        strIDFA    = IDFA.UUIDString;
    }
    NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"result",strIDFA,@"adid",@"뭐야",@"gameid", nil];
    [self finishedActionWithResult:result success:YES];
}
@end


@implementation requestLight
-(void)run {
    NSString *mode = [self.paramDic objectForKey:@"mode"];
    
    if([mode isEqualToString:@"on"]) { // LCD 최대 밝기로
        [AppInfo sharedInfo].lcdBrightnessValue = [UIScreen mainScreen].brightness;
        [[UIScreen mainScreen] setBrightness:1.0];
    } else { // LCD 원래 밝기로
        [[UIScreen mainScreen] setBrightness:[AppInfo sharedInfo].lcdBrightnessValue];
    }
    [self finishedActionWithResult:nil success:YES];
}
@end

//공유하기 팝업 호출(퀴즈)
@interface requestSharePop () <KCLMateTalkShareViewDelegate, MFMessageComposeViewControllerDelegate> {
    NSString *_title;
    NSString *_imgUrl;
    NSString *_btnUrl;
    NSString *_installUrl;
	NSString *_selectedIndex;	// 1, 2, 3, ...
}
@end

@implementation requestSharePop
-(void)run {
	// for 카카오톡
    _title = [self.paramDic objectForKey:@"title"];
    _imgUrl = [self.paramDic objectForKey:@"imgUrl"];
    _btnUrl = [self.paramDic objectForKey:@"page"];
	
	// for sms, facebook, twitter
    _installUrl = [self.paramDic objectForKey:@"installUrl"];
	
	if (_title.length == 0) _title = @"";
	if (_imgUrl.length == 0) _imgUrl = @"";
	if (_btnUrl.length == 0) _btnUrl = @"";
	if (_installUrl.length == 0) _installUrl = @"";

    KCLMateTalkShareView *shareView = [KCLMateTalkShareView makeView];
    
    WKWebView *webView = (WKWebView*)[self webView];

    [[webView superview] addSubview:shareView];

    shareView.delegate = self;
    [shareView showDesignView:YES];
}

#pragma mark - KCLMateTalkShareViewDelegate
- (void)selectedShareBtn:(int)selectIndex {
    NSLog(@"selectedShareBtn : %d", selectIndex);
    
    self->_selectedIndex = [NSString stringWithFormat:@"%ld", (long)selectIndex];
    
    switch (selectIndex) {
        case 1: { // 카카오톡
            if ( [AppDelegate canOpenURL:[NSURL URLWithString:@"kakaolink://"]] ) {
                // Feed 타입 템플릿 오브젝트 생성
                KMTTemplate *template = [KMTFeedTemplate feedTemplateWithBuilderBlock:^(KMTFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {
                    
                    // 컨텐츠
                    feedTemplateBuilder.content = [KMTContentObject contentObjectWithBuilderBlock:^(KMTContentBuilder * _Nonnull contentBuilder) {
                        contentBuilder.title = self->_title;
                        contentBuilder.desc = @"";
                        contentBuilder.imageURL = [NSURL URLWithString:self->_imgUrl];
                        contentBuilder.imageWidth = [NSNumber numberWithInt:576];
                        contentBuilder.imageHeight = [NSNumber numberWithInt:310];
                        contentBuilder.link = [KMTLinkObject linkObjectWithBuilderBlock:^(KMTLinkBuilder * _Nonnull linkBuilder) {
                        }];
                    }];
                    
                    [feedTemplateBuilder addButton:[KMTButtonObject buttonObjectWithBuilderBlock:^(KMTButtonBuilder * _Nonnull buttonBuilder) {
                        buttonBuilder.title = @"앱에서 자세히 보기";
                        buttonBuilder.link = [KMTLinkObject linkObjectWithBuilderBlock:^(KMTLinkBuilder * _Nonnull linkBuilder) {
                            NSString *params = [NSString stringWithFormat:@"param=%@", self->_btnUrl];
                            linkBuilder.iosExecutionParams = params;
                            linkBuilder.androidExecutionParams = params;
                        }];
                    }]];
                }];
                
                // 카카오링크 실행
                [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
                    NSLog(@"warning message: %@", warningMsg);
                    NSLog(@"argument message: %@", argumentMsg);
                } failure:^(NSError * _Nonnull error) {
                    NSLog(@"error: %@", error);
                }];
				[self finishedActionWithResult:@{@"shareTypeIndex" : _selectedIndex} success:YES];
            } else { // 앱스토어 이동
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"] options:@{} completionHandler:nil];
				[self finishedActionWithResult:@{@"errorMessage":@"Not Install",@"shareTypeIndex" : _selectedIndex} success:NO];
            }
        }
            break;
            
        case 300: { // 라인
            if ( [AppDelegate canOpenURL:[NSURL URLWithString:@"line://"]] ) { // 앱 실행
                NSString *lineUrlString = [NSString stringWithFormat:@"line://msg/text/%@", _installUrl.stringByUrlEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:lineUrlString] options:@{} completionHandler:nil];
            } else { // 앱스토어 이동
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/%EB%9D%BC%EC%9D%B8-line/id443904275?mt=8"] options:@{} completionHandler:nil];
            }
            [self finishedActionWithResult:nil success:NO];
        }
            break;
            
        case 3: {// 페이스북
			if ([AppDelegate canOpenURL:[NSURL URLWithString:@"fb://"]]) {
				SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                if(_title.length) {
					[controller setInitialText:_title];
                }
                if(_installUrl.length) {
					[controller addURL:[NSURL URLWithString:_installUrl]];
                }
				[(UIViewController*)[AllMenu delegate] presentViewController:controller animated:YES completion:nil];
				[self finishedActionWithResult:@{@"shareTypeIndex" : _selectedIndex} success:YES];
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/id284882215?mt=8"] options:@{} completionHandler:nil];
				[self finishedActionWithResult:@{@"errorMessage":@"Not Install",@"shareTypeIndex" : _selectedIndex} success:NO];
			}
        }
            break;
			
		case 4: {// 트위터
			if ([AppDelegate canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
				SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                if(_title.length) {
					[controller setInitialText:_title];
                }
                if(_installUrl.length) {
					[controller addURL:[NSURL URLWithString:_installUrl]];
                }
				[(UIViewController*)[AllMenu delegate] presentViewController:controller animated:YES completion:nil];
				[self finishedActionWithResult:@{@"shareTypeIndex" : _selectedIndex} success:YES];
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/id333903271?mt=8"] options:@{} completionHandler:nil];
				[self finishedActionWithResult:@{@"errorMessage":@"Not Install",@"shareTypeIndex" : _selectedIndex} success:NO];
			}
		}
			break;

        case 2: { // SMS
            if(![MFMessageComposeViewController canSendText]) { // USIM이 없거나, 시뮬레이터에서는 NO가 리턴되며, 앱이 죽을수도 있다.
				[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"메시지 보내기 기능을 지원하지 않습니다." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {} cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
				[self finishedActionWithResult:@{@"errorMessage":@"Not Install",@"shareTypeIndex" : _selectedIndex} success:NO];
            } else {
                MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                if([MFMessageComposeViewController canSendText]) {
                    controller.messageComposeDelegate = self;
                    controller.body = [NSString stringWithFormat:@"%@\n%@",_title,_installUrl];
                    [(UIViewController*)[AllMenu delegate] presentViewController:controller animated:YES completion:nil];
                }
            }
        }
            break;
            
        case 600: { // 더보기
            NSString *textToShare = _installUrl;
            NSArray *itemsToShare = @[textToShare];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAssignToContact]; //or whichever you don't need
            [(UIViewController*)[AllMenu delegate] presentViewController:activityVC animated:YES completion:nil];
            
			[self finishedActionWithResult:@{@"shareTypeIndex" : _selectedIndex} success:YES];
        }
            break;
            
        default:
			[self finishedActionWithResult:nil success:NO];
            break;
    }
}

#pragma mark - 메시지 전송 delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result)
    {
        case MessageComposeResultSent:
            [self finishedActionWithResult:@{@"shareTypeIndex" : _selectedIndex} success:YES];
            break;
        default:
            [self finishedActionWithResult:@{@"shareTypeIndex" : _selectedIndex} success:NO];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

// KB Easy 대출(웹 스크래핑)
@implementation requestScrapingInfo
- (void)run {
    // param
//    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
//                           @"cn=김응엽()001104520110111111001963,ou=NACF,ou=personal4IB,o=yessign,c=kr", @"subject",
//                           @"2019-04-12 23:59:59", @"expiryDate",
//                           @[@"101", @"102", @"211"], @"reportType",
//                           @"2", @"beforeDate_1",
//                           @"2", @"beforeDate_2",
//                           @"910925", @"ssno",
//             nil];
    [[ScrappingManager shared] startScrapping:self.paramDic retry:NO completion:^(NSDictionary * _Nonnull result, BOOL isSuccess) {
        if (!isSuccess) {
            [GifProgress hideGif:nil];
        }
        [self finishedActionWithResult:result success:isSuccess];
    }];
}
@end

@implementation requestCertifyList
- (void)run {
    NSArray *certArr = [[CertificationManager shared] getCertificationList2];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                         certArr, @"certifyList",
                         [NSString stringWithFormat:@"%lu",(unsigned long)certArr.count], @"certCount",
                         nil];
    [self finishedActionWithResult:result success:YES];
}

@end

@implementation saveCertify
- (void)run {
    NSString * certifyNumber = self.paramDic[@"certifyNumber"];
    [IndicatorView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //프로그래스 호출 직후 바로 위즈베라 모듈에서 통신이 발생하면 프로그래스 호출이 무시되는 현상이 있음 (위즈베라 모듈 통신을 메인 스레드에서 하는지??)
        //프로그래스 호출 후 딜레이를 주고 실행
        [[CertificationManager shared] getCertWizvera:self.paramDic authCode:certifyNumber completion:^(NSDictionary * _Nullable result, BOOL isSuccess) {
            [self finishedActionWithResult:result success:isSuccess];
        }];
    });
}
@end

@implementation deleteCertify
- (void)run {
    [[CertificationManager shared] deleteCertification:self.paramDic completion:^(NSDictionary * _Nonnull result, BOOL isSuccess) {
        [self finishedActionWithResult:result success:isSuccess];
    }];
}
@end

@implementation backBtnCall
- (void)run {
    NSString *action = self.paramDic[@"preAction"];
    WebViewController *webVc = (id)self.webView.parentViewController;

    if([action isEqualToString:@"C"])
        webVc.preType  = PreTypeClose;
    else if([action isEqualToString:@"T"])
        webVc.preType  = PreTypeTargetUrl;
    else if([action isEqualToString:@"F"])
        webVc.preType  = PreTypeTargetFunction;
    else
        webVc.preType  = PreTypeGoBack;
    
   [webVc backButtonAction:nil];
}
@end

@implementation setTopMenuV2
- (void)run {
    WebViewController *webVc = (id)self.webView.parentViewController;
    if([webVc respondsToSelector:@selector(setTopMenu:)])
        webVc.topMenu = self.paramDic;

    [self finishedActionWithResult:nil success:YES];
}
@end

@implementation callProgressBar
- (void)run {
    NSString * showHideFlag = self.paramDic[@"callProgress"];
    NSLog(@"showHideFlag : %@", showHideFlag);
    
    if([showHideFlag isEqualToString:@"1"]){
        //show
        [GifProgress showGifWithName:gifType_cheer completion:^(NSDictionary * _Nullable result, BOOL isSuccess) {
            [self finishedActionWithResult:result success:isSuccess];
        }];
    } else {
        //hide
        [GifProgress hideGif:^(NSDictionary * _Nullable result, BOOL isSuccess) {
            [self finishedActionWithResult:result success:isSuccess];
        }];
    }
}
@end

@implementation showAlert
- (void)run {
    @try {
        NSString *msg = self.paramDic[@"msg"];
        NSString *lBtnNm;
        NSString *rBtnNm;
        
        NSArray *btnNms = self.paramDic[@"btnNms"];
        if (btnNms.count == 1) {
            rBtnNm = [btnNms objectAtIndex:0];
        } else {
            lBtnNm = [btnNms objectAtIndex:0];
            rBtnNm = [btnNms objectAtIndex:1];
        }
        [BlockAlertView showBlockAlertWithTitle:nil message:msg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            NSString *btnIdx = [NSString stringWithFormat:@"%ld", (long)buttonIndex];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:btnIdx, @"idx", nil];
            [self finishedActionWithResult:dic success:YES];
        } cancelButtonTitle:lBtnNm buttonTitles:rBtnNm, nil];
    } @catch (NSException *exception) {
        [self finishedActionWithResult:nil success:NO];
    }
}
@end

#pragma mark - V2 인터페이스
//자동로그인 설정
@implementation setAutoLogin
-(void)run {
    // 버튼 클릭시, 전문 결과후 버튼이 토글되기에 전문엔 !값을 붙여 보냄.
    NSString *autoLoginYn = self.paramDic[@"autoLoginYn"];
    [AppInfo sharedInfo].autoLogin = autoLoginYn.boolValue;
    [self finishedActionWithResult:nil success:YES];
}
@end

//비밀번호 확인
@implementation verifyPassword
-(void)run {
    // 비밀번호 확인 화면으로 이동
    NSString *custNo = [AppInfo userInfo].custNo;
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:custNo,@"custNo", nil];
    
    // Ver. 3  비밀번호 검증(KATL010)
    [Request requestID:KATL010
                  body:param
              pinKeyNm:KEY_PWD
               setting:^(id  _Nonnull vc) {
                        [PwdWrapper setTitle:vc value:@"비밀번호 6자리를"];
                        [PwdWrapper setSubTitle:vc value:@"입력해 주세요"];
                        [PwdWrapper setShowPwdResetBtn:vc value:YES];
                    }
           showLoading:YES
             cancelOwn:self
              finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                  if(IS_SUCCESS(rsltCode)) {
                      // 결과 전송 (성공)
                      [self finishedActionWithResult:result success:YES];
                  } else {
                      // 결과 전송 (실패)
                      NSDictionary *errorDic = (message.length > 0 ? @{@"errorMessage":message} : nil);
                      [self finishedActionWithResult:errorDic success:NO];
                  }
              }];
}
@end

//비밀번호 변경
@interface changePassword () {
    NSMutableDictionary *_changPwdParm;
}
@end

@implementation changePassword
-(void)run {
    // 비밀번호 변경 화면으로 이동
    _changPwdParm = [[NSMutableDictionary alloc] init];
    
    // 비밀번호 확인 화면으로 이동
    [PwdWrapper showPwd:^(id  _Nonnull vc) {
        [PwdWrapper setTitle:vc value:@"비밀번호"];
        [PwdWrapper setSubTitle:vc value:@"6자리를 입력해주세요."];
        [PwdWrapper setMaxLen:vc value:PWD_PIN_MAX_LEN];
        [PwdWrapper setShowPwdResetBtn:vc value:NO];
        [PwdWrapper setTag:vc tag:0];
    } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
        if (isCancel == NO) {
            // 새 비밀번호
            if([PwdWrapper getTag:vc] == 0) {
                [self->_changPwdParm setObject:[PwdWrapper doublyEncrypted:vc keyNm:KEY_PWD] forKey:KEY_PWD];
                
                (*dismiss) = NO;
                
                NSMutableDictionary *sendBody = [NSMutableDictionary dictionaryWithDictionary:@{ @"custNo" : [AppInfo userInfo].custNo }];
                [sendBody addEntriesFromDictionary:[PwdWrapper blockChainWithKeyNm:vc keyNm:KEY_PWD]];
                
                // Ver. 3 비밀번호 변경전 검증(KATL010)
                    [Request requestID:KATL010
                          message:nil
                             body:sendBody
                    waitUntilDone:NO
                      showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                          if(IS_SUCCESS(rsltCode)) {
                              [PwdWrapper setTitle:vc value:@"비밀번호 변경"];
                              [PwdWrapper setSubTitle:vc value:@"변경하실 비밀번호 숫자 6자리를 입력해주세요."];
                              [PwdWrapper setTag:vc tag:1];
                              [PwdWrapper setShowPwdResetBtn:vc value:NO];
                              
                              [PwdWrapper resetPwd:vc];
                          }
                          else {
                              rsltCode = (rsltCode) ? rsltCode : @"";
                              if ([ERRCODE_PinMaxErr rangeOfString:rsltCode].location == NSNotFound) {   // 네트워크 공통 처리에서 이미 팝업 띄움
                                  [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                                      
                                  } cancelButtonTitle:nil buttonTitles:@"확인", nil];
                              }
                              
                              [vc dismissViewControllerAnimated:YES completion:^{
                                  // 결과 전송 (실패)
                                  NSDictionary *errorDic = (message.length > 0 ? @{@"errorMessage":message} : nil);
                                  [self finishedActionWithResult:errorDic success:NO];
                              }];                          }
                      }];
            }
            else if([PwdWrapper getTag:vc] == 1) { // 새 비밀번호 확인
                [self->_changPwdParm setObject:[PwdWrapper doublyEncrypted:vc keyNm:KEY_NEW_PWD]  forKey:KEY_NEW_PWD];
                (*dismiss) = NO;
                [PwdWrapper resetPwd:vc];
                
                [PwdWrapper setTitle:vc value:@"비밀번호 변경"];
                [PwdWrapper setSubTitle:vc value:@"비밀번호를 다시 입력해주세요."];
                [PwdWrapper setTag:vc tag:2];
                [PwdWrapper setShowPwdResetBtn:vc value:NO];
            } else if([PwdWrapper getTag:vc] == 2) {
                [self->_changPwdParm setObject:[PwdWrapper doublyEncrypted:vc keyNm:KEY_NEW_PWD_CFRM] forKey:KEY_NEW_PWD_CFRM];
                
                [self requestChangePassWord];
            }
        } else {
            // ???? TODO : 결과 전송 (실패)
            NSString *message = nil;    //@"비밀번호 변경을 취소하셨습니다.";
            NSDictionary *errorDic = (message.length > 0 ? @{@"errorMessage":message} : nil);
            [self finishedActionWithResult:errorDic success:NO];
        }
    }];
}

- (void)requestChangePassWord {
    NSString *custNo = [AppInfo userInfo].custNo;
    NSString *pwd = [_changPwdParm objectForKey:KEY_PWD];
    NSString *newPwd = [_changPwdParm objectForKey:KEY_NEW_PWD];
    NSString *newPwdCfrm = [_changPwdParm objectForKey:KEY_NEW_PWD_CFRM];
    
    NSDictionary *pwdParam = [[NSDictionary alloc] initWithObjectsAndKeys:custNo,@"custNo",pwd,KEY_PWD,newPwd,KEY_NEW_PWD,newPwdCfrm,KEY_NEW_PWD_CFRM, nil];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] initWithDictionary:pwdParam];
    
    //  Ver. 3 비밀번호 변경(KATL020)
    [Request requestID:KATL020
                  body:param
         waitUntilDone:NO
           showLoading:YES
             cancelOwn:self
              finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                  if(IS_SUCCESS(rsltCode)) {
                      [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"비밀번호가 변경 되었습니다." dismisTitle:@"확인"];
                      
                      // ???? TODO : 결과 전송 (성공)
                      [self finishedActionWithResult:result success:YES];
                  } else {
                      rsltCode = (rsltCode) ? rsltCode : @"";
                      if ([ERRCODE_PinMaxErr rangeOfString:rsltCode].location == NSNotFound) {   // 네트워크 공통 처리에서 이미 팝업 띄움
                          [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismisTitle:@"확인"];
                      }
                      
                      // ???? TODO : 결과 전송 (실패)
                      NSDictionary *errorDic = (message.length > 0 ? @{@"errorMessage":message} : nil);
                      [self finishedActionWithResult:errorDic success:NO];
                  }
              }];
}

@end

//회원가입시 기존회원일경우 인증 (재구현)
@implementation certifiedMember
- (void)run {
    [[UserDefaults sharedDefaults] joinReset];
    [PwdWrapper deleteBlockChain];
    [AppInfo sharedInfo].isJoin = YES;
    
    [[AppInfo sharedInfo] performLogin:^(BOOL success, NSString *errCD, NSDictionary* result) {
                
        if ([AppInfo sharedInfo].pwdErrNotms >= 99 || [MenuID_PwdReset isEqualToString:errCD] || [MenuID_V3_PwdReset isEqualToString:errCD]) {       // 일시 정지 상태 (이미 본인인증 화면 이동함) Ver. 3 MenuID_V3_PwdReset 코드 추가
            CGFloat time = 0.4;
            
            // Ver. 3 MenuID_V3_PwdReset 코드 추가(MYD_LO0103)
            time = [MenuID_V3_PwdReset isEqualToString:errCD] ? 1 : time;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self finishedActionWithResult:nil success:YES];
            });
        } else {
            [self finishedActionWithResult:nil success:YES];
        }
    }];
}
@end

//본인인증 결과
@interface certifiedResult () {
    NSMutableDictionary *_changPwdParm;
    NSString *_oldPW;
}
@end

@implementation certifiedResult
- (void)run {
    if ([self.paramDic[@"isResetPassword"] isEqualToString:@"Y"]) {
        _changPwdParm = [[NSMutableDictionary alloc] init];
        
        [PwdWrapper showPwd:^(id  _Nonnull vc) {
            
            [PwdWrapper setTitle:vc value:@"비밀번호 설정"];
            [PwdWrapper setSubTitle:vc value:@"비밀번호 숫자 6자리를 입력해주세요."];
            [PwdWrapper setMaxLen:vc value:PWD_PIN_MAX_LEN];
            [PwdWrapper setTag:vc tag:0];

        } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
            if(isCancel == NO) {
                // 새 비밀번호
                if([PwdWrapper getTag:vc] == 0) {
                    [self->_changPwdParm setObject:[PwdWrapper doublyEncrypted:vc keyNm:KEY_NEW_PWD] forKey:KEY_NEW_PWD];
                    (*dismiss) = NO;
                    
                    [PwdWrapper resetPwd:vc];
                    
                    [PwdWrapper setTitle:vc value:@"비밀번호 설정"];
                    [PwdWrapper setSubTitle:vc value:@"비밀번호를 다시 한번 입력해주세요."];
                    [PwdWrapper setTag:vc tag:1];
                } else if([PwdWrapper getTag:vc] == 1) { // 새 비밀번호 확인
                    [self->_changPwdParm setObject:[PwdWrapper doublyEncrypted:vc keyNm:KEY_NEW_PWD_CFRM] forKey:KEY_NEW_PWD_CFRM];
                    (*dismiss) = YES;
                    
                    // 전문 실행
                    [self requestResetPassWord];
                }
            } else {
                // ???? TODO : 결과 전송 (실패)
                NSString *message = @"비밀번호 설정을 취소하셨습니다.";
                NSDictionary *errorDic = (message.length > 0 ? @{@"errorMessage":message} : nil);
                [self finishedActionWithResult:errorDic success:NO];
            }
        }];
    } else {
        // ???? 기존 코드 (이외 케이스)
        [((id)self.webView.parentViewController) successCertified:self.paramDic];
        [self finishedActionWithResult:nil success:YES];
    }
}

-(void)requestResetPassWord {
    // 비번 5회 초과시 로그아웃되어, custNo를 알수 없기에 appId로 변경
    NSString *appId = [UserDefaults sharedDefaults].appID;
    NSString *newPwd = [_changPwdParm objectForKey:KEY_NEW_PWD];
    NSString *newPwdCfrm = [_changPwdParm objectForKey:KEY_NEW_PWD_CFRM];
    
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:appId,@"appId",newPwd,KEY_NEW_PWD,newPwdCfrm,KEY_NEW_PWD_CFRM, nil];
    UIViewController *vc = self.webView.parentViewController;
    
    //  Ver. 3  비밀번호 재설정(KATJ023)
    [Request requestID:KATJ023
             body:param
    waitUntilDone:NO
      showLoading:YES
        cancelOwn:self
         finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
             if(IS_SUCCESS(rsltCode)) {
                 //비밀번호 재설정 성공시 비밀번호 오류횟수 초기화
                 [AppInfo sharedInfo].pwdErrNotms = 0;
                 [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"비밀번호가 변경되었습니다." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                     [vc.navigationController popViewControllerAnimated:YES];
                     // 앱 메인 화면으로 이동
                     //[[AllMenu delegate] goMainViewControllerAnimated:YES];
                 } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
                 
                 // ???? TODO : 결과 전송 (성공)
                 [self finishedActionWithResult:result success:YES];
             } else {
                 [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                     
                     if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"재시도"]) {
                         // ???? 입력창 다시 호출
                         [self run];
                     } else {
                         // ???? TODO : 결과 전송 (실패)
                         NSDictionary *errorDic = (message.length > 0 ? @{@"errorMessage":message} : nil);
                         [self finishedActionWithResult:errorDic success:NO];
                         
                         [vc.navigationController popViewControllerAnimated:YES];
                     }
                 } cancelButtonTitle:@"취소" buttonTitles:@"재시도", nil];
             }
         }];
}
@end

//기기 정보 조회 (native에서 읽어야 할 정보 모두 보낸다)
@implementation getDeviceInfo
- (void)run {
    // ???? TODO : native에서 읽어야 할 정보 모두 보낸다
    BOOL isFidoDevice =
    ([AppInfo sharedInfo].useBiometrics == UseBiometricsEnabled ||
     ([AppInfo sharedInfo].useBiometrics == UseBiometricsDisabled && [AppInfo sharedInfo].lastBiometricsError.code != kLAErrorBiometryNotAvailable /*kLAErrorTouchIDNotAvailable*/));
    
    BOOL fidoIsNotRegisteredInDevice = isFidoDevice &&
    ([AppInfo sharedInfo].useBiometrics == UseBiometricsDisabled &&
     ([AppInfo sharedInfo].lastBiometricsError.code == kLAErrorBiometryNotEnrolled
      || [AppInfo sharedInfo].lastBiometricsError.code == kLAErrorPasscodeNotSet ));
    
    
    BOOL fidoIsLockOut =  isFidoDevice &&
    ([AppInfo sharedInfo].useBiometrics == UseBiometricsDisabled && [AppInfo sharedInfo].lastBiometricsError.code == kLAErrorBiometryLockout /*kLAErrorTouchIDLockout*/);
    
    NSString *fidoType = @"";
    
    if (isFidoDevice) {
        if ([AppInfo sharedInfo].typeBiometrics == TypeTouchID) {
            fidoType = @"touchID";
        } else if([AppInfo sharedInfo].typeBiometrics == TypeFaceID) {
            fidoType = @"faceID";
        }
    }
    
    if (([UserDefaults sharedDefaults].useFido == FidoUseSettingEnabled)) {
        [UserDefaults sharedDefaults].isRegistedFido = YES;
    }
    
    NSDictionary *deviceInfo = @{
                                 @"authenticationType": (([UserDefaults sharedDefaults].useFido == FidoUseSettingEnabled) ? @"FIDO" : @"PASSWORD"),
                                 @"appCardInstalled": ([AppDelegate canOpenURL:[NSURL URLWithString:@"kb-auth://"]] ? @"Y" : @"N"),    // ???? TODO : 앱카드 확인요망
                                 @"paymentType": ([[[[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"] objectForKey:@"WIDGET_PAYMENT_TYPE"] isEqualToString:@"QR"] ? @"QR" : @"BARCODE"),
                                 @"isFidoRegistered": ([UserDefaults sharedDefaults].isRegistedFido ? @"Y" : @"N"),
                                 @"isFidoDevice": (isFidoDevice ? @"Y" : @"N"),
                                 @"isFidoRegisteredInDevice": (!fidoIsNotRegisteredInDevice && !fidoIsLockOut ? @"Y" : @"N"),
                                 @"fidoType":fidoType,
                                 @"isFidoLock":fidoIsLockOut?@"Y":@"N",
                                 @"isFaceEnable": [AppInfo sharedInfo].isFaceEnable,
                                 };
    
    [self finishedActionWithResult:deviceInfo success:YES];
}
@end

//로그인
@implementation login
- (void)run {
    // ???? TODO : 회원가입, 비밀번호 초과 처리 등 확인 요망 (performLogin 수정 요망)
    NSLog(@"login1 ViewController : %@", [APP_MAIN_VC.visibleViewController class]);
    NSLog(@"login2 ViewController : %@", [APP_DELEGATE.window.rootViewController class]);
    
    [[AppInfo sharedInfo] performLogin:^(BOOL success, NSString *errCD, NSDictionary* result) {
        if (success) {
            [self finishedActionWithResult:result success:YES];
        } else {
            [[AppInfo sharedInfo] performLogout:nil];
            [self finishedActionWithResult:nil success:NO];
        }
    }];
}
@end

//로그아웃 (native 정보 정리, 자동로그인 설정 해제)
@implementation logout
- (void)run {
    // ???? TODO : 자동로그인 설정 해제
    [BlockAlertView dismissAllAlertViews];
    [Request cancelRequestAll];
    [[AppInfo sharedInfo] performLogout:^(BOOL success) {
        // 위젯 처리 위해 저장
        NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
        [userDefault setObject:@"N" forKey:@"WIDGET_USER_LOGINED"];
        [userDefault synchronize];
    
        [self finishedActionWithResult:nil success:YES];
    }];
}
@end

//회원정보 수정
@implementation modifiedMemberInfo
- (void)run {
    // ???? TODO : 회원정보 수정 -> 서버 저장 -> 수정 정보 native setting 요망 (P00206 : [AppInfo sharedInfo].moblNo)
    // 앱 로컬에 변경된 내용 저장
    [AppInfo userInfo].moblNo = self.paramDic[@"moblNo"];
        
    [self finishedActionWithResult:nil success:YES];
}
@end

//회원탈퇴
@implementation memberDropedOut
- (void)run {
    // ???? TODO : 회원탈퇴 -> 서버 저장 -> native 로컬 정보 삭제 요망 (P00902 : [self successMemDropOut];)
    NSLog(@"%s isLogin == %d", __FUNCTION__, [AppInfo sharedInfo].isLogin);
    if ([AppInfo sharedInfo].isLogin) { // 회원탈퇴 시 로그아웃
        [[AppInfo sharedInfo] performLogout:^(BOOL success) {
            [AppInfo sharedInfo].isJoin = NO;
            // 회원탈퇴 시 지문등록 처리 (지문등록 안된 걸로)
            [UserDefaults sharedDefaults].useFido = FidoUseSettingNone;
             
            [self finishedActionWithResult:nil success:YES];
        }];
        
        [IndicatorView hide];
        return;
    }
}
@end

//통신시 사용되는 httpRequsetHeaderField
@implementation getHttpHeader : MobileWeb
- (void)run {
    [self finishedActionWithResult:[MateRequest httpHeader] success:YES];
}
@end

//QR코드 스캔
@implementation scannQRCode
- (void)run {
    NSInteger type = [self.paramDic[@"type"] integerValue];
    NSString *title = self.paramDic[@"title"];
    NSString *menuID = MenuID_ScannerSend;
    if(type == 1) {
        menuID = MenuID_ScannerCancel;
    }
    
    [AllMenu.delegate navigationWithMenuID:menuID animated:YES option:NavigationOptionNavigationModal callBack:^(ViewController *vc) {
        if(title.length) {
            vc.title = title;
        }
        ((KCLQRScannerViewController*)vc).type = type;
        [((KCLQRScannerViewController*)vc) setFinishedCallback:^(NSString *result, BOOL isCancel) {
            if(isCancel == NO && result) {
                [self finishedActionWithResult:@{@"result" : result} success:YES];
            } else {
                [self finishedActionWithResult:@{@"errorMessage":@"cancel"} success:NO];
            }
        }];
    }];
}
@end

//접근권한설정.....
//#define confirmKeyList    @[@"pushEvtRecv",@"pushUseRecv",@"userAppMenuGbn",@"pushTermYn"]
//setUserInfo
@implementation setUserInfo
- (void)run {
    NSMutableArray *failArray = [NSMutableArray array];
    for(NSString *key in self.paramDic.allKeys) {
#ifdef confirmKeyList
        if([confirmKeyList containsObject:key] == NO) { //접근권한체크
            [failArray addObject:key];
            continue;
        }
#endif
        if([[AppInfo userInfo] respondsToSelector:NSSelectorFromString(key)]) {
            [[AppInfo userInfo] setValue:self.paramDic[key] forKey:key];
        } else {
            [failArray addObject:key];
        }
    }
    [self finishedActionWithResult:@{@"fail" : failArray} success:YES];
}
@end

//getUserInfo
@implementation getUserInfo
- (void)run {
    NSArray *allKeys = self.paramDic[@"getList"];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for(NSString *key in allKeys) {
#ifdef confirmKeyList
        if([confirmKeyList containsObject:key] == NO) {//접근권한체크
            continue;
        }
#endif
        if([[AppInfo userInfo] respondsToSelector:NSSelectorFromString(key)]) {
            [result setValue:[[AppInfo userInfo] valueForKey:key] forKey:key];
        }
    }
    [self finishedActionWithResult:result success:YES];
}
@end

//바코드 확대 출력
@implementation showExtendedBarcode
- (void)run {
    NSString *barcode = self.paramDic[@"barcode"];
    if (barcode.length == 0) {
        [self finishedActionWithResult:@{@"errorMessage":@"바코드가 없습니다."} success:NO];
        return;
    }
    
    [AllMenu.delegate navigationWithMenuID:MenuID_PaymentBarcodeZoom animated:NO option:NavigationOptionModal callBack:^(ViewController *vc) {
        ((KCLBarcodeZoomViewController*)vc).codeString = barcode;
    }];
    [self finishedActionWithResult:nil success:YES];
}
@end

//결제취소 바코드 출력
@implementation showPaymentCancelBarcode
- (void)run {
    NSString *validTime = self.paramDic[@"validTime"];
    NSString *barcode = self.paramDic[@"barcode"];

    [KCLPaymentRequestPopupView showPopupWithType:KCLPaymentCancelPopupTypeBarcode
                             barcodeValue:barcode
                               remainTime:validTime.floatValue
                                checkTime:0
                            checkFunction:nil
                             checkWebView:nil
                          dismissCallback:^(KCLPaymentCancelPopupCloseType closeType) {
                              if (closeType == KCLPaymentCancelPopupCloseTypeRecreationButton) {
                                  [self finishedActionWithResult:@{@"errorMessage":@"timeout"} success:NO];
                              } else {
                                  [self finishedActionWithResult:nil success:YES];
                              }
                          }];
}
@end

//Toast 메시지 출력
@implementation showToast
- (void)run {
    NSString *message = self.paramDic[@"message"];
    if (message.length == 0) {
        [self finishedActionWithResult:@{@"errorMessage":@"메시지가 없습니다."} success:NO];
        return;
    }
    
    showSplashMessage(message, YES, NO);
    [self finishedActionWithResult:nil success:YES];
}
@end

//웹뷰 히스토리 쌓기
@implementation addHistoryStack
- (void)run {
    //간편결제 화면에서의 예외처리 - bugFix2 Merge // MDPaymentViewController -> KCLPaymentViewController
    if ([@"KCLPaymentViewController" isEqualToString:NSStringFromClass([(WebViewController *)(self.webView.parentViewController) class])]) {
        [self finishedActionWithResult:nil success:YES];
        return;
    }
    
    // ???? TODO : 확인 요망
    if([self.paramDic isKindOfClass:[NSDictionary class]]) {
        [(WebViewController *)(self.webView.parentViewController) addHistoryStack:self.paramDic];
        [self finishedActionWithResult:nil success:YES];
    } else {
        [self finishedActionWithResult:@{@"errorMessage":[NSString stringWithFormat:@"param = %@",self.paramDic]} success:NO];
    }
}
@end

//웹뷰 히스토리 지우기
@implementation removeHistoryStack
- (void)run {
    NSArray * historyStack = [self getCurrHistoryStack];
    NSInteger cnt = [self.paramDic[@"cnt"] integerValue];
    
    if (historyStack.count < cnt) {
        // overflow 실패 반환
        [self finishedActionWithResult:@{@"resCd":@"1001", @"historyStack" : historyStack} success:NO];
        return;
    }
    
    // 히스토리 스택 삭제
    [(WebViewController *)(self.webView.parentViewController) removeHistoryStack:cnt];
    historyStack = [self getCurrHistoryStack];
        
   [self finishedActionWithResult:@{@"resCd":@"0000", @"historyStack" : historyStack} success:YES];
}

- (NSArray *)getCurrHistoryStack {
    NSArray * retStack = @[];
    
    WebViewController *webVc = (id)self.webView.parentViewController;
    if (webVc.historyStack && webVc.historyStack.count > 0) {
        retStack = webVc.historyStack;
    }
    
    return retStack;
}
@end

//웹뷰 히스토리 스택 지우기
@implementation clearHistoryStack
- (void)run {
    // ???? TODO : 확인 요망
    [(WebViewController *)(self.webView.parentViewController) clearHistoryStack];
    [self finishedActionWithResult:nil success:YES];
}
@end

//로딩화면
@implementation lodingIndicator
- (void)run {
    if([self.paramDic[@"show"] boolValue]) {
        [IndicatorView show];
    } else {
        [IndicatorView hide];
    }
    [self finishedActionWithResult:nil success:YES];
}
@end

//하이브리드 화면이동
@implementation openNewPage        // param : {"screnId" : "KAT_FIPR_001", "openUrl" : "http://", "params" : {key : value},"closeYn" : "Y","externalYn" : "Y"}
- (void)run {
    NSString *clearDomain = self.paramDic[@"clearDomain"];

    if (!nilCheck(clearDomain)) {
        [WKWebsiteDataStore.defaultDataStore fetchDataRecordsOfTypes:WKWebsiteDataStore.allWebsiteDataTypes completionHandler:^(NSArray<WKWebsiteDataRecord *> * records) {
            BOOL isExist = NO;
            for(WKWebsiteDataRecord *record in records){
                if ([clearDomain containsString:record.displayName]) {
                    isExist = YES;
                }
            }
            
            if (isExist) {
                for(WKWebsiteDataRecord *record in records){
                    NSLog(@"record : %@", record);
                    if ([clearDomain containsString:record.displayName]) {
                        [WKWebsiteDataStore.defaultDataStore removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                            //delete callback
                            [self movePage];
                        }];
                    }
                }
            } else {
                [self movePage];
            }
        }];
    } else {
        [self movePage];
    }
}

- (void)movePage {
    NSString *screnId = self.paramDic[@"screnId"];
    NSString *openUrl = self.paramDic[@"openUrl"];
    NSString *externalYn = self.paramDic[@"externalYn"];
    NSString *closeYn = self.paramDic[@"closeYn"];
    if(externalYn.boolValue) {
        NSURL *url = [NSURL URLWithString:openUrl];
        if([AppDelegate canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        
        if(closeYn.boolValue) {
            if(self.webView.isLoading) {
                [IndicatorView hide];
            }
            [self.webView.parentViewController.navigationController popViewControllerAnimated:NO];
        }
        return;
    }
    
    if(openUrl.length) {
        screnId = MenuID_WebViewVC;
    }
    if([screnId isEqualToString:@"KAT_LIBE_059"]) {
        if([AppDelegate canOpenURL:[NSURL URLWithString:HDTV_SCHEME]]) {
            NSString * uri = [NSString stringWithFormat:@"%@",HDTV_SCHEME];
            NSURL *url = [NSURL URLWithString:uri];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:HDTV_NAME@" 앱 설치를 위하여\n스토어로 이동하시겠습니까?" dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:AlertConfirm]) {
                    NSURL *url = [NSURL URLWithString:STORE_LINK(HDTV_STORE_ID)];
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                }
            } cancelButtonTitle:AlertCancel buttonTitles:AlertConfirm, nil];
        }
    } else {
        NavigationOption option = closeYn.boolValue ? NavigationOptionNoneHistoryPush : NavigationOptionPush;
        [AllMenu.delegate navigationWithMenuID:screnId animated:YES option:option callBack:^(ViewController *vc) {
            if(vc) {
                if(option == NavigationOptionNoneHistoryPush && self.webView.isLoading) {
                    [IndicatorView hide];
                }
                if(openUrl.length && [vc respondsToSelector:@selector(setFirstOpenUrl:)]) {
                    ((WebViewController *)vc).firstOpenUrl = openUrl;
                }
                vc.dicParam = self.paramDic[@"params"];
                [self finishedActionWithResult:nil success:YES];
            } else {
                [self finishedActionWithResult:@{@"errorMessage":@"화면이동 실패"} success:NO];
            }
        }];
    }
}
@end

@implementation goMainView        // param : 없음
-(void)run {
    // Indicator Hide - 메인으로 이동시 무조건 Indicator hide시키게 적용
    [IndicatorView hide];
    
    // 메인 화면으로 이동
    [AllMenu.delegate navigationWithMenuID:MenuID_V4_MainPage animated:YES option:NavigationOptionSetRoot callBack:^(ViewController *vc) {
    }];
    
    [[APP_DELEGATE mainViewController] goBasePage]; // 메인화면 재로딩

    if([AppInfo sharedInfo].isLogin) { // 로그인시 포인트 재조회 추가
        [[AppInfo sharedInfo] reloadPoint];
    }
    
    [self finishedActionWithResult:nil success:YES];
}
@end

//클립보드 복사
@implementation copyToClipboard
- (void)run {
    NSString *message = self.paramDic[@"message"];
    if (message.length == 0) {
        [self finishedActionWithResult:@{@"errorMessage":@"메시지가 없습니다."} success:NO];
        return;
    }
    
    // 계좌번호 클립보드에 복사 하기 진행 시 토스트 알림 추가
    NSString *toastYn = [self.paramDic null_valueForKey:@"toastYn"];
    if ([toastYn isEqualToString:@"Y"] ) {
        showSplashMessage(self.paramDic[@"toastMsg"], YES, NO);
    }
    
    [UIPasteboard generalPasteboard].string = message;
    [APP_DELEGATE setBeforePasteMessage:message.hashSHA1];
    [self finishedActionWithResult:nil success:YES];
}
@end

//json객체 보안키패드 공개키 암호화 기능 삭제됨 서버에서 처리
@implementation encJson
- (void)run {
    [self finishedActionWithResult:@{@"result" : [PwdWrapper encryptedDictionary:self.paramDic]} success:YES];
}
@end

@implementation ajaxCall
- (void)run {
    NSString * url = self.paramDic[@"url"];
    NSDictionary * params = self.paramDic[@"params"];
    NSString * trxCd = self.paramDic[@"trxCd"];
    NSString *encYn = self.paramDic[@"isEnc"];
    BOOL isEnc = encYn.boolValue;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (NSString * key in params) {
        
        if ([params[key] isKindOfClass:[NSNumber class]]) {
            [dict setObject:[(NSNumber*)params[key] stringValue] forKey:key];
        } else {
            [dict setObject:params[key] forKey:key];
        }
    }
    
    [Request requestID:url message:nil body:dict waitUntilDone:YES showLoading:YES cancelOwn:self isJsCallback:YES isEnc:isEnc trxCd:trxCd finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
        
        if ((rsltCode.integerValue / 100 * 100) == 200) {
            // 2xx번대 성공
             [self finishedActionWithResult:result success:YES];
        } else {
            [self finishedActionWithResult:@{@"statusCd": rsltCode} success:NO];
        }
    }];
}
@end

#pragma mark - V3 인터페이스 
/**
@var requestAddressMultiMobileWeb
@brief 해외여행자보험가입용 전화번호부 전달
@param maxCount : 선택 최대 인원 수 (param : maxCount - 최대선택가능 인원수)
@return 선택된 연락처 인원 ({@"contactsList" : [ {"name":이름, "phone":전화번호}, ...] }))
*/
@implementation requestAddressMultiMobileWeb
- (void)run {
    NSInteger maxCount = [[self.paramDic objectForKey:@"maxCount"] integerValue];
    NSLog(@"Native maxCount = %i", (int)maxCount);
    
    // To Do : 멀티 전화 번호부
    [[[requestAddressBook4MobileWeb alloc] init] runWithParam:@{@"mCount" : @(maxCount) , @"isMemberOnly" : @"N"} callback:^(NSDictionary *result, BOOL success) {
         [self finishedActionWithResult:result success:YES];
    }];
}
@end

/**
@var requestBarcodeCardList
@brief CardList 데이터 전달 (원패쓰)
@return myCardList 카드 리스트
*/
@implementation requestBarcodeCardList
- (void)run {
    NSMutableArray* myCardList = [[NSMutableArray alloc] init];
    if(self.webView.parentViewController.class == [KCLPaymentViewController class]) {
        KCLPaymentViewController *paymentVc = (id)self.webView.parentViewController;
        myCardList = [paymentVc getMyCardList];
    }
    
    NSLog(@"myCardList == %@", myCardList);
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         myCardList.count > 0 ? myCardList : @[], @"myCardList", nil];
    
    [self finishedActionWithResult:dic success:YES];
}
@end

/**
@var requestOSPushState
@brief Push 상태값 (OS Push)
@return push 설정 값  ("pushYn" : "Y" - 푸쉬설정 , "N" - 푸쉬미설정)
*/
@implementation requestOSPushState
- (void)run {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            
            NSString *pushYn = @"N";
            
            if ([settings notificationCenterSetting] == UNNotificationSettingEnabled) {
                    pushYn = @"Y";
            }
             
            NSDictionary *dic = [self resultDic:pushYn];
             
            [self finishedActionWithResult:dic success:YES];
        }];
}

- (NSDictionary *)resultDic: (NSString *)pushYn {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
    pushYn, @"pushYn", nil];
    
    return dic;
}
@end

/**
@var requestUUID
@brief UUID 값 전달 (신규 KB Open API용)
@return UUID
*/
@implementation requestUUID                           // param : {}
- (void)run {
    NSString *uuid = [AppInfo sharedInfo].UUID;
    
    if(uuid == nil) {
        uuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                           uuid, @"UUID", nil];
    
    [self finishedActionWithResult:dic success:YES];
}
@end

/**
@var requestBuzzvilFeed
@brief 버즈빌 (버즈빌 Feed호출)
@param param : title 명
*/
@implementation requestBuzzvilFeed                   // param : {"title" : "타이틀"}
- (void)run {
    // To DO : 버즈빌 Feed
    NSString *title = [self.paramDic objectForKey:@"title"];

    BABFeedConfig *config = [[BABFeedConfig alloc] initWithUnitId:BUZZ_FEED_UNIT_ID];
    config.title = title;
    config.articlesEnabled = NO;
    config.autoLoadingEnabled = YES;
    config.shouldShowAppTrackingTransparencyDialog = YES;
    config.tabUiEnabled = YES;
    config.filterUiEnabled = YES;
    config.adViewHolderClass = [CustomAdViewHolder class];

    BABFeedHandler *feedHandler = [[BABFeedHandler alloc] initWithConfig:config];
    [(UIViewController *)[AllMenu delegate] presentViewController:[feedHandler populateViewController] animated:YES completion:nil];
        [self finishedActionWithResult:nil success:YES];
}
@end

/**
@var requestGA360SendData
@brief GA360 (신규 GA360)
@param param : param : GA360 가이드 데이터 (JSon)  parameters =     { "&_crc" = 0; "&_s" = 2389; "&_u" = ".oKKKKKKKKKKKKKKKKKKKKKoKKKKKKKKKKKKKyBL"; "&_v" = "mi3.1.7";  "&a" = 1787718835;  "&aid" = "com.kbcard.kat.liivmate";  "&an" = LiivMate;  "&ate" = 1; "&av" = "3.0.0"; "&cd" = "\Ud558\Ub2e8 \Ud0ed\Ubc14"; "&cd1" = ccc5a0374f148b85dbbea483bd7fc9da7eb10447f67299b11289844a008d0a8f; "&cd10" = "<null>"; "&cd11" = "<null>"; "&cd12" = "<null>";  "&cd13" = "<null>"; "&cd14" = MDMainTabbarViewController; "&cd15" = "\Ud558\Ub2e8 \Ud0ed\Ubc14";  "&cd16" = "<null>";  "&cd17" = "<null>"; "&cd18" = "<null>";  "&cd19" = "7DC39E14-58DB-4543-BAEF-00C2C2A54CFD";  "&cd2" = 4f188825a2765cf4bb2b0a08e46639dcfd9c9f70708b3eca61ebdb3caca9509f; "&cd3" = 1;  "&cd4" = 20;  "&cd5" = 40;  "&cd6" = 1;  "&cd7" = "<null>";  "&cd8" = 1;  "&cd9" = "<null>";  "&cid" = "21844ab1-ce2c-4d02-ad90-a31c6af204b4";  "&dm" = "iPhone8,1";  "&ds" = app; "&ea" = "\Ubc84\Ud2bc"; "&ec" = "<null>"; "&el" = "\Ud558\Ub2e8 \Ud0ed\Ubc14"; "&ev" = "<null>"; "&idfa" = "7DC39E14-58DB-4543-BAEF-00C2C2A54CFD"; "&sr" = 750x1334; "&t" = event;  "&tid" = "UA-65962490-15";  "&uid" = ccc5a0374f148b85dbbea483bd7fc9da7eb10447f67299b11289844a008d0a8f; "&ul" = "ko-kr";  "&v" = 1;  "&z" = 11898805510720697418;  gaiVersion = "3.17"; }; timestamp = "2020-07-20 06:21:22 +0000";}
*/
@implementation requestGA360SendData : MobileWeb                 // param : GA360 가이드 데이터 (JSon)
- (void)run {
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    if([self.webView.parentViewController isKindOfClass:[WebViewController class]]) {
        [WebViewController sendGa360:self.paramDic];
        [result setValue:@"success" forKey:@"result"];
        [self finishedActionWithResult:result success:YES];
    } else {
        [result setValue:@"fail" forKey:@"result"];
        [self finishedActionWithResult:result success:NO];
    }
}
@end

/**
@var clearInterHistoryStack
@brief 인터널 푸시로 더해진 스택을 모두 지우고 최상위 뷰컨트롤러로 이동한다.
@param url : 이동 url 또는 스크린 ID
*/
@implementation clearInterHistoryStack : MobileWeb            //  param : "screnId" : "MYD_APP_MAIN"(앱 메인 MYD_MA0100 -> MYD_APP_MAIN) / "screenId" : "MYD_FI0100"(통합조회)
- (void)run {
    NSString *urlStr = [self.paramDic valueForKey:@"url"];
    
    UINavigationController *nvc =  [[self.webView parentViewController] navigationController];
            
    UIViewController *tempVc1;
    WebViewController *tempVc2;
    
    for(int i=0; i < nvc.viewControllers.count;i++) {
        UIViewController *cvc = nvc.viewControllers[i];
        if(i == 0 ) {
            tempVc1 = cvc;
        } else if(i == 1) {
            tempVc2 = (WebViewController*)cvc;
        }
    }
    [nvc setViewControllers:@[tempVc1,tempVc2]];
    [tempVc2 clearHistoryStack];
    WVRequest *rq = [WVRequest requestWithURL:[NSURL URLWithString:urlStr]];

    [tempVc2.webView webViewLoadRequest:rq];
}
@end

@implementation requestSelectCard : MobileWeb
- (void)run {
    if(self.webView.parentViewController.class == [KCLPaymentViewController class]) {
        KCLPaymentViewController *paymentVc = (id)self.webView.parentViewController;
        [paymentVc selectCardInfo:self.paramDic[@"selectCard"]];
        [self finishedActionWithResult:nil success:YES];
    } else {
        [self finishedActionWithResult:nil success:NO];
    }
}
@end

@interface sendKakaoTalkLink() {
    NSString *title;
    NSString *imgUrl;
    NSString *btnUrl;
}
@end

/**
@var sendKakaoTalkLink
@brief 카카오 링크
@param title: 타이틀, imgUrl: 이미지 URL, page: 페이지 URL
*/
@implementation sendKakaoTalkLink : MobileWeb
- (void)run {
    title = [self.paramDic objectForKey:@"title"];
    imgUrl = [self.paramDic objectForKey:@"imgUrl"];
    btnUrl = [self.paramDic objectForKey:@"page"];
    
    if ( [AppDelegate canOpenURL:[NSURL URLWithString:@"kakaolink://"]] ) {
        // Feed 타입 템플릿 오브젝트 생성
        KMTTemplate *template = [KMTFeedTemplate feedTemplateWithBuilderBlock:^(KMTFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {
            
            // 컨텐츠
            feedTemplateBuilder.content = [KMTContentObject contentObjectWithBuilderBlock:^(KMTContentBuilder * _Nonnull contentBuilder) {
                contentBuilder.title = self->title;
                contentBuilder.desc = @"";
                contentBuilder.imageURL = [NSURL URLWithString:self->imgUrl];
                contentBuilder.imageWidth = [NSNumber numberWithInt:576];
                contentBuilder.imageHeight = [NSNumber numberWithInt:310];
                contentBuilder.link = [KMTLinkObject linkObjectWithBuilderBlock:^(KMTLinkBuilder * _Nonnull linkBuilder) {
                }];
            }];
            
            [feedTemplateBuilder addButton:[KMTButtonObject buttonObjectWithBuilderBlock:^(KMTButtonBuilder * _Nonnull buttonBuilder) {
                buttonBuilder.title = @"앱에서 자세히 보기";
                buttonBuilder.link = [KMTLinkObject linkObjectWithBuilderBlock:^(KMTLinkBuilder * _Nonnull linkBuilder) {
                    NSString *params = [NSString stringWithFormat:@"param=%@", self->btnUrl];
                    linkBuilder.iosExecutionParams = params;
                    linkBuilder.androidExecutionParams = params;
                }];
            }]];
        }];
        
        // 카카오링크 실행
        [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
            NSLog(@"warning message: %@", warningMsg);
            NSLog(@"argument message: %@", argumentMsg);
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"error: %@", error);
        }];
        [self finishedActionWithResult:nil success:YES];
    } else { // 앱스토어 이동
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"] options:@{} completionHandler:nil];
        [self finishedActionWithResult:nil success:NO];
    }
}
@end

#pragma mark - V4 인터페이스
/**
@var requestRaonKeyPadV4
@brief OpenAPI 라온키패드
@param "title":"공동인증서 비밀번호를 입력해주세요.", "subject":"cn=김응엽()001104520110111111001963,ou=NACF,ou=personal4IB,o=yessign,c=kr", "expiryDate":"20201-05-17 22:59:59", "caOrg": "yessign",
 "myDataSignInfoList": [{
    "ucpidAgreeInfo" : {"ucpidNonce": "bgY0bSvBsYFUFIFxe1dvGg==", "userAgreement":"인증서 기반 본인확인서비스는 인증기관(한국정보인증, 금융결제원, 한국무역정보통신, 한국증권전산, 한국전자인증)에 저장된 가입자 정보를 본인확인을\n", "userAgerrInfo":{"realame":true, "gender":false, "nationalInfo":false, "birthDate":true, "CI":true}, "ispUrlInfo":"www.ispurl.com", "orgCode": "A1AAEM000"},
 "consentInfo" : {"consentNonce":"bgY0bSvBsYFUFIFxe1dvGg==", "consent": {계좌정보, 송금내역}}
 }]
*/
@implementation requestRaonKeyPadV4 : MobileWeb
- (void)run {
    NSLog(@"%s, paramDic == %@" , __FUNCTION__, self.paramDic); // 업무단(web)에서 넘어오는 값을 확인하기 위한 로그
    
    [[KCLStandardOpenAPI sharedInstance] startOpenApiSinged:self.paramDic completion:^(NSDictionary * _Nonnull result, BOOL isSuccess) {
            [self finishedActionWithResult:result success:isSuccess];
    }];
}
@end

/**
@var requestPopUpWebView
@brief Popup webView 화면(modal view)
@param url:  URL,  title: 타이틀명
 */
@implementation requestPopUpWebView : MobileWeb
- (void)run {
    NSLog(@"%s  param == %@", __FUNCTION__, self.paramDic);
    
    KCLPopupViewController *popUp = [[UIStoryboard storyboardWithName:@"KCLMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"KCLPopupViewController"];
    
    //param 으로 넘어온 데이터를 팝업뷰에 넘겨준다
    popUp.menuItem = self.paramDic;
    popUp.modalPresentationStyle = UIModalPresentationFullScreen;
    [(UIViewController*)[AllMenu delegate] presentViewController:popUp animated:YES completion:nil];
    
    [self finishedActionWithResult:nil success:YES];
}
@end

/**
@var requestInstalledAppScheme
@brief Open API 개별인증을 위한 App  설치 유/무
@param scheme:  App scheme
 */
@implementation requestInstalledAppScheme : MobileWeb
- (void)run {
    NSLog(@"%s  param == %@", __FUNCTION__, self.paramDic);
    
    NSString *appScheme = [self.paramDic objectForKey:@"scheme"];
    NSString *installed = @"N";
    
    if ( [AppDelegate canOpenURL:[NSURL URLWithString:appScheme]] ) {
        installed = @"Y";
    }
    
    NSDictionary *installedYnDic = @{@"installedYn" : installed};

    [self finishedActionWithResult:installedYnDic success:YES];
}
@end
