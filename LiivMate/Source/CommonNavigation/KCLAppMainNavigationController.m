//
//  KCLAppMainNavigationController.m
//  LiivMate
//
//  Created by KB on 26/03/2020.
//  Copyright © 2020 KBCard. All rights reserved.
//

#import "KCLAppMainNavigationController.h"

@interface KCLAppMainNavigationController () <MenuNavigationDelegate>

@end

@implementation KCLAppMainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    
    // Do any additional setup after loading the view.
    
    self.delegate = (id)self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [[AllMenu menu] setDelegate:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//로그인이 되어있거나 로그인이후 블럭이 호출된다.
- (void)checkLoginBlock:(void (^)(void))block {
    
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
                    // Ver. 3 회원가입(MYD_JO0100)
                    [self navigationWithMenuID:MenuID_V3_MateJoin animated:YES option:(NavigationOptionPush) callBack:nil];
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


#pragma mark - MenuNavigationDelegate

-(void)navigationWithMenuID:(NSString*)viewID option:(NavigationOption)option callBack:(NavigationCallback)callBack
{
    [self navigationWithMenuID:viewID animated:NO option:option callBack:callBack];
}

-(void)navigationWithMenuID:(NSString*)viewID animated:(BOOL)animated option:(NavigationOption)option callBack:(NavigationCallback)callBack
{
    NSDictionary *menuDic = [AllMenu menuForID:viewID];
    BOOL login = [[menuDic objectForKey:K_LOGIN] boolValue];

//    TXLog(@"======화면이동 [%@]======%@========================",viewID,menuDic.jsonStringPrint);
    
    if(menuDic == nil) {
        if (callBack) callBack(nil);
        return;
    }
    
    NSString *url = [menuDic null_objectForKey:K_URL_ADDR];
    if(url.length && [url rangeOfString:Scheme_External].location == 0)
    {//사파리 오픈;
        NSURL *pageUrl = [NSURL URLWithString:[url stringByReplacingCharactersInRange:NSMakeRange(0, Scheme_External.length) withString:@""]];
        if([AppDelegate canOpenURL:pageUrl])
        {
            [[UIApplication sharedApplication] openURL:pageUrl options:@{} completionHandler:nil];
        }
        return;
    }
    
    if([viewID isEqualToString:MenuID_V4_MainPage] == NO){
        if(login && [AppInfo sharedInfo].isLogin == NO)
        {
            if([viewID isEqualToString:MenuID_Login] && [AppInfo sharedInfo].isJoin == YES)
            {
                    [[AppInfo sharedInfo] performLogin:^(BOOL success, NSString *errCD, NSDictionary *result) {
                        if (callBack) callBack(nil);
                        
                        // Y : 위젯에서 로그인 시도 , K : 키보드 호출 , N : 로그인 완료
                        NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.kbcard.kat.liivmate"];
                        NSString *widgetLogin = [userDefault objectForKey:@"WIDGET_LOGIN"];
                        if([widgetLogin isEqualToString:@"K"]){
                            if (success){
                                [AllMenu.delegate navigationWithMenuID:MenuID_V4_MainPage animated:YES option:NavigationOptionSetRoot callBack:^(ViewController *vc) {}];
                            }
                            [userDefault setObject:@"N" forKey:@"WIDGET_LOGIN"];
                        }
                    }];
            }
            else
            {
                [self checkLoginBlock:^(void) {
                    [self navigationWithMenuID:viewID animated:animated option:option callBack:callBack];
                }];
            }
            return;
        }
    }
    
    if(self.presentedViewController !=  nil
       &&  ([self.visibleViewController isKindOfClass:[PwdWrapper pwdClass]] == NO)
       && (option != NavigationOptionModal && option != NavigationOptionModalPush && option != NavigationOptionNavigationModal))
    {
        [self dismissViewControllerAnimated:animated completion:^{
            [self navigationWithMenuID:viewID animated:animated option:option callBack:callBack];
        }];
        return;
    }
    
    //네비게이션 옵션이 지정되어있는경우 항상 해당옵션으로 화면을 연다.(ex 모달, 네비게이션모달)
    if([menuDic valueForKey:K_NaviOption])
        option = [[menuDic valueForKey:K_NaviOption] integerValue];
    
    if(option == NavigationOptionPopRoot)
    {
        if (callBack) callBack(self.viewControllers.firstObject);
        [self popToRootViewControllerAnimated:animated];
        return;
    }
    else if(option == NavigationOptionPopView)
    {
        if(self.viewControllers.count >= 2)
        {
            ViewController *vc = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
            if (callBack) callBack(vc);
        }
        [self popViewControllerAnimated:animated];
        return;
    }
    else if(option == NavigationOptionPopWithViwID)
    {
        ViewController *toVc = nil;
        for(NSInteger i = self.viewControllers.count-1 ; i >= 0 ; i--)
        {
            ViewController *vc = [self.viewControllers objectAtIndex:i];
            if([vc.viewID isEqualToString:viewID])
            {
                toVc = vc;
                break;
            }
        }
        
        if(toVc)
        {
            if (callBack) callBack(toVc);
            [self popToViewController:toVc animated:animated];
        }
        else
        {
            [self goMainViewControllerAnimated:animated];
        }
        return;
    }
    
    ViewController *vc = nil;
    if([viewID isEqualToString:MenuID_V4_MainPage])
    {
        vc = self.mainViewController;
        [self goMainViewControllerAnimated:animated];
        return;
    }
    else if([viewID isEqualToString:MenuID_V3_TabMenu_Finance]) { // 윗제에서 통합조회 선택시 탭에 대한 선택도 넘겨 줌

        [[AllMenu delegate] navigationWithMenuID:MenuID_V3_TabMenu_Finance
                                        animated:YES
                                          option:NavigationOptionPush
                                        callBack:nil];
        
//        [self.selectedTabbarController.webView webViewLoadRequest:[NSURLRequest requestWithURL:url]];
    }
    else
    {
        vc = [AllMenu controllerForMenu:menuDic];
        if([vc respondsToSelector:@selector(setViewID:)])
            vc.viewID = viewID;
    }
    
    if(vc)
    {
        if([vc respondsToSelector:@selector(setMenuItem:)])
            vc.menuItem = menuDic;
        
        if([vc respondsToSelector:@selector(setFirstOpenUrl:)] && url.length)
            ((WebViewController *)vc).firstOpenUrl = url;
        
        NSString *title = [menuDic null_valueForKey:K_MENU_NAME];
        if(title)
        {
            vc.title = title;
        }
        
        if (callBack) callBack(vc);
        
        //사전처리 메서드가 있으면 호출, 최초 한번만 호출하기위하여 현재 화면에 보여지는지 체크(재활용시 호출하지 않기 위해서)
        if([vc respondsToSelector:@selector(initPreprocessingCallback:)] && vc.nextResponder == nil)
        {
            [vc initPreprocessingCallback:^(BOOL success) {
                if(success == NO) return;
                [self setViewController:vc option:option animated:animated];
            }];
        }
        else
        {
            [self setViewController:vc option:option animated:animated];
        }
    }
    else
    {
        if (callBack) callBack(nil);
    }
}

-(void)setViewController:(ViewController*)vc option:(NavigationOption)option animated:(BOOL)animated
{
    switch (option)
    {
        case NavigationOptionSetRoot:
            [self popToRootViewControllerAnimated:YES];
            break;
        case NavigationOptionPopRootAndPush:
        {
            if(vc){
                [self setViewControllers:[NSArray arrayWithObjects:[APP_DELEGATE mainViewController], vc, nil] animated:animated];
            }else{
                [self setViewControllers:[NSArray arrayWithObjects:[APP_DELEGATE mainViewController], nil] animated:animated];
            }
        }
            break;
        case NavigationOptionPush:
            [self pushViewController:vc animated:YES];
            break;
        case NavigationOptionNoneHistoryPush:
        {
            /**
                앱 재설치 후 서비스 둘러 보기에서 다음 버튼으로 나가지 않아 일단 원복 주석 처리
             */
            // 하이브리드 액션 openNewPage시 closeYn시 옵션처리
//            if([MDMainTabbarViewController sharedInstance].currentNavigationController){

                NSMutableArray *array = [NSMutableArray arrayWithArray:self.viewControllers];
                if(array.count > 1)
                    [array removeLastObject];
                [array addObject:vc];

                [self setViewControllers:array animated:animated];
//            }
//            else{
//                [self.navigationController pushViewController:vc animated:YES];
//
//                NSMutableArray *array = [NSMutableArray arrayWithArray:[MDMainTabbarViewController sharedInstance].currentNavigationController.viewControllers];
//                if(array.count > 1)
//                    [array removeLastObject];
//                [array addObject:vc];
//
//                [[MDMainTabbarViewController sharedInstance].currentNavigationController setViewControllers:array animated:animated];
//            }
        }
            break;
        case NavigationOptionNavigationModal:
        {
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.visibleViewController presentViewController:nvc animated:animated completion:^{
            }];
        }
            break;
        case NavigationOptionModalPush:
            [self.visibleViewController.navigationController pushViewController:vc animated:animated];
            break;
        case NavigationOptionModal:
            [self.visibleViewController presentViewController:vc animated:animated completion:^{
            }];
            break;
            
        default:
            break;
    }
}

- (void)goMainViewControllerAnimated:(BOOL)animated {
    
    if (self.viewControllers.count > 1) {
        // 메인화면 리로드 위해 설정
//        [APP_DELEGATE mainViewController].menuID_main = MenuID_V4_MainPage;
        [self popToRootViewControllerAnimated:animated];
    }
    else {
        [[APP_DELEGATE mainViewController] goBasePage];
    }
}

//샌드버드/하이브리드에서 페이지이동
-(void)sendBirdDetailPage:(NSString*)page callBack:(NavigationCallback)callBack
{
    //함수 네이밍이 모호하여 명시적인 역할명으로 변경 puahPageUrl : url 및 내부pageID 을 받아 네비게이션컨트롤러에서 페이지를 푸시하거나 외부 사파리앱으로 토스 한다.
    [self pushPageUrl:page callBack:callBack];
}

-(void)pushPageUrl:(NSString*)page callBack:(NavigationCallback)callBack{
    TXLog(@"page => %@",page);
    
    page = page.trim;
    
    BOOL isInternal = ([page rangeOfString:Scheme_Internal].location == 0);
    
    if ([page hasPrefix:Scheme_Main@"://"]) {
//        if([self.visibleViewController presentingViewController]) {
//            [self.visibleViewController dismissViewControllerAnimated:YES completion:nil];
//        }
        [self popToRootViewControllerAnimated:YES];
//        [[MDMainTabbarViewController sharedInstance] goMainViewController];
        return;
    }
    
    //사파리 오픈;
    if([page rangeOfString:Scheme_External].location == 0)
    {
        NSURL *pageUrl = [NSURL URLWithString:[page stringByReplacingCharactersInRange:NSMakeRange(0, Scheme_External.length) withString:@""]];
        
        if([AppDelegate canOpenURL:pageUrl])
        {
            [[UIApplication sharedApplication] openURL:pageUrl options:@{} completionHandler:nil];
        }
        return;
    }
    
    NSString *viewID = [self replacePageStringToViewID:page];
    if([viewID isEqualToString:MenuID_DEPRECATED])
    {
        [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"서비스가 종료된 화면입니다." dismisTitle:AlertConfirm];
        return;
    }
    
    if(viewID == nil)
    {
        // LiivMate channel 쿠폰ID 처리를 위해...
        if([page rangeOfString:@"http"].location == 0) // URL
            ; // do nothing
        else if([page rangeOfString:@"APP_"].location == 0 || [page rangeOfString:@"KAT_"].location == 0 || [page rangeOfString:@"MYD_"].location == 0 || [page rangeOfString:@"MYD4_"].location == 0) // APP id // Ver. 3 viewID 추가 (MYD_)
            ; // do nothing
        else { // coupon id
            // 쿠폰 아이디가 있으면 (숫자로된 스트링일경우)
            if( page != nil && [page length] > 0 && [page isEqualToString:page.getDecimalString]) {
                // 쿠폰 상세화면으로 이동 시킴. ( required : initWithID 함수 )
//                CouponDetailVC *vc = [[CouponDetailVC alloc] initWithID:page];
//                [self pushViewController:vc animated:YES];
                
                viewID = @"KAT_LIBE_021";
                NSDictionary *menu = [AllMenu menuForID:viewID];
                page = [NSString stringWithFormat:@"%@?cponId=%@",[menu objectForKey:@"urlAddr"],page];
            }
        }
        
        if(viewID == nil)
        {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"페이지 이동에 실패하였습니다." dismisTitle:AlertConfirm];
            return;
        }
    }

    
    //파람 파싱
//    NSDictionary *params = [EtcUtil parseUrl:page];
//    NSString *pageTitle = [params objectForKey:@"setInternalNavigationTitle"];
    
    NSString *pageTitle = @"";
    NSArray *titleArr = [page componentsSeparatedByString:@"?setInternalNavigationTitle="];
    if(titleArr.count > 1){
        pageTitle = [[titleArr objectAtIndex:1] stringByUrlDecoding];
    }
    
    page = [self replaceInternalSchemeToWebPageString:page];
    
    // internal로 들어올시 visibleViewcontroller의 네비게이션 뷰컨트롤러에 push할수있도록 처리
    [self navigationWithMenuID:viewID
                      animated:YES
                        option:isInternal ? NavigationOptionModalPush :NavigationOptionPush
                      callBack:^(ViewController *vc) {
                          if([vc isKindOfClass:[WebViewController class]])
                          {
//                              if([page rangeOfString:@"http"].location == 0)
                              if([page hasPrefix:@"http"]){
                                  ((WebViewController*)vc).firstOpenUrl = page;
                                  if(pageTitle.length > 0){
//                                      [MDMainTabbarViewController sharedInstance].internalNavigationTitleString = pageTitle;
                                      ((WebViewController*)vc).internalNavigationTitleString = pageTitle;
                                  }
                              }
                          }
                          if(callBack)
                              callBack(vc);
                      }];
}

-(NSString*)replacePageStringToViewID:(NSString*)page{
    
    if([page hasPrefix:Scheme_Internal])
        page = [page stringByReplacingCharactersInRange:NSMakeRange(0, Scheme_Internal.length) withString:@""];
    
    //리브메이트 1.0으로 들어올 경우 2.0경로로 바꿔주는 코드인듯.
    if(page.length && [page hasPrefix:@"http"])
        page = [page stringByReplacingOccurrencesOfString:@"/katsv/liivmate/" withString:@"/katsv2/liivmate/"];
    
    NSString *pageString = page;
    if( ![pageString length] )
    {
        return nil;
    }
    
    if([pageString rangeOfString:@"http"].location == 0 || [pageString rangeOfString:Scheme_Internal@"http"].location == 0)
    {//웹페이지 링크
        if([pageString rangeOfString:Scheme_Internal@"http"].location == 0)
            pageString = [pageString stringByReplacingCharactersInRange:NSMakeRange(0, Scheme_Internal.length) withString:@""];
        NSString *menuId = [AllMenu menuIdForUrl:pageString];
        if(menuId.length)
        {
            return menuId;
        }
        //메뉴아이디가 없으면 일반 웹뷰컨트롤러 페이지 리턴
        return MenuID_WebViewVC;
    }
    else
    {
        //트리거 이벤트 ID에서 메뉴ID를 찾는다.
        NSString *viewID = [AllMenu trgPageIdforViewId:pageString];
        if(viewID == nil)
        {
            NSDictionary *menu = [AllMenu menuForID:pageString];
            if(menu)//페이지 스트링이 메뉴ID였을경우.
                viewID = pageString;
            
            menu = [AllMenu menuForClass:pageString];
            if(menu)//페이지스트링이 등록된 class명일경우
                viewID = [[menu objectForKey:K_VIEWID] firstObject];
        }
        return viewID;
    }
}

-(NSString*)replaceInternalSchemeToWebPageString:(NSString*)page{
    
    if([page hasPrefix:Scheme_Internal])
        page = [page stringByReplacingCharactersInRange:NSMakeRange(0, Scheme_Internal.length) withString:@""];
    
    //리브메이트 1.0으로 들어올 경우 2.0경로로 바꿔주는 코드인듯.
    if(page.length && [page hasPrefix:@"http"])
        page = [page stringByReplacingOccurrencesOfString:@"/katsv/liivmate/" withString:@"/katsv2/liivmate/"];
    
    return page;
}


@end
