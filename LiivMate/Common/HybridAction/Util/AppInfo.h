//
//  AppInfo.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 20..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

typedef void (^SuccessCallBack)(BOOL success);
typedef void (^SuccessLoginCallBack)(BOOL success, NSString *errCD, NSDictionary* result);
typedef void (^VoidCallBack)(void);

typedef NS_ENUM(NSUInteger, UseBiometrics) {
	UseBiometricsNone,
	UseBiometricsDisabled,
	UseBiometricsEnabled,
    UseBiometricsServerDisableFaceID,
};

typedef NS_ENUM(NSUInteger, TypeBiometrics) {
    TypeTouchID,
    TypeFaceID,
};

@interface AppInfo : NSObject
@property (nonatomic, strong) NSString *pureAppToken;
@property (nonatomic, readonly) NSString *platform;
@property (nonatomic, readonly) NSString *appVer;
@property (nonatomic, readonly) NSString *managerVer;
@property (nonatomic, readonly) NSString *osVer;
@property (nonatomic, readonly) NSString *sysNm;
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSData *pushToken;
@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic, assign) UseBiometrics useBiometrics;
@property (nonatomic, assign) TypeBiometrics typeBiometrics;
@property (nonatomic, strong) NSError *lastBiometricsError;

//@property (nonatomic, strong) NSString *accessToken; // OPEN API(계좌 잔액/거래내역 조회) 사용을 위한 인증 값(10분동안 사용 안하면 expired 됨)
//@property (nonatomic, strong) NSString *samlAssertion; //
//@property (nonatomic, strong) NSMutableArray * accessTokens; // OPEN API(계좌 잔액/거래내역 조회) 사용을 위한 인증 값(10분동안 사용 안하면 expired 됨)
//@property (nonatomic, strong) NSMutableArray * samlAssertions;
@property (nonatomic, strong) NSMutableDictionary * openApiAuthTokens;
@property (nonatomic, strong) NSMutableDictionary * cooconTokens; // 쿠콘 비밀번호 리스트

@property (nonatomic, strong) NSString *ktUcloudAuthToken; // KT Ucloud API(컨테이너 생성, 파일 업로드/다운러드) 사용을 위한 인증 값(24시간이 최대 유효 시간)
@property (nonatomic, strong) NSString *ktStroageUrl; // KT Ucloud API(이미지 업로드/다운로드 url)
@property (nonatomic, assign) float lcdBrightnessValue; // 바코드 표시할때, 화면 최대 밝게 한뒤에 원래 밝기로 하기 위해

//앱관리
@property (nonatomic, strong) NSDictionary *notice;
@property (nonatomic, strong) NSString *isFaceEnable; // FaceID 사용 여부
@property (nonatomic, strong) NSString *tablePayShowGbn; // 테이블페이 스킴처리 여부
@property (nonatomic, strong) NSString *isBlockChainEnable; // 블록체인 사용 여부
@property (nonatomic, strong) NSString *CONNCTLUSEYN; // 유량제어 사용 여부
@property (nonatomic, strong) NSString *appBarUseYn; // 가맹점 앱바 사용여부
@property (nonatomic, strong) NSString *setEfdsDataYn; //efds를 useragent에 포함하는지에 대한 여부

@property (nonatomic, assign) BOOL isTablePayCall; // 테이블페이관련 스킴호출을 했는지 유무
@property (nonatomic, strong) NSDictionary *tablePayParamInfo; // 테이블페이(okpos)로 부터 받은 스킴 파라메타

@property (nonatomic, strong) NSString *ktCloudApiKey; // KT UCloud TempUrl Key
@property (nonatomic, strong) NSString *ktCloudAuthUser; // KT UCloud API Key
@property (nonatomic, strong) NSString *ktCloudAuthKey; // KT UCloud 계정(이메일 주소 형식)
@property (nonatomic, strong) NSString *keypadType;     // 키페드 타입(1:라온, 0:펜타, 디폴트 라온)

@property (nonatomic, assign) BOOL isFidoActive; // 지문인증, 페이스아이디 사용 중 앱 백그라운드 이미지 변경 방지용 플레그
@property (nonatomic, assign) BOOL isIdfaDisable; // IDFA 사용여부

@property (nonatomic, strong) NSMutableDictionary * encUrlData; // 암호화 해야할 url 리스트
@property (nonatomic, strong) NSMutableDictionary * themeData; // 스플레이 이미지 다운로드 데이타정보

@property (nonatomic, strong) NSDictionary * openUrlParam; // openUrl로 들어오는 파람 정보.

//WKWebView 최소버전
@property (nonatomic, strong) NSString *iosWkWebviewVsn;
-(void)setBenefitStTime:(NSString*)benefitStTime; //알림함 혜택채널 보여줄 start시간
-(long long)benefitStTime;
//수동로그아웃 여부
@property (nonatomic, assign) BOOL mnpcLogoutYn;

@property (nonatomic, readonly) BOOL isLogin;
@property (nonatomic, assign) BOOL isJoin;
@property (nonatomic, assign) BOOL autoLogin;


//연동 Url
@property (nonatomic, strong) NSString *updateUrl;//업데이트 URL
@property (nonatomic, strong) NSString *LGVODApi;//LG VOD포털
@property (nonatomic, strong) NSString *LGPrdtSrchAPI;
@property (nonatomic, strong) NSString *LGPayHisAPI;
@property (nonatomic, strong) NSString *tablePayUrl; //테이블 페이 url
@property (nonatomic, strong) NSString *ntsHomepageUrl; //국세청 홈페이지 url

@property (nonatomic, assign) int pwdErrNotms;//비밀번호 오류 횟수

@property (nonatomic, strong) NSString *semiMbrId; //준회원번호(푸시에 사용)
//로그인 정보
@property (nonatomic, retain) UserInfo *userInfo;
@property (nonatomic) NSString *point;//userInf의 point를 셋팅하고 post noti

+(AppInfo *)sharedInfo;
+(UserInfo *)userInfo;
-(void)reloadPoint;
-(void)logoutReset;
-(void)performLogin:(SuccessLoginCallBack)callback;
-(void)sendLoginRequestWithPwdDic:(NSDictionary *)pwdDic success:(SuccessLoginCallBack)callback;
-(void)performLogout:(SuccessCallBack)callback;
-(void)willEnterForeground:(id)noti;
-(void)clearCookie;
@end
