//
//  AppDelegate.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 18..
//  Copyright © 2016년 KBCard. All rights reserved.
//  중금리대출 커밋 테스트

#import <UIKit/UIKit.h>
#import "KCLAppMainNavigationController.h"
#import "KCLMainViewController.h"
//#import <Google/Analytics.h> Goo
#import "GAI.h"
//#import
#ifndef DEBUG
//주요 함수명 난독화
#define checkPureAppStart				jsjmlew
#define pureAppSuccess					jomsmow
#define mateApplicationStartService		sdlfjje
#define startLiivmateApplication		jfeijsm
#endif

void showSplashMessage(NSString *msg, BOOL autoHide, BOOL showTop);

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) KCLAppMainNavigationController *appMainNavigationController;

@property (strong, nonatomic) UILabel *devPageInfoLabel;

@property (strong, nonatomic) KCLMainViewController *mainViewController;

@property (nonatomic, strong) UIView *splashView;
@property (nonatomic, strong) UIView *statusBarView;
@property (nonatomic, assign) BOOL isSplashViewShow;
@property (nonatomic) NSString *beforePasteMessage;
@property (nonatomic, strong) NSString * server;

@property (nonatomic, assign) BOOL bUseNewLiveMate;
@property (nonatomic, assign) BOOL backgoundTaskId;

-(void)processesDoKill:(NSString*)message;
-(BOOL)showRemoteNotificationPopup:(NSDictionary *)userInfo;
-(BOOL)schemeActionWithURL:(NSURL *)url;

-(void)mateApplicationStartService;

-(void)setBeforePasteMessage:(NSString *)beforePasteMessage;
-(void)updateCurrentPageInfo:(NSString*)pageString;
+(BOOL)canOpenURL:(NSURL *)url;
@end

