//
//  TransPatternManager.h
//  mTrankeyDemo_xib
//
//  Created by 전지완 on 27/12/2018.
//  Copyright © 2018 lumensoft. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TransKeyView.h"

enum{
    PatternCancel,
    PatternFail,
    PatternComplete,
};

@interface TransPatternManager : NSObject

@property (nonatomic, retain) id<TransKeyViewDelegate> delegate;

// 비밀키 설정
- (void) mTK_SetSecureKey:(NSData*)securekey;
- (NSData*)mTK_GetSecureKey;

// 랜덤 비밀키 생성
- (void)mTK_MakeSecureKey;

// 최소 자리 수 설정
- (void) mTK_SetMinLength:(NSInteger)length;

// 암호화 데이터 추출
- (NSString*)mTK_GetCipherData;
- (NSString*)mTK_GetCipherDataEx;
- (NSString*)mTK_GetCipherDataExWithPadding;

// 비대칭키 암호화 패킷 추출
- (NSString*) mTK_EncryptSecureKey:(NSString*)publicKey cipherString:(NSString *)cipherString;

// 암호화 데이터 복호화
- (void) getPlainDataWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;
- (void) getPlainDataExWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;
- (void) getPlainDataExWithPaddingWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;

// 패턴 입력 길이
- (NSInteger)mTK_GetPatternLength;
- (void) addPatternCtrlView:(CGRect)frame parentView:(UIView*)parentView;
- (void) removePatternView;
- (BOOL) patternIsShown;

//라이선스 설정
- (int) mTK_LicenseCheck : (NSString *) fileName;

//입력패턴을 보여줄지 설정
- (void) mTK_SetStealthMode:(BOOL) bEnable;

//도트컬러 설정
- (void) mTK_SetDotColor:(UIColor*) defaultColor wrongColor:(UIColor *)wrongColor;

//라인컬러 설정
- (void) mTK_SetLineColor:(UIColor*) defaultColor wrongColor:(UIColor*) wrongColor;

// samekey 옵션
- (void)mTK_EnableSamekeyInputDataEncrypt:(BOOL)bEnable;

// 클리어 타임 설정
- (void) mTK_SetClearDelayMillis:(NSInteger) millis;

// 보이스 오버 설정
- (void)mTK_UseVoiceOver:(BOOL)bUse;

// 패턴 입력 완료
- (void)mTK_PatternTouchesDone;

// 패턴 입력 취소
- (void)mTK_PatternTouchesCancel;

// 도트 크기 설정
- (void)mTK_SetDotSizeRatio:(CGFloat) ratio;

// 라인 크기 설정
- (void)mTK_SetLineSizeRatio:(CGFloat) ratio;
@end
