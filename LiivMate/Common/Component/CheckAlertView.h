//
//  CheckAlertView.h
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2019. 1. 29..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "BlockAlertView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheckAlertView : BlockAlertView

+(void)showCheckTitle:(NSString*)title message:(NSString*)message dismissTitle:(NSString*)dismissTitle defaultCheck:(BOOL)defaultCheck dissmiss:(void (^)(BOOL checked, NSInteger buttonIndex))dissmiss buttonTitles:(NSString *)buttonTitles, ...NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END
