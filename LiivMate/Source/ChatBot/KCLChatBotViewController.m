//
//  KCLChatBotViewController.m
//  LiivMate
//
//  Created by KB on 4/20/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLChatBotViewController.h"

#import <UserNotifications/UserNotifications.h>

@interface KCLChatBotViewController ()

@property (weak, nonatomic) IBOutlet UITextField *intputUrl;

@end

@implementation KCLChatBotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

    self.webView.UIDelegate = self;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://dm.liivmate.com/uaasv3/sample3.do"]]];
    
    BOOL noti = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];

    BOOL isPush = [[[UIApplication sharedApplication] currentUserNotificationSettings] isAccessibilityElement];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {

        NSLog(@"UNAuthorizationStatus status == %@", settings);
        
        if ([settings notificationCenterSetting] == UNNotificationSettingEnabled) {
            NSLog(@"UNAuthorizationStatus UNNotificationSettingEnabled");
        }
        else if ([settings notificationCenterSetting] == UNNotificationSettingDisabled) {
            NSLog(@"UNAuthorizationStatus UNNotificationSettingDisabled");
        }
        else {
            NSLog(@"UNAuthorizationStatus UNNotificationSettingNotSupported");
        }
    }];
    
    NSLog(@"noti == %i", noti);
    NSLog(@"isPush == %i", isPush);
}

-(void)webViewFirstResponder{
    [self.webView becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textField == %@ ", textField.text);
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:textField.text]]];
    
    return YES;
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
