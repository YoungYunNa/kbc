//
//  HybridWKWebView.h
//  LiivMate
//
//  Created by kbcard on 2018. 5. 23..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HybridWebView.h"
#import <WebKit/WebKit.h>

@interface HybridWKWebView : WKWebView <WebView>
@property (nonatomic, unsafe_unretained) id webViewDelegate;
@property (nonatomic) BOOL scalesPageToFit;
@property (nonatomic, assign) BOOL KLUMode;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign) BOOL parentNotice;
@property (nonatomic, strong) NSString *javascriptAlertResultYn;
@property (nonatomic, strong) WKWebView * wkWebviewPop;
@end
