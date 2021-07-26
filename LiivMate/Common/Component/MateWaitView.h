//
//  MateWaitView.h
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2018. 4. 17..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MateWaitView : UIView
@property (nonatomic, retain) UIImageView *imgSandglass;
- (void)reloadWaitData:(int)waitTime waitCnt:(int)waitCnt;
@end



