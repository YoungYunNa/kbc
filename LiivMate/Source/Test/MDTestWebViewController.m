//
//  MDTestWebViewController.m
//  LiivMate
//
//  Created by KB on 2021/05/12.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "MDTestWebViewController.h"
#import <WebKit/WebKit.h>

@interface MDTestWebViewController () <WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation MDTestWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://dm.liivmate.com/katsv4/DesignPublishing/WEB-INF/index_app.html"]];
    [_webView loadRequest:request];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)didTouchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WKNavigationDelegate
-(void)webView:(WKWebView*)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"2.didFinishNavigation");
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"2. didFinishNavigtaion");
}

-(void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error {
    NSLog(@"3.didFailNavigation");
}

@end
