//
//  YmmDeviceInfoUtil.h
//  기기 정보 관련 처리 유틸 클래스
//
//  Created by 박준오 on 13. 5. 10..
//  Copyright (c) 2013년 YHDatabase Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YmmDeviceInfoUtil : NSObject

@property (strong, nonatomic) NSString *serverUrlString;
@property (strong, nonatomic) NSString *encKeyString;
@property (strong, nonatomic) NSString *chkAppUrlScheme;
@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, unsafe_unretained) id eTarget;
@property (nonatomic, assign) SEL eSelector;

/* 기기 기본 정보 조회 함수 */
- (NSMutableDictionary *)getBasicDeviceInfo;
/* 기기 기본 정보 조회 함수 */

/* 기기 정보 조회 함수(일부 항목) */
- (NSMutableDictionary *)getDeviceInfo;
/* 기기 정보 조회 함수(일부 항목) */

/* 기기 정보 조회 함수(전체) */
- (NSMutableDictionary *)getAllDeviceInfo;
/* 기기 정보 조회 함수(전체) */

/* 서버 데이터 전송 함수 */
- (void)sendServerData:(NSDictionary *)params;
/* 서버 데이터 전송 함수 */

/* Http Request Delegate 설정 함수 */
- (void)setHttpUtilDelegate:(id)aTarget selector:(SEL)aSelector errTarget:(id)eTarget errSelector:(SEL)eSelector;
/* Http Request Delegate 설정 함수 */

/* 복호화 함수 */
+ (NSString *)decodeDeviceInfo:(NSString *)encStr encKey:(NSString *)encKeyStr;
/* 복호화 함수 */

/* JSON 문자열 생성 함수 */
+ (NSString *)makeJSONString:(NSMutableDictionary *)paramDict;
/* JSON 문자열 생성 함수 */
@end
