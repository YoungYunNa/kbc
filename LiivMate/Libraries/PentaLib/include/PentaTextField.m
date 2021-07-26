//
//  PentaTextField.m
//  virtual-keypad
//
//  Created by 하 지윤 on 2014. 11. 29..
//  Copyright (c) 2014년 Penta Security Systems Inc. All rights reserved.
//

#import "PentaTextField.h"

#import "PentaKeypad.h"

@interface PentaTextField () {
    UIViewController *_inputViewController;
    unsigned char *_encryptionKey;
    unsigned int _keyLength;
    UIView *_inputContainView;
}

@property() UIViewController *inputViewController;

@end

@implementation PentaTextField

@synthesize inputViewController = _inputViewController;
@synthesize maxLength = _maxLength;
@synthesize useUpperDone = _useUpperDone;
@synthesize useUpperCancel = _useUpperCancel;
@synthesize useUpperTextfield = _useUpperTextfield;
@synthesize upperMessage = _upperMessage;
@synthesize upperMessageFont = _upperMessageFont;
@synthesize pentaDelegate = _pentaDelegate;
@synthesize enableChangeKeypad = _enableChangeKeypad;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSLog(@"123123");
}
*/

- (id)init
{
    self = [super init];
    if (self != nil) {
        // iOS 7에서 숫자키패드 실행 시 키패드 전체 크기가 기본 키패드와 동일한 크기를 가지는 오류 때문에 여기서 생성하지 않음.
        //[self createInputViewController];
        // 무조건 보안 텍스트필드로 생성되게 하려면 아래 코드 주석 해제 (IB에서의 설정은 의미 없어짐)
        //[self setSecureTextEntry:YES];
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

- (UIView *)inputView
{
    [self createInputViewController];
    if(@available(iOS 11.0, *))
        return _inputContainView;
    return _inputViewController.view;
}

- (NSString *)inputText
{
    if (_inputViewController != nil) {
        return [PentaKeypad inputTextFromKeypad:_inputViewController];
    }
    
    return @"";
}

- (void)createInputViewController
{
    if (_inputViewController == nil) {
        _inputViewController = [PentaKeypad createInputViewController:self];
        [PentaKeypad setKeypad:_inputViewController pentaDelegate:_pentaDelegate];
        [PentaKeypad setKeypad:_inputViewController maxLength:_maxLength];
        [PentaKeypad setKeypad:_inputViewController useUpperDone:_useUpperDone];
        [PentaKeypad setKeypad:_inputViewController useUpperCancel:_useUpperCancel];
        [PentaKeypad setKeypad:_inputViewController useUpperTextfield:_useUpperTextfield];
        [PentaKeypad setKeypad:_inputViewController upperMessage:_upperMessage];
        if (_upperMessageFont != nil)
            [PentaKeypad setKeypad:_inputViewController upperMessageFont:_upperMessageFont];
        [PentaKeypad setKeypad:_inputViewController enableChangeKeypad:_enableChangeKeypad];
        [PentaKeypad setKeypad:_inputViewController encryptionKey:_encryptionKey keyLength:_keyLength];
        [PentaKeypad setKeypad:_inputViewController targetTextfield:self];

        if(@available(iOS 11.0, *))
        {
            _inputContainView = [[UIView alloc] initWithFrame:_inputViewController.view.bounds];
            _inputContainView.backgroundColor = UIColorFromRGBWithAlpha(0xf7f7f7, 1);
            _inputViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            [_inputContainView addSubview:_inputViewController.view];
            
            UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyPad:)];
            swipe.direction = UISwipeGestureRecognizerDirectionDown;
            swipe.numberOfTouchesRequired = 2;
            [_inputContainView addGestureRecognizer:swipe];
        }
    }
    
    if (@available(iOS 11.0, *))
    {
        CGFloat bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        if(bottom != 0)
            bottom += 44;
        CGRect rect = _inputViewController.view.bounds;
        rect.size.height += bottom;
        _inputContainView.frame = rect;
    }
}

-(void)resignKeyPad:(UISwipeGestureRecognizer*)ges
{
	if(self.isFirstResponder)
		[self resignFirstResponder];
}

- (void)setEncryptionKey:(unsigned char *)encryptionKey keyLength:(unsigned int)keyLength
{
    if (_encryptionKey != nil)
        free(_encryptionKey);
    
    _keyLength = keyLength;
    _encryptionKey = (unsigned char *) malloc(keyLength);
    memcpy(_encryptionKey, encryptionKey, keyLength);
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController encryptionKey:_encryptionKey keyLength:_keyLength];
    }
}

- (unsigned int)maxLength
{
    return _maxLength;
}

- (void)setMaxLength:(unsigned int)newMaxLength
{
    _maxLength = newMaxLength;
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController maxLength:self.maxLength];
    }
}

- (BOOL)useUpperDone
{
    return _useUpperDone;
}

- (void)setUseUpperDone:(BOOL)use
{
    _useUpperDone = use;
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController useUpperDone:_useUpperDone];
    }
}

- (BOOL)useUpperCancel
{
    return _useUpperDone;
}

- (void)setUseUpperCancel:(BOOL)use
{
    _useUpperCancel = use;
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController useUpperCancel:_useUpperCancel];
    }
}

- (BOOL)useUpperTextfield
{
    return _useUpperDone;
}

- (void)setUseUpperTextfield:(BOOL)use
{
    _useUpperTextfield = use;
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController useUpperTextfield:_useUpperTextfield];
    }
}

- (NSString *)upperMessage
{
    return _upperMessage;
}

- (void)setUpperMessage:(NSString *)message
{
    _upperMessage = message;
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController upperMessage:_upperMessage];
    }
}

- (UIFont *)upperMessageFont
{
    return _upperMessageFont;
}

- (void)setUpperMessageFont:(UIFont *)newFont
{
    _upperMessageFont = newFont;
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController upperMessageFont:_upperMessageFont];
    }
}

- (BOOL)enableChangeKeypad
{
    return _enableChangeKeypad;
}

- (void)setEnableChangeKeypad:(BOOL)enable
{
    _enableChangeKeypad = enable;
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController enableChangeKeypad:_enableChangeKeypad];
    }
}

- (id)pentaDelegate
{
    return _pentaDelegate;
}

- (void)setPentaDelegate:(id)newDelegate
{
    _pentaDelegate = newDelegate;
    
    if (self.inputViewController != nil) {
        [PentaKeypad setKeypad:_inputViewController pentaDelegate:_pentaDelegate];
    }
}

- (void)dealloc
{
//    [super dealloc];
	_pentaDelegate = nil;
	_inputViewController = nil;
    if (_encryptionKey != nil) {
        memset(_encryptionKey, 0x00, _keyLength);
        free(_encryptionKey);
        _encryptionKey = nil;
    }
}

@end
