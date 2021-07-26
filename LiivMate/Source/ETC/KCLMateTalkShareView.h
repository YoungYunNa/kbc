//
//  KCLMateTalkShareView.h
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLMateTalkShareView
@date 2021.04.21
@brief SNS 공유
*/

#import <UIKit/UIKit.h>

#import <KakaoLink/KakaoLink.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KCLMateTalkShareViewDelegate <NSObject>
- (void)selectedShareBtn:(int)selectIndex;
@end

@interface KCLMateTalkShareView : UIView

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *bottomMessageView;
@property (nonatomic, weak)    id<KCLMateTalkShareViewDelegate>delegate;

+ (KCLMateTalkShareView *)makeView;

- (IBAction)didTouchClose:(id)sender;
-(void)showDesignView:(BOOL)animated;
-(void)hideDesignView:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
