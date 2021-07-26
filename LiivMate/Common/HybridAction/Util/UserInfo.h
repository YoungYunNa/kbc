//
//  UserInfo.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 8. 14..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////회원타입 구분코드////////////////////
// 일반 (liivmate4.0)
#define ShopMember_pUser4               @"pUser4"

///////////////////////////////////////////////
//메뉴 검색 키워드
#define MenuSearch_keyWordList          @"keyWordList"

@interface UserInfo : NSObject
//고객정보 일반
@property (nonatomic, strong) NSString *point;
@property (nonatomic, strong) NSString *age;//나이
@property (nonatomic, strong) NSArray *chnlList;//샌드버드 채널리스트
@property (nonatomic, strong) NSString *userAppMenuGbn; //가맹점 회원 구분코드
@property (nonatomic, strong) NSString *mbrmchJoinAblYn; //가맹점 원장 여부(가맹점 가입가능)
@property (nonatomic, strong) NSString *gender;//성별
@property (nonatomic, strong) NSString *semiMbrIdf;//준회원식별자 - push 추가
@property (nonatomic, strong) NSString *custGbnCd;//회원정보구분값 (GA360 4번째 값)

@property (nonatomic, strong) NSString *ga_starClubGrade;//스타클럽 등급(ga360)
@property (nonatomic, strong) NSString *ga_bamt;//보유 포인트(ga360)
@property (nonatomic, strong) NSString *ga_scrpTgFiorMduls;//자산연동금융기관(ga360)
@property (nonatomic, strong) NSString *ga_scrpTgFiorMdulsYN;//자산연동유무(ga360)
@property (nonatomic, strong) NSString *ga_chrgWayRegYn;//충전수단 등록 여부(ga360)
@property (nonatomic, strong) NSString *ga_autoChrgRegYn;//자동충전 등록 여부(ga360)
@property (nonatomic, strong) NSString *ga_cardOwnGbnCd;//카드보유여부(ga360)
@property (nonatomic, strong) NSString *ga_age;//연령대(ga360)
@property (nonatomic, strong) NSString *ga_gender;//성별(ga360)
@property (nonatomic, strong) NSString *ga_custGbnCd;//회원정보구분값;
@property (nonatomic, strong) NSString *ga_kbPinEnc;//kbpin 암호화값;
@property (nonatomic, strong) NSString *ga_semiMbrIdfEnc; // 준회원식별자 암호화값


//////////////////////암호화 저장/////////////////////////
@property (nonatomic, copy) NSString *custNo;//고객번호
@property (nonatomic, copy) NSString *custNm;//고객이름
@property (nonatomic, copy) NSString *mbspId;//멤버십ID
@property (nonatomic, copy) NSString *cId;//외부 공개용 ID
@property (nonatomic, copy) NSString *kbPin;//고객 고유정보
@property (nonatomic, copy) NSString *moblNo;//휴대폰번호
@property (nonatomic, copy) NSString *sendBirdToken;//샌드버드토큰
@property (nonatomic, copy) NSString *userCI; // OPEN API(계좌 잔액/거래내역 조회) 사용을 위해서 CI값을 임시적 보관(계좌충전 메뉴에서 사용, 고정값)
/////////////////////////////////////////////////////

//설정관련
@property (nonatomic, retain) NSString *pushUseRecv;//활동내역 푸시 설정
@property (nonatomic, retain) NSString *pushEvtRecv;//이벤트알림 푸시 설정
@property (nonatomic, retain) NSString *pushTermYn;//이벤트 푸시알림 약관동의

//스크래핑 연동유무 관련
@property (nonatomic, strong) NSString *scrpTgFiorMdulsYN;  //스크래핑 연동업권 유무
@property (nonatomic, strong) NSString *astTermYn;          //스크래핑 PFM동의 유무

@end
