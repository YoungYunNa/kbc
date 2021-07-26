//
//  SplashMessageView.h
//  NewKBCardShop
//
//  Created by Lee SeungWoo on 13. 2. 26..
//

#import <UIKit/UIKit.h>


@interface SplashMessageView : UIImageView 
{
	UILabel* _labelMessage;
	
	NSTimer* _timerForAutoHide;
}

- (void)showMessage:(UIView*)parentView message:(NSString*)message autohide:(BOOL)autohide withShowTop:(BOOL)showTop;
- (void)hideMessage;
- (void)performAnimationShow:(BOOL)autohide;
- (void)performAnimationHide:(NSTimer*)timer;
- (void)didStopAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)didEndAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)stopTimerForAutoHide;

@end
