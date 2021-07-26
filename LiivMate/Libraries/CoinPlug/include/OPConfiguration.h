//
//  OPConfiguration.h
//  CoinPlugOPsignKit
//
//  OPsign service 모듈의 인스턴스의 생성을 지원하며, OPConfiguration 클래스를 제공.
//
//  Created by ParkByungho on 2016. 8. 5..
//  Copyright © 2016년 coinplug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPsignService.h"

#define COPYRIGHT @"Copyright (C) 2013-2016 Coinplug, Inc. - All Rights Reserved\nUnauthorized copy of this file, via any medium is strictly prohibited\nProprietary and confidential"
#define VERSION @"1.0.7"

@interface OPConfiguration : NSObject

/**
 * @brief OPsign 서비스 인스턴스를 호출
 * @exception CPRootedDeviceException,
 *            CPDeviceNotSupportedException,
 *            CPOSVersionNotSupportedException
 * @return 생성된 OPsignService
 * @author byungho park
 */
+ (OPsignService*)getOPsignService;

/**
 * @brief SDK 버전을 조회하여 반환한다.
 * @return SDK 버전 정보.
 * @author byungho park
 */
+ (NSString*)getVersion;

/**
 * @brief Copyrighter 정보를 반환한다.
 * @return Copyrighter 정보.
 * @author byungho park
 */
+ (NSString*)getCopyright;

/**
 * @brief Console창에 로그를 출력할지 선택한다. 기본상태는 NO
 * @param show YES일 경우 출력 NO일경우 출력안함.
 * @author byungho park
 */
+ (void)showLog:(Boolean)show;

/**
 * @brief 로그출력 여부 값을 반환한다.
 * @return 로그 출력 설정 값 반환.
 * @author byungho park
 */
+ (Boolean)isShowLog;

@end
