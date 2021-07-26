//
//  UserInfo.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 8. 14..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "KCLCommonWidgetHeader.h"
#import "UserInfo.h"

@implementation UserInfo
@synthesize custNo	= _custNo;
@synthesize userCI = _userCI;
@synthesize custNm	= _custNm;
@synthesize mbspId	= _mbspId;
@synthesize cId		= _cId;
@synthesize kbPin	= _kbPin;
@synthesize moblNo	= _moblNo;
@synthesize sendBirdToken = _sendBirdToken;

//고객번호
-(void)setCustNo:(NSString *)custNo
{
	_custNo = custNo.encryptAes128;
	
	if (_custNo != nil) {
		// 고객번호 세팅시 위젯에서 사용하기 위해 NSUserDefault에 저장
		NSUserDefaults *sharedUserDefault = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
		if ([sharedUserDefault objectForKey:WIDGET_CUST_NO] != nil) {
			
			if (![[sharedUserDefault objectForKey:WIDGET_CUST_NO] isEqualToString:_custNo]) {
				// 달라도 저장
				[sharedUserDefault setObject:_custNo forKey:WIDGET_CUST_NO];
				[sharedUserDefault synchronize];
			}
			
		} else {
			// 없으면 저장
			[sharedUserDefault setObject:_custNo forKey:WIDGET_CUST_NO];
			[sharedUserDefault synchronize];
		}
	}
}

-(NSString*)custNo
{
	return _custNo.decryptAes128;
}

//고객이름
-(void)setCustNm:(NSString *)custNm
{
	_custNm = custNm.encryptAes128;
}
-(NSString*)custNm
{
	return _custNm.decryptAes128;
}

//userCI
-(void)setUserCI:(NSString *)userCI
{
	_userCI = userCI.encryptAes128;
}
-(NSString*)userCI
{
	return _userCI.decryptAes128;
}

//멤버십ID
-(void)setMbspId:(NSString *)mbspId
{
	_mbspId = mbspId.encryptAes128;
}
-(NSString*)mbspId
{
	return _mbspId.decryptAes128;
}

//외부 공개용 ID
-(void)setCId:(NSString *)cId
{
	_cId = cId.encryptAes128;
}
-(NSString*)cId
{
	return _cId.decryptAes128;
}

//고객 고유정보
-(void)setKbPin:(NSString *)kbPin
{
	_kbPin = kbPin.encryptAes128;
}
-(NSString*)kbPin
{
	return _kbPin.decryptAes128;
}

//휴대폰번호
-(void)setMoblNo:(NSString *)moblNo
{
	_moblNo = moblNo.encryptAes128;
}
-(NSString*)moblNo
{
	return _moblNo.decryptAes128;
}

//샌드버드토큰
-(void)setSendBirdToken:(NSString *)sendBirdToken
{
	_sendBirdToken = sendBirdToken.encryptAes128;
}
-(NSString*)sendBirdToken
{
	return _sendBirdToken.decryptAes128;
}

@end
