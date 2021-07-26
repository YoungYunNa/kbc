//
//  UserDefaults.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 21..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PureAppLib.h"
#import "CertificationManager.h"
typedef NS_ENUM(NSUInteger, FidoUseSetting) {
	FidoUseSettingNone,
	FidoUseSettingDisabled,
	FidoUseSettingEnabled,
};

@interface UserDefaults : NSObject
@property (nonatomic)   NSString *appID;
@property (nonatomic)   NSString *splashVer;
@property (nonatomic)   NSString *gatheringOrderType;

@property (nonatomic)   NSString *certUserPw;
@property (nonatomic)   NSString *userRrno;
@property (nonatomic)   NSString *userPW;
@property (nonatomic)   NSString *userID;
@property (nonatomic)   NSString *userAccountNumber;
@property (nonatomic)   NSString *userAccountPassword;

@property (nonatomic)	BOOL showTutorial;
@property (nonatomic)	BOOL showDeviceUseAgreement;
@property (nonatomic)	BOOL showMainTutorial;
@property (nonatomic)	BOOL isFirstRun;
@property (nonatomic)   BOOL isRegistedFido;
@property (nonatomic)   BOOL isPort;
@property (nonatomic)	FidoUseSetting useFido;
@property (nonatomic)   BOOL isFidoTestTOBE;

//개발용 테스트 벨류 : 개발 완료시 제거.
@property (nonatomic)    BOOL isLiveMate3DataValidationCheck;
@property (nonatomic)    BOOL isLiveMate3DataValidationCheckDummy;
@property (nonatomic)    BOOL isLiveMate3UINavigationCheck;
@property (nonatomic)    BOOL isLiveMate3UINavigationCheckDummy;
@property (nonatomic)    BOOL isLiveMate3Dummy1;
@property (nonatomic)    BOOL isLiveMate3Dummy2;
@property (nonatomic)    BOOL isLiveMate3Dummy3;
@property (nonatomic)    BOOL isLiveMate3Dummy4;
@property (nonatomic)    BOOL isLiveMate3Dummy5;

@property (nonatomic)   PureAppLib *recentPureLib;
@property (nonatomic)   NSString *recentPureAppDataString;
@property (nonatomic)   NSString *recentPureAppDataStringV2;
@property (nonatomic)   NSString *recentPureAppDataStringV3;
@property (nonatomic)   NSString *recentPureAppDataDecryptString;


//공지사항 오늘 하루 안보기 체크
-(BOOL)checkDayNoticeNo:(NSString*)noticeNo update:(BOOL)upDate;
//공지사항 더이상 안보기 체크
-(BOOL)checkNoticeNo:(NSString*)noticeNo update:(BOOL)upDate;
//트리거이벤트 오늘하루 안보기 체크
-(BOOL)checkTrgPageId:(NSString*)pageId update:(BOOL)upDate;
-(void)removeCheckTrgFlag;
+(UserDefaults *)sharedDefaults;
-(void)setObject:(NSString*)anObject forKey:(NSString*)aKey;
-(void)setValue:(NSString*)value forKey:(NSString *)key;
-(id)objectForKey:(NSString*)aKey;
-(id)valueForKey:(NSString *)key;
-(void)removeAllObjects;
-(void)removeObjectForKey:(NSString*)key;
-(NSArray *)allKeys;
-(BOOL)synchronize;
-(void)joinReset;
@end
