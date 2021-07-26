

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CornerRadiusButton : UIButton

@property (nonatomic) IBInspectable CGFloat contentInsetTop;
@property (nonatomic) IBInspectable CGFloat contentInsetLeft;
@property (nonatomic) IBInspectable CGFloat contentInsetBottom;
@property (nonatomic) IBInspectable CGFloat contentInsetRight;

@property (nonatomic) IBInspectable UIColor *backgroundNormal;
@property (nonatomic) IBInspectable UIColor *backgroundSelected;

@property (nonatomic) IBInspectable CGFloat cornerRadius;

@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable UIColor *borderColorSelected;

@end
