//
//  PwdWrapper.h
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2019. 2. 26..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

// 통신시 메세지 처리관련 define
typedef NS_ENUM(NSUInteger, keypadType) {
    keypadTypePenta = 0,     // 펜타키패드
    keypadTypeRaon = 1,     // 라온키패드
};

#define PWD_PIN_MAX_LEN 6

typedef void (^PwdWrapperFinish)(id vc, BOOL isCancel, BOOL *dismiss);
typedef void (^PwdWrapperSetting)(id vc);

@interface PwdWrapper : NSObject

+ (PwdWrapper *)shared;
@property(nonatomic, retain)UIViewController *pwdPinVC;
@property(nonatomic, retain)UIViewController *pwdCertVC;

+(void)setTitle:(id)vc value:(NSString *)title;
+(void)setSubTitle:(id)vc value:(NSString *)subTitle;
+(void)setInfoMsg:(id)vc value:(NSString *)infoMsg;
+(void)setShowPwdResetBtn:(id)vc value:(BOOL)showPwdResetBtn;
+(void)setMaxLen:(id)vc value:(int)maxLen;
+(void)setMinLen:(id)vc value:(int)minLen;
+(void)setKeyPadTypeCert:(id)vc;
+(void)setTag:(id)vc tag:(NSInteger)tag;
+(NSInteger)getTag:(id)vc;
+(BOOL)getResetPWClecked:(id)vc;
+(Class)pwdClass;

+(NSString *)doublyEncrypted:(id)vc keyNm:(NSString*)keyNm;
+(NSString*)encText:(id)vc;
+(NSString*)encryptedDictionary:(NSDictionary*)dic;
+(void)deleteBlockChain;
+(NSDictionary*)blockChainWithKeyNm:(id)vc keyNm:(NSString *)keyNm;
+(void)resetPwd:(id)vc;

+(BOOL)isShowPwd:(ViewController *)currVc;
+(void)showCertPwd:(PwdWrapperSetting)settingCallBack callBack:(PwdWrapperFinish)callBack;
+(void)showPwd:(PwdWrapperSetting)settingCallBack callBack:(PwdWrapperFinish)callBack;
//블럭체인 전문및 FIDO 사용전문시...
+(void)showPwd:(PwdWrapperSetting)settingCallBack target:(NSString*)requestID callBack:(PwdWrapperFinish)callBack;

+(void)setTimeStamp:(double)timestamp;
+(double)timeStamp;
+(void)loadResource;

@end

NS_ASSUME_NONNULL_END
