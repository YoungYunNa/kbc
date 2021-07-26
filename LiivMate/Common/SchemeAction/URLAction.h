//
//  URLAction.h
//  LiivMate
//
//  Created by kbcard on 2018. 11. 9..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>

//스킴액션으로 호출된 기능을 실행하는 기능으로 url의 host명으로 class를 체크하여 해당기능을 수행한다.
@interface NSURL (URLAction)
-(BOOL)runAction;
@end

@interface BaseURLAction : NSObject
+(void)runWithUrl:(NSURL*)url;
@end

/*
 ! 기능을 추가하려면 BaseURLAction을 상속받아 생성을 해야한다
 ! 명명규칙은 "Action_" + 액션명(host (대소문자 구분)) 형태로 class이름을 적용한다.
 ! 현재는 단순 화면이동 기능으로 설계된 로직이며, HybridAction처럼 unsync방식으로 단독처리후 결과를 실행하려면 별도의 라이프사이클 로직을 해당 액션에 구현해야함
 */

//host명이 call인 기능으로 cmd로 전달된 sub action을 분기하여 처리할수있는 Action (세부 기능은 URLAction+Call.h 파일에 구현)
@interface Action_call : BaseURLAction
@end

//SMS 등 공유하기로 전달된 링크에서 리브메이트 브릿지 페이지를 거처서 들어오는 이벤트 액션
@interface Action_event : BaseURLAction
@end

//SMS 등 공유하기로 전달된 링크에서 리브메이트 브릿지 페이지를 거처서 들어오는 액션
@interface Action_appid : BaseURLAction
@end

//스킴액션으로 리브메이트 웹뷰컨트롤러에 화면을 보여주는 액션
@interface Action_webview : BaseURLAction
@end

//카카오톡 공유하기 연동액션
@interface Action_kakaolink : BaseURLAction
@end

//아이폰 기본카메라로 리브메이트 QR을 스캔했을경우 호출되는 액션
@interface Action_QR : BaseURLAction
@end
