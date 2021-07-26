//
//  BlockAlertView.m
//
//  Created by Oh seung yong on 13. 10. 18..
//  Copyright (c) 2013년 Lilac Studio. All rights reserved.
//

#import "BlockAlertView.h"
#import <objc/runtime.h>
#import "TTTAttributedLabel.h"
#import "HybridWKWebView.h"
#import "SplashScreenManager.h"

#if __has_feature(objc_arc)
#define autorelease	__returSelf
#define retain		__returSelf
#define release		__returVoid
#define retainCount	__returInt

@interface NSObject (__objc_arc)
-(instancetype)__returSelf;
-(void)__returVoid;
-(NSInteger)__returInt;
@end

@implementation NSObject (__objc_arc)
-(instancetype)__returSelf{return self;}
-(void)__returVoid{}
-(NSInteger)__returInt{return 1;}
@end
#endif

#define releaseObj(obj) ([obj release], obj = nil)

#define maskAlertTag 9999
#define LOADING_ICON_COUNT 11

@implementation UIScreen (Frame)
-(CGRect)frame
{
	CGRect rect = self.bounds;
	rect.size = CGSizeMake(MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)), MAX(CGRectGetWidth(rect), CGRectGetHeight(rect)));
	return rect;
}
@end

@implementation UIImage (Capimage)

#if 0
+ (void)load
{
	[super load];
	Method m1 = class_getClassMethod(self, @selector(imageNamed:));
	Method m2 = class_getClassMethod(self, @selector(mk_imageNamed:));
	
	method_exchangeImplementations(m1, m2);
}

+(UIImage*)mk_imageNamed:(NSString*)named
{
	if(named == nil) return nil;
	UIImage *retImage = [UIImage mk_imageNamed:[@"Images.bundle/" stringByAppendingString:named]];
	if(retImage) return retImage;
	return [self mk_imageNamed:named];
}
#endif

+(UIImage *)imageNamed:(NSString *)name capWidth:(CGFloat)width capHeight:(CGFloat)height
{
	if((width < 1.0 && width != 0.0) || (height < 1.0 && height != 0.0))
		return [self imageNamed:name capWidthRatio:width capHeightRatio:height];
	UIImage *image = [UIImage imageNamed:name];
	return [image stretchableImageWithLeftCapWidth:width topCapHeight:height];
}


+(UIImage *)imageNamed:(NSString *)name capWidthRatio:(CGFloat)wRatio capHeightRatio:(CGFloat)hRatio
{
	UIImage *image = [UIImage imageNamed:name];
	return [image stretchableImageWithLeftCapWidth:image.size.width*wRatio topCapHeight:image.size.height*hRatio];
}

-(UIImage *)stretchableImageWithCapWidthRatio:(CGFloat)wRatio capHeightRatio:(CGFloat)hRatio
{
	return [self stretchableImageWithLeftCapWidth:self.size.width*wRatio topCapHeight:self.size.height*hRatio];
}

+(UIImage *)imageWithStrData:(NSString*)strData scale:(CGFloat)scale
{
	NSData *data = [[[NSData alloc] initWithBase64EncodedString:strData options:NSDataBase64DecodingIgnoreUnknownCharacters] autorelease];
	return [UIImage imageWithData:data scale:scale];
}

+ (UIImage*)screenCapture
{
	UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, 0.0);
	for(UIView *view in [UIApplication sharedApplication].windows)
	{
		if([NSStringFromClass(view.class) isEqualToString:@"AlertControlWindow"])
			view.alpha = 0.6;
		[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	}
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}

+ (UIImage*)captureView:(UIView*)view
{
	UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color width:(CGFloat)widht height:(CGFloat)height
{
	CGRect rect = CGRectMake(0.0f, 0.0f, widht, height);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

static UIImage *_orderBtImage = nil;
static UIImage *_defultBtImage = nil;
static NSMutableArray *_splashImages = nil;
+(NSArray*)splashLoadingImages
{
	if(_splashImages == nil)
	{
		_splashImages = [[NSMutableArray alloc] init];
		for(int i = 0; i < LOADING_ICON_COUNT; i++)
		{
			[_splashImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loading_icon%d.png",i+1]]];
		}
	}
	return _splashImages;
}

+(UIImage*)orderButtonImage
{
	if(_orderBtImage == nil)
	{
		_orderBtImage = [UIImage imageWithColor:UIColorFromRGB(0xEBEBEB)];
	}
	return _orderBtImage;
}

+(UIImage*)defultButtonImage
{
	if(_defultBtImage == nil)
	{
        _defultBtImage = [UIImage imageWithColor:COLOR_MAIN_PURPLE]; //UIColorFromRGB(0x8d9cfd)];
	}
	return _defultBtImage;
}

@end

@implementation UILabel (TextSize)
-(CGSize)sizeWithMaxSize:(CGSize)maxSize
{
	return [self.text boundingRectWithSize:maxSize
								   options:NSStringDrawingUsesLineFragmentOrigin//NSStringDrawingUsesFontLeading
								attributes:@{NSFontAttributeName:self.font}
								   context:nil].size;
}
@end

@implementation EdgeLabel
@synthesize textInsets;

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	/*
	if(self)
	{
		self.backgroundColor = [UIColor clearColor];
	}
	*/
	return self;
}

-(void)dealloc
{
	self.background = nil;
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
	CGRect r = bounds;
	const CGFloat wd = self.textInsets.left + self.textInsets.right;
	const CGFloat hd = self.textInsets.top + self.textInsets.bottom;
	r.size.width -= wd;
	r.size.height -= hd;
	r = [super textRectForBounds:r limitedToNumberOfLines:numberOfLines];
	r.size.width += wd;
	r.size.height += hd;
	return r;
}

-(void)drawTextInRect:(CGRect)rect
{
	UIEdgeInsets inset = textInsets;
	CGRect frame = UIEdgeInsetsInsetRect(rect, textInsets);
	
	if (_verticalAlignment == VerticalAlignmentTop)
	{
		CGRect textRect = [super textRectForBounds:frame limitedToNumberOfLines:self.numberOfLines];
		frame.size.height = CGRectGetHeight(textRect);
	}
	else if (_verticalAlignment == VerticalAlignmentBottom)
	{
		CGRect textRect = [super textRectForBounds:frame limitedToNumberOfLines:self.numberOfLines];
		frame.origin.y = CGRectGetHeight(self.bounds)-CGRectGetHeight(textRect)+inset.bottom;
	}
	
	if(frame.size.width > 0 && frame.size.height > 0)
	{
		rect = CGRectIntegral(frame);
	}
	[super drawTextInRect:rect];
}

-(void)drawRect:(CGRect)rect
{
	if(_background)
	{
		[_background drawInRect:self.bounds];
	}
	[super drawRect:rect];
}

-(void)setBackground:(UIImage *)background
{
	[_background release];
	_background = [background retain];
	if(_background)
		[self setNeedsDisplay];
}

@end

@interface BlockAlertView ()
{
}
@property (nonatomic, readonly, assign) UITextField *textField;
@property (nonatomic, readonly) BOOL isCustomizeAlert;
- (void)showPopupAnimated:(BOOL)animated;
- (void)dismissPopAnimated:(BOOL)animated dismiss:(BOOL)dismiss;
- (void)callWkCallback;
@end


@interface AlertContentView : UIView
{
	NSMutableArray *_waitingArray;
}
@property (nonatomic, readonly) BlockAlertView *currentAlert;
@property (nonatomic, readonly) NSArray *waitingArray;
@end

@interface AlertControlWindow : UIWindow
{
	AlertContentView *_messageAlert;
	AlertContentView *_messageViewAlert;
}
@property (nonatomic, readonly) NSArray *waitingArray;
-(BOOL)isVisible:(BlockAlertView*)alert;
-(void)dismissAllAlertViews;
-(void)dismissCurrentAlertAnimated:(BOOL)animated;
-(void)dismissMaskAlertAnimated:(BOOL)animated;
-(void)removeAlertWithOwner:(id)owner;

+ (void)show:(BlockAlertView*)alert;
+ (void)didDismiss:(BlockAlertView*)alert;
@end

@implementation IndicatorView
{
	UIImageView *_lodingIndicator;
	UILabel *_label;
	UIView *_launchImageView;
}
static IndicatorView *_indicatorView = nil;
static int timeOut = 61;
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		self.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.3);
		
		if ([UIImage splashLoadingImages]) {
			_lodingIndicator = [[UIImageView alloc] initWithImage:[UIImage splashLoadingImages].firstObject];
			[_lodingIndicator setIsAccessibilityElement:YES];
			[_lodingIndicator setAccessibilityLabel:@"로딩중"];
			[_lodingIndicator setAccessibilityTraits:(UIAccessibilityTraitNone)];
			_lodingIndicator.frame = CGRectMake(0, 0, 70, 70);
			[self addSubview:_lodingIndicator];
			[_lodingIndicator release];
			_lodingIndicator.animationImages = [UIImage splashLoadingImages];
			_lodingIndicator.animationDuration = 1.5;
            
            // splash 다운로드 완료 노티피케이션
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSplashImage) name:SplashImageDownloadNotification object:nil];
		}
		else
		{
			_lodingIndicator = (id)[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
			_lodingIndicator.frame = CGRectMake(0, 0, 30, 30);
			[self addSubview:_lodingIndicator];
			[_lodingIndicator release];
		}
		
		_label = [[UILabel alloc] initWithFrame:CGRectZero];
		_label.font = FONTSIZE(10);
		_label.textColor = UIColorFromRGB(0x616161);
		_label.textAlignment = NSTextAlignmentCenter;
		_label.backgroundColor = [UIColor clearColor];
		_label.numberOfLines = 0;
		[self addSubview:_label];
		[_label release];
		[[APP_DELEGATE window] setAccessibilityElementsHidden:YES];
	}
	self.frame = frame;
	return self;
}

// splash 다운로드 완료 노티피케이션
- (void)downloadSplashImage
{
    [_launchImageView removeFromSuperview];
    _launchImageView = nil;
}

-(void)removeFromSuperview
{
	[_lodingIndicator stopAnimating];
	[super removeFromSuperview];
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	if(_lodingIndicator.isAnimating == NO)
		[_lodingIndicator startAnimating];
	_lodingIndicator.frame = CGRectMake(CGRectGetWidth(self.bounds)/2-CGRectGetWidth(_lodingIndicator.frame)/2,
									  CGRectGetHeight(self.bounds)/2-CGRectGetHeight(_lodingIndicator.frame)/2,
									  CGRectGetWidth(_lodingIndicator.frame),
									  CGRectGetHeight(_lodingIndicator.frame));
	_label.frame = CGRectMake(0,
							  CGRectGetHeight(self.bounds)/2+31,
							  CGRectGetWidth(self.bounds),
							  15);
}

-(void)setMessage:(NSString *)message
{
	_label.text = nil;
	if([message isKindOfClass:[NSString class]])
	{
		if([message isEqualToString:@"showLaunchImage"])
		{
			if(_launchImageView == nil)
			{
                _launchImageView = [[[LaunchScreen alloc] init] getLaunchScreen];
				[self addSubview:_launchImageView];
			}
			_launchImageView.frame = [UIScreen mainScreen].bounds;
			return;
		}
		_label.text = message;
	}
	[_launchImageView removeFromSuperview];
	_launchImageView = nil;
}

-(NSString*)message
{
	return _label.text;
}

-(void)showMessage:(NSString*)message
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if(timeOut > 0)
		{
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
			[self performSelector:@selector(hide) withObject:nil afterDelay:timeOut];
		}
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[self->_lodingIndicator startAnimating];
		[AlertControlWindow show:(id)message];
	});
}

-(void)hide
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
		[AlertControlWindow didDismiss:nil];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	});
}

+(void)setTimeout:(int)time
{
	timeOut = time;
}

+(void)showLaunchImage
{
	[self showMessage:@"showLaunchImage"];
}

+(void)show
{
	[self showMessage:nil];
}

+(void)showMessage:(NSString*)message
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if(_indicatorView == nil)
		{
			_indicatorView = [[IndicatorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		}
		[_indicatorView showMessage:(id)message];
	});
}

+(void)hide
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_indicatorView hide];
	});
}

// splash 다운로드 완료 노티피케이션
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}
@end

@implementation AlertContentView
@synthesize waitingArray = _waitingArray;

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		_waitingArray = [[NSMutableArray alloc] init];
		self.backgroundColor = UIColorFromRGBWithAlpha(0x000000,0.6);
	}
	return self;
}

-(void)dealloc
{
	releaseObj(_waitingArray);
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

-(void)showPopupAlert
{
	if(_currentAlert != _waitingArray.lastObject)
	{
		if(_currentAlert != nil)
		{
			[_currentAlert dismissPopAnimated:YES dismiss:NO];
		}
		CGFloat stH = 0;
		if([UIApplication sharedApplication].statusBarHidden == NO)
			stH = MIN(CGRectGetWidth([UIApplication sharedApplication].statusBarFrame), CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
		_currentAlert = _waitingArray.lastObject;
		_currentAlert.center = CGPointMake(CGRectGetWidth(self.bounds)/2, (CGRectGetHeight(self.bounds)+stH)/2);
		
		[self addSubview:_currentAlert];
		[_currentAlert showPopupAnimated:YES];
	}
}

-(void)showAlert:(BlockAlertView*)alert
{
	[_waitingArray addObject:alert];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showPopupAlert) object:nil];
	[self performSelector:@selector(showPopupAlert) withObject:nil afterDelay:0.1];
}

-(void)removeAlert:(BlockAlertView*)alert
{
	[_waitingArray removeObject:alert];
	_currentAlert = nil;
}

-(BOOL)nextAlert
{
	if(_waitingArray.count == 0) return NO;
	[self showPopupAlert];
	return YES;
}

-(void)dismissAllAlertViews
{
    //
    for(BlockAlertView *alert in _waitingArray)
    {
        [alert callWkCallback];
    }
    
	[_waitingArray removeAllObjects];
	if(_currentAlert)
	{
		[_waitingArray addObject:_currentAlert];
		_currentAlert.delegate = nil;
		[_currentAlert alertViewCancelAnimated:YES];
	}
}

-(void)dismissMaskAlertAnimated:(BOOL)animated
{
	for(BlockAlertView *alert in _waitingArray)
	{
		if(alert.tag == maskAlertTag)
		{
			if(alert == _currentAlert)
			{
				_currentAlert.delegate = nil;
				[_currentAlert alertViewCancelAnimated:animated];
			}
			else
			{
				[_waitingArray removeObject:alert];
			}
		}
	}
}

-(void)dismissCurrentAlertAnimated:(BOOL)animated
{
	_currentAlert.delegate = nil;
	[_currentAlert alertViewCancelAnimated:animated];
}

-(void)removeAlertWithOwner:(id)owner
{
	for(BlockAlertView *alert in _waitingArray)
	{
		if(alert.owner == owner)
		{
			if(alert == _currentAlert)
			{
				_currentAlert.delegate = nil;
				[_currentAlert alertViewCancelAnimated:YES];
			}
			else
			{
				[_waitingArray removeObject:alert];
			}
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(_currentAlert
	   &&_currentAlert.tag != maskAlertTag
	   &&_currentAlert.numberOfButtons == 0
       &&_currentAlert.isTouchDisable != YES)
	{
		[_currentAlert dismissPopAnimated:YES dismiss:YES];
	}
}

@end

@interface AlertViewController : UIViewController;

@end

@implementation AlertViewController

-(void)loadView
{
	[super loadView];
	self.view.backgroundColor = [UIColor clearColor];
}

@end

@implementation AlertControlWindow
static AlertControlWindow *_alertControlView = nil;
static BOOL _didReceiveMemoryWarning = NO;

+(void)show:(BlockAlertView*)alert
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if(nil == _alertControlView)
		{
			_alertControlView = [[AlertControlWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
			_alertControlView.windowLevel = UIWindowLevelAlert - 1;
			[_alertControlView makeKeyAndVisible];
			_alertControlView.alpha = 0;
		}
		if([alert isKindOfClass:[BlockAlertView class]])
			[[APP_DELEGATE window] setAccessibilityElementsHidden:YES];
		[UIView animateWithDuration:0.1 animations:^{
			_alertControlView.alpha = 1;
		} completion:^(BOOL finished) {
			_alertControlView.alpha = 1;
		}];
		
		[_alertControlView showAlert:alert];
	});
}

+(void)didDismiss:(BlockAlertView*)alert
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_alertControlView removeAlert:alert];
		if(NO == [_alertControlView nextAlert])
		{
			UIWindow *removeWindow = _alertControlView;
			_alertControlView = nil;
			if([APP_DELEGATE window].accessibilityElementsHidden)
				[[APP_DELEGATE window] setAccessibilityElementsHidden:NO];
			[UIView animateWithDuration:0.1 animations:^{
				removeWindow.alpha = 0;
			} completion:^(BOOL finished) {
				[removeWindow removeFromSuperview];
				[removeWindow release];
                
                if( ![[APP_DELEGATE window] isKeyWindow] )
                {
                    [[APP_DELEGATE window] makeKeyAndVisible];
                }
			}];
		}
	});
}

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		AlertViewController *vc = [[AlertViewController alloc] init];
		self.rootViewController = vc;
		[vc release];
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

-(void)dealloc
{
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

-(void)showAlert:(BlockAlertView*)alert
{
	if([alert isKindOfClass:[BlockAlertView class]])
	{
		if(alert.isCustomizeAlert)
		{
			if(_messageViewAlert == nil)
			{
				_messageViewAlert = [[AlertContentView alloc] initWithFrame:self.bounds];
				[self addSubview:_messageViewAlert];
				[_messageViewAlert release];
				_messageViewAlert.alpha = 0;
				[UIView animateWithDuration:0.1 animations:^{
					self->_messageViewAlert.alpha = 1;
				}];
			}
			[_messageViewAlert showAlert:alert];
		}
		else
		{
			if(_messageAlert == nil)
			{
				_messageAlert = [[AlertContentView alloc] initWithFrame:self.bounds];
				[self addSubview:_messageAlert];
				[_messageAlert release];
				_messageAlert.alpha = 0;
				[UIView animateWithDuration:0.1 animations:^{
					self->_messageAlert.alpha = 1;
				}];
			}
			[_messageAlert showAlert:alert];
		}
	}
	else
	{
		_indicatorView.message = (id)alert;
		[self addSubview:_indicatorView];
	}
	[self bringSubviewToFront:_indicatorView];
	[self bringSubviewToFront:_messageAlert];
}

-(void)removeAlert:(BlockAlertView*)alert
{
	if([alert isKindOfClass:[BlockAlertView class]])
	{
		AlertContentView *_content = alert.isCustomizeAlert ? _messageViewAlert : _messageAlert;
		[_content removeAlert:alert];
		if([_content nextAlert] == NO)
		{
			[UIView animateWithDuration:0.1 animations:^{
				_content.alpha = 0;
			} completion:^(BOOL finished) {
				_content.alpha = 0;
				[_content removeFromSuperview];
			}];
			if(_content == _messageViewAlert)
				_messageViewAlert = nil;
			else
				_messageAlert = nil;
		}
	}
	else
	{
		[_indicatorView removeFromSuperview];
	}
}

-(BOOL)nextAlert
{
	return (_messageAlert || _messageViewAlert || _indicatorView.superview);
}

-(BOOL)isVisible:(BlockAlertView*)alert
{
	return (_messageViewAlert.currentAlert == alert || _messageAlert.currentAlert == alert);
}

-(NSArray*)waitingArray
{
	if(_messageViewAlert && _messageAlert)
	{
		NSMutableArray *array = [NSMutableArray array];
		[array addObjectsFromArray:_messageViewAlert.waitingArray];
		[array addObjectsFromArray:_messageAlert.waitingArray];
		return array;
	}
	else if(_messageViewAlert)
		return _messageViewAlert.waitingArray;
	else if(_messageAlert)
		return _messageAlert.waitingArray;
	return nil;
}

-(void)dismissAllAlertViews
{
	[_messageAlert dismissAllAlertViews];
	[_messageViewAlert dismissAllAlertViews];
}

-(void)dismissCurrentAlertAnimated:(BOOL)animated
{
	[_messageViewAlert dismissCurrentAlertAnimated:animated];
}

-(void)dismissMaskAlertAnimated:(BOOL)animated
{
	[_messageViewAlert dismissMaskAlertAnimated:animated];
}

-(void)removeAlertWithOwner:(id)owner
{
	[_messageAlert removeAlertWithOwner:owner];
	[_messageViewAlert removeAlertWithOwner:owner];
}

-(BlockAlertView*)currentAlert
{
	return _messageViewAlert.currentAlert;
}

@end

@implementation UIView (ParentViewAlert)

-(BlockAlertView*)parentViewAlert
{
	UIResponder *responder = self;
	while (![responder isKindOfClass:[BlockAlertView class]]) {
		responder = [responder nextResponder];
		if (nil == responder) {
			break;
		}
	}
	return (BlockAlertView *)responder;
}

@end

@implementation BlockAlertView
@synthesize delegate = _delegate;
@synthesize defaultButtonHighlightedName;
@synthesize defaultButtonNormalName;
@synthesize otherButtonHighlightedName;
@synthesize otherButtonNormalName;
@synthesize customMessageView;
@synthesize textField = _textField;
@synthesize owner;


static BOOL _checkedOverlap = YES;
+(BOOL)isAlert
{
	return _alertControlView != nil;
}

+(void)setCheckedOverlap:(BOOL)checkedOverlap
{
	_checkedOverlap = checkedOverlap;
}

+ (void)didReceiveMemoryWarning
{
	_didReceiveMemoryWarning = YES;
	releaseObj(_defultBtImage);
	releaseObj(_orderBtImage);
}

+(void)dismissAllAlertViews
{
	[_alertControlView dismissAllAlertViews];
}

+(void)dismissCurrentAlert
{
	[BlockAlertView dismissCurrentAlertAnimated:YES];
}

+ (void)dismissCurrentAlertAnimated:(BOOL)animated
{
	[_alertControlView dismissCurrentAlertAnimated:animated];
}

+(void)dismisMaskAlert
{
	[BlockAlertView dismisMaskAlertAnimated:YES];
}

+(void)dismisMaskAlertAnimated:(BOOL)animated
{
	[_alertControlView dismissMaskAlertAnimated:animated];
}

+(void)removeAlertWithOwner:(id)owner
{
	if(owner != nil)
	{
		[_alertControlView removeAlertWithOwner:owner];
	}
}

+ (BlockAlertView*)alertViewWithTag:(NSInteger)tag
{
	if(nil != _alertControlView)
	{
		for(BlockAlertView *alert in _alertControlView.waitingArray)
		{
			if(alert.tag == tag)
			{
				return alert;
			}
		}
	}
	return nil;
}

+ (BlockAlertView*)currentAlert
{
	return [_alertControlView currentAlert];
}

+(CGSize)customViewMaxSize
{
	CGRect rect = [UIApplication sharedApplication].keyWindow.bounds;
	if (@available(iOS 11.0, *))
	{
		rect = UIEdgeInsetsInsetRect(rect, [UIApplication sharedApplication].keyWindow.safeAreaInsets);
	}
	rect = CGRectInset(rect, 15, 16);
	return rect.size;
}

+(NSInteger)blockAlertWithTitle:(NSString *)title
						message:(NSString *)message
			  cancelButtonTitle:(NSString *)cancelButtonTitle
				   buttonTitles:(NSString *)buttonTitles, ...NS_REQUIRES_NIL_TERMINATION
{
	BlockAlertView *alert =  [[[self alloc] initWithTitle:title
															message:message
												  dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
													  alertView.tag = buttonIndex;
												  } cancelButtonTitle:cancelButtonTitle
												  otherButtonTitles: nil] autorelease];
	
	va_list args;
	va_start(args, buttonTitles);
	for (NSString *buttonTitle = buttonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString *))
	{
		[alert addButtonWithTitle:buttonTitle];
	}
	va_end(args);
	alert.tag = NSNotFound;
	
	if([alert showOtherButton:YES])
	{
		while(alert.tag == NSNotFound)
		{
			[[NSRunLoop currentRunLoop] acceptInputForMode:NSDefaultRunLoopMode beforeDate:[[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode]];
		}
	}
	return alert.tag;
}

+(void)showBlockAlertWithTitle:(NSString*)title
						  message:(NSString*)message
					  dismisTitle:(NSString*)dismisTitle
{
	[[[[self alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:dismisTitle otherButtonTitles: nil] autorelease] show];
}

+(BOOL)showBlockAlertWithTitle:(NSString *)title
					   message:(NSString *)message
			 dismissedCallback:(DismissedCallback)callback
			 cancelButtonTitle:(NSString *)cancelButtonTitle
				  buttonTitles:(NSString *)buttonTitles, ...
{
	BlockAlertView *alert =  [[[self alloc] initWithTitle:title message:message dismissedCallback:callback cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil] autorelease];
	
	va_list args;
	va_start(args, buttonTitles);
	for (NSString *buttonTitle = buttonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString *))
	{
		if([buttonTitle isKindOfClass:[NSArray class]])
		{
			for(NSString *title in (NSArray*)buttonTitle)
				[alert addButtonWithTitle:title];
		}
		else
			[alert addButtonWithTitle:buttonTitle];
	}
	va_end(args);
	
	return [alert showOtherButton:YES];
}

// wkwebview에서 띄운 알럿일경우 버튼을 누르지 않고 소스코드로 알럿창만 없애는 경우 후에 웹뷰가 dealloc될경우 앱이 죽음
+(BOOL)showBlockAlertWithTitle:(NSString *)title
                       message:(NSString *)message
             dismissedCallback:(DismissedCallback)callback
              wkCancleCallback:(WkCancleCallback)wkCancleCallback
             cancelButtonTitle:(NSString *)cancelButtonTitle
                  buttonTitles:(NSString *)buttonTitles, ...
{
    BlockAlertView *alert =  [[[self alloc] initWithTitle:title message:message dismissedCallback:callback wkCancleCallback:wkCancleCallback cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil] autorelease];
    
    va_list args;
    va_start(args, buttonTitles);
    for (NSString *buttonTitle = buttonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString *))
    {
        if([buttonTitle isKindOfClass:[NSArray class]])
        {
            for(NSString *title in (NSArray*)buttonTitle)
                [alert addButtonWithTitle:title];
        }
        else
            [alert addButtonWithTitle:buttonTitle];
    }
    va_end(args);
    
    return [alert showOtherButton:YES];
}

+(BOOL)showBlockAlertWithTitle:(NSString *)title
              showClosedButton:(BOOL)isClosedBtnShow
                       message:(id)message
             dismissedCallback:(DismissedCallback)callback
             cancelButtonTitle:(NSString *)cancelButtonTitle
                  buttonTitles:(NSString *)buttonTitles, ...
{
    BlockAlertView *alert =  [[[self alloc] initWithTitle:title message:message dismissedCallback:callback cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil] autorelease];
    alert.isShowClosedBtn = isClosedBtnShow;
    
    va_list args;
    va_start(args, buttonTitles);
    for (NSString *buttonTitle = buttonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString *))
    {
        if([buttonTitle isKindOfClass:[NSArray class]])
        {
            for(NSString *title in (NSArray*)buttonTitle)
                [alert addButtonWithTitle:title];
        }
        else
            [alert addButtonWithTitle:buttonTitle];
    }
    va_end(args);
    
    return [alert showOtherButton:YES];
}

+(BOOL)showBlockAlertCustomView:(id)customView withTouchDisable:(BOOL)disable
{
    BlockAlertView *alert =  [[[self alloc] initWithTitle:nil message:customView dismissedCallback:nil cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    alert.isShowClosedBtn = YES;
    alert.isFullCustomView = YES;
    alert.isTouchDisable = disable;
    
    return [alert showOtherButton:NO];
}

+(BOOL)showBlockAlertCustomView:(id)customView withTouchDisable:(BOOL)disable dismissedCallback:(DismissedCallback)callback
{
    BlockAlertView *alert =  [[[self alloc] initWithTitle:nil message:customView dismissedCallback:callback cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    alert.isShowClosedBtn = YES;
    alert.isFullCustomView = YES;
    alert.isTouchDisable = disable;
    
    return [alert showOtherButton:NO];
}

+(BOOL)showBlockAlertCustomView:(id)customView withTouchDisable:(BOOL)disable showClosedButton:(BOOL)isClosedBtnShow  dismissedCallback:(DismissedCallback)callback
{
    BlockAlertView *alert =  [[[self alloc] initWithTitle:nil message:customView dismissedCallback:callback cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    alert.isShowClosedBtn = isClosedBtnShow;
    alert.isFullCustomView = YES;
    alert.isTouchDisable = disable;
    
    return [alert showOtherButton:NO];
}

+(BOOL)showBlockAlertCustomView:(id)customView showClosedButton:(BOOL)isClosedBtnShow withTouchDisable:(BOOL)disable;
{
    BlockAlertView *alert =  [[[self alloc] initWithTitle:nil message:customView dismissedCallback:nil cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    alert.isShowClosedBtn = isClosedBtnShow;
    alert.isFullCustomView = YES;
    alert.isTouchDisable = disable;
    
    return [alert showOtherButton:NO];
}

+(BOOL)showBlockAlertCustomCallback:(CustomizeCallback)customCallback
				  dismissedCallback:(DismissedCallback)callback
{
	BlockAlertView *alert =  [[[self alloc] initWithTitle:nil message:nil dismissedCallback:callback cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
	customCallback(alert);
	return [alert showOtherButton:YES];
}

+(void)showMaskBlockAlertWithTitle:(NSString *)title
						   message:(NSString *)message
{
	BlockAlertView *alert =  [[[self alloc] initWithTitle:title message:message dismissedCallback:nil cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
	[alert setMaskAlert];
	[alert show];
}

- (id)initWithTitle:(NSString *)title
			message:(NSString *)message
  dismissedCallback:(DismissedCallback)callback
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
	
	if (self)
	{
		va_list args;
		va_start(args, otherButtonTitles);
		for (NSString *buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString *))
		{
			[self addButtonWithTitle:buttonTitle];
		}
		va_end(args);
#if __has_feature(objc_arc)
		_callback = callback;
#else
		_callback = [callback copy];
#endif
	}
	
	return self;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  dismissedCallback:(DismissedCallback)callback
   wkCancleCallback:(WkCancleCallback)wkCancleCallback
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    if (self)
    {
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString *))
        {
            [self addButtonWithTitle:buttonTitle];
        }
        va_end(args);
#if __has_feature(objc_arc)
        _callback = callback;
        _wkCancleCallback = wkCancleCallback;
#else
        _callback = [callback copy];
        _wkCancleCallback = [WkCancleCallback copy];
#endif
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	self = [self init];
	if(self)
	{
		_delegate = delegate;
		
		if(title)
			self.title = title;
		if(message)
			self.message = message;
		
		_selectIndex = 0;
		
		if(cancelButtonTitle)
			[self setCancelButtonWithTitle:cancelButtonTitle];
		
		if(_cancelButton)
		{
			_cancelButton.tag = _selectIndex;
			[self addSubview:_cancelButton];
		}
		
		
		va_list args;
		va_start(args, otherButtonTitles);
		for (NSString *buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString *))
		{
			[self addButtonWithTitle:buttonTitle];
		}
		va_end(args);
	}
	return self;
}

-(id)init
{
	self = [super init];
	if(self)
	{
		_buttons = [[NSMutableArray alloc] init];
		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
	}
	return self;
}

-(UIButton*)setCancelButtonWithTitle:(NSString*)title
{
	if(_cancelButton)
		[_cancelButton removeFromSuperview];
	_cancelButton = nil;
	if(title)
	{
		_cancelButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
		[_cancelButton setExclusiveTouch:YES];
		[_cancelButton setTitle:title forState:(UIControlStateNormal)];
		[_cancelButton addTarget:self action:@selector(alertViewCancel) forControlEvents:(UIControlEventTouchUpInside)];
		_cancelButton.tag = _selectIndex;
		[self addSubview:_cancelButton];
	}
	
	for(UIButton *button in _buttons)
	{
		button.tag = [_buttons indexOfObject:button] +(nil != _cancelButton);
	}
	return _cancelButton;
}

-(UIButton*)buttonWithTitle:(NSString*)buttonTitle
{
	if(nil == buttonTitle) return nil;
	if([[_cancelButton titleForState:(UIControlStateNormal)] isEqualToString:buttonTitle])
		return _cancelButton;
	
	for(UIButton *btn in _buttons)
	{
		if([[btn titleForState:(UIControlStateNormal)] isEqualToString:buttonTitle])
			return btn;
	}
	return nil;
}

-(NSInteger)addButtonWithTitle:(NSString*)buttonTitle
{
	if(nil == buttonTitle) return NSNotFound;
	UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
	[button setExclusiveTouch:YES];
	if([buttonTitle rangeOfString:@"\n"].location != NSNotFound)
		button.titleLabel.numberOfLines = 2;
	[button setTitle:buttonTitle forState:(UIControlStateNormal)];
	button.tag = _buttons.count+(nil != _cancelButton);
	[button addTarget:self action:@selector(alertViewClickedWithButtonIndex:) forControlEvents:(UIControlEventTouchUpInside)];
	[_buttons addObject:button];
	
	return [_buttons indexOfObject:button];
}

-(NSInteger)addButton:(UIButton*)button
{
	if(nil == button) return NSNotFound;
	button.tag = _buttons.count+(nil != _cancelButton);
	[button addTarget:self action:@selector(alertViewClickedWithButtonIndex:) forControlEvents:(UIControlEventTouchUpInside)];
	[_buttons addObject:button];
	
	return [_buttons indexOfObject:button];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
	NSMutableArray *buttonArray = [NSMutableArray arrayWithArray:_buttons];
	
	if(_cancelButton)
	{
		if(buttonIndex == self.cancelButtonIndex) return [_cancelButton titleForState:(UIControlStateNormal)];
		[buttonArray insertObject:_cancelButton atIndex:0];
	}
	
	if(buttonArray.count > buttonIndex && buttonIndex >= 0 && buttonArray.count != 0)
	{
		UIButton *button = [buttonArray objectAtIndex:buttonIndex];
		return [button titleForState:(UIControlStateNormal)];
	}
	return nil;
}

-(void)setIsShowClosedBtn:(BOOL)isShowClosedBtn
{
	_isShowClosedBtn = isShowClosedBtn;
	if(_isShowClosedBtn && _closedButton == nil)
	{
		_closedButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
		[_closedButton setExclusiveTouch:YES];
        [_closedButton setImage:[UIImage imageNamed:@"icoBlack"] forState:(UIControlStateNormal)]; // 이미지 변경 X 버튼 (시작시 이벤트 알림
		[_closedButton setAccessibilityLabel:@"닫기"];
		[_closedButton addTarget:self action:@selector(alertViewClosed) forControlEvents:(UIControlEventTouchUpInside)];
		[self addSubview:_closedButton];
	}
	else if(_isShowClosedBtn == NO)
	{
		[_closedButton removeFromSuperview];
		_closedButton = nil;
	}
}

- (UILabel *)messageLabel
{
	return _messageLabel;
}

- (void)callWkCallback
{
    if (_wkCancleCallback) {
        _wkCancleCallback();
        releaseObj(_wkCancleCallback);
        _wkCancleCallback = nil;
    }
}

- (void)dealloc
{
	releaseObj(_buttons);
	if(_setButtonCallBack)
		releaseObj(_setButtonCallBack);
	if(_callback)
        releaseObj(_callback);
    
    if(_wkCancleCallback) {
        releaseObj(_wkCancleCallback);
        _wkCancleCallback = nil;
    }
	
	self.defaultButtonHighlightedName = nil;
	self.defaultButtonNormalName = nil;
	self.otherButtonHighlightedName = nil;
	self.otherButtonNormalName = nil;
	self.customMessageView = nil;
	self.delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

-(void)customizeAlertView
{
	//alertView의 크기
	CGFloat width = 300;
	CGFloat space = 25;//간격 / 여백
	CGFloat height = _titleLabel ? 0 : 25;
	CGFloat objWidth = width-(space*2);
	CGFloat messageMaxH = [BlockAlertView customViewMaxSize].height;
	CGFloat titleH = 0;
	NSMutableArray *buttonArray = [NSMutableArray arrayWithArray:_buttons];
	
	if(_cancelButton)
	{
		if(_buttons.count < 2)
			[buttonArray insertObject:_cancelButton atIndex:0];
		else
			[buttonArray addObject:_cancelButton];
	}
	
	if(buttonArray.count > 2 && _setButtonCallBack == nil)
	{
		messageMaxH -= 10*(_cancelButton!=nil)+(buttonArray.count-1)*40;
	}
	
	
	if(customMessageView)
	{
		if([customMessageView isKindOfClass:[UILabel class]])
		{
			objWidth = [BlockAlertView customViewMaxSize].width-space*2;
			width = [BlockAlertView customViewMaxSize].width;
			_messageLabel = (id)customMessageView;
		}
		else
		{
			objWidth = MIN(MAX(CGRectGetWidth(customMessageView.bounds),150),[BlockAlertView customViewMaxSize].width);
			width = objWidth;
		}
	}
	
	if(_backImageView == nil)
	{
		_backImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self addSubview:_backImageView];
		[_backImageView release];
		_backImageView.image = nil;
		_backImageView.backgroundColor = UIColorFromRGB(0xffffff);
		_backImageView.layer.masksToBounds = YES;
		_backImageView.userInteractionEnabled = YES;
	}
	//백그라운드 커스터마이징
	
	
	//타이틀라벨 커스터마이징
	if(_titleLabel)
	{
		NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
											  _titleLabel.font, NSFontAttributeName,
											  _titleLabel.textColor, NSForegroundColorAttributeName,
											  nil];
		
		CGRect textRect = [_titleLabel.text boundingRectWithSize:CGSizeMake(objWidth, 10000)
														 options:NSStringDrawingUsesLineFragmentOrigin//NSStringDrawingUsesFontLeading
													  attributes:attributesDictionary
														 context:nil];
		CGSize strSize = textRect.size;
		_titleLabel.frame = CGRectMake(0, height, width, MAX(strSize.height, 44));
		[_backImageView addSubview:_titleLabel];
		height = MAX(height, CGRectGetMaxY(_titleLabel.frame)+space);
		titleH = height;
	}
	
	if(customMessageView&&customMessageView != _messageLabel)
	{
		if(_titleLabel)
			height -= space - 5;
		else
			height = 5;
        
        if (self.isFullCustomView == YES) {
            height = 0;
        }
        
        if (self.isShowClosedBtn == YES) {
            height -= 5;
        }
		
		customMessageView.frame = CGRectMake((width-objWidth)/2,
											 height,
											 MIN(CGRectGetWidth(customMessageView.frame),objWidth),
											 MIN(CGRectGetHeight(customMessageView.frame),messageMaxH-height-space));
		
		[_backImageView addSubview:customMessageView];
		height = MAX(height, CGRectGetMaxY(customMessageView.frame));
	}
	else if (_messageLabel)
	{
		CGFloat minimumH = 50;//메시지영역의 최소높이
		
		if(_messageLabel != customMessageView)
		{
//			_messageLabel.textColor = UIColorFromRGB(0x666666);
//			_messageLabel.font = FONTSIZE(16);
			
//			if(_messageLabel.text.length >= 100)
//				_messageLabel.textAlignment = NSTextAlignmentLeft;
//			else
//				_messageLabel.textAlignment = NSTextAlignmentCenter;
		}
		
		NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
											  _messageLabel.font, NSFontAttributeName,
											  _messageLabel.textColor, NSForegroundColorAttributeName,
											  nil];
		
		CGRect textRect = [_messageLabel.text boundingRectWithSize:CGSizeMake(objWidth, 10000)
														   options:NSStringDrawingUsesLineFragmentOrigin//NSStringDrawingUsesFontLeading
														attributes:attributesDictionary
														   context:nil];
		
		CGSize textSize = textRect.size;
		if([_messageLabel isKindOfClass:[TTTAttributedLabel class]])
		{
			CGFloat lineHeightMultiple = [(TTTAttributedLabel*)_messageLabel lineHeightMultiple];
			int labelHeight = textSize.height * 1.1;
			if(lineHeightMultiple != 0.0)
				labelHeight = labelHeight * lineHeightMultiple;
			textSize.height = labelHeight;
		}
		
		CGFloat plusH = 0;//(textSize.height*0.1)*([_messageLabel isKindOfClass:NSClassFromString(@"TTTAttributedLabel")]);
		
		_messageLabel.frame = CGRectMake(space,
										 height,
										 objWidth,
										 MAX(textSize.height+plusH+space/2, minimumH));
		[_backImageView addSubview:_messageLabel];
		
		height = (int)MAX(height, CGRectGetMaxY(_messageLabel.frame)+space);
	}
    
    if (self.isShowClosedBtn)
	{
		_closedButton.frame = CGRectMake(width - 48, (_titleLabel ? CGRectGetMidY(_titleLabel.frame) - 19 : 5), 38, 38);
        [_backImageView addSubview:_closedButton];
    }
	
	UIView *messageView = customMessageView;
	if(nil == messageView)
		messageView = _messageLabel;
	
	if(messageView)
	{
		if((messageView == _messageLabel && height > messageMaxH)
		   ||(messageView == customMessageView && height > messageMaxH))
		{
			
			CGRect messageRect = messageView.frame;
			messageRect.size.height = MIN(height, messageMaxH)-titleH;
			
			if([messageView isKindOfClass:[UIScrollView class]] == NO)
			{
				if(nil == _messageScrollView)
				{
					_messageScrollView = [[UIScrollView alloc] initWithFrame:messageRect];
					[_backImageView addSubview:_messageScrollView];
					[_messageScrollView release];
				}
				else
				{
					_messageScrollView.frame = messageRect;
				}
				messageView.frame = messageView.bounds;
				_messageScrollView.contentSize = messageView.frame.size;
				[_messageScrollView addSubview:messageView];
				[_messageScrollView flashScrollIndicators];
				height = CGRectGetMaxY(_messageScrollView.frame);
			}
			else
			{
				messageView.frame = messageRect;
				height = CGRectGetMaxY(messageRect);
			}
		}
		else
		{
			if(_messageScrollView)
			{
				[_messageScrollView removeFromSuperview];
				_messageScrollView = nil;
			}
		}
	}
	
	
	
	BOOL makeOtherButton = NO;
	//버튼들 커스터마이징
	for(UIButton *button in buttonArray)
	{
		button.titleLabel.shadowOffset = CGSizeZero;
		button.titleLabel.adjustsFontSizeToFitWidth = YES;
		button.titleLabel.font = FONTSIZE(16);
		UIImage *imageN = nil;
		//UIImage *imageH = nil;
		if(makeOtherButton == NO
//		   && (button == buttonArray.lastObject || button == _cancelButton) && buttonArray.count != 1)
			&& (button == buttonArray.lastObject))
		{//confirm
			button.titleLabel.font = BOLDFONTSIZE(16);
			imageN = [UIImage defultButtonImage];//[UIImage imageNamed:otherButtonNormalName];
			if(imageN)
			{
				//imageH = [UIImage imageNamed:otherButtonHighlightedName];
				[button setTitleColor:UIColorFromRGB(0xffffff) forState:(UIControlStateNormal)];
			}
			else
			{
				imageN = [UIImage defultButtonImage];
				[button setTitleColor:UIColorFromRGB(0xffffff) forState:(UIControlStateNormal)];
			}
			makeOtherButton = YES;
		}
		else
		{//cancel
			imageN = [UIImage orderButtonImage];//[UIImage imageNamed:defaultButtonNormalName];
			if(imageN)
			{
				//imageH = [UIImage imageNamed:defaultButtonHighlightedName];
				[button setTitleColor:UIColorFromRGB(0x666666) forState:(UIControlStateNormal)];
			}
			else
			{
				imageN = [UIImage orderButtonImage];
				[button setTitleColor:UIColorFromRGB(0x666666) forState:(UIControlStateNormal)];
			}
		}
		
		if(imageN)
		{
			[button setBackgroundImage:imageN forState:UIControlStateNormal];
			//[button setBackgroundImage:imageH forState:UIControlStateHighlighted];
		}
		
		switch (buttonArray.count)
		{
			case 0:break;
			case 1:
			{
				CGSize size = CGSizeMake(width, 44);
				button.frame = CGRectMake(0, height, size.width, size.height);
				
				height = MAX(height, CGRectGetMaxY(button.frame));
				[_backImageView addSubview:button];
				
				if(_setButtonCallBack)
					_setButtonCallBack(button,[buttonArray indexOfObject:button]);
			}
				break;
				
			case 2:
			{
				BOOL leftButton = button == [buttonArray objectAtIndex:0];
				CGSize size = CGSizeMake(width/2, 44);
				CGFloat y = leftButton ? height : [[buttonArray objectAtIndex:0] frame].origin.y;
				CGFloat x = leftButton ? 0 : width/2;
				button.frame = CGRectMake(x, y, size.width, size.height);
				
				height = MAX(height, CGRectGetMaxY(button.frame));
				[_backImageView addSubview:button];
				
				if(_setButtonCallBack)
					_setButtonCallBack(button,[buttonArray indexOfObject:button]);
			}
				break;
				
			default:
			{
				if(_setButtonCallBack)
				{
					NSInteger index = [buttonArray indexOfObject:button];
					CGSize size = CGSizeMake(width/buttonArray.count, 45);
					CGFloat y = index == 0 ? height : [[buttonArray objectAtIndex:0] frame].origin.y;
					CGFloat x = size.width * index;
					button.frame = CGRectMake(x, y, size.width, size.height);
					_setButtonCallBack(button,index);
					[_backImageView addSubview:button];
					height = MAX(height, CGRectGetMaxY(button.frame));
					break;
				}
				
				if(_buttonScrollView == nil)
				{
					_buttonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
																					   height,
																					   width,
																					   0)];
					[_backImageView addSubview:_buttonScrollView];
					[_buttonScrollView release];
					height = 0;
				}
				
				
				if(button != _cancelButton)
				{
					[_buttonScrollView addSubview:button];
					button.frame = CGRectMake(space,
											  height,
											  width-space*2,
											  35);
					height = CGRectGetMaxY(button.frame)+5;
					_buttonScrollView.contentSize = CGSizeMake(width,height);
					
					_buttonScrollView.frame = CGRectMake(0,
														 CGRectGetMinY(_buttonScrollView.frame),
														 width,
														 MIN(IPHONE_H(400, 300), CGRectGetMaxY(button.frame)));
				}
				else
				{
					button.frame = CGRectMake(0,
											  CGRectGetMaxY(_buttonScrollView.frame)+space-5,
											  width,
											  44);
					[_backImageView addSubview:button];
					height = CGRectGetMaxY(button.frame);
				}
			}
				break;
		}
	}
	
	self.bounds = CGRectInset(self.bounds, (CGRectGetWidth(self.bounds)-width)/2, (CGRectGetHeight(self.bounds)-height)/2);
	_backImageView.frame = self.bounds;
	_backImageView.layer.cornerRadius = 8;
	
	self.layer.masksToBounds = NO;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOffset = CGSizeMake(2, 4);
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	[self customizeAlertView];
}

-(BOOL)showOtherButton:(BOOL)other
{
	//이미 똑같은 얼랏창이 떠있다면 보여주지 않는다.
	if(_checkedOverlap)
	{
		for(BlockAlertView *alert in _alertControlView.waitingArray)
		{
			if ([alert.title isEqualToString:self.title]	//타이틀, 메시지, 버튼수가 같으면 같은 얼랏창이라고 여김
				&& [alert.message isEqualToString:self.message]
				&& alert.numberOfButtons == self.numberOfButtons
				&& self.isCustomizeAlert == NO)
			{
				return NO;
			}
		}
	}
#if 1
	if(nil == defaultButtonNormalName)
	{
//		self.defaultButtonNormalName = @"btn_cancel_bg.png";
	}
	
	if(NO == other)
	{
		self.otherButtonNormalName = nil;
		self.otherButtonHighlightedName = nil;
	}
	else
	{
		if(nil == otherButtonNormalName)
		{
//			self.otherButtonNormalName = @"btn_confirm_bg.png";
		}
	}
#endif
	[AlertControlWindow show:self];
	return YES;
}

-(void)show
{
	[self showOtherButton:YES];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
	_selectIndex = buttonIndex;
	if([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
	{
		[_delegate alertView:(id)self clickedButtonAtIndex:_selectIndex];
	}
	[self dismissPopAnimated:animated dismiss:YES];
}

- (void)setMaskAlert
{
	self.tag = maskAlertTag;
}

#pragma mark - delegate

- (void)alertViewClickedWithButtonIndex:(UIButton*)selectButton
{
	_selectIndex = selectButton.tag;
	if([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
	{
		[_delegate alertView:(id)self clickedButtonAtIndex:_selectIndex];
	}
	[self dismissPopAnimated:YES dismiss:YES];
}

//켄슬버튼 액션.
- (void)alertViewCancel
{
	[self alertViewClickedWithButtonIndex:_cancelButton];
}

- (void)alertViewClosed
{
    _selectIndex = -2;
    [self dismissPopAnimated:YES dismiss:YES];
}


- (void)alertViewCancelAnimated:(BOOL)animated
{
	_selectIndex = -1;//self.cancelButtonIndex;
	if([_delegate respondsToSelector:@selector(alertViewCancel:)])
	{
		[_delegate alertViewCancel:(id)self];
	}
    
    [self dismissPopAnimated:_wkCancleCallback?NO:animated dismiss:YES];
}

- (void)willPresentAlertView
{
	if([_delegate respondsToSelector:@selector(willPresentAlertView:)])
	{
		[_delegate willPresentAlertView:(id)self];
	}
}
- (void)didPresentAlertView
{
	if([_delegate respondsToSelector:@selector(didPresentAlertView:)])
	{
		[_delegate didPresentAlertView:(id)self];
	}
}

- (void)alertViewWillDismiss
{
	if([_delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
	{
		[_delegate alertView:(id)self willDismissWithButtonIndex:_selectIndex];
	}
}
- (void)alertViewDidDismiss
{
	if([_delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
	{
		[_delegate alertView:(id)self didDismissWithButtonIndex:_selectIndex];
	}
}

- (void)alertView:(BlockAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if(self->_callback)
			self->_callback(self, buttonIndex);
	});
}

#pragma mark - setter&getter

-(BOOL)isCustomizeAlert
{
	return (customMessageView != nil || self.tag == maskAlertTag);
}

-(BOOL)isVisible
{
	return [_alertControlView isVisible:self];
}

-(NSInteger)numberOfButtons
{
	return _buttons.count+(_cancelButton != nil);
}

-(void)setCancelButtonIndex:(NSInteger)cancelButtonIndex
{
	_cancelButton.tag = cancelButtonIndex;
}

-(NSInteger)cancelButtonIndex
{
	if(_cancelButton)
		return _cancelButton.tag;
	else
		return NSNotFound;
}

-(void)setTitle:(NSString *)title
{
	if(title.length == 0)
	{
		if(_titleLabel)
		{
			[_titleLabel removeFromSuperview];
			_titleLabel = nil;
		}
		return;
	}
	if(nil == _titleLabel)
	{
		_titleLabel = [[EdgeLabel alloc] initWithFrame:CGRectZero];
		_titleLabel.textInsets = UIEdgeInsetsMake(0, 10, 0, 10);
		_titleLabel.adjustsFontSizeToFitWidth = YES;
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.numberOfLines = 0;
		_titleLabel.textColor = UIColorFromRGB(0x000000);
		_titleLabel.font = BOLDFONTSIZE(16);
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_titleLabel];
		[_titleLabel release];
		
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, -1, 0, 1)];
		line.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
		line.backgroundColor = UIColorFromRGB(0xdddddd);
		[_titleLabel addSubview:line];
		[line release];
	}
	_titleLabel.text = title;
}

-(NSString *)title
{
	if(_titleLabel)
		return _titleLabel.text;
	return nil;
}

-(void)checkedTextField
{
	for(UIView *view in customMessageView.subviews)
	{
		if([view isKindOfClass:[UITextField class]])
		{
			_textField = (id)view;
			break;
        } else if ([view isKindOfClass:[UITextView class]]){
            if (((UITextView*)view).editable == YES){
                _messageTextView = (id)view;
            }
        }
	}
}

-(void)setMessage:(NSString *)message
{
	if([message isKindOfClass:[UIView class]])
	{
		self.customMessageView = (id)message;
		[self checkedTextField];
	}
	else if([message isKindOfClass:[NSString class]])
	{
		if(nil == _messageLabel)
		{
			_messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			_messageLabel.backgroundColor = [UIColor clearColor];
			_messageLabel.textAlignment = NSTextAlignmentCenter;
			_messageLabel.numberOfLines = 0;
			_messageLabel.textColor = UIColorFromRGB(0x666666);
			_messageLabel.font = FONTSIZE(16);
			[self addSubview:_messageLabel];
			[_messageLabel release];
		}
		_messageLabel.text = message;
	}
	else
	{
		if(_messageLabel)
		{
			[_messageLabel removeFromSuperview];
			_messageLabel = nil;
		}
	}
}

-(void)setCustomMessageView:(UIView *)_customMessageView
{
	[customMessageView removeFromSuperview];
	customMessageView = _customMessageView;
	[self addSubview:customMessageView];
}

-(NSString*)message
{
	if(_messageLabel)
		return _messageLabel.text;
	return nil;
}

-(void)setButtonCallBack:(SetButtonsCallback)callBack
{
#if __has_feature(objc_arc)
	_setButtonCallBack = callBack;
#else
	_setButtonCallBack = [callBack copy];
#endif
}

- (void)setDismissCallBack:(DismissedCallback)callBack
{
#if __has_feature(objc_arc)
	_callback = callBack;
#else
	_callback = [callBack copy];
#endif
}

#pragma mark - ani

- (void)showPopupAnimated:(BOOL)animated
{
	if(_didReceiveMemoryWarning)
	{
		animated = NO;
	}
	
	self.transform = CGAffineTransformMakeScale(1.15, 1.15);
	self.alpha = 0.0;
	self.userInteractionEnabled = NO;
	[self willPresentAlertView];
	
	if(_textField)
	{
		self.transform = CGAffineTransformTranslate(self.transform, 0, -100);
		[_textField becomeFirstResponder];
	}
    if(_messageTextView)
    {
        self.transform = CGAffineTransformTranslate(self.transform, 0, -100);
        [_messageTextView becomeFirstResponder];
    }
	
	[UIView animateWithDuration:0.15*animated animations:^{
		self.transform = CGAffineTransformMakeScale(1.005, 1.005);
		if(self->_textField || self->_messageTextView)
			self.transform = CGAffineTransformTranslate(self.transform, 0, -100);
		self.alpha = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.3*animated animations:^{
			self.transform = CGAffineTransformMakeScale(1.0, 1.0);
			if(self->_textField || self->_messageTextView)
				self.transform = CGAffineTransformTranslate(self.transform, 0, -100);
		} completion:^(BOOL finished) {
			if(self->customMessageView)
				[self->customMessageView selectView];
			self.userInteractionEnabled = YES;
			[self didPresentAlertView];
			if(self->_textField || self->_messageTextView)
				[self addTextFieldNotification];
		}];
	}];
}

- (void)dismissPopAnimated:(BOOL)animated dismiss:(BOOL)dismiss
{
	self.userInteractionEnabled = NO;
	if(dismiss)
		[self alertViewWillDismiss];
	if(_textField)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[_textField resignFirstResponder];
	}
    
    if(_messageTextView)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_messageTextView resignFirstResponder];
    }
	
	if(_didReceiveMemoryWarning)
	{
		animated = NO;
	}
	
	[UIView animateWithDuration:0.2*animated animations:^{//0.2
		self.transform = CGAffineTransformMakeScale(0.8, 0.8);//(0.9, 0.9);
		self.alpha = 0.0;
	} completion:^(BOOL finished) {
		if(dismiss)
		{
			if(self->customMessageView)
				[self->customMessageView deSelectView];
			
			[AlertControlWindow didDismiss:self];
			[self alertViewDidDismiss];
		}
		[self removeFromSuperview];
	}];
}

-(void)addTextFieldNotification
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTxteFieldEditingNoti:) name:UITextFieldTextDidBeginEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTxteFieldEditingNoti:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTxteFieldEditingNoti:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTxteFieldEditingNoti:) name:UITextViewTextDidEndEditingNotification object:nil];
}

-(void)changeTxteFieldEditingNoti:(NSNotification*)noti
{
	if(noti.object == _textField || noti.object == _messageTextView)
	{
		[UIView animateWithDuration:0.3 animations:^{
            if (noti.object == self->_textField) {
                self.transform = CGAffineTransformMakeTranslation(0, (self->_textField.isFirstResponder ? -100 : 0));
            } else {
                self.transform = CGAffineTransformMakeTranslation(0, (self->_messageTextView.isFirstResponder ? -100 : 0));
            }
		}];
	}
}

@end
