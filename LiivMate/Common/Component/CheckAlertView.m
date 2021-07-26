//
//  CheckAlertView.m
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2019. 1. 29..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "CheckAlertView.h"

@interface CheckAlertView ()
{
    UIButton *_checkButton;
}

-(BOOL)isChecked;
@end

@implementation CheckAlertView

+(void)showCheckTitle:(NSString*)title message:(NSString*)message dismissTitle:(NSString*)dismissTitle defaultCheck:(BOOL)defaultCheck dissmiss:(void (^)(BOOL checked, NSInteger buttonIndex))dissmiss buttonTitles:(NSString *)buttonTitles, ...
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    va_list args;
    va_start(args, buttonTitles);
    for (NSString *buttonTitle = buttonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString *))
    {
        if([buttonTitle isKindOfClass:[NSArray class]])
        {
            for(NSString *btnTitle in (NSArray*)buttonTitle)
                [array addObject:btnTitle];
        }
        else
            [array addObject:buttonTitle];
    }
    va_end(args);
    
    [self showBlockAlertCustomCallback:^(BlockAlertView *alertView) {
        alertView.title = title;
        alertView.message = message;
        for (NSString *btnTitle in array) {
            [alertView addButtonWithTitle:btnTitle];
        }
        [((CheckAlertView*)alertView)->_checkButton setTitle:dismissTitle forState:(UIControlStateNormal)];
        ((CheckAlertView*)alertView)->_checkButton.selected = defaultCheck;
    } dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        dissmiss([((CheckAlertView*)alertView) isChecked], buttonIndex);
    }];
}


-(id)init
{
    self = [super init];
    if(self)
    {
        self.isShowClosedBtn = NO;
        self.isTouchDisable = YES;
        
        _checkButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_checkButton setImage:[UIImage imageNamed:@"pop_today_checkbox"] forState:(UIControlStateNormal)]; //  checkbox 이미지 교체
        [_checkButton setImage:[UIImage imageNamed:@"pop_today_checkbox_on"] forState:(UIControlStateSelected)];
        [_checkButton setIsAccessibilityElement:YES];
        [_checkButton setAccessibilityLabel:_checkButton.currentTitle];
        _checkButton.titleLabel.font = FONTSIZE(16);
        [_checkButton setTitleColor:UIColorFromRGB(0xffffff) forState:(UIControlStateNormal)];
        [_checkButton addTarget:self action:@selector(onClickedCheckButton:) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:_checkButton];
    }
    return self;
}

-(BOOL)isChecked
{
    return _checkButton.selected;
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
    [super customizeAlertView];
    
    CGFloat width = 310;
    CGFloat buttonH = 30;
    
    CGRect rect = self.bounds;
    
    rect.origin.y -= ((buttonH + 15)/2.f);
    rect.size.height += (buttonH + 15);
    
    self.bounds = rect;
   
    rect.size.height -= (buttonH + 15);
    _backImageView.frame = rect;

    rect.origin.y = CGRectGetMaxY(rect) + 15;
    rect.size.width = 200;
    rect.origin.x += width - CGRectGetWidth(rect);
    rect.size.height = buttonH;
    _checkButton.frame = rect;
    [self addSubview:_checkButton];
    _checkButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 35);
    _checkButton.imageEdgeInsets = UIEdgeInsetsMake(0, 170, 0, 0);
    
}
@end
