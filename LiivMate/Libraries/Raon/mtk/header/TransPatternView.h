/*==============================================================================
 - TransPatternView.h (패턴 secureKeyboard)
 ==============================================================================*/

#import <UIKit/UIKit.h>
#import "TransPatternManager.h"

@interface TransPatternView : UIViewController

@property (nonatomic, retain) id<TransKeyViewDelegate> delegate;

// 비밀키 설정
-(void) mTK_SetSecureKey:(NSData*)securekey;
-(NSData*)mTK_GetSecureKey;

// 상단 안내 문구 설정
-(void) mTK_SetTopLabelText:(NSString*) defaultText wrongText:(NSString *)wrongText;
-(void) mTK_SetTopLabelColor:(UIColor *)defaultTextColor textColor:(UIColor *)wrongTextColor;

// 최소 입력 자리수 설정
-(void) mTK_SetMinLength:(NSInteger)length;

// 암호화 데이터 추출
-(NSString*) mTK_GetCipherData;
-(NSString*) mTK_GetCipherDataEx;
-(NSString*) mTK_GetCipherDataExWithPadding;

// 비대칭키 암호화 패킷 추출
-(NSString*) mTK_EncryptSecureKey:(NSString*)publicKey cipherString:(NSString *)cipherString;

// 패턴 입력 길이
-(NSInteger) mTK_GetPatternLength;

// 암호화 데이터 복호화
-(void) getPlainDataWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;
-(void) getPlainDataExWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;
-(void) getPlainDataExWithPaddingWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;

// 입력값이 동일할 경우 같은 암호문으로 암호화
-(void) mTK_EnableSamekeyInputDataEncrypt:(BOOL)bEnable;

// 취소버튼을 이미지로 설정
-(void) mTK_SetCancelButtonImage : (UIImage*) cancelImage;

// 패턴 도트 컬러 설정
-(void) mTK_SetDotColor:(UIColor*) defaultColor wrongColor:(UIColor*) wrongColor;

// 패턴 라인 컬러 설정
-(void) mTK_SetLineColor:(UIColor*) defaultColor wrongColor:(UIColor*) wrongColor;

// 로고 에니메이션 재생 설정
-(void) mTK_SetLogoAnimating:(BOOL) setAnimation;

//입력패턴을 보여줄지 설정
-(void) mTK_SetStealthMode:(BOOL) bEnable;

//라이선스 설정
- (int) mTK_LicenseCheck : (NSString *) fileName;

//비밀키 생성
- (void)mTK_MakeSecureKey;

// 클리어 타임 설정
- (void) mTK_SetClearDelayMillis:(NSInteger) millis;

// 보이스 오버 설정
- (void)mTK_UseVoiceOver:(BOOL)bUse;

// 서브뷰 제거
- (void)mTK_ClearDelegateSubviews;

// 도트 크기 설정
- (void)mTK_SetDotSizeRatio:(CGFloat) ratio;

// 라인 크기 설정
- (void)mTK_SetLineSizeRatio:(CGFloat) ratio;
@end
