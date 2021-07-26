//
//  AllMenu.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 8. 8..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "AllMenu.h"
#import "GoogleAnalyticsBuilder.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@interface AllMenu ()
@property (nonatomic, strong) NSMutableArray *appMenuList;
@property (nonatomic, strong) NSMutableArray *allMenu;
@property (nonatomic, strong) NSMutableDictionary *trgEvtMenu;
@end

@implementation AllMenu
static AllMenu *menuObj = nil;
static NSMutableString *failViewID = nil;
static NSArray *noneRequestMenu = nil;

+(NSMutableDictionary*)getGa360DefaultDictionary{
    NSMutableDictionary *screenView_dict = [[NSMutableDictionary alloc] init];
    
    //INFO:USER
//    NSString *dimension1        = strIDFA;//@"UA-65962490-15";
//    NSString *dimension1        = [AppInfo userInfo].cId; //@"UA-65962490-15";        //기존코드로 바꿔달라고 골든플레닛 요청 0528
    id<GAITracker> mTracker = [[GAI sharedInstance] defaultTracker];
    NSString *dimension1 = [mTracker get:@"&cid"];  // 골든플레닛 요청 0728
    
    NSString *dimension2 = [NSString sha256HashForText:[AppInfo userInfo].custNo];    // GA360 dimension2 값 변경 (custNo->kbpin) - 데이터혁신부 회신 // 0720 - 데이터 혁신부 요청 사항 원복
    
    NSString *dimension3 = @"0";
    if([AppInfo sharedInfo].isLogin){
        dimension3 = @"1";
    }
    
    NSString *dimension4     = [AppInfo userInfo].custGbnCd;
    
    NSString *dimension5     = @"";
    if([AppInfo userInfo].age != nil){
        int temp = [[AppInfo userInfo].age intValue];
        if (temp < 20) {
            dimension5 = @"10";
        } else if (temp < 30) {
            dimension5 = @"20";
        } else if (temp < 40) {
            dimension5 = @"30";
        } else if (temp < 50) {
            dimension5 = @"40";
        } else if (temp < 60) {
            dimension5 = @"50";
        } else {
            dimension5 = @"60";
        }
    }
    NSString *dimension6     = [AppInfo userInfo].gender;    //고객성별 남:1,여:2
    NSString *dimension7     = @"";    //KB스타클럽 등급
    NSString *dimension8     = [AppInfo userInfo].point.intValue > 0 ? @"1":@"0";    //보유포인트 보유:1 , 미보유:0
    NSString *dimension9     = @"";     //자산연동 여부 연동:1 , 미연동:0
    NSString *dimension10     = @"";   //연동 금융기관이 있는경우
    NSString *dimension11     = @"";   //고객충전수단등록여부 등록:1 , 미등록:0
    NSString *dimension12     = @"";   //고객자동충전등록여부 등록:1 , 미등록:0
    NSString *dimension13     = @"";   //고객카드보유여부
    //INFO:EVENT HIT
    NSString *dimension14     = @"";   //GA화면정의 엑셀파일 > 화면명(컬럼):사용자가조회한 사이트 화면 코드 값
    NSString *dimension15     = @"";   //GA화면정의 엑셀파일 > 카테고리(컬럼):사용자가 유입된 메뉴 경로를 나타낸 값
    NSString *dimension16     = @"";   //이벤트_이벤트코드 이벤트 페이지 내 eventid값 전송
    NSString *dimension17     = @"";   //이벤트_이벤트상세명 : 해당이벤트명 전송
    NSString *dimension18     = @"";   //이벤트_추천시나리오ID : PD_RCM_SBROI_MG_NO
    NSString *dimension19     = @"";   
    
    if (![AppInfo sharedInfo].isIdfaDisable) {
        // IDFA(광고 식별자) 등록 - 최초/재가입시 서버와 통신(서버에서 최초 가입 판단해서 진행)
        NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        dimension19    = IDFA.UUIDString;
    }
    
//    NSString *dimension20    = [AppInfo userInfo].kpinDes;  // 로그인시 받아 온 kpin값 (DES 암호화 알고리즘 적용된 값 - 데이터혁신부 요청 사항(0720)
    
    [screenView_dict setValue:dimension1 forKey:GACustomKey(Dimension1)];
    [screenView_dict setValue:dimension2 forKey:GACustomKey(Dimension2)];
    [screenView_dict setValue:dimension3 forKey:GACustomKey(Dimension3)];
    [screenView_dict setValue:dimension4 forKey:GACustomKey(Dimension4)];
    [screenView_dict setValue:dimension5 forKey:GACustomKey(Dimension5)];
    [screenView_dict setValue:dimension6 forKey:GACustomKey(Dimension6)];
    [screenView_dict setValue:dimension7 forKey:GACustomKey(Dimension7)];
    [screenView_dict setValue:dimension8 forKey:GACustomKey(Dimension8)];
    [screenView_dict setValue:dimension9 forKey:GACustomKey(Dimension9)];
    [screenView_dict setValue:dimension10 forKey:GACustomKey(Dimension10)];
    [screenView_dict setValue:dimension11 forKey:GACustomKey(Dimension11)];
    [screenView_dict setValue:dimension12 forKey:GACustomKey(Dimension12)];
    [screenView_dict setValue:dimension13 forKey:GACustomKey(Dimension13)];
    [screenView_dict setValue:dimension14 forKey:GACustomKey(Dimension14)];
    [screenView_dict setValue:dimension15 forKey:GACustomKey(Dimension15)];
    [screenView_dict setValue:dimension16 forKey:GACustomKey(Dimension16)];
    [screenView_dict setValue:dimension17 forKey:GACustomKey(Dimension17)];
    [screenView_dict setValue:dimension18 forKey:GACustomKey(Dimension18)];   //이벤트_추천시나리오ID : PD_RCM_SBROI_MG_NO
    [screenView_dict setValue:dimension19 forKey:GACustomKey(Dimension19)];
//    [screenView_dict setValue:dimension20 forKey:GACustomKey(Dimension20)]; // 데이터혁신부 요청 사항(0720)
    return screenView_dict;

}


//로그인이 되어있거나 로그인이후 블럭이 호출된다.
+(void)checkLoginBlock:(void (^)(void))block
{
    if([AppInfo sharedInfo].isLogin == NO)
    {
        if([AppInfo sharedInfo].isJoin)
        {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"서비스 이용을 위해\n로그인이 필요합니다." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"로그인"])
                {
                    [[AppInfo sharedInfo] performLogin:^(BOOL success, NSString *errCD, NSDictionary* result) {
                        if (success)
                        {
                            if(block) block();
                        }
                    }];
                }
            } cancelButtonTitle:AlertCancel buttonTitles:@"로그인", nil];
        }
        else
        {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"서비스 이용을 위해\n회원가입이 필요합니다." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"회원가입"])
                {
                    // Ver. 3 회원가입(MYD_JO0100) TO BE : 회원가입 화면으로 보내는 부분 확인 필요
//                  [self navigationWithMenuID:MenuID_V3_MateJoin animated:YES option:(NavigationOptionPush) callBack:nil];
                }
            } cancelButtonTitle:AlertCancel buttonTitles:@"회원가입", nil];
        }
    }
    else
    {
        if(block)
            block();
    }
}

+(NSDictionary*)getEtcMenuDictionary:(NSString*)menuID{
    NSDictionary *selectedMenuDic;
    NSArray *etcArray = [[AllMenu menu].appMenu objectForKey:@"etc"];
    
    for(NSDictionary *dic in etcArray){
        if([[dic valueForKey:@"screnId"] isEqualToString:menuID]){
            selectedMenuDic = dic;
            break;
        }
    }
    return selectedMenuDic;
}

+ (void)setStatusBarStyle:(BOOL)enableMainColor viewController:(UIViewController*)vc {
    if (enableMainColor) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//        if (@available(iOS 13.0, *)) {
//            CGRect rect = [[[[[UIApplication sharedApplication] keyWindow] windowScene] statusBarManager] statusBarFrame];
//            UIView* statusBarView = [APP_DELEGATE statusBarView];
//            if(statusBarView == nil){
//                statusBarView = [[UIView alloc] initWithFrame:rect];
//                AppDelegate * appDelegate = APP_DELEGATE;
//                appDelegate.statusBarView = statusBarView;
//                [[APP_DELEGATE window] addSubview:statusBarView];
//            } else {
//                [[APP_DELEGATE window] bringSubviewToFront:statusBarView];
//            }
//            statusBarView.backgroundColor = COLOR_MAIN_BLUE;
//        }
//        else {
//            UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//            statusBar.backgroundColor = COLOR_MAIN_BLUE;
//        }
    } else {
        [UIApplication sharedApplication].statusBarStyle = [vc preferredStatusBarStyle];
//        if (@available(iOS 13.0, *)) {
//            CGRect rect = [[[[[UIApplication sharedApplication] keyWindow] windowScene] statusBarManager] statusBarFrame];
//            UIView* statusBarView = [APP_DELEGATE statusBarView];
//            if(statusBarView == nil){
//                statusBarView = [[UIView alloc] initWithFrame:rect];
//                AppDelegate * appDelegate = APP_DELEGATE;
//                appDelegate.statusBarView = statusBarView;
//                [[APP_DELEGATE window] addSubview:statusBarView];
//            } else {
//                [[APP_DELEGATE window] bringSubviewToFront:statusBarView];
//            }
//            statusBarView.backgroundColor = COLOR_WHITE;
//        }
//        else {
//            UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//            statusBar.backgroundColor = COLOR_WHITE;
//        }
    }
//    [UIApplication sharedApplication].statusBarStyle = [vc preferredStatusBarStyle];
    [vc setNeedsStatusBarAppearanceUpdate];
}

+(void)initialize
{
	[super initialize];
	if(noneRequestMenu == nil)
	{//네이티브 화면으로 메뉴검색전문 생략해야할 id List
		noneRequestMenu = @[MenuID_Tutorial, MenuID_AddressBook, MenuID_SecureKeypad,
							MenuID_Splash, MenuID_MyQR, MenuID_AffiliateStampQR,
							MenuID_AffiliateLocRegister, MenuID_AffiliateLocRegisterSingle,
							MenuID_AffiliateStoreList, MenuID_SimplePaymentComplete, MenuID_ScannerSend,
							MenuID_ScannerCancel, MenuID_PaymentBarcodeZoom, MenuID_SimplePayment,
							MenuID_SimplePaymentQR];
	}
}

+(AllMenu*)menu
{
	if(menuObj == nil)
	{
		menuObj = [[AllMenu alloc] init];
	}
	return menuObj;
}

+(id<MenuNavigationDelegate>)delegate
{
	return menuObj.delegate;
}

+(NSDictionary*)menuIdForUrl:(NSString*)urlStr
{
	if([urlStr containsString:@"?"])
	{
		NSRange rang = [urlStr rangeOfString:@"?"];
		urlStr = [urlStr substringToIndex:rang.location];
	}
	NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"%K MATCHES[c] %@",K_URL_ADDR, urlStr];
	NSDictionary *menu = [[[AllMenu menu].appMenuList filteredArrayUsingPredicate:findPredicate] firstObject];
	return [menu valueForKey:K_VIEWID];
}

+(NSDictionary*)menuForID:(NSString*)viewID
{
	if(viewID.length == 0) return nil;
	//서버에서 내려받은 데이터에서 먼저 검색을 한다.
	NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"%K == %@",K_VIEWID, viewID];
	__block NSDictionary *menu = [[[AllMenu menu].appMenuList filteredArrayUsingPredicate:findPredicate] firstObject];
	
    // Ver. 3 viewID 추가 (MYD_)
	if(menu == nil && (([viewID rangeOfString:@"KAT_"].location == 0 || [viewID rangeOfString:@"MYD_"].location == 0 || [viewID rangeOfString:@"MYD4_"].location == 0) && [noneRequestMenu containsObject:viewID] == NO))
	{
		if(failViewID == nil)
			failViewID = [[NSMutableString alloc] init];
		if([failViewID rangeOfString:viewID].location == NSNotFound)
		{
            // ver.3 화면URL조회 (KATW003)
            [Request requestID:KATW003
                          body:@{K_VIEWID : viewID}
                 waitUntilDone:YES
                   showLoading:YES
                     cancelOwn:self
                      finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                          if(IS_SUCCESS(rsltCode) || [rsltCode isEqualToString:@"200"]) //서버통신 0000으로 넘어와야 통과하는데 200으로 넘어와 임시 200통과 처리. 
                          {
                              menu = result;
                              [(NSMutableArray*)[AllMenu menu].appMenuList addObject:result];
                          }
                          else
                          {
                              [failViewID appendString:[NSString stringWithFormat:@"%@,",viewID]];
                          }
                      }];
		}
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN %K",viewID,K_VIEWID];
	NSArray *array = [[AllMenu menu].allMenu filteredArrayUsingPredicate:predicate];
	
	if(array.count)
	{//네이티브도 있을경우
		NSMutableDictionary *dic = [array.firstObject mutableCopy];
		NSInteger index = [[dic valueForKey:K_VIEWID] indexOfObject:viewID];
		[dic setValue:@(index) forKey:@"index"];
		[dic addEntriesFromDictionary:menu];
		if(menu == nil)
		{//네이티브에만 메뉴가 존재하는 경우.
			[dic setValue:viewID forKey:K_VIEWID];
			[(NSMutableArray*)[AllMenu menu].appMenuList addObject:dic];
		}
		else
			[dic addEntriesFromDictionary:menu];
		menu = dic;
	}
	else
	{//screnDstcd : 1 - 네이티브, 2 - 하이브리드, 4 - 제휴및 외부웹사이트
		if([menu[K_SCREN_DSTCD] intValue] == 4)
		{//제휴및 외부웹사이트
			predicate = [NSPredicate predicateWithFormat:@"%@ IN %K",MenuID_AlianceWeb,K_VIEWID];
			array = [[AllMenu menu].allMenu filteredArrayUsingPredicate:predicate];
			NSMutableDictionary *dic = [array.firstObject mutableCopy];
			[dic addEntriesFromDictionary:menu];
			menu = dic;
        } else if([menu[K_SCREN_DSTCD] intValue] == 1){
            return nil;
        } else if([menu null_objectForKey:K_URL_ADDR])

		{//url이 있으면 하이브리드 웹뷰로 연다.
			predicate = [NSPredicate predicateWithFormat:@"%@ IN %K",MenuID_WebViewVC,K_VIEWID];
			array = [[AllMenu menu].allMenu filteredArrayUsingPredicate:predicate];
			NSMutableDictionary *dic = [array.firstObject mutableCopy];
			[dic addEntriesFromDictionary:menu];
			menu = dic;
		}
	}
	
	return menu;
}

+(NSDictionary*)menuForClass:(NSString*)classStr
{
	NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"%K == %@",K_ClassName, classStr];
	NSArray *array = [[AllMenu menu].allMenu filteredArrayUsingPredicate:findPredicate];
	return array.firstObject;
}

+(NSInteger)groupIndex:(NSString*)viewID
{
	NSDictionary *menu = [self menuForID:viewID];
	if(menu == nil) return 0;
	NSArray *viewIDs = [menu objectForKey:K_VIEWID];
	NSInteger index = [viewIDs indexOfObject:viewID];
	return index == NSNotFound ? 0 : index;
}

+(ViewController*)controllerForMenu:(NSDictionary*)menu
{
    NSArray *classNm = [[menu objectForKey:K_ClassName] componentsSeparatedByString:@"."];
    if(classNm.count == 2)
    {//여기서 오류발생시 메뉴 Class에 등록된 스토리보드 이름, Identifier 확인필요.(ex - stroyboardFileName.viewControllerIdentifier)
		//static
		UIStoryboard *story = nil;
        story = [UIStoryboard storyboardWithName:classNm.firstObject bundle:nil];
        return [story instantiateViewControllerWithIdentifier:classNm.lastObject];
    }
    else if(classNm.count == 1)
    {
        return [[NSClassFromString(classNm.firstObject) alloc] init];
    }
    return nil;
}

+(BOOL)isMenuEnabled:(id)menuItem
{
	if([menuItem isKindOfClass:[NSString class]])
		menuItem = [self menuForID:menuItem];
	NSArray *options = [menuItem objectForKey:K_MenuEnabled];
	if(options.count != 2) return YES;
	
	NSString * selectorStr = options.firstObject;
	NSNumber * option = options.lastObject;
	if(options && [[AppInfo sharedInfo] respondsToSelector:NSSelectorFromString(selectorStr)])
	{
		return [[[AppInfo sharedInfo] valueForKey:selectorStr] boolValue] == option.boolValue;
	}
	return YES;
}

+(BOOL)isMenuHidden:(id)menuItem
{
	if([menuItem isKindOfClass:[NSString class]])
		menuItem = [self menuForID:menuItem];
	NSArray *options = [menuItem objectForKey:K_MenuHidden];
	if(options.count != 2) return NO;
	
	NSString * selectorStr = options.firstObject;
	NSNumber * option = options.lastObject;
	if(options && [[AppInfo sharedInfo] respondsToSelector:NSSelectorFromString(selectorStr)])
	{
		return [[[AppInfo sharedInfo] valueForKey:selectorStr] boolValue] == option.boolValue;
	}
	return NO;
}

+(NSString*)trgPageIdforViewId:(NSString*)viewID
{
	return [[AllMenu menu].trgEvtMenu valueForKey:viewID];
}

-(void)makeTrgEvtMenuDic
{
	if(_trgEvtMenu == nil)
	{
		//TODO: AS-IS에서 쓰던 화면id 번역로직, 이전에 발송된 샌드버드 메시지 화면이동관련, 차후 삭제해도 무관할듯함.
		self.trgEvtMenu = [[NSMutableDictionary alloc] init];
		
		//메인화면
		[_trgEvtMenu setValue:MenuID_MainPage forKey:@"APP_0000004"];
		//내 쿠폰함
		[_trgEvtMenu setValue:MenuID_CouponStorage forKey:@"APP_0000072"];
		//거래내역조회
		[_trgEvtMenu setValue:MenuID_PointreeHistory forKey:@"APP_0000093"];
		//포인트리 계좌정보
		[_trgEvtMenu setValue:@"KAT_MYPG_026"forKey:@"APP_0000097"];
		//포인트리 카드정보
		[_trgEvtMenu setValue:@"KAT_MYPG_026" forKey:@"APP_0000098"];
		//포인트리 보내기
		[_trgEvtMenu setValue:@"KAT_PONT_003" forKey:@"APP_0000106"];
		//자동보내기 목록
		[_trgEvtMenu setValue:@"KAT_MYPG_032" forKey:@"APP_0000114"];
		//자동보내기 등록 메인
		[_trgEvtMenu setValue:@"KAT_MYPG_036" forKey:@"APP_0000117"];
		//ATM출금안내
		[_trgEvtMenu setValue:@"KAT_PONT_010" forKey:@"APP_0000124"];
		//충전수단 카드목록
		[_trgEvtMenu setValue:@"KAT_MYPG_026" forKey:@"APP_0000127"];
		//충전수단 카드등록
		[_trgEvtMenu setValue:@"KAT_MYPG_026" forKey:@"APP_0000129"];
		//충전수단 계좌등록
		[_trgEvtMenu setValue:@"KAT_MYPG_026" forKey:@"APP_0000134"];
		//충전하기 카드
		[_trgEvtMenu setValue:@"KAT_MYPG_026" forKey:@"APP_0000136"];
		//카드충전완료
		[_trgEvtMenu setValue:MenuID_PointreeHistory forKey:@"APP_0000141"];
		//자동충전
		[_trgEvtMenu setValue:@"KAT_MYPG_029" forKey:@"APP_0000144"];
		//교환하기
		[_trgEvtMenu setValue:@"KAT_PONT_024" forKey:@"APP_0000150"];
		//교환하기 - 아시아나항공마일리지
		[_trgEvtMenu setValue:@"KAT_PONT_024" forKey:@"APP_0000487"];
		//교환하기 - 대한항공마일리지
		[_trgEvtMenu setValue:@"KAT_PONT_024" forKey:@"APP_0000155"];
		//교환하기 - 비트코인
		[_trgEvtMenu setValue:@"KAT_PONT_024" forKey:@"APP_0000162"];
		//기부하기 - 기부처 목록
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000166"];
		//조르기 - 받은조르기목록
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000171"];
		//조르기 - 조르기 상세
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000175"];
		//조르기 - 신청
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000176"];
		//함께하기 - n빵
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000179"];
		//함께하기 - 용돈보내기목록
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000184"];
		//함께하기 - 용돈미션(만든미션)
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000187"];
		//함께하기 - 용돈미션(수행미션)
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000190"];
		//함께하기 - 모임통장목록
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000194"];
		//함께하기 - 모임통장만들기 1
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000202"];
		//함께하기 - 모임통장만들기 3
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000203"];
		//함께하기 - 모임통장만들기 2- 모임회비 임력화면
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000204"];
		//함께하기 - 모임통장 홈
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000206"];
		//함께하기 - 모임통장 글남기기
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000218"];
		//함께하기 - 모임통장 일정
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000220"];
		//함께하기 - 커플통장생성 기념일입력
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000228"];
		//함께하기 - 커플통장홈
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000230"];
		//함께하기 - 미션목록
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000245"];
		//함께하기 - 모임통장 회비납부 - 수기입력
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000263"];
		//함께하기 - 모임통장 - 일괄졸르기
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000265"];
		//함께하기 - 모임통장 - 일괄졸르기
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000266"];
		//함께하기 - 모임통장 - 회비납부하기
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000267"];
		//함께하기 - 모임통장 - 월별내역
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000270"];
		//함께하기 - 주소록 - 그룹목록
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000281"];
		//소비매니저 - 설정
		[_trgEvtMenu setValue:@"KAT_CNMN_004" forKey:@"APP_0000324"];
		//소비매니저 - 카드설정
		[_trgEvtMenu setValue:@"KAT_CNMN_022" forKey:@"APP_0000325"];
		//쿠폰 - 쿠폰메인
		[_trgEvtMenu setValue:@"KAT_LIBE_020" forKey:@"APP_0000373"];
        //쿠폰 - 쿠폰혜택
        [_trgEvtMenu setValue:@"KAT_LIBE_020" forKey:@"APP_0000498"];
		//즐기기 - 로또리치
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000383"];
        //Mate생활 - MVP스타서비스
        [_trgEvtMenu setValue:@"KAT_MYPG_003" forKey:@"APP_0000492"];
		//Mate생활 - 건강
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000488"];
		
		////샌드버드 추가
		//조르기 - 보낸조르기목록
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000173"];
		//커플통장목록
		[_trgEvtMenu setValue:@"KAT_LIBE_028" forKey:@"APP_0000222"];
		//가맹점
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000431"];
		//설정
		[_trgEvtMenu setValue:MenuID_SettingHome forKey:@"APP_0000039"];
        //비디오튜토리얼
        [_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"APP_0000496"];
		
        // 이벤트 - APP_0000416 : KAT_LIBE_001
        [_trgEvtMenu setValue:@"KAT_LIBE_001" forKey:@"APP_0000416"];
        // 바코드결제 - APP_0000499 : KAT_PABA_001
        [_trgEvtMenu setValue:MenuID_SimplePayment forKey:@"APP_0000499"];
        // 소비리포트 - APP_0000296 : KAT_CNMN_001
        [_trgEvtMenu setValue:@"KAT_CNMN_001" forKey:@"APP_0000296"];
		
		//AS-IS 1차오픈 화면이동
		//거래내역조회
		[_trgEvtMenu setValue:MenuID_PointreeHistory forKey:@"liivmate_money_list"];
		//거래내역조회
		[_trgEvtMenu setValue:MenuID_PointreeHistory forKey:@"liivmate_money_list_plus"];
		//거래내역조회
		[_trgEvtMenu setValue:MenuID_PointreeHistory forKey:@"liivmate_money_list_minus"];
		//자동충전목록
		[_trgEvtMenu setValue:@"KAT_MYPG_029" forKey:@"liivmate_charge_auto"];
		//충전수단 목록
		[_trgEvtMenu setValue:@"KAT_MYPG_026" forKey:@"liivmate_charge_method"];
		//자동보내기 목록
		[_trgEvtMenu setValue:@"KAT_MYPG_032" forKey:@"liivmate_send_auto"];
		//보낸조르기
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"liivmate_request_send"];
		//받은조르기
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"liivmate_request_receive"];
		//추천인등록
		[_trgEvtMenu setValue:@"KAT_SETT_013" forKey:@"liivmate_regist_introducer"];
		//쿠폰함상세
		[_trgEvtMenu setValue:@"KAT_LIBE_021" forKey:@"liivmate_coupon_detail"];
		//용돈보내기
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"together_pocket_money"];
		//쿠폰바로쓰기
		[_trgEvtMenu setValue:MenuID_DEPRECATED forKey:@"PU_LI_DT"];
		//설정
		[_trgEvtMenu setValue:MenuID_SettingHome forKey:@"setting"];
        
        
        // Ver. 2 통합조회 화면
        [_trgEvtMenu setValue:MenuID_V3_TabMenu_Finance forKey:@"finance"];
	}
}
		
-(void)openMenu:(NSNotification *)noti
{
	[self.delegate openMenu];
}
		
-(void)setGnbType:(GNBType)gnbType
{
	_gnbType = gnbType;
	[[NSNotificationCenter defaultCenter] postNotificationName:GNBTypeChangedNotification object:[NSNumber numberWithInt:(int)gnbType]];
}

-(id)init
{
	self = [super init];
	if(self)
	{
		_appMenuList = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenu:) name:MenuOpenNotification object:nil];
		
		_allMenu = [[NSMutableArray alloc] init];
		//로그인
		[_allMenu addObject:@{K_LOGIN : @YES,
							  K_VIEWID : @[MenuID_Login]}];
        
        //간편결제(모달로 화면이 열리도록 지정)
        [_allMenu addObject:@{K_ClassName : @"Payment.KCLPaymentViewController",
                              K_LOGIN : @YES,
                              K_NaviOption : @(NavigationOptionNavigationModal),
                              K_VIEWID : @[MenuID_SimplePayment,MenuID_SimplePaymentQR,MenuID_V3_SimplePayment]}];
        
        //팝업웹뷰(모달로 화면이 열리도록 지정)
        [_allMenu addObject:@{K_ClassName : @"KCLPopupViewController",
                              K_LOGIN : @YES,
                              K_NaviOption : @(NavigationOptionNavigationModal),
                              K_VIEWID : @[MenuID_V4_SimplePayment]}];
		
		//간편결제-바코드 확대(모달로 화면이 열리도록 지정)
		[_allMenu addObject:@{K_ClassName : @"Payment.KCLBarcodeZoomViewController",
							  K_NaviOption : @(NavigationOptionModal),
							  K_VIEWID : @[MenuID_PaymentBarcodeZoom]}];
		
		//QR코드 스캐너
		[_allMenu addObject:@{K_ClassName : @"Payment.KCLQRScannerViewController",
							  K_VIEWID : @[MenuID_ScannerSend,MenuID_ScannerCancel]}];
		
		//간편결제완료
		[_allMenu addObject:@{K_ClassName : @"Payment.KCLPaymentCompleteViewController",
							  K_LOGIN : @YES,
							  K_VIEWID : @[MenuID_SimplePaymentComplete]}];
		
		//튜토리얼
		[_allMenu addObject:@{K_ClassName : @"ETC.KCLTutorialViewController",
							  K_LOGIN : @NO,
							  K_VIEWID : @[MenuID_Tutorial]}];

		//네이티브 웹뷰컨트롤러
		[_allMenu addObject:@{K_ClassName : @"HybridViewController",
							  K_VIEWID : @[MenuID_WebViewVC]}];
		
		//제휴사이트 - 파라미터로 CID를 넣어줘야하는것들
		[_allMenu addObject:@{K_ClassName : @"KCLAlianceSiteWebViewController",
							  K_VIEWID : @[MenuID_AlianceWeb]}];
        
		//제휴사이트 - 로그인이 필수인 웹뷰
		[_allMenu addObject:@{K_ClassName : @"HybridViewController",
							  K_LOGIN : @YES,
							  K_VIEWID : @[MenuID_LoginWebViewVC]}];
		
		//메인 - QR코드 결제 상세 웹뷰
		[_allMenu addObject:@{K_ClassName : @"WebViewController",
//                              K_LOGIN : @YES,
							  K_MenuHidden : @[@"isAffiliate",@YES],
							  K_VIEWID : @[MenuID_V1_QRCodePaymentDetail]}];
		
		//메인 - QR코드 결제 상세 웹뷰(복합결제)
		[_allMenu addObject:@{K_ClassName : @"WebViewController",
							  K_LOGIN : @YES,
							  K_MenuHidden : @[@"isAffiliate",@YES],
							  K_VIEWID : @[MenuID_V1_QRCodePaymentMixDetail]}];
        
        // 통합조회
        [_allMenu addObject:@{K_ClassName : @"MDFinanceViewController",
                                   K_LOGIN : @YES,
                                   K_VIEWID : @[MenuID_V3_TabMenu_Finance]}];
		
		[self makeTrgEvtMenuDic];
	}
	return self;
}
@end
