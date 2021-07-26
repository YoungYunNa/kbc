//
//  CustomWaitView.m
//  NetFunnelTest
//
//  Created by JangJaeMan on 2015. 6. 1..
//  Copyright (c) 2015년 JangJaeMan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomWaitView.h"
#import "MateWaitView.h"


#define CLOSE_WAIT_ALERT -9191
// ---------------------------------------------------------------------
// NetFunnelDefaultWaitView
// ---------------------------------------------------------------------
@interface CustomWaitView(){
    MateWaitView *mateWaitView;
    BlockAlertView *alert;

}
@end

@implementation CustomWaitView

-(id)init{
    self = [super init];
    
    if (self) {
    }
    return self;
}



-(void)show
{
    NetFunnelWaitData *wdata = [self getWaitData];
    
    NSString * msg = @"";
    msg = [msg stringByAppendingFormat:@" - WaitUser=%ld\n",(long)wdata._waitUser];
    msg = [msg stringByAppendingFormat:@" - TotalWaitUser=%ld\n",(long)wdata._totalWaitUser];
    msg = [msg stringByAppendingFormat:@" - WaitTime=%ld\n",(long)wdata._waitTime];
    msg = [msg stringByAppendingFormat:@" - 처리량(tps)=%f\n",(float)wdata._tps];
    msg = [msg stringByAppendingFormat:@" - Progress=%f",(float)wdata._progress];
   
    NSLog(@"%@", msg);

    
    if (!alert && !mateWaitView) {
        
        [IndicatorView hide]; // 유량제어 로딩바 hide
        
        mateWaitView =  [[MateWaitView alloc] initWithFrame:CGRectMake(0, 0, 313, 338)];
        [mateWaitView reloadWaitData:(int)wdata._waitTime waitCnt:(int)wdata._waitUser];

        [BlockAlertView dismissAllAlertViews];
        
        alert =  [[BlockAlertView alloc] initWithTitle:@"접속대기 중입니다."
                                               message:mateWaitView
                                     dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                                                 if (buttonIndex != CLOSE_WAIT_ALERT) {
                                                     [self setStop];
                                                 }
                                     } cancelButtonTitle:nil
                                     otherButtonTitles:nil];

		[mateWaitView.imgSandglass startAnimating];
        alert.isShowClosedBtn = YES;
        alert.isFullCustomView = YES;
        alert.isTouchDisable = YES;
        [alert showOtherButton:NO];
        
    } else {
         [mateWaitView reloadWaitData:(int)wdata._waitTime waitCnt:(int)wdata._waitUser];
    }
}

-(void)hide
{
    if (alert) {
        [alert dismissWithClickedButtonIndex:CLOSE_WAIT_ALERT animated:YES];
        alert = nil;
		[mateWaitView.imgSandglass stopAnimating];
        mateWaitView = nil;
    }
}

-(void)showVirtualWait
{
 
}

-(void)showBlockAlert{
   
}




@end
