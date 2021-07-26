//
//  ServerChoiceView.h
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 26/07/2019.
//  Copyright © 2019 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerChoiceView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView  *titleSubView;
@property (weak, nonatomic) IBOutlet UIButton * firstButton;
@property (weak, nonatomic) IBOutlet UIButton * secondButton;

+ (ServerChoiceView *)makeView;
- (BOOL)isExistPort;
- (void)setSelPort:(BOOL)isSel;

@end

NS_ASSUME_NONNULL_END
