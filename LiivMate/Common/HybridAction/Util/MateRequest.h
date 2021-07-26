//
//  Request.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 20..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PwdWrapper.h"

//#define Single_Task_Mode

static NSInteger TimeoutInterval = 40;

//로그아웃 에러코드(기동전문으로 초기화)
#define ERRCODE_AppReset			@"logout"

//로그아웃 처리후 메인화면
#define ERRCODE_AppLogOut			@"2031"

//블럭체인 에러, 키쌍삭제
#define ERRCODE_BlockChain			@"1000"

//긴급공지 에러코드
#define ERRCODE_AppExitNotic		@"2030"
//앱종료 에러코드(일시정지(관리자, 사고신고, 장기미사용, 부정사용), 가입정지(블랙리스트), 중복로그인)
#define ERRCODE_AppExitErr			@"2004,2013,2022,2029,"ERRCODE_AppExitNotic

//인증관련에러 (회원가입 페이지 이동)
#define ERRCODE_UserCertiErr		@"2009,2026,2027"

//비밀번호 오류
#define ERRCODE_PinErr				@"5011"
//비밀번호 오류횟수 초과(비밀번호 찾기 화면이동)
#define ERRCODE_PinMaxErr			@"2006"

//비정상 접근 for jail break...etc
#define ERRCODE_AbnormalStat        @"4444"

//넷퍼넬 block코드
#define ERRCODE_NETFUNNEL_BLOCK     @"netfunnel_block"
#define ERRCODE_NETFUNNEL_STOP      @"netfunnel_STOP"

//세션체크를 하지않는 전문 추가 PATH
#define NONE_SESSION				@"KBC/"

#define IS_SUCCESS(resCode)			[@"0000" isEqualToString:resCode]

typedef void (^RequestFinish)(NSDictionary *result, NSString *rsltCode, NSString *message);
typedef void (^CompletionHandler)(NSData * data, NSURLResponse * response, NSError * error);

@class MateRequest;
typedef MateRequest Request;

@interface MateRequest : NSMutableURLRequest
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) NSString *requestServer;
@property (nonatomic, strong) NSDictionary *param;
@property (nonatomic, assign) BOOL showLoading;
@property (nonatomic, assign) BOOL wait;
@property (nonatomic, assign) BOOL isJsCallback;
@property (nonatomic, assign) BOOL isEnc;
@property (nonatomic, assign) NSString * trxCd;
@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic, unsafe_unretained) id own;

+(void)requestID:(NSString*)requestID
			body:(NSDictionary*)body
		pinKeyNm:(NSString*)keyNm
   showLoading:(BOOL)show cancelOwn:(id)own
		finished:(RequestFinish)finished;

+(void)requestID:(NSString*)requestID
			body:(NSDictionary*)body
		pinKeyNm:(NSString*)keyNm
		 setting:(PwdWrapperSetting)settingCallBack
	 showLoading:(BOOL)show cancelOwn:(id)own
		finished:(RequestFinish)finished;

+(void)requestID:(NSString*)requestID
			body:(NSDictionary*)body
   waitUntilDone:(BOOL)wait showLoading:(BOOL)show cancelOwn:(id)own
		finished:(RequestFinish)finished;

+(void)requestID:(NSString*)requestID
		 message:(NSString *)message
			body:(NSDictionary*)body
   waitUntilDone:(BOOL)wait showLoading:(BOOL)show cancelOwn:(id)own
		finished:(RequestFinish)finished;

+(void)requestID:(NSString*)requestID
         message:(NSString *)message
            body:(NSDictionary*)body
   waitUntilDone:(BOOL)wait showLoading:(BOOL)show cancelOwn:(id)own
    isJsCallback:(BOOL)isJsCallback
           isEnc:(BOOL)isEnc
           trxCd:(NSString *)trxCd
        finished:(RequestFinish)finished;

+(void)requestServer:(NSString*)serverUrl
      message:(NSString *)message
         body:(NSDictionary*)body
waitUntilDone:(BOOL)wait showLoading:(BOOL)show cancelOwn:(id)own
 isJsCallback:(BOOL)isJsCallback
        isEnc:(BOOL)isEnc
        trxCd:(NSString *)trxCd
     finished:(RequestFinish)finished;

-(void)setCallback:(RequestFinish)callBack;
-(BOOL)send;
-(void)sendDataTask:(CompletionHandler)completionHandler;
-(BOOL)cancel;
-(void)remove;

+(void)removeRequest:(Request*)request;
+(void)cancelRequestAll;
+(void)cancelRequestWithOwn:(id)own;
+(void)sendKeepAlive:(void (^)(void))callback;
+(void)sendKeepAlive:(BOOL)showLaunchImage callback:(void (^)(void))callback;
+(void)stopKeepAlive;
+(BOOL)isSendKeepAlive;
+(NSDictionary*)httpHeader;
@end

/**
 @brief RequestID : 바코드결제 - 카드및 결제정보 획득 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA001            =    @"KATA001";

/**
 @brief RequestID : 바코드결제 - OTC생성 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA002            =    @"KATA002";

/**
 @brief RequestID : QR코드 결제금액 확인 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA003            =    @"KATA003";

/**
 @brief RequestID : QR코드 결제요청 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA004            =    @"KATA004";

/**
 @brief RequestID : 위젯 포인트리 조회(세션 없음) - Ver. 3 거래 코드 변경
 */
static NSString *const KATPH01            =    @"KATPH01";

/**
 @brief RequestID : 화면URL조회 - Ver. 3 거래 코드 변경
 */
static NSString *const KATW003            =    @"KATW003";

/**
 @brief RequestID : 충전수단 카드 등록/삭제 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPC13            =    @"KATPC13";

/**
 @brief RequestID : 주소록 회원여부 체크 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPS16            =    @"KATPS16";

/**
 @brief RequestID : 친구 목록 조회 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPS17            =    @"KATPS17";

/**
 @brief RequestID : 커뮤니티 주소록 목록 조회
 */
static NSString *const M71200			=	@"M71200";

/**
 @brief RequestID : SSG 교환 요청 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPE38            =    @"KATPE38";

/**
 @brief RequestID : 제휴사 교환요청 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPE07            =    @"KATPE07";

/**
 @brief RequestID : 광고ID 저장
 */
static NSString *const P00908			=	@"P00908";

/**
 @brief RequestID : 주소록 회원정보 조회 (Array로 관리) - Ver. 3 거래 코드 변경
 */
static NSString *const KATPS13            =    @"KATPS13";

/**
 @brief RequestID : 계좌 충전 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPC04            =    @"KATPC04";

/**
 @brief RequestID : 자동 충전 등록/해지 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPC09            =    @"KATPC09";

/**
 @brief RequestID : 비밀번호 변경 - Ver. 3 거래 코드 변경
 */
static NSString *const KATL020            =    @"KATL020";

/**
 @brief RequestID : 계죄 등록/해지 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPC19            =    @"KATPC19";

/**
 @brief RequestID : 고객 서비스 해지 - Ver. 3 거래 코드 변경
 */
static NSString *const KATJ033            =    @"KATJ033";

/**
 @brief RequestID : 비밀번호 검증 - Ver. 3 거래 코드 변경
 */
static NSString *const KATL010            =    @"KATL010";

/**
 @brief RequestID : 로그인 - Ver. 3 거래 코드 변경
 */
static NSString *const KATL001          =    @"KATL001";

/**
 @brief RequestID : 비밀번호 재설정 - Ver. 3 거래 코드 변경
 */
static NSString *const KATJ023            =    @"KATJ023";

/**
 @brief RequestID : KeepAlive - Ver. 3 거래 코드 변경
 */
static NSString *const KATA014            =    @"KATA014";

/**
 @brief RequestID : 기부하기 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA015            =    @"KATA015";

/**
 @brief RequestID : 충전하기 CI조회 - Ver. 3 거래 코드 변경
 */
static NSString *const KATPC20            =    @"KATPC20";

/**
 @brief RequestID : 가맹점 P2P결제 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA016            =    @"KATA016";

/**
 @brief RequestID : 가맹점 P2P결제 취소 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA017            =    @"KATA017";

/**
 @brief RequestID : 가맹점 계좌 입금 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA018            =    @"KATA018";

/**
 @brief RequestID : 블럭체인 실패통계 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA022            =    NONE_SESSION@"KATA022";

/**
 @brief RequestID : 블럭체인 인증서등록 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA023            =    NONE_SESSION@"KATA023";

/**
 @brief RequestID : 블럭체인 인증서 검증용 Challenge요청 - Ver. 3 거래 코드 변경
 */
static NSString *const KATA024            =    NONE_SESSION@"KATA024";

/**
 @brief RequestID : FIDO 인증내역 등록
 */
static NSString *const KATWA19            =    NONE_SESSION@"KATWA19";

/**
@brief RequestID : 회원가입페이지 호출 URL
*/
static NSString *const KATJ031            =   @"KATJ031";

/**
 @brief RequestID : 전용카드 결제멤버십 ID설정  - Ver. 3 거래 코드 변경
 */
static NSString *const KATJ032            =   @"KATJ032";

/**
@brief RequestID : 메뉴팝업공지 (운영에서 추후 개발진행이 될 수 있어 추가)
*/
static NSString *const KATW002            =    @"KATW002";
