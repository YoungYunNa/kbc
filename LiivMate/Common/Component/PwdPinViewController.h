//
//  PwdPinViewController.h
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2018. 12. 28..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "ViewController.h"
#import "TransKey+Extension.h"
#import "KBFidoManager.h"

#define PwdPinLen            6

@class PwdPinViewController;
typedef void (^PwdPinFinish)(PwdPinViewController *vc, BOOL isCancel, BOOL *dismiss);
typedef void (^PwdPinSetting)(PwdPinViewController *vc);

@interface PwdPinViewController : ViewController
@property (nonatomic, readonly) NSString *encText;
@property (nonatomic, readonly) NSString *dummyText;
@property (nonatomic, strong)    NSString *subTitle;
@property (nonatomic, strong)    NSString *infoMsg;
@property (nonatomic, assign)   BOOL showPwdResetBtn;
@property (nonatomic, assign)    int maxLen;//defult 6
@property (nonatomic, assign)    int minLen;
@property (nonatomic, assign)    BOOL successTouchID;
@property (nonatomic, strong) TransKey *raonTf;
@property (nonatomic) BOOL resetPWClecked;

+(void)showPwd:(PwdPinSetting)settingCallBack callBack:(PwdPinFinish)callBack;
//블럭체인 전문및 FIDO 사용전문시...
+(void)showPwd:(PwdPinSetting)settingCallBack target:(NSString*)requestID callBack:(PwdPinFinish)callBack;
-(NSString*)doublyEncrypted:(NSString*)dataStr key:(NSString*)key;
-(NSString*)doublyEncrypted:(NSString*)keyNm;
-(NSString*)encText;
-(NSDictionary*)blockChainWithKeyNm:(NSString*)keyNm;
+(void)checkedBlockChain;
+(void)deleteBlockChain;

- (void)resetPwd;
// 라온키페드 이미지를 로드한다
+(void)loadResource;
@end
