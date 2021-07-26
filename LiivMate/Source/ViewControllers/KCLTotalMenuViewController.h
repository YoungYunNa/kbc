//
//  KCLTotalMenuViewController.h
//  LiivMate
//
//  Created by KB on 2021/05/14.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KCLTotalMenuViewController : ViewController

@property (weak, nonatomic) IBOutlet UIButton *leftFirstButton;
@property (weak, nonatomic) IBOutlet UIButton *leftSecondButton;

// 개발 테스트
@property (weak, nonatomic) IBOutlet UIButton *devButton;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

// 상단 메뉴 탭 버튼
@property (weak, nonatomic) IBOutlet UIButton *tabRecentButton;   // 최근방문
@property (weak, nonatomic) IBOutlet UIButton *tabBookmarkButton; // 즐겨찾기

// 상단 메뉴 버튼 언더라인
@property (weak, nonatomic) IBOutlet UIView *tabButtonUnderlineView;
@property (weak, nonatomic) IBOutlet UIView *tabRecentUnderline;
@property (weak, nonatomic) IBOutlet UIView *tabBookmarkUnderline;

// 상단 메뉴 버튼 언더라인 Leading Alignment Constraint
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabButtonUnderlineViewLeading01;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabButtonUnderlineViewLeading02;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabButtonUnderlineViewLeading03;

// 최근방문/즐겨찾기 가이드
@property (weak, nonatomic) IBOutlet UILabel *tabRecentGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel *tabBookmarkGuideLabel;

// 상단 메뉴 뷰
@property (weak, nonatomic) IBOutlet UIView *topRecentView;
@property (weak, nonatomic) IBOutlet UIView *topBookmarkView;

// 상단 메뉴 뷰 높이
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMenuViewHeight;

// 상단 메뉴 최근방문 버튼
@property (weak, nonatomic) IBOutlet UIButton *recent01Button;
@property (weak, nonatomic) IBOutlet UIButton *recent02Button;
@property (weak, nonatomic) IBOutlet UIButton *recent03Button;

// 상단 메뉴 최근방문의 즐겨찾기 버튼
@property (weak, nonatomic) IBOutlet UIButton *recentBookmark01Button;
@property (weak, nonatomic) IBOutlet UIButton *recentBookmark02Button;
@property (weak, nonatomic) IBOutlet UIButton *recentBookmark03Button;

// 상단 메뉴 즐겨찾기 타이틀 버튼
@property (weak, nonatomic) IBOutlet UIButton *bookmarkTitle01Button;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkTitle02Button;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkTitle03Button;

// 상단 메뉴 즐겨찾기 버튼
@property (weak, nonatomic) IBOutlet UIButton *bookmark01Button;
@property (weak, nonatomic) IBOutlet UIButton *bookmark02Button;
@property (weak, nonatomic) IBOutlet UIButton *bookmark03Button;

@end

@interface TotalMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;

@end

NS_ASSUME_NONNULL_END
