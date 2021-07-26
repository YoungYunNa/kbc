//
//  ViewController.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 18..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NeedsLayout)
-(void)setNeedsLayoutSubviews;
@end

@class ViewController;
typedef void (^PerformCallback)(ViewController *vc);

@interface ViewController : UIViewController
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSString *viewID;
@property (nonatomic, strong) NSDictionary *menuItem;
@property (nonatomic, assign) BOOL checkedPopup;//해당화면의 menuId로 팝업을 보여줘야 하는지 체크
@property (nonatomic, strong) NSDictionary *dicParam;
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL menuHidden;
@property (nonatomic, assign) BOOL enableTfAutoScroll; //def YES
@property (nonatomic, assign) BOOL isSuccessTRByInit;
@property (nonatomic, assign) BOOL disableScrollViewContentInset;
@property (nonatomic, strong) UIColor *navigationBarColor;  // navgationBar색상 변경Color (구현 페이지 viewDidLoad에서 세팅후 확인 가능)
@property (nonatomic, assign) BOOL naviUnderlineHidden;

@property (nonatomic, assign) BOOL toolBarTranslucent;//def YES
@property (nonatomic, assign) BOOL navigationBarTranslucent;//def NO

@property (nonatomic, strong) PerformCallback performCallback;

@property (nonatomic, assign, readonly) BOOL isLoadView;	//viewDidLoad가 호출되었는지 여부
@property (nonatomic, assign, readonly) BOOL isViewAppear;	//view가 최초 한번이라도 화면에 보여졌는지 여부

//ga용 웹뷰 호출함수로 히든시켜둔 싱글톤 웹뷰를 통해서 호출, setViewID: 메서드에서 호출되고, 하이브리드 화면은 기본적으로 동작하지 않음
+(void)sendGAWithScrenId:(NSString*)screnId;
//-(void)sendGa360:(NSDictionary*)infoDic;
-(void)initSettings;

//화면 진입전에 처리해야만 하는 작업으로 네비게이션직전에 호출됨 return이 NO이면 화면이 열리지 않음
-(void)initPreprocessingCallback:(void (^)(BOOL success))callback;

//서버에서 받은 데이터
@property (nonatomic, strong)   NSDictionary *serverRecieveDic;
//이전화면에서 넘겨받은 데이터
@property (nonatomic, strong)   NSString *nativeStrInfo;

- (UIButton*)setupLeftBarButtonItem;
- (IBAction)backButtonAction:(UIButton*)sender;
- (BOOL)isShowPwd;
- (void)resetData;

///////////////////////스크롤에 따른 탭바 위치변화에 사용하는 메서드임
////////////상속받은 컨트롤러에서 아래 메서드를 사용하는경우 superClass에 호출해주어야함.. [super scrollViewDidScroll:scrollView]
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;
/////////////////////////////////////////////////////////////////////

@end

