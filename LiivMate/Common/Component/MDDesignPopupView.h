//
//  MDDesignPopupView.h
//  LiivMate
//
//  Created by KB on 17/04/2020.
//  Copyright © 2020 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CornerRadiusButton.h"
NS_ASSUME_NONNULL_BEGIN

@interface MDDesignPopupView : UIView
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *bottomMessageView;
@property (weak, nonatomic) IBOutlet CornerRadiusButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *cancelPaddingView;
@property (weak, nonatomic) IBOutlet CornerRadiusButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (IBAction)didTouchClose:(id)sender;
- (IBAction)didTouchConfirm:(id)sender;

-(void)showDesignView:(BOOL)animated;
-(void)hideDesignView:(BOOL)animated;

+(instancetype)instance;
@end

NS_ASSUME_NONNULL_END
