//
//  URLAction+Call.m
//  LiivMate
//
//  Created by kbcard on 2018. 11. 9..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "URLAction+Call.h"

@implementation Action_call_move_to
+(void)runWithUrl:(NSURL*)url
{
	//@"liivmate://call?cmd=move_to&id=KAT_JOIN_001&params={key:value,...}"
	NSDictionary *params = [EtcUtil parseUrl:url.query];
	NSString *pageID = [params objectForKey:@"id"];
	NSString *paramsStr = [params objectForKey:@"params"];
	[[AllMenu delegate] sendBirdDetailPage:pageID callBack:^(ViewController *vc) {
//		vc.dicParam = paramsStr.stringByUrlDecoding.jsonObject; //vc생성되기 전에 바인딩되어 값 nil되어 userDefault에 저장해놨다 사용하도록 변경.
        [AppInfo sharedInfo].openUrlParam = [[NSDictionary alloc] initWithDictionary:paramsStr.stringByUrlDecoding.jsonObject];
        [[NSUserDefaults standardUserDefaults] setObject:paramsStr.stringByUrlDecoding.jsonObject forKey:ACTION_CALL_MOVE_TO_PARAM_INFO];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}];
}
@end
