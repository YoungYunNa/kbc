//
//  KCLPaymentViewController.m
//  LiivMate
//
//  Created by KB on 4/30/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLPaymentViewController.h"
#import "BarCodeImageView.h"
#import "KCLBarcodeZoomViewController.h"
#import "KCLQRScannerViewController.h"
#import "PentaPinViewController.h"
#import "PwdPinViewController.h"

#define ResetTime    181

typedef NS_ENUM(NSUInteger, PaymentViewType) {
    PaymentViewType_Make = 0,
    PaymentViewType_Barcode,
    PaymentViewType_ReMake,
};

@interface KCLPaymentViewController ()
{
    NSTimeInterval _endTime;
    NSMutableArray *_cardArray;
    NSDictionary *dicKATA001Result;
    BOOL _isFirstLoaded;
}

@property (weak, nonatomic) IBOutlet UIView * parentView;

@property (weak, nonatomic) IBOutlet UIButton *pointreeMakeViewButton;
@property (weak, nonatomic) IBOutlet UIButton *pointreeBarcodeViewButton;


//바코드 영역 View
@property (weak, nonatomic) IBOutlet UIView *barcodeContainView;

//바코드및 유효시간 View
@property (strong, nonatomic) IBOutlet UIView *barcodeView;
@property (weak, nonatomic) IBOutlet BarCodeImageView *barcodeImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIView *barcodeDimmView;

//바코드 생성/재생성 View
@property (strong, nonatomic) IBOutlet UIView *barcodeMakeView;
@property (weak, nonatomic) IBOutlet UIButton *barcodeMakeButton;

//결제 타입/ 카드 및 포인트리 정보
@property (nonatomic, assign) PaymentViewType paymentType;
@property (nonatomic, strong) NSDictionary *cardInfo;
@property (nonatomic, strong) NSString *pointree;

@end

@implementation KCLPaymentViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"간편결제";
        
    // 바코드결제 카드및 결제정보 획득 후 nextUrl 거래코드를 이용하여 원패쓰 하단의 웹 영역을 로드 - ver .3 for test
    // 공통 dealloc로직을 타기위해 webviewcontroller을 상속받아 사용 아니면 앱크래시 남... - (bugFix2 Merge)
    HybridWKWebView * wv = (HybridWKWebView *)self.webView;
    [wv removeFromSuperview];
        
    [self.parentView addSubview:wv];
    
    NSString *nextUrl = [dicKATA001Result objectForKey:@"nextUrl"];
    self.firstOpenUrl = [NSString stringWithFormat:@"%@%@", SERVER_URL, nextUrl]; // (bugFix2 Merge)

    // Do any additional setup after loading the view from its nib.
    self.naviUnderlineHidden = YES;
    self.barcodeImage.imageInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        
    self.paymentType = PaymentViewType_Make;

    self.barcodeContainView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.barcodeContainView.frame.size.height);
    self.barcodeView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.barcodeView.frame.size.height);
    self.barcodeMakeView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.barcodeMakeView.frame.size.height);
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPoint) name:ReloadPointNotification object:nil];
            
    KCLCustomNavigationBarView  *navi = [KCLCustomNavigationBarView instance];
    [navi setNavigationItems:self navigationType:KCLNavigationViewTypeTargetMenuOnepass];
    navi.titleLabel.text = @"간편결제";
    [self.view addSubview:navi];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 간편결제 최초 실행시는 initProcessing이 동작하므로 ui만 그려준다
    if (!_isFirstLoaded) {
        [self cardViewLayoutSettingWithResult:dicKATA001Result];
        _isFirstLoaded = YES;
        return;
    }
    
    // ver.3 바코드결제 - 카드및 결제정보 획득 (KATA001)
    if(!self.presentedViewController ||
       (self.presentedViewController
        && !([self.presentedViewController isKindOfClass:[PwdPinViewController class]]
             || [self.presentedViewController isKindOfClass:[PentaPinViewController class]]
             || [self.presentedViewController isKindOfClass:[KCLBarcodeZoomViewController class]])) ) {
        
        // QR 스캔시 refresh 안되게 수정
        if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
             if ([((UINavigationController *)self.presentedViewController).visibleViewController isKindOfClass:[KCLQRScannerViewController class]]) {
                 return;
             }
         }
        
        [self simplePayReoload];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.webView.frame = self.parentView.bounds;
    [((HybridWKWebView*)self.webView) layoutIfNeeded];
}

- (void)viewWillLayoutSubviews {
    NSLog(@"viewWillLayoutSubviews");
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Request
-(void)initPreprocessingCallback:(void (^)(BOOL))callback {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[AppInfo userInfo].custNo forKey:@"custNo"];
    [params setValue:[AppInfo userInfo].kbPin forKey:@"kbPin"];
    
    // ver.3 바코드결제 - 카드및 결제정보 획득 (KATA001)
     [Request requestID:KATA001 body:params waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
         if(IS_SUCCESS(rsltCode)) { //성공일 경우
             self->dicKATA001Result = result;
             callback(YES);
         } else {
             callback(NO);
             [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismisTitle:@"확인"];
         }
     }];
}

-(void)requestOtcNo:(NSDictionary*)cardPwdInfo {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[AppInfo userInfo].custNo forKey:@"custNo"];
    [param setValue:[AppInfo userInfo].kbPin forKey:@"kbPin"];
    
    if(_cardInfo) {//설정된 카드가 있으면 카드비밀번호 요청.
        [param setValue:_cardInfo[@"bacrdPyaccCardNoEcryp"] forKey:@"bacrdPyaccCardNoEcryp"];
        [param setValue:_cardInfo[@"bacrdPyaccCardDst"] forKey:@"bacrdPyaccCardDst"];
        [param addEntriesFromDictionary:cardPwdInfo];
    }
    
     // ver.3 바코드결제 - OTC생성 (KATA002)
    [Request requestID:KATA002 body:param waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
        
        if(IS_SUCCESS(rsltCode)) {
            [self makeBarcodeWithOtcNumber:result[@"otcNo"]];
        }
        else {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismisTitle:@"확인"];
        }
    }];
}

#pragma mark - 간편결제 Hybrid Interface
/**
@var dimmBarcodeView
@brief 바코드 영역 dimm  처리
@param barcodeDimmYn
@return
*/
-(void)dimmBarcodeView:(BOOL)value {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    if(value){
        self.barcodeDimmView.alpha = 0.7;
    }else{
        self.barcodeDimmView.alpha = 0.0;
    }
    [UIView commitAnimations];
}

/**
@var getMyCardList
@brief 원패쓰 결제 카드 목록 전달
@return 카드 목록 전달
*/
-(NSMutableArray *)getMyCardList {
    return _cardArray;
}

-(void)pushNewWebPage:(NSString*)url {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.firstOpenUrl = url;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
@var getReloadPoin
@brief 포인트리 재조회
@return 간편결제에서 사용되고 남은 포인트리
*/
-(NSString *)getReloadPoin {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[AppInfo userInfo].custNo forKey:@"custNo"];
    
    // ver.3 포인트리 조회(세션 없음) (KATPH01)
    [Request requestID:KATPH01
                  body:param
         waitUntilDone:YES
           showLoading:NO
             cancelOwn:self
              finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                  if(IS_SUCCESS(rsltCode)) {
                      self.pointree = [result null_valueForKey:@"searchPoint"];

                      // 위젯에 포인트리 정보 전송부분 추가
                      NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
                      [userDefault setObject:self.pointree forKey:@"WIDGET_POINTREE"];
                      [userDefault synchronize];
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:ReloadPointNotification object:self.pointree];
                  }
              }];
    
    return self.pointree;
}

-(void)reloadPoint {
    NSLog(@"reloadPoint");
    [self updatePointreeViews:[AppInfo sharedInfo].point.formatNumber];
}

- (void)selectCardInfo:(NSDictionary *)cardinfo {
    _cardInfo = cardinfo;
    [self cardViewLayoutSettingWithResult:dicKATA001Result];
}

- (void)simplePayReoload {
    [self initPreprocessingCallback:^(BOOL success) {
        if(success) {
            [self cardViewLayoutSettingWithResult:self->dicKATA001Result];
            [self.webView webViewLoadRequest:self.baseUrlRequest];
            [self dimmBarcodeView:NO];
        } else {
            [self backButtonAction:nil];
        }
    }];
}

#pragma mark - IBAction
//바코드 확대버튼
- (IBAction)zoomButtonAction:(id)sender {
    [AllMenu.delegate navigationWithMenuID:MenuID_PaymentBarcodeZoom animated:NO option:NavigationOptionModal callBack:^(ViewController *vc) {
        ((KCLBarcodeZoomViewController*)vc).codeString = self.barcodeImage.codeStr;
        ((KCLBarcodeZoomViewController*)vc).endTime = self->_endTime;
    }];
    [WebViewController sendGa360Native:YES p1:@"간편결제" p2:@"간편결제" p3:@"바코드확대" campainUrl:nil];
}

//바코드 생성/재생성/포인트리 충전 버튼
- (IBAction)barcodeMakeButtonAction:(id)sender {
    if (sender) {
        NSString * str = ((UIButton *)sender).titleLabel.text;
        str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
        [WebViewController sendGa360Native:YES p1:@"간편결제" p2:@"간편결제" p3:str campainUrl:nil];
    }
    
    if([sender tag] == 1) {//간편결제 카드등록 x 포인트리 0
        [AllMenu.delegate navigationWithMenuID:MenuID_V3_PointreeCharge animated:YES option:NavigationOptionModalPush callBack:^(ViewController *vc) {
            
        }];
        return;
    }
    
    if(_cardArray.count == 0) {//간편결제에 카드등록을 안한경우
        [self requestOtcNo:nil];
    }
    else
    {
        if(_cardInfo) {//선택된 카드가 있을경우
            [PwdWrapper showPwd:^(id  _Nonnull vc) {
                
                [PwdWrapper setTitle:vc value:@"카드 비밀번호 4자리를"];
                [PwdWrapper setSubTitle:vc value:@"입력해 주세요."];
                [PwdWrapper setMaxLen:vc value:4];
                
            } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
                if(isCancel == NO) {
                    NSDictionary * cardPwdInfo = @{@"pwd" : [PwdWrapper doublyEncrypted:vc keyNm:@"pwd"]};
                    [self requestOtcNo:cardPwdInfo];
                }
            }];
        }
        else {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"결제카드 선택 후 바코드를 생성해 주세요." dismisTitle:AlertConfirm];
        }
    }
}

- (IBAction)chargeButtonAction:(id)sender {
    [AllMenu.delegate navigationWithMenuID:MenuID_V3_PointreeCharge animated:YES option:NavigationOptionModalPush callBack:^(ViewController *vc) {

    }];
    
    [WebViewController sendGa360Native:YES p1:@"간편결제" p2:@"간편결제" p3:@"충전" campainUrl:nil];
}

//내역조회 화면으로 이동.
- (IBAction)showListViewButtonAction:(id)sender {
    // Ver. 3 간편결제내역조회
    [AllMenu.delegate navigationWithMenuID:MenuID_V3_PaymentHistory animated:YES option:NavigationOptionModalPush callBack:^(ViewController *vc) {
        
    }];
    [WebViewController sendGa360Native:YES p1:@"간편결제" p2:@"간편결제" p3:@"결제내역" campainUrl:nil];
}

//포인트리 이용내역 화면으로 이동
- (IBAction)pointreeButtonAction:(id)sender {
    [AllMenu.delegate navigationWithMenuID:MenuID_V3_PointreeHistory animated:YES option:NavigationOptionModalPush callBack:^(ViewController *vc) {
        
    }];
    
    [WebViewController sendGa360Native:YES p1:@"간편결제" p2:@"간편결제" p3:@"포인트리조회" campainUrl:nil];
}

//Back 버튼
- (IBAction)backButtonAction:(UIButton*)sender {
    [AllMenu.delegate navigationWithMenuID:MenuID_V4_MainPage animated:YES option:NavigationOptionSetRoot callBack:^(ViewController *vc) {}];

    if([AppInfo sharedInfo].isLogin){ // 로그인시 포인트 재조회 추가
        [[AppInfo sharedInfo] reloadPoint];
    }
}

#pragma mark - private
-(void)cardViewLayoutSettingWithResult:(NSDictionary*)result {
    self.cardInfo = nil;  // 카드 정보에 대한 부분을 받아 올 수 있는지 확인이 필요
    [AppInfo sharedInfo].point =  [result null_valueForKey:@"holdPoint"];
    _cardArray = [result null_valueForKey:@"myCardList"];
    for (int i=0; i<[_cardArray count]; i++) {
        NSDictionary *result = _cardArray[i];
        if([[result null_valueForKey:@"bacrdPyaccCardRegiDst"] intValue] == 10) { // 대표 카드로 설정 되어 있을 경우 (대표카드:10, 그외 연동카드 : 20)
            self.cardInfo = _cardArray[i];
        }
    }
    
    // 카드리스트가 없고 포인트가 0보다 크면 선불카드로 바코드 생성
    if ([AppInfo sharedInfo].point.integerValue > 0 && [_cardArray count] == 0) {
        [self barcodeMakeButtonAction:nil];
    } else {
        self.paymentType =  PaymentViewType_Make;
    }
}

-(void)makeBarcodeWithOtcNumber:(NSString*)otcNumber {
    self.paymentType = PaymentViewType_Barcode;
    _barcodeImage.codeStr = otcNumber;
    _endTime = [NSDate date].timeIntervalSince1970 + ResetTime;
    [self runTime];
}

-(void)runTime
{
    int time = _endTime - [NSDate date].timeIntervalSince1970;
    if(time < 0) {
        self.paymentType = PaymentViewType_ReMake;
    }
    else {
        _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", time/60, time%60];
        [self performSelector:@selector(runTime) withObject:nil afterDelay:1];
    }
}

-(void)stopTime {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runTime) object:nil];
}

-(void)setPaymentType:(PaymentViewType)paymentType {
    if([self.presentedViewController isKindOfClass:[KCLBarcodeZoomViewController class]]) {
        [(ViewController*)self.presentedViewController backButtonAction:nil];
    } else if(self.presentedViewController != nil && [self.presentedViewController isKindOfClass:[PwdWrapper pwdClass]] == NO) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self stopTime];
    _paymentType = paymentType;
    [_barcodeView removeFromSuperview];
    [_barcodeMakeView removeFromSuperview];
    
    _barcodeView.frame = _barcodeContainView.frame;
    _barcodeMakeView.frame = _barcodeContainView.frame;
    switch (_paymentType) {
        case PaymentViewType_Make:
        {
            [_barcodeContainView addSubview:_barcodeMakeView];
            _barcodeMakeButton.tag = 0;
            ((UIImageView*)[_barcodeMakeView viewWithTag:10]).highlighted = NO;
            UILabel *infoLabel = [_barcodeMakeView viewWithTag:12];
            if([AppInfo sharedInfo].point.integerValue <= 0 && _cardArray.count == 0) {
                _barcodeMakeButton.tag = 1;
                [_barcodeMakeButton setTitle:@"포인트리 충전"forState:(UIControlStateNormal)];
                infoLabel.text = @"바코드 결제를 이용하시려면\n포인트리 충전 또는 결제카드를 등록해주세요.";
            }
            else {
                [_barcodeMakeButton setTitle:@"바코드생성"forState:(UIControlStateNormal)];
                if([AppInfo sharedInfo].point.integerValue <= 0) {
                    infoLabel.text = @"포인트리가 부족하여\n연동한 결제카드로 결제됩니다.";
                }
                else {
                    infoLabel.text = @"비밀번호 확인 후 바코드가 생성됩니다.";
                }
            }
        }break;
        case PaymentViewType_ReMake:
        {
             [_barcodeContainView addSubview:_barcodeMakeView];
            _barcodeMakeView.frame = _barcodeContainView.frame;
            _barcodeMakeButton.tag = 0;
            ((UIImageView*)[_barcodeMakeView viewWithTag:10]).highlighted = YES;
            [_barcodeMakeButton setTitle:@"바코드 재생성" forState:(UIControlStateNormal)];
            UILabel *infoLabel = [_barcodeMakeView viewWithTag:12];
            infoLabel.text = @"결제 유효시간이 초과되었습니다.\n바코드를 다시 생성해주세요.";
        }break;
        case PaymentViewType_Barcode:
        {
            if([AppInfo sharedInfo].point.integerValue <= 0 && _cardArray.count == 0) {
                [_barcodeContainView addSubview:_barcodeMakeView];
                _barcodeMakeButton.tag = 0;
                ((UIImageView*)[_barcodeMakeView viewWithTag:10]).highlighted = NO;
                UILabel *infoLabel = [_barcodeMakeView viewWithTag:12];
                
                _barcodeMakeButton.tag = 1;
                [_barcodeMakeButton setTitle:@"포인트리 충전"forState:(UIControlStateNormal)];
                infoLabel.text = @"바코드 결제를 이용하시려면\n포인트리 충전 또는 결제카드를 등록해주세요.";
            } else {
                _barcodeView.frame = _barcodeContainView.frame;
                [_barcodeContainView addSubview:_barcodeView];
            }
        }break;
    }
}

-(void)updatePointreeViews:(NSString*)pointStr {
    NSString *pointFormatString = [NSString stringWithFormat:@"%@ P",pointStr];;
    [_pointreeMakeViewButton setTitle:pointFormatString forState:UIControlStateNormal];
    [_pointreeBarcodeViewButton setTitle:pointFormatString forState:UIControlStateNormal];
}

#pragma mark - keyboard show / hide
-(void)keyboardWillshow:(NSNotification*)notification {
    
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect rect = self.parentView.bounds;
    rect.size.height -= keyboardFrame.size.height;
    self.webView.frame = rect;
}

-(void)keyboardWillHide:(NSNotification*)notification {
    self.webView.frame = self.parentView.bounds;
}
@end
