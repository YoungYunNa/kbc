//
//  PushNotificationViewController.m
//

#import "PushNotificationViewController.h"
#import "PushDefaultNotification.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface PushNotificationViewController ()

@property (nonatomic, strong) PushDefaultNotification *notification;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *buttonClose;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet WKWebView *webView;
@property (nonatomic, readwrite, getter=isTerminated) BOOL terminated;

@end

@implementation PushNotificationViewController

- (IBAction)onClickCloseButton:(id)sender {
    [self close];
}

- (BOOL)useStatusBarView {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (id)initWithNotification:(PushDefaultNotification *)notification
{
    self = [super init];
    if (self) {
        self.notification = notification;
        self.terminated = NO;
    }
    return self;
}

- (IBAction)didTouchPushTest:(id)sender {
//    [PushM]
    [[PushManager defaultManager] send:self message:@"푸시테스트 용" serviceCode:@"1faf5270e99fb77325abdea4da7ffa212912125cb811e828cb92f661d031a29f" ext:@"1" completionHandler:^(BOOL success){
        
    }];
    
}
-(void)manager:(PushManager *)manager didReceiveUserNotification:(NSDictionary *)userInfo status:(NSString *)status messageUID:(NSString *)messageUID{
    NSLog(@"%@,%@",userInfo,messageUID);
    
}
-(void)manager:(PushManager *)manager didReceiveRemoteNotification:(NSDictionary *)userInfo status:(NSString *)status
{
    NSLog(@"%@",userInfo);
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}

// 알림 등록 메소드
-(IBAction)didTouchLocalPushTest{
 
    // UILocalNotification 객체 생성
    UILocalNotification *noti = [[UILocalNotification alloc]init];
 
    // 알람 발생 시각 설정. 5초후로 설정. NSDate 타입.
    noti.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
 
    // timeZone 설정.
    noti.timeZone = [NSTimeZone systemTimeZone];
 
    // 알림 메시지 설정
    noti.alertBody = @"Just Do It";
 
    // 알림 액션 설정
    noti.alertAction = @"GOGO";
 
    // 아이콘 뱃지 넘버 설정. 임의로 1 입력
    noti.applicationIconBadgeNumber = 1;
 
    // 알림 사운드 설정. 자체 제작 사운드도 가능. (if nil = no sound)
    noti.soundName = UILocalNotificationDefaultSoundName;
 
    // 임의의 사용자 정보 설정. 알림 화면엔 나타나지 않음
    noti.userInfo = [NSDictionary dictionaryWithObject:@"My User Info" forKey:@"User Info"];
 
    // UIApplication을 이용하여 알림을 등록.
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
}

- (void) onPause {
    
}
- (void) onResume {
    
}
- (void) onOrientationWillChange {
    
}
- (void) onOrientationDidChange {
    
}
- (void)didReceiveLocalNotification:(NSNotification *)notification{
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [[PushManager defaultManager] initilaizeWithDelegate:self];
    
//    AppInfo.userInfo.custNo
    
    self.webView = [[WKWebView alloc] init];
    [self.view addSubview:self.webView];
    
    NSLayoutConstraint *layoutTop = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *layoutBottom = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    NSLayoutConstraint *layoutLeft = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *layoutRight = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    [self.view addConstraints:[NSArray arrayWithObjects:layoutTop, layoutBottom, layoutLeft, layoutRight, nil]];
    
    self.titleLabel.text = self.notification.title;
    
    if ( self.notification.isWebContent ) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.notification.contentURL]];

        self.webView.hidden = NO;
    }
    else {
        [self.textView setText:self.notification.message];

        self.textView.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
//    self.webView.delegate = nil;

    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

@synthesize notification = _notification;

@end
