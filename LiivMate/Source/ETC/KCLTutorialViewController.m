//
//  KCLTutorialViewController.m
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLTutorialViewController.h"

@interface KCLTutorialViewController ()
{
    NSMutableArray *tutorialImageViewArray;
    
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIView *scrollContentView;
    __weak IBOutlet NSLayoutConstraint *scrollContentViewWidth;
    __weak IBOutlet UIButton *prevButton;
    __weak IBOutlet NSLayoutConstraint *prevButtonLeft;
    __weak IBOutlet UIButton *nextButton;
    __weak IBOutlet NSLayoutConstraint *nextButtonRight;
    __weak IBOutlet UIButton *finishButton;
    __weak IBOutlet UIPageControl *pageControl; // PageControl 추가
}
@end

@implementation KCLTutorialViewController

#pragma mark - Super Init (ViewController)
- (void)initSettings
{
    [super initSettings];
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBarHidden = YES;
    
    NSArray *imageNames = @[@"Intro_01",
                            @"Intro_02",
                            @"Intro_03",
                            @"Intro_04",
                            @"Intro_05"];
    
    NSArray *voiceLabels = @[@"매일 새로워지는 금융자산과 혜택 큐레이션입니다.",
                             @"소비생활을 통해 추천 받는 다양한 맞춤 혜택 서비스입니다.",
                             @"일상생활에서 합리적 소비를 실천하게 해주는 관리 서비스입니다.",
                             @"금융생활을 분석하여 쉽고 친근하게 알려주는 자산 관리 서비스입니다.",
                             @"여러 제휴사 포인트를 포인트리로 모아서 쉽고 간편하게 결제하는 간편결제 서비스입니다."];
    
    tutorialImageViewArray = [[NSMutableArray alloc] init];
    for (int i=0; i<imageNames.count; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNames[i]]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.accessibilityLabel = voiceLabels[i];
        imageView.accessibilityTraits = UIAccessibilityTraitStaticText;
        imageView.isAccessibilityElement = YES;
        imageView.accessibilityHint = [NSString stringWithFormat:@"%d개 중, %d번째 이미지", (int)imageNames.count, i+1];
        if (imageView)
        {
            [tutorialImageViewArray addObject:imageView];
            [scrollContentView addSubview:imageView];
        }
    }
    
    // To Do : 추후 기능에 대한 추가 요청이 있을 수 버튼에 대한 구현부분은 삭제 하지 않음.
    prevButton.isAccessibilityElement = NO;
    nextButton.isAccessibilityElement = NO;
    
    // 페이지 컨트롤 초기화
    pageControl.numberOfPages = tutorialImageViewArray.count;           // 페이지 갯수
    pageControl.currentPage = 0;                                        // 초기 페이지
    pageControl.currentPageIndicatorTintColor = COLOR_MAIN_PURPLE;      // 선택된 페이지 컬러
    pageControl.pageIndicatorTintColor = UIColor.lightGrayColor;        // 선택 안된 페이지 컬러
    
    
    [finishButton setBackgroundImage:[[finishButton backgroundImageForState:UIControlStateNormal] stretchableImageWithCapWidthRatio:0.5 capHeightRatio:0.5] forState:UIControlStateNormal];

    [self updateButtonUI];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize viewSize = self.view.frame.size;

    scrollContentViewWidth.constant = viewSize.width * tutorialImageViewArray.count;

    for (int i=0; i<tutorialImageViewArray.count; i++)
    {
        UIImageView *imageView = tutorialImageViewArray[i];
        imageView.frame = CGRectMake(viewSize.width * i, 0, viewSize.width, viewSize.height);
    }

    // ???? TODO : 확인 요망
    if (IS_IPHONE_4)
    {
        for (int i=0; i<tutorialImageViewArray.count; i++)
        {
            UIImageView *imageView = tutorialImageViewArray[i];

            CGFloat width = viewSize.width;
            CGFloat height = viewSize.width * (667.0/375.0);
            imageView.frame = CGRectMake(viewSize.width * i, 0, width, height);
        }
    }
    if (IS_IPHONE_X)
    {
        for (int i=0; i<tutorialImageViewArray.count; i++)
        {
            UIImageView *imageView = tutorialImageViewArray[i];
            
            CGFloat width = viewSize.width;
            CGFloat height = viewSize.height - 100;
            imageView.frame = CGRectMake(viewSize.width * i, viewSize.height - height, width, height);
        }

        prevButtonLeft.constant = 10;
        nextButtonRight.constant = 10;
    }
}

#pragma mark - Prev / Next Button UI Update
- (void)updateButtonUI
{
    int pageNo = (int)(scrollView.contentOffset.x + scrollView.bounds.size.width / 2.0) / (int)scrollView.bounds.size.width;
    
    prevButton.hidden = (pageNo == 0);
    nextButton.hidden = (pageNo == tutorialImageViewArray.count - 1);
}

#pragma mark - Scroll Event Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    [self updateButtonUI];
}

/**
@var scrollViewDidScroll
@brief 스크롤시 페이지 컨트롤러 변경
*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 현재 페이지 계산
    pageControl.currentPage = (int)scrollView.contentOffset.x / UIScreen.mainScreen.bounds.size.width;
}

#pragma mark - Button Click Event
- (IBAction)prevButtonClicked:(id)sender
{
    // 이전 버튼
    int pageNo = (int)(scrollView.contentOffset.x + scrollView.bounds.size.width / 2.0) / (int)scrollView.bounds.size.width;
    pageNo = MAX((pageNo - 1), 0);
    
    [scrollView setContentOffset:CGPointMake(pageNo * scrollView.bounds.size.width, 0) animated:YES];
    
    [self performSelector:@selector(updateButtonUI) withObject:nil afterDelay:0.3];
}

- (IBAction)nextButtonClickecd:(id)sender
{
    // 다음 버튼
    int pageNo = (int)(scrollView.contentOffset.x + scrollView.bounds.size.width / 2.0) / (int)scrollView.bounds.size.width;
    pageNo = MIN((pageNo + 1), ((int)tutorialImageViewArray.count - 1));

    [scrollView setContentOffset:CGPointMake(pageNo * scrollView.bounds.size.width, 0) animated:YES];
    [self performSelector:@selector(updateButtonUI) withObject:nil afterDelay:0.3];
}

- (IBAction)finishButtonClicked:(id)sender
{
    // ???? TODO : 종료 버튼 - 확인 요망
    
    // 메인화면
    if([AppInfo sharedInfo].isJoin==NO)
    {
        // Ver. 3 회원가입(MYD_JO0100)
        // 회원가입
        [[AllMenu delegate] navigationWithMenuID:MenuID_V3_MateJoin
                                        animated:YES
                                          option:NavigationOptionNoneHistoryPush
                                        callBack:nil];
    }
    else
    {
        [self backButtonAction:nil];
    }
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
