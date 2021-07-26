//
//  PwdCertViewController.h
//  LiivMate
//
//  Created by kbcard-macpro-a on 2019. 3. 7..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "ViewController.h"
#import "TransKey+Extension.h"


@class PwdCertViewController;
typedef void (^PwdCertFinish)(PwdCertViewController *vc, BOOL isCancel, BOOL *dismiss);
typedef void (^PwdCertSetting)(PwdCertViewController *vc);

@interface PwdCertViewController : ViewController
@property (nonatomic, readonly) NSString *encText;
@property (nonatomic, readonly) NSString *dummyText;
@property (nonatomic, strong) TransKey *raonTf;

@property (nonatomic, assign)    int maxLen;
@property (nonatomic, assign)    int minLen;
//공인인증서 암호 체계참조(영문,숫자,특수문자 조합 10~56자리 *특수문자[',",|,￦] 설정불가)

+(void)showPwd:(PwdCertSetting)settingCallBack callBack:(PwdCertFinish)callBack;

-(NSString*)doublyEncrypted:(NSString*)dataStr key:(NSString*)key;
-(NSString*)doublyEncrypted:(NSString*)keyNm;
-(void)setKeyPadTypeCert;
-(NSString*)encText;

- (void)resetPwd;
// 라온키페드 이미지를 로드한다
+(void)loadResource;
@end
