//
//  MobileWeb+Fido.h
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2019. 3. 19..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "MobileWeb.h"
#import "KBFidoManager.h"


//인증방식 설정
@interface setAuthenticationType : MobileWeb    // param : @{@"authenticationType" : @"FIDO" or @"PASSWORD"}
// output param : 성공(없음)
@end

//지문인식 등록
@interface registerFido : MobileWeb        // param : 없음
// output param : 성공(없음), 실패(@{@"errorMessage" : 오류 메시지})
@end

//지문인식 해제
@interface deregisterFido : MobileWeb        // param : 없음
// output param : 성공(없음), 실패(@{@"errorMessage" : 오류 메시지})
@end
