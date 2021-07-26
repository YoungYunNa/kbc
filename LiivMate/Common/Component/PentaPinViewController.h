//
//  PentaPinViewController.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 8. 4..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "ViewController.h"
#import "PentaTextField.h"
#import "PentaKeypad.h"
#import "Issacweb_static.h"
#import "KBFidoManager.h"

#define PentaPinLen			6

@class PentaPinViewController;
typedef void (^PentaPinFinish)(PentaPinViewController *vc, BOOL isCancel, BOOL *dismiss);
typedef void (^PentaPinSetting)(PentaPinViewController *vc);

@interface PentaPinViewController : ViewController
@property (nonatomic, readonly) NSString *encText;
@property (nonatomic, readonly) NSString *dummyText;
@property (nonatomic, strong)	NSString *subTitle;
@property (nonatomic, strong)	NSString *infoMsg;
@property (nonatomic, assign)   BOOL showPwdResetBtn;
@property (nonatomic, assign)	int maxLen;//defult 6
@property (nonatomic, assign)	BOOL successTouchID;
@property (nonatomic, strong) PentaTextField *pentaTf;
@property (nonatomic) BOOL resetPWClecked;

+(void)showPenta:(PentaPinSetting)settingCallBack callBack:(PentaPinFinish)callBack;
//블럭체인 전문및 FIDO 사용전문시...
+(void)showPenta:(PentaPinSetting)settingCallBack target:(NSString*)requestID callBack:(PentaPinFinish)callBack;

+(NSString*)doublyEncrypted:(NSString*)dataStr key:(NSString*)key;
+(NSString*)encryptedDictionary:(NSDictionary*)dic;
-(NSString*)doublyEncrypted:(NSString*)keyNm;
-(NSString*)encText;
-(NSDictionary*)blockChainWithKeyNm:(NSString*)keyNm;
+(void)checkedBlockChain;
+(void)deleteBlockChain;

- (void)resetPenta;

typedef void (^PlainText)(char *plain);
- (void)getPlainText:(PlainText)completion;

@end
