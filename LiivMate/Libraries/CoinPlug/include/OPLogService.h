//
//  OPLogService.h
//  CoinPlugOPsignKit
//
//  Created by coinplug on 2016. 8. 22..
//  Copyright © 2016년 coinplug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPKeyData.h"

@interface OPLogService : NSObject

/**
 * @brief 함수의 시작을 로그로 출력한다.
 * @param functionName 함수명.
 * @author byungho park
 */
+ (void) printStartFunctionLog:(NSString*)functionName;

/**
 * @brief 함수의 끝을 로그로 출력한다. 결과값이 존재할 경우 같이 출력한다.
 * @param functionName 함수명.
 * @param result 함수 실행 결과.
 * @author byungho park
 */
+ (void) printEndFunctionLog:(NSString*)functionName result:(NSString*)result;

/**
 * @brief 함수의 끝을 로그로 출력한다. 결과값이 존재할 경우 같이 출력한다.
 * @param functionName 함수명.
 * @param data 출력할 OPKeyData.
 * @author byungho park
 */
+ (void) printEndFunctionLog:(NSString*)functionName opKeyData:(OPKeyData*)data;

/**
 * @brief Exception 발생을 로그로 출력한다.
 * @param exception 발생한 Exception 이름.
 * @param message 발생한 Exception의 설명.
 * @author byungho park
 */
+ (void) printExceptionLog:(NSString*)exception message:(NSString*)message;

@end
