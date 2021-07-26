//
//  MobileWeb+NetFunnel.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 8. 7..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "MobileWeb.h"

//유량제어 라이브러리 호출
@interface checkNetFunnel : MobileWeb		// param : @{@"reqID" : @"P00202"}//전문id
// output param : (라이브러리 결과 로그)
+ (void)checkNetFunnelActionID:(NSString*)actionID params:(NSDictionary*)params callback:(void (^)(NSDictionary *result, BOOL success))finishedCallback;
@end
typedef checkNetFunnel CheckNetFunnel;
