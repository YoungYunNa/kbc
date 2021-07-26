//
//  IBProtocol.h
//  KBSmartPay
//
//  Created by admin on 2015. 8. 24..
//  Copyright (c) 2015년 Seeroo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 ** IPS에서 사용하는 enum과  Model을 관리하는 Class
 **
 **/

//알리미함 상태
typedef enum EN_INBOX_STATE
{
    InboxStateNone,   //viewWillAppear가 호출되기 이전시점
    InboxStateNormal, //view모드
    InboxStateDelete, //삭제모드
    InboxStateUpdate, //더보기 or 갱신모드
}InboxState;

//삭제 모드
typedef enum EN_DELETE_TYPE
{
    InboxDeleteTypeAll, //전체삭제
    InboxDeleteTypeCheck, //체크삭제
}InboxDeleteType;


typedef enum EN_ALERT_TYPE
{
    InboxAlertNotAvailable
} InboxAlertType;

//알림이 cell의 버튼 클릭
typedef enum EN_FEEDBACK_STATUS
{
    Feedback_Status_None = 1,
    Feedback_Status_Share,
    Feedback_Status_Like,
    Feedback_Status_Bookmark,
    Feedback_Status_Link,
}Feedback_Status;

@interface IBProtocol : NSObject

@end


//알리미함의 기본내역 Model
@interface InboxData : NSObject

@property (nonatomic) BOOL isFullMsg;                       //더보기 클릭 유무
@property (nonatomic) int64_t date;                         //발송 시간
@property (nonatomic) int64_t readTime;                     //읽음처리 시간
@property (nonatomic) int64_t exp;
@property (nonatomic) int64_t expiryTime;                   //만료시간
@property (nonatomic) int64_t categoryId;                   //카테로기 번호
@property (nonatomic, strong) NSString *contentKey;         //상세내역을 조회하기 위한 key
@property (nonatomic, strong) NSString *serverMessageKey;   //IbboxData의 key
@property (nonatomic, strong) NSString *title;              //제목
@property (nonatomic, strong) NSString *text;               //본문
@property (nonatomic, strong) NSString *like;               //좋아요 선택 유무 (true, false)
@property (nonatomic, strong) NSString *callback;           //고객센터번호 유무 (true, false)
@property (nonatomic, strong) NSString *bookmark;           //찜하기 선택 유무 (true, false)
@property (nonatomic, strong) NSArray *payloadList;         //치환문구

@end


//알림이의 상세내역 Model
@interface ContentPayLoadData : NSObject
{
    BOOL isEditMode;        //삭제모드 flag
    NSArray *imgs;          //이미지 경로
    NSString *report;       //
    NSString *schd_id;      //report key (report를 서버에 전송 시 필요)
    
    NSString *survey;       //설문 유무
    NSString *like;         //좋아요 유무
    NSString *link;         //링크 유무
    NSString *share;        //공유하기 유무
    NSString *favorite;     //찜하기 유무
    
    NSString *linkUrl;      //링크 url
    NSString *btn;          //버튼에 들어가는 text문구
}

@property(nonatomic) BOOL isEditMode;
@property(nonatomic, strong) NSArray *imgs;
@property(nonatomic, strong) NSString *report;
@property(nonatomic, strong) NSString *schd_id;
@property(nonatomic, strong) NSString *linkUrl;

@property(nonatomic, strong) NSString *survey;
@property(nonatomic, strong) NSString *like;
@property(nonatomic, strong) NSString *link;
@property(nonatomic, strong) NSString *share;
@property(nonatomic, strong) NSString *favorite;

@property(nonatomic, strong) NSString *btn;
@end
