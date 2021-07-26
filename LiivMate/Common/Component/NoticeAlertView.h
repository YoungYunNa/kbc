//
//  NoticeAlertView.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 11. 1..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "BlockAlertView.h"

@interface NoticeAlertView : BlockAlertView
//공지사항.
+(void)showNoticeTitle:(NSString*)title message:(NSString*)message dismissTitle:(NSString*)dismissTitle dissmiss:(void (^)(BOOL checked))dissmiss;
+(void)showNoticeTitle:(NSString*)title message:(NSString*)message dismissTitle:(NSString*)dismissTitle isFullPopup:(BOOL)isFullPopup dissmiss:(void (^)(BOOL checked))dissmiss;
//화면 이미지 팝업
+(void)showNoticeTitle:(NSString*)title message:(NSString*)message detail:(BOOL)showDetail dissmiss:(void (^)(BOOL checked, BOOL showDetail))dissmiss;
@end
