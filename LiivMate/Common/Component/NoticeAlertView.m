//
//  NoticeAlertView.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 11. 1..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "NoticeAlertView.h"
#import "HybridWKWebView.h"

@interface NoticeAlertView ()
{
    UIView *_noticeWebView;
    UIButton *_checkButton;
    BOOL isFullPopup;
}

-(BOOL)isChecked;
@end

@implementation NoticeAlertView
//공지사항 팝업
+(void)showNoticeTitle:(NSString*)title message:(NSString*)message dismissTitle:(NSString*)dismissTitle dissmiss:(void (^)(BOOL checked))dissmiss
{
	[self showBlockAlertCustomCallback:^(BlockAlertView *alertView) {
		alertView.title = title;
		alertView.message = message;
		[alertView setCancelButtonWithTitle:@"닫기"];
		[((NoticeAlertView*)alertView)->_checkButton setTitle:dismissTitle forState:(UIControlStateNormal)];
	} dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
		dissmiss([((NoticeAlertView*)alertView) isChecked]);
	}];
}

//공지사항 팝업
+(void)showNoticeTitle:(NSString*)title message:(NSString*)message dismissTitle:(NSString*)dismissTitle isFullPopup:(BOOL)isFullPopup dissmiss:(void (^)(BOOL checked))dissmiss
{
    [self showBlockAlertCustomCallback:^(BlockAlertView *alertView) {
        ((NoticeAlertView*)alertView)->isFullPopup = isFullPopup;
        alertView.title = title;
        alertView.message = message;
        [alertView setCancelButtonWithTitle:@"닫기"];
        [((NoticeAlertView*)alertView)->_checkButton setTitle:dismissTitle forState:(UIControlStateNormal)];
    } dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        dissmiss([((NoticeAlertView*)alertView) isChecked]);
    }];
}

//화면팝업
+(void)showNoticeTitle:(NSString*)title message:(NSString*)message detail:(BOOL)showDetail  dissmiss:(void (^)(BOOL checked, BOOL showDetail))dissmiss
{
	[self showBlockAlertCustomCallback:^(BlockAlertView *alertView) {
		alertView.title = title;
		alertView.message = message;
		[((NoticeAlertView*)alertView)->_checkButton setTitle:@"오늘 하루 안보기" forState:(UIControlStateNormal)];
		if(showDetail)
			[alertView setCancelButtonWithTitle:@"자세히 보기"];
	} dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
		dissmiss([((NoticeAlertView*)alertView) isChecked], buttonIndex == alertView.cancelButtonIndex);
	}];
}

-(id)init
{
	self = [super init];
	if(self)
	{
		self.isShowClosedBtn = YES;
		self.isTouchDisable = YES;
		
		_checkButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
		_checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
		[_checkButton setImage:[UIImage imageNamed:@"pop_today_checkbox"] forState:(UIControlStateNormal)]; // checkbox 이미지 교체
		[_checkButton setImage:[UIImage imageNamed:@"pop_today_checkbox_on"] forState:(UIControlStateSelected)];
		[_checkButton setIsAccessibilityElement:YES];
		[_checkButton setAccessibilityLabel:_checkButton.currentTitle];
		_checkButton.titleLabel.font = FONTSIZE(16);
		[_checkButton setTitleColor:UIColorFromRGB(0xffffff) forState:(UIControlStateNormal)];
		[_checkButton addTarget:self action:@selector(onClickedCheckButton:) forControlEvents:(UIControlEventTouchUpInside)];
		[self addSubview:_checkButton];
        
        _noticeWebView = [[HybridWKWebView alloc] initWithFrame:CGRectMake(0, 0, 310, 30)];
        [self addSubview:_noticeWebView];
        ((HybridWKWebView *)_noticeWebView).webViewDelegate = self;
        _noticeWebView.hidden = YES;
        ((HybridWKWebView *)_noticeWebView).parentNotice = YES;
	}
	return self;
}

-(BOOL)isChecked
{
	return _checkButton.selected;
}

-(void)setMessage:(NSString*)message
{
	if(message.length == 0)
	{
		_noticeWebView.hidden = NO;
		return;
	}
	if([message rangeOfString:@"http"].location == 0)
	{
			[(HybridWKWebView *)_noticeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:message] cachePolicy:(NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:30]];
		}
		else
		{
#ifdef DEBUG
//        message = [NSString stringWithFormat:@"%@<br/><br/><a href='liivmate://appid?param=https://dm.liivmate.com/katsv2/liivmate/v2/finacPrdct/story/storyMain.do'>링크테스트</a><br/>", message];
#endif
            message = [message stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            message = [message stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            message = [message stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            message = [message stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            message = [message stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
            
			[(HybridWKWebView *)_noticeWebView loadHTMLString:message baseURL:nil];
		}
}

- (void)webView:(id)webView didFailLoadWithError:(NSError *)error;
{
	__block CGRect rect = _noticeWebView.frame;
	if ([_noticeWebView isKindOfClass:[HybridWKWebView class]])
	{
		[(HybridWKWebView *)_noticeWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;" completionHandler:^(NSString *result){
			NSString *offsetHeight = result;
			rect.size.height = offsetHeight.integerValue;
			self->_noticeWebView.frame = rect;
			self->_noticeWebView.hidden = NO;
		}];
	}
	else
	{
		NSString *offsetHeight = [(id)_noticeWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
		rect.size.height = offsetHeight.integerValue;
		self->_noticeWebView.frame = rect;
		self->_noticeWebView.hidden = NO;
	}
}

- (void)webViewDidFinishLoad:(id)webView
{
	__block CGRect rect = _noticeWebView.frame;
	if ([_noticeWebView isKindOfClass:[HybridWKWebView class]])
	{
		[(HybridWKWebView *)_noticeWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;" completionHandler:^(NSString *result){
			NSString *offsetHeight = result;
			rect.size.height = offsetHeight.integerValue;
			self->_noticeWebView.frame = rect;
			self->_noticeWebView.hidden = NO;
			[self setNeedsLayout];
		}];
	}
	else
	{
		NSString *offsetHeight = [(id)_noticeWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
		rect.size.height = offsetHeight.integerValue;
		_noticeWebView.frame = rect;
		_noticeWebView.hidden = NO;
		[self setNeedsLayout];
	}
}

- (BOOL)webView:(id)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(NSInteger)navigationType
{
      if ([webView isKindOfClass:[HybridWKWebView class]] && navigationType == WKNavigationTypeLinkActivated) {
        // 이동로직 내뷰 웹뷰로 이동하도록 변경 (하이브리드엑션을 다 지원하기엔 알럿형태라 콜백받는부분등 제약사항이 많음)
        // 그동안 이동정도만 문제가 되어 해당부분 지원(외부에서 앱 스킴호출하는 형태로 호출시(a링크 클릭시) 화면이동 - 안드로이드 이동되는 형식과 같은 방법으로 구현)
          
        // 메인에 떠있는 공지팝업 close
        [self alertViewCancelAnimated:YES];
        
        // 화면이동
        if(request.URL.runAction) {
            return NO;
        } else {
            
            // 링크가 httpS://~~로 시작할 경우, 사용할일 없을듯...안드로이드가 이기능은 안됨..
//            NSString * pageID = request.URL.absoluteString;
//            [[AllMenu delegate] sendBirdDetailPage:pageID callBack:^(ViewController *vc) {
//                if([pageID rangeOfString:@"?"].location != NSNotFound)
//                {//v2 POST파라미터 적용
//                    NSString *query = [pageID componentsSeparatedByString:@"?"].lastObject;
//                    vc.dicParam = [EtcUtil parseUrl:query];
//                }
//            }];
            
            if ([AppDelegate canOpenURL:request.URL]) {
                [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
            }
        }
        return NO;
    }

    return YES;
}

-(void)dealloc
{
	_noticeWebView = nil;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
}

-(BOOL)showOtherButton:(BOOL)other
{
	//Loop가 동작중일때는 WKWebView가 Load를 시작하지 않는 오류가 있어서 루프방식 변경
//	while(_noticeWebView.alpha != 1.0)
//	{
//		[[NSRunLoop currentRunLoop] acceptInputForMode:NSDefaultRunLoopMode beforeDate:[[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode]];
//	}
	if(_noticeWebView.hidden)
	{
		[self performSelector:@selector(show) withObject:nil afterDelay:0.01];
		return NO;
	}
	return [super showOtherButton:other];
}

-(void)onClickedCheckButton:(UIButton*)sender
{
	sender.selected = !sender.selected;
}

-(BOOL)isCustomizeAlert
{
	return YES;
}

-(void)customizeAlertView
{
	CGFloat width = 310;
	CGFloat space = 25;//간격 / 여백
	CGFloat height = 0;
	CGFloat objWidth = width-(space*2);
	CGFloat messageMaxH = [BlockAlertView customViewMaxSize].height - 45;
    CGRect rect;
    
    if(_backImageView == nil) // Alert Background 전체 뷰
    {
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_backImageView];
        _backImageView.image = nil;
        _backImageView.backgroundColor = RGBA(255, 255, 255, 1);
        _backImageView.layer.masksToBounds = YES;
        _backImageView.userInteractionEnabled = YES;
    }
    //백그라운드 커스터마이징
    
    if (isFullPopup) {
        
        rect = _noticeWebView.frame; // 공지내용
        rect.origin.y = height;
        rect.size.height = MAX(MIN(CGRectGetHeight(rect), messageMaxH-height), 250);
        _noticeWebView.frame = rect;
        [_backImageView addSubview:_noticeWebView];
        
        
    } else {
        if(_cancelButton)
                messageMaxH -= 44;
            
            
            
            
            //타이틀라벨 커스터마이징
            if(_titleLabel)
            {
                NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      _titleLabel.font, NSFontAttributeName,
                                                      _titleLabel.textColor, NSForegroundColorAttributeName,
                                                      nil];
                
                CGRect textRect = [_titleLabel.text boundingRectWithSize:CGSizeMake(objWidth-80, 10000)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin//NSStringDrawingUsesFontLeading
                                                              attributes:attributesDictionary
                                                                 context:nil];
                CGSize strSize = textRect.size;
                _titleLabel.frame = CGRectMake(0, height, width, MAX(strSize.height+5, 44));
                _titleLabel.textInsets = UIEdgeInsetsMake(0, 40, 0, 40);
                [_backImageView addSubview:_titleLabel];
                height = MAX(height, CGRectGetMaxY(_titleLabel.frame));
                messageMaxH -= 44;
            }
            
            rect = _noticeWebView.frame; // 공지내용
            rect.origin.y = height;
            rect.size.height = MAX(MIN(CGRectGetHeight(rect), messageMaxH-height), 250);
            _noticeWebView.frame = rect;
            [_backImageView addSubview:_noticeWebView];
            
            if(_closedButton)
            {
                _closedButton.frame = CGRectMake(width - 48, (_titleLabel ? CGRectGetMidY(_titleLabel.frame) - 19 : 5), 38, 38);
                [_backImageView addSubview:_closedButton];
            }
            
            if(_cancelButton)
            {
                rect = CGRectMake( 8, CGRectGetMaxY(rect), width - 16, 44);
                _cancelButton.frame = rect;
                _cancelButton.titleLabel.font = BOLDFONTSIZE(16);
                
                _cancelButton.clipsToBounds = YES;      // 공지팝업 버튼 디자인 가이드 적용
                _cancelButton.layer.cornerRadius = 5;   // 코너 둥글게 처리
        //        _cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 100, 0);
                
                [_cancelButton setBackgroundImage:[UIImage defultButtonImage] forState:(UIControlStateNormal)];
                [_cancelButton setTitleColor:UIColorFromRGB(0xffffff) forState:(UIControlStateNormal)];
                [_backImageView addSubview:_cancelButton];
                

            }
            else if(_titleLabel)
            {
                rect.size.height += 10;
            }
            
            
    }
	
	CGFloat buttonH = 30;
        
    height = CGRectGetMaxY(rect) + buttonH + 24;
    
    self.bounds = CGRectInset(self.bounds, (CGRectGetWidth(self.bounds)-width)/2, (CGRectGetHeight(self.bounds)-height)/2);
    _backImageView.layer.cornerRadius = 8;
//    _backImageView.frame = CGRectMake(0, 0, width, height);
//    NSLog(@"%@",NSStringFromCGRect(self.bounds));
    rect = self.bounds;
    rect.size.height -= (buttonH + (isFullPopup? 24 : 15));
    _backImageView.frame = rect;
	
    rect.origin.y = CGRectGetMaxY(rect) + 15;//+ (isFullPopup? 24 : 15);
	rect.size.width = 200;
	rect.origin.x += width - CGRectGetWidth(rect);
	rect.size.height = buttonH;
	_checkButton.frame = rect;
	[self addSubview:_checkButton];
	_checkButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 35);
	_checkButton.imageEdgeInsets = UIEdgeInsetsMake(0, 170, 0, 0);
	
//	self.layer.masksToBounds = NO;
//	self.layer.shadowOpacity = 0.5;
//	self.layer.shadowColor = [UIColor blackColor].CGColor;
//	self.layer.shadowOffset = CGSizeMake(2, 4);
}

@end

