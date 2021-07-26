//
//  KCLCommonHeader.h
//  LiivMate
//
//  Created by KB on 4/20/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLCommonHeader.h
@date 2021.04.20
@brief 공통 헤더 값
*/

#ifndef KCLCommonHeader_h
#define KCLCommonHeader_h

#import "RegistedPersonsList.h"
#import <CoreText/CoreText.h>
#import "Permission.h"
#import "EtcUtil.h"
#import "AllMenu.h"
#import "UIImageView+ImageURL.h"
#import "NSString+VersionCompare.h"
#import "NSDictionary+NSNull.h"
#import "URLAction.h"
#import "WebViewController.h"

/**
 @brief 메뉴 오픈 노티피케이션
 */
#define MenuOpenNotification                    @"MenuOpenNotification"
//포인트리 포인트 변경
#define ReloadPointNotification                 @"ReloadPointNotification"
//포인트리 가맹점포인트 변경
#define ReloadAffiliatePointNotification        @"ReloadAffiliatePointNotification"
//포인트리 현금화포인트 변경
#define ReloadCashPointNotification             @"ReloadCashPointNotification"
//앱 초기화시작
#define StartLiivMateNotification               @"StartLiivMateNotification"
//위변조통과
#define PureAppSuccessNotification              @"PureAppSuccessNotification"
/// 로그인 상태 변경 통지
#define LoginStatusChangedNotification          @"LoginStatusChangedNotification"

// 전체메뉴 항목 중 hidden상태를 변경하기 위한 통지
#define MenuViewReloadNotification              @"MenuViewReloadNotification"
// GNB 타입 변경 노티피케이션
#define GNBTypeChangedNotification              @"GNBTypeChangedNotification"

//QR 팝업 내리기 노티피케이션
#define HideQRNotification                      @"HideQRNotification"

//MateRequest 쿠키 노티피케이션
#define MateRequestCookieNotification           @"MateRequestCookieNotification"

// splash 다운로드 완료 노티피케이션
#define SplashImageDownloadNotification         @"SplashImageDownloadNotification"

//스토어 다운로드 메크로
#define STORE_LINK(appId)                       @"http://itunes.apple.com/kr/app/"appId@"?mt=8"
#define APP_STORE_ID                            @"id1170306387"

//모바일홈 앱관련
#define CARDAPP_SCHEME                          @"kbkookmincard://"
#define CARDAPP_STORE_ID                        @"id509382678"
#define CARDAPP_IMAGELINK                       @"https://img1.kbcard.com/LT/cxh/images/ewallet/contents/kbapp_card.png"

//버즈빌 개발
#if DEBUG
#define BUZZ_FEED_APP_ID                        @"483179397716064"
#define BUZZ_FEED_UNIT_ID                       @"390052094496779"
#else// 운영
#define BUZZ_FEED_APP_ID                        @"196285242512045"
#define BUZZ_FEED_UNIT_ID                       @"87584960665423"
#endif

#define ACTION_CALL_MOVE_TO_PARAM_INFO          @"ACTION_CALL_MOVE_TO_PARAM_INFO"

#define AlertConfirm                            @"확인"
#define AlertCancel                             @"취소"

#define INCH4_HEIGHT                [UIScreen mainScreen].bounds.size.height == 568 ? @"568" : NULL

#define IS_IPAD                        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_6PLUS                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 736)
#define IS_IPHONE_6                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE_5                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE_4                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE_X                    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 812)

#define IOS_VERSION_OVER_6            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 ? YES : NO)
#define IOS_VERSION_OVER_7            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? YES : NO)
#define IOS_VERSION_OVER_8            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)
#define IOS_VERSION_OVER_9            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? YES : NO)
#define IOS_VERSION_OVER_10            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 ? YES : NO)
#define IOS_VERSION_OVER_11            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0 ? YES : NO)
#define IOS_VERSION_OVER_12            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12.0 ? YES : NO)

#define IPHONE_H(IPHONE_5,IPHONE_4) (CGFloat)((IS_IPHONE_4) ? (IPHONE_4) : (IPHONE_5))

#define IS_USE_WKWEBVIEW            (isUseWkWebView())

#define kScreenBoundsWidth          [[UIScreen mainScreen] bounds].size.width
#define kScreenBoundsHeight         [[UIScreen mainScreen] bounds].size.height
#define kIndicatorHeight            ( (IOS_VERSION_OVER_7) ? 20 : 0 )
#define kNavigationHeight           64
#define kToolBarHeight              45
#define kSideMenuWidth              292


#define APP_DELEGATE                (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define APP_MAIN_VC                 ((UINavigationController*)AllMenu.delegate)
#define APP_VERSION                    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_BUNDLE_ID                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define APP_BUNDLE_NAME                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]


#define FONTSIZE(pt)                [UIFont systemFontOfSize:pt]
#define BOLDFONTSIZE(pt)            [UIFont boldSystemFontOfSize:pt]

#define radians(Degrees)            (Degrees * M_PI/180)
#define degreesToRadian(x)            (M_PI * (x) / 180.0)
#define radianToDegrees(x)            ((x) * 180.0 / M_PI)
#define FONTSIZE(pt)                [UIFont systemFontOfSize:pt]
#define BOLDFONTSIZE(pt)            [UIFont boldSystemFontOfSize:pt]


#define nilCheck(str)                (str==nil || [str isEqualToString:@""] || [str isKindOfClass:[NSNull class]])
#define nil2Str(str)                nilCheck(str) ? @"" : str


// 라온키페드 관련
#define KEY_KEYPAD_TYPE             @"keypadType"
#define KEY_KEYPAD_VALUE            @"1"


//#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBWithAlpha(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define COLOR_WHITE                            [UIColor whiteColor]
#define COLOR_BLACK                            [UIColor blackColor]
#define COLOR_BLUE                             [UIColor blueColor]
#define COLOR_RED                              [UIColor redColor]
#define COLOR_YELLOW                           [UIColor yellowColor]
#define CLEARCOLOR                             [UIColor clearColor]

#define COLOR_MAIN_PURPLE                      UIColorFromRGB(0x5D59E6)  // 93, 89, 230 device color rgb
#define COLOR_MAIN_GRAY                        UIColorFromRGB(0x888888)  // 136, 136, 136 device color rgb
#define COLOR_LINE_GRAY                        UIColorFromRGB(0xEBEBEB)  // 235, 235, 235 device color rgb


#define DOCUMENT_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]

//고객센터 전화번호
#define CustomerCenter_NO    @"1644-9311"

#define KB_BANK_CODE        @"004"

//연락처 정보에서 사용할 키
#define KEY_NAME            @"frdNm"            //이름
#define KEY_NUM             @"frdMoblNo"        //폰 번호
#define KEY_GROUP           @"grpNm"            //그룹명
#define KEY_GROUP_ID        @"grpId"            //그룹ID
#define KEY_ARR_GROUP       @"KEY_ARR_GROUP"    //공통 그룹 배열
#define KEY_MONEY           @"KEY_MONEY"        //금액 (사용하는 부분에서만 사용)
#define KEY_CID             @"KEY_CID"          // CID

#define NAME_NONSELECTED    @"미지정"

// 바이오 인증 문구
#define TouchIdChangeMsg            @"스마트폰의 생체정보가 변경되었습니다.\n\n설정에서 지문을 재등록하면\n정상 이용이 가능합니다."
#define TouchIdLockoutMsg           @"스마트폰에서 Touch ID가 잠금상태로 되었습니다. '설정' > 'Touch ID 및 암호' 에서 스마트폰 암호를 입력하여 사용할 수 있도록 하십시요."
#define TouchIdPasscodeNotSetMsg    @"스마트폰에 지문이 등록되어 있지 않습니다. '설정' > 'Touch ID 및 암호' 에서 지문 등록 후 이용해 주시기 바랍니다."
#define TouchIdNotAvailableMsg      @"지문인식 서비스를 이용할 수 없는 기기입니다."
#define TouchIdRegFailMsg           @"지문인식 등록에 실패 하셨습니다."
#define TouchIdSkipMsg              @"지문등록을 건너뜁니다."
#define TouchIdAuthFailMsg          @"지문 인증에 실패 하였습니다."
#define TouchIdDiffMsg              @"스마트폰에 등록된 지문과 다릅니다."

#define FaceIdLockoutMsg            @"스마트폰에서 Face ID가 잠금상태로 되었습니다. '설정' > 'Face ID 및 암호' 에서 스마트폰 암호를 입력하여 사용할 수 있도록 하십시요."
#define FaceIdPasscodeNotSetMsg     @"스마트폰에 Face ID가 등록되어 있지 않습니다. '설정' > 'Face ID 및 암호' 에서 Face ID를 등록 후 이용해 주시기 바랍니다."
#define FaceIdNotAvailableMsg       @"Face ID 서비스를 이용할 수 없는 기기입니다."
#define FaceIdRegFailMsg            @"Face ID 등록에 실패 하였습니다."
#define FaceIdSkipMsg               @"Face ID 등록을 건너뜁니다."
#define FaceIdDiffMsg               @"스마트폰에 등록된 Face ID와 다릅니다."
#define FaceIdAuthFailMsg           @"Face ID 인증에 실패 하였습니다."

//보내기 관련 define
typedef NS_ENUM(NSInteger, sendType) {
    sendTypeAddress = 0,        //주소록, 커뮤니티
    sendTypeSelfInput,          //직접입력
    sendTypeCouple,             //커플/모임통장 회비
    sendTypeMy,                 //내계좌
    sendTypeLove,               //나라사랑통장계좌
};

//자동보내기 관련 define
typedef NS_ENUM(NSInteger, autoSendType) {
    autoSendTypeAddress = 0,    //주소록
    autoSendTypeInput,          //직접입력
    autoSendTypeCouple,         //커플/모임통장 회비
    autoSendTypeLove,           //나라사랑통장계좌
};

//커뮤니티 define
#define communityTag            5555
#define bankHomeTag             7777

//QR코드관련
#define QR_SCHEME            @"liivmate"
#define QR_INTENT_FM        @"fleamarket"
#define QR_INTENT_AF        @"affiliate"

//Fido관련
#define FIDO_LICENSE        @[@"FjwmADokKwE5LTs3FSY8KyYuBBHi+vyckOf8pmr2/f+p6pGTn4XrDT0DGj8QABoWChUBfmZ1cWdkeHp3cnxjdG5gf2Fjc31gYDAPcn1qYmFzdgQxYy8zLiY0AxYKHxQ9KGB+eBAVDiUNGAMKCh9ueA=="]
#define FIDO_SERVICE_NAME   @"com.kbcard.kat.liivmate"

inline static NSString * encodingQR(NSDictionary *param, NSString *intent)
{
    if(param) {
        return [NSString stringWithFormat:@"%@://%@?param=%@",QR_SCHEME,intent,param.jsonString.encryptAes256.stringByUrlEncoding];
    }
    return nil;
};

inline static NSDictionary * decodingQR(NSString *qrString, NSString*intent) {
    NSURL *url = [NSURL URLWithString:qrString];
    if([url.host isEqualToString:intent] && [url.scheme isEqualToString:QR_SCHEME]) {
        NSDictionary *param = [EtcUtil parseUrl:url.query];
        NSString *value = [param objectForKey:@"param"];
        return value.stringByUrlDecoding.decryptAes256.jsonObject;
    }
    return nil;
};

inline static BOOL isUseWkWebView() {
    // ???? for test
    //return FALSE;
    
    if (@available(iOS 11.0, *)) {
        if ([AppInfo sharedInfo].iosWkWebviewVsn.length > 0) {
            int compareCount = 3;
            
            NSString *minVersion = [AppInfo sharedInfo].iosWkWebviewVsn;
            NSMutableArray *minArray = [NSMutableArray arrayWithArray:[minVersion componentsSeparatedByString:@"."]];
            while (minArray.count < compareCount) {
                [minArray addObject:@"0"];
            }
            
            NSString *osVersion = [[UIDevice currentDevice] systemVersion];
            NSMutableArray *osArray = [NSMutableArray arrayWithArray:[osVersion componentsSeparatedByString:@"."]];
            while (osArray.count < compareCount) {
                [osArray addObject:@"0"];
            }
            
            for (int i=0; i<compareCount; i++) {
                if ([osArray[i] intValue] < [minArray[i] intValue]) return FALSE;
            }
        }

        return TRUE;
    }
    else return FALSE;
};

inline static BOOL isFaceID() {
    return [AppInfo sharedInfo].typeBiometrics == TypeFaceID;
};

#endif /* KCLCommonHeader_h */
