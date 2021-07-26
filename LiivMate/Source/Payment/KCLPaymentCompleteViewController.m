//
//  KCLPaymentCompleteViewController.m
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLPaymentCompleteViewController.h"

@interface KCLPaymentCompleteViewController () <UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *_scrollView;
    
    __weak IBOutlet UIImageView *_receiptImageView;                 // 영수증 배경 이미지
    
    __weak IBOutlet UILabel *_storeNameLabel;                        // 상호
    __weak IBOutlet UILabel *_storeRegistNoLabel;                    // 대표자 | 사업자등록번호
    __weak IBOutlet UILabel *_storeAddressLabel;                    // 주소 | 전화번호
    __weak IBOutlet UILabel *_storeNumberLabel;                        // 가맹점번호 : 가맹점번호
    __weak IBOutlet UILabel *_cardNoLabel;                            // 카드번호
    __weak IBOutlet UILabel *_buyDateLabel;                            // 거래일시
    __weak IBOutlet UILabel *_buyTypeLabel;                            // 구입형태
    __weak IBOutlet UILabel *_approvalNoLabel;                        // 승인번호
    __weak IBOutlet UILabel *_approvalStatusLabel;                    // 승인상태
    __weak IBOutlet UILabel *_totalPriceLabel;                        // 총 판매금액
    __weak IBOutlet UILabel *_serviceFeeLabel;                        // 봉사료
    __weak IBOutlet UILabel *_discountPriceLabel;                    // 할인금액
    __weak IBOutlet UILabel *_pointreePriceLabel;                    // 포인트리 이용금액
    __weak IBOutlet UILabel *_cardPriceLabel;                        // 카드 이용금액
    __weak IBOutlet UILabel *_paymentPriceLabel;                    // 총 결제금액

    __weak IBOutlet UIView *_stampView;                                // 스탬프 배경 뷰
    __weak IBOutlet NSLayoutConstraint *_stampViewTop;
    __weak IBOutlet UILabel *_stampDescLabel;                        // 스탬프 제공조건 설명
    __weak IBOutlet UILabel *_stampCountLabel;                        // 보유 스탬프 개수
    __weak IBOutlet NSLayoutConstraint *_stampCountLabel2Right;
    __weak IBOutlet UIImageView *_stampLinkImageView;                // >
    __weak IBOutlet UIButton *_stampLinkButton;                        // > 버튼
    
    __weak IBOutlet UILabel *_stampPlusLabel;                        // 스탭프 적립
    __weak IBOutlet UILabel *_stampMinusLabel;                        // 스탭프 차감
    __weak IBOutlet NSLayoutConstraint *_minusH;
    __weak IBOutlet NSLayoutConstraint *_minusB;
    
    __weak IBOutlet UIButton *_buyHistoryButton;                    // 거래내역보기 버튼
    __weak IBOutlet UIButton *_finishButton;                        // 완료 버튼
}
@end

@implementation KCLPaymentCompleteViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    [self initUI];
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - UI Init / Update
- (void)initUI
{
    _scrollView.delegate = self;
    
    [_finishButton setBackgroundImage:[[_finishButton backgroundImageForState:UIControlStateNormal] stretchableImageWithCapWidthRatio:0.5 capHeightRatio:0.5] forState:UIControlStateNormal];
    [_buyHistoryButton setBackgroundImage:[[_buyHistoryButton backgroundImageForState:UIControlStateNormal] stretchableImageWithCapWidthRatio:0.5 capHeightRatio:0.5] forState:UIControlStateNormal];

    // 초기값
    _storeNameLabel.text = @" ";        // @"DADA커피"
    _storeRegistNoLabel.text = @" ";    // @"이승현 | 123-12-12345"
    _storeAddressLabel.text = @" ";        // @"서울시 종로구 청진동 | 02-1111-2222"
    _storeNumberLabel.text = @" ";
    _cardNoLabel.text = @" ";    // @"5658 - 5658 - 5658 - 5658"
    _buyDateLabel.text = @" ";    // @"2018. 05. 28 | 19:18"
    _buyTypeLabel.text = @" ";    // @"일시불"
    _approvalNoLabel.text = @" ";
    _approvalStatusLabel.text = @" ";    // @"정상매입"
    _totalPriceLabel.text = @" ";    // @"10,000"
    _serviceFeeLabel.text = @" ";    // @"1,000"
    _discountPriceLabel.text = @" ";    // @"300"
    _pointreePriceLabel.text = @" ";    // @"7,000"
    _cardPriceLabel.text = @" ";    // @"3,000"
    _paymentPriceLabel.text = @" ";    // @"9,700"
    _stampPlusLabel.text = @"";    // @"100"
    _stampMinusLabel.text = @"";    // @"300"

    [self showStampView:NO animated:NO];
}

- (void)updateUI
{
    // 데이터 매핑
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.dicParam];
    for (NSString *key in self.dicParam.allKeys)
    {
        if ([self.dicParam[key] isKindOfClass:[NSNull class]])
        {
            dic[key] = nil;
        }
    }
    self.dicParam = dic;
    
    _storeNameLabel.text = self.dicParam[@"mbrmchName"];        // @"DADA커피"
    _storeRegistNoLabel.text = [NSString stringWithFormat:@"%@ | %@", (self.dicParam[@"rprsName"] ?: @""), (self.dicParam[@"bzno"] ?: @"")];    // @"이승현 | 123-12-12345"
    _storeAddressLabel.text = [NSString stringWithFormat:@"%@ | %@", (self.dicParam[@"mbrmchAddr"] ?: @""), (self.dicParam[@"mbrmchTelno"] ?: @"")];    // @"서울시 종로구 청진동 | 02-1111-2222"
    _storeNumberLabel.text = [NSString stringWithFormat:@"가맹점번호 | %@", (self.dicParam[@"mbrmchNo"] ?: @"")];
    _cardNoLabel.text = self.dicParam[@"cardNo"];        // @"5658 - 5658 - 5658 - 5658"
    
    NSString *dateStr = [NSString stringWithFormat:@"%@%@", self.dicParam[@"tranYmd"], self.dicParam[@"tranHMS"]];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyyMMddHHmm"];
    NSDate *date = [fmt dateFromString:dateStr];
    [fmt setDateFormat:@"yyyy. MM. dd | HH:mm"];
    _buyDateLabel.text = [fmt stringFromDate:date];// @"2018. 05. 28 | 19:18"
    
    // 할부개월수 (60: 일시불, 62, 63 ...  : x-60    ->  0)
    int intmMnths = [self.dicParam[@"intmMnths"] intValue];
    NSString *buyType = (intmMnths == 0 ? @"일시불" : [NSString stringWithFormat:@"%d개월", intmMnths]);
    _buyTypeLabel.text = buyType;    // @"일시불"
    
    _approvalNoLabel.text = self.dicParam[@"cardAthorNo"];
    _approvalStatusLabel.text = self.dicParam[@"dstStus"];    // @"정상매입"
    _totalPriceLabel.text = [([self.dicParam[@"tranAmt"] stringValue] ?: @"0") formatNumber];        // @"10,000"
    _serviceFeeLabel.text = [([self.dicParam[@"serviceAmt"] stringValue] ?: @"0") formatNumber];        // @"1,000"
    _discountPriceLabel.text = [([self.dicParam[@"dcAmt"] stringValue] ?: @"0") formatNumber];    // @"300"
    _pointreePriceLabel.text = [([self.dicParam[@"pointUseAmt"] stringValue] ?: @"0") formatNumber];    // @"7,000"
    _cardPriceLabel.text = [([self.dicParam[@"cardPyaccAmt"] stringValue] ?: @"0") formatNumber];        // @"3,000"
    _paymentPriceLabel.text = [([self.dicParam[@"totAmt"] stringValue] ?: @"0") formatNumber];    // @"9,700"
    
    //long pointreePrice = [self.dicParam[@"totAmt"] longValue] - [self.dicParam[@"cardPyaccAmt"] longValue];
    //_pointreePriceLabel.text = [[NSString stringWithFormat:@"%ld", pointreePrice] formatNumber];    // @"7,000"

    //_stampDescLabel.text = self.dicParam[@""];    // @"5000원 구매 시 스탬프 1개 제공\n스탬프 10개에 아메리카노 1잔 무료"
    //_stampCountLabel.text = self.dicParam[@""];    // @"3"
    
    _stampPlusLabel.text = [NSString stringWithFormat:@"%d개",[self.dicParam[@"stmpInsSubtrCtnt"] intValue]];    // @"3"
    if([self.dicParam[@"stmpSubtrCtnt"] length] != 0)
    {
        _stampMinusLabel.text = [NSString stringWithFormat:@"%d개",[self.dicParam[@"stmpSubtrCtnt"] intValue]];    // @"10"
        //10개(아메리카노 1잔 증정), 10개(1000원 할인) ...
        NSString *appendStr = [NSString stringWithFormat:@"%@",([self.dicParam[@"stmpSubtrBoonDstcd"] integerValue] == 3 ? self.dicParam[@"stmpSubtrPrsntnPrdctCtnt"] : self.dicParam[@"dcRate"])];
        if(appendStr.length)
            _stampMinusLabel.text = [_stampMinusLabel.text stringByAppendingFormat:@"(%@)",appendStr];
    }
    
    if(_stampMinusLabel.text.length == 0)
    {
        _minusH.constant = 0;
        _minusB.constant = 0;
    }
    
    [self showStampView:[self.dicParam[@"stmpSubtrStorYn"] boolValue] animated:NO];
}

- (void)showStampView:(BOOL)show animated:(BOOL)animated
{
    if (show)
    {
        // 보유 스탬프 버튼 disable
        if ([_stampCountLabel.text intValue] == 0)
        {
            _stampCountLabel2Right.constant = 0;
            _stampLinkImageView.hidden = YES;
            _stampLinkButton.hidden = YES;
        }
        else
        {
            _stampCountLabel2Right.constant = 20;
            _stampLinkImageView.hidden = NO;
            _stampLinkButton.hidden = NO;
        }
        
        _stampViewTop.constant = 13.5;
        _stampView.alpha = 1.0;
    }
    else
    {
        _stampViewTop.constant = -1 * _stampView.frame.size.height + 13;
        _stampView.alpha = 0.0;
    }
    
    // 애니메이션
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:(animated ? 0.3 : 0.0) animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Button Action
- (IBAction)stampLinkButtonClicked:(id)sender
{
    // 보유 스탬프 버튼 클릭 처리 -> 기획 삭제
    NSLog(@"%s", __FUNCTION__);
}

- (IBAction)finishButtonClicked:(id)sender
{
    // 완료 버튼 클릭
    [[AllMenu delegate] goMainViewControllerAnimated:YES];
}

- (IBAction)buyHistoryButtonClicked:(id)sender
{
   // 간편결제내역조회 거래내역보기 버튼 클릭
   [AllMenu.delegate navigationWithMenuID:MenuID_V3_PaymentHistory animated:YES option:NavigationOptionPush callBack:^(ViewController *vc) {
   }];
}

- (IBAction)installmentTransactionContractButtonClicked:(id)sender
{
    // 할부거래계약서 보기
    [AllMenu.delegate navigationWithMenuID:MenuID_InstTransactionContract animated:YES option:NavigationOptionPush callBack:^(ViewController *vc) {
    }];
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
