//
//  PwdCertViewController.m
//  LiivMate
//
//  Created by kbcard-macpro-a on 2019. 3. 7..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "PwdCertViewController.h"

#import "PwdPinViewController.h"
#if 1
#define USE_BLOCKCHAIN
#define DEF_PWD_NAVIBAR_HEIGHT 0
#import "OPConfiguration.h"
static OPsignService *_opSignService = nil;
#endif

@interface PwdCertViewController ()<TransKeyDelegate>
{
    PwdCertFinish _callBack;
    BOOL _blockChainCertMode;
    
    __weak IBOutlet NSLayoutConstraint *keypadH;
    __weak IBOutlet UIView *keypadBgView;
    __weak IBOutlet UILabel *keypadLb;
    __weak IBOutlet EdgeLabel *titleLB;
    __weak IBOutlet UITextField *keypadLbTextFile;      // 비밀번호 입력시 화면 (힌트를 보여 주기위해 추가)
    __weak IBOutlet CornerRadiusButton *finishPwdBtn;
}


@end

@implementation PwdCertViewController
@synthesize raonTf = _raonTf;


#pragma mark -


+(void)loadResource
{
    [TransKey loadResource:nil];
}

-(NSString*)doublyEncrypted:(NSString*)dataStr key:(NSString*)key
{
    if(key == nil) return @"";
    
    NSString * doubleEncryptedStr = [_raonTf getPublicKeyEnc:@"server2048.der" encStr:dataStr];
    
    if (doubleEncryptedStr) {
        doubleEncryptedStr = [NSString stringWithFormat:@"%@|1|%.0f", doubleEncryptedStr, ++PwdWrapper.timeStamp];
    }
    
    
    return doubleEncryptedStr?doubleEncryptedStr:@"";
}

+(void)showPwd:(PwdCertSetting)settingCallBack callBack:(PwdCertFinish)callBack;
{
    PwdCertViewController *vc = [[UIStoryboard storyboardWithName:@"Component" bundle:nil] instantiateViewControllerWithIdentifier:@"PwdCertViewController"];
    vc.viewID = MenuID_SecureKeypad;
    //TODO : 메뉴아이디 변경 필요
    [vc setupWithCallBack:callBack];
    
    if(settingCallBack)
        settingCallBack(vc);
    
    [APP_MAIN_VC.visibleViewController presentViewController:vc animated:YES completion:nil];
}

-(void)setupWithCallBack:(PwdCertFinish)callBack
{
    _callBack = callBack;
    
    self.enableTfAutoScroll = NO;
}

-(void)dealloc
{
    _callBack = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    keypadLb.cornerRadius = 0;
//    keypadLb.borderWidth = 2;
//    keypadLb.borderColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];

    // 보안키패드 placeholder 영역 선택시 키패드 안올라 오게 수정 
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    keypadLbTextFile.inputView = dummyView;
    
    if(self.title != nil && ![self.title isEqualToString:@""]){
        titleLB.text = self.title;
    }
    
//    if (@available(iOS 13.0, *)) {
//        CGRect rect = [[[[[UIApplication sharedApplication] keyWindow] windowScene] statusBarManager] statusBarFrame];
//        UIView *statusBar = [[UIView alloc] initWithFrame:rect];
//
//        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//            statusBar.backgroundColor = RGBA(6, 108, 253, 1);
//        }
//
//        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
//    }
//    else {
//        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//
//        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//            statusBar.backgroundColor = RGBA(6, 108, 253, 1);
//        }
//    }
    
    
}


-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    if(self.title != nil && ![self.title isEqualToString:@""]){
        titleLB.text = self.title;
    }
}

-(void)becomeActiveNotification:(NSNotification*)noti
{
    //보안키패드 입력중 푸시가 도착하고 푸시익스텐션으로 바로 답장을 할경우 보안키패드가 내려감, 다시 앱으로 돌아올때 키패드를 올리는 로직
    if(_callBack) {
        [_raonTf TranskeyBecomeFirstResponder];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updatePwContentView];
    [AllMenu setStatusBarStyle:NO viewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)updatePwContentView {
    [self.raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:0.2];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self->_raonTf mTK_ClearDelegateSubviews];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewWillLayoutSubviews
{
    // 죄우 마진은 각 16씩...
    [super viewWillLayoutSubviews];
    
}

-(TransKey *)raonTf
{
    if(_raonTf == nil)
    {
        _raonTf = [TransKey getRandomKeypad:self
                                    license:@"license_mtk_kbcard_liivmate_20181214_20991231"
                                       type:TransKeyResourceTypeNormal];
        [_raonTf setKeyPadTypeCert];
        
        [self.view addSubview:_raonTf];
    }
    return _raonTf;
}
-(void)setKeyPadTypeCert
{
    if(self.isLoadView)
    {
        [_raonTf setKeyPadTypeCert];
        [self viewWillLayoutSubviews];
    }
}
-(void)setRaonTf:(TransKey *)raonTf
{
    if(raonTf == nil)
    {
        [_raonTf removeFromSuperview];
    }
    _raonTf = raonTf;
}
////

#pragma mark - Raon Keypad Delegate
- (void)TransKeyDidBeginEditing:(TransKey *)transKey {
    [keypadBgView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
}

- (void)TransKeyDidEndEditing:(TransKey *)transKey {
    
}

- (void)TranskeyWillBeginEditing:(TransKey *)transKey {
    
}

- (void)TranskeyWillEndEditing:(TransKey *)transKey {
    [keypadBgView setBackgroundColor:UIColorFromRGB(0x97b1f9)];
}

- (void)TransKeyInputKey:(NSInteger)keytype {
    NSString *str = @"";
    for (int i = 0; i < _raonTf.length; i++) {
        str = [str stringByAppendingString:@"●"];
    }
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:str];
    if(_raonTf.length != 0){ // 0.44:0.49:0.81 , 0.98:0.89:0.48
//        [muStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.44 green:0.49 blue:0.81 alpha:1.0] range:NSMakeRange(0, _raonTf.length - 1)];
//        [muStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.98 green:0.89 blue:0.48 alpha:1.0] range:NSMakeRange(_raonTf.length - 1, 1)];
        // Black Color로 색상변경
        [muStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, _raonTf.length - 1)];
        [muStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(_raonTf.length - 1, 1)];
        
        [muStr addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:10] range:NSMakeRange(0, _raonTf.length)];
        
        finishPwdBtn.backgroundColor = COLOR_MAIN_PURPLE; // 입력값이 있으면 확인버튼 색상변경(Purple)
    }
    else if (_raonTf.length <= 0){
        finishPwdBtn.backgroundColor = UIColorFromRGB(0xC3C3C3); // 입력값이 없으면 확인버튼 색상변경(기본 색상(Gray)
    }
//    keypadLb.attributedText = muStr;
    keypadLbTextFile.attributedText = muStr;    // 보안키패드 ● 입력표시
}

- (BOOL)TransKeyShouldInternalReturn:(TransKey *)transKey btnType:(NSInteger)type {
    [self finishPwdPin:nil];
    return NO;
}

//키패드 생성이 완료된 후에 받는 delegate.
- (void)TransKeyEndCreating:(TransKey *)transKey {
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        keypadH.constant = [transKey mTK_GetCurrentKeypadHeight] + bottomPadding + DEF_PWD_NAVIBAR_HEIGHT;
    } else {
        keypadH.constant = [transKey mTK_GetCurrentKeypadHeight] + DEF_PWD_NAVIBAR_HEIGHT;
    }
    
    [self.view layoutIfNeeded];
}

//키패드가 터치되면 콜백을 줌(mTK_RemoveFieldTouchEvent 옵션 사용시)
- (void)TranskeyFieldTouched:(TransKey *)transKey {
    
}

- (BOOL)TransKeyShouldReturn:(TransKey *)transKey {
    return YES;
}

-(IBAction)finishPwdPin:(id)sender
{
    if (_minLen == 0) {
        _minLen = 10;
        _maxLen = 56;
    }
    if (_raonTf.length == 0) {
        [BlockAlertView showBlockAlertWithTitle:nil message:@"비밀번호를 입력해주세요" dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            
        }  cancelButtonTitle:nil buttonTitles:@"확인", nil];
//        showSplashMessage(@"공인인증서 비밀번호를 입력해주세요", YES, YES);
    }else if (_raonTf.length > _maxLen){
        [BlockAlertView showBlockAlertWithTitle:nil message:[NSString stringWithFormat:@"비밀번호는 최대 %d자리 입니다.", _maxLen] dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            
        }  cancelButtonTitle:nil buttonTitles:@"확인", nil];
//        showSplashMessage([NSString stringWithFormat:@"공인인증서 비밀번호는 최대 %d자리 입니다.", _maxLen], YES, YES);
    }else {
        [_raonTf TranskeyResignFirstResponder];
        
        BOOL dismiss = YES;
        if(_callBack)
            _callBack(self, NO, &dismiss);
        
        if(dismiss)
        {
            _callBack = nil;
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

- (void)resetPwd
{
    self.raonTf = nil;
    [self.raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:0.2];
//    keypadLb.text = @"";
    keypadLbTextFile.text = @"";
}

-(void)cancelPwdPin
{
    if(_callBack)
        _callBack(self, YES, nil);
    _callBack = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)onClickedPwdCloseButton:(id)sender
{
    [self cancelPwdPin];
}

-(NSString *)encText
{
    return [_raonTf getCipherDataEx];
}


-(NSString*)doublyEncrypted:(NSString*)keyNm
{
    return [self doublyEncrypted:[self encText] key:keyNm];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
@end
