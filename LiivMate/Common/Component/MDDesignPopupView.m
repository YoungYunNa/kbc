//
//  MDDesignPopupView.m
//  LiivMate
//
//  Created by KB on 17/04/2020.
//  Copyright © 2020 KBCard. All rights reserved.
//

#import "MDDesignPopupView.h"

@implementation MDDesignPopupView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)instance
{
    @try {
//        return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Component" owner:nil options:nil];
        MDDesignPopupView *viewObj;
        for (id obj in objects)
        {
            if ([obj isKindOfClass:[MDDesignPopupView class]])
            {
                viewObj = obj;
                
                UIWindow *window = UIApplication.sharedApplication.keyWindow;
                CGFloat topPadding = 0;
                if (@available(iOS 11.0, *)) {
                    topPadding = window.safeAreaInsets.top;
                }
                CGFloat navHeight = 50; //
                
                navHeight = 0;
                topPadding = 0;

                
                viewObj.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, window.frame.size.height-topPadding-navHeight);

                break;
            }
        }
        return viewObj;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

-(void)viewWillLayoutSubviews
{
    NSLog(@"viewWillLayoutSubviews10");
}
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

- (IBAction)didTouchClose:(id)sender {
    [self hideDesignView:YES];
}

- (IBAction)didTouchConfirm:(id)sender {
    [self hideDesignView:YES];
}
@end
