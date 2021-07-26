//
//  OPsignService.h
//  CoinPlugOPsignKit
//
//  앱의 요청을 실행하고, 결과를 전달하는 모듈로 OPSignService, OPKeyData 클래스를 제공
//
//  Created by ParkByungho on 2016. 8. 5..
//  Copyright © 2016년 coinplug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPKeyData.h"


@interface OPsignService : NSObject

/**
 * @brief 키를 생성한다.
 * @exception CPRootedDeviceException,
 *            CPDeviceNotSupportedException,
 *            CPOSVersionNotSupportedException,
 *            CPKeyPairAlreadyExistException,
 *            CPKeyPairCreationException
 * @return 키 생성 여부.
 * @author byungho park
 */
-(Boolean)createKeyPair;

/**
 * @brief PinCode를 이용하여 키를 생성한다.
 * @exception CPRootedDeviceException,
 *            CPDeviceNotSupportedException,
 *            CPOSVersionNotSupportedException,
 *            CPKeyPairAlreadyExistException,
 *            CPKeyPairCreationException
 * @return 키 생성 여부.
 * @author byungho park
 */
-(Boolean)createKeyPairByPinCode;

/**
 * @brief 지문을 이용하여 키를 생성한다.
 * @exception CPRootedDeviceException,
 *            CPDeviceNotSupportedException,
 *            CPOSVersionNotSupportedException,
 *            CPKeyPairAlreadyExistException,
 *            CPKeyPairCreationException
 * @return 키 생성 여부.
 * @author byungho park
 */
-(Boolean)createKeyPairByTouch;

/**
 * @brief KeyPair를 삭제 한다.
 * @exception CPRootedDeviceException,
 *            CPDeviceNotSupportedException,
 *            CPOSVersionNotSupportedException,
 *            CPKeyPairNotExistException,
 * @return 삭제 여부.
 * @author byungho park
 */
-(Boolean)deleteKeyPair;

/**
 * @brief PublicKey를 OPKeyData구조에 담아 반환한다.
 * @exception CPRootedDeviceException,
 *            CPDeviceNotSupportedException,
 *            CPOSVersionNotSupportedException,
 *            CPKeyPairNotExistException,
 *            CPPubkeyRetrievalException
 * @return 생성된 OPKeyData.
 * @author byungho park
 */
-(OPKeyData*)getPublicKey;

/**
 * @brief DATA를 서명하여 OPKeyData구조에 담아 반환한다.
 * @param data 서명할 Data.
 * @exception CPRootedDeviceException,
 *            CPDeviceNotSupportedException,
 *            CPOSVersionNotSupportedException,
 *            CPKeyPairNotExistException,
 *            CPSigningException
 * @return 생성된 OPKeyData.
 * @author byungho park
 */
-(OPKeyData*)signData:(NSString*)data;

@end
