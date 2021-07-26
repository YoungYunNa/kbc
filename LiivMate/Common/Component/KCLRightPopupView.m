//
//  KCLRightPopupView.m
//  LiivMate
//
//  Created by KB on 2021/07/01.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLRightPopupView.h"

@implementation KCLRightPopupView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)instance {
    
    @try {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Component" owner:nil options:nil];
        KCLRightPopupView *viewObj;
        
        for (id obj in objects) {
            if ([obj isKindOfClass:[KCLRightPopupView class]]) {
                viewObj = obj;
                viewObj.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

                break;
            }
        }
        return viewObj;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (void)showDesignView:(BOOL)animated {
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGRect retMainScreen = window.frame;
    CGRect retButtonsView = self.buttonsView.frame;
    
    self.backgroundView.frame = retMainScreen;
    self.backgroundView.alpha = 0;
    
    self.buttonsView.frame = CGRectMake(retMainScreen.size.width, 0, retMainScreen.size.width, retButtonsView.size.height);
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^() {
        self.backgroundView.alpha = 0.6;
        self.buttonsView.frame = CGRectMake(retMainScreen.size.width-retButtonsView.size.width, 0, retButtonsView.size.width, retButtonsView.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

- (void)hideDesignView:(BOOL)animated {
    
    CGRect retMainScreen = [UIScreen mainScreen].bounds;
    CGRect retButtonsView = self.buttonsView.frame;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^() {
        self.backgroundView.alpha = 0;
        self.buttonsView.frame = CGRectMake(retMainScreen.size.width, 0, retButtonsView.size.width, retButtonsView.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (IBAction)didTouchClose:(id)sender {
    [self hideDesignView:YES];
}

@end
