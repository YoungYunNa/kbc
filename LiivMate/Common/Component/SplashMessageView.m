//
//  SplashMessageView.mm
//  NewKBCardShop
//
//  Created by Lee SeungWoo on 13. 2. 26..
//

#import "SplashMessageView.h"

@implementation SplashMessageView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		
		self.image = [UIImage imageNamed:@"bg_Toastpopup.png" capWidthRatio:0.5 capHeightRatio:0.5];
		
		_labelMessage = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)];
		//_labelMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _labelMessage.textColor = UIColorFromRGB(0xffffff);
        _labelMessage.font = FONTSIZE(16);
        _labelMessage.backgroundColor = CLEARCOLOR;
        _labelMessage.textAlignment = NSTextAlignmentCenter;
		_labelMessage.numberOfLines = 0;
		_labelMessage.adjustsFontSizeToFitWidth = YES;
		_labelMessage.minimumScaleFactor = 0.5;
		[self addSubview:_labelMessage];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[self stopTimerForAutoHide];
}


- (void)showMessage:(UIView*)parentView message:(NSString*)message autohide:(BOOL)autohide withShowTop:(BOOL)showTop
{
	self.alpha = 0.0;
	[_labelMessage setText:message];
	
	if (self.superview)
		[self removeFromSuperview];
	int xPos = 20;
	CGFloat width = CGRectGetWidth(parentView.frame) - xPos * 2;
	CGFloat height = [message boundingRectWithSize:CGSizeMake(width-20, 1000)
									  options:NSStringDrawingUsesLineFragmentOrigin//NSStringDrawingUsesFontLeading
								   attributes:@{NSFontAttributeName:_labelMessage.font}
									  context:nil].size.height + 20;
	int bottom = 24;
	
	if (@available(iOS 11.0, *))
	{
		bottom += [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
	}
	self.frame =CGRectMake(xPos, CGRectGetHeight(parentView.frame) - bottom - height, width, height);
	_labelMessage.frame = CGRectInset(self.bounds, 10, 10);
	
	[parentView addSubview:self];
	[parentView bringSubviewToFront:self];
	
	[self stopTimerForAutoHide];
	[self performAnimationShow:autohide];
}

- (void)hideMessage
{
	[self stopTimerForAutoHide];// issue #5277. 아래쪽에서 호출하는 것을 위로 옮겨봄. 해결될지는 미지수.
	self.alpha = 0.0;
	
	//[self stopTimerForAutoHide];// issue #5277
	if (self.superview)
		[self removeFromSuperview];
}

- (void)performAnimationShow:(BOOL)autohide
{
	self.alpha = 0.0;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	float fDuration = 0.5f;
	[UIView setAnimationDuration:fDuration];
	[UIView setAnimationDelay:0];
	[UIView setAnimationDelegate:self];
	
	if (autohide)
	{
		[UIView setAnimationDidStopSelector:@selector(didStopAnimation:finished:context:)];
	}
	
	self.alpha = 1.0;
	
	[UIView commitAnimations];
	[self performSelector:@selector(runVoiceMessage) withObject:nil afterDelay:fDuration];
}

- (void)performAnimationHide:(NSTimer*)timer
{
	if ([_timerForAutoHide isValid])
		[_timerForAutoHide invalidate];
	_timerForAutoHide = nil;
		
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	float fDuration = 0.5f;
	[UIView setAnimationDuration:fDuration];
	[UIView setAnimationDelay:0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didEndAnimation:finished:context:)];
	
	self.alpha = 0.0;
	
	[UIView commitAnimations];
}

-(void)runVoiceMessage
{
	if(UIAccessibilityIsVoiceOverRunning())
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, _labelMessage.text);
}

- (void)didStopAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if (self.superview)
	{
		float fInterval = 3.0f;
		_timerForAutoHide = [NSTimer scheduledTimerWithTimeInterval:fInterval
															 target:self 
														   selector:@selector(performAnimationHide:) 
														   userInfo:nil 
															repeats:NO];
	}
}

- (void)didEndAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if (self.superview)
		[self removeFromSuperview];
}

- (void)stopTimerForAutoHide
{
	if (_timerForAutoHide)
	{
		if ([_timerForAutoHide isValid])
			[_timerForAutoHide invalidate];
		_timerForAutoHide = nil;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self hideMessage];
}

@end
