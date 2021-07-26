//
//  Permission.h
//  wibeetalk
//
//  Created by 최원식 on 2017. 11. 15..
//  Copyright © 2017년 wibeetalk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PERMISSION_DENIED = 0,//사용불가 선택
    PERMISSION_USE = 1,//사용선택
    PERMISSION_NOT_DETERMINED = 2,//선택되지 않음
    PERMISSION_DONT_USE = 3//사용할수 없음
} PERMISSION_STATUS;

typedef void (^PermissionCallback)(PERMISSION_STATUS statusNextProccess);

@interface Permission : NSObject

/*!
 * @discussion 연락처 접근 권한 체크
 * @param block 결과값 전달할 Block 함수
 */
+ (PERMISSION_STATUS)getContactsPermission;
+ (void)checkContactsSettingAlert:(BOOL)settingAlert permission:(PermissionCallback)block;

/*!
 * @discussion 카메라 접근 권한 체크
 * @param block 결과값 전달할 Block 함수
 */
+ (PERMISSION_STATUS)getCameraPermission;
+ (void)checkCameraSettingAlert:(BOOL)settingAlert permission:(PermissionCallback)block;

/*!
 * @discussion 앨범 접근 권한 체크
 * @param block 결과값 전달할 Block 함수
 */
+ (PERMISSION_STATUS)getPhotoLibraryPermission;
+ (void)checkPhotoLibrarySettingAlert:(BOOL)settingAlert permission:(PermissionCallback)block;

/*!
 * @discussion 위치 정보 권한 체크
 * @param block 결과값 전달할 Block 함수
 */
+ (PERMISSION_STATUS)getLocationPermission;
+ (void)checkLocationSettingAlert:(BOOL)settingAlert permission:(PermissionCallback)block;
+ (NSString *)getStartPointLocation;
/*!
 * @discussion 시스템 어플리케이션 설정 화면 호출
 */
+ (void)openApplicationSetting:(void (^)(void))foregroundCallback;

@end

