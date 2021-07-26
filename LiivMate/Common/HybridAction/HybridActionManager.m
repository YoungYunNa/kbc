//
//  HybridActionManager.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 22..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "HybridActionManager.h"
#import "WebViewController.h"
#import "MobileWeb.h"

@implementation HybridActionManager
static NSMutableArray *actionPool = nil;
//liivmate://call?cmd=external&name=MobileWeb.setTopMenu&successCallback=&failCallback=failCall&params=%7B%22preBt%22:%22Y%22,%22menuBt%22:%22Y%22,%22title%22:%22Call%20Test%22,%22target%22:%22http://m.naver.com%22,%22preAction%22:%22B%22%7D

//liivmate://call?cmd=a2a&name=setPaymentType&return=catcrush://liivmate&params={"key":"value"}
//catcrush://liivmate?success=Y&result={"key":"value"}

+(BOOL)registActionWithWebView:(id<WebView>)webView request:(NSURLRequest*)request
{
	TXLog(@"%@",request.URL.absoluteString.stringByUrlDecoding);
	NSString *hostNm = request.URL.host;
    
    if([request.URL.scheme isEqualToString:Scheme_Action])
	{
		if([hostNm isEqualToString:@"call"])
		{
			NSDictionary *params = [EtcUtil parseUrl:request.URL.query];
			
			NSString *cmd = [params objectForKey:@"cmd"];
			if( [cmd isEqualToString:@"external"] )
			{
				NSString *name = [params objectForKey:@"name"];
				NSString *paramsStr = [params objectForKey:@"params"];
				NSString *failCallback = [params objectForKey:@"failCallback"];
				NSDictionary *paramDic = nil;
				if( paramsStr )
				{
					// ???? for test
					/*
					{
						paramsStr = [paramsStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
						paramsStr = [paramsStr stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
						paramsStr = [paramsStr stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
					}
					*/
                    
                    NSLog(@"paramsStr : %@", paramsStr);
                    NSLog(@"paramsStr.stringByUrlDecoding : %@", paramsStr.stringByUrlDecoding);
                    NSLog(@"jsonObject : %@", paramsStr.stringByUrlDecoding.jsonObject );

					paramDic = paramsStr.jsonObject;
				}
				NSArray *separArr = [name componentsSeparatedByString:@"."];
				NSString *className = [separArr firstObject];
				NSString *methodName = [separArr lastObject];
				
				MobileWeb *action = [[NSClassFromString(methodName) alloc] init];
				if([action isKindOfClass:[MobileWeb class]] && [separArr count] == 2)
				{
					action.webView = (id)webView;
					action.tag = request.URL.port;
					action.paramDic = paramDic;
					action.successCallback = [params objectForKey:@"successCallback"];
					action.failCallback = failCallback;
					
					[self regestAction:action];
					@try {
						[action run];
					} @catch (NSException *exception) {
						[self finishedAction:action];
						if([webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:completionHandler:)])
							[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@();",failCallback] completionHandler:nil];
					}
				}
				else
				{
                    // 구현된 액션이 없을경우에 콜백처리
                    NSDictionary * result = @{@"resCd": mobWeb_not_action};
                    NSString *argumentsStr = (result ? result.jsonString : @"");
                    NSString *script = [NSString stringWithFormat:@"%@(%@);",failCallback,argumentsStr];
                    
                    if([webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:completionHandler:)])
                        [webView stringByEvaluatingJavaScriptFromString:script completionHandler:nil];

#ifdef DEBUG
					TXLog(@"======================액션없음[%@.%@]==================",className,methodName);
//                    [BlockAlertView showBlockAlertWithTitle:@"액션 구현안됨" message:request.URL.absoluteString dismisTitle:@"확인"];
#endif
					//[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@();",failCallback]];
				}
			}
			else if( [cmd isEqualToString:@"method"] )
			{
				
			}
		}
		return YES;
	}
	else if([request.URL.scheme isEqualToString:Scheme_TablePay])
	{
		if([hostNm isEqualToString:@"tablepay"] ) {
			
			NSDictionary *paramDic = [EtcUtil parseUrlWithoutDecoding:request.URL.query];
			
			MobileWeb *action = [[NSClassFromString(hostNm) alloc] init];
			action.webView = (id)webView;
			action.tag = request.URL.port;
			action.paramDic = paramDic;
			
			[self regestAction:action];
			@try {
				[action run];
			} @catch (NSException *exception) {
				[self finishedAction:action];
			}
		}
		return YES;
	}
    return NO;
}

+(void)cancelActionWithWebView:(id<WebView>)webView
{
    // 리브메이트 2.0 Merge (로그인->백그라운드->세션만료후(10분후)->포그라운드시 간헐적으로 죽는 현상 발생
//    dispatch_async(dispatch_get_main_queue(), ^{
        for( NSInteger i=[actionPool count]-1; i>=0; i--)
        {
            MobileWeb * action = actionPool[i];
            if(action.webView == webView)
            {
                [action cancel];
            }
        }
//    });
}

+(void)cancelAllAction
{
    NSLog(@"count ViewController : %d",(int)[actionPool count]);
    for( NSInteger i=[actionPool count]-1; i>=0; i--)
    {
        MobileWeb * action = actionPool[i];
        [action cancel];
    }
}

+(void)regestAction:(MobileWeb*)action
{
	if(actionPool == nil)
		actionPool = [[NSMutableArray alloc] init];
	[actionPool addObject:action];
}

+(void)finishedAction:(MobileWeb*)action
{
    [actionPool removeObject:action];
	if([action respondsToSelector:@selector(setWebView:)])
		[action setWebView:nil];
}

@end



