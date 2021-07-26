//
//  KBFidoManager.h
//  KBCardCommon
//
//  Created by 조휘준 on 2020/08/06.
//  Copyright © 2020 kbcard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CCUniSign/CCUniSign.h>
#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

// %%%%%%%% FIDO 적용 시 필독사항 %%%%%%%%
// 1. 운영/개발서버 확인하기 (한국전자인증 담당자에게 요청)
// 2. App별 라이센스 적용하기 (한국전자인증 담당자에게 App정보 전달 후 라이센스 요청)
// 3. App별 CCFido.dat, CCFido.conf 적용하기 (한국전자인증 담당자에게 요청)
// 4. App별 SERVICE_NAME 적용하기 (한국전자인증 담당자에게 전달해야 함)
// 상세 사항은 한국전자인증 적용가이드 문서 참고

typedef NS_ENUM(NSUInteger, FIDOType) {
    FIDOTypeReg = 0,    //등록
    FIDOTypeRegAuth,    //등록and인증
    FIDOTypeDeReg,      //해지
    FIDOTypeAuth        //인증,로그인
};

/// FIDO인증 completion block
/// @param result :  FIDO인증 결과
typedef void (^FidoCompletion)(BOOL success, ResultMessage * _Nullable result, NSError * _Nullable error);

@interface KBFidoManager : NSObject

@property (nonatomic, strong) NSArray *license;
@property (nonatomic, strong) NSString *fidoServerUrl;
@property (nonatomic, strong) NSString *fidoServiceName;

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *localizedMsg;
@property (nonatomic, assign) BOOL isRegAuth; //등록and인증 flag

+ (instancetype)sharedInstance;
- (void)initFido:(NSArray *)license;

/// FIDO 등록
/// @param completion  FIDO 등록 결과 block
- (void)registrationFido:(FidoCompletion)completion;

/// FIDO 등록and인증
/// @param completion  FIDO 등록and인증 결과 block
- (void)regAuthenticationFido:(FidoCompletion)completion;

/// FIDO 해지
/// @param completion  FIDO 해지 결과 block
- (void)deRegistrationFido:(FidoCompletion)completion;

/// FIDO 인증
/// @param completion  FIDO 인증 결과 block
- (void)authenticationFido:(FidoCompletion)completion;

/// Utility
/**
 @discussion TouchID 지원 가능 단말기 여부 판별
 */
-(BOOL)isAvailableTouchID;

/**
 @discussion TouchID 사용 가능 할 경우 등록 되어있는 지문이 있는지 확인
 */
-(BOOL)isTouchIDEnrolled;

/**
 @discussion Check if the device is an iPhone.
        단말기의 iPhone여부를 판별한다.
 @return Returns `true` if `Device` is iPhone.
 */
-(BOOL)isThisDeviceAniPhone;

/**
 @discussion Check the biometryType available on the device.
        단말기의 사용 가능한 BiometryType을 확인한다.
 @return
     BiometryNone : 0
     BiometryTypeTouchID : 1
     BiometryTypeFaceID : 2
 */
-(BiometryType)getBiometryType;

/**
@discussion dictionary형태를 JSONString형태로 변환한다.
@return Returns JSONString
*/
-(NSString *)dictionaryToJSONString:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
