//
//  AccountManager.h
//  KBSmartPay
//
//  Created by admin on 2015. 9. 1..
//  Copyright (c) 2015년 Seeroo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MPushLibrary/MPushLibrary.h>
#import "IBInbox.h"


/**
 ** 기본적으로 사용자 등록을 요청하고 관리해주는 Classdl다.
 **/

@interface AccountManager : NSObject

/**
 * singleton instance 생성
 **/
+ (AccountManager *)sharedInstance;

- (void)destroyInstance;

/**
 * 사용자 등록을 서버에 요청한다.
 **/
-(void)registerUser:(NSString *)userId;

/**
 * 사용자 등록 해지를 서버에 요청한다.
 **/
-(void)unRegisterUser;

@end
