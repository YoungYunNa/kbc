

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CornerRadiusView : UIView

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable BOOL highlighted;


- (void)setCornerRadiusValue:(CGFloat)cornerRadius;
- (void)setBorderWidthValue:(CGFloat)borderWidth;
- (void)setBorderColorValue:(UIColor *)borderColor;

- (void)sharedInit;

@end
