//
//  PwdPinViewController.m
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2018. 12. 28..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "PwdPinViewController.h"
#import "FidoLib.h"
#import <LocalAuthentication/LocalAuthentication.h>


#import "PwdCertViewController.h"
#if 1
#define USE_BLOCKCHAIN
#import "OPConfiguration.h"
static OPsignService *_opSignService = nil;
#endif

#define DEFAULT_KEY_SIZE    16
#define DEF_BUTTON_WIDTH    105
#define DEF_BUTTON_HEIGHT   40
#define DEF_PWD_NAVIBAR_HEIGHT 0

@interface PwdPinViewController ()<VPFidoLibDelegate, TransKeyDelegate>
{
    __weak IBOutlet UIView *_pinContentView;
    
    __weak IBOutlet UIButton *_pwdResetBtn;
    __weak IBOutlet UIButton *_closeButton;
    
    PwdPinFinish _callBack;
    
    __weak IBOutlet EdgeLabel *_titleLabel;
    __weak IBOutlet EdgeLabel *_subTitleLabel;
    __weak IBOutlet EdgeLabel *_infoTextLabel;
    
    __weak IBOutlet UIButton *_cancelButton;
    __weak IBOutlet UIButton *_confirmButton;
    
    __weak IBOutlet UIView *_imageBackView;
    __weak IBOutlet NSLayoutConstraint *_imageBackViewBottom;
    __weak IBOutlet NSLayoutConstraint *keypadH;
    __weak IBOutlet UIView *keypadBgView;
    
    NSMutableArray *_imageViewArray;
    
    __weak IBOutlet UIView *_fidoContentView;
    __weak IBOutlet UIButton *_fidoCancelButton;
    __weak IBOutlet UIButton *_fidoRetryButton;
    
    __weak IBOutlet UIImageView *_fidoImageView;
    
    __weak IBOutlet UILabel *_fidoTitleLabel;
    __weak IBOutlet UILabel *_fidoSubLabel;
    
    FidoLib* _fidoLib;
    
    BOOL _blockChainCertMode;
    BOOL _showTouchID;
    BOOL _alreadyShowTouchIDLockedOut;
}


@property (nonatomic, strong) NSDictionary *blockChainChallenge;
@property (nonatomic, strong) NSString *targetRequestID;
@end

@implementation PwdPinViewController
@synthesize subTitle = _subTitle;
@synthesize infoMsg = _infoMsg;
@synthesize raonTf = _raonTf;


static NSData *_sKey = nil;
static NSMutableArray *blockChainRequests = nil;
static BOOL useBlockChain = NO;

#pragma mark - BlockChainRequestSetting
+(void)initialize
{
    [super initialize];
    if(blockChainRequests == nil)
    {
        blockChainRequests = [[NSMutableArray alloc] init];
        //katsv
        
         // Ver. 3 SSG 교환 요청(KATPE38), 제휴사 교환요청(KATPE07), 쿠폰구매(KATA009), 쿠폰 선물하기(KATA010)
        //교환
        [blockChainRequests addObjectsFromArray:@[KATPE38,KATPE07]];
        
        // Ver. 3 로그인 추가, 충전수단 카드 등록/삭제, 보내기, 자동송금 등록/해지, ATM 출금 비밀번호 생성, 계좌 충전, 자동 충전 등록/해지, 계죄 등록/해지, 고객 서비스 해지, 비밀번호 검증, 내 계좌로 보내기(환급하기), 가맹점 P2P결제, 가맹점 P2P결제 취소, 가맹점 계좌 입금, 전용카드 결제멤버십 ID설정
        [blockChainRequests addObjectsFromArray:@[KATL001,
                                                  KATPC19,KATPC13,KATJ032,
                                                  KATPC04,KATPC09,
                                                  KATJ033,KATL010,
                                                  KATA016,KATA017,KATA018,
                                                  ]];
        
        //하이브리드에서 BC및 FIDO모드 사용
        [blockChainRequests addObjectsFromArray:@[@"HybridCall"]];
    }
    
//    if(_sKey == nil)
//    {
//        unsigned char iv[16] = { 'M', 'o', 'b', 'i', 'l', 'e', 'T', 'r' , 'a', 'n', 's', 'K', 'e', 'y', '1', '0' };
//        _sKey = [[NSData alloc] initWithBytes:iv length:16];
//    }
}

#pragma mark - BlockChain

+(void)initializeBlockChain
{
#ifdef USE_BLOCKCHAIN
    if ([@"Y" isEqualToString:[AppInfo sharedInfo].isBlockChainEnable]) {
        if(_opSignService != nil || IOS_VERSION_OVER_9 == NO) return;
        @try {
            // OPsign SDK에서 실행되는 내역 로그를 Console 창에 출력한다.
#ifdef DEBUG
            [OPConfiguration showLog:YES];
#endif
            // 키 관리를 위한 OPsignService 객체를 아래와 같이 받아옴.
            _opSignService = [OPConfiguration getOPsignService];
            
            //최초 블럭체인을 사용하는지 체크하여 초기화한다.(블럭체인 사용안하는버전에서 사용버전으로 업데잍트시 블럭체인이 생성되어있다면 삭제한다. -- 운영환경이 아닌 테스트환경에서 블럭체인오류때문.)
            BOOL useBlockChainFlag = [[[UserDefaults sharedDefaults] objectForKey:@"useBlockChainFlag"] boolValue];
            if(useBlockChainFlag == NO)
            {
                [[UserDefaults sharedDefaults] setValue:@"1" forKey:@"useBlockChainFlag"];
                [self deleteBlockChain];
            }
            
        } @catch (NSException *exception) {
            // 오류가 났을 경우 Popup화면을 띄워준다.
            useBlockChain = NO;
            _opSignService = nil;
        }
    }
#endif
}

+(void)checkedBlockChain
{
#ifdef USE_BLOCKCHAIN
    if ([@"Y" isEqualToString:[AppInfo sharedInfo].isBlockChainEnable]) {
        [self initializeBlockChain];
        if(_opSignService == nil) return;
        @try {
            //공개키추출 성공
            if([_opSignService getPublicKey])
            {
                useBlockChain = YES;
            }
        } @catch (NSException *exception) {
            //공개키 추출 실패시새로운 공개키 등록
            [self registCert];
        }
    }
#endif
}

- (void)checkedBlockChainAsync
{
#ifdef USE_BLOCKCHAIN
    if ([@"Y" isEqualToString:[AppInfo sharedInfo].isBlockChainEnable]) {
        [PwdPinViewController initializeBlockChain];
        if(_opSignService == nil) return;
        @try {
            //공개키추출 성공
            if([_opSignService getPublicKey])
            {
                useBlockChain = YES;
            }
        } @catch (NSException *exception) {
            //공개키 추출 실패시새로운 공개키 등록
            [self registCertAsync];
            return;
        }
        [self requestP1203];
    }
#endif
}

+(void)deleteBlockChain
{
#ifdef USE_BLOCKCHAIN
    if ([@"Y" isEqualToString:[AppInfo sharedInfo].isBlockChainEnable]) {
        [self initializeBlockChain];
        if(_opSignService == nil) return;
        @try {
            [_opSignService deleteKeyPair];
        } @catch (NSException *exception) {
            
        }
    }
#endif
}

+(void)registCert
{
#ifdef USE_BLOCKCHAIN
    if ([@"Y" isEqualToString:[AppInfo sharedInfo].isBlockChainEnable]) {
        if(_opSignService == nil) return;
        @try {
            //새로운 키쌍생성
            if([_opSignService createKeyPair])
            {
                OPKeyData* opKeyData = [_opSignService getPublicKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:[opKeyData opData] forKey:@"bcaPublicKey"];
                [dic setValue:[opKeyData deviceId] forKey:@"bcaDeviceId"];
                [dic setValue:[opKeyData deviceModel] forKey:@"bcaDeviceModel"];
                [dic setValue:[opKeyData appId] forKey:@"bcaAppId"];
                [dic setValue:[opKeyData cryptoType] forKey:@"bcaCryptoType"];
                
                 // Ver. 3 블럭체인 인증서등록(KATA023)
                [Request requestID:KATA023 body:dic waitUntilDone:YES showLoading:NO cancelOwn:nil finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                        if(IS_SUCCESS(rsltCode))
                        {
                            useBlockChain = YES;
                        }
                    }];

            }
        } @catch (NSException *exception) {
            //키쌍생성 실패시 실패 리포트
            useBlockChain = NO;
            [self deleteBlockChain];
            [self sendFailReport:@"1" bcaUsage:@"KATBCA0100" failReason:@"2"];
        }
    }
#endif
}

-(void)registCertAsync
{
#ifdef USE_BLOCKCHAIN
    if ([@"Y" isEqualToString:[AppInfo sharedInfo].isBlockChainEnable]) {
        if(_opSignService == nil) return;
        @try {
            //새로운 키쌍생성
            if([_opSignService createKeyPair])
            {
                OPKeyData* opKeyData = [_opSignService getPublicKey];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:[opKeyData opData] forKey:@"bcaPublicKey"];
                [dic setValue:[opKeyData deviceId] forKey:@"bcaDeviceId"];
                [dic setValue:[opKeyData deviceModel] forKey:@"bcaDeviceModel"];
                [dic setValue:[opKeyData appId] forKey:@"bcaAppId"];
                [dic setValue:[opKeyData cryptoType] forKey:@"bcaCryptoType"];
                
                 // Ver. 3 블럭체인 인증서등록(KATA023)
                [Request requestID:KATA023 body:dic waitUntilDone:NO showLoading:NO cancelOwn:nil finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                         if(IS_SUCCESS(rsltCode))
                         {
                             useBlockChain = YES;
                             [self requestP1203];
                         }
                     }];
            }
        } @catch (NSException *exception) {
            //키쌍생성 실패시 실패 리포트
            useBlockChain = NO;
            [PwdPinViewController deleteBlockChain];
            [PwdPinViewController sendFailReport:@"1" bcaUsage:@"KATBCA0100" failReason:@"2"];
        }
    }
#endif
}

//statType : 통계유형구분, bcaUsage : 인증용도, failReason : 폐기등록실패사유구분
+(void)sendFailReport:(NSString *)statType bcaUsage:(NSString*)bcaUsage failReason:(NSString*)failReason
{
    Request *failRequest = [[Request alloc] init];
   // Ver. 3 블럭체인 실패통계
    failRequest.requestID = KATA022;

    failRequest.showLoading = NO;
    failRequest.message = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"statType":statType?statType:@"",
                                                                 @"bcaUsage":bcaUsage?bcaUsage:@"",
                                                                 @"failReason":failReason?failReason:@""}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    [failRequest setValue:[NSString stringWithFormat:@"%.0f",[PwdWrapper timeStamp]] forHTTPHeaderField:@"lts"];
    [failRequest setValue:[NSString stringWithFormat:@"%d", ((int)[jsonData length])] forHTTPHeaderField:@"Content-Length"];
    [failRequest setHTTPBody:jsonData];
    [failRequest sendDataTask:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [failRequest remove];
        });
    }];
}

#pragma mark -


+(void)loadResource
{
    [TransKey loadResource:nil];
}


-(NSString*)doublyEncrypted:(NSString*)dataStr key:(NSString*)key
{
    if(key == nil) return @"";
//    NSString *encVal = [NSString stringWithFormat:@"timestamp=%.0f&%@_doubly_encrypted_hexa=%@",++_timeStamp, key, dataStr];
//    NSLog(@"VALUE : %@", encVal);
    
    NSString * doubleEncryptedStr = [_raonTf getPublicKeyEnc:@"server2048.der" encStr:dataStr];
    
    if (doubleEncryptedStr) {
        doubleEncryptedStr = [NSString stringWithFormat:@"%@|1|%.0f", doubleEncryptedStr, ++PwdWrapper.timeStamp];
    }
    
    
    return doubleEncryptedStr?doubleEncryptedStr:@"";
}

+(void)showPwd:(PwdPinSetting)settingCallBack callBack:(PwdPinFinish)callBack;
{
    [self showPwd:settingCallBack target:nil callBack:callBack];
}

+(void)showPwd:(PwdPinSetting)settingCallBack target:(NSString*)targetRequestID callBack:(PwdPinFinish)callBack
{
    PwdPinViewController *vc = [[UIStoryboard storyboardWithName:@"Component" bundle:nil] instantiateViewControllerWithIdentifier:@"PwdPinViewController"];
    vc.viewID = MenuID_SecureKeypad;
    [vc setupWithCallBack:callBack];
    
    if(settingCallBack)
        settingCallBack(vc);
    vc.targetRequestID = targetRequestID;
 
    // Fabric [TransKey didEndEditing] crash 패치
    // 라온키패드가 2개가 뜨면 하나닫은후 나머지하나에서 "입력완료 버튼이 생기는버그가 있음" 남은 키패드vc를 닫고나서 입력완료 버튼을 누르면
    // 라온 텍스트필드가 메모리에서 사라져 크래시 현상이 일어남
    // 일단 키패드vc가 연달아 두번뜨지 않도록 패치
    if ([APP_MAIN_VC.visibleViewController isKindOfClass:[PwdPinViewController class]]) return;
    
    [APP_MAIN_VC.visibleViewController presentViewController:vc animated:YES completion:nil];
}

-(void)setupWithCallBack:(PwdPinFinish)callBack
{
    _callBack = callBack;
    // 비밀번호가 입력되는 중간의 작은원 이미지 array
    _imageViewArray = [[NSMutableArray alloc] init];
    _maxLen = PwdPinLen;
    self.enableTfAutoScroll = NO;
}

-(void)dealloc
{
//    [_fidoLib SetDelegate:nil];
    [_fidoLib setDelegate:nil withKBType:KBType02];
    _fidoLib = nil;
    _callBack = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(_targetRequestID)
    {
        NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"SELF == %@", _targetRequestID];
        NSArray *array = [blockChainRequests filteredArrayUsingPredicate:findPredicate];
        if(array.count != 0)
        {
            [self checkedBlockChainAsync];
            _blockChainCertMode = YES;
                        
            [[AppInfo sharedInfo] willEnterForeground:nil];
            _showTouchID = ([AppInfo sharedInfo].useBiometrics == UseBiometricsEnabled && [UserDefaults sharedDefaults].useFido == FidoUseSettingEnabled);
            
            _alreadyShowTouchIDLockedOut = YES;
            if (!_showTouchID && [UserDefaults sharedDefaults].useFido == FidoUseSettingEnabled)
            {
                if ([AppInfo sharedInfo].lastBiometricsError.code == -8 /*kLAErrorTouchIDLockout*/)
                {
                    _alreadyShowTouchIDLockedOut = NO;
                }
            }
            _maxLen = PwdPinLen;
        }
    }
    
    _pinContentView.userInteractionEnabled = NO;
    
    // 첫째줄 문구
    _titleLabel.text = self.title;
    
    // 둘째줄 문구
    _subTitleLabel.text = _subTitle;
    
    // 하단 문구
    _infoTextLabel.text = _infoMsg;
    
    // fido 취소 버튼
//    [_fidoCancelButton setBackgroundImage:[UIImage imageNamed:@"btn_p_cancel.png" capWidthRatio:0.5 capHeightRatio:0.5] forState:(UIControlStateNormal)];
//
//    // fido 확인 버튼
//    [_fidoRetryButton setBackgroundImage:[UIImage imageNamed:@"btn_w_try.png" capWidthRatio:0.5 capHeightRatio:0.5] forState:(UIControlStateNormal)];
//
//    // 취소 버튼
//    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_purple02.png" capWidthRatio:0.5 capHeightRatio:0.5] forState:(UIControlStateNormal)];
//
//    // 확인 버튼
//    [_confirmButton setBackgroundImage:[UIImage imageNamed:@"btn_purple03.png" capWidthRatio:0.5 capHeightRatio:0.5] forState:(UIControlStateNormal)];
    
    // fido 이미지
    [_fidoImageView setImage:[UIImage imageNamed:isFaceID()?@"faceid_ok.png" : @"FingerPrint"]];
    
    // 비밀번호를 잊으셨나요? 버튼 회원가입 완료된 후
    if ([AppInfo sharedInfo].isJoin == YES) {
        _pwdResetBtn.hidden = !_showPwdResetBtn;
    }
    else {
        _pwdResetBtn.hidden = YES;
    }
    
    [_pwdResetBtn setAccessibilityHint:@"비밀번호 찾기 화면으로 이동합니다."];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPwdKeyPad:)];
    [self.view addGestureRecognizer:tapGes];
    
    self.maxLen = _maxLen;
    
    // fido화면 문구 지정
    
    _fidoTitleLabel.text = isFaceID() ? @"FaceID를 사용하여" : @"지문을 사용하여";
    _fidoSubLabel.text =  @"본인인증을 해주세요.";
    
    // 지문인식 백그라운드 화면
    _fidoContentView.hidden = !_showTouchID;
    
    //NSLog(@"%@",self.raonTf);
    [self raonTf];
}

- (void)requestP1203
{
    if(useBlockChain)
    {
        // Ver. 3 블럭체인 인증서 검증용 Challenge요청(KATA024)
        [Request requestID:KATA024 body:nil waitUntilDone:NO showLoading:NO cancelOwn:nil finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                if(IS_SUCCESS(rsltCode))
                {
                    self.blockChainChallenge = result;
                }
            }];
    }
    
}

-(void)showPwdKeyPad:(UITapGestureRecognizer*)ges
{
    if(_fidoContentView.hidden)
    {
        if (self.raonTf.isFirstResponder == NO)
            [self.raonTf TranskeyBecomeFirstResponder];
    }
}

-(void)becomeActiveNotification:(NSNotification*)noti
{
    //보안키패드 입력중 푸시가 도착하고 푸시익스텐션으로 바로 답장을 할경우 보안키패드가 내려감, 다시 앱으로 돌아올때 키패드를 올리는 로직
    if(_successTouchID == NO && _showTouchID == NO && _callBack) {
        [_raonTf TranskeyBecomeFirstResponder];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 윈도우에 로딩바가 떠있는상태에서 키패드가 호출되면 로딩바가 포함된 윈도우에 키페드가 add되어(라이브러리에서 그러고있음...) 로딩바를 hide할때 키보드가 사라짐
    // 미리 로딩바를 hide 시켜준후 키패드화면으로 진입한다.
    [IndicatorView hide];
    
    [self updatePwContentView];
//    [self setStatusBar:YES];
    [AllMenu setStatusBarStyle:YES viewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)fidoCancelButtonClicked:(id)sender
{
    _showTouchID = NO;
    [self updatePwContentView];
}

- (IBAction)fidoRetryButtonClicked:(id)sender
{
    [self updatePwContentView];
}

- (void)updatePwContentView
{
    if(_showTouchID)
    {
        // 한국전자인증 FIDO
        if ([UserDefaults sharedDefaults].isFidoTestTOBE) {
            [IndicatorView showMessage:nil];
            
            // showSplashView setting
            [AppInfo sharedInfo].isFidoActive = YES;
            
            // 한국전자인증 FIDO가 등록 되어있을 때 ==> 로그인
            if ([UserDefaults sharedDefaults].isRegistedFido == YES) {
                [[KBFidoManager sharedInstance] setUserName:[UserDefaults sharedDefaults].appID];
                [[KBFidoManager sharedInstance] setLocalizedMsg:[NSString stringWithFormat:@"%@ %@", _fidoTitleLabel.text, _fidoSubLabel.text]];
                [[KBFidoManager sharedInstance] authenticationFido:^(BOOL success, ResultMessage * _Nonnull result, NSError * _Nullable error) {
                    
                    [IndicatorView hide];
                    
                    // showSplashView setting
                    [AppInfo sharedInfo].isFidoActive = NO;
                    
                    [self responseFidoAction:FIDOTypeAuth success:success resultMessage:result error:error];
                }];
            }
            // 브이피 FIDO가 등록 되어있을 때 ==> 등록 및 로그인
            else {
                [[KBFidoManager sharedInstance] setUserName:[UserDefaults sharedDefaults].appID];
                [[KBFidoManager sharedInstance] setLocalizedMsg:[NSString stringWithFormat:@"%@ %@", _fidoTitleLabel.text, _fidoSubLabel.text]];
                [[KBFidoManager sharedInstance] regAuthenticationFido:^(BOOL success, ResultMessage * _Nonnull result, NSError * _Nullable error) {
                    
                    [IndicatorView hide];
                    
                    // showSplashView setting
                    [AppInfo sharedInfo].isFidoActive = NO;
                    [[KBFidoManager sharedInstance] setIsRegAuth:NO];
                    
                    [self responseFidoAction:FIDOTypeAuth success:success resultMessage:result error:error];
                }];
            
            }
        }
        // 브이피 FIDO
        else {
            LAContext *context = [[LAContext alloc] init];
            NSError *error = nil;
            if( [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error] )
            {
                context.localizedFallbackTitle = @"";
                [AppInfo sharedInfo].isFidoActive = YES;
                [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                        localizedReason:[NSString stringWithFormat:@"%@ %@", _fidoTitleLabel.text, _fidoSubLabel.text]
                                  reply:^(BOOL success, NSError *error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [AppInfo sharedInfo].isFidoActive = NO;
                                          if (success)
                                          {
                                              self->_successTouchID = YES;
                                              [IndicatorView showMessage:nil];
                                              self->_fidoLib = [[FidoLib alloc] init];
//                                              [self->_fidoLib SetDelegate:self];
                                              [self->_fidoLib setDelegate:self withKBType:KBType02];
                                              
                                              NSString * authType = @"";
                                              if ([AppInfo sharedInfo].typeBiometrics == TypeTouchID) {
                                                  authType = @"finger";
                                              } else if([AppInfo sharedInfo].typeBiometrics == TypeFaceID) {
                                                  authType = @"face";
                                              }
                                              
                                              NSString * strFidoType = [self getFidoAuthType:0];
                                              FidoType fidoType = FidoTypeNone;
                                              
                                              if([@"L" isEqualToString:strFidoType])
                                                  fidoType = FidoTypeLogin;
                                              else if ([@"A" isEqualToString:strFidoType]) {
                                                  fidoType = FidoTypeAuthentication;
                                              } else {
                                                  fidoType = FidoTypeETC;
                                              }
                                              
                                              [self->_fidoLib fido_Authentication:fidoType server:FidoMode];
                                              self->_pinContentView.userInteractionEnabled = YES;
                                              // 인증성공시에 마지막 에러 초기화
                                              [AppInfo sharedInfo].lastBiometricsError = nil;
                                          }
                                          else
                                          {
                                              [self biometryErrorCode:error];
                                          }
                                          
                                          // HA서버에 지문인증 사용 기록을 위해 전달
                                          NSMutableDictionary *param = [NSMutableDictionary dictionary];
                                          [param setValue:[UserDefaults sharedDefaults].appID forKey:@"appId"];
                                          [param setValue:@"Auth" forKey:@"certGbn"];
                                          [param setValue:[self getFidoAuthType:1] forKey:@"certTrxGbn"];
                                          [param setValue:success ? @"1" : @"0" forKey:@"certRslt"];
                                          [param setValue:[AppInfo sharedInfo].typeBiometrics == TypeTouchID ? @"1" : @"2" forKey:@"certMethodGbn"];
                                          [Request requestID:KATWA19    //P01209
                                                        body:param
                                               waitUntilDone:NO
                                                 showLoading:NO         // ???? TODO : 확인 요망        // YES
                                                   cancelOwn:self
                                                    finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                                                    }];
                                      });
                                  }];
            } else if (error) {
                [self biometryErrorCode:error];
            }
        }
    }
    else
    {
        BOOL isFidoLocked = NO;
        if (!_showTouchID && [UserDefaults sharedDefaults].useFido == FidoUseSettingEnabled)
        {
            if ([AppInfo sharedInfo].lastBiometricsError.code == -8 /*kLAErrorTouchIDLockout*/)
            {
                isFidoLocked = YES;
            }
        }
        
        if (isFidoLocked && !_alreadyShowTouchIDLockedOut)
        {
            [self biometryErrorCode:[AppInfo sharedInfo].lastBiometricsError];
        }
        else
        {
            _fidoContentView.hidden = YES;
            _pinContentView.userInteractionEnabled = YES;
            
            NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
            NSString *widgetLogin = [userDefault objectForKey:@"WIDGET_LOGIN"];
            
            if([widgetLogin isEqualToString:@"Y"]){
                // delay 0.5 -> 1.0로 변경 (bugFix2 Merge)
                [self->_raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:1.0];
                
                // Y : 위젯에서 로그인 시도 , K : 키보드 호출 , N : 로그인 완료
                NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
                [userDefault setObject:@"K" forKey:@"WIDGET_LOGIN"];
            }else{
                [self->_raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:0.2];
            }

            
        }
    }
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
    
    // 비밀번호 이미지
    CGFloat imageWidth = 18.0;
    CGFloat imageHeight = 18.0;
    CGFloat imageGap = 17.0;
    CGFloat x = (_imageBackView.bounds.size.width - (imageWidth*_maxLen + imageGap*(_maxLen-1)))/2;
    for(UIImageView *view in _imageViewArray)
    {
        NSInteger index = [_imageViewArray indexOfObject:view];
        view.frame = CGRectMake(x + ((imageWidth + imageGap) * index), (_imageBackView.bounds.size.height - imageHeight)/2.0, imageWidth, imageHeight);
    }
    
    if (IS_IPHONE_4) _imageBackViewBottom.constant = 30;
    
}

-(TransKey *)raonTf
{
    if(_raonTf == nil)
    {
        _raonTf = [TransKey getRandomKeypad:self
                                    license:@"license_mtk_kbcard_liivmate_20181214_20991231"
                                       type:TransKeyResourceTypeRandom];
        [_raonTf setMaxLen:_maxLen];
        _sKey = [_raonTf getSecureKey];

        [self.view addSubview:_raonTf];
    }
    return _raonTf;
}

-(void)setRaonTf:(TransKey *)raonTf
{
    if(raonTf == nil)
    {
        [_raonTf removeFromSuperview];
    }
    _raonTf = raonTf;
}
-(UIImageView*)setKeyInputImage:(UIImageView*)imageView index:(NSInteger)idx{
    
    NSInteger index = idx%3;
    
    switch (index) {
        case 0:
            imageView.image = [UIImage imageNamed:@"circle"];
            imageView.highlightedImage = [UIImage imageNamed:@"circle_highlighted"];
            break;
        case 1:
            imageView.image = [UIImage imageNamed:@"triangle"];
            imageView.highlightedImage = [UIImage imageNamed:@"triangle_highlighted"];
            break;
        case 2:
            imageView.image = [UIImage imageNamed:@"rectangle"];
            imageView.highlightedImage = [UIImage imageNamed:@"rectangle_highlighted"];
        break;
            
        default:
            break;
    }
    //            imageView.image = [UIImage imageNamed:@"input_pw_pupple.png"];
    //            imageView.highlightedImage = [UIImage imageNamed:@"input_pw_yellow.png"];

    return imageView;
    
}

-(void)setMaxLen:(int)maxLen
{
    _maxLen = maxLen;
    if(self.isLoadView)
    {
        [_raonTf setMaxLen:_maxLen];
        
        for(UIView *view in _imageViewArray){
            [view removeFromSuperview];
        }
        [_imageViewArray removeAllObjects];
        
        for (int i = 0; i < _maxLen; i++)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.tag = i;
//            imageView.image = [UIImage imageNamed:@"input_pw_pupple.png"];
//            imageView.highlightedImage = [UIImage imageNamed:@"input_pw_yellow.png"];
            imageView = [self setKeyInputImage:imageView index:i];
//            imageView.image = [UIImage imageNamed:@"input_pw_pupple.png"];
//            imageView.highlightedImage = [UIImage imageNamed:@"input_pw_yellow.png"];
            
            [_imageViewArray addObject:imageView];
            [_imageBackView addSubview:imageView];
        }
        [self viewWillLayoutSubviews];
    }
}

-(void)setShowPwdResetBtn:(BOOL)showRestBtn
{
    _showPwdResetBtn = showRestBtn;
    _pwdResetBtn.hidden = !_showPwdResetBtn;
    
}

-(IBAction)onClickedPwdResetButton:(id)sender
{
    _resetPWClecked = YES;
    if(_callBack)
        _callBack(self, YES, nil);
    _callBack = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        // Ver. 3 MenuID_V3_PwdReset 코드 추가(MYD_LO0103)
        [[AllMenu delegate] navigationWithMenuID:MenuID_V3_PwdReset
                                        animated:YES
                                          option:(NavigationOptionPush)
                                        callBack:^(ViewController *vc) {
                                            
                                        }];
        
    }];
}

- (void)TransKeyDidBeginEditing:(TransKey *)transKey
{
    [keypadBgView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    
    
//
//    AppDelegate.shared.window?.subviews.forEach {
//        if String(describing: type(of: $0)) == "TsKeypadView" {
//            $0.accessibilityViewIsModal = true
//            if $0.subviews.count > 0 {
//                $0.accessibilityElements = [self.view, $0.subviews[0]]
//            }
//        }
//    }
    
}
- (void)TransKeyDidEndEditing:(TransKey *)transKey
{
    NSLog(@"TransKeyDidEndEditing");
}
- (void)TranskeyWillBeginEditing:(TransKey *)transKey
{
}
- (void)TranskeyWillEndEditing:(TransKey *)transKey
{
    [keypadBgView setBackgroundColor:UIColorFromRGB(0x0067FF)]; // 색변경 (퍼플 -> 블루)
}

- (void)TransKeyInputKey:(NSInteger)keytype
{
    [self reloadLabel];
    
    if(_raonTf.length == _maxLen)
        [self finishPwdPin:nil];
    
}
- (BOOL)TransKeyShouldInternalReturn:(TransKey *)transKey btnType:(NSInteger)type
{
    [self finishPwdPin:nil];
    return NO;
}

- (void)TransKeyEndCreating:(TransKey *)transKey
{
    NSLog(@"TransKeyEndCreating");
    NSLog(@"mTK_GetCurrentKeypadHeight : %f",[transKey mTK_GetCurrentKeypadHeight]);
    
    [transKey mTK_SetCompleteBtnHide:YES]; //입력완료 버튼 숨김처리(라온 문의결과 TransKeyEndCreating 시점에서 호출해야된다고 함)
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    
    if (@available(iOS 11.0, *)) {
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        keypadH.constant = [transKey mTK_GetCurrentKeypadHeight] + bottomPadding + DEF_PWD_NAVIBAR_HEIGHT;
    } else {
        keypadH.constant = [transKey mTK_GetCurrentKeypadHeight] + DEF_PWD_NAVIBAR_HEIGHT;
    }
    
//    [transKey mTK_SetCompleteBtnHide:YES];
    
    NSLog(@"mTK_GetCurrentKeypadHeight : %f",keypadH.constant);
    [self.view layoutIfNeeded];
    
    // 알럿이 떠있을 경우 키윈도우가 달라져서 알럿키윈도우에 키패드가 뜨는 현상이 발생해서 키보드가 뜨고나서 윈도우를 체크하고 알럿윈도우이면 키패드를 내린ㄷ
    if (window != ((AppDelegate *)APP_DELEGATE).window) {
        [_raonTf TranskeyResignFirstResponder];
    }
   
}
//키패드가 터치되면 콜백을 줌(mTK_RemoveFieldTouchEvent 옵션 사용시)
- (void)TranskeyFieldTouched:(TransKey *)transKey
{
    NSLog(@"TranskeyFieldTouched");
}
- (BOOL)TransKeyShouldReturn:(TransKey *)transKey
{
    NSLog(@"TransKeyShouldReturn");
    return YES;
}

-(IBAction)finishPwdPin:(id)sender
{
    if(_raonTf.length < _maxLen)
    {
        showSplashMessage([NSString stringWithFormat:@"숫자 %d자리를 입력하세요",_maxLen],YES, YES);
        [_raonTf clear];
        [self reloadLabel];
        return;
    }
    
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

- (void)resetPwd
{
    // fido모드이고 서버에 문제가있어 로그인에 실패시에 키보드 뜨는현상 방지
    // 파이도 모드일때는 키페드 리셋을 하지 않는다
    if (_showTouchID) return;
    
    self.raonTf = nil;
    [self.raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:0.2];
    [self performSelector:@selector(reloadLabel) withObject:nil afterDelay:0.2];
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

-(void)reloadLabel
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadLabel) object:nil];
    for(UIImageView *view in _imageViewArray)
    {
        view.highlighted = view.tag < _raonTf.length;
    }
}

-(NSString *)encText
{
    return [_raonTf getCipherDataEx];
}

//-(NSString*)dummyText
//{
//    return _pentaTf.text;
//}

-(NSString*)doublyEncrypted:(NSString*)keyNm
{
    if(_successTouchID) return @"";

    return [self doublyEncrypted:[self encText] key:keyNm];
}

//블럭체인 딕션어리 리턴
-(NSDictionary*)blockChainWithKeyNm:(NSString *)keyNm
{
    NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
    NSString *pwd = [self doublyEncrypted:keyNm];
    if(_blockChainCertMode)
    {
        NSString *verifyMode = @"0";
        NSString *bcaUsage = @"";
        NSString *bcaChallenge = @"";
        NSString *bcaChallengeResponse = @"";
        NSString *bcaReferrerKey = @"";
        if(self.successTouchID)
        {//FIDO
            verifyMode = @"3";
        }
        else
        {
            if(self.blockChainChallenge)
            {//PIN+blockChain
                // Ver. 3 로그인 추가
                if([_targetRequestID isEqualToString:KATL001])
                    bcaUsage = @"KATBCA0101";
                else
                    bcaUsage = @"KATBCA0102";
                
#ifdef USE_BLOCKCHAIN
                if ([@"Y" isEqualToString:[AppInfo sharedInfo].isBlockChainEnable]) {
                    BOOL failReport = NO;
                    @try {
                        bcaChallenge = [self.blockChainChallenge objectForKey:@"challenge"];
                        OPKeyData* opKeyData = [_opSignService signData:bcaChallenge];
                        if(opKeyData != nil){
                            // 값을 참조하여 서버에 전송.
                            bcaReferrerKey = [self.blockChainChallenge objectForKey:@"referrer_key"];
                            bcaChallengeResponse = [opKeyData opData];
                            verifyMode = @"1";
                        }
                        else
                            failReport = YES;
                    } @catch (NSException *exception) {
                        //공개키 추출 실패시새로운 공개키 등록
                        failReport = YES;
                    }
                    
                    if(failReport)
                    {
                        [PwdPinViewController sendFailReport:@"2" bcaUsage:bcaUsage failReason:@"5"];
                        verifyMode = @"0";
                        bcaUsage = @"";
                        bcaReferrerKey = @"";
                        bcaChallengeResponse = @"";
                    }
                }
#endif
            }
        }
        [returnDic setValue:verifyMode forKey:@"verifyMode"];
        [returnDic setValue:bcaUsage forKey:@"bcaUsage"];
        [returnDic setValue:bcaChallenge forKey:@"bcaChallenge"];
        [returnDic setValue:bcaChallengeResponse forKey:@"bcaChallengeResponse"];
        [returnDic setValue:bcaReferrerKey forKey:@"bcaReferrerKey"];
    }
    if(keyNm)
        [returnDic setValue:pwd forKey:keyNm];
    
    return returnDic;
}

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    _titleLabel.text = title;
}


-(void)setSubTitle:(NSString *)subTitle
{
    _subTitle = subTitle;
    _subTitleLabel.text = subTitle;
}


-(void)setInfoMsg:(NSString *)infoMsg
{
    _infoMsg = infoMsg;
    _infoTextLabel.text = infoMsg;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// Result Registration(등록)
- (void)result_Register:(BOOL)success
{
    
}

#pragma mark - FidoAction Delegate
- (void)responseFidoAction:(FIDOType)type success:(BOOL)success resultMessage:(ResultMessage *)resultMessage error:(NSError *)error {
    
    switch (type) {
        case FIDOTypeAuth:
        {
            if (success)
            {
                // 저장
                [UserDefaults sharedDefaults].isRegistedFido = YES;
                
                self->_successTouchID = YES;
                self->_pinContentView.userInteractionEnabled = YES;
                // 인증성공시에 마지막 에러 초기화
                [AppInfo sharedInfo].lastBiometricsError = nil;
                
                BOOL dismiss = YES;
                if(_callBack)
                    _callBack(self, NO, &dismiss);
                
                if(dismiss)
                {
                    _callBack = nil;
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
                // HA서버에 지문인증 사용 기록을 위해 전달
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:[UserDefaults sharedDefaults].appID forKey:@"appId"];
                [param setValue:@"Auth" forKey:@"certGbn"];
                [param setValue:[self getFidoAuthType:1] forKey:@"certTrxGbn"];
                [param setValue:success ? @"1" : @"0" forKey:@"certRslt"];
                [param setValue:[AppInfo sharedInfo].typeBiometrics == TypeTouchID ? @"1" : @"2" forKey:@"certMethodGbn"];
                [Request requestID:KATWA19    //P01209
                              body:param
                     waitUntilDone:NO
                       showLoading:NO         // ???? TODO : 확인 요망        // YES
                         cancelOwn:self
                          finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                          }];
            }
            else
            {
                LAContext *context = [[LAContext alloc] init];
                NSError * lockError;
                if(![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&lockError]){
                    error = lockError;
                }
                
                if (!(error.code == kLAErrorUserCancel || error.code == kLAErrorSystemCancel))    // -2: Canceled by user, -4: UI canceled by system
                {
                    //바이오인증 락이 걸렸을 경우
                    if (resultMessage.errorCode == 0 && error == nil) {
                        [BlockAlertView showBlockAlertWithTitle:nil message: isFaceID() ? FaceIdLockoutMsg : TouchIdLockoutMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                            
                            self->_showTouchID = NO;
                            self->_fidoContentView.hidden = YES;
                            [self->_raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:0.2];
                            self->_pinContentView.userInteractionEnabled = YES;
                            
                        } cancelButtonTitle:nil buttonTitles:@"확인", nil];
                        break;
                    }
                    else {
                        if (!(resultMessage.errorCode == USER_CANCEL || resultMessage.errorCode == SYSTEM_CANCEL))    // 10021: Canceled by user, 10023: UI canceled by system
                        {
                            // 10025 LOCK_OUT - 바이오인증 락이 걸렸을 경우 발생한다.
                            // kLAErrorBiometryLockout
                            if (resultMessage.errorCode == LOCK_OUT || error.code == kLAErrorBiometryLockout) {
                                [AppInfo sharedInfo].useBiometrics = UseBiometricsDisabled;
                                [AppInfo sharedInfo].lastBiometricsError = error;
                                
                                [BlockAlertView showBlockAlertWithTitle:nil message: isFaceID() ? FaceIdLockoutMsg : TouchIdLockoutMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                                    
                                    self->_showTouchID = NO;
                                    self->_fidoContentView.hidden = YES;
                                    [self->_raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:0.2];
                                    self->_pinContentView.userInteractionEnabled = YES;
                                    
                                } cancelButtonTitle:nil buttonTitles:@"확인", nil];
                            }
                            // 10026 Biometrics Changes detected - 바이오 인증정보 변경이 감지됨
                            else if (resultMessage.errorCode == BIOMETRICS_CHANGES_DETECTED) {
                                [AppInfo sharedInfo].lastBiometricsError = error;
                                
                                [BlockAlertView showBlockAlertWithTitle:nil message: TouchIdChangeMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                                    
                                    self->_showTouchID = NO;
                                    self->_fidoContentView.hidden = YES;
                                    [self->_raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:0.2];
                                    self->_pinContentView.userInteractionEnabled = YES;
                                    
                                    [[UserDefaults sharedDefaults] joinReset];
                                    [AppInfo sharedInfo].useBiometrics = UseBiometricsEnabled;
                                    
                                } cancelButtonTitle:nil buttonTitles:@"확인", nil];
                            }
                            // 지문인증 3회 오류
                            else if ( error.code == kLAErrorAuthenticationFailed ) {
                                [BlockAlertView showBlockAlertWithTitle:nil message: isFaceID() ? FaceIdDiffMsg : TouchIdDiffMsg dismissedCallback:nil cancelButtonTitle:nil buttonTitles:@"확인", nil];
                            }
                            else {
                                //FIDO error statusCode 가져오기
                                int statusCode = [NSString getFidoStatusCode:resultMessage.errorMessage];
                                if (error) {
                                    statusCode = (int)error.code;
                                }
                                [self OnFidoError:statusCode];
                            }
                        }
                    }
                }
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - FIDO Result CallBack
// Result Authentication(인증)
-(void)result_Auth:(BOOL)success postData:(NSString*)postData userId:(NSString*)userId;
{
    NSLog(@"result_Auth - success / postData : %d / %@", success, postData);
    [IndicatorView hide];
//    [_fidoLib SetDelegate:nil];
     [_fidoLib setDelegate:nil withKBType:KBType02];
    _fidoLib = nil;
    if (success)
    {
        BOOL dismiss = YES;
        if(_callBack)
            _callBack(self, NO, &dismiss);
        
        if(dismiss)
        {
            _callBack = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        // ????
        _successTouchID = NO;
        
        _showTouchID = NO;
        _fidoContentView.hidden = YES;
        //[_pentaTf becomeFirstResponder];
        [self mAlertView: isFaceID() ? FaceIdAuthFailMsg : TouchIdAuthFailMsg];
    }
}


// Result Deregistration(해지)
- (void)result_Deregister:(BOOL)success
{
    
}

// Fido Error
- (void)OnFidoError:(int)reason
{
    NSLog(@"OnFidoError - reason : %d", reason);
    [IndicatorView hide];
    switch(reason)
    {
        case 1500 :
            [self mAlertView:@"서버 내부 오류가 발생하였습니다."];
            break;
        case 1481 :
        {
            //미등록 상태에서 인증시도 시
            [IndicatorView showMessage:nil];
            
            // showSplashView setting
            [AppInfo sharedInfo].isFidoActive = YES;
            
            [[KBFidoManager sharedInstance] setUserName:[UserDefaults sharedDefaults].appID];
            [[KBFidoManager sharedInstance] setLocalizedMsg:[NSString stringWithFormat:@"%@ %@", _fidoTitleLabel.text, _fidoSubLabel.text]];
            [[KBFidoManager sharedInstance] regAuthenticationFido:^(BOOL success, ResultMessage * _Nonnull result, NSError * _Nullable error) {

                [IndicatorView hide];
                
                // showSplashView setting
                [AppInfo sharedInfo].isFidoActive = NO;
                [[KBFidoManager sharedInstance] setIsRegAuth:NO];

                [self responseFidoAction:FIDOTypeAuth success:success resultMessage:result error:error];
            }];
            break;
        }
        case 1480 :
            [self mAlertView:@"해당 인증장치 정보가 없습니다."];
            break;
        case 1408 :
            [self mAlertView:@"요청 시간이 초과되었습니다."];
            break;
        case 1404 :
            [self mAlertView:@"이미 등록된 정보입니다."];// reg
            break;
        case 1405 :
        {
            [self mAlertView:@"등록 후 사용이 가능합니다."];// auth // original
            break;
        }
        case 1403 :
            [self mAlertView:@"현재 사용자가 수행할 수 없는 동작입니다."];
            break;
        case 1401 :
            [self mAlertView:@"인증되지 않은 사용자입니다."];
            break;
        case 1400 :
            [self mAlertView:@"잘못된 요청입니다."];
            break;
        case 1202 :
            [self mAlertView:@"제한 시간 내 처리되지 못했습니다."];
            break;
        case 1496 :
            [self mAlertView:@"Unacceptable Attestation."];
            break;
        case 1494 :
            [self mAlertView:@"Unacceptable Key."];
            break;
        case 1492 :
            [self mAlertView:@"정책에 부합하는 인증장치가 없습니다."];
            break;
            
            // ???? TODO : 확인 요망
        default :
            [self mAlertView:[NSString stringWithFormat:@"바이오 인증에 실패하였습니다.(%d)", reason]];
            break;
    }
}

-(void)mAlertView:(NSString *)message
{
    [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismisTitle:AlertConfirm];
}

-(NSString *)getFidoAuthType:(int)type {
    NSString *authType;
    NSArray *etcReqIDs;
    
    // Ver. 3 충전수단 카드 등록/삭제, 자동송금 등록/해지, 자동 충전 등록/해지, 계죄 등록/해지, 고객 서비스 해지, 비밀번호 검증, //소비매니저 (절약금액 모으기 본거래) - M52516/거래 코드 삭제예정(서비스 종료), 전용카드 결제멤버십 ID설정
    etcReqIDs = @[KATPC19, KATPC13, KATJ032, KATPC09, KATJ033, KATL010];
//    NSArray *etcReqIDs = @[M70205, M70207, M70109, M52516, P00304, P00306, P00309, P00605, P00606, P00902, P00906];
    
    // Ver. 3 로그인 추가
    if([_targetRequestID isEqualToString:KATL001]) { // 로그인
        if(type == 0) // VP 서버에 보낼때
            authType = @"L";
        else // HA 서버에 보낼때
            authType = @"0";
    } else if([etcReqIDs containsObject:_targetRequestID]) { // 기타
        if(type == 0)
            authType = @"E";
        else
            authType = @"2";
    } else { // 결제
        if(type == 0)
            authType = @"A";
        else
            authType = @"1";
    }
    return authType;
}

- (void)biometryErrorCode:(NSError *)error
{
    // ????
    NSLog(@"LAPolicyDeviceOwnerAuthenticationWithBiometrics :%@ %d", error.localizedDescription, (int)error.code);
    LAContext *context = [[LAContext alloc] init];
    NSError * lockError;
    if(![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&lockError]){
        error = lockError;
    }
    
    if (!(error.code == kLAErrorUserCancel || error.code == kLAErrorSystemCancel))    // -2: Canceled by user, -4: UI canceled by system
    {
        switch (error.code) {
            case kLAErrorBiometryLockout:
            {
                [AppInfo sharedInfo].useBiometrics = UseBiometricsDisabled;
                [AppInfo sharedInfo].lastBiometricsError = error;
                
                [BlockAlertView showBlockAlertWithTitle:nil message: isFaceID() ? FaceIdLockoutMsg : TouchIdLockoutMsg dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                    
                    self->_showTouchID = NO;
                    self->_fidoContentView.hidden = YES;
                    [self->_raonTf performSelector:@selector(TranskeyBecomeFirstResponder) withObject:nil afterDelay:0.2];
                    self->_pinContentView.userInteractionEnabled = YES;
                    
                } cancelButtonTitle:nil buttonTitles:@"확인", nil];
                break;
            }
            default:
            {
                [BlockAlertView showBlockAlertWithTitle:nil message: isFaceID() ? FaceIdDiffMsg : TouchIdDiffMsg dismissedCallback:nil cancelButtonTitle:nil buttonTitles:@"확인", nil];
                break;
            }
        }
    }
}

@end
