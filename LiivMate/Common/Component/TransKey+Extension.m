//
//  TransKey+Extension.m
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2019. 2. 22..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "TransKey+Extension.h"

@implementation TransKey (Extension)

+ (void)loadResource:(id)vc
{
    [TransKey mTK_initTransKeyResourceFull:vc];
}

+(TransKey *)getRandomKeypad:(id)delegate
                     license:(NSString *)license
                        type:(TransKeyResourceType)type

{
    TransKey * transKey = [[TransKey alloc] initWithFrame:CGRectMake(-60, 50, 60, 30)];
    transKey.delegate = delegate;
    transKey.parent = delegate;
    // 리브메이트 2.0 Merge 라온키패드 57버전 키패드 뜨도록 parent를 viewcontroller로 설정
//    transKey.parent = ((UIViewController *)delegate).view;
    
    [transKey makeSecureKey];
//    [transKey mAMSLJBScanner2.frameworkakeSecureKey];

    [transKey mTK_SupportedByDeviceOrientation:SupportedByDevicePortraitUpsideDownOnly];
    
    [transKey mTK_UseCursor:NO];
    [transKey mTK_SetInputEditboxImage:NO];
    [transKey mTK_UseVoiceOver:YES];
    [transKey mTK_ShowNaviBar:NO];
    [transKey mTK_SetInputBoxTransparent:NO];
    
    [transKey mTK_UseKeypadAnimation:NO];
    [transKey mTK_DisableCancelBtn:YES];
    [transKey mTK_SetBottomSafeArea:YES];
    [transKey mTK_EnableSamekeyInputDataEncrypt:NO];
    
    if (type == TransKeyResourceTypeRandom) {
        [transKey mTK_SetEnableCompleteButton:NO];
        [transKey mTK_SetCompleteBtnHide:YES];
    }else {
        
        [transKey mTK_SetEnableCompleteButton:YES];
        [transKey mTK_SetCompleteBtnHide:NO];
    }
    [transKey mTK_UseRandomNumpad:YES];
    [transKey mTK_SetKeypadResourceType:type];
    
    [transKey mTK_UseNavigationBar:NO];
    
    int res = [transKey mTK_LicenseCheck:license];
    NSLog(@"res == %d", res);
    
    return transKey;
}

- (void)setMaxLen:(NSInteger)maxLen
{
    [self setKeyboardType:TransKeyKeypadTypeNumberWithPassword maxLength:maxLen minLength:0];
}
- (void)setKeyPadTypeCert  
{
    [self setKeyboardType:TransKeyKeypadTypeTextWithPassword maxLength:99 minLength:0];
}

- (NSString *)getPublicKeyEnc:(nonnull NSString *)keyfileName
{
    return [self getPublicKeyEnc:keyfileName encStr:[self getCipherDataEx]];
}

- (NSString *)getPublicKeyEnc:(nonnull NSString *)keyfileName encStr:(NSString *)encStr
{
    NSString* fileName = [[keyfileName lastPathComponent] stringByDeletingPathExtension];
    NSString* extension = [keyfileName pathExtension];
    
    if (nilCheck(fileName) || nilCheck(extension))
        return nil;
    
    NSString *pubKey = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
    NSString *encryptedStr = [self mTK_EncryptSecureKey:pubKey cipherString:encStr];
    
    return encryptedStr;
}
- (void)getPlainText:(PlainText)completion {
    char *plain = (char *)malloc(256);
    [self getPlainDataWithKey:self.getSecureKey cipherString:self.getCipherData plainString:plain length:256];
    completion(plain);
    free(plain);
}

@end
