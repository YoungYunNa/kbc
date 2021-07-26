//
//  MDViewController.h
//  LiivMate
//
//  Created by KB on 17/03/2020.
//  Copyright © 2020 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class KCLCustomNavigationBarView;
@interface MDViewController : UIViewController

@property (nonatomic,strong) KCLCustomNavigationBarView *customNavigationBar;

- (void)backButtonAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
