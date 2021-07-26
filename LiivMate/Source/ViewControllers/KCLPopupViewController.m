//
//  KCLPopupViewController.m
//  LiivMate
//
//  Created by KB on 2021/05/20.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLPopupViewController.h"

@interface KCLPopupViewController ()

@end

@implementation KCLPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //url 로 이동
    NSString *urlStr = [self.menuItem null_objectForKey:@"url"];
    NSLog(@"urlStr %@",urlStr);

    // url 값이 nil 일때 예외 처리추가
    if (urlStr == nil) {
        urlStr = [self.menuItem objectForKey:K_URL_ADDR];
        NSLog(@"key K_URL_ADDR == %@",urlStr);
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.webView webViewLoadRequest:(request)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.customNavigationBar setCloseBtn:@"Y" action:@"C"];    // PopupView close 버튼 공통으로 사용
    
    NSString *title = [self.menuItem null_objectForKey:@"title"];
    if (nil2Str(title)) {
        [self.customNavigationBar setTitle:title];  // 타이틀 설정
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
