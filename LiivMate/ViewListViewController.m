//
//  ViewListViewController.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 21..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "ViewListViewController.h"
#ifdef DEBUG
#import "HybridActionManager.h"
#import "PwdWrapper.h"
#import "WebViewController.h"
#import "KCLPaymentCancelPopupView.h"
#import "MobileWeb.h"
#import "MobileWeb+KBOpenApi.h"

#import "NoticeAlertView.h"
#import "PentaPinViewController.h"
#import "PwdPinViewController.h"
#import "PwdCertViewController.h"
#import "CertificationManager.h"
#import "ScrappingManager.h"
#import "MobileWeb+KBOpenApi.h"
#import "GifProgress.h"
#import "SplashScreenManager.h"
#import "KBAddressView.h"
#import <BuzzAdBenefit/BuzzAdBenefit.h>
#import <BuzzAdBenefitNative/BuzzAdBenefitNative.h>
#import <BuzzAdBenefitInterstitial/BuzzAdBenefitInterstitial.h>
#import <BuzzAdBenefitFeed/BuzzAdBenefitFeed.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SafariServices/SafariServices.h>
#import "CustomAdViewHolder.h"
#import <Contacts/Contacts.h>
#import "KCLPaymentViewController.h"
#import "KCLPopupViewController.h"

@import TouchadSDK;

@interface V2ListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    NSArray *_viewList;
}
@property (nonatomic, strong) NSString *delegateIndetifier;
@end

@implementation V2ListViewController

-(void)initSettings
{
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"목록 V2";
    //테스트 코드
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"알리미" style:(UIBarButtonItemStylePlain) target:self action:@selector(openChannelList)];
    
    // Do any additional setup after loading the view.
    _viewList = @[@{@"title":@"ChatBot 테스트",@"class":@"ChatBotViewController",@"depth":@"1"},
                  @{@"title":@"디자인팝업 테스트",@"class":@"MDDesignPopupView",@"depth":@"1"},
                  @{@"title":@"오른쪽 버튼팝업 테스트",@"class":@"KCLRightPopupView",@"depth":@"1"},
                  @{@"title":@"푸시테스트",@"class":@"PushNotificationViewController",@"depth":@"1"},
//                  @{@"title":@"ChatBot 테스트",@"class":@"KCLChatBotViewController",@"depth":@"1"},
                  @{@"title":@"BuzzAD 테스트",@"class":@"BuzzAdBenefitViewController",@"depth":@"1"},
                  @{@"title":@"해외여행자보험 주소록 선택",@"class":@"ComponentTestViewController",@"depth":@"1"},
                  @{@"title":@"포인트리보내기 > 주소록)",@"class":@"KBAddressView",@"depth":@"1"},
                  @{@"title":@"앱아이디삭제",@"class":@"deleteAppid",@"depth":@"1"},
                  @{@"title":@"로그아웃",@"class":@"logOut",@"depth":@"1"},
                  @{@"title":@"앱아이디 체인지",@"class":@"changeAppid",@"depth":@"1"},
                  @{@"title":@"앱아이디 체인지(텍스트입력)",@"class":@"changeAppid2",@"depth":@"1"},
                  @{@"title":@"open api 3자 동의 삭제",@"class":@"deleteAgreeOpenApi",@"depth":@"1"},
                  @{@"title":@"연락처 저장 테스트용",@"class":@"addTel",@"depth":@"1"},
                  @{@"title":@"연락처 전체삭제 테스트용",@"class":@"delTel",@"depth":@"1"},
                  @{@"title":@"open api 토큰초기화",@"class":@"initTokenOpenApi",@"depth":@"1"},
                  @{@"title":@"스플레시 초기화",@"class":@"initSplash",@"depth":@"1"},
                  @{@"title":@"라온 공개키 암호화",@"class":@"raonRsaTest",@"depth":@"1"},
                  @{@"title":@"블럭체인 삭제",@"class":@"deleteBlockChain",@"depth":@"1"},
                  @{@"title":@"공지팝업 테스트",@"class":@"noticePopupTest",@"depth":@"1"},
                  @{@"title":@"암호화 테스트",@"class":@"encTest",@"depth":@"1"},
                  @{@"title":@"스킴액션 테스트",@"class":@"URLActionTest",@"depth":@"1"},
                  @{@"title":@"가맹점 메인이동",@"class":@"moveMain",@"depth":@"1"},
                  @{@"title":@"키체인삭제",@"class":@"deleteKey",@"depth":@"1"},
                  @{@"title":@"캐시이미지삭제",@"class":@"deleteImage",@"depth":@"1"},
                  @{@"title":@"인트로",@"class":@"KCLIntroViewController",@"depth":@"1"},
                  @{@"title":@"초대이벤트 연락처",@"class":@"inviteAddressBook",@"depth":@"1"},
                  @{@"title":@"튜토리얼",@"class":@"KCLTutorialViewController",@"depth":@"1"},
                  
                  @{@"title":@"이미지 업로드 액션",@"class":@"selectImageAndUpload",@"depth":@"1"},
                  @{@"title":@"펜타",@"class":@"PentaTest",@"depth":@"1"},
                  @{@"title":@"라온 7자리",@"class":@"RaonTest1",@"depth":@"1"},
                  @{@"title":@"라온 6자리",@"class":@"RaonTest2",@"depth":@"1"},
                  @{@"title":@"라온 문자열",@"class":@"RaonTest3",@"depth":@"1"},
                  @{@"title":@"공인인증서 가져오기",@"class":@"getCert",@"depth":@"1"},
                  @{@"title":@"공인인증서 목록조회",@"class":@"getCertList",@"depth":@"1"},
                  @{@"title":@"스크래핑",@"class":@"getScrappingInfo",@"depth":@"1"},
                  @{@"title":@"Gif테스트",@"class":@"showGif",@"depth":@"1"},
                  @{@"title":@"KB Easy대출(운영)",@"class":@"WebViewController",@"depth":@"1",@"link":@"https://m.liivmate.com/katsv2/liivmate/medmIrt/loan/web/L01001.do"},
                  @{@"title":@"공인인증서 관리(운영)",@"class":@"WebViewController",@"depth":@"1",@"link":@"https://m.liivmate.com/katsv2/liivmate/medmIrt/loan/web/L01071.do"},
                  
                  @{@"title":@"하이브리드 테스트",@"class":@"WebViewController",@"depth":@"1",@"link":@"https://dm.liivmate.com/katsv2/call.jsp"},
                  @{@"title":@"간편결제",@"class":@"Payment.KCLPaymentViewController",@"modal":@YES,@"depth":@"1"},
                  @{@"title":@"결제완료",@"class":@"Payment.KCLPaymentCompleteViewController",@"depth":@"1"}, // testPaymentCompleteVC
                  @{@"title":@"결제요청팝업",@"class":@"PaymentRequestPopupTest",@"depth":@"1"},
                  @{@"title":@"결제취소팝업",@"class":@"PaymentCancelPopupTest",@"depth":@"1"},
                  @{@"title":@"비디오포털",@"class":@"TestTableView",@"depth":@"1"},
                  @{@"title":@"토스트",@"class":@"ToastTest",@"depth":@"1"},
                  @{@"title":@"QR코드 촬영",@"class":@"Payment.KCLQRScannerViewController",@"modal":@YES,@"depth":@"1"},
                  @{@"title":@"My QR",@"class":@"showMyQR",@"depth":@"1"},
                  @{@"title":@"알림보관함",@"class":@"Sendbird.AlertMessageVC",@"depth":@"1"},
                  @{@"title":@"공지사항",@"class":@"Sendbird.NoticeMessageVC",@"depth":@"1"},
                  @{@"title":@"KB오픈api",@"class":@"MobileWeb.KBOpenApiTermVC_V2",@"modal":@YES,@"depth":@"2"},
                  @{@"title":@"위젯 전문 테스트",@"class":@"showWidgetLog",@"depth":@"1"},
                  @{@"title":@"공유 팝업 테스트",@"class":@"showSharePopup",@"depth":@"1"},
                  @{@"title":@"open api 약관화면",@"class":@"MobileWeb.KBOpenApiTermDetailVC",@"depth":@"1"},
                  @{@"title":@"퍼블리싱테스트",@"class":@"WebViewController",@"depth":@"1",@"link":@"https://dm.liivmate.com/katsv4/DesignPublishing/WEB-INF/index_app.html"},
                  @{@"title":@"kakaoMap길안내",@"class":@"KakaoMapNavi",@"depth":@"1"},
                  @{@"title":@"공유연동테스트",@"class":@"UIActivityViewControllerTest",@"depth":@"1"},
                  @{@"title":@"KakaoMap테스트",@"class":@"KakaoMapTest",@"depth":@"1"},
                  @{@"title":@"Touchad 참여적립",@"class":@"clickJoinAndEarning",@"depth":@"1"},
                  @{@"title":@"Touchad 터치애드",@"class":@"clickTouchadMain",@"depth":@"1"},
                  @{@"title":@"Touchad 전면광고",@"class":@"clickTouchad",@"depth":@"1"},
                  @{@"title":@"Touchad 적립결과(즉시)",@"class":@"clickEarningResult",@"depth":@"1"},
                  @{@"title":@"Touchad 적립결과(5초)",@"class":@"clickEarningResult5",@"depth":@"1"},
                  @{@"title":@"팝업webView 테스트",@"class":@"KCLPopupViewController",@"modal":@YES,@"depth":@"1"},
                  @{@"title":@"인터페이스 테스트",@"class":@"WebViewController",@"depth":@"1",@"link":@"https://dm.liivmate.com/katsv4/liivmate/common/cnsmmgr/test_cnsm.do"}
                  ];
    
    /*
     [UIStoryboard storyboardWithName:@"MobileWeb" bundle:nil];
     KBOpenApiTermVC *vc = [storyBoard instantiateViewControllerWithIdentifier:@"KBOpenApiTermVC"];
     */
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    KCLCustomNavigationBarView  *navi = [KCLCustomNavigationBarView instance];
    [navi setNavigationItems:self navigationType:KCLNavigationViewTypeAllShow];
    [self.view addSubview:navi];
    CGRect tableViewFrame = _tableView.frame;
    tableViewFrame.origin.y = navi.frame.size.height+50;
    tableViewFrame.size.height = tableViewFrame.size.height-navi.frame.size.height-50;
    _tableView.frame = tableViewFrame;

    
    //    NSDictionary *menu = [AllMenu menuForID:MenuID_V1_MateList];
    //    NSLog(@"%@",menu);
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}                                                

- (void)deleteAgreeOpenApi
{
    if([AppInfo sharedInfo].isLogin) {
        OpenAPIAuth_V2 *action = [[OpenAPIAuth_V2 alloc] init];
        [action requestDelAgree];
    } else {
        [[AppInfo sharedInfo] performLogin:^(BOOL success, NSString *errCD, NSDictionary* result) {
            if(success)
            {
               OpenAPIAuth_V2 *action = [[OpenAPIAuth_V2 alloc] init];
               [action requestDelAgree];
            }
        }];
    }
}
-(void)initTokenOpenApi
{
    [AppInfo sharedInfo].openApiAuthTokens = nil;
    
    showSplashMessage(@"메모리에서 토큰값을 삭제하였습니다", YES, NO);
}

- (void)initSplash
{
    //파일삭제
    NSString * filePath = [DOCUMENT_PATH stringByAppendingPathComponent:[NSString stringWithFormat:DATA_FILENAME_FORMAT, [UserDefaults sharedDefaults].splashVer]];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    [UserDefaults sharedDefaults].splashVer = nil;
    
     showSplashMessage(@"스플레시 정보를 초기화 하였습니다", YES, NO);
}


- (void)raonRsaTest
{
//    NSDictionary * dict = @{@"result" : @"abcdefg121212"};
//
//    [Request requestID:@"AT0006" body:@{@"encText":[PwdPinViewController encryptedDictionaryTest:dict]} waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
//        if(IS_SUCCESS(rsltCode)) { //성공일 경우
//
//            [BlockAlertView showBlockAlertWithTitle:@"알림" message:[NSString stringWithFormat:@"%@", result] dismisTitle:@"확인"];
//
//            NSLog(@"%@", result);
//        }
//    }];
}
- (void)changeAppid2
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:@"변경할 appid를 입력해주세요" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"변경할 appid";
        textField.text = [UserDefaults sharedDefaults].appID?[UserDefaults sharedDefaults].appID :@"";
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"변경"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              NSString * appid = [[alert textFields][0] text];
                                                              if (appid.length != 0 && [appid hasPrefix:@"KAT"]) {
                                                                  [self changeAppIDProcess:appid];
                                                              }
                                                          }];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)changeAppid
{
    [Request requestID:@"AT0999" body:nil waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
        if(IS_SUCCESS(rsltCode)) { //성공일 경우
            
            NSArray * appIDs = result[@"resultList"];
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"알림"
                                                                            message:@"appid를 선택해 주세요"
                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
            
            for (int i=0; i<appIDs.count; i++) {
                NSDictionary * item = appIDs[i];
                NSString * title = [NSString stringWithFormat:@"%@(%@)", item[@"cdNm"], item[@"appId"]];
                UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   int idx = (int)[alert.actions indexOfObject:action];
                                                                   [self changeAppIDProcess:appIDs[idx][@"appId"]];
                                                               }];
                [alert addAction:action];
            }
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"닫기"
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction * action) {}];
            [alert addAction:action];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            NSLog(@"%@", result);
        }
    }];
}

- (void)changeAppIDProcess:(NSString *)appid
{
    [UserDefaults sharedDefaults].appID = appid;
    [[UserDefaults sharedDefaults] synchronize];
    
    [[AppInfo sharedInfo] performLogout:^(BOOL success){}];
    
    [BlockAlertView dismissAllAlertViews];
    [Request cancelRequestAll];
    
    [AppInfo sharedInfo].autoLogin = YES;
    [AppInfo sharedInfo].isJoin = YES;
    
    [BlockAlertView showBlockAlertWithTitle:@"알림"
                                    message:@"로그인 하시겠습니까?"
                          dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == 0) {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:StartLiivMateNotification object:nil];
                              } else {
                                  [[AppInfo sharedInfo] sendLoginRequestWithPwdDic:nil success:^(BOOL success, NSString *errCD, NSDictionary* result) {
                                      [[NSNotificationCenter defaultCenter] postNotificationName:StartLiivMateNotification object:nil];
                                  }];
                              }
                          } cancelButtonTitle:nil buttonTitles:@"로그인 안함",@"로그인", nil];
}
- (void)addTel
{
    [Request requestID:@"KATSE99" body:@{} waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
        if(IS_SUCCESS(rsltCode)) { //성공일 경우

            NSArray * telList = result[@"telNoList"];
            int i = 0;
            for (NSDictionary *dict in telList) {
//                if (i >= 1000) {
//                    break;
//                }
                [self saveContact:dict[@"custNm"] phoneNumber:dict[@"moblNm"]];
                i++;
            }
            
//            for (int i=0; i<1000; i++) {
//
//                [self saveContact:@"랜덤전화번호" phoneNumber:[NSString stringWithFormat:@"010%04d%04d", arc4random()%9999, arc4random()%9999]];
//
//            }
//
            NSLog(@"%@", result);
        }
    }];
}

- (void)delTel
{
    [self deleteAllContacts];
}

#ifdef DEBUG
- (void) deleteAllContacts {
    CNContactStore *contactStore = [[CNContactStore alloc] init];

    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            NSArray *keys = @[CNContactPhoneNumbersKey];
            NSString *containerId = contactStore.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];

            if (error) {
                NSLog(@"error fetching contacts %@", error);
            } else {
                CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];

                for (CNContact *contact in cnContacts) {
                    [saveRequest deleteContact:[contact mutableCopy]];
                }

                [contactStore executeSaveRequest:saveRequest error:nil];
                
            }
        }
    }];

}

-(void)saveContact:(NSString*)name phoneNumber:(NSString*)phoneNumber {
    CNMutableContact *mutableContact = [[CNMutableContact alloc] init];
    
    mutableContact.familyName = name;
    CNPhoneNumber * phone =[CNPhoneNumber phoneNumberWithStringValue:phoneNumber];

    mutableContact.phoneNumbers = [[NSArray alloc] initWithObjects:[CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberiPhone value:phone], nil];
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest addContact:mutableContact toContainerWithIdentifier:store.defaultContainerIdentifier];

    NSError *error;
    if([store executeSaveRequest:saveRequest error:&error]) {
        NSLog(@"save");
    }else {
        NSLog(@"save error");
    }
}

#endif
-(void)URLActionTest
{
    //    NSURL *url = [NSURL URLWithString:@"liivmate://QR?type=M&code=20181109103239004817"];
    NSURL *url = [NSURL URLWithString:@"liivmate://call?cmd=move_to&id=KAT_MYPG_020"];
    if(url.runAction)
    {
        NSLog(@"액션성공");
    }
    else
    {
        [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"스킴액션 없음" dismisTitle:@"확인"];
    }
}

-(void)encTest
{
    [NSClassFromString(@"encJson") runWithParam:@{@"name" : @"홍길동", @"phone" : @"01011112222" } callback:^(NSDictionary *result, BOOL success) {
        NSLog(@"%@",result);
    }];
}

-(void)noticePopupTest
{
    NSDictionary *notice = @"eyJub3RpY2VDb250Ijoi7ZWt7IOBIExpaXYgTWF0ZSDrpbwg7J207Jqp7ZW07KO87Iuc64qUIOqzoOqwneuLmOq7mCDqsJDsgqzsnZgg66eQ7JSA7J2EIOuTnOumveuLiOuLpC48YnIgXC8+XHJcbjxiciBcLz5cclxuTGlpdiBNYXRlIEFwcCDrgrQg7Iug6rec7ISc67mE7IqkIOy2lOqwgCDrsI8g7Jqp7Ja0IOyerOygleydmOyXkCDrlLDrnbwgMjAxOOuFhCAxMeyblCAwMOydvOu2gO2EsCBMaWl2IE1hdGUg7J207Jqp7JW96rSA7J20IOydvOu2gCDrs4Dqsr3rkJjslrQg7Iuc7ZaJIOyYiOygleyeheuLiOuLpC48YnIgXC8+XHJcbjxiciBcLz5cclxuPOuzgOqyveyCrO2VrT48YnIgXC8+XHJcbi3qtZDtmZjtlZjquLAsIOyGjOu5hOunpOuLiOyggCwg6rCE7Y646rKw7KCc7J2YIOyaqeyWtOygleydmDxiciBcLz5cclxuLeq1kO2ZmO2VmOq4sCDrs4Dqsr0g65iQ64qUIOykkeuLqCDsi5wg7ZqM7JuQIOyViOuCtOyhsO2VrSDstpTqsIA8YnIgXC8+XHJcbi3siqTtg6ztlIQg7ISc67mE7IqkIOy2lOqwgDxiciBcLz5cclxuPGJyIFwvPlxyXG4q67O4IOyVveq0gOydgCBMaWl2IE1hdGUg66qo67CU7J28IEFwcCwgTGlpdiBNYXRlIO2ZiO2OmOydtOyngOyXkCDqsozsi5zrkKnri4jri6QuPGJyIFwvPlxyXG4q67O4IOyVveq0gCDrs4Dqsr0g7JWI64K0IO2bhCDsi5ztlonsnbwoMjAxOOuFhCAxMeyblCAwMOydvCnquYzsp4Ag67OE64+E7J2YIOydtOydmOygnOq4sOqwgCDsl4bsnLzsi5zrqbQg67O4IOyVveq0gCDrs4Dqsr3snYQg7Iq57J247ZWcIOqyg+ycvOuhnCDqsITso7ztlZjsl6wg7KCB7JqpIO2VoCDsmIjsoJXsnbTsmKTri4gg7JaR7KeA7ZWY7JesIOyjvOyLnOq4sCDrsJTrno3ri4jri6QuPGJyIFwvPlxyXG48YnIgXC8+XHJcbuyVveq0gCDqtIDroKgg7J6Q7IS47ZWcIOuCtOyaqeydgCBb6rOg6rCd7IS87YSwPuqzteyngOyCrO2VrV3snYQg7LC47KGw7ZW07KO87Iuc6riwIOuwlOuejeuLiOuLpC48YnIgXC8+XHJcbirrs7gg7JW96rSA7J2AIExpaXYgTWF0ZSDrqqjrsJTsnbwgQXBwLCBMaWl2IE1hdGUg7ZmI7Y6Y7J207KeA7JeQIOqyjOyLnOuQqeuLiOuLpC48YnIgXC8+XHJcbirrs7gg7JW96rSAIOuzgOqyvSDslYjrgrQg7ZuEIOyLnO2WieydvCgyMDE464WEIDEx7JuUIDAw7J28Keq5jOyngCDrs4Trj4TsnZgg7J207J2Y7KCc6riw6rCAIOyXhuycvOyLnOuptCDrs7gg7JW96rSAIOuzgOqyveydhCDsirnsnbjtlZwg6rKD7Jy866GcIOqwhOyjvO2VmOyXrCDsoIHsmqkg7ZWgIOyYiOygleydtOyYpOuLiCDslpHsp4DtlZjsl6wg7KO87Iuc6riwIOuwlOuejeuLiOuLpC48YnIgXC8+XHJcbjxiciBcLz5cclxu7JW96rSAIOq0gOugqCDsnpDshLjtlZwg64K07Jqp7J2AIFvqs6DqsJ3shLzthLA+6rO17KeA7IKs7ZWtXeydhCDssLjsobDtlbTso7zsi5zquLAg67CU656N64uI64ukLiIsIm5vdGljZVluIjoiWSIsIm5vdGljZU5vIjoiODgiLCJub3RpY2VDbG9zZVR5cGUiOiIxIiwibm90aWNlVGl0bGUiOiLrpqzruIzrqZTsnbTtirgg7J207Jqp7JW96rSAIOqwnOygleyViOuCtCJ9".jsonObjectForBase64;
    
    NSString *noticeTitle = [notice null_valueForKey:@"noticeTitle"];
    NSString *noticeCont = [notice null_valueForKey:@"noticeCont"];
    [NoticeAlertView showNoticeTitle:noticeTitle message:noticeCont dismissTitle:@"오늘 하루 안보기" dissmiss:^(BOOL checked) {
        
    }];
    
}

-(void)inviteAddressBook
{
    [NSClassFromString(@"inviteAddressBook") runWithParam:@{@"mCount" : @(rand()%2+1) } callback:^(NSDictionary *result, BOOL success) {
        
    }];
}

-(void)moveMain
{
    [NSClassFromString(@"goMainView") runWithParam:@{@"shopMain" : @"Y"} callback:^(NSDictionary *result, BOOL success) {
        
    }];
}

-(void)deleteImage
{
    [UserDefaults sharedDefaults].showDeviceUseAgreement = NO;
    [NSClassFromString(@"RemoteImageManager") removeCachesImages];
}

-(void)deleteBlockChain
{
    [PwdWrapper deleteBlockChain];
}

-(void)selectImageAndUpload
{
    
    
    
    [NSClassFromString(@"selectImageAndUpload") runWithParam:@{@"chnlGbnCd" : @[@"01",@"02"]} callback:^(NSDictionary *result, BOOL success) {
        
        //[[SDWebImageManager sharedManager].imageDownloader setValue:[AppInfo sharedInfo].ktUcloudAuthToken forHTTPHeaderField:@"X-Auth-Token"];
        
        NSString *url = @"https://ssproxy.ucloudbiz.olleh.com/v1/AUTH_d4ea23b0-ea3f-4b12-bd90-27b6a2a493d0/lm_4baeb2e259901bea65240d72a9b71764a85798502a7f37285e05f264759c734a/lm_lm20181022120244001.jpg";//[result[@"imageUrl"] stringByReplacingOccurrencesOfString:@"https://ssproxy.ucloudbiz.olleh.com" withString:@"http://14.63.210.33"];//ssproxy.ucloudbiz.olleh.com
        NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [rq setValue:[AppInfo sharedInfo].ktUcloudAuthToken forHTTPHeaderField:@"X-Auth-Token"];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:rq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSHTTPURLResponse *resp = (id)response;
                NSLog(@"[%d] %@",(int)resp.statusCode,resp);
                UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
                view.image = [[UIImage alloc] initWithData:data];
                [BlockAlertView showBlockAlertWithTitle:nil message:view dismisTitle:AlertConfirm];
            });
        }] resume];
        //
        //        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        //        view.image = image;
        //        [BlockAlertView showBlockAlertWithTitle:nil message:view dismisTitle:AlertConfirm];
        //        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:result[@"imageUrl"]] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        //
        //        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        //            UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        //            view.image = image;
        //            [BlockAlertView showBlockAlertWithTitle:nil message:view dismisTitle:AlertConfirm];
        //        }];
        
    }];
}

-(void)requestTest
{
    [Request requestID:nil body:nil waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
        
    }];
}

-(void)PwdTest
{
    [PwdWrapper showPwd:^(id vc) {
        [PwdWrapper setTitle:vc value:@"비밀번호 4자리를"];
        [PwdWrapper setSubTitle:vc value:@"입력해 주세요"];
        [PwdWrapper setMaxLen:vc value:4];
        [PwdWrapper setShowPwdResetBtn:vc value:YES];
        
    } callBack:^(id vc, BOOL isCancel, BOOL *dismiss) {
        
    }];
    
    
}
-(void)PentaTest {
    [PentaPinViewController showPenta:^(PentaPinViewController *vc) {
        ((PentaPinViewController *)vc).title = @"주민등록번호 7자리를";
        ((PentaPinViewController *)vc).subTitle = @"입력해 주세요";
        ((PentaPinViewController *)vc).maxLen = 7;
        ((PentaPinViewController *)vc).showPwdResetBtn = NO;
    } callBack:^(PentaPinViewController *vc, BOOL isCancel, BOOL *dismiss) {
        [PwdWrapper shared].pwdPinVC = vc;
        [((PentaPinViewController *)vc) getPlainText:^(char *plain) {
            NSString *plainText = [NSString stringWithCString:plain encoding:NSUTF8StringEncoding];
            NSLog(@"plain : %@", plainText);
        }];
        
    }];
}

-(void)RaonTest1
{
    [PwdWrapper showPwd:^(id vc) {
        [PwdWrapper setTitle:vc value:@"주민등록번호 7자리를"];
        [PwdWrapper setSubTitle:vc value:@"입력해 주세요"];
        [PwdWrapper setMaxLen:vc value:7];
        [PwdWrapper setShowPwdResetBtn:vc value:NO];

    } callBack:^(id vc, BOOL isCancel, BOOL *dismiss) {
        if (!isCancel) {
            NSDictionary * pwdInfo = @{@"pwd"           : [PwdWrapper doublyEncrypted:vc keyNm:@"pwd"],
                                       KEY_KEYPAD_TYPE  : KEY_KEYPAD_VALUE
                                       };

            [Request requestID:@"AT0006" body:pwdInfo waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                if(IS_SUCCESS(rsltCode)) { //성공일 경우

                    [BlockAlertView showBlockAlertWithTitle:@"알림" message:[NSString stringWithFormat:@"%@", result] dismisTitle:@"확인"];

                    NSLog(@"%@", result);
                }
            }];
        }
    }];
}

- (void)RaonTest2
{
    [PwdWrapper showPwd:^(id vc) {
        if([AppInfo sharedInfo].useBiometrics == UseBiometricsEnabled){
            [PwdWrapper setTitle:vc value:@"지문을 사용하여 본인인증을 해주세요."];
            [PwdWrapper setMaxLen:vc value:6];
            [PwdWrapper setShowPwdResetBtn:vc value:YES];
        }else{
            [PwdWrapper setTitle:vc value:@"비밀번호 6자리를"];
            [PwdWrapper setSubTitle:vc value:@"입력해 주세요"];
            [PwdWrapper setMaxLen:vc value:6];
            [PwdWrapper setShowPwdResetBtn:vc value:YES];
        }
    } target:@"HybridCall" callBack:^(id vc, BOOL isCancel, BOOL *dismiss) {
        if (!isCancel) {
            NSDictionary * pwdInfo = @{@"pwd"           : [PwdWrapper doublyEncrypted:vc keyNm:@"pwd"],
                                       KEY_KEYPAD_TYPE  : KEY_KEYPAD_VALUE
                                       };
            
            [Request requestID:@"AT0006" body:pwdInfo waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                if(IS_SUCCESS(rsltCode)) { //성공일 경우
                    
                    [BlockAlertView showBlockAlertWithTitle:@"알림" message:[NSString stringWithFormat:@"%@", result] dismisTitle:@"확인"];
                    
                    NSLog(@"%@", result);
                }
            }];
        }
    }];
    
    
    
}
- (void)RaonTest3 {
    [PwdWrapper showCertPwd:^(id  _Nonnull vc) {
        
        [PwdWrapper setKeyPadTypeCert:vc];
        
    } callBack:^(id  _Nonnull vc, BOOL isCancel, BOOL * _Nonnull dismiss) {
        if (!isCancel) {
            
            
            PwdCertViewController *pwdVc = (PwdCertViewController *)vc;
            [pwdVc.raonTf getPlainText:^(char *plain) {
                
            }];
            
            
//            NSDictionary * pwdInfo = @{@"pwd"           : [PwdWrapper doublyEncrypted:vc keyNm:@"pwd"],
//                                       KEY_KEYPAD_TYPE  : KEY_KEYPAD_VALUE
//                                       };
//
//            [Request requestID:@"AT0006" body:pwdInfo waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
//                if(IS_SUCCESS(rsltCode)) { //성공일 경우
//
//                    [BlockAlertView showBlockAlertWithTitle:@"알림" message:[NSString stringWithFormat:@"%@", result] dismisTitle:@"확인"];
//
//                    NSLog(@"%@", result);
//                }
//            }];
        }
    }];
}
- (void)getCert {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"인증코드 입력" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"인증코드 12자리";
        textField.text = @"";
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"확인"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              NSString * code = [[alert textFields][0] text];
                                                              [IndicatorView show];
                                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                  [[CertificationManager shared] getCertWizvera:code completion:^(NSDictionary * _Nonnull result, BOOL isFail) {
                                                                      
                                                                  }];
                                                              });
                                                          }];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)getCertList {
    [[CertificationManager shared] getCertificationList];
}

- (void)getScrappingInfo {
    //test
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"cn=김응엽()001104520110111111001963,ou=NACF,ou=personal4IB,o=yessign,c=kr", @"subject",
                           @"2020-04-13 23:59:59", @"expiryDate",
                           @[@"211"], @"reportType",
                           @"1Y", @"beforeDate_1",
                           @"2", @"beforeDate_2",
                           @"910925", @"ssno",
                           @"김응엽", @"name",
                           @"", @"businessNum",
                           nil];
    
    
//    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
//                           @"cn=김나래()0020047200802052153389,ou=WOORI,ou=personal4IB,o=yessign,c=kr", @"subject",
//                           @"2020-03-19 23:59:59", @"expiryDate",
//                           @[@"211"], @"reportType",
//                           @"1Y", @"beforeDate_1",
//                           @"2", @"beforeDate_2",
//                           @"890817", @"ssno",
//                           @"김나래", @"name",
//                           @"", @"businessNum",
//                           nil];
    
    
//    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
//                           @"cn=김현재()008804520180904188000706,ou=SHB,ou=personal4IB,o=yessign,c=kr", @"subject",
//                           @"2019-09-04 23:59:59", @"expiryDate",
//                           @[@"101"], @"reportType",
//                           @"2", @"beforeDate_1",
//                           @"2", @"beforeDate_2",
//                           @"930115", @"ssno",
//                           @"김현재", @"name",
//                           @"", @"businessNum",
//                           nil];
    
//    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
//                           @"cn=김병준(제이솔루션(kim byung jun)0004057B000513204,ou=kim byung jun,ou=KMB,ou=corporation4EC,o=CrossCert,c=KR", @"subject",
//                           @"2019-11-16 23:59:59", @"expiryDate",
//                           @[@"221"], @"reportType",
//                           @"2", @"beforeDate_1",
//                           @"2", @"beforeDate_2",
//                           @"710319", @"ssno",
//                           @"김병준", @"name",
//                           @"1262439875", @"businessNum",
//                           nil];
    
    
//    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
//                           @"cn=김병준(kimbyungjun)0004049H011793625,ou=KMB,ou=personal4IB,o=yessign,c=kr", @"subject",
//                           @"2020-04-26 23:59:59", @"expiryDate",
//                           @[@"212"], @"reportType",
//                           @"2", @"beforeDate_1",
//                           @"2", @"beforeDate_2",
//                           @"710319", @"ssno",
//                           @"김병준", @"name",
//                           @"1262439875", @"businessNum",
//                           nil];
//
//    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
//                           @"cn=최우진()001104920090817111002256,ou=NACF,ou=personal4IB,o=yessign,c=kr", @"subject",
//                           @"2019-10-23 23:59:59", @"expiryDate",
//                           @[@"101", @"102", @"211"], @"reportType",
//                           @"2", @"beforeDate_1",
//                           @"2", @"beforeDate_2",
//                           @"840509", @"ssno",
//                           @"최우진", @"name",
//                           nil];
    //test
    [[ScrappingManager shared] startScrapping:param retry:NO completion:^(NSDictionary * _Nonnull result, BOOL isFail) {
        NSLog(@"test:::%@", result.jsonString);
        [GifProgress hideGif:nil];
    }];
}

- (void)showGif {
    [GifProgress showGifWithName:gifType_heart completion:nil];
    [GifProgress performSelector:@selector(hideGif:) withObject:nil afterDelay:4.5];
}
-(void)showMyQR
{
    //[NSClassFromString(@"MyQRViewController") performSelector:@selector(showMyQR:) withObject:@"1234567890"];
    
//    [MyQRViewController showStampQR:@"1234567890" validTime:10.0];
}

- (void)showWidgetLog
{
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
    NSString *requestString = [userDefault objectForKey:@"POINTREE_REQUEST_"];
    NSLog(@"\n[WIDGET] REQUEST\n%@", requestString);
    NSString *responseString = [userDefault objectForKey:@"POINTREE_RESPONSE_"];
    NSLog(@"\n[WIDGET] RESPONSE\n%@", responseString);
    
    [BlockAlertView showBlockAlertWithTitle:@"요청" message:requestString dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        [BlockAlertView showBlockAlertWithTitle:@"응답" message:responseString dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {} cancelButtonTitle:nil buttonTitles:@"확인", nil];
    } cancelButtonTitle:nil buttonTitles:@"확인", nil];
}

- (void)showSharePopup
{
    MobileWeb *action = [[NSClassFromString(@"requestSharePop") alloc] init];
    action.webView = (id)self.view;
    action.tag = @(80);
    action.paramDic = @{@"title":@"타이틀",
                        @"imgUrl":@"https://imgnews.pstatic.net/image/057/2018/08/14/0001276057_001_20180814013158941.jpg?type=w647",
                        @"page":[NSString stringWithFormat:@"liivmate://call?cmd=move_to&id=%@",MenuID_SimplePayment],
                        @"installUrl":@"http://m.naver.com"};
    action.successCallback = nil;
    action.failCallback = nil;
    [HybridActionManager regestAction:action];
    [action run];
}

-(void)PaymentRequestPopupTest
{
    [KCLPaymentRequestPopupView showPopupWithType:KCLPaymentCancelPopupTypeQR
                              barcodeValue:@"http://www.naver.com"
                                remainTime:10
                                 checkTime:0
                             checkFunction:nil
                              checkWebView:nil
                           dismissCallback:^(KCLPaymentCancelPopupCloseType closeType) {
                               if (closeType == KCLPaymentCancelPopupCloseTypeRecreationButton)
                               {
                                   NSLog(@"KCLPaymentRequestPopupViewCloseTypeRecreationButton");
                               }
                           }];
}

-(void)PaymentCancelPopupTest
{
    [KCLPaymentCancelPopupView showPopupWithType:KCLPaymentCancelPopupTypeBarcode
                             barcodeValue:@"1234-5678-9012-3456"
                               remainTime:10
                                checkTime:0
                            checkFunction:nil
                             checkWebView:nil
                          dismissCallback:^(KCLPaymentCancelPopupCloseType closeType) {
                              if (closeType == KCLPaymentCancelPopupCloseTypeRecreationButton)
                              {
                                  NSLog(@"KCLPaymentCancelPopupView CloseTypeRecreationButton");
                              }
                          }];
}

-(void)ToastTest
{
    //showSplashMessage(@"카드 결제수단이 변경되었습니다.", YES, NO);
    showSplashMessage(@"sdfsfdasdfjwioefjowiejfowienmvoiwenmvoiwne ovinw eoiv woev oweivnwoevnowevnowienvowenvoweinvwoievnwoienvowenbowienboweinbowenbownboiwrnoi", YES, NO);
}

- (void)KakaoMapNavi {
    [Permission checkLocationSettingAlert:YES permission:^(PERMISSION_STATUS statusNextProccess) { // 위치정보 퍼미션 체크
        if(statusNextProccess == PERMISSION_USE) { // 사용가능
            NSLog(@"PERMISSION_USE");

            // 위/경도 값 가져오기
            NSString *startPoint = [Permission getStartPointLocation];

            NSLog(@"startPoint == %@", startPoint);
            // 카카오맵 url Scheme route 이동 - TO BE: ep값은(도착지정보) 업무단에서 Hybrid 값으로 전달 받은 데이터(위/경도)를 사용 할 예정
            if ([AppDelegate canOpenURL:[NSURL URLWithString:@"kakaomap://"]]) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"kakaomap://roadView?p=37.537229,127.005515"] options:@{} completionHandler:nil];
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"kakaomap://place?id=7813422"] options:@{} completionHandler:nil]; // place id를 알수 없음
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"kakaomap://look?p=37.537229,127.005515"] options:@{} completionHandler:nil];
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"kakaomap://search?q=맛집&p=37.537229,127.005515"] options:@{} completionHandler:nil]; // 동작안함
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"kakaomap://route?sp=%@&ep=37.4979502,127.0276368&by=CAR", startPoint]] options:@{} completionHandler:nil];
            } else { // 카카오맵이 설치되어 있지 않으면.... (카카오맵은 iOS12 부터 지원)
                if (@available(iOS 12.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/id304608425?mt=8"] options:@{} completionHandler:nil];
                } else {
                    [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"IOS11버전 이하에서는 지원하지 않습니다. " dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                    } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
                }
            }
        } else { // 사용불가능
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"사용자 위치정보 조회를 허용해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {

            } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
            NSLog(@"statusNextProccess == %li", (NSInteger)statusNextProccess);
        }
    }];
}

- (void)KakaoMapTest {
    [Permission checkLocationSettingAlert:YES permission:^(PERMISSION_STATUS statusNextProccess) {
        if(statusNextProccess == PERMISSION_USE) {
            NSLog(@"PERMISSION_USE");
            WebViewController *webview = [[WebViewController alloc] init];
            webview.firstOpenUrl = @"https://map.kakao.com/";
            [self.navigationController pushViewController:webview animated:YES];
        } else {
            NSLog(@"statusNextProccess == %li", (NSInteger)statusNextProccess);
        }
    }];
}

- (void)UIActivityViewControllerTest {
    NSString *text = @"리브메이트";
    NSURL *url = [NSURL URLWithString:@"www.liivmate.com"]; // [NSURL URLWithString:@"http://roadfiresoftware.com/2014/02/how-to-add-facebook-and-twitter-sharing-to-an-ios-app/"]
    UIImage *image = [UIImage imageNamed:@"liivmateBi"];
    
    NSArray *activityItems = @[text, url, image]; // 공유 Item
    
    NSArray *applicationActivitys = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypeMessage]; // 공유하기 목록

    UIActivityViewController *activityViewController;
    
    activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivitys];

    // 정의된 공유 목록
//    UIKIT_EXTERN UIActivityType const UIActivityTypePostToFacebook     API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypePostToTwitter      API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypePostToWeibo        API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;    // SinaWeibo
//    UIKIT_EXTERN UIActivityType const UIActivityTypeMessage            API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypeMail               API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypePrint              API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypeCopyToPasteboard   API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypeAssignToContact    API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypeSaveToCameraRoll   API_AVAILABLE(ios(6.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypeAddToReadingList   API_AVAILABLE(ios(7.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypePostToFlickr       API_AVAILABLE(ios(7.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypePostToVimeo        API_AVAILABLE(ios(7.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypePostToTencentWeibo API_AVAILABLE(ios(7.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypeAirDrop            API_AVAILABLE(ios(7.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypeOpenInIBooks       API_AVAILABLE(ios(9.0)) __TVOS_PROHIBITED;
//    UIKIT_EXTERN UIActivityType const UIActivityTypeMarkupAsPDF        API_AVAILABLE(ios(11.0)) __TVOS_PROHIBITED;

    // 공유하기 제외 목록
    activityViewController.excludedActivityTypes = @[
                                                        UIActivityTypePostToWeibo,
                                                        UIActivityTypeMail,
                                                        UIActivityTypePrint,
                                                        UIActivityTypeCopyToPasteboard,
                                                        UIActivityTypeAssignToContact,
                                                        UIActivityTypeSaveToCameraRoll,
                                                        UIActivityTypeAddToReadingList,
                                                        UIActivityTypePostToFlickr,
                                                        UIActivityTypePostToVimeo,
                                                        UIActivityTypePostToTencentWeibo,
                                                        UIActivityTypeAirDrop,
                                                        UIActivityTypeOpenInIBooks,
                                                        UIActivityTypeMarkupAsPDF
                                                     ];
    
    // 공유하기 성공 유무
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
         NSLog(@"activityType == %@", activityType);
         NSLog(@"completed == %d", completed);
         NSLog(@"returnedItems == %@", returnedItems);
         NSLog(@"activityError == %@", activityError);
        
        if (activityType != nil) {
            if ([activityType rangeOfString:@"line"].location != NSNotFound && !completed) {
                [BlockAlertView showBlockAlertWithTitle:nil message:@"메시지를 보내시려면 라인을 열고 로그인하세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {

                } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
            }
            else if ([activityType rangeOfString:@"PostToTwitter"].location != NSNotFound && !completed) {
                [BlockAlertView showBlockAlertWithTitle:@"로그인해주세요" message:@"메시지를 보내시려면 트위터을 열고 로그인하세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {

                } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
            }
        }
//        else if ([activityType rangeOfString:@"PostToFacebook"].location != NSNotFound && !completed) {
//            [BlockAlertView showBlockAlertWithTitle:@"로그인해주세요" message:@"메시지를 보내시려면 페이스북을 열고 로그인하세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
//
//            } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
//        } else if ([activityType rangeOfString:@"KakaoTalk"].location != NSNotFound && !completed) {
//            [BlockAlertView showBlockAlertWithTitle:@"로그인해주세요" message:@"메시지를 보내시려면 카카오톡을 열고 로그인하세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
//
//            } cancelButtonTitle:nil buttonTitles:AlertConfirm, nil];
//        }
    }];
   
    //공유 화면 뛰우기
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)testPaymentCompleteVC
{
    
    [[AllMenu delegate] navigationWithMenuID:MenuID_SimplePaymentComplete
                                    animated:YES
                                      option:NavigationOptionPush    //NavigationOptionNavigationModal //NavigationOptionPush
                                    callBack:^(ViewController *vc)
     {
         vc.dicParam = @"{\"tranTrackNo\":\"181114181256\",\"cardAthorCnclDstcd\":\"0\",\"totAmt\":1000,\"stmpSubtrStorYn\":\"Y\",\"cardAthorNo\":\"34381321\",\"regiYMS\":\"20181114\",\"bzno\":\"128-37-51050\",\"tranOccurNo\":\"20181114181256002050\",\"intmMnths\":\"00\",\"stmpSubtrBoonDstcd\":\"\",\"cardNo\":\"9491-02**-****-1794\",\"tranYmd\":\"20181114\",\"tranHMS\":\"181256\",\"cardPyaccAmt\":0,\"rprsName\":\"신진섭\",\"mbrmchNo\":\"000000072066387\",\"cnclYmd\":null,\"mbrmchAddr\":\"(정발산동)\",\"tranCtnt\":\"\",\"cnclHMS\":null,\"stmpSubtrPrsntnPrdctCtnt\":\"\",\"tranStusDstcd\":\"01\",\"tranDsticNo\":null,\"pointUseAmt\":1000,\"stmpInsSubtrCtnt\":\"1\",\"mbrmchTelno\":\"031)902-1223        \",\"maskedNoCd\":null,\"stmpSubtrCtnt\":\"\",\"cardAthorCnclDst\":null,\"tranPtrnDstcd\":null,\"serviceAmt\":0,\"cardKndDstcd\":null,\"dstStus\":\"정상거래\",\"tranAmt\":1000,\"trnOccurNo\":null,\"orglAthorNo\":null,\"dcAmt\":0,\"custID\":\"P20180276941\",\"mbrmchName\":\"평화건강원\",\"dcRate\":\"\"}".jsonObject;
     }];
}

- (void)clickJoinAndEarning
{
    [TASDKManager openKBEarningMenu:@"12345678" adPushYn:nil gender:nil birthYear:nil];
}
- (void)clickTouchadMain
{
    [TASDKManager openKBTouchadMenu:@"12345678" adPushYn:nil gender:nil birthYear:nil callback:nil];
}
- (void)clickTouchad
{
    NSDictionary * userInfo = @{@"custom-type" : @"touchad",
                                @"custom-body" : @"%7B%22touchad%22%3A%22touchad%3A%2F%2Ft.ta.runcomm.co.kr%2Fsrv%2Fadvertise%2Fmobile%2Fselect%2Fkb%3FonOff%3D1%26cd%3D1916%26cardIdx%3D896%22%7D"};
    
    [TASDKManager openKBAdvertise:@"12345678" userInfo:userInfo];
}
- (void)clickEarningResult
{
    NSDictionary * userInfo = @{@"custom-type" : @"touchad",
                                @"custom-body" : @"%7B%22touchad%22%3A%22touchad%3A%2F%2Ft.ta.runcomm.co.kr%2Fsrv%2Fadvertise%2Fmobile%2Fselect%2Fkb%3FonOff%3D1%26cd%3D1916%26cardIdx%3D896%22%7D"};
    
    [TASDKManager openKBEarningResult:@"12345678" userInfo:userInfo];
}
- (void)clickEarningResult5
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary * userInfo = @{@"custom-type" : @"touchad",
                                    @"custom-body" : @"%7B%22touchad%22%3A%22touchad%3A%2F%2Ft.ta.runcomm.co.kr%2Fsrv%2Fadvertise%2Fmobile%2Fselect%2Fkb%3FonOff%3D1%26cd%3D1916%26cardIdx%3D896%22%7D"};
        
        [TASDKManager openKBEarningResult:@"12345678" userInfo:userInfo];
    });
}

- (void)testImageDownload
{
    // ???? 이미지 다운로드 테스트
    [NSClassFromString(@"getAuthToken") runWithParam:@{} callback:^(NSDictionary *result, BOOL success) {
        
        if (success)
        {
            NSString *token = result[@"X-Auth-Token"];
            NSString *downloadURL = @"https://ssproxy.ucloudbiz.olleh.com/v1/AUTH_d4ea23b0-ea3f-4b12-bd90-27b6a2a493d0/lm_8bd1c515a8564216b888f54ee6d583008970f816101848dedfae07283a8b3c13/lm_20180831143925684.jpg";
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            request.timeoutInterval = 30;
            request.HTTPMethod = @"GET";
            request.URL = [NSURL URLWithString:downloadURL];
            [request setValue:token forHTTPHeaderField:@"X-Auth-Token"];
            
            NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
                    view.image = [[UIImage alloc] initWithData:data];
                    [BlockAlertView showBlockAlertWithTitle:nil message:view dismisTitle:AlertConfirm];
                });
                
            }];
            [task resume];
        }
    }];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _viewList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ssdfsd"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"ssdfsd"];
    }
    NSDictionary *dic = [_viewList objectAtIndex:indexPath.row];
    NSString *classNm = [dic objectForKey:@"class"];
    int depth = [[dic objectForKey:@"depth"] intValue];
    NSMutableString *format = [NSMutableString string];
    for(int i = 1; i < depth; i++)
    {
        [format appendString:@"\t"];
    }
    [format appendString:@"%@"];
    
    NSDictionary *menu = [AllMenu menuForClass:classNm];
    cell.textLabel.text = [NSString stringWithFormat:format,[dic objectForKey:@"title"]];
    if([self respondsToSelector:NSSelectorFromString(classNm)])
        cell.textLabel.textColor = [UIColor purpleColor];
    else if(NSClassFromString([[menu objectForKey:K_ClassName] componentsSeparatedByString:@"."].lastObject))
    {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else
    {
        cell.textLabel.textColor = NSClassFromString(classNm) || [self respondsToSelector:NSSelectorFromString(classNm)] ? [UIColor blueColor] : [UIColor redColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_viewList objectAtIndex:indexPath.row];
    NSString *classNm = [dic objectForKey:@"class"];
    BOOL modal = [[dic objectForKey:@"modal"] boolValue];
    if([self respondsToSelector:NSSelectorFromString(classNm)])
    {
        [self performSelector:NSSelectorFromString(classNm)];
        return;
    }
    
    if([classNm isEqualToString:@"MobileWeb.KBOpenApiTermDetailVC"]) // MobileWeb.KBOpenApiTermVC_V2        OpenApiTermDetailVC
//    if([classNm isEqualToString:@"OpenApiTermDetailVC"])
    {
        KBOpenApiTermDetailVC *vc = [[KBOpenApiTermDetailVC alloc] init];
        vc.title = @"개인정보 제3자 제공 동의(필수)";
        vc.agreeBody = @"개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- <option class=\"apiAgreeHL\">FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리</option>\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.";
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    else if([classNm isEqualToString:@"BuzzAdBenefitViewController"]) {
//        UIViewController *vc = [[NSClassFromString(classNm) alloc] init];
//
//        [self.navigationController pushViewController:vc animated:YES];
        
        BABFeedConfig *config = [[BABFeedConfig alloc] initWithUnitId:BUZZ_FEED_UNIT_ID];
        config.title = @"보고쌓기";
        config.articlesEnabled = YES;
        config.articleCategories = @[BABArticleCategoryAnimal, BABArticleCategoryBusiness, BABArticleCategoryEntertainment, BABArticleCategoryFashion, BABArticleCategoryFood, BABArticleCategoryFun, BABArticleCategoryGame, BABArticleCategoryHealth, BABArticleCategoryLifestyle, BABArticleCategoryNews, BABArticleCategoryRelationship, BABArticleCategorySports, BABArticleCategoryTechnology];
        config.adViewHolderClass = [CustomAdViewHolder class];

        BABFeedHandler *feedHandler = [[BABFeedHandler alloc] initWithConfig:config];
        [self presentViewController:[feedHandler populateViewController] animated:YES completion:nil];
        
        
        return;
    }
    else if([classNm isEqualToString:@"MDDesignPopupView"]){
        MDDesignPopupView *popupView = [MDDesignPopupView instance];
        
        [self.view addSubview:popupView];
        [popupView showDesignView:YES];
        return;
    }
    else if([classNm isEqualToString:@"KCLRightPopupView"]){
        KCLRightPopupView *popupView = [KCLRightPopupView instance];
        
        [self.view addSubview:popupView];
        [popupView showDesignView:YES];
        return;
    }
    else if([classNm isEqualToString:@"ComponentTestViewController"])
    {
//        [[[inviteAddressBook alloc] init] runWithParam:@{@"mCount" : @(rand()%2+10) } callback:^(NSDictionary *result, BOOL success) {
//        }];
                
        return;
    }
    else if([classNm isEqualToString:@"KBAddressView"])
    {
        KBAddressView *addView = [KBAddressView initWithLimitedType:TYPE_ONE_LIMITED filterType:@"" title:@"" dismissAnimated:NO completeBlock:^(BOOL success, CONTACTS_TYPE typeContact, NSArray *result) {
            
            if (success) {
                NSLog(@"---- result %@", result);
                
                NSMutableArray *numsArray = [[NSMutableArray alloc] init];
                for( NSDictionary *subDic in result )
                {
                    [numsArray addObject:@{@"name" : [subDic objectForKey:KEY_NAME],
                                           @"phone" : [subDic objectForKey:KEY_NUM],
                                           }];
                }
            }
            
        } menues:TYPE_FRIEND,/*([AppInfo sharedInfo].isLogin ? TYPE_FRIEND : nil),*/ nil];
        addView.inviteMode = NO;
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:addView];
        [(UINavigationController *)[AllMenu delegate] presentViewController:nvc animated:YES completion:nil];
        return;
    }
    else if([classNm isEqualToString:@"deleteAppid"])
    {
        [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"앱을 초기화 합니다" dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:AlertConfirm])
            {
                [UserDefaults sharedDefaults].appID = nil;
                [UserDefaults sharedDefaults].showTutorial = NO;
                [[UserDefaults sharedDefaults] synchronize];
                [[AppInfo sharedInfo] performLogout:^(BOOL success) {
                    exit(0);
                }];
            }
        } cancelButtonTitle:AlertCancel buttonTitles:AlertConfirm, nil];
        return;
    }
    else if([classNm isEqualToString:@"logOut"])
    {
        [[AppInfo sharedInfo] performLogout:^(BOOL success) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    else if([classNm isEqualToString:@"deleteKey"])
    {
        //        FidoTermDetailViewController *vc = [[FidoTermDetailViewController alloc] init];
        //        vc.title = @"개인정보 제3자 제공 동의(필수)";
        //        vc.text = @"개인정보 제3자 제공 동의(필수)\n\n\n1. 개인정보의 제공 목적\n\t- FIDO기반 지문인증서비스(이하 “본 서비스”)의 제공, 유지, 관리\n\t- 회원식별 등 회원관리, “본 서비스” 및 부가/제휴서비스 제공, 상담/민원/분쟁의 처리/해결, 거래사실 확인, 기록 보존, 법령상 의무이행 등\n\n2. 개인정보의 제공 항목\n\t- User ID, Device ID\n\n3. 개인정보를 제공받는 자\n\t- 브이피㈜\n\n4. 제공받는 자의 개인정보의 보유 및 이용기간\n\t- 위 개인정보의 수집 및 이용 동의일로부터 제공 목적을 달성할 때까지 보유 및 이용하게 되며, 관련 법령에서 별도 규정이 명시되어 있는 경우 그 기간에 따릅니다.\n\n5. 동의를 거부할 권리 및 거부할 경우의 불이익\n\t- 위 사항에 대해 동의를 거부할 수 있으나, 본 동의 내용은 “본 서비스” 가입, 유지 등을 위해 필수 사항으로 동의하지 않으실 경우 서비스 이용이 불가할 수 있음을 알려드립니다.\n\n\n본인은 귀 사가 상기 내용으로 개인정보를 제공하는 것에 동의합니다.";
        //        [self.navigationController pushViewController:vc animated:YES];
        //        return;
        
    }
    if([[dic objectForKey:@"Component"] boolValue])
    {
        ViewController *vc = [[ViewController alloc] init];
        UIView * view = [[NSClassFromString(classNm) alloc] initWithFrame:CGRectMake(10, 20, CGRectGetWidth(vc.view.bounds)-20, 100)];
        if([view respondsToSelector:@selector(setDelegate:)])
            [view performSelector:@selector(setDelegate:) withObject:self];
        [vc.view addSubview:view];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if(NSClassFromString(classNm))
    {
        ViewController *vc = [[NSClassFromString(classNm) alloc] init];
        
        if(vc)
        {
            if(indexPath.row < 6)
            {
                UIButton *button = [UIButton buttonWithType:(UIButtonTypeInfoDark)];
                button.frame = CGRectMake(0, 20, 30, 30);
                [button addTarget:self action:@selector(popViewController) forControlEvents:(UIControlEventTouchUpInside)];
                [vc.view addSubview:button];
            }
            
            if([vc isKindOfClass:[WebViewController class]])
            {
                ((WebViewController*)vc).firstOpenUrl = [dic objectForKey:@"link"];
                vc.dicParam = dic[@"params"];
            }
            
            
            if([vc respondsToSelector:@selector(initPreprocessingCallback:)])
            {
                [vc initPreprocessingCallback:^(BOOL success) {
                    if(success == NO) return;
                    if(modal)
                    {
                        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                        [self presentViewController:nvc animated:YES completion:^{
                            
                        }];
                    }
                    else
                        [self.navigationController pushViewController:vc animated:YES];
                }];
            }
            else
            {
                if(modal)
                {
                    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                    [self presentViewController:nvc animated:YES completion:^{
                        
                    }];
                }
                else
                    [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else if([classNm rangeOfString:@"."].location != NSNotFound)
    {
        NSArray *classNmArr = [classNm componentsSeparatedByString:@"."];
        ViewController *vc = nil;
        if(classNmArr.count == 2)
        {
            UIStoryboard *story = [UIStoryboard storyboardWithName:classNmArr.firstObject bundle:nil];
            vc = [story instantiateViewControllerWithIdentifier:classNmArr.lastObject];
        }
        
        if([vc isKindOfClass:[WebViewController class]])
        {
            ((WebViewController*)vc).firstOpenUrl = [dic objectForKey:@"link"];
            vc.dicParam = dic[@"params"];
        }
        
        if([self respondsToSelector:@selector(initPreprocessingCallback:)])
        {
            [vc initPreprocessingCallback:^(BOOL success) {
                if(success == NO) return;
                if(modal)
                {
                    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                    [self presentViewController:nvc animated:YES completion:^{
                        
                    }];
                }
                else
                    [self.navigationController pushViewController:vc animated:YES];
            }];
        }
        else
        {
            if(modal)
            {
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nvc animated:YES completion:^{
                    
                }];
            }
            else
                [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    NSDictionary *menu = [AllMenu menuForClass:classNm];
    NSArray *viewID = [menu objectForKey:K_VIEWID];
    if(NSClassFromString([[menu objectForKey:K_ClassName] componentsSeparatedByString:@"."].lastObject))
    {
        NavigationOption optin = NavigationOptionPush;
        if(modal) optin = NavigationOptionNavigationModal;
        [[AllMenu delegate] navigationWithMenuID:viewID.firstObject animated:YES option:optin callBack:^(ViewController *vc) {
            if ([dic objectForKey:@"param"] != nil) {
                vc.dicParam = [dic objectForKey:@"param"];
            }
            //            if(indexPath.row < 4)
            //            {
            //                UIButton *button = [UIButton buttonWithType:(UIButtonTypeInfoDark)];
            //                button.frame = CGRectMake(0, 20, 30, 30);
            //                [button addTarget:self action:@selector(popViewController) forControlEvents:(UIControlEventTouchUpInside)];
            //                [vc.view addSubview:button];
            //            }
            if([vc isKindOfClass:[WebViewController class]])
            {
                ((WebViewController*)vc).firstOpenUrl = [dic objectForKey:@"link"];
                vc.dicParam = dic[@"params"];
            }
        }];
    }
}

-(void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)startDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
    NSLog(@"start = %@, end = %@", startDate, endDate);
}

-(void)startDateStr:(NSString*)startDate endDateStr:(NSString*)endDate
{
    NSLog(@"start = %@, end = %@", startDate, endDate);
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




//#pragma mark - 테스트 코드
//
//-(void)openChannelList
//{
//    if([AppInfo sharedInfo].cId == nil){
//        [AppInfo sharedInfo].cId = @"katios";
//        [AppInfo sharedInfo].sendBirdToken = @"b853c1272c1eqa0dfb7212a13c5df8e377a24c37";
//    }
//    MSGChannelListViewController *vc = [[MSGChannelListViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
@end
#endif
