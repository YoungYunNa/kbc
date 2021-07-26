//
//  KCLRightPopupView.h
//  LiivMate
//
//  Created by KB on 2021/07/01.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KCLRightPopupView : UIView

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

- (void)showDesignView:(BOOL)animated;
- (void)hideDesignView:(BOOL)animated;

+ (instancetype)instance;

@end

NS_ASSUME_NONNULL_END
