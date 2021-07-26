//
//  EdgeTextField.m
//  Pulmuone_Calendar
//
//  Created by SeungYong Oh on 2014. 3. 17..
//
//

#import "EdgeTextField.h"

@interface EdgeTextField ()
{
    UIButton *_clearButton;
    
    CALayer *unlinelayer;
}
@end

@implementation EdgeTextField
@synthesize textInsets;
@synthesize image;
@synthesize highlightedImage;


-(void)setTintColor:(UIColor *)tintColor
{
    if([super respondsToSelector:@selector(setTintColor:)])
        [super setTintColor:tintColor];
}

-(void)initSetting
{
	self.pasteEnabled = YES;
    self.showClearButton = YES;
    textInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemDone) target:self action:@selector(resignFirstResponder)];
    toolBar.items = [NSArray arrayWithObjects:space,doneButton, nil];
    self.inputAccessoryView = toolBar;
    
    [self addTarget:self action:@selector(controlEventEditingChanged:) forControlEvents:(UIControlEventEditingChanged)];
	[self setTintColor:UIColorFromRGB(0xa164ce)];
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.adjustsFontSizeToFitWidth = YES;
//	self.clearButtonMode = UITextFieldViewModeAlways;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initSetting];
        [self setIsAccessibilityElement:NO];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [self initSetting];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self initSetting];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.highlighted = self.isFirstResponder;
	if(self.leftView)
	{
		CGRect rect = self.leftView.frame;
		rect.size.height = CGRectGetHeight(self.bounds);
		self.leftView.frame = rect;
	}
//    _clearButton.frame = CGRectMake(5,
//                                    CGRectGetHeight(self.bounds)/2-10,
//                                    20,
//                                    20);
}

-(void)dealloc
{
    self.image = nil;
    self.highlightedImage = nil;
    _clearButton = nil;
}

-(void)setShowClearButton:(BOOL)showClearButton
{
    _showClearButton = showClearButton;
    if(_showClearButton)
    {
//        self.textAlignment = NSTextAlignmentLeft;
//        self.returnKeyType = UIReturnKeySearch;
//		self.clearButtonMode = UITextFieldViewModeAlways;
        
        if(_clearButton == nil)
        {
            _clearButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
			[_clearButton setIsAccessibilityElement:YES];
			[_clearButton setAccessibilityLabel:@"입력된 내용 삭제"];
			[_clearButton setImage:[UIImage imageNamed:@"btn_close04.png"] forState:(UIControlStateNormal)];
            [_clearButton addTarget:self action:@selector(onClickedClearButton:) forControlEvents:(UIControlEventTouchUpInside)];
            [_clearButton setFrame:CGRectZero];
//            [self addSubview:_clearButton];
//            [self setNeedsLayout];
        }
        
        [self setRightViewMode:UITextFieldViewModeAlways];
        self.rightView = _clearButton;
    }
    else
    {
        self.rightView = nil;
        [_clearButton removeFromSuperview];
        _clearButton = nil;
    }
    
}

-(CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super rightViewRectForBounds:bounds];
 
    CGRect selfBounds = self.bounds;
    
    rect.size.width = 20;
    rect.size.height = 20;
    rect.origin.x = selfBounds.size.width - rect.size.width - 5;
    rect.origin.y = (selfBounds.size.height - rect.size.height)/2;
    
    return rect;
}

-(void)onClickedClearButton:(id)sender
{
    self.text = nil;
    [self controlEventEditingChanged:nil];
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if(highlighted && self.highlightedImage)
    {
        self.background = self.highlightedImage;
    }
    else if(highlighted == NO && self.image)
    {
        self.background = self.image;
    }
    
    if( _showUnderlineByStatus )
    {
        CGRect bounds = self.bounds;
        
        if( !unlinelayer )
        {
            CALayer *layer = self.layer;
            unlinelayer = [CALayer layer];
            
            [unlinelayer setFrame:CGRectMake(0, bounds.size.height-1, bounds.size.width, 1)];
            [layer addSublayer:unlinelayer];
        }
        
        if( highlighted )
        {
            [unlinelayer setBackgroundColor:(RGBA(138, 42, 203, 1)).CGColor];
            [unlinelayer setFrame:CGRectMake(0, bounds.size.height-2, bounds.size.width, 2)];
        }
        else
        {
            [unlinelayer setBackgroundColor:(RGBA(228, 228, 228, 1)).CGColor];
            [unlinelayer setFrame:CGRectMake(0, bounds.size.height-1, bounds.size.width, 1)];
        }
    }
    else
    {
        if( _showBorderLineByStatus )
        {
            self.layer.borderWidth = 1;
            self.layer.cornerRadius = 4;
            self.layer.masksToBounds = YES;
            
            if( highlighted )
            {
                self.layer.borderColor = (RGBA(154, 94, 208, 1)).CGColor;
            }
            else
            {
                self.layer.borderColor = [EtcUtil colorWithHexString:@"aaaaaa"].CGColor;
            }
        }
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    UIEdgeInsets insets = textInsets;
	_clearButton.hidden = self.text.length == 0;
	[_clearButton setIsAccessibilityElement:!_clearButton.hidden];
	if(_showClearButton && _clearButton.hidden == NO)
        insets.right += 20;
    CGRect frame = UIEdgeInsetsInsetRect(bounds, insets);
    if(frame.size.width > 0 && frame.size.height > 0)
    {
        bounds = CGRectIntegral(frame);
    }
    return bounds;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    UIEdgeInsets insets = textInsets;
	_clearButton.hidden = self.text.length == 0;
	[_clearButton setIsAccessibilityElement:!_clearButton.hidden];
	if(_showClearButton && _clearButton.hidden == NO)
        insets.right += 20;
    CGRect frame = UIEdgeInsetsInsetRect(bounds, insets);
    if(frame.size.width > 0 && frame.size.height > 0)
    {
        bounds = CGRectIntegral(frame);
    }
    return bounds;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    UIEdgeInsets insets = textInsets;
	_clearButton.hidden = self.text.length == 0;
	[_clearButton setIsAccessibilityElement:!_clearButton.hidden];
    if(_showClearButton && _clearButton.hidden == NO)
        insets.right += 20;
    CGRect frame = UIEdgeInsetsInsetRect(bounds, insets);
    if(frame.size.width > 0 && frame.size.height > 0)
    {
        bounds = CGRectIntegral(frame);
    }
    return bounds;
}

-(void)controlEventEditingChanged:(id)sender
{
    if([self.delegate respondsToSelector:@selector(textFieldShouldChange:)])
        [self.delegate performSelector:@selector(textFieldShouldChange:) withObject:self];
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(paste:)) {
        
        // 1. textfield생성시 셋팅하는 pasteEnable값이 NO이면 붙여넣기 데이타에 상관없이 NO
        // 2. pasteEnable이 YES일경우 붙여넣을 문자열의 값이 있을경우만 붙여넣기 가능하도록
        // 3. whitespace 문자만 존재할경우도 붙여넣기 안되게..
        NSString * pasteString = [UIPasteboard generalPasteboard].string;
        pasteString = [pasteString trim];
        
        if (pasteString != nil && pasteString.length > 0 && _pasteEnabled)
            return YES;
        else
            return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

#pragma mark - 텍스트필드의 leftView를 특정 타이틀로 사용
- (void)insertLeftViewWithTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font
{
    [self setLeftViewMode:UITextFieldViewModeAlways];
    CGFloat fWidth = [title boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, fWidth+5, self.bounds.size.height)];
	label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [label setIsAccessibilityElement:YES];
    [label setAccessibilityLabel:title];
    [label setFont:font];
    [label setText:title];
    [label setTextColor:color];
    
    self.leftView = label;
}

-(CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super leftViewRectForBounds:bounds];
    rect.origin.x = 7;
    return rect;
}

#pragma mark - 텍스트필드의 테투리 선을 표시
- (void)setBorderLine
{
    CALayer *selfLayer = self.layer;
    selfLayer.borderWidth = 1;
    selfLayer.borderColor = [EtcUtil colorWithHexString:@"D7D7D7"].CGColor;
    selfLayer.cornerRadius = 3;
}

#pragma mark - 텍스트필드에 밑줄 표시
- (void)setUnderLine:(UIColor *)color borderWidth:(CGFloat)borderWidth
{
	CGRect bounds = self.bounds;
	CALayer *layer = self.layer;
	CALayer *underlinelayer = [CALayer layer];
	
	[underlinelayer setFrame:CGRectMake(0, bounds.size.height-borderWidth, bounds.size.width, borderWidth)];
	[underlinelayer setBackgroundColor:color.CGColor];
	[layer addSublayer:underlinelayer];
}

@end
