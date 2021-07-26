//
//  BlockAlertView.h
//
//  Created by Oh seung yong on 13. 10. 18..
//  Copyright (c) 2013년 Lilac Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (Frame)
@property (nonatomic, readonly) CGRect frame;
@end

@interface IndicatorView : UIView
@property (nonatomic, copy) NSString *message;
+(void)setTimeout:(int)time;
+(void)showLaunchImage;
+(void)showMessage:(NSString*)message;
+(void)show;
+(void)hide;
@end

@interface UIImage (Capimage)
+(UIImage *)imageNamed:(NSString *)name capWidth:(CGFloat)width capHeight:(CGFloat)height;
+(UIImage *)imageNamed:(NSString *)name capWidthRatio:(CGFloat)wRatio capHeightRatio:(CGFloat)hRatio;
-(UIImage *)stretchableImageWithCapWidthRatio:(CGFloat)wRatio capHeightRatio:(CGFloat)hRatio;
+(UIImage *)imageWithStrData:(NSString*)strData scale:(CGFloat)scale;
+(NSArray*)splashLoadingImages;
+(UIImage*)screenCapture;
+(UIImage*)captureView:(UIView*)view;
+(UIImage *)imageWithColor:(UIColor *)color width:(CGFloat)widht height:(CGFloat)height;
+(UIImage *)imageWithColor:(UIColor *)color;
+(UIImage*)orderButtonImage;
+(UIImage*)defultButtonImage;
@end


typedef enum : NSUInteger {
	VerticalAlignmentCenter = 0,
	VerticalAlignmentTop,
	VerticalAlignmentBottom,
} VerticalAlignment;

@interface UILabel (TextSize)
-(CGSize)sizeWithMaxSize:(CGSize)maxSize;
@end

@interface EdgeLabel : UILabel
@property (nonatomic, assign) UIEdgeInsets textInsets;
@property (nonatomic, retain) UIImage *background;
@property (nonatomic, assign) VerticalAlignment verticalAlignment;
@end

@class BlockAlertView;

@interface UIView (ParentViewAlert)
- (BlockAlertView*)parentViewAlert;
@end

@protocol BlockAlertViewDelegate <UIAlertViewDelegate>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(BlockAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(BlockAlertView *)alertView;

- (void)willPresentAlertView:(BlockAlertView *)alertView;  // before animation and showing view
- (void)didPresentAlertView:(BlockAlertView *)alertView;  // after animation

- (void)alertView:(BlockAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(BlockAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(BlockAlertView *)alertView;

@end


typedef void (^DismissedCallback)(BlockAlertView *alertView, NSInteger buttonIndex);
typedef void (^WkCancleCallback)(void);
typedef void (^CustomizeCallback)(BlockAlertView *alertView);
typedef void (^SetButtonsCallback)(UIButton *button, NSInteger buttonIndex);

/*
 * Block Alert View
 */
@interface BlockAlertView : UIView <BlockAlertViewDelegate>
{
	NSMutableArray *_buttons;
	UIImageView *_backImageView;
	EdgeLabel *_titleLabel;
	UILabel *_messageLabel;
	UIScrollView *_messageScrollView;
	UITextView *_messageTextView;
	
	UIButton *_cancelButton;
	UIScrollView *_buttonScrollView;
	
	NSInteger _selectIndex;
	
	UIButton *_closedButton;
    
    WkCancleCallback _wkCancleCallback;
    
@private
	DismissedCallback _callback;
	SetButtonsCallback _setButtonCallBack;
}

@property(nonatomic,retain)UIView *customMessageView;
@property(nonatomic,assign)id owner;
@property(nonatomic,retain)NSString *defaultButtonNormalName;	//기본버튼 이미지이름
@property(nonatomic,retain)NSString *defaultButtonHighlightedName;
@property(nonatomic,retain)NSString *otherButtonNormalName;		//마지막버튼 이미지이름
@property(nonatomic,retain)NSString *otherButtonHighlightedName;

@property(nonatomic,assign) id /*<UIAlertViewDelegate>*/ delegate;    // weak reference
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) id message;   // secondary explanation text
@property(nonatomic,readonly,getter=isVisible) BOOL visible;
@property(nonatomic,readonly) NSInteger numberOfButtons;
@property(nonatomic) NSInteger cancelButtonIndex; // -1;
@property(nonatomic, assign) BOOL isShowClosedBtn;      // 타이틀 옆 닫기 버튼 보기
@property(nonatomic, assign) BOOL isFullCustomView;      // 전체 커스텀뷰
@property(nonatomic, assign) BOOL isTouchDisable;        // 외부 터치 닫기 처리끔
- (void)customizeAlertView;
- (void)setMaskAlert;
// adds a button with the title. returns the index (0 based) of where it was added. buttons are displayed in the order added except for the
// cancel button which will be positioned based on HI requirements. buttons cannot be customized.
- (UIButton *)setCancelButtonWithTitle:(NSString*)title;
- (NSInteger)addButtonWithTitle:(NSString *)title;    // returns index of button. 0 based.
- (NSInteger)addButton:(UIButton*)button;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (UIButton *)buttonWithTitle:(NSString*)buttonTitle;
- (UILabel *)messageLabel;

#if 0
+(BOOL)showBlockAlertCustomCallback:(CustomizeCallback)customCallback
				 setButtonsCallback:(SetButtonsCallback)setButtonsCallback
				  dismissedCallback:(DismissedCallback)callback;

+(BOOL)showBlockAlertCustomCallback:(CustomizeCallback)customCallback
				  dismissedCallback:(DismissedCallback)callback
					   buttonTitles:(NSString *)buttonTitles, ...NS_REQUIRES_NIL_TERMINATION;
#endif
+(BOOL)showBlockAlertCustomCallback:(CustomizeCallback)customCallback
				  dismissedCallback:(DismissedCallback)callback;

+(void)showMaskBlockAlertWithTitle:(NSString *)title
						   message:(id)message;

+(void)showBlockAlertWithTitle:(NSString*)title
					   message:(id)message
				   dismisTitle:(NSString*)dismisTitle;

+(NSInteger)blockAlertWithTitle:(NSString *)title
						message:(NSString *)message
			  cancelButtonTitle:(NSString *)cancelButtonTitle
				   buttonTitles:(NSString *)buttonTitles, ...NS_REQUIRES_NIL_TERMINATION;

+(BOOL)showBlockAlertWithTitle:(NSString *)title
					   message:(id)message
			 dismissedCallback:(DismissedCallback)callback
			 cancelButtonTitle:(NSString *)cancelButtonTitle
				  buttonTitles:(NSString *)buttonTitles, ...NS_REQUIRES_NIL_TERMINATION;

+(BOOL)showBlockAlertWithTitle:(NSString *)title
                       message:(NSString *)message
             dismissedCallback:(DismissedCallback)callback
              wkCancleCallback:(WkCancleCallback)wkCancleCallback
             cancelButtonTitle:(NSString *)cancelButtonTitle
                  buttonTitles:(NSString *)buttonTitles, ...NS_REQUIRES_NIL_TERMINATION;

+(BOOL)showBlockAlertWithTitle:(NSString *)title
              showClosedButton:(BOOL)isClosedBtnShow
                       message:(id)message
             dismissedCallback:(DismissedCallback)callback
             cancelButtonTitle:(NSString *)cancelButtonTitle
                  buttonTitles:(NSString *)buttonTitles, ...NS_REQUIRES_NIL_TERMINATION;



+(BOOL)showBlockAlertCustomView:(id)customView withTouchDisable:(BOOL)disable;
+(BOOL)showBlockAlertCustomView:(id)customView withTouchDisable:(BOOL)disable dismissedCallback:(DismissedCallback)callback;
+(BOOL)showBlockAlertCustomView:(id)customView withTouchDisable:(BOOL)disable showClosedButton:(BOOL)isClosedBtnShow  dismissedCallback:(DismissedCallback)callback;
+(BOOL)showBlockAlertCustomView:(id)customView showClosedButton:(BOOL)isClosedBtnShow withTouchDisable:(BOOL)disable;

- (id)initWithTitle:(NSString *)title
			message:(id)message
  dismissedCallback:(DismissedCallback)callback
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  dismissedCallback:(DismissedCallback)callback
   wkCancleCallback:(WkCancleCallback)wkCancleCallback
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;

- (id)initWithTitle:(NSString *)title
			message:(id)message
		   delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)setButtonCallBack:(SetButtonsCallback)callBack;
- (void)setDismissCallBack:(DismissedCallback)callBack;
- (BOOL)showOtherButton:(BOOL)other;
- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
- (void)alertViewCancelAnimated:(BOOL)animated;

+ (void)setCheckedOverlap:(BOOL)checkedOverlap;//중복얼랏뷰 체크여부..
+ (CGSize)customViewMaxSize;
+ (void)dismissAllAlertViews;//모든얼랏뷰 닫기..
+ (void)dismissCurrentAlert;//현재 보이는 얼랏뷰 닫기
+ (void)dismissCurrentAlertAnimated:(BOOL)animated;//현재 보이는 얼랏뷰 닫기
+ (void)dismisMaskAlert;
+ (void)dismisMaskAlertAnimated:(BOOL)animated;
+ (void)removeAlertWithOwner:(id)owner;
+ (BOOL)isAlert;
+ (BlockAlertView*)currentAlert;
+ (BlockAlertView*)alertViewWithTag:(NSInteger)tag;

+ (void)didReceiveMemoryWarning;

@end
