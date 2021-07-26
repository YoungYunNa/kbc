//
//  PwdWrapper.m
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2019. 2. 26..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "PwdWrapper.h"
#import "PentaPinViewController.h"
#import "PwdPinViewController.h"
#import "PwdCertViewController.h"

@implementation PwdWrapper
static double _timeStamp = 0;
+ (PwdWrapper *)shared {
    static PwdWrapper *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self == [super init]) {
        
    }
    return self;
}
+(void)showCertPwd:(PwdWrapperSetting)settingCallBack callBack:(PwdWrapperFinish)callBack
{
    [PwdCertViewController showPwd:^(PwdCertViewController *vc) {
        settingCallBack(vc);
    } callBack:^(PwdCertViewController *vc, BOOL isCancel, BOOL *dismiss) {
        [self shared].pwdCertVC = vc;
        callBack(vc, isCancel, dismiss);
    }];
}
+(void)showPwd:(PwdWrapperSetting)settingCallBack callBack:(PwdWrapperFinish)callBack
{
    
    if ([[AppInfo sharedInfo].keypadType integerValue] == keypadTypePenta) {
        
        [PentaPinViewController showPenta:^(PentaPinViewController *vc) {
            settingCallBack(vc);
        } callBack:^(PentaPinViewController *vc, BOOL isCancel, BOOL *dismiss) {
            [self shared].pwdPinVC = vc;
            callBack(vc, isCancel, dismiss);
        }];
        
    } else {
        
        [PwdPinViewController showPwd:^(PwdPinViewController *vc) {
            settingCallBack(vc);
        } callBack:^(PwdPinViewController *vc, BOOL isCancel, BOOL *dismiss) {
            [self shared].pwdPinVC = vc;
            callBack(vc, isCancel, dismiss);
        }];
    }
}
//블럭체인 전문및 FIDO 사용전문시...
+(void)showPwd:(PwdWrapperSetting)settingCallBack target:(NSString*)requestID callBack:(PwdWrapperFinish)callBack
{
    if ([[AppInfo sharedInfo].keypadType integerValue] == keypadTypePenta) {
        
        [PentaPinViewController showPenta:^(PentaPinViewController *vc) {
            settingCallBack(vc);
        } target:requestID callBack:^(PentaPinViewController *vc, BOOL isCancel, BOOL *dismiss) {
            callBack(vc, isCancel, dismiss);
        }];
        
    } else {
        
        [PwdPinViewController showPwd:^(PwdPinViewController *vc) {
            settingCallBack(vc);
        } target:requestID callBack:^(PwdPinViewController *vc, BOOL isCancel, BOOL *dismiss) {
            callBack(vc, isCancel, dismiss);
        }];
    }
}

+(void)setTitle:(id)vc value:(NSString *)title
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        ((PentaPinViewController *)vc).title = title;
    } else if ([vc isKindOfClass:[PwdPinViewController class]]) {
        ((PwdPinViewController *)vc).title = title;
    }else {
        ((PwdCertViewController *)vc).title = title;
    }
}
+(void)setSubTitle:(id)vc value:(NSString *)subTitle
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        ((PentaPinViewController *)vc).subTitle = subTitle;
    } else {
        ((PwdPinViewController *)vc).subTitle = subTitle;
    }
}
+(void)setInfoMsg:(id)vc value:(NSString *)infoMsg
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        ((PentaPinViewController *)vc).infoMsg = infoMsg;
    } else {
        ((PwdPinViewController *)vc).infoMsg = infoMsg;
    }
}
+(void)setShowPwdResetBtn:(id)vc value:(BOOL)showPwdResetBtn
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        ((PentaPinViewController *)vc).showPwdResetBtn = showPwdResetBtn;
    } else {
        ((PwdPinViewController *)vc).showPwdResetBtn = showPwdResetBtn;
    }
}
+(void)setMaxLen:(id)vc value:(int)maxLen
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        ((PentaPinViewController *)vc).maxLen = maxLen;
    } else if ([vc isKindOfClass:[PwdPinViewController class]]) {
        ((PwdPinViewController *)vc).maxLen = maxLen;
    }else {
        ((PwdCertViewController *)vc).maxLen = maxLen;
    }
}
+(void)setMinLen:(id)vc value:(int)minLen
{
    if ([vc isKindOfClass:[PwdPinViewController class]]) {
        ((PwdPinViewController *)vc).minLen = minLen;
    }else {
        ((PwdCertViewController *)vc).minLen = minLen;
    }
}
+(void)setKeyPadTypeCert:(id)vc
{
    [((PwdCertViewController *)vc) setKeyPadTypeCert];
}

+(NSString *)doublyEncrypted:(id)vc keyNm:(NSString*)keyNm
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        return  [((PentaPinViewController *)vc) doublyEncrypted:keyNm];
    } else if([vc isKindOfClass:[PwdPinViewController class]]) {
        return  [((PwdPinViewController *)vc) doublyEncrypted:keyNm];
    } else {
        return  [((PwdCertViewController *)vc) doublyEncrypted:keyNm];
    }
}

+(NSString*)doublyEncrypted:(id)vc dataStr:(NSString*)dataStr key:(NSString*)key
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        return [PentaPinViewController doublyEncrypted:dataStr key:key];
    } else if([vc isKindOfClass:[PwdPinViewController class]]) {
        return  [((PwdPinViewController *)vc) doublyEncrypted:dataStr key:key];
    } else {
        return  [((PwdCertViewController *)vc) doublyEncrypted:dataStr key:key];
    }
}

+(NSString *)encText:(id)vc
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        return  [((PentaPinViewController *)vc) encText];
    } else if([vc isKindOfClass:[PwdPinViewController class]]) {
        return  [((PwdPinViewController *)vc) encText];
    } else {
        return  [((PwdCertViewController *)vc) encText];
    }
}

+(void)deleteBlockChain
{
    if ([[AppInfo sharedInfo].keypadType integerValue] == keypadTypePenta) {
        [PentaPinViewController deleteBlockChain];
    } else {
        [PwdPinViewController deleteBlockChain];
    }
}

+(NSDictionary*)blockChainWithKeyNm:(id)vc keyNm:(NSString *)keyNm
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        return  [((PentaPinViewController *)vc) blockChainWithKeyNm:keyNm];
    } else {
        return  [((PwdPinViewController *)vc) blockChainWithKeyNm:keyNm];
    }
}

+(void)setTag:(id)vc tag:(NSInteger)tag
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        ((PentaPinViewController *)vc).tag = tag;
    } else if([vc isKindOfClass:[PwdPinViewController class]]) {
        ((PwdPinViewController *)vc).tag = tag;
    } else {
        ((PwdCertViewController *)vc).tag = tag;
    }
}

+(NSInteger)getTag:(id)vc
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        return ((PentaPinViewController *)vc).tag;
    } else if([vc isKindOfClass:[PwdPinViewController class]]) {
        return ((PwdPinViewController *)vc).tag;
    } else {
        return ((PwdCertViewController *)vc).tag;
    }
}

+(BOOL)getResetPWClecked:(id)vc
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        return ((PentaPinViewController *)vc).resetPWClecked;
    } else {
        return ((PwdPinViewController *)vc).resetPWClecked;
    }
}

+(void)resetPwd:(id)vc
{
    if ([vc isKindOfClass:[PentaPinViewController class]]) {
        [((PentaPinViewController *)vc) resetPenta];
    } else if([vc isKindOfClass:[PwdPinViewController class]]) {
        [((PwdPinViewController *)vc) resetPwd];
    } else {
        [((PwdCertViewController *)vc) resetPwd];
    }
}

+(NSString*)encryptedDictionary:(NSDictionary*)dic
{
    return [PentaPinViewController encryptedDictionary:dic];
}

+(BOOL)isShowPwd:(ViewController *)currVc
{
     return [currVc.navigationController.visibleViewController isKindOfClass:[PwdPinViewController class]] || [currVc.navigationController.visibleViewController isKindOfClass:[PentaPinViewController class]];
}

+(Class)pwdClass
{
    if ([[AppInfo sharedInfo].keypadType integerValue] == keypadTypePenta) {
        return [PentaPinViewController class];
    } else {
        return [PwdPinViewController class];
    }
}

+(void)setTimeStamp:(double)timestamps
{
//    if ([[AppInfo sharedInfo].keypadType integerValue] == keypadTypePenta) {
//        [PentaPinViewController setTimeStamp:timestamp];
//    } else {
//       [PwdPinViewController setTimeStamp:timestamp];
//    }
    
    //2019.03 공인인증서용 보안키패드 추가로 타임스템프를 한곳에서 관리하도록 변경
    if(_timeStamp < timestamps)
        _timeStamp = timestamps;
}

+(double)timeStamp
{
//    if ([[AppInfo sharedInfo].keypadType integerValue] == keypadTypePenta) {
//        return [PentaPinViewController timeStamp];
//    } else {
//        return [PwdPinViewController timeStamp];
//    }
    return _timeStamp;
}

+(void)loadResource
{
    if ([[AppInfo sharedInfo].keypadType integerValue] == keypadTypeRaon) {
        [PwdPinViewController loadResource];
    }
    [PwdCertViewController loadResource];
}
@end
