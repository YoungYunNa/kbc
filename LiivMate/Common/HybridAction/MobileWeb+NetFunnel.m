//
//  MobileWeb+NetFunnel.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 8. 7..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "MobileWeb+NetFunnel.h"
#import <NetFunnel/NetFunnel.h>
#import "CustomWaitView.h"

// 유량제어
#define NETFUNNEL_PROTO                 @"https"
#define NETFUNNEL_HOST                  @"m.liivmate.com"
#define NETFUNNEL_PORT                  @"10000"
#define NETFUNNEL_SERVICEID             @"service_1"
#define NETFUNNEL_CONN_TIMEOUT          @"3.0"
#define NETFUNNEL_CONN_RETRY            @"2"

//유량제어 라이브러리 호출
@implementation checkNetFunnel
static NSMutableDictionary *netFunnelReqID = nil;

+(void)initialize
{
	[super initialize];
	netFunnelReqID = [[NSMutableDictionary alloc] init];
//	[netFunnelReqID setObject:@{@"ACTION_ID" : MenuID_Mypage} forKey:MenuID_Mypage]; //마이페이지
     // Ver. 3 로그인 추가(KATL001), 쿠폰 상세(KATA008), 쿠폰 구매(KATA009)
    [netFunnelReqID setObject:@{@"ACTION_ID" : KATL001} forKey:KATL001]; // 로그인
//    [netFunnelReqID setObject:@{@"ACTION_ID" : KATA008} forKey:KATA009]; // 이벤트쿠폰발급
//    [netFunnelReqID setObject:@{@"ACTION_ID" : KATA008, @"PARAMS" : @{@"useSaleTime" : @"1"}} forKey:KATA008]; // 쿠폰상세
}

/**
 @var isExistParams
 @brief 생성된 리퀘스트의 파라메타값과 유량제어할 리퀘스트의 파라메타값 빅7
 @return 유량제어할 파라메타값들이 리퀘스트의 파라메타값에 존재하면 YES, 야니면 NO
 */
+ (BOOL)isExistParams:(NSString*)actionID params:(NSDictionary*)params {
	
	BOOL isExist = YES;
	
	for (NSString * key in netFunnelReqID[actionID][@"PARAMS"]) {
		
		NSString * value = params[key];
		
		if (![netFunnelReqID[actionID][@"PARAMS"][key] isEqualToString:value]) {
			isExist = NO;
			break;
		}
	}
	
	return isExist;
}

#ifdef DEBUG
//#define NetFunnelTest
#endif

/**
 @var getNetFunnelActionID
 @brief 생성된 리퀘스트에 매칭되는 유량제어할 actionId값을 얻어온다
 @return actionID 또는 유량제어 되지 않는 리퀘스트일시  nil반환
 */
+ (NSString *)getNetFunnelActionID:(NSString*)actionID params:(NSDictionary*)params
{
#ifndef NetFunnelTest
	if (![[AppInfo sharedInfo].CONNCTLUSEYN boolValue]) return nil;
#endif
	if (!netFunnelReqID[actionID]) return nil;
	
	if(![netFunnelReqID[actionID] isKindOfClass:[NSDictionary class]]) return nil;
	
	if (!netFunnelReqID[actionID][@"PARAMS"]) return netFunnelReqID[actionID][@"ACTION_ID"];
	
	// params가 있는 경우
	if([self isExistParams:actionID params:params])
		return netFunnelReqID[actionID][@"ACTION_ID"];
	
	return nil;
}

+ (void)checkNetFunnelActionID:(NSString*)actionID params:(NSDictionary*)params callback:(void (^)(NSDictionary *result, BOOL success))finishedCallback
{
	NSString *ACTION_ID = [self getNetFunnelActionID:actionID params:params];
	if(ACTION_ID != nil)
	{
        [IndicatorView show]; // 유량제어 로딩바 show
		[self runWithParam:@{@"reqID" : ACTION_ID} callback:^(NSDictionary *result, BOOL success) {
             [IndicatorView hide]; // 유량제어 로딩바 hide
			if(finishedCallback)
				finishedCallback(result, success);
		}];
	}
	else
	{
		if(finishedCallback)
			finishedCallback(nil, YES);
	}
}

- (void)run
{
	NSString *actionID = self.paramDic[@"reqID"];
	if(actionID == nil)
		actionID = @"mobileWeb";
#ifndef NetFunnelTest
	if([[AppInfo sharedInfo].CONNCTLUSEYN boolValue] == NO)
	{
		[self finishedActionWithResult:nil success:YES];
		return;
	}
#else
	actionID = @"ver2";
	while(time(0)%3 != 0)
	{
		NSLog(@"====>%d",3-((int)time(0)%3));
		[[NSRunLoop currentRunLoop] acceptInputForMode:NSDefaultRunLoopMode beforeDate:[[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode]];
	}
#endif
	[self tryChackInNetFunnel:actionID];
}

#pragma mark - NetFunnel private method
/**
 @var initNetFunnel:
 @brief 유량제어 요청시 사용될 초기화 값
 @param 유량제여 요청시 사용될 actionID
 */
-(void)initNetFunnel:(NSString *)actionID
{
	[NetFunnel setGlobalConfigObject:NETFUNNEL_PROTO forKey:@"proto" withId:nil];
	[NetFunnel setGlobalConfigObject:NETFUNNEL_HOST forKey:@"host" withId:nil];
	[NetFunnel setGlobalConfigObject:NETFUNNEL_PORT forKey:@"port" withId:nil];
	[NetFunnel setGlobalConfigObject:NETFUNNEL_SERVICEID forKey:@"service_id" withId:nil];
	[NetFunnel setGlobalConfigObject:NETFUNNEL_CONN_TIMEOUT forKey:@"conn_timeout" withId:nil];
	[NetFunnel setGlobalConfigObject:NETFUNNEL_CONN_RETRY forKey:@"conn_retry" withId:nil];
	[NetFunnel setGlobalConfigObject:actionID forKey:@"action_id" withId:nil];
}

/**
 @var completeNetFunnel
 @brief 유량제어 complete 요청
 */
- (void)completeNetFunnel:(NSDictionary *)result
{
	if(![[[NetFunnel alloc] initWithDelegate:(id)self pView:nil] complete]){
		NSLog(@"Complete Error");
		[self finishedActionWithResult:result success:NO];
	}
	else
		[self finishedActionWithResult:result success:YES];
}

/**
 @var tryChackInNetFunnel:action_id:
 @brief 유량제어 요청
 @param actionID - 유량제어 요청시 사용될 actionId
 */
- (void)tryChackInNetFunnel:(NSString *)actionID
{
	[self initNetFunnel:actionID];
	
	[NetFunnel setGlobalConfigObject:[[CustomWaitView alloc] initWithParentView:nil] forKey:@"wait_view_object" withId:nil];
	[[[NetFunnel alloc] initWithDelegate:(id)self pView:nil] actionWithNid:nil config:nil ];
}

#pragma mark - NetFunnel delegate
-(void)NetFunnelActionSuccess:(NSString *)nid withResult:(NetFunnelResult *)result
{
	NSLog(@"Action Success Called [nid=%@,result=%@",nid,result);
	[self completeNetFunnel:@{@"nid":[NSString stringWithFormat:@"%@",nid],@"result":[NSString stringWithFormat:@"%@",result]}];
}
-(void)NetFunnelCompleteSuccess:(NSString *)nid withResult:(NetFunnelResult *)result
{
	NSLog(@"Complete Success Called [nid=%@,result=%@",nid,result);
}
-(BOOL)NetFunnelActionContinue:(NSString *)nid withResult:(NetFunnelResult *)result
{
	return YES;
}
-(void)NetFunnelStop:(NSString *)nid
{
	NSLog(@"Stop Called [nid=%@]",nid);
	[self finishedActionWithResult:@{@"nid":[NSString stringWithFormat:@"%@",nid]} success:NO];
}
-(void)NetFunnelActionError:(NSString *)nid withResult:(NetFunnelResult *)result
{
	NSLog(@"Error Called [nid=%@,result=%@",nid,result);
	// 에러 생겼을때도 리퀘스트 그냥 넘기게....
	[self completeNetFunnel:@{@"nid":[NSString stringWithFormat:@"%@",nid],@"result":[NSString stringWithFormat:@"%@",result]}];
}

-(void)NetFunnelCompleteError:(NSString *)nid withResult:(NetFunnelResult *)result
{
	NSLog(@"NetFunnelCompleteError Called [nid=%@,result=%@",nid,result);
	[self finishedActionWithResult:@{@"nid":[NSString stringWithFormat:@"%@",nid],@"result":[NSString stringWithFormat:@"%@",result]} success:NO];
}

-(BOOL)NetFunnelActionBlock:(NSString *)nid withResult:(NetFunnelResult *)result
{
	[BlockAlertView showBlockAlertWithTitle:@"알림"
						   showClosedButton:NO
									message:@"서비스 점검중 입니다."
						  dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
							  
						  } cancelButtonTitle:@"확인" buttonTitles:nil];
	[self finishedActionWithResult:@{@"nid":[NSString stringWithFormat:@"%@",nid],@"result":[NSString stringWithFormat:@"%@",result]} success:NO];
	return NO;
}
@end

