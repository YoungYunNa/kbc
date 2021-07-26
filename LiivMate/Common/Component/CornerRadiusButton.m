

#import "CornerRadiusButton.h"
IB_DESIGNABLE

@implementation CornerRadiusButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
#if !TARGET_INTERFACE_BUILDER
        [self setDefault];
#endif
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#if !TARGET_INTERFACE_BUILDER
        [self setDefault];
#endif
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
#if !TARGET_INTERFACE_BUILDER
    [self setDefault];
#endif
}

- (void)prepareForInterfaceBuilder {
    [self setDefault];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
#if !TARGET_INTERFACE_BUILDER
    [self setDefault];
#endif
}

#pragma mark - setter

- (void)setDefault {
    [self setContentInsetTopValue:_contentInsetTop];
    [self setContentInsetLeftValue:_contentInsetLeft];
    [self setContentInsetBottomValue:_contentInsetBottom];
    [self setContentInsetRightValue:_contentInsetRight];
    [self setCornerRadiusValue:_cornerRadius];
    [self setBorderWidthValue:_borderWidth];
    if(_borderColor && !self.isSelected)[self setBorderColorValue:_borderColor];
    if(_borderColorSelected && self.isSelected)[self setBorderColorSelectedValue:_borderColorSelected];
    if(_backgroundNormal && !self.isSelected)[self setBackgroundNormalValue:_backgroundNormal];
    if(_backgroundSelected && self.isSelected)[self setBackgroundSelectedValue:_backgroundSelected];
}

- (CGSize)intrinsicContentSize {
//    [self setContentInsetTopValue:_contentInsetTop];
//    [self setContentInsetLeftValue:_contentInsetLeft];
//    [self setContentInsetBottomValue:_contentInsetBottom];
//    [self setContentInsetRightValue:_contentInsetRight];
    CGSize size = [super intrinsicContentSize];
    size.width += _contentInsetLeft + _contentInsetRight;
    size.height += _contentInsetTop + _contentInsetBottom;
    return size;
}

- (void)setContentInsetTopValue:(CGFloat)contentInsetTop {
    UIEdgeInsets inset = self.contentEdgeInsets;
    inset.left = contentInsetTop;
    self.contentEdgeInsets = inset;
    _contentInsetTop = contentInsetTop;
}

- (void)setContentInsetLeftValue:(CGFloat)contentInsetLeft {
    UIEdgeInsets inset = self.contentEdgeInsets;
    inset.left = contentInsetLeft + (_borderWidth * 2);
    self.contentEdgeInsets = inset;
    _contentInsetLeft = contentInsetLeft;
}

- (void)setContentInsetBottomValue:(CGFloat)contentInsetBottom {
    UIEdgeInsets inset = self.contentEdgeInsets;
    inset.left = contentInsetBottom;
    self.contentEdgeInsets = inset;
    _contentInsetBottom = contentInsetBottom;
}

- (void)setContentInsetRightValue:(CGFloat)contentInsetRight {
    UIEdgeInsets inset = self.contentEdgeInsets;
    inset.right = contentInsetRight;
    self.contentEdgeInsets = inset;
    _contentInsetRight = contentInsetRight;
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
    if(!self.isSelected)self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderColorSelectedValue:(UIColor *)borderColorSelected {
    if(self.isSelected)self.layer.borderColor = borderColorSelected.CGColor;
}

- (void)setBackgroundNormalValue:(UIColor *)backgroundNormal {
    if(!self.isSelected)self.backgroundColor = backgroundNormal;
}

- (void)setBackgroundSelectedValue:(UIColor *)backgroundSelected {
    if(self.isSelected)self.backgroundColor = backgroundSelected;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if(_borderColor && !self.isSelected)[self setBorderColorValue:_borderColor];
    if(_borderColorSelected && self.isSelected)[self setBorderColorSelectedValue:_borderColorSelected];
    if(_backgroundNormal && !self.isSelected)[self setBackgroundNormalValue:_backgroundNormal];
    if(_backgroundSelected && self.isSelected)[self setBackgroundSelectedValue:_backgroundSelected];
}


@end
