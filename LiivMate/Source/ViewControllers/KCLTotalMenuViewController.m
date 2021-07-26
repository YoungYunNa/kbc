//
//  KCLTotalMenuViewController.m
//  LiivMate
//
//  Created by KB on 2021/05/14.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLTotalMenuViewController.h"
#import "KCLPopupViewController.h"
#import "KCLSearchViewController.h"

#define GUIDE_RECENT   @"리브메이트 메뉴를 둘러보세요"
#define GUIDE_BOOKMARK @"즐겨 찾는 메뉴를 설정해 보세요"

#define RECENT_MENU_ARRAY   @"RECENT_MENU_ARRAY"
#define BOOKMARK_MENU_ARRAY @"BOOKMARK_MENU_ARRAY"

#define LIST_MENU_NAME @"menuName"
#define LIST_MENU_URL  @"urlAddr"

#define topMenuViewHeightDefault 181 // 상단 메뉴 뷰 높이값
#define topMenuViewHeightEmpty 133 // 상단 메뉴 뷰 높이값 (메뉴 없을 경우)
#define menuCellHeightDefault 44 // 메뉴 셀 높이값
#define menuCellHeaderHeight 57 // 메뉴 셀 Header 높이값
#define menuCellFooterHeight 20 // 메뉴 셀 Footer 높이값

@interface KCLTotalMenuViewController () <UITableViewDelegate, UITableViewDataSource> {
    
    KCLPopupViewController *subViewController;
}

@property (nonatomic,strong) IBOutlet UITableView *menuTableView;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint *menuTableViewHeightConstraint;

@property (nonatomic,strong) NSMutableArray *menuTotalList;     // 전체 메뉴 리스트
@property (nonatomic,strong) NSMutableArray *recentMenuArray;   // 최근방문 메뉴 리스트
@property (nonatomic,strong) NSMutableArray *bookmarkMenuArray; // 즐겨찾기 메뉴 리스트

@end

@implementation KCLTotalMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_recent01Button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_recent02Button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_recent03Button.titleLabel setAdjustsFontSizeToFitWidth:YES];

    [_bookmarkTitle01Button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_bookmarkTitle02Button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_bookmarkTitle03Button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    //메뉴파싱
    self.menuTotalList = [NSMutableArray array];
    
    for (NSDictionary *menuDic in [[AllMenu menu].appMenu objectForKey:ShopMember_pUser4]) {
        NSLog(@"pUser == %@",menuDic);
        
        NSMutableArray *menuCategoryListMenuArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *menuList in [menuDic valueForKey:@"list"]) {
            [menuCategoryListMenuArray addObject:menuList];
        }
        if (menuCategoryListMenuArray.count > 0) {
            [self.menuTotalList addObject:@[[menuDic valueForKey:LIST_MENU_NAME], menuCategoryListMenuArray]];
        }
    }
    
    //쿠폰함 : MenuID_V3_CouponStorage = MYD_MW0500
    //알림함 : MYD_MY0200
    //앱설정 : MYD_AM0500
    //회원가입 : MYD_JO0100
    //자산연동하기 : MYD_ML0100
    
    
#ifdef DEBUG
    BOOL bEtcMenuShow = NO;
    if(bEtcMenuShow){
        NSMutableArray *etcMenuCategoryListMenuArray = [[NSMutableArray alloc] init];
        for(NSDictionary *menuDic in [[AllMenu menu].appMenu objectForKey:@"etc"]){
                NSLog(@"etc == %@",menuDic);
            NSString *menuName = [menuDic valueForKey:@"screnName"];
            [menuDic setValue:menuName forKey:LIST_MENU_NAME];
            [etcMenuCategoryListMenuArray addObject:menuDic];
        }
        [self.menuTotalList addObject:@[@"ETC\n(개발계옵션)", etcMenuCategoryListMenuArray]];
    }
#endif
    
    
    self.recentMenuArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:RECENT_MENU_ARRAY]];
    self.recentMenuArray = [self deleteInvalidRecentData:self.recentMenuArray];
    self.bookmarkMenuArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:BOOKMARK_MENU_ARRAY]];
    self.bookmarkMenuArray = [self deleteInvalidBookmarkData:self.bookmarkMenuArray];
    
    
    subViewController = [[UIStoryboard storyboardWithName:@"KCLMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"KCLPopupViewController"];
    
    [_menuTableView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
    
    [self tabMenuViewInit];
    
    
    // 개발서버로 접속시에만 테스트 메뉴 나오게 설정
    if ([SERVER_URL isEqualToString:SERVER_URL_REAL] == NO && [SERVER_URL hasPrefix:@"https://sm."] == NO) {
        _devButton.hidden = NO;
    } else {
        _devButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AllMenu setStatusBarStyle:YES viewController:self];
    
    [WebViewController sendGa360Native:NO p1:@"더보기" p2:@"ME1101" p3:@"더보기>전체메뉴" campainUrl:nil];
    
    [self updateLeftButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.recentMenuArray) {
        [self updateRecentMenuData:self.recentMenuArray];
    }
    
    if (self.bookmarkMenuArray) {
        [self updateBookmarkMenuUI:self.bookmarkMenuArray];
    }
}

- (void)viewDidLayoutSubviews {
    _menuTableViewHeightConstraint.constant = _menuTableView.contentSize.height + 10 + 10;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [UIView setAnimationsEnabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

// 개발 테스트
- (void)addSubViewDevLabel {
    
    UIButton *devLabel = [self.view viewWithTag:600];
    
    if(devLabel != nil){
        if(devLabel.hidden){
            devLabel.hidden = NO;
            [devLabel setTitle:@"테스트 기능 [보기]" forState:UIControlStateNormal];
            [self showHybridInterfaceList];
        }else{
            devLabel.hidden = YES;
            [devLabel setTitle:@"테스트 기능 [숨기기]" forState:UIControlStateNormal];
            [self showHybridInterfaceList];
        }
        
        return;
    }
    
    UIButton *resetButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [resetButton setTitle:@"재구동 하기" forState:(UIControlStateNormal)];
    [resetButton setBackgroundColor:UIColor.whiteColor];
    resetButton.titleLabel.font = BOLDFONTSIZE(17);
    resetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [resetButton setTitleColor:COLOR_MAIN_PURPLE forState:(UIControlStateNormal)];
    //    [button setAccessibilityElementsHidden:YES];
    [resetButton addTarget:self action:@selector(restartApp) forControlEvents:(UIControlEventTouchUpInside)];
    resetButton.frame = CGRectMake(20, self.view.frame.size.height-240, 150, 40);
    resetButton.tag = 400;
//        resetButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:resetButton];
    
    UIButton *pureAppDataButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [pureAppDataButton setTitle:@"V3퓨어앱데이터" forState:(UIControlStateNormal)];
    [pureAppDataButton setBackgroundColor:UIColor.whiteColor];
    pureAppDataButton.titleLabel.font = BOLDFONTSIZE(17);
    pureAppDataButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [pureAppDataButton setTitleColor:COLOR_MAIN_PURPLE forState:(UIControlStateNormal)];
    //    [button setAccessibilityElementsHidden:YES];
    [pureAppDataButton addTarget:self action:@selector(showPureAppData) forControlEvents:(UIControlEventTouchUpInside)];
    pureAppDataButton.frame = CGRectMake(20, self.view.frame.size.height-280, 150, 40);
    pureAppDataButton.tag = 500;
//        pureAppDataButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pureAppDataButton];
    
    //하이브리드 인터페이스 테스트
    UIButton *pureAppDataButton2 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [pureAppDataButton2 setTitle:@"테스트 기능 [숨기기]" forState:(UIControlStateNormal)];
    pureAppDataButton2.titleLabel.font = BOLDFONTSIZE(19);
    pureAppDataButton2.backgroundColor = [UIColor whiteColor];
    pureAppDataButton2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [pureAppDataButton2 setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];

    //    [button setAccessibilityElementsHidden:YES];
    [pureAppDataButton2 addTarget:self action:@selector(showHybridInterfaceList) forControlEvents:(UIControlEventTouchUpInside)];
    pureAppDataButton2.frame = CGRectMake(20,self.view.frame.size.height- 320, 200, 40);
    pureAppDataButton2.tag = 600;
    [self.view addSubview:pureAppDataButton2];
    
#ifdef DEBUG
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setTitle:@"기능리스트[로그인아웃]" forState:(UIControlStateNormal)];
    [button setBackgroundColor:UIColor.whiteColor];
    button.titleLabel.font = BOLDFONTSIZE(17);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setTitleColor:COLOR_MAIN_PURPLE forState:(UIControlStateNormal)];

    [button addTarget:self action:@selector(openListViewController:) forControlEvents:(UIControlEventTouchUpInside)];
    button.frame = CGRectMake(20, self.view.frame.size.height-200, 200, 40);
    button.tag = 300;
    button.backgroundColor = [UIColor clearColor];
    [self.view addSubview:button];
    button.hidden = YES;
#endif
}

- (void)openListViewController:(UIButton*)sender {
    if([sender tag] == 300) {
        ViewController *vc = [[NSClassFromString(@"V2ListViewController") alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showHybridInterfaceList {
    
    UIButton *btn = (UIButton*)[self.view viewWithTag:600];
    BOOL isHidden = YES;
    
    if ([btn.titleLabel.text containsString:@"[숨기기]"]) {
        [btn setTitle:@"테스트 기능 [보기]" forState:UIControlStateNormal];
        isHidden = YES;
    } else {
        [btn setTitle:@"테스트 기능 [숨기기]" forState:UIControlStateNormal];
        isHidden = NO;
    }
    
    [self.view viewWithTag:300].hidden = isHidden;
    [self.view viewWithTag:400].hidden = isHidden;
    [self.view viewWithTag:500].hidden = isHidden;
}

- (void)restartApp {
    
    AppDelegate * delegate = APP_DELEGATE;
    delegate.server = nil;
    [UserDefaults sharedDefaults].isFirstRun = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:StartLiivMateNotification object:nil];
}

- (void)showPureAppData {
    
    CGRect mainFrame = self.view.frame;
    
    mainFrame.origin.y = 70;
    mainFrame.size.height = mainFrame.size.height-70;
    
    UIView *view = [[UIView alloc] initWithFrame:mainFrame];
    view.backgroundColor = [UIColor grayColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
    titleLabel.text = @"V3퓨어앱 데이터";
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(mainFrame.size.width-50, 0, 50, 50);
    [closeButton setTitle:@"닫기" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(didTouchPureAppDataClose:) forControlEvents:UIControlEventTouchUpInside];
    
    mainFrame.origin.y = 50;
    mainFrame.size.height = mainFrame.size.height-50;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:mainFrame];
    textView.text = [UserDefaults sharedDefaults].recentPureAppDataDecryptString;
    
    [view addSubview:titleLabel];
    [view addSubview:closeButton];
    [view addSubview:textView];
    
    [self.view addSubview:view];
}

- (void)didTouchPureAppDataClose:(UIButton*)btn {
    [[btn superview] removeFromSuperview];
}

/**
@var updateLeftButtons
@brief 로그인/자산연동, 회원가입/마이포켓 버튼 설정
@param
@return
*/
- (void)updateLeftButtons {
    
    if ([AppInfo sharedInfo].isLogin) {
        [_leftFirstButton setTitle:@"자산연동" forState:UIControlStateNormal];
        [_leftSecondButton setTitle:@"마이포켓" forState:UIControlStateNormal];
    }
    else {
        [_leftFirstButton setTitle:@"로그인" forState:UIControlStateNormal];
        [_leftSecondButton setTitle:@"회원가입" forState:UIControlStateNormal];
    }
}

/**
@var tabMenuViewInit
@brief 최근방문/즐겨찾기 메뉴 탭 초기화
@param
@return
*/
- (void)tabMenuViewInit {
    
    [_tabRecentButton setTitleColor:COLOR_MAIN_GRAY forState:UIControlStateNormal];
    [_tabRecentButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_tabBookmarkButton setTitleColor:COLOR_MAIN_GRAY forState:UIControlStateNormal];
    [_tabBookmarkButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    _tabRecentUnderline.hidden = YES;
    _tabBookmarkUnderline.hidden = YES;
    
    _topMenuViewHeight.constant = 0;
    
    _topRecentView.hidden = YES;
    _topBookmarkView.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/**
 @brief 메뉴가 사라지거나 해서 유효하지 않은 최근 방문기록을 삭제한다
 */
- (NSMutableArray *)deleteInvalidRecentData:(NSMutableArray *)recnetMenuArray {
    
    NSMutableArray *compareMenu = [NSMutableArray array];
    for (NSArray *arr in self.menuTotalList) {
        if (arr.count > 1) {
            [compareMenu addObjectsFromArray:arr[1]];
        }
    }
     
    NSMutableArray *deleteRecentArray = [NSMutableArray array];

    for (NSDictionary *recentMenu in recnetMenuArray) {
      NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"%K MATCHES[c] %@",K_VIEWID, recentMenu[K_VIEWID]];
      NSDictionary *menu = [[compareMenu filteredArrayUsingPredicate:findPredicate] firstObject];
        
        if (menu == nil) {
            [deleteRecentArray addObject:recentMenu];
        }
    }
    
    [recnetMenuArray removeObjectsInArray:deleteRecentArray];
    
    [[NSUserDefaults standardUserDefaults] setObject:recnetMenuArray forKey:RECENT_MENU_ARRAY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return recnetMenuArray;
}

/**
 @brief 메뉴가 사라지거나 해서 유효하지 않은 즐겨찾기 기록을 삭제한다
 */
- (NSMutableArray *)deleteInvalidBookmarkData:(NSMutableArray *)bookmarkMenuArray {
    
    NSMutableArray *compareMenu = [NSMutableArray array];
    for (NSArray *arr in self.menuTotalList) {
        if (arr.count > 1) {
            [compareMenu addObjectsFromArray:arr[1]];
        }
    }
     
    NSMutableArray *deleteRecentArray = [NSMutableArray array];

    for (NSDictionary *bookmarkMenu in bookmarkMenuArray) {
      NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"%K MATCHES[c] %@",K_VIEWID, bookmarkMenu[K_VIEWID]];
      NSDictionary *menu = [[compareMenu filteredArrayUsingPredicate:findPredicate] firstObject];
        
        if (menu == nil) {
            [deleteRecentArray addObject:bookmarkMenu];
        }
    }
    
    [bookmarkMenuArray removeObjectsInArray:deleteRecentArray];
    
    [[NSUserDefaults standardUserDefaults] setObject:bookmarkMenuArray forKey:BOOKMARK_MENU_ARRAY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return bookmarkMenuArray;
}

/**
@var updateRecentMenuData
@brief 최근방문 메뉴 화면 업데이트
@param 최근에 방문한 메뉴 리스트
@return
*/
- (void)updateRecentMenuData:(NSMutableArray *)menuArray {
    
    [_recent01Button setTitle:@"" forState:UIControlStateNormal];
    [_recent02Button setTitle:@"" forState:UIControlStateNormal];
    [_recent03Button setTitle:@"" forState:UIControlStateNormal];
    _recent01Button.hidden = YES;
    _recent02Button.hidden = YES;
    _recent03Button.hidden = YES;
    
    _recentBookmark01Button.hidden = YES;
    _recentBookmark02Button.hidden = YES;
    _recentBookmark03Button.hidden = YES;
    
    _tabRecentGuideLabel.hidden = NO;
    
    if (menuArray.count > 0) {
        NSDictionary *menuDic = [menuArray objectAtIndex:0];
        [_recent01Button setTitle:[menuDic valueForKey:K_MENU_NAME] forState:UIControlStateNormal];
        _recent01Button.hidden = NO;
        _recentBookmark01Button.hidden = NO;
        _tabRecentGuideLabel.hidden = YES;
    }
    if (menuArray.count > 1) {
        NSDictionary *menuDic = [menuArray objectAtIndex:1];
        [_recent02Button setTitle:[menuDic valueForKey:K_MENU_NAME] forState:UIControlStateNormal];
        _recent02Button.hidden = NO;
        _recentBookmark02Button.hidden = NO;
    }
    if (menuArray.count > 2) {
        NSDictionary *menuDic = [menuArray objectAtIndex:2];
        [_recent03Button setTitle:[menuDic valueForKey:K_MENU_NAME] forState:UIControlStateNormal];
        _recent03Button.hidden = NO;
        _recentBookmark03Button.hidden = NO;
    }
    
    [self updateRecentMenuBookmarkButtons];
}

/**
@var updateRecentMenuBookmarkButtons
@brief 최근방문 메뉴의 즐겨찾기 버튼 업데이트
@param
@return
*/
- (void)updateRecentMenuBookmarkButtons {
    
    [_recentBookmark01Button setAccessibilityLabel:@"즐겨찾기"];
    [_recentBookmark02Button setAccessibilityLabel:@"즐겨찾기"];
    [_recentBookmark03Button setAccessibilityLabel:@"즐겨찾기"];
    
    if (([_recent01Button.currentTitle isEqualToString:_bookmarkTitle01Button.currentTitle] ||
         [_recent01Button.currentTitle isEqualToString:_bookmarkTitle02Button.currentTitle] ||
         [_recent01Button.currentTitle isEqualToString:_bookmarkTitle03Button.currentTitle]) && ![_recent01Button.currentTitle isEqualToString:@""]) {
        _recentBookmark01Button.selected = YES;
        [_recentBookmark01Button setAccessibilityTraits:UIAccessibilityTraitButton|UIAccessibilityTraitSelected];
    } else {
        _recentBookmark01Button.selected = NO;
        [_recentBookmark01Button setAccessibilityTraits:UIAccessibilityTraitButton];
    }
    
    if (([_recent02Button.currentTitle isEqualToString:_bookmarkTitle01Button.currentTitle] ||
         [_recent02Button.currentTitle isEqualToString:_bookmarkTitle02Button.currentTitle] ||
         [_recent02Button.currentTitle isEqualToString:_bookmarkTitle03Button.currentTitle]) && ![_recent02Button.currentTitle isEqualToString:@""]) {
        _recentBookmark02Button.selected = YES;
        [_recentBookmark02Button setAccessibilityTraits:UIAccessibilityTraitButton|UIAccessibilityTraitSelected];
    } else {
        _recentBookmark02Button.selected = NO;
        [_recentBookmark02Button setAccessibilityTraits:UIAccessibilityTraitButton];
    }
    
    if (([_recent03Button.currentTitle isEqualToString:_bookmarkTitle01Button.currentTitle] ||
         [_recent03Button.currentTitle isEqualToString:_bookmarkTitle02Button.currentTitle] ||
         [_recent03Button.currentTitle isEqualToString:_bookmarkTitle03Button.currentTitle]) && ![_recent03Button.currentTitle isEqualToString:@""]) {
        _recentBookmark03Button.selected = YES;
        [_recentBookmark03Button setAccessibilityTraits:UIAccessibilityTraitButton|UIAccessibilityTraitSelected];
    } else {
        _recentBookmark03Button.selected = NO;
        [_recentBookmark03Button setAccessibilityTraits:UIAccessibilityTraitButton];
    }
}

/**
@var updateBookmarkMenuUI
@brief 즐겨찾기 메뉴 화면 업데이트
@param 즐겨찾기한 메뉴 리스트
@return
*/
- (void)updateBookmarkMenuUI:(NSMutableArray *)menuArray {
    
    [UIView setAnimationsEnabled:NO];
    
    _bookmark01Button.hidden = YES;
    _bookmark02Button.hidden = YES;
    _bookmark03Button.hidden = YES;
    
    _tabBookmarkGuideLabel.hidden = NO;
    
    if (menuArray.count > 0) {
        NSDictionary *menuDic = [menuArray objectAtIndex:0];
        [_bookmarkTitle01Button setTitle:[menuDic valueForKey:LIST_MENU_NAME] forState:UIControlStateNormal];
        _bookmarkTitle01Button.hidden = NO;
        _bookmark01Button.hidden = NO;
        _tabBookmarkGuideLabel.hidden = YES;
    } else {
        [_bookmarkTitle01Button setTitle:@"" forState:UIControlStateNormal];
        _bookmarkTitle01Button.hidden = YES;
    }
    
    if (menuArray.count > 1) {
        NSDictionary *menuDic = [menuArray objectAtIndex:1];
        [_bookmarkTitle02Button setTitle:[menuDic valueForKey:LIST_MENU_NAME] forState:UIControlStateNormal];
        _bookmarkTitle02Button.hidden = NO;
        _bookmark02Button.hidden = NO;
    } else {
        [_bookmarkTitle02Button setTitle:@"" forState:UIControlStateNormal];
        _bookmarkTitle02Button.hidden = YES;
    }
    
    if (menuArray.count > 2) {
        NSDictionary *menuDic = [menuArray objectAtIndex:2];
        [_bookmarkTitle03Button setTitle:[menuDic valueForKey:LIST_MENU_NAME] forState:UIControlStateNormal];
        _bookmarkTitle03Button.hidden = NO;
        _bookmark03Button.hidden = NO;
    } else {
        [_bookmarkTitle03Button setTitle:@"" forState:UIControlStateNormal];
        _bookmarkTitle03Button.hidden = YES;
    }
    
    [self updateRecentMenuBookmarkButtons];
}

/**
@var updateBookmarkMenuArray
@brief 즐겨찾기 메뉴 데이터 업데이트
@param 즐겨찾기한 메뉴 인덱스
@return
*/
- (void)updateBookmarkMenuArray:(UIButton *)sender {
    
    NSDictionary *selectedMenuDic = [self getMenuDictionaryWithTag:sender.tag];
    
    NSString *menuName = [selectedMenuDic valueForKey:K_MENU_NAME];
    NSString *urlString = [selectedMenuDic valueForKey:K_URL_ADDR];
    NSString *viewId = [selectedMenuDic valueForKey:K_VIEWID];
    NSString *loginYn = [selectedMenuDic valueForKey:K_LOGIN];
    
    for (NSDictionary *menuDic in self.bookmarkMenuArray) {
        BOOL isAlreadyExist = [[menuDic valueForKey:LIST_MENU_NAME] isEqualToString:menuName];
        if (isAlreadyExist) {
            [self.bookmarkMenuArray removeObject:menuDic];
            
            [self updateBookmarkMenuUI:self.bookmarkMenuArray];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.bookmarkMenuArray forKey:BOOKMARK_MENU_ARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSIndexPath *deleteIndexPath = [self getMenuIndexPathWithTag:sender.tag];
            [_menuTableView reloadRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            sender.selected = !sender.selected;
            
            [self updateRecentMenuBookmarkButtons];
            
            return;
        }
    }
    
    if (self.bookmarkMenuArray.count > 2) {
        showSplashMessage(@"즐겨찾기는 3개까지 설정 가능합니다.", YES, NO);
        return;
    }
    
    [self.bookmarkMenuArray addObject:@{LIST_MENU_NAME:menuName,
                                         LIST_MENU_URL:urlString,
                                         K_VIEWID:viewId,
                                         K_LOGIN:loginYn
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.bookmarkMenuArray forKey:BOOKMARK_MENU_ARRAY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateBookmarkMenuUI:self.bookmarkMenuArray];
    
    sender.selected = !sender.selected;
}

/**
@var getMenuDictionary
@brief 인덱스에 따른 메뉴 가져오기
@param 메뉴 인덱스
@return 메뉴 데이터
*/
- (NSDictionary *)getMenuDictionaryWithTag:(NSInteger)menuTag {
    
    NSInteger menuIdx = 0;
    for (NSArray *array in self.menuTotalList) {
        for (NSDictionary *menuDic in array.lastObject) {
            if (menuIdx == menuTag) {
                return menuDic;
            }
            menuIdx++;
        }
    }
    return nil;
}

/**
@var getMenuIndexPathWithTag
@brief 즐겨찾기 태그값으로 메뉴의 IndexPath 가져오기
@param 메뉴 인덱스
@return 메뉴의 IndexPath
*/
- (NSIndexPath *)getMenuIndexPathWithTag:(NSInteger)menuTag {
    
    NSInteger sectionIdx = 0;
    NSInteger rowIdx = 0;
    for (NSArray *array in self.menuTotalList) {
        for (NSDictionary *menuDic __unused in array.lastObject) {
            if (menuTag == 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
                return indexPath;
            }
            rowIdx++;
            menuTag--;
        }
        sectionIdx++;
        rowIdx = 0;
    }
    return nil;
}

/**
@var getMenuIndexPathWithName
@brief 즐겨찾기 메뉴이름으로 메뉴의 IndexPath 가져오기
@param 메뉴 이름
@return 메뉴의 IndexPath
*/
- (NSIndexPath *)getMenuIndexPathWithName:(NSString *)menuName {
    
    NSInteger sectionIdx = 0;
    NSInteger rowIdx = 0;
    for (NSArray *array in self.menuTotalList) {
        for (NSDictionary *menuDic in array.lastObject) {
            if ([[menuDic valueForKey:LIST_MENU_NAME] isEqualToString:menuName]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
                return indexPath;
            }
            rowIdx++;
        }
        sectionIdx++;
        rowIdx = 0;
    }
    return nil;
}


#pragma mark - Button Event

// 로그인 / 자산연동
- (IBAction)didTouchLeftFirstButton:(id)sender {
    
    if ([AppInfo sharedInfo].isLogin) {
        [[AllMenu delegate] navigationWithMenuID:MenuID_V4_ASSET_LINKAGE
                                        animated:YES
                                          option:NavigationOptionPush
                                        callBack:nil];
    }
    else {
        [[AppInfo sharedInfo] performLogin:^(BOOL success, NSString *errCD, NSDictionary* result) {
        }];
    }
}

// 회원가입 / 마이포켓
- (IBAction)didTouchLeftSecondButton:(id)sender {
    
    if ([AppInfo sharedInfo].isLogin) {
        [[AllMenu delegate] navigationWithMenuID:MenuID_V4_SimplePayment
                                        animated:YES
                                          option:NavigationOptionPush
                                        callBack:nil];
    }
    else {
        [[AllMenu delegate] navigationWithMenuID:MenuID_V3_MateJoin
                                        animated:YES
                                          option:NavigationOptionPush
                                        callBack:nil];
    }
}

// 알림
- (IBAction)didTouchNoticeButton:(id)sender {
    
    [[AllMenu delegate] navigationWithMenuID:MenuID_V3_Notification option:NavigationOptionPush callBack:^(ViewController *vc){
    }];
}

// 앱설정
- (IBAction)didTouchSettingButton:(id)sender {
    
    [[AllMenu delegate] navigationWithMenuID:MenuID_V3_AppConfiguration option:NavigationOptionPush callBack:^(ViewController *vc){
    }];
}

// 전체메뉴 화면 닫기
- (IBAction)didTouchClose:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 개발 테스트
- (IBAction)didTouchDevButton:(UIButton *)button {
    
    [self addSubViewDevLabel];
}

// 메뉴 검색
- (IBAction)didTouchSearchButton:(UIButton *)button {
    
    KCLSearchViewController *searchVC = [[UIStoryboard storyboardWithName:@"KCLMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"KCLSearchViewController"];
    searchVC.menuTotalList = self.menuTotalList;
    [self.navigationController pushViewController:searchVC animated:NO];
}

// 최근방문
- (IBAction)didTouchRecentTab:(id)sender {
    
    [_tabRecentButton setTitleColor:COLOR_MAIN_PURPLE forState:UIControlStateNormal];
    [_tabRecentButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [_tabBookmarkButton setTitleColor:COLOR_MAIN_GRAY forState:UIControlStateNormal];
    [_tabBookmarkButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    _tabRecentUnderline.hidden = NO;
    _tabBookmarkUnderline.hidden = YES;
    
//    if ([_recent01Button.currentTitle isEqualToString:@""] &&
//        [_recent02Button.currentTitle isEqualToString:@""] &&
//        [_recent03Button.currentTitle isEqualToString:@""]) {
//        _topMenuViewHeight.constant = topMenuViewHeightEmpty;
//    } else {
        _topMenuViewHeight.constant = topMenuViewHeightDefault;
//    }
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    _topRecentView.hidden = NO;
    _topBookmarkView.hidden = YES;
}

// 즐겨찾기
- (IBAction)didTouchBookmarkTab:(id)sender {

    [_tabRecentButton setTitleColor:COLOR_MAIN_GRAY forState:UIControlStateNormal];
    [_tabRecentButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_tabBookmarkButton setTitleColor:COLOR_MAIN_PURPLE forState:UIControlStateNormal];
    [_tabBookmarkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    _tabRecentUnderline.hidden = YES;
    _tabBookmarkUnderline.hidden = NO;
    
//    if ([_bookmarkTitle01Button.currentTitle isEqualToString:@""] &&
//        [_bookmarkTitle02Button.currentTitle isEqualToString:@""] &&
//        [_bookmarkTitle03Button.currentTitle isEqualToString:@""]) {
//        _topMenuViewHeight.constant = topMenuViewHeightEmpty;
//    } else {
        _topMenuViewHeight.constant = topMenuViewHeightDefault;
//    }
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    _topRecentView.hidden = YES;
    _topBookmarkView.hidden = NO;
}

/**
@var setTabButton
@brief 주요메뉴/최근방문/즐겨찾기 탭 설정 및 밑줄 애니메이션
@param 주요메뉴/최근방문/즐겨찾기 버튼 순서
@return

- (void)setTabButton:(int)order {
    
    _tabRecentButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _tabBookmarkButton.titleLabel.font = [UIFont systemFontOfSize:15];

    if (order == 1) { // 주요메뉴
        _tabButtonUnderlineViewLeading01.priority = 750;
        _tabButtonUnderlineViewLeading02.priority = 250;
        _tabButtonUnderlineViewLeading03.priority = 250;
    }
    else if (order == 2) { // 최근방문
        _tabRecentButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _tabButtonUnderlineViewLeading01.priority = 250;
        _tabButtonUnderlineViewLeading02.priority = 750;
        _tabButtonUnderlineViewLeading03.priority = 250;
    }
    else if (order == 3) { // 즐겨찾기
        _tabBookmarkButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _tabButtonUnderlineViewLeading01.priority = 250;
        _tabButtonUnderlineViewLeading02.priority = 250;
        _tabButtonUnderlineViewLeading03.priority = 750;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}
*/

// 최근방문/즐겨찾기 메뉴 접기
- (IBAction)didTouchSubMenuFold:(UIButton *)sender {
    
    [self tabMenuViewInit];
    
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}

// 주요메뉴 첫번째 메뉴 (자산)
- (IBAction)didTouchMainMenu01:(id)sender {
    
    [APP_DELEGATE mainViewController].menuID_main = MenuID_V4_ASSETLINKAGE_MainPage;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 주요메뉴 두번째 메뉴 (소비)
- (IBAction)didTouchMainMenu02:(id)sender {
    
    [APP_DELEGATE mainViewController].menuID_main = MenuID_V4_PayMngCnsmRpt;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 주요메뉴 세번째 메뉴 (톡톡)
- (IBAction)didTouchMainMenu03:(id)sender {
    
    [APP_DELEGATE mainViewController].menuID_main = MenuID_V4_TocToc;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 주요메뉴 네번째 메뉴 (오픈뱅킹)
- (IBAction)didTouchMainMenu04:(id)sender {
    
    [[AllMenu delegate] navigationWithMenuID:MenuID_V4_OpenBanking
                                    animated:YES
                                      option:NavigationOptionPush
                                    callBack:nil];
}

// 최근방문 첫번째 메뉴
- (IBAction)didTouchRecent01:(id)sender {
    
    [self didTouchRecent:_recent01Button.currentTitle];
}

// 최근방문 두번째 메뉴
- (IBAction)didTouchRecent02:(id)sender {
    
    [self didTouchRecent:_recent02Button.currentTitle];
}

// 최근방문 세번째 메뉴
- (IBAction)didTouchRecent03:(id)sender {
    
    [self didTouchRecent:_recent03Button.currentTitle];
}

/**
@var didTouchRecent
@brief 최근방문 메뉴 클릭시 처리
@param 최근방문 메뉴의 타이틀
@return
*/
- (void)didTouchRecent:(NSString *)recentButtonTitle {
    
    if ([recentButtonTitle isEqualToString:@""]) {
        return;
    }
    
    NSInteger menuIdx = 0;
    BOOL isBreak = NO;
    
    for (NSArray *array in self.menuTotalList) {
        for (NSDictionary *menuDic in array.lastObject) {
            if ([[menuDic valueForKey:LIST_MENU_NAME] isEqualToString:recentButtonTitle]) {
                isBreak = YES;
                break;
            }
            menuIdx++;
        }
        if (isBreak) {
            break;
        }
    }
    
    NSIndexPath *indexPath = [self getMenuIndexPathWithTag:menuIdx];
    
    NSDictionary *selectedMenuDic = [self getMenuDictionary:indexPath];
    [[AllMenu delegate] sendBirdDetailPage:selectedMenuDic[K_VIEWID] callBack:^(ViewController *vc) {}];
    
    [self updateRecentMenuArray:selectedMenuDic];
    
    NSArray *menuCategoryArray = [self.menuTotalList objectAtIndex:indexPath.section];
    [WebViewController sendGa360Native:YES p1:@"전체메뉴" p2:menuCategoryArray[0] p3:selectedMenuDic[@"menuName"] campainUrl:nil];
}
    

// 최근방문 첫번째 메뉴 즐겨찾기
- (IBAction)didTouchRecentBookmark01:(id)sender {
    
    [self didTouchRecentBookmark:_recent01Button.currentTitle];
}

// 최근방문 두번째 메뉴 즐겨찾기
- (IBAction)didTouchRecentBookmark02:(id)sender {
    
    [self didTouchRecentBookmark:_recent02Button.currentTitle];
}

// 최근방문 세번째 메뉴 즐겨찾기
- (IBAction)didTouchRecentBookmark03:(id)sender {
    
    [self didTouchRecentBookmark:_recent03Button.currentTitle];
}

/**
@var didTouchRecentBookmark
@brief 최근방문 메뉴의 즐겨찾기 버튼 클릭시 처리
@param 최근방문 메뉴의 타이틀
@return
*/
- (void)didTouchRecentBookmark:(NSString *)recentButtonTitle {
    
    if ([recentButtonTitle isEqualToString:@""]) {
        return;
    }
    
    NSInteger menuIdx = 0;
    BOOL isBreak = NO;
    
    for (NSArray *array in self.menuTotalList) {
        for (NSDictionary *menuDic in array.lastObject) {
            if ([[menuDic valueForKey:LIST_MENU_NAME] isEqualToString:recentButtonTitle]) {
                isBreak = YES;
                break;
            }
            menuIdx++;
        }
        if (isBreak) {
            break;
        }
    }
    
    UIButton *button = [[UIButton alloc] init];
    button.tag = menuIdx;
    [self updateBookmarkMenuArray:button];
    
    NSIndexPath *indexPath = [self getMenuIndexPathWithTag:menuIdx];
    [_menuTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


// 즐겨찾기 첫번째 메뉴
- (IBAction)didTouchBookmarkTitle01:(id)sender {
    
    [self didTouchRecent:_bookmarkTitle01Button.currentTitle];
}

// 즐겨찾기 두번째 메뉴
- (IBAction)didTouchBookmarkTitle02:(id)sender {
    
    [self didTouchRecent:_bookmarkTitle02Button.currentTitle];
}

// 즐겨찾기 세번째 메뉴
- (IBAction)didTouchBookmarkTitle03:(id)sender {
    
    [self didTouchRecent:_bookmarkTitle03Button.currentTitle];
}

// 즐겨찾기 첫번째 북마크
- (IBAction)didTouchBookmark01:(id)sender {
    
    [self bookmarkUpdate:_bookmarkTitle01Button];
}

// 즐겨찾기 두번째 북마크
- (IBAction)didTouchBookmark02:(id)sender {
    
    [self bookmarkUpdate:_bookmarkTitle02Button];
}

// 즐겨찾기 세번째 북마크
- (IBAction)didTouchBookmark03:(id)sender {
    
    [self bookmarkUpdate:_bookmarkTitle03Button];
}

/**
@var bookmarkUpdate
@brief 즐겨찾기 업데이트
@param 선택한 즐겨찾기의 타이틀 버튼
@return
*/
- (void)bookmarkUpdate:(UIButton *)bookmarkTitleButton {
    
    for (NSDictionary *menuDic in self.bookmarkMenuArray) {
        
        NSString *menuName = [menuDic valueForKey:LIST_MENU_NAME];
        
        if ([menuName isEqualToString:bookmarkTitleButton.currentTitle]) {
            [self.bookmarkMenuArray removeObject:menuDic];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.bookmarkMenuArray forKey:BOOKMARK_MENU_ARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self updateBookmarkMenuUI:self.bookmarkMenuArray];
            
            NSIndexPath *deleteIndexPath = [self getMenuIndexPathWithName:menuName];
            [_menuTableView reloadRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            return;
        }
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return menuCellHeightDefault;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return menuCellHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return menuCellFooterHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, menuCellHeaderHeight)];
    headerView.backgroundColor = UIColor.whiteColor;
    
    if (section > 0) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
        lineView.backgroundColor = COLOR_LINE_GRAY;
        [headerView addSubview:lineView];
    }
    
    UILabel *categoryName = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, kScreenBoundsWidth - 30*2, 21)];
    NSArray *menuCategoryArray = [self.menuTotalList objectAtIndex:section];
    categoryName.text = menuCategoryArray.firstObject;
    categoryName.textColor = COLOR_MAIN_PURPLE;
    categoryName.font = [UIFont boldSystemFontOfSize:18];
    
    [headerView addSubview:categoryName];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, menuCellHeaderHeight)];
    footerView.backgroundColor = UIColor.whiteColor;
    return footerView;
}

- (NSDictionary*)getMenuDictionary:(NSIndexPath*)indexPath {
    
    NSArray *menuArray = [[self.menuTotalList objectAtIndex:indexPath.section] objectAtIndex:1];
    return [menuArray objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *selectedMenuDic = [self getMenuDictionary:indexPath];
    
    // 메인(자산/소비/톡톡) 메뉴는 메인으로 이동
    NSString *selectedMenuID = selectedMenuDic[K_VIEWID];
    if ([selectedMenuID isEqualToString:MenuID_V4_ASSETLINKAGE_MainPage] ||
        [selectedMenuID isEqualToString:MenuID_V4_PayMngCnsmRpt] ||
        [selectedMenuID isEqualToString:MenuID_V4_TocToc]) {
        
        [APP_DELEGATE mainViewController].menuID_main = selectedMenuID;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [[AllMenu delegate] sendBirdDetailPage:selectedMenuID callBack:^(ViewController *vc) {}];
    }
    
    [self updateRecentMenuArray:selectedMenuDic];
    
    NSArray *menuCategoryArray = [self.menuTotalList objectAtIndex:indexPath.section];
    
    [WebViewController sendGa360Native:YES p1:@"전체메뉴" p2:menuCategoryArray[0] p3:selectedMenuDic[@"menuName"] campainUrl:nil];
}

- (void)updateRecentMenuArray:(NSDictionary*)selectedDic {

    NSString *menuName = [selectedDic valueForKey:K_MENU_NAME];
    NSString *urlString = [selectedDic valueForKey:K_URL_ADDR];
    NSString *viewId = [selectedDic valueForKey:K_VIEWID];
    NSString *loginYn = [selectedDic valueForKey:K_LOGIN];
    
    for (NSDictionary *menuDic in self.recentMenuArray) {
        BOOL isAlreadyExist = [[menuDic valueForKey:LIST_MENU_NAME] isEqualToString:menuName];
        if (isAlreadyExist) {
            return;
        }
    }
    
    if (self.recentMenuArray.count > 2) {
        [self.recentMenuArray removeObjectAtIndex:2];
    }
    
    [self.recentMenuArray insertObject:@{LIST_MENU_NAME:menuName,
                                         LIST_MENU_URL:urlString,
                                         K_VIEWID:viewId,
                                         K_LOGIN:loginYn,
    } atIndex:0];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.recentMenuArray forKey:RECENT_MENU_ARRAY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateRecentMenuData:self.recentMenuArray];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.menuTotalList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *menuArray = [[self.menuTotalList objectAtIndex:section] objectAtIndex:1];
    
    return menuArray.count;
}
    
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *ideneifier = @"TotalMenuTableViewCell";
    TotalMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    
    NSArray *menuArray = [[self.menuTotalList objectAtIndex:indexPath.section] objectAtIndex:1];

    NSDictionary *menuDic =  [menuArray objectAtIndex:indexPath.row];
    NSString *menuName = [menuDic valueForKey:LIST_MENU_NAME];
    
    cell.menuTitleLabel.text = menuName;
    
    [cell.bookmarkButton setTag:[self indexOfMenu:indexPath]];
    [cell.bookmarkButton addTarget:self action:@selector(updateBookmarkMenuArray:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bookmarkButton setSelected:NO];
    
    for (NSDictionary *menuDic in self.bookmarkMenuArray) {
        BOOL isAlreadyExist = [[menuDic valueForKey:LIST_MENU_NAME] isEqualToString:menuName];
        if (isAlreadyExist) {
            [cell.bookmarkButton setSelected:YES];
        }
    }
    
    return cell;
}

- (NSInteger)indexOfMenu:(NSIndexPath *)indexPath {
    
    NSInteger menuIdx = 0;
    
    for (int i=0; i<indexPath.section; i++) {
        NSArray *array = [self.menuTotalList objectAtIndex:i];
        NSArray *menuList = array.lastObject;
        menuIdx += menuList.count;
    }
    
    NSInteger indexOfMenu = menuIdx + indexPath.row;
    return indexOfMenu;
}

@end

@implementation TotalMenuTableViewCell

@end
