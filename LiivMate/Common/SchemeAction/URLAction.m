//
//  URLAction.m
//  LiivMate
//
//  Created by kbcard on 2018. 11. 9..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "URLAction.h"
#import "MobileWeb.h"
//#import "PaymentViewController.h"

@implementation NSURL (URLAction)
-(BOOL)runAction
{
	if([self.scheme isEqualToString:Scheme_Action] == NO && [self.scheme rangeOfString:@"kakao"].location == NSNotFound && [self.scheme isEqualToString:Scheme_TablePay] == NO)
		return NO;
	
	TXLog(@"SchemeAction ==> %@",self);
	//CASE 1 host명으로 구분되어지는 케이스
	NSString *classNm = [NSString stringWithFormat:@"Action_%@",self.host];
	Class actionClass = NSClassFromString(classNm);
	if([actionClass respondsToSelector:@selector(runWithUrl:)])
	{
		[actionClass runWithUrl:self];
		return YES;
	}
	return NO;
}
@end

@implementation BaseURLAction
+(void)runWithUrl:(NSURL*)url
{
	
}
@end

@implementation Action_call
+(void)runWithUrl:(NSURL*)url
{
	//CASE 2 host명 + cmd명으로 구분되는 케이스 ==> URLAction+Call.h
	//@"liivmate://call?cmd=move_to&id=KAT_JOIN_001&params={key:value,...}"
	NSDictionary *params = [EtcUtil parseUrl:url.query];
	NSString *cmd = [params objectForKey:@"cmd"];
	NSString *classNm = [NSString stringWithFormat:@"%@_%@",NSStringFromClass(self),cmd];
	Class actionClass = NSClassFromString(classNm);
	if([actionClass respondsToSelector:@selector(runWithUrl:)])
	{
		[actionClass runWithUrl:url];
	}
}
@end

@implementation Action_event
+(void)runWithUrl:(NSURL*)url
{
	// LMS/MMS 통해서 scheme url(= liivmate://event?param=url) 호출시, event url 진입
	//NSDictionary *params = [EtcUtil parseUrl:url.query];
	//NSString *param = [params objectForKey:@"param"];
	NSArray *strArr = [url.absoluteString componentsSeparatedByString:@"event?param="];
	NSString *pageID = strArr.lastObject;
	if(pageID.length != 0 && strArr.count >= 2) {
		[[AllMenu delegate] sendBirdDetailPage:pageID callBack:^(ViewController *vc) {
			if([pageID rangeOfString:@"?"].location != NSNotFound)
			{//v2 POST파라미터 적용
				NSString *query = [pageID componentsSeparatedByString:@"?"].lastObject;
				vc.dicParam = [EtcUtil parseUrl:query];
			}
		}];
	}
}
@end

@implementation Action_appid
+(void)runWithUrl:(NSURL*)url
{
	// KB은행쪽에서 scheme url(= liivmate://appid?param=APP_???????) 호출시, 특정 화면 진입
	//liivmate://appid?param=https://dm.liivmate.com/katsv2/liivmate/v2/finacPrdct/lfMgzn/lfMgznDtail.do?intnlCgryDstcd=01&newMgtNo=20180730185237434540
	//NSDictionary *params = [EtcUtil parseUrl:url.query];
	NSArray *strArr = [url.absoluteString componentsSeparatedByString:@"appid?param="];
	NSString *pageID = strArr.lastObject;
	if(pageID.length != 0 && strArr.count >= 2) {
		if ([pageID rangeOfString:@"selectQuizDetail.do" options:NSCaseInsensitiveSearch].location != NSNotFound ) { // 시사/경제 퀴즈
			[[AllMenu delegate] checkLoginBlock:^{
				[[AllMenu delegate] sendBirdDetailPage:pageID callBack:^(ViewController *vc) {
					if([pageID rangeOfString:@"?"].location != NSNotFound)
					{//v2 POST파라미터 적용
						//NSString *query = [param componentsSeparatedByString:@"?"].lastObject;
						//vc.dicParam = [EtcUtil parseUrl:query];
					}
				}];
			}];
		} else {
			[[AllMenu delegate] sendBirdDetailPage:pageID callBack:^(ViewController *vc) {
				if([pageID rangeOfString:@"?"].location != NSNotFound)
				{//v2 POST파라미터 적용
					NSString *query = [pageID componentsSeparatedByString:@"?"].lastObject;
					vc.dicParam = [EtcUtil parseUrl:query];
				}
			}];
		}
	}
}
@end

@implementation Action_webview
+(void)runWithUrl:(NSURL*)url {
	NSLog(@"url.query %@", url.query);
	NSDictionary *params = [EtcUtil parseUrl:url.query];
	NSString *urlStr = [[params objectForKey:@"url"] stringByUrlDecoding];
	NSString * loginYN = [params objectForKey:@"loginYN"];
	NSMutableDictionary * postParam = nil;
	
	if (params[@"params"]) {
		postParam = [[NSMutableDictionary alloc] init];
		NSDictionary * tempParam = [[params[@"params"] stringByUrlDecoding] jsonObject];
		
		for (NSString * key in tempParam) {
			NSString * value = tempParam[key];
			
			NSLog(@"value : %@", value);
			NSLog(@"value.stringByUrlEncoding : %@", value.stringByUrlEncoding);
            
			[postParam setObject:value.stringByUrlEncoding forKey:key];
		}
	}
	
	if(urlStr.length != 0) {
		if([@"Y" isEqualToString:loginYN]) {
			[[AllMenu delegate] checkLoginBlock:^{
				[[AllMenu delegate] sendBirdDetailPage:urlStr callBack:^(ViewController *vc) {
					if([vc isKindOfClass:[WebViewController class]]) {
						((WebViewController*)vc).passEncoding = YES;
						((WebViewController*)vc).dicParam = postParam;
					}
				}];
			}];
		}
		else {
			[[AllMenu delegate] sendBirdDetailPage:urlStr callBack:^(ViewController *vc) {
				if([vc isKindOfClass:[WebViewController class]]) {
					((WebViewController*)vc).passEncoding = YES;
					((WebViewController*)vc).dicParam = postParam;
				}
			}];
		}
	}
}
@end

@implementation Action_kakaolink
+(void)runWithUrl:(NSURL*)url
{
	// 카카오 링크
	//kakao4d7c13c769ed2d0c29cc9358088e93d7://kakaolink?param=https://dm.liivmate.com/katsv2/liivmate/v2/finacPrdct/lfMgzn/lfMgznDtail.do?intnlCgryDstcd=01&newsMgtNo=20180730180827004720
	//NSDictionary *params = [EtcUtil parseUrl:url.query];
	//NSString *param = [params objectForKey:@"param"];
	NSArray *strArr = [url.absoluteString componentsSeparatedByString:@"kakaolink?param="];
	NSString *pageID = strArr.lastObject;
	if(pageID.length != 0 && [pageID hasPrefix:@"http"] && strArr.count >= 2) {
		if ([pageID rangeOfString:@"selectQuizDetail.do" options:NSCaseInsensitiveSearch].location != NSNotFound
            || [pageID.lowercaseString containsString:@"loginyn=y"]) { // 시사/경제 퀴즈 || 로그인 필수 파라메타가 있거나
			[[AllMenu delegate] checkLoginBlock:^{
				[[AllMenu delegate] sendBirdDetailPage:pageID callBack:^(ViewController *vc) {
					if([pageID rangeOfString:@"?"].location != NSNotFound)
					{//v2 POST파라미터 적용
						//NSString *query = [param componentsSeparatedByString:@"?"].lastObject;
						//vc.dicParam = [EtcUtil parseUrl:query];
					}
				}];
			}];
		} else {
			[[AllMenu delegate] sendBirdDetailPage:pageID callBack:^(ViewController *vc) {
				if([pageID rangeOfString:@"?"].location != NSNotFound)
				{//v2 POST파라미터 적용
					NSString *query = [pageID componentsSeparatedByString:@"?"].lastObject;
					vc.dicParam = [EtcUtil parseUrl:query];
				}
			}];
		}
	}
	else if(pageID.length && strArr.count >= 2)
	{//카카오톡 공유하기로 쿠폰Id만 들어올경우,.
		[[AllMenu delegate] sendBirdDetailPage:pageID callBack:^(ViewController *vc) {
			if([pageID rangeOfString:@"?"].location != NSNotFound)
			{//v2 POST파라미터 적용
				NSString *query = [pageID componentsSeparatedByString:@"?"].lastObject;
				vc.dicParam = [EtcUtil parseUrl:query];
			}
		}];
	}
}
@end

@implementation Action_QR
+(void)runWithUrl:(NSURL*)url
{
	[AllMenu.delegate checkLoginBlock:^(void) {
		
		if(AppInfo.sharedInfo.isLogin == NO) return;
		
		NSString *type = [EtcUtil parseUrlWithoutDecoding:url.query][@"type"];
		NSDictionary *qrInfo = @{@"result" : url.absoluteString};
		NSString *menuId = nil;
		PerformCallback callback = nil;
		
		//M - 마이QR, P - 간편결제 가맹점QR, C - 결제취소QR >>>> 현재 구현되어있는 타입임 해당타입은 서버에서 생성됨
		if([type isEqualToString:@"M"])
		{//보내기 화면이동 liivmate://QR?type=M&code=20181108152614004804 - 마이페이지 > 보내기(≈≈) successQrCode({"result":"liivmate://QR?type=M&code=20181108152614004804"});
			menuId = @"KAT_PONT_003";
			callback = ^(ViewController *vc) {
				if([vc isKindOfClass:[WebViewController class]])
				{
					//해당화면에 스크립트가 존재해야함 현재 구현되어있는 스크립트 사용-변경될수도 있음
					[((WebViewController*)vc).webView
					 stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"successQrCode(%@);",qrInfo.jsonString]
					 completionHandler:nil];
				}
			};
		}
		else if([type isEqualToString:@"P"])
		{//간편결제 QR화면이동 liivmate://QR?type=P&code=20181108153313004806 - 가맹점QR결제 > 간편결제(MenuID_SimplePaymentQR)  [self requestQRCodeInfo:@"liivmate://QR?type=P&code=20181108153313004806"];
		}
#if 0	//결제취소는 해당 스크립트를 실행하는순간 결제취소 요청이 들어가며 별도의 핀번호 인증이 없어서 해당기는은 제외
		else if([type isEqualToString:@"C"])
		{//결제취소화면 가맹점만 liivmate://QR?type=C&code=20181108153921004807 - 결제취소 > 가맹점 결제취소(MenuID_ShopHome) succeQrScan({"result":"liivmate://QR?type=C&code=20181108153921004807"});
			//(pUser,mOwnr,mMng,mEmp)
			if([[AppInfo userInfo].userAppMenuGbn isEqualToString:ShopMember_mOwnr]
			   || [[AppInfo userInfo].userAppMenuGbn isEqualToString:ShopMember_mMng]
			   || [[AppInfo userInfo].userAppMenuGbn isEqualToString:ShopMember_mEmp])
			{
				menuId = MenuID_ShopHome;
				callback = ^(ViewController *vc) {
					if([vc isKindOfClass:[WebViewController class]])
					{
						//해당화면에 스크립트가 존재해야함 현재 구현되어있는 스크립트 사용-변경될수도 있음
						[((WebViewController*)vc).webView
						 stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"succeQrScan(%@);",qrInfo.jsonString]
						 completionHandler:nil];
					}
				};
			}
		}
#endif
		if(menuId)
		{
			[[AllMenu delegate] navigationWithMenuID:menuId
											animated:YES
											  option:(NavigationOptionPush)
											callBack:^(ViewController *vc) {
												vc.performCallback = callback;
											}];
		}
	}];
}
@end
