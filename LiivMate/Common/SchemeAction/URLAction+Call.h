//
//  URLAction+Call.h
//  LiivMate
//
//  Created by kbcard on 2018. 11. 9..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLAction.h"

//CASE 2 host명 + cmd명으로 구분되는 케이스
//ex) @"liivmate://call?cmd=move_to&id=KAT_JOIN_001&params={key:value,...}"

/*
 ! 기능을 추가하려면 Action_call을 상속받아 생성을 해야한다
 ! 명명규칙은 "Action_call_" + 호출명(cmd 대소문자 구분) 형태로 class이름을 적용한다.
 */

//넘어온 화면id로 해당화면으로 이동시켜주는 기능
@interface Action_call_move_to : Action_call
@end
