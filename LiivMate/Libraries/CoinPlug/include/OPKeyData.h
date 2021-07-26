//
//  OPKeyData.h
//  CoinPlugOPsignKit
//
//  Created by ParkByungho on 2016. 8. 5..
//  Copyright © 2016년 coinplug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPKeyData : NSObject

/**
 *  기기 식별 값 - ex)65ACEAD5-0169-4BAF-8A05-2CC401DE0999
 */
@property (nonatomic, strong) NSString* deviceId;

/**
 *  기기 모델명 - ex)iPhone8,1
 */
@property (nonatomic, strong) NSString* deviceModel;

/**
 *  앱 식별값 - ex)com.coinplug.demo.kb
 */
@property (nonatomic, strong) NSString* appId;

/**
 *  OPsign service의 동작을 완료한 후 결과 값
 */
@property (nonatomic, strong) NSString* opData;

/**
 *  암호화 알고리즘 타입
 */
@property (nonatomic, strong) NSString* cryptoType;

@end


