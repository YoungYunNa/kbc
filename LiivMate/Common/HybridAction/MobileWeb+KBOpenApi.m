//
//  MobileWeb+KBOpenApi.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 8. 7..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "MobileWeb+KBOpenApi.h"
#import "NSString+Util.h"

@interface KBOpenApiTermDetailVC ()
@end

@implementation KBOpenApiTermDetailVC
-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * htmlStr = [_agreeBody stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<option class=\"apiAgreeHL\">" withString:@"<big><u><font color=\"#000000\"><b>"];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"</option>" withString:@"</b></font></u></big>"];
    htmlStr = [NSString stringWithFormat:@"<html><body style=\"font-style: normal;font-size: 13px;margin-left: 16px;margin-top: 16px;\">%@</body></html>",htmlStr];
    
    [(HybridWKWebView *)self.webView loadHTMLString:htmlStr baseURL:nil];
}
@end


@implementation OpenApiTermCell

- (IBAction)onClickedTrimChecked:(UIButton *)sender {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(onClickedTrimChecked:)]) {
            sender.tag = self.tag;
            [_delegate onClickedTrimChecked:sender];
        }
    }
}

- (IBAction)onClickedDetailTrimButton:(UIButton *)sender {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(onClickedDetailTrimButton:)]) {
            sender.tag = self.tag;
            [_delegate onClickedDetailTrimButton:sender];
        }
    }
}
@end

@interface KBOpenApiTermVC_V2 : ViewController <UITableViewDataSource, UITableViewDelegate, OpenApiTermCellgDelegate>
@property (weak, nonatomic) IBOutlet LMButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *termCheckButton;
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UILabel * lblTermInfo;
@property (weak, nonatomic) IBOutlet UIView *parentView;
@property (strong, nonatomic) WKWebView *webView;
@property (nonatomic, strong) NSArray * termKeys;   //
@property (nonatomic, strong) NSDictionary * terms;
@property (nonatomic, strong) NSMutableArray * arrList;
@property (nonatomic, strong) NSString * info;

@property (nonatomic, copy) void (^confirmCallBack) (BOOL isConfirm, NSDictionary * term);
@end

@implementation KBOpenApiTermVC_V2

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[WKWebView alloc] init];
    [self.parentView addSubview:self.webView];

    
    _arrList = [[NSMutableArray alloc] init];
    
    if (!nilCheck(_info)) {
        _lblTermInfo.text = _info;
    }
    
    // term key
    for (NSDictionary * term in _termKeys) {
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict addEntriesFromDictionary:term];
        
        NSString * valId = nilCheck(_terms[term[@"idKey"]]) ? @"" : _terms[term[@"idKey"]];
        NSString * valVer = nilCheck(_terms[term[@"verKey"]]) ? @"" : _terms[term[@"verKey"]];
        NSString * valBody = nilCheck(_terms[term[@"bodyKey"]]) ? @"" : _terms[term[@"bodyKey"]];
        
        [dict setObject:valId forKey:term[@"idKey"]];
        [dict setObject:valBody forKey:term[@"bodyKey"]];
        [dict setObject:valVer forKey:term[@"verKey"]];
        [dict setObject:@"N" forKey:@"agreeYN"];
        
        [_arrList addObject:dict];
    }
    
    [_tableView reloadData];
    
    [self loadAgreementHtmlString : _arrList];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.webView.frame = self.parentView.bounds;
}

-(void)loadAgreementHtmlString:(NSMutableArray *)arrayList {
    NSDictionary *dic = arrayList[0];
    
    NSString *strTitle = dic[@"title"];
    NSString *_agreeBody = dic[dic[@"bodyKey"]];
    NSLog(@"strTitle == %@", strTitle);
    NSLog(@"_agreeBody == %@", _agreeBody);
    
//    NSString *_agreeBody = @"개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.";
    
    NSString * htmlStr = [_agreeBody stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<option class=\"apiAgreeHL\">" withString:@"<big><u><font color=\"#000000\"><b>"];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"</option>" withString:@"</b></font></u></big>"];
        htmlStr = [NSString stringWithFormat:@"<html><body style=\"font-style: normal;font-size: 13px;margin-left: 16px;margin-top: 16px;\">%@</body></html>",htmlStr];
        
    [self.webView loadHTMLString:htmlStr baseURL:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OpenApiTermCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpenApiTermCell"];
    
    NSDictionary * info = _arrList[indexPath.row];
    
    [cell.btnTitle setTitle:info[@"title"] forState:UIControlStateNormal];
    cell.btnTitle.tag = indexPath.row;
    cell.tag = indexPath.row;
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

-(void)backButtonAction:(UIButton *)sender {
    [super backButtonAction:sender];
    if(_confirmCallBack)
    {
        _confirmCallBack(NO, nil);
    }
}

//약관 상세 이동
-(IBAction)onClickedDetailTrimButton:(UIButton*)sender {
    NSDictionary * term = _arrList[sender.tag];
    
    NSString *strTitle = term[@"title"];
    NSString *strAgreeBody = term[term[@"bodyKey"]];
    
    if(strTitle)
    {
        KBOpenApiTermDetailVC *vc = [[KBOpenApiTermDetailVC alloc] init];
        vc.title = strTitle;//@"개인정보 제3자 제공 동의(필수)";
        vc.agreeBody = strAgreeBody;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(IBAction)onClickedTrimChecked:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    NSMutableDictionary * term = _arrList[sender.tag];
    [term setObject:sender.selected?@"Y":@"N" forKey:@"agreeYN"];
}

// 리브메이트 약관 3.0 확인버튼
-(IBAction)onClickedConfirmButton:(id)sender {
    // term 정보가공
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];

    for (NSDictionary * term in _arrList) {

        [dict setObject:term[term[@"idKey"]] forKey:term[@"idKey"]];
        [dict setObject:term[term[@"verKey"]] forKey:term[@"verKey"]];
        [dict setObject:@"Y" forKey:term[@"agreeKey"]];
    }
    
    _confirmCallBack(YES, dict);
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end

@implementation requestKBBankOpenAPI
{
    NSDictionary *_resultDic;
    OpenAPIAuth_V2 *openApi;
}

- (void)run {
    _resultDic = [NSMutableDictionary dictionary];
    
    if (openApi == nil) {
        openApi = [[OpenAPIAuth_V2 alloc] init];
        openApi.service = self;
        openApi.webView = self.webView;
        openApi.failCallback = self.failCallback;
        openApi.successCallback = self.successCallback;
        openApi.paramDic = self.paramDic;
        openApi.tag = self.tag;
        openApi.authData = [openApi getDefaultData:@"KBBANK"];
    }
    
    [openApi goAuthProcess:openApiType_requestKBBankOpenAPI callback:^(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd) {
        
        if (success) {
            [self requestKBBankOpenAPI];
        }
    }];
}
- (void)requestKBBankOpenAPI {
    NSString *cms = self.paramDic[@"reqURL"];
    NSString *tran_dstcd = self.paramDic[@"tran_dstcd"];
    NSDictionary *reqData = self.paramDic[@"reqData"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:reqData.jsonString forKey:@"reqData"];
    [param setObject:tran_dstcd forKey:@"tran_dstcd"];
    [param setObject:[openApi getCMSUrl:cms] forKey:@"url"];
    [param setValue:[openApi getBase64Str:openApi.accessToken] forKey:@"accessToken"];
    [param setValue:OPEN_API_CLIENT_ID forKey:@"clientId"];
    
    [openApi requestAuthOpenApi:OPENAPI_PARAM_KEY_API
                           type:openApiType_requestKBBankOpenAPI
                          param:param callback:^(BOOL success, NSString *step, NSDictionary *result, NSInteger statusCd) {
                              
                          if (success) {
                              [self finishedActionWithResult:result success:YES];
                          } else {
                             
                              NSMutableDictionary *newResult = [result mutableCopy];
                              @try {
                                  
                                  [newResult setObject:result[@"errCode"] forKey:@"rsltCode"];
                                  [newResult setObject:result[@"resultMessage"] forKey:@"message"];
                                  [newResult setObject:[NSNumber numberWithInteger:statusCd] forKey:@"statusCd"];
                                  [newResult setObject:[NSNumber numberWithInteger:4] forKey:@"step"];
                                  
                              } @catch (NSException *exception) {
                                  [newResult setObject:exception.description forKey:@"catch"];
                              } @finally {
                                  [self finishedActionWithResult:newResult success:NO];
                              }
                          }
                      }];
}
@end

@implementation OpenAPIAuth_V2
-(id)init {
    self = [super init];
    if (self) {
        if (![AppInfo sharedInfo].openApiAuthTokens) {
             [AppInfo sharedInfo].openApiAuthTokens = [NSMutableDictionary dictionary];
        }
    }
    
    return self;
}

- (void)goAuthProcess:(openApiType)type callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback {
    // ci 획득
    if([AppInfo userInfo].userCI.length == 0) {
        [self requestUserCI:type callback:finishedCallback];
        return;
    } else {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict addEntriesFromDictionary:_authData[OPENAPI_PARAM_KEY_SAML]];
        [dict setObject:[self getBase64Str:[AppInfo userInfo].userCI] forKey:@"ciNo"];
        [_authData setObject:dict forKey:OPENAPI_PARAM_KEY_SAML];
    }
    
    // 전역메모리에 리퀘스트와 결과값이 있는지 확인후 samlAssertion 제셋팅
    self.samlAssertion = [[AppInfo sharedInfo].openApiAuthTokens null_valueForKey:_authData[@"actionKey"]][@"samlAssertion"];
    
    // samlAssertion 획득
    if (self.samlAssertion.length == 0) {
        [self requestAuthOpenApi:OPENAPI_PARAM_KEY_SAML type:type callback:finishedCallback];
        return;
    } else {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict addEntriesFromDictionary:_authData[OPENAPI_PARAM_KEY_TOKEN]];
        [dict setObject:[self getBase64Str:self.samlAssertion] forKey:@"samlAssertion"];
        [_authData setObject:dict forKey:OPENAPI_PARAM_KEY_TOKEN];
    }
    
    // 전역메모리에 리퀘스트와 결과값이 있는지 확인후 accessToken 제셋팅
    self.accessToken = [[AppInfo sharedInfo].openApiAuthTokens null_valueForKey:_authData[@"actionKey"]][@"accessToken"];

    // 토큰 획득
    if (self.accessToken.length == 0) {

        [self requestAuthOpenApi:OPENAPI_PARAM_KEY_TOKEN type:type callback:finishedCallback];
        return;
    }
    
    if (finishedCallback) {
        finishedCallback(YES, OPENAPI_PARAM_KEY_API, nil, 200);
    }
}

- (void)requestUserCI:(openApiType)type callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback {
    BOOL isShowLoading = [self showProgress:@"CI"];
    
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:[AppInfo userInfo].custNo, @"custNo", nil];
    
    // Ver. 3 충전하기 CI조회(KATPC20)
    [Request requestID:KATPC20
                  body:param
         waitUntilDone:NO
           showLoading:isShowLoading
             cancelOwn:self
              finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                  if(IS_SUCCESS(rsltCode) || [rsltCode isEqualToString:@"200"])
                  {
                      [AppInfo userInfo].userCI = result[@"ci"]; // App에서 확인 할수 없는 정보이나, OPEN API 사용을 위해 허용 됨.
                      [self goAuthProcess:type callback:finishedCallback];
                      
                  } else
                  {
                      [self finishedActionWithResult:result success:NO];
                      [self hideProgress];
                  }
              }];
}

// 인증 리퀘스트 공통
- (void)requestAuthOpenApi:(NSString *)reqType type:(openApiType)type callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback {
    [self requestAuthOpenApi:reqType type:type param:self.authData[reqType] callback:finishedCallback];
}

// 인증 리퀘스트 공통
- (void)requestAuthOpenApi:(NSString *)reqType type:(openApiType)type param:(NSMutableDictionary *)reqParam callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback {
    Request *req = [self settingRequest:reqParam[@"url"]];
    
    req.showLoading = [self showProgress:reqType];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param addEntriesFromDictionary:reqParam];
    [param removeObjectForKey:@"url"];
    
#if 0
    NSData * jsonData = nil;
    if ([OPENAPI_PARAM_KEY_API isEqualToString:reqType] && type == openApiType_requestKBOpenApi) {
        jsonData = [NSJSONSerialization dataWithJSONObject:param
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    } else {
        NSString *paramEnc = [NSString urlEncodedQueryString:param];
        jsonData = [paramEnc dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    }
#else
    NSString *paramEnc = [NSString urlEncodedQueryString:param];
//    NSData * jsonData = [paramEnc dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_KR) allowLossyConversion:YES];
    
    NSData * jsonData = [paramEnc dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
#endif
    
    
    [req setValue:[NSString stringWithFormat:@"%d", ((int)[jsonData length])] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:jsonData];
    
    [req sendDataTask:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            [req performSelectorOnMainThread:@selector(remove) withObject:nil waitUntilDone:NO];
            
            if (statusCode / 100  * 100 == 200) {
                // 네트워크 통신 성공
                NSDictionary *resultDic = [self jsonDataToDictionary:data];
                BOOL isOpenApiSpec = [self isOpenApiResType:data];
                
                if (!resultDic || !isOpenApiSpec) {
                    // 파싱 결과 json객체 생성안될경우
                    NSString * strResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"response : %@", strResult);
                    strResult = nilCheck(strResult) ? @"" : strResult;
                    
                    NSDictionary * dict = @{
                        @"resCd" : resultDic ? mobWeb_openapi_not_spec :mobWeb_openapi_not_jsonStr,
#ifdef DEBUG
                        @"errBody" : strResult
#endif
                    };
                    
                    [self callCommonError:reqType result:dict
                               statusCode:statusCode callback:finishedCallback];
                    return;
                }
                
                NSString *strErrCode = resultDic[@"errCode"];
                NSString *msg = resultDic[@"resultMessage"];
                
                // open api 마지막(??)리퀘스트는 각 클래스에서 처리 받아오는 값이 다르기 때문
                if ([OPENAPI_PARAM_KEY_API isEqualToString:reqType]) {
                    
                    if(!IS_SUCCESS(strErrCode) && !nilCheck(msg) && [msg rangeOfString:@"expired"].location != NSNotFound) {
                       // 세션 만료
                        [self expiredToken:self->_authData[OPENAPI_PARAM_KEY_TOKEN]];
                        [self->_service run];
                        return;
                    }
                    
                    if (finishedCallback) {
                        if (type == openApiType_requestKBOpenApi) {
                            finishedCallback(YES, reqType, resultDic, ((NSHTTPURLResponse *)response).statusCode);
                        } else {
                            finishedCallback(IS_SUCCESS(strErrCode), reqType, resultDic, ((NSHTTPURLResponse *)response).statusCode);
                        }
                        
                    }
                    return;
                }
                
                if(IS_SUCCESS(strErrCode)) { // 성공  openapi auth관련 성공,
                    
                    if ([OPENAPI_PARAM_KEY_SAML isEqualToString:reqType]) {
                        NSDictionary * value = @{
                            @"samlAssertion" : resultDic[@"samlAssertion"]
                        };
                        [[AppInfo sharedInfo].openApiAuthTokens setObject:value forKey:self->_authData[@"actionKey"]];
                
                    } else if([OPENAPI_PARAM_KEY_TOKEN isEqualToString:reqType]) {
                        
                        NSDictionary * value = @{
                            @"samlAssertion" : self.samlAssertion,
                            @"accessToken" : resultDic[@"accessToken"],
                        };
                        
                        [[AppInfo sharedInfo].openApiAuthTokens setObject:value forKey:self->_authData[@"actionKey"]];
                    }
                    
                    [self goAuthProcess:type callback:finishedCallback];
                } else { // 실패
                    if([@"9000" isEqualToString:strErrCode])
                    { // 약관동의 화면으로
                        
                        if ([@"Y" isEqualToString:self->_authData[OPENAPI_PARAM_KEY_TERM][@"autoAgreeProc"]]) {
                            
                            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                            
                            for (NSDictionary * term in self->_authData[OPENAPI_PARAM_KEY_TERM][@"termInfo"]) {
                                
                                NSString * valId = nilCheck(resultDic[term[@"idKey"]]) ? @"" : resultDic[term[@"idKey"]];
                                NSString * valVer = nilCheck(resultDic[term[@"verKey"]]) ? @"" : resultDic[term[@"verKey"]];

                                [dict setObject:valId forKey:term[@"idKey"]];
                                [dict setObject:valVer forKey:term[@"verKey"]];
                                [dict setObject:@"Y" forKey:term[@"agreeKey"]];
                            }
                            
                            [self requestAgreeTerm:dict type:type];
                            return;
                        }
                        
                        [BlockAlertView showBlockAlertWithTitle:@"알림" message:resultDic[@"resultMessage"] dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                            
                            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MobileWeb" bundle:nil];
                            KBOpenApiTermVC_V2 *vc = [storyBoard instantiateViewControllerWithIdentifier:@"KBOpenApiTermVC_V2"];
                            vc.terms = resultDic;
                            vc.termKeys = self->_authData[OPENAPI_PARAM_KEY_TERM][@"termInfo"];
                            vc.info = self->_authData[OPENAPI_PARAM_KEY_TERM][@"termSubTitle"];
                            if (!nilCheck(self->_authData[OPENAPI_PARAM_KEY_TERM][@"termTitle"])) {
                                vc.title = self->_authData[OPENAPI_PARAM_KEY_TERM][@"termTitle"];
                            }
  
                            vc.modalPresentationStyle = UIModalPresentationCustom;
                            [vc setConfirmCallBack:^(BOOL isConfirm, NSDictionary *dict) {
                                NSLog(@"requestOpenApiTerm");
                                if(isConfirm) {
                                    
                                    [self requestAgreeTerm:dict type:type];
                                    
                                } else {
                                    
                                    NSDictionary * dict = @{
                                        @"resCd" : mobWeb_openapi_term_cancel,
                                        @"resultMessage" : @"termCancel"
                                    };

                                    [self finishedActionWithResult:dict success:NO];
                                }
                            }];
                            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                            
                            [self.webView.parentViewController presentViewController:nvc animated:YES completion:^{}];
                        } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
                    } else { // 그외 실패
                        
                        [self callCommonError:reqType result:resultDic statusCode:statusCode callback:finishedCallback];
                    }
                    
                    [self hideProgress];
                }
                
            } else {
                
                [self callCommonError:reqType result:nil statusCode:statusCode callback:finishedCallback];
                
                [self hideProgress];
            }
        });
    }];
}

- (void)requestAgreeTerm:(NSDictionary *)dict type:(openApiType)type {
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param addEntriesFromDictionary:dict];
    [param setValue:@"LM" forKey:@"usrAgent"];
    [param setValue:@"insertAgree" forKey:@"agreePage"];
    [param setValue:[self getBase64Str:[AppInfo userInfo].userCI] forKey:@"ciNo"];
    [param setValue:OPEN_API_CLIENT_ID forKey:@"clientId"];
    [param setValue:self->_authData[OPENAPI_PARAM_KEY_TERM][@"url"] forKey:@"url"];
    
    [self requestAuthOpenApi:OPENAPI_PARAM_KEY_TERM type:type param:param callback:^(BOOL success, NSString *step, NSDictionary *result, NSInteger statusCd) {
        
        if (success) {
            [self->_service run];
        } else {
            
        }
    }];
}

#ifdef DEBUG
- (void)requestDelAgree {
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:[AppInfo userInfo].custNo, @"custNo", nil];
    
    // Ver. 3 충전하기 CI조회(KATPC20)
    [Request requestID:KATPC20
             body:param
    waitUntilDone:NO
      showLoading:YES
        cancelOwn:self
         finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
             if(IS_SUCCESS(rsltCode))
             {
                 Request *req = [self settingRequest:[self getCMSUrl:@"CXOXXOOC0004.cms"]];
                 req.showLoading = YES;
                 
                 NSMutableDictionary *param = [NSMutableDictionary dictionary];
                 
                 [param setValue:@"LM" forKey:@"usrAgent"];
                 [param setValue:@"deleteAgree" forKey:@"agreePage"];
                 [param setValue:[self getBase64Str:result[@"ci"]] forKey:@"ciNo"];
                 [param setValue:OPEN_API_CLIENT_ID forKey:@"clientId"];
                 
                 NSString *paramEnc = [NSString urlEncodedQueryString:param];
                 NSData *jsonData = [paramEnc dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                 [req setValue:[NSString stringWithFormat:@"%d", ((int)[jsonData length])] forHTTPHeaderField:@"Content-Length"];
                 [req setHTTPBody:jsonData];
                 
                 [req sendDataTask:^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSLog(@">>>>>> %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                         
                         NSDictionary* result = [self jsonDataToDictionary:data];
                         
                         if (result[@"resultMessage"]) {
                             [BlockAlertView showBlockAlertWithTitle:@"알림" message:result[@"resultMessage"] dismisTitle:@"확인"];
                         }
                         
                         [AppInfo sharedInfo].openApiAuthTokens = nil;
                         [req performSelectorOnMainThread:@selector(remove) withObject:nil waitUntilDone:NO];
                     });
                 }];
             }
         }];
}

#endif

- (void)callCommonError:(NSString *)reqType result:(NSDictionary *)dict statusCode:(NSInteger)statusCode  callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback {
    NSMutableDictionary *newResult = [NSMutableDictionary dictionary];
    NSInteger step = 0;
    if ([OPENAPI_PARAM_KEY_SAML isEqualToString:reqType]) step = 1;
    else if ([OPENAPI_PARAM_KEY_TOKEN isEqualToString:reqType]) step = 2;
    else if ([OPENAPI_PARAM_KEY_TERM isEqualToString:reqType]) step = 3;
    else if ([OPENAPI_PARAM_KEY_API isEqualToString:reqType]) step = 4;
   
    NSDictionary * retValue = @{@"statusCd" : [NSNumber numberWithInteger:statusCode],
                               @"step" : [NSNumber numberWithInteger:step]
                               };
    
    [newResult addEntriesFromDictionary:retValue];
    
    if (dict) {
        [newResult addEntriesFromDictionary:dict];
    }
    
    if (finishedCallback) {
        finishedCallback(NO, reqType, newResult, statusCode);
    }
}

- (NSString *)getCMSUrl:(NSString *)reqCMS {
//    NSString *url = @"https://m.kbcard.com/CXOXXOOC0004.cms?responseContentType=json"; // 운영
//    NSString *url = @"https://dmobileapps.kbcard.com:15000/CXOXXOOC0004.cms?responseContentType=json"; // 개발
    
    NSString *apiUrl = OPEN_API_SERVER_URL;
#ifdef SELECT_SERVER
    if ([SERVER_URL hasPrefix:@"https://sm."]) {
        apiUrl = OPEN_API_SERVER_URL2;
    }
#endif
    
    return [NSString stringWithFormat:@"%@/%@?responseContentType=json", apiUrl, reqCMS];
}

- (Request *)settingRequest:(NSString *)reqCMS {

    NSURL *url = [NSURL URLWithString:reqCMS];
    Request *req = [Request requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return req;
}

- (NSString *)getBase64Str:(NSString *)str {
    NSString *strReplace = str.stringByUrlEncoding;    
    NSString *base64EncodedString = [[strReplace dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    return base64EncodedString;
}

/**
 @var jsonDataToDictionary
 @brief NSData를 json데이타로 변경 만약 array일시 배열의 첫번째 데이타 반환
 @param json data
 @return json 객체
 */
- (NSDictionary *)jsonDataToDictionary:(NSData *)data {
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers
                                                error:nil];
    
    NSLog (@"response : %@", json);
    
    if (!json) return nil;
    
    if ([json isKindOfClass:[NSArray class]]) {
        NSArray * array = json;
        return array.count == 0 ? @{} : array[0];
    }
    
    return json;
}

- (BOOL)isOpenApiResType:(NSData *)data {
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers
                                                error:nil];
    
    if (!json) return NO;
    
    return [json isKindOfClass:[NSArray class]] ? YES : NO;
}

- (NSMutableDictionary *)getDefaultData:(NSString *)actionKey {
    NSMutableDictionary * info = [[NSMutableDictionary alloc] init];
    NSDictionary * samlInfo = @{
                                @"usrAgent" : @"LM",
                                @"clientId" : OPEN_API_CLIENT_ID,
                                @"url" : [self getCMSUrl:@"CXOXXOOC0003.cms"]
                                };
    NSDictionary * tokenInfo = @{
                                 @"url" : [self getCMSUrl:@"CXOXXOOC0006.cms"],
                                 @"clientId" : OPEN_API_CLIENT_ID,
                                 @"clientSecret" : OPEN_API_CLIENT_SECRET,
                                 @"grantType" : @"urn:ietf:params:oauth:grant-type:saml2-bearer",
                                 @"targetInstitution" : @"KBBANK",
                                 };
    NSDictionary * termInfo = @{
                                @"url" : [self getCMSUrl:@"CXOXXOOC0004.cms"],
                                @"termTitle" : @"KB금융오픈API서비스약관동의",
                                @"termSubTitle" : @"KB국민은행 잔액 조회 이용에 필요한 약관입니다.",
                                @"termInfo" : @[
                                        @{
                                            @"title" : @"고객정보 수집, 이용 제공 동의",
                                            @"idKey" : @"collAgreeId",
                                            @"bodyKey" : @"collAgreeBody",
                                            @"verKey" : @"collAgreeVer",
                                            @"agreeKey" : @"collAgreeYn"
                                            }
                                        ]
                                };
    
    [info setObject:samlInfo forKey:OPENAPI_PARAM_KEY_SAML];
    [info setObject:tokenInfo forKey:OPENAPI_PARAM_KEY_TOKEN];
    [info setObject:termInfo forKey:OPENAPI_PARAM_KEY_TERM];
    [info setObject:actionKey forKey:@"actionKey"];
    
    return info;
}

- (void)expiredToken:(NSDictionary *)param {
    self.accessToken = nil;
    self.samlAssertion = nil;
    
    NSDictionary * tempData = [[AppInfo sharedInfo].openApiAuthTokens objectForKey:_authData[@"actionKey"]];
    NSMutableDictionary * saveData = [NSMutableDictionary dictionary];
    [saveData addEntriesFromDictionary:tempData];
    [saveData removeObjectForKey:@"accessToken"];
    [saveData removeObjectForKey:@"samlAssertion"];
    
    [[AppInfo sharedInfo].openApiAuthTokens setObject:saveData forKey:_authData[@"actionKey"]];
}

- (BOOL)showProgress:(NSString *)reqType {
    BOOL retValue = NO;
    NSString *tran_dstcd = self.paramDic[@"tran_dstcd"];
    if ([tran_dstcd isEqualToString:@"KB100"]) {
        retValue = NO;
        [GifProgress showGifWithName:gifType_heart completion:nil];
    }else {
        retValue = YES;
    }
    
    return retValue;
}

- (void)hideProgress {
    NSString *tran_dstcd = self.paramDic[@"tran_dstcd"];
    if ([tran_dstcd isEqualToString:@"KB100"]) {
        [GifProgress hideGif:nil];
    }
}
@end


@implementation requestBalance {
    NSString *_chrgMnsNo;
    
    NSDictionary *_resultDic;
    OpenAPIAuth_V2 *openApi;
}

-(void)run {
    //계좌번호
    _chrgMnsNo = self.paramDic[@"chargMnsNo"];
    if(_chrgMnsNo.length == 0)
    {
        [self finishedActionWithResult:@{@"resultMessage" : @"notAccountNo"} success:NO];
        return;
    }
    
    _resultDic = [NSMutableDictionary dictionary];
    
    if (openApi == nil) {
        openApi = [[OpenAPIAuth_V2 alloc] init];
        openApi.service = self;
        openApi.webView = self.webView;
        openApi.failCallback = self.failCallback;
        openApi.successCallback = self.successCallback;
        openApi.paramDic = self.paramDic;
        openApi.tag = self.tag;
        openApi.authData = [openApi getDefaultData:@"KBBANK"];
    }
    
    [openApi goAuthProcess:openApiType_requestBalance callback:^(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd) {
        
        if (success) {
            [self requestBalance:self->openApi.accessToken];
        }
    }];
}

-(void)success {
    [self finishedActionWithResult:_resultDic success:YES];
}


// 계좌 잔액 정보 요청
- (void)requestBalance:(NSString *)accessToken {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[openApi getCMSUrl:@"CXOXXBAC0001.cms"] forKey:@"url"];
    [param setValue:OPEN_API_CLIENT_ID forKey:@"clientId"];
    [param setValue:_chrgMnsNo forKey:@"accntNo"];
    [param setValue:[openApi getBase64Str:accessToken] forKey:@"accessToken"];
    
    [openApi requestAuthOpenApi:OPENAPI_PARAM_KEY_API
                           type:openApiType_requestBalance
                          param:param callback:^(BOOL success, NSString *step, NSDictionary *result, NSInteger statusCd) {
                              
                              if (success) {
                                  [self->_resultDic setValue:result forKey:@"balance"];
                                  [self requestTrstnHstry:accessToken];
                              } else {
                                  NSString *msg = result[@"resultMessage"];
                                  NSDictionary * retValue = @{@"statusCd" : [NSNumber numberWithInteger:statusCd],
                                                              @"step" : [NSNumber numberWithInteger:4]
                                                              };
                                  
                                  if (msg) {
                                      [BlockAlertView showBlockAlertWithTitle:@"알림" message:msg dismisTitle:@"확인"];
                                  }
                                  [self finishedActionWithResult:retValue success:NO];
                              }
                          }];
}

// 거래 내역 정보 요청
- (void)requestTrstnHstry:(NSString *)accessToken {
    // 오늘로부터 3개월(90일) 전의 날짜 계산, 우선 최근 1주일간에 대해 조회
    NSDate *endDate = [NSDate date];
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comps = [cal components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:endDate];
    [comps setDay:comps.day -6];
    NSDate *startDate = [cal dateFromComponents:comps];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"]; // 20170717
    NSString *strStartDate = [dateFormatter stringFromDate:startDate];
    NSString *strEndDate = [dateFormatter stringFromDate:endDate];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[openApi getCMSUrl:@"CXOXXBAC0002.cms"] forKey:@"url"];
    [param setValue:OPEN_API_CLIENT_ID forKey:@"clientId"];
    [param setValue:strStartDate forKey:@"inqStartYmd"];
    [param setValue:strEndDate forKey:@"inqEndYmd"];
    [param setValue:_chrgMnsNo forKey:@"accntNo"];
    [param setValue:[openApi getBase64Str:accessToken] forKey:@"accessToken"];
    
    [openApi requestAuthOpenApi:OPENAPI_PARAM_KEY_API
                           type:openApiType_requestBalance
                          param:param callback:^(BOOL success, NSString *step, NSDictionary *result, NSInteger statusCd) {
                              
                              if (success) {
                                  [self->_resultDic setValue:result forKey:@"trstnHstry"];
                                  [self success];
                              } else {
                                  NSString *msg = result[@"resultMessage"];
                                  NSDictionary * retValue = @{@"statusCd" : [NSNumber numberWithInteger:statusCd],
                                                              @"step" : [NSNumber numberWithInteger:4]
                                                              };
                                  
                                  if (msg) {
                                      [BlockAlertView showBlockAlertWithTitle:@"알림" message:msg dismisTitle:@"확인"];
                                  }
                                  [self finishedActionWithResult:retValue success:NO];
                              }
                          }];
}
@end

// 손보 openapi (여행자 보험)
@implementation requestOpenApi {
    NSDictionary *_resultDic;
    OpenAPIAuth_V2 *openApi;
}

-(void)run {
    _resultDic = [NSMutableDictionary dictionary];

    BOOL useToken = !([@"N" isEqualToString:self.paramDic[@"useToken"]]); // 기본값 Y
    
    if (nilCheck(self.paramDic[@"actionKey"]) && useToken) {
        
        NSDictionary * dict = @{
            @"resCd" : mobWeb_openapi_not_actionKey,
            @"resultMessage" : @"notActionKey"
        };
        
        [self finishedActionWithResult:dict success:NO];
        return;
    }
    
    if (openApi == nil) {
        openApi = [[OpenAPIAuth_V2 alloc] init];
        openApi.service = self;
        openApi.webView = self.webView;
        openApi.failCallback = self.failCallback;
        openApi.successCallback = self.successCallback;
        openApi.paramDic = self.paramDic;
        openApi.tag = self.tag;
        openApi.authData = [NSMutableDictionary dictionaryWithDictionary:self.paramDic];
    }
    
    if (useToken) {
        
         if ([openApi.authData null_valueForKey:OPENAPI_PARAM_KEY_SAML][@"ciNo"]) {
             NSString * ciNo = [openApi.authData null_valueForKey:OPENAPI_PARAM_KEY_SAML][@"ciNo"];
             NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:ciNo options:0];
             ciNo = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
             [AppInfo userInfo].userCI = ciNo.stringByUrlDecoding;          
         }
        
        // 입력 파라메타에 clientId 이나 secretKey가 입력되지 않았을경우 앱에 지정된 기본값으로
        if (![openApi.authData null_valueForKey:OPENAPI_PARAM_KEY_SAML][@"clientId"]) {
            [openApi.authData[OPENAPI_PARAM_KEY_SAML] setObject:OPEN_API_CLIENT_ID forKey:@"clientId"];
        }
        
        if (![openApi.authData null_valueForKey:OPENAPI_PARAM_KEY_TOKEN][@"clientId"]) {
            [openApi.authData[OPENAPI_PARAM_KEY_TOKEN] setObject:OPEN_API_CLIENT_ID forKey:@"clientId"];
        }
        
        if (![openApi.authData null_valueForKey:OPENAPI_PARAM_KEY_TOKEN][@"clientSecret"]) {
            [openApi.authData[OPENAPI_PARAM_KEY_TOKEN] setObject:OPEN_API_CLIENT_SECRET forKey:@"clientSecret"];
        }
        
        [openApi goAuthProcess:openApiType_requestKBOpenApi callback:^(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd) {
            
            if (success) {
                [self requestOpenApi];
            } else {
                
                if (statusCd / 100 * 100 == 200) {
                    [self finishedActionWithResult:result success:YES];
                } else {

                    NSMutableDictionary *newResult = [result mutableCopy];
                    [newResult setObject:[NSNumber numberWithInteger:statusCd] forKey:@"statusCd"];
                    [newResult setObject:[NSNumber numberWithInteger:4] forKey:@"step"];
                    [self finishedActionWithResult:newResult success:NO];
                }
            }
        }];
    } else {
        [self requestOpenApi];
    }
}

- (void)requestOpenApi {
    NSDictionary * apiParam = self.paramDic[@"API"];
    NSDictionary * requestParam = apiParam[@"requestParam"];
    NSString * url = apiParam[@"url"];
    
    BOOL useToken = !([@"N" isEqualToString:self.paramDic[@"useToken"]]); // 기본값 Y
    
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param addEntriesFromDictionary:requestParam];
    [param setObject:url forKey:@"url"];
    [param setValue:OPEN_API_CLIENT_ID forKey:@"clientId"];
    
    if(useToken && openApi.accessToken.length > 0) {
        [param setValue:[openApi getBase64Str:openApi.accessToken] forKey:@"accessToken"];
    }
    
    [openApi requestAuthOpenApi:OPENAPI_PARAM_KEY_API
                           type:openApiType_requestKBOpenApi
                          param:param callback:^(BOOL success, NSString *step, NSDictionary *result, NSInteger statusCd) {

                          if(success) {
                              [self finishedActionWithResult:result success:YES];
                          } else {

                              NSMutableDictionary *newResult = [result mutableCopy];
                              [newResult setObject:[NSNumber numberWithInteger:statusCd] forKey:@"statusCd"];
                              [newResult setObject:[NSNumber numberWithInteger:4] forKey:@"step"];
                              [self finishedActionWithResult:newResult success:NO];
                          }
                      }];
}
@end

/**
@var KB Open API (저축은행)
@brief Open API를 이용한 SAML인증, AccessToken발급, Api 통신
@param SAML 발급용 Json,  AccessToken 발급용 Json, Api Json
@return 결과값 (SAML, AccessToken, Api)
*/
@implementation requestKBOpenAPI
- (void) run {
    NSDictionary * samlParam = self.paramDic[@"SAML"];
    NSDictionary * tokenlParam = self.paramDic[@"AccessToken"];
    NSDictionary * apiParam = self.paramDic[@"Api"];
    if (samlParam != nil) {
        [self requestKBOpenAPI:samlParam];
    }
    else if (tokenlParam != nil) {
        [self requestKBOpenAPI:tokenlParam];
    }
    else if (apiParam != nil) {
        [self requestKBOpenAPI:apiParam];
    }
}

// KB Open API 통신
- (void) requestKBOpenAPI : (NSDictionary *)apiParam {
    // Ver. 3 KBOpenAPI Param 추가
    NSURL *url = [NSURL URLWithString:[apiParam objectForKey:@"url"]];  // URL 정보
    NSString *method = [apiParam objectForKey:@"method"];   // method Type
//    NSURL *url = [NSURL URLWithString:@"https://dev-openapi.kbcard.com:8443/v1.0/OAuth/saml/assertion"];
    Request *req = [Request requestWithURL:url];
    [req setHTTPMethod:method];
    
    NSDictionary *jsonHeader = [apiParam objectForKey:@"jsonHeader"]; // 통신 헤더
    
    NSString *jsonBodyStr;
    if ([[apiParam objectForKey:@"jsonBody"] isKindOfClass:[NSDictionary class]]) { // json body 형식 Dictionary
        NSData *data = [NSJSONSerialization dataWithJSONObject:[apiParam objectForKey:@"jsonBody"] options:kNilOptions error:nil];
        // "\"문자 제거
        jsonBodyStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else { // json body 형식 string
        jsonBodyStr = [NSString stringWithFormat:@"%@", [apiParam objectForKey:@"jsonBody"]];
    }
    
//    NSDictionary *jsonHeader = @{
//        @"Content-Type" : @"application/json;charset=UTF-8",
//        @"Accept"    : @"*/*",
//        @"User-Agent"     : @"LiivMate",
//        @"X-Requested-With"     : @"XMLHttpRequest",
//        @"clientId" : @"l7xx245ef6a9327d417ebc81a6a80f88d2a4"
//    };
    
//    NSDictionary *jsonDic = [apiParam objectForKey:@"jsonBody"];
//
//    // for test
//    NSDictionary *jsonBody = @{@"dataHeader" : @{},
//        @"dataBody" : @{
//        @"ciNo"         : @"A67kR5QQZFoGlSe+Ldk6fFi0xjV0cdnaRjlf8puoCNz52BGItnf30OtOA978ePeASLaFcs7gxVstBWSdTsBUtQ==",
//        @"loginType"    : @"1",
//        @"clientId"     : @"l7xx245ef6a9327d417ebc81a6a80f88d2a4",
//        @"serialNo"     : @"serialNo",
//        @"reservedType" : @"reservedType"
//        }
//    };
    
    [req setAllHTTPHeaderFields:jsonHeader];
    
    NSLog(@"jsonBodyStr == %@", jsonBodyStr);
    
    NSData* jsonData; // 통신용 데이터
    
    jsonData = [jsonBodyStr dataUsingEncoding:NSUTF8StringEncoding]; // json Body 값
    
    [req setValue:[NSString stringWithFormat:@"%d", ((int)[jsonData length])] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:jsonData];
    
    
    [req sendDataTask:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
           NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            NSLog (@"statusCode : %li", (long)statusCode);
            // data가 nil 일 때 예외 처리추가 (crash log 패치)
            if (data == nil) {
                [self finishedActionWithResult:@{@"statusCd":@(statusCode)} success:NO];
                return;
            }
            
            NSDictionary *resultDic = [self jsonDataToDictionary:data];
            if (statusCode / 100 * 100 == 200 ) { // 200~299 사이면 성공
                [self finishedActionWithResult:resultDic success:YES];
            }
            else { // 그이외 실패 
                [self finishedActionWithResult:resultDic success:NO];
            }
            NSLog (@"KBOpenAPI resultDic : %@", resultDic);
        });
    }];
}

// 결과 값을 Dictionary로 변경
- (NSDictionary *)jsonDataToDictionary:(NSData *)data {
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers
                                                error:nil];
    
    NSLog (@"response : %@", json);
    
    if (!json) return nil;
    
    if ([json isKindOfClass:[NSArray class]]) {
        NSArray * array = json;
        return array.count == 0 ? @{} : array[0];
    }
    
    return json;
}
@end

