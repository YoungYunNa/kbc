//
//  KCLChatBotViewController.h
//  LiivMate
//
//  Created by KB on 4/20/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLChatBotViewController
@date 2021.04.20
@brief 챗봇
*/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KCLChatBotViewController : UIViewController<WKUIDelegate,WKNavigationDelegate, UITextFieldDelegate>

@property(nonatomic,strong)IBOutlet WKWebView *webView; // 챗봇 웹뷰

@end

NS_ASSUME_NONNULL_END
