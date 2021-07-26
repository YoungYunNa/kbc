/*=============================================================================================================
 - TransKeyModalView.h
 =============================================================================================================*/













/*=============================================================================================================
 modalView frame
 =============================================================================================================*/
#define TYPE_SECUREKEYBOARD_TEXT        0
#define TYPE_SECUREKEYBOARD_NUMBER      1

#define SECUREKEYBOARD_NUMBER_WIDTH     303
#define SECUREKEYBOARD_NUMBER_HEIGHT    390

#define SECUREKEYBOARD_TEXT_WIDTH       657
#define SECUREKEYBOARD_TEXT_HEIGHT      326

#define SecureKeyboardWidth(type)       ((type == TYPE_SECUREKEYBOARD_NUMBER)?SECUREKEYBOARD_NUMBER_WIDTH:SECUREKEYBOARD_TEXT_WIDTH)
#define SecureKeyboardHeight(type)      ((type == TYPE_SECUREKEYBOARD_NUMBER)?SECUREKEYBOARD_NUMBER_HEIGHT:SECUREKEYBOARD_TEXT_HEIGHT)

#define SECURE_FIELD_HEIGHT             38

@class TransKeyModalView;

/*=============================================================================================================
 secureKeyboard delegate
 =============================================================================================================*/
@protocol TransKeyModalViewDelegate <NSObject>

@required
- (void)didEndSecureInput:(NSInteger)type;

@optional
- (void)didEndSecureInputIgnoreInputLength:(NSInteger)type;
- (void)TransKeyInputKey:(NSInteger)keytype;
- (void)handleTapBehind:(TransKeyModalView *)view touchLocation:(CGPoint)location ;

@end



/*=============================================================================================================
 secureKeyboard interface
 =============================================================================================================*/
@interface TransKeyModalView : UIViewController 
@property (nonatomic, assign) id<TransKeyModalViewDelegate> delegate;




/*=============================================================================================================
 모달 초기화
 =============================================================================================================*/
- (id)mTK_Init;

/*=============================================================================================================
 보안 키보드 초기화
 type_     : 보안 키보드 타입(0 - 텍스트, 1 - 숫자)
 crypt_    : 암호화 동작 방식(0 - 로컬, 1 - 서버연동)
 bUpper_   : 보안 키보드(대문자 설정)
 language_ : 언어(0 - 한글, 1 - 영어)
 =============================================================================================================*/
- (void)SetSecureKeyboardType:(NSInteger)type_ crypt:(NSInteger)crypt_ isUpper:(BOOL)upper_ language:(NSInteger)language_;

/*=============================================================================================================
 보안 텍스트 필드 초기화
 type_ : 보안 텍스트 필드 타입(0 - 일반, 1 - 보안모드)
 title_ : 입력 필드명(계좌번호, 계정, 비밀번호 등)
 max_ : 최대 입력받을 문자열 길이(기본값:16) - 16 초과 시 16으로 제한
 min_ : 최소 입력받을 문자열 길이(기본값:0) - 사용안함
 =============================================================================================================*/
- (void)SetSecureFieldType:(NSInteger)type_ title:(NSString*)title_ maxLength:(NSInteger)max_ minLength:(NSInteger)min_;

- (void)mTK_UseSequentialKey:(BOOL)bUse_;
- (void)mTK_SetLabelFont:(UIColor*)txtColor_ font:(UIFont*)font_;
- (void)mTK_SetHint:(NSString*)desc_ font:(UIFont*)font_;
- (void)mTK_SetHint:(NSString*)desc_ font:(UIFont*)font_ textAlignment:(NSTextAlignment)alignment_;
- (void)mTK_UseCursor:(BOOL)bUse_;
- (void)mTK_UseAllDeleteButton:(BOOL)bUse_;
- (void)mTK_ShowMessageIfMaxLength:(NSString*)message_;
- (void)mTK_ShowMessageIfMinLength:(NSString*)message_;
- (void)mTK_UseSpecialKey:(BOOL)bUse_ message:(NSString*)text_;
- (void)mTK_SetInputEditboxImage:(BOOL)bUse_;


/*=============================================================================================================
 암호화관련 API
 =============================================================================================================*/
- (void)mTK_MakeSecureKey;
- (void)mTK_SetSecureKey:(NSData*)key_;
- (NSData*)mTK_GetSecureKey;
- (NSInteger)mTK_GetDataLength;
- (NSString*)mTK_GetCipherData;
- (NSString*)mTK_GetCipherDataEx;
- (NSString*)mTK_GetCipherDataExWithPadding;
- (void)mTK_GetPlainDataWithKey:(NSData*)key_
                   cipherString:(NSString*)cipherString_
                    plainString:(char*)plainData_
                         length:(NSInteger)length_;
- (void)mTK_GetPlainDataExWithKey:(NSData*)key_
                     cipherString:(NSString*)cipherString_
                      plainString:(char*)plainData_
                           length:(NSInteger)length_;
- (void)mTK_GetPlainDataExWithPaddingWithKey:(NSData*)key_
                                cipherString:(NSString*)cipherString_
                                 plainString:(char*)plainData_
                                      length:(NSInteger)length_;

/*=============================================================================================================
 기타 API
 =============================================================================================================*/
- (NSString*)mTK_GetVersion;
- (NSInteger)mTK_GetLanguage;
- (NSString*)CK_GetSecureData;
- (void)mTK_SetLabelBackColor:(UIColor*)labelBackColor;

// VoiceOver 사용
- (void)mTK_UseVoiceOver:(BOOL)bUse;

// Navi Bar 설정
- (void)mTK_UseNativeBackground;
- (void)mTK_ShowNaviBar:(BOOL)show;

- (void)mTK_SetEnableCancelButton:(BOOL)enable;
- (void)mTK_SetDisableCancelButtonImageName:(NSString *)name;
- (void)mTK_SetCancelButtonAccessibilityLabel:(NSString *)label;

- (void)mTK_SetEnableCompleteButton:(BOOL)enable;
- (void)mTK_SetDisableCompleteButtonImageName:(NSString *)name;
- (void)mTK_SetCompleteButtonAccessibilityLabel:(NSString *)label;

//입력필드 안보이게 처리
- (void)mTK_SetSecureFieldHidden:(BOOL)hidden;

- (void)mTK_UseShiftOptional:(BOOL)bUse;

- (void)mTK_ClearDelegateSubviews;

- (NSInteger)mTK_GetInputLength;

- (void)mTK_EnableSamekeyInputDataEncrypt:(BOOL)bEnable;

- (void)showModalViewAnimated:(BOOL)animated;

- (void)hideModalView;

- (void)mTK_SetModalPositionWithPosX:(CGFloat)PosX PosY:(CGFloat)PosY;

- (void)mTK_SetPBKDF_RandKey:(NSData*)randkey;

// 쿼티키패드 특수키와 재배열키의 배열을 바꾸는 옵션 - bugFix2 Merge
- (void) mTK_SwapSymbolToRearrange:(BOOL)isSwap;

//라이선스 설정
- (int) mTK_LicenseCheck : (NSString *) fileName;
@end
