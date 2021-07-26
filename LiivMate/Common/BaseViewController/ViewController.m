//
//  ViewController.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 18..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "ViewController.h"
#import "NoticeAlertView.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import "HybridWKWebView.h"
#import "GoogleAnalyticsBuilder.h"
#import <Firebase/Firebase.h>

@implementation UIViewController (NeedsLayout)
-(void)setNeedsLayoutSubviews
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(viewWillLayoutSubviews) object:nil];
    [self performSelector:@selector(viewWillLayoutSubviews) withObject:nil afterDelay:0.001];
}
@end

@interface ViewController ()
{
    CGFloat _scrollOffsetY;
    BOOL _regTfNoti;
    UITextField *_scrollTf;
	BOOL _initSetting;
}
@end

@implementation ViewController

static UIImage *defUnderlineImage = nil;
static UIImage *hiddenUnderlineImage = nil;

+(void)initialize
{
	[super initialize];
	if(defUnderlineImage == nil)
	{
		defUnderlineImage = [EtcUtil imageWithColor:UIColorFromRGB(0xdddddd)];
		hiddenUnderlineImage = [EtcUtil imageWithColor:UIColorFromRGBWithAlpha(0xffffff, 0)];
	}
}

-(id)init
{
	self = [super init];
	if(self)
	{
		if(_initSetting == NO)
			[self initSettings];
		_initSetting = YES;
	}
	return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if(self)
	{
		if(_initSetting == NO)
			[self initSettings];
		_initSetting = YES;
	}
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self)
	{
		if(_initSetting == NO)
			[self initSettings];
		_initSetting = YES;
	}
	return self;
}

-(void)initSettings
{
	self.navigationBarTranslucent = NO;
	self.toolBarTranslucent = YES;
	self.enableTfAutoScroll = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.view.backgroundColor = [UIColor whiteColor];
	_isLoadView = YES;
    
     if (@available(iOS 13.0, *)) {
         if ([self respondsToSelector:NSSelectorFromString(@"overrideUserInterfaceStyle")]) {
             [self setValue:@(UIUserInterfaceStyleLight) forKey:@"overrideUserInterfaceStyle"];
         }
     }
    
//    [[Crashlytics sharedInstance] setObjectValue:NSStringFromClass([self class]) forKey:@"Last_Class"];
//    CLS_LOG(@"ViewController : %@", NSStringFromClass([self class]));
    [[FIRCrashlytics crashlytics] logWithFormat:@"ViewController : %@", NSStringFromClass([self class])];
    NSLog(@"ViewController : %@", NSStringFromClass([self class]));
}

-(void)resetData
{
	
}

-(void)initPreprocessingCallback:(void (^)(BOOL success))callback
{
	if(callback)
		callback(YES);
}

-(BOOL)isShowPwd
{
    return [PwdWrapper isShowPwd:self];
}

-(void)dealloc
{
	self.performCallback = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	NSLog(@">> [%@]",NSStringFromClass(self.class));
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupLeftBarButtonItem];
        
    [UIApplication sharedApplication].statusBarStyle = [self preferredStatusBarStyle];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

	if(_regTfNoti == NO && _enableTfAutoScroll)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKeybordScroll:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKeybordScroll:) name:UITextFieldTextDidEndEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKeybordScroll:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKeybordScroll:) name:UITextViewTextDidEndEditingNotification object:nil];
        _regTfNoti = YES;
    }
	
    // Menu Popup 공지관련 코드추가
    NSString *menuId = self.menuItem[@"menuId"];
    if(_checkedPopup && menuId) {
        if([[UserDefaults sharedDefaults] checkTrgPageId:menuId update:NO]) {
                [Request requestID:KATW002 body:@{@"menuId":menuId} waitUntilDone:NO showLoading:NO cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                    if(IS_SUCCESS(rsltCode)) {
                        NSString *pupTitl = [result null_valueForKey:@"pupTitl"];
                        NSString *pupCtnt = [result null_valueForKey:@"pupCtnt"];
                        NSString *targetUrl = [result null_valueForKey:@"targetUrl"];
                        [NoticeAlertView showNoticeTitle:pupTitl message:pupCtnt detail:targetUrl.length dissmiss:^(BOOL checked, BOOL showDetail) {
                            self->_checkedPopup = NO;
                            if(checked) {
                                [[UserDefaults sharedDefaults] checkTrgPageId:menuId update:YES];
                            }
                            if(showDetail) {
                                [AllMenu.delegate sendBirdDetailPage:targetUrl callBack:^(ViewController *vc) {
                                }];
                            }
                        }];
                    }
                }];
            }
    }
    
	_isViewAppear = YES;
	self.naviUnderlineHidden = _naviUnderlineHidden;
}

-(void)setNaviUnderlineHidden:(BOOL)naviUnderlineHidden
{
	_naviUnderlineHidden = naviUnderlineHidden;
	if(self.navigationController.navigationBar)
	{
		UIImage *image = _naviUnderlineHidden ? hiddenUnderlineImage : defUnderlineImage;
		if([image isEqual:self.navigationController.navigationBar.shadowImage] == NO)
		{
			self.navigationController.navigationBar.shadowImage = image;
			if (@available(iOS 11.0, *)){} else
			{
				if(nil != self.navigationController)
				{
					for(UIView *view in self.navigationController.navigationBar.subviews)
					{
						if([NSStringFromClass(view.class) hasSuffix:@"Background"])
						{
							view.subviews.firstObject.alpha = self.naviUnderlineHidden ? 0 : (_navigationBarTranslucent ? 0.7 : 1);
							break;
						}
					}
				}
			}
		}
	}
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(_regTfNoti)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
        _regTfNoti = NO;
        _scrollTf = nil;
    }
	_isViewAppear = NO;
}

- (UIScrollView*)parentScrollView:(UIView *)view;
{
    if(view == nil) return nil;
    UIResponder *responder = view.superview;
    
    while (!([NSStringFromClass(responder.class) isEqualToString:@"UIScrollView"]
             ||[NSStringFromClass(responder.class) isEqualToString:@"UITableView"])) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return (UIScrollView *)responder;
}

-(void)changeKeybordScroll:(NSNotification*)noti
{
    UIScrollView *scrollView = [self parentScrollView:noti.object];
    if(CGRectGetWidth(scrollView.frame) != CGRectGetWidth(self.view.frame))
        scrollView = [self parentScrollView:scrollView];
    
    if(((UIView*)noti.object).parentViewController == self && scrollView)
    {
        if([noti.name isEqualToString:UITextFieldTextDidBeginEditingNotification]
           ||[noti.name isEqualToString:UITextViewTextDidBeginEditingNotification])
        {
            _scrollTf = noti.object;
			CGFloat keyH = 260;
			UIWindow *win = [UIApplication sharedApplication].windows.lastObject;
			if([NSStringFromClass([win class]) containsString:@"KeyboardWindow"])
			{
				UIViewController *keyboardVc = win.rootViewController.childViewControllers.firstObject;
				keyH = CGRectGetHeight(keyboardVc.view.superview.frame);
			}
			
            CGFloat bottom = keyH;// + (CGRectGetHeight(self.view.frame) - CGRectGetMaxY(scrollView.frame));
            CGRect rect = ((UIView*)noti.object).getVisibleRect;
            
            if (self.disableScrollViewContentInset != YES){
                UIEdgeInsets inset = scrollView.contentInset;
                inset.bottom = bottom;
                scrollView.contentInset = inset;
            }
            
            if(CGRectGetMaxY(rect) > CGRectGetHeight([UIScreen mainScreen].bounds) - keyH)
            {
                CGFloat keyY = CGRectGetMaxY(rect) - (CGRectGetHeight([UIScreen mainScreen].bounds) - keyH);
                
                CGPoint offset = scrollView.contentOffset;
                offset.y += keyY;
                [scrollView setContentOffset:offset animated:YES];
            }
        }
        else if([noti.name isEqualToString:UITextFieldTextDidEndEditingNotification]
                ||[noti.name isEqualToString:UITextViewTextDidEndEditingNotification])
        {
            [self performSelector:@selector(resignResponder:) withObject:noti.object afterDelay:0.0001];
        }
    }
    
}

-(void)resignResponder:(UIView *)view
{
    if(_scrollTf == view)
        _scrollTf = nil;
    
    if(_scrollTf == nil)
    {
        UIScrollView *scrollView = [self parentScrollView:view];
        if(CGRectGetWidth(scrollView.frame) != CGRectGetWidth(self.view.frame))
            scrollView = [self parentScrollView:scrollView];
        
        UIEdgeInsets inset = scrollView.contentInset;
        inset.bottom = 0;
        scrollView.contentInset = inset;
    }
}

- (UIButton*)setupLeftBarButtonItem
{
    UIButton *button = nil;
    if(self.navigationItem.hidesBackButton == NO && self.navigationItem.leftBarButtonItem == nil)
    {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 40, 35);
        [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if(self.navigationController.viewControllers.count > 1)
        {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [button setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
            [button setIsAccessibilityElement:YES];
            [button setAccessibilityLabel:@"뒤로가기"];
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
            self.navigationItem.leftBarButtonItem = barButton;
#if ScreenEdgeBackMode
			//navigationControl 밀어서닫기
            if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && IS_USE_WKWEBVIEW) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
                self.navigationController.interactivePopGestureRecognizer.delegate = (id)[AllMenu delegate];
            }
#endif
        }
        else if(self.navigationController != (id)[AllMenu delegate])
        {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            button.tag = 1;
            [button setImage:[UIImage imageNamed:@"close_black"] forState:(UIControlStateNormal)];
            [button setIsAccessibilityElement:YES];
            [button setAccessibilityLabel:@"닫기"];
            UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
            self.navigationItem.rightBarButtonItem = barButton;
        }
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setValue:@(YES) forKeyPath:@"hidesShadow"];
    }
    return button;
}

// 백버튼 액션.
- (IBAction)backButtonAction:(UIButton*)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.navigationController.viewControllers.count > 1)
    {
        NSLog(@"self.navigationController.viewControllers : %@", self.navigationController.viewControllers);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
		if(sender.tag == 1 || self.navigationController != APP_MAIN_VC)
		{
			[self dismissViewControllerAnimated:YES completion:nil];
		}
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        // Fallback on earlier versions
        return UIStatusBarStyleDefault;
    }
    //  지금 13sdk 12sdk공용으로 빌드중이라 방어코드 처리 추후 수정예정
//    if (@available(iOS 13.0, *)) {
//
//        if (![self respondsToSelector:NSSelectorFromString(@"setModalInPresentation:")])
//            return UIStatusBarStyleDefault;
//        else
//            return 3;
//    } else {
//        return UIStatusBarStyleDefault;
//    }
}

#pragma mark - GNB ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
}

-(void)didEndScrollView:(UIScrollView*)scrollView
{
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark - GA관련 코드
static id<WebView> gaWebView = nil;
#define GA_URL_FORMAT	@"%@/comm/sendGa.do?screnId=%@"

+(void)sendGAWithScrenId:(NSString*)screnId
{
	if(gaWebView == nil)
	{
        gaWebView = (id)[[HybridWKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];

		((UIView*)gaWebView).alpha = 0;
		[[UIApplication sharedApplication].keyWindow insertSubview:(UIView*)gaWebView atIndex:0];
	}
	NSString *urlStr = [NSString stringWithFormat:GA_URL_FORMAT,SERVER_URL,screnId];
	NSURL *url = [NSURL URLWithString:urlStr];
	if(url)
	{
		NSURLRequest *rq = [NSURLRequest requestWithURL:url];
		[gaWebView stopLoading];
		[gaWebView webViewLoadRequest:rq];
	}
}

-(void)setViewID:(NSString *)viewID
{
	_viewID = viewID;
	if(_viewID)
	{//ga화면ID보냄, 하이브리드웹뷰class는 이메서드가 오버라이딩 되어있어 동작하지않음.
//		[ViewController sendGAWithScrenId:_viewID]; // 3.0에서 사용하지 않는 코드로 주석처리 (GA360으로변경)
	}

}

-(void)sendGaMesurementProtocol:(NSString *)screenName
{
    // 2020.5.14 최일용 구글 애널리틱스 추가.
    //----------------------------------------------------------
    //Golden Planet에서 받은 GoogleAnalyticsBuilder.h m파일 헤더추가후 호출할수 있음

    NSMutableDictionary *screenView_dict = [[NSMutableDictionary alloc] init];
    [screenView_dict setValue:@"맞춤측정 기준1값" forKey:GACustomKey(Dimension1)];
    [screenView_dict setValue:@"맞춤측정 기준1값" forKey:GACustomKey(Dimension1)];
    [screenView_dict setValue:@"맞춤측정 기준1값" forKey:GACustomKey(Dimension1)];
    [screenView_dict setValue:[NSString sha256HashForText:[AppInfo userInfo].custNo] forKey:GAHitKey(UserID)];
    [screenView_dict setValue:screenName forKey:GAHitKey(Title)];

    GADataSend_Screen(screenView_dict);
    //----------------------------------------------------------
}

// ios13 모달뷰 패치코드 뒷배경에 이전화면이 보이고 내리는 제스처로 화면을 닫는것을 방지한다.
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (@available(iOS 13.0, *)) {
        viewControllerToPresent.modalPresentationStyle =UIModalPresentationFullScreen;
        if ([viewControllerToPresent respondsToSelector:NSSelectorFromString(@"setModalInPresentation:")]) {
            [viewControllerToPresent performSelector:@selector(setModalInPresentation:) withObject:[NSNumber numberWithBool:YES]];
        }
        
    }
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
