//
//  KCLCustomNavigationBarView.m
//  LiivMate
//
//  Created by KB on 20/02/2020.
//  Copyright © 2020 KBCard. All rights reserved.
//

#import "KCLCustomNavigationBarView.h"
#import "KCLTotalMenuViewController.h"

#define barViewHeight 60 // 상단 공통헤더 뷰 높이값

@implementation KCLCustomNavigationBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/

+ (instancetype)instance
{
    @try {
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Component" owner:nil options:nil];
        KCLCustomNavigationBarView *naviObj;
        for (id obj in objects)
        {
            if ([obj isKindOfClass:[KCLCustomNavigationBarView class]])
            {
                naviObj = obj;
                
                CGRect statusBarRect = [UIApplication sharedApplication].statusBarFrame;
                naviObj.frame = CGRectMake(0, statusBarRect.size.height, [UIScreen mainScreen].bounds.size.width, barViewHeight);
                
                break;
            }
        }
        return naviObj;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

#pragma mark - Button Event
/**
@var didTouchLoginButton (로그인)
@brief 로그인
*/
-(IBAction)didTouchLoginButton:(UIButton*)button{
    NSLog(@"로그인");
    [[AppInfo sharedInfo] performLogin:^(BOOL success, NSString *errCD, NSDictionary* result) {
        
    }];
}

/**
@var didTouchSignUpButton (회원가입)
@brief 회원가입
*/
-(IBAction)didTouchSignUpButton:(UIButton*)button{
    NSLog(@"회원가입");
    // Ver. 3 회원가입(MYD_JO0100)
    [[AllMenu delegate] navigationWithMenuID:MenuID_V3_MateJoin
                                    animated:YES
                                      option:NavigationOptionPush
                                    callBack:nil];
}

/**
@var didTouchMenuButton
@brief 전체 메뉴 버튼 클릭 이벤트
*/
- (IBAction)didTouchMenuButton:(UIButton*)button {

    KCLTotalMenuViewController *totalMenuViewController;
    
    for (UIViewController *vc in _currentViewController.navigationController.viewControllers) {
        if ([vc isKindOfClass:[KCLTotalMenuViewController class]]) {
            totalMenuViewController = (KCLTotalMenuViewController *)vc;
        }
    }
    
    if (totalMenuViewController) {
        [self.currentViewController.navigationController popToViewController:totalMenuViewController animated:YES];
    } else {
        totalMenuViewController = [[UIStoryboard storyboardWithName:@"KCLMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"KCLTotalMenuViewController"];
        [self.currentViewController.navigationController pushViewController:totalMenuViewController animated:YES];
    }
}

#pragma mark - Set Data
/**
@var setTitle
@brief Title 설정
@param title
*/
- (void)setTitle:(NSString*)title {
    self.titleLabel.text = title;
}

/**
@var setCloseBtn
@brief Close 버튼 추가 (혜택찾기 업무단 추가 요청 인터페이스)
@param action :   "C" : PreTypeClose, "T" : PreTypeTargetUrl,  "F" : PreTypeTargetFunction
*/
- (void)setCloseBtn:(NSString*)closeYN action:(NSString *)action {
    
    if ([closeYN isEqualToString:@"Y"]) {
        self.closeButton.hidden = NO;
        [self.closeButton setExclusiveTouch:YES];
        self.action = action;
        
        self.menuButton.hidden = YES;
    }
    else {
        self.closeButton.hidden = YES;
    }
}

/**
@var dimmViewSet
@brief dimmView hidden 설정
@param dimmYN :  dimmView  hidden 여부 ("Y"/"N")
*/
- (void)dimmViewSet:(NSString *)dimmYN {
    
    if ([dimmYN isEqualToString:@"Y"]) {
        [self.closeButton setImage:[UIImage imageNamed:@"close_white.png"]  forState:UIControlStateNormal];
        self.dimmView.hidden = NO;
    }
    else {
        [self.closeButton setImage:[UIImage imageNamed:@"close_black.png"]  forState:UIControlStateNormal];
        self.dimmView.hidden = YES;
    }
}

/**
@var setTotalMenuBtn
@brief 전체메뉴 버튼 hidden 설정
@param menuYN : 전체메뉴 버튼 hidden 여부 ("Y"/"N")
*/
- (void)setTotalMenuBtn:(NSString*)menuYN {
    
    if ([menuYN isEqualToString:@"Y"]) {
        self.menuButton.hidden = NO;
        self.closeButton.hidden = YES;
    }
    else {
        self.menuButton.hidden = YES;
    }
}

/**
@var mainHeaderViewSet
@brief 메인화면의 공통헤더뷰 설정 (전체메뉴 버튼만 보여줌)
*/
- (void)mainHeaderViewSet {
    
    self.leftBackButton.hidden = YES;
    self.titleLabel.text = @"";
    [self setTotalMenuBtn:@"Y"];
}

/**
@var setCustomNavigationBar
@brief 상단 Title 버튼 이벤트 처리
*/
- (void)setCustomNavigationBar:(UIViewController*)viewController {
    
    viewController.navigationController.navigationBarHidden = YES;
    self.currentViewController = viewController;
    
    [self.leftBackButton addTarget:viewController action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    // Close 버튼 추가 (혜택찾기 업무단 추가 요청 인터페이스)
    [self.closeButton addTarget:viewController action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

/**
@var setNavigationItems
@brief 상단 Title 버튼에 대한 초기 표시 설정
*/
- (void)setNavigationItems:(UIViewController*)viewController navigationType:(KCLNavigationViewType)naviViewType {
    
    viewController.navigationController.navigationBarHidden = YES;
    self.currentViewController = viewController;
    
    self.leftBackButton.hidden = YES;               // 뒤로가기
    self.leftBackButtonWidth.constant = 12;
    self.titleLabel.hidden = NO;                    // 타이틀
    self.closeButton.hidden = YES;                  // 닫기 버튼
    
    // 뒤로가기 버튼
    [self.leftBackButton addTarget:viewController action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Close 버튼 추가 (혜택찾기 업무단 추가 요청 인터페이스)
    [self.closeButton addTarget:viewController action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    switch (naviViewType) {
        case KCLNavigationViewTypeTargetMenuOnepass:
            self.closeButton.hidden = NO;
            break;
            
        case KCLNavigationViewTypeAllShow:
            self.leftBackButton.hidden = NO;
            self.leftBackButtonWidth.constant = 38;
            self.closeButton.hidden = NO;
            break;
            
        default:
            break;
    }
}

@end
