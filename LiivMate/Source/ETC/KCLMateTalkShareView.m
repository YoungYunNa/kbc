//
//  KCLMateTalkShareView.m
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLMateTalkShareView.h"

@implementation KCLMateTalkShareView

#pragma mark - View Make
+ (KCLMateTalkShareView *)makeView
{
    KCLMateTalkShareView *viewObj = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Component" owner:nil options:nil];
    for (id obj in objects)
    {
        if ([obj isKindOfClass:[KCLMateTalkShareView class]])
        {
            viewObj = obj;
            
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            CGFloat bottomPadding = 0;
            if (@available(iOS 11.0, *)) {
                bottomPadding = window.safeAreaInsets.bottom;
            }
            CGFloat navHeight = 0; //
            
            navHeight = 0;

            viewObj.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, window.frame.size.height-bottomPadding-navHeight);
            break;
        }
    }
    return viewObj;
}

#pragma mark - Button Action
- (IBAction)selectedButtonIndex:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    if (self.delegate != nil)
    {
        [self.delegate selectedShareBtn:(int)tag];
    }

    [self hideDesignView:YES];
}

- (IBAction)closeButtonClicked:(id)sender
{
    // 팝업 닫기 버튼 클릭
//    [[BlockAlertView currentAlert] dismissWithClickedButtonIndex:-1 animated:YES];
}

- (IBAction)didTouchClose:(id)sender{
    [self hideDesignView:YES];
}

#pragma mark - View Show / Hide
-(void)showDesignView:(BOOL)animated{
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGRect retMainScreen = window.frame;
    CGRect retMessageView = self.bottomMessageView.frame;
    
    CGFloat bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        
        bottomPadding = window.safeAreaInsets.bottom;
    }
    
    self.backgroundView.frame = retMainScreen;
    self.backgroundView.alpha = 0;
    self.bottomMessageView.frame = CGRectMake(0, retMainScreen.size.height, retMainScreen.size.width, retMessageView.size.height);
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        self.backgroundView.alpha = 0.7;
        self.bottomMessageView.frame = CGRectMake(0,retMainScreen.size.height-retMessageView.size.height-bottomPadding, retMessageView.size.width, retMessageView.size.height);
    }completion:^(BOOL finished){
        if(finished){
            
        }
    }];
}

-(void)hideDesignView:(BOOL)animated{
    CGRect retMainScreen = [UIScreen mainScreen].bounds;
    CGRect retMessageView = self.bottomMessageView.frame;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        self.backgroundView.alpha = 0;
        self.bottomMessageView.frame = CGRectMake(0, retMainScreen.size.height, retMessageView.size.width, retMessageView.size.height);
    }completion:^(BOOL finished){
        if(finished){
            [self removeFromSuperview];
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
