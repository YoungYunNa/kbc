

#import "CornerRadiusView.h"
IB_DESIGNABLE

@implementation CornerRadiusView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
#if !TARGET_INTERFACE_BUILDER
        [self sharedInit];
#endif
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#if !TARGET_INTERFACE_BUILDER
        [self sharedInit];
#endif
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
#if !TARGET_INTERFACE_BUILDER
    [self sharedInit];
#endif
}

- (void)prepareForInterfaceBuilder {
#if TARGET_INTERFACE_BUILDER
    [self sharedInit];
#endif
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
#if !TARGET_INTERFACE_BUILDER
    [self sharedInit];
#endif
}

- (void)sharedInit {
    [self setCornerRadiusValue:_cornerRadius];
    [self setBorderColorValue:_borderColor];
    [self setBorderWidthValue:_borderWidth];
}

- (void)setCornerRadiusValue:(CGFloat)cornerRadius {
    if(cornerRadius > 0.0) {
        self.clipsToBounds = YES;
    }
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderWidthValue:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColorValue:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}


@end
