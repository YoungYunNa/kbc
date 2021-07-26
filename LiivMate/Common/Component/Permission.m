//
//  Permission.m
//  wibeetalk
//
//  Created by 최원식 on 2017. 11. 15..
//  Copyright © 2017년 wibeetalk. All rights reserved.
//

#import "Permission.h"

#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>

static Permission *permission = nil;


@import AVFoundation;
@import Photos;

@interface Permission () <CLLocationManagerDelegate>
{
    CLLocationManager *locManger;
}

@property (nonatomic, strong) PermissionCallback pCallback;
@property (nonatomic, strong) void (^foregroundCallback)(void);
@end


@implementation Permission

#pragma mark - ********** 연락처 접근 권한 정보 **********

+ (PERMISSION_STATUS)getContactsPermission
{
	__block PERMISSION_STATUS status = PERMISSION_DENIED;
	[self checkContactsSettingAlert:NO permission:^(PERMISSION_STATUS statusNextProccess) {
		status = statusNextProccess;
	}];
	return status;
}

+ (void)checkContactsSettingAlert:(BOOL)settingAlert permission:(PermissionCallback)block
{
    // 연락처 접근 권한 정보 가져오기
    CNEntityType entityType = CNEntityTypeContacts;
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:entityType];
    
    switch ( authorizationStatus )
    {
            // 아직 결정되지않음
        case CNAuthorizationStatusNotDetermined:
        {
			if(settingAlert)
			{
				if(IOS_VERSION_OVER_9)
				{
					CNContactStore *cs = [[CNContactStore alloc] init];
					[cs requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
						dispatch_async(dispatch_get_main_queue(), ^{
							if( granted )
							{
								// 허용 선택
								if(block)
									block(PERMISSION_USE);
							}
							else
							{
								// 거절 선택
								if(block)
									block(PERMISSION_DENIED);
							}
						});
					}];
				}
				else
				{
					if(block)
						block(PERMISSION_USE);
				}
			}
			else
			{
				if(block)
					block(PERMISSION_NOT_DETERMINED);
			}
			
        }
            break;
            // 거절한 상태
        case CNAuthorizationStatusDenied:
        {
			if(settingAlert)
			{
				[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"단말기의 [설정 > 개인정보보호 > 연락처]에서 설정을 변경해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
					if(buttonIndex == 1)
					{
						[self openApplicationSetting:^{
							[self checkContactsSettingAlert:NO permission:block];
						}];
					}
					else
					{
						if(block)
							block(PERMISSION_DENIED);
					}
				} cancelButtonTitle:@"취소" buttonTitles:@"설정", nil];
			}
			else
			{
				if(block)
					block(PERMISSION_DENIED);
			}
        }
            break;
            // 사용할 수 없는 상태
        case CNAuthorizationStatusRestricted:
        {
            if (settingAlert)
				[self showRestrictedAlert:@"연락처를 사용 할 수 없는 상태입니다."];
			if(block)
				block(PERMISSION_DONT_USE);
        }
            break;
            // 허용됨
        default:
        {
			if(block)
				block(PERMISSION_USE);
        }
            break;
    }
}

#pragma mark - ********** 카메라 접근 권한 정보 **********
+ (PERMISSION_STATUS)getCameraPermission
{
	__block PERMISSION_STATUS status = PERMISSION_DENIED;
	[self checkCameraSettingAlert:NO permission:^(PERMISSION_STATUS statusNextProccess) {
		status = statusNextProccess;
	}];
	return status;
}

+ (void)checkCameraSettingAlert:(BOOL)settingAlert permission:(PermissionCallback)block
{
    // 카메라 접근 권한 정보 가져오기
    NSString *mediaTypeStringCamera = AVMediaTypeVideo;
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:mediaTypeStringCamera];
    
    if (![inputDevice hasMediaType:mediaTypeStringCamera]) {
        // 사용할 수 없는 상태
        if (settingAlert)
			[self showRestrictedAlert:@"카메라를 사용 할 수 없는 상태입니다."];
		if(block)
			block(PERMISSION_DONT_USE);
        return;
    }
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:mediaTypeStringCamera]) {
            // 거절한 상태
        case AVAuthorizationStatusDenied:
        {
            if (settingAlert) {
				[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"단말기의 [설정 > 개인정보보호 > 카메라]에서 설정을 변경해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
					if(buttonIndex == 1)
					{
						[self openApplicationSetting:^{
							[self checkCameraSettingAlert:NO permission:block];
						}];
					}
					else
					{
						if(block)
							block(PERMISSION_DENIED);
					}
				} cancelButtonTitle:@"취소" buttonTitles:@"설정", nil];
            }
			else
			{
				if(block)
					block(PERMISSION_DENIED);
			}
        }
            break;
            // 사용할 수 없는 상태
        case AVAuthorizationStatusRestricted:
        {
            if (settingAlert)
                [self showRestrictedAlert:@"카메라를 사용 할 수 없는 상태입니다."];
			if(block)
				block(PERMISSION_DONT_USE);
        }
            break;
            // 아직 결정되지않음
        case AVAuthorizationStatusNotDetermined:
        {
			if (settingAlert)
			{
				[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
					dispatch_async(dispatch_get_main_queue(), ^{
						if( granted )
						{
							// 허용 선택
							if(block)
								block(PERMISSION_USE);
						}
						else
						{
							// 거절 선택
							if(block)
								block(PERMISSION_DENIED);
						}
					});
				}];
			}
			else
			{
				if(block)
					block(PERMISSION_NOT_DETERMINED);
			}
			
        }
            break;
            // 허용됨
        default:
        {
			if(block)
				block(PERMISSION_USE);
        }
    }
}

#pragma mark - ********** 앨범 접근 권한 정보 **********
+ (PERMISSION_STATUS)getPhotoLibraryPermission
{
	__block PERMISSION_STATUS status = PERMISSION_DENIED;
	[self checkPhotoLibrarySettingAlert:NO permission:^(PERMISSION_STATUS statusNextProccess) {
		status = statusNextProccess;
	}];
	return status;
}

+ (void)checkPhotoLibrarySettingAlert:(BOOL)settingAlert permission:(PermissionCallback)block {
    // 앨범 접근 권한 정보 가져오기
    switch ([PHPhotoLibrary authorizationStatus]) {
            // 거절한 상태
        case PHAuthorizationStatusDenied:
        {
            if (settingAlert) {
				[BlockAlertView showBlockAlertWithTitle:@"알림" message:@"단말기의 [설정 > 개인정보보호 > 사진]에서 설정을 변경해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
					if(buttonIndex == 1)
					{
						[self openApplicationSetting:^{
							[self checkPhotoLibrarySettingAlert:NO permission:block];
						}];
					}
					else
					{
						if(block)
							block(PERMISSION_DENIED);
					}
				} cancelButtonTitle:@"취소" buttonTitles:@"설정", nil];
            }
			else
			{
				if(block)
					block(PERMISSION_DENIED);
			}
        }
            break;
            // 사용할 수 없는 상태
        case PHAuthorizationStatusRestricted:
        {
            if (settingAlert)
                [self showRestrictedAlert:@"사진첩을 사용 할 수 없는 상태입니다."];
			if(block)
				block(PERMISSION_DONT_USE);
        }
            break;
            // 아직 결정되지않음
        case PHAuthorizationStatusNotDetermined:
        {
			if (settingAlert)
			{
				if(IOS_VERSION_OVER_8)
				{
					[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
						dispatch_sync(dispatch_get_main_queue(), ^{
							if (status == PHAuthorizationStatusAuthorized) {
								// 허용 선택
								if(block)
									block(PERMISSION_USE);
							}else {
								// 거절 선택
								if(block)
									block(PERMISSION_DENIED);
							}
						});
					}];
				}
				else
				{
					if(block)
						block(PERMISSION_USE);
				}
			}
            else
			{
				if(block)
					block(PERMISSION_NOT_DETERMINED);
			}
        }
            break;
            // 허용됨
        default:
        {
			if(block)
				block(PERMISSION_USE);
        }
    }
}

#pragma mark - ********** 위치 정보 권한 체크 **********
+ (PERMISSION_STATUS)getLocationPermission
{
    __block PERMISSION_STATUS status = PERMISSION_DENIED;
    [self checkLocationSettingAlert:NO permission:^(PERMISSION_STATUS statusNextProccess) {
        status = statusNextProccess;
    }];
    return status;
}

+ (void)checkLocationSettingAlert:(BOOL)settingAlert permission:(PermissionCallback)block
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            if(block)
                block(PERMISSION_USE);
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            if(block)
                block(PERMISSION_USE);
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            if (settingAlert)
            {
                if( permission == nil )
                {
                    permission = [[Permission alloc] init];
                }
                permission.pCallback = block;
                [permission locationExcuteForPermission];
            }
            else
            {
                if(block)
                    block(PERMISSION_NOT_DETERMINED);
            }
        }
            break;
        default:
        {
            if (settingAlert)
            {
                [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"단말기의 [설정 > 개인정보보호 > 위치]에서 설정을 변경해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
                    if(buttonIndex == 1)
                    {
                        if( buttonIndex == 1 )
                        {
                            [self openApplicationSetting:^{
                                [self checkLocationSettingAlert:NO permission:block];
                            }];
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(block)
                                    block(PERMISSION_DENIED);  // 0번 거부
                            });
                        }
                    }
                } cancelButtonTitle:@"취소" buttonTitles:@"설정", nil];
            } else {
                if(block)
                    block(PERMISSION_DENIED);
            }
        }
            break;
    }
}

#pragma mark - 위치동의여부 첫 선택 시 호출
- (void)locationExcuteForPermission
{
    NSLog(@"%s", __FUNCTION__);
    locManger = [[CLLocationManager alloc] init];
    [locManger setDelegate:self];
    [locManger requestWhenInUseAuthorization];
}

#pragma mark - Location Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if( status == kCLAuthorizationStatusNotDetermined )
    {
        return;
    }
    else if( status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways )
    {
        if( _pCallback )
        {
            _pCallback(PERMISSION_USE);
        }
    }
    else
    {
        if( _pCallback )
        {
            _pCallback(PERMISSION_DONT_USE);
        }
    }
    
    _pCallback = NULL;
    locManger = nil;
    permission = nil;
}

#pragma mark - 사용자 현재위치의 위/경도
+ (NSString *)getStartPointLocation {
    NSLog(@"%s", __FUNCTION__);
    // 위치정보
    CLLocationManager *locationManger = [[CLLocationManager alloc] init];
    // 정확도 관련
    locationManger.desiredAccuracy = kCLLocationAccuracyBest;
    // 위치 업데이트
    [locationManger startUpdatingLocation];
    NSLog(@"latitude == %f, longitude == %f", locationManger.location.coordinate.latitude, locationManger.location.coordinate.longitude);
        
    // 위/경도 값
    return [NSString stringWithFormat: @"%f,%f", locationManger.location.coordinate.latitude, locationManger.location.coordinate.longitude];
}

#pragma mark - 객체 해제됨
-(void)dealloc
{
	NSLog(@"dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)showRestrictedAlert:(NSString *)message {
	[BlockAlertView showBlockAlertWithTitle:@"알림" message:message?:@"사용할 수 없는 기기입니다." dismissedCallback:nil cancelButtonTitle:@"취소" buttonTitles:nil];
}

+ (void)openApplicationSetting:(void (^)(void))foregroundCallback {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    
	permission = [[Permission alloc] init];
	permission.foregroundCallback = foregroundCallback;
	[[NSNotificationCenter defaultCenter] addObserver:permission selector:@selector(enterForegroundNoti:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)enterForegroundNoti:(NSNotification*)noti
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if(self.foregroundCallback)
			self.foregroundCallback();
		
		[[NSNotificationCenter defaultCenter] removeObserver:permission];
		self.foregroundCallback = nil;
		permission = nil;
	});
}

@end
