//
//  KCLCustomNavigationBarView.h
//  LiivMate
//
//  Created by KB on 20/02/2020.
//  Copyright © 2020 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum KCLNavigationViewType {
    KCLNavigationViewTypeTargetMenuOnepass = 0,                         // X(close 버튼) Button Set
    KCLNavigationViewTypeAllShow,                                       // <-(이전), X(close 버튼) Button Set
    KCLNavigationViewTypeNone,
} KCLNavigationViewType;

@interface KCLCustomNavigationBarView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;               // 타이틀
@property (weak, nonatomic) IBOutlet UIButton *leftBackButton;          // 이전버튼
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBackButtonWidth; // 이전버튼의 넓이를 조절하여 타이틀의 leading 간격 조정

@property (weak, nonatomic) IBOutlet UIButton *menuButton;              // Menu 버튼 추가
@property (weak, nonatomic) IBOutlet UIButton *closeButton;             // Close 버튼 추가 (혜택찾기 업무단 추가 요청 인터페이스)
@property (strong, nonatomic) NSString *action;                         // Close 버튼 선택 시 뒤로 Action에 대한 이벤트 처리를 위해 주가

@property (weak, nonatomic) IBOutlet UIView *dimmView;                  // 헤더 dimm
@property (strong, nonatomic) NSString *dimmYN;                         // 공통 헤더 영역 dimm 처리 여부

@property (weak, nonatomic) UIViewController *currentViewController;    // 현재 ViewController

+ (instancetype)instance;
- (void)setNavigationItems:(UIViewController*)viewController navigationType:(KCLNavigationViewType)naviViewType;
- (void)setCustomNavigationBar:(UIViewController*)viewController;
- (void)setTitle:(NSString*)title;
- (void)setCloseBtn:(NSString*)closeYN action:(NSString *)action;       // Close 버튼 추가 (혜택찾기 업무단 추가 요청 인터페이스)
- (void)setTotalMenuBtn:(NSString*)menuYN;
- (void)mainHeaderViewSet;
- (void)dimmViewSet:(NSString *)dimmYN;
@end
