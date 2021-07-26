//
//  HybridActionManager.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 22..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HybridWebView.h"
#import "HybridWKWebView.h"

#define Hybrid_Result_Success		@"0000"
#define Hybrid_Result_Error			@"9999"

#define KeyName_CallBack			@"callBack"
#define KeyName_ActionNm			@"actionNm"
#define KeyName_Tag					@"tag"
#define KeyName_ResultCode			@"resultCode"

@interface HybridActionManager : NSObject
+(BOOL)registActionWithWebView:(id<WebView>)webView request:(NSURLRequest*)request;
+(void)cancelActionWithWebView:(id<WebView>)webView;
+(void)finishedAction:(id)action;
+(void)regestAction:(id)action;
+(void)cancelAllAction;
@end
