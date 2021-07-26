/*==============================================================================
 - TransKeyView.h (풀뷰 secureKeyboard)
 - 연동가이드 참조
 ==============================================================================*/

/*==============================================================================
 secureKeyboard delegate
 ==============================================================================*/
@protocol TransKeyViewDelegate <NSObject>

@optional
- (BOOL)didAutorotateToInterfaceOrient:(UIInterfaceOrientation)orientation; //ios5 이하
- (NSUInteger)didAutorotateToInterfaceOrient; //ios6
- (void)secureInputFinishIgnoreInputLength:(NSInteger)type;

@required
- (void)secureInputFinish:(NSInteger)type;

@end

/*==============================================================================
 secureKeyboard interface
 ==============================================================================*/
@interface TransKeyView : UIViewController
@property (nonatomic, assign) id<TransKeyViewDelegate> delegate;

/*=============================================================================================================
 MTranskey 기본 API
 =============================================================================================================*/

// 라이브러리 초기화
// host : TransKeyView의 상위 UIViewController
- (id)mTK_Init:(id)host;

// 암호키 설정, 128bit
- (void)mTK_SetSecureKey:(NSData*)securekey;

// 라이브러리 내에서 랜덤하게 로컬 암호화에 사용할 비밀키를 생성한다. (128bit)
- (void)mTK_MakeSecureKey;

// 가상키보드 초기화
// host : TransKeyView의 상위 UIViewController
- (id)SetKeyboardType:(id)host;

/*==============================================================================
 가상키보드 초기화
 host : TransKeyView의 상위 UIViewController (self)
 keypad : 보안 키패드 타입
 "0" - "영문+숫자+특수문자" 타입 (기본값)
 "1" - "숫자" 타입
 input : text/password type 형태 구분해서 입력필드를 생성
 "0" - text type (기본값)
 "1" - password type
 label : 입력  필드명 정의 (계좌번호, 계정, 비밀번호, 등등… )
 기본값 - "입력"
 crypt : 암호화 동작 방식 정의
 "0" - 로컬 암호 사용 (기본값)
 "1" - 서버 연동 암호 사용 (5번CK_SetSecureKey함수를 이용하여 키 설정)
 maxlength : 최대 입력받을 문자열 길이(기본값:16) - 16 초과 시 16으로 제한
 minlength : 최소 입력받을 문자열 길이(기본값:0) - 사용안함
 bUpper : 최초 키패드의 시작을 대문자 키패드로 할 것인지.
 language : 언어 셋팅
 "0" - 한글(기본값)
 "1" - 영어
 ==============================================================================*/
- (id)SetKeyboardType:(id)host
           keypadType:(NSInteger)keypad
        mTK_inputType:(NSInteger)input
       mTK_inputTitle:(NSString*)label
        mTK_cryptType:(NSInteger)crypt
        mTK_maxLength:(NSInteger)maxlength
        mTK_minLength:(NSInteger)minlength
      mTK_keypadUpper:(BOOL)bUpper
     mTK_languageType:(NSInteger)language;

// 입력 에디트박스의 설명설정
- (void)mTK_SetHint:(NSString*)desc font:(UIFont*)font;
- (void)mTK_SetHint:(NSString*)desc font:(UIFont*)font textAlignment:(NSTextAlignment)alignment;

// 허용입력 초과시 메세지 박스 사용
- (void)mTK_ShowMessageIfMaxLength:(NSString*)message;

// 최소입력 미만시 메세지 박스 사용
- (void)mTK_ShowMessageIfMinLength:(NSString*)message;

// 입력 에디트박스에 커서 사용유무
- (void)mTK_UseCursor:(BOOL)bUse;

// 전체삭제버튼 사용유무
- (void)mTK_UseAllDeleteButton:(BOOL)bUse;

// navigation bar 사용할 경우 셋팅
- (void)mTK_UseNavigationBar:(BOOL)bUse;

// VoiceOver 사용
- (void)mTK_UseVoiceOver:(BOOL)bUse;

// Navi Bar 설정
- (void)mTK_ShowNaviBar:(BOOL)show;

// 다국어 언어 설정
- (void)mTK_SetLanguage:(NSInteger)langType;

/*=============================================================================================================
 MTranskey additional API
 =============================================================================================================*/
// 라이브러리 버전정보
- (NSString*)mTK_GetVersion;

// 암호키를 얻는다.
- (NSData*)mTK_GetSecureKey;

// 보안 키패드를 사용하여 입력된 암호화 값을 얻는다.
- (NSString*)mTK_GetCipherData;
- (NSString*)mTK_GetCipherDataEx;
- (NSString*)mTK_GetCipherDataExWithPadding;

// 모바일 장치에 대한 고유 ID값을 얻는다.
- (NSString*)mTK_GetUniqueID;
- (NSString*)mTK_GetUniqueIDEx;

// 보안 키패드를 사용하여 입력된 원문 값을 얻는다.
- (void)mTK_GetPlainDataWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;
- (void)mTK_GetPlainDataExWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;
- (void)mTK_GetPlainDataExWithPaddingWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;

- (NSString*)mTK_GetPBKDF2DataEncryptCipherDataWithSeedIv:(unsigned char*)iv;
- (NSString*)mTK_GetPBKDF2DataEncryptCipherDataExWithSeedIv:(unsigned char*)iv;
- (NSString*)mTK_GetPBKDF2DataEncryptCipherDataExWithPaddingWithSeedIv:(unsigned char*)iv;

// 어플리케이션의 패스워드 필드에 넣을 dummy값을 얻는다.
- (NSString*)mTK_GetDummyData;

// 보안 키패드로 입력한 데이터 길이를 얻는다.
- (NSInteger)mTK_GetDataLength;

// 보안 키패드의 키패드 배경색을 변경할 때 사용한다.
- (void)mTK_SetKeypadBackColor:(UIColor*)backColor;

// 보안 키패드의 키패드 배경색을 변경할 때 사용한다.
- (UIColor*)mTK_GetKeypadBackColor;

// 보안 키패드의 Label 글씨 색을 가져올 때 사용한다.
- (UIColor*)mTK_GetLabelColor;

// 보안 키패드의 Label 폰트를 변경할 때 사용한다.
- (void)mTK_SetLabelFont:(UIColor*)txtColor fontType:(NSString*)type fontSize:(CGFloat)size;

// 보안 키패드를 사용하여 입력된 암호화 값 및 사용된 암호화 키를 얻는다.
- (NSString*)mTK_GetSecureData;

// 랜덤키 사용유무
// 사용하면 쿼티 <-> 순열 변환버튼 사용하지 않음.(쿼티 자판으로 고정)
- (void)mTK_UseSequentialKey:(BOOL)bUse;

// 버튼 간격조절
- (void)mTK_SetButtonMargin:(float)addGap;

// 키패드 간격조절 (입력완료는 그대로)
- (void)mTK_SetKeypadMargin:(float)addGap;

// 버튼 라운드처리
- (void)mTK_SetButtonRadius:(float)fround;

// 특수문자키 사용유무
- (void)mTK_UseSpecialKey:(BOOL)bUse message:(NSString*)text;

// 입력 이미지 사이즈 조절
- (void)mTK_SetSizeOfInputKeyImage:(CGFloat)width height:(CGFloat)height_;
- (void)mTK_SetSizeOfInputPwKeyImage:(CGFloat)width height:(CGFloat)height_;

// 입력 에디트, 타이틀 라벨, 입력완료 버튼 중앙으로
// iPhone 전용
- (void)mTK_SetControlCenter:(BOOL)bUse;

// 입력에디트필드의 백그라운드 이미지 설정(transkey_inputbox.png)
- (void)mTK_SetInputEditboxImage:(BOOL)bUse;

// 보안키패드에 설정된 언어 리턴
- (NSInteger)mTK_GetLanguage;


// 디바이스 지원범위 설정
- (void)mTK_SupportedByDeviceOrientation:(NSInteger)supported_;

// iPhone frame으로 강제 설정(기업은행 전용)
- (void)mTK_ForceiPhone;

// iOS 4.x에서 풀뷰를 addSubview하고 난 후 호출
- (void)act;

// IOS4에서 풀뷰 키패드를 addSubview 했는데 화면이 보이지 않는 경우가 있어 수동으로 불러준다.
// IOS4를 지원할 때는 넣어준다.IOS4에만 동작하므로 IOS5 이상 버전에 영향을 미치지 않는다.
- (void)actToIos4;
// IOS4에서 풀뷰 키패드를 removeFromSuperview 했는데 화면이 사라지지 않는 경우가 있어 수동으로 불러준다.
// IOS4를 지원할 때는 넣어준다.IOS4에만 동작하므로 IOS5 이상 버전에 영향을 미치지 않는다.(mTK_SupportedByDeviceOrientation를 사용할 경우)
- (void)removeToIos4;


//최상위 버튼의 Top 마진  - bugFix2 Merge
//- (void)mTK_setHighestTopMargin:(int)height;
//- (void)mTK_SetHighestTopMargin:(int)height;

//최상위 버튼의 Top 마진 - bugFix2 Merge
- (void)mTK_SetHighestTopMargin:(int)height;

// 최 상위 버튼의 Top Margin 설정 - bugFix2 Merge
- (void)mTK_setHighestTopMargin:(int)height;

// Navi Bar 백그라운드 색상 설정
- (void)mTK_SetNaviBarBackgroundColor:(UIColor *)color;
// Navi Bar 백그라운드 이미지 설정
- (void)mTK_SetNaviBarBackgroundImage:(NSString *)name;

// Navi Bar 이전/다음/완료 버튼 숨김설정
- (void)mTK_SetHiddenBeforeButton:(BOOL)hidden;
- (void)mTK_SetHiddenNextButton:(BOOL)hidden;
- (void)mTK_SetHiddenCompleteButton:(BOOL)hidden;

// Navi Bar 마지막 입력값 보여주기 설정
- (void)mTK_ShowLastInput:(BOOL)show;

// 멀티 파라미터 설정
- (void)mTK_SetMultiParam:(NSMutableArray *)params;
// 멀티 파라미터 ResultData가져오기
- (NSMutableArray *)mTK_GetMultiResultData;

// Shift Option 사용 유무 설정
- (void)mTK_UseShiftOptional:(BOOL)bUse;


// 키패드 파라미터 옵션 초기화
- (void)mTK_ClearParamOptions;

// 키패드 사용한 Parent뷰에서 Subview를 삭제 설정
- (void)mTK_ClearDelegateSubviews;

// 입력된 텍스트의 길이를 가져온다
- (NSInteger)mTK_GetInputLength;

// ios7이상에서만 사용. 풀뷰 상태바 색상을 지정한다.
- (void)mTK_SetStatusbarColorwithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Alpha:(CGFloat)alpha;

// 어두운계열과 밝은 계열의 상태바텍스트 색상 선택
- (void)mTK_SetStatusbarTextColorDark:(BOOL)darkColor;

- (void)mTK_EnableSamekeyInputDataEncrypt:(BOOL)bEnable;

- (void)mTK_setHideInputPasswordDelay:(NSInteger)delaySecond;

- (void)mTK_setVerticalKeypadPosition:(int)position;

- (void)mTK_NaviButtonChangeClearData:(BOOL)bClear;

- (void)mTK_setIgnoreStatusbar:(BOOL)isIgnore;

- (void)mTK_SetPBKDF_RandKey:(NSData*)randkey;
- (void)mTK_SetPBKDF_RandKey:(NSData*)randkey withSalt:(NSData *)salt withIterator:(NSInteger)iterator;

- (NSString*)mTK_GetPBKDF2DataEncryptCipherData;
- (NSString*)mTK_GetPBKDF2DataEncryptCipherDataEx;
- (NSString*)mTK_GetPBKDF2DataEncryptCipherDataExWithPadding;

- (void)mTK_SetAlertTitle:(NSString*)title;
// 말풍선(balloon) 사용유무
- (void)mTK_SetUseBalloonImageButton:(BOOL)bUse;

//키패드가 최초에 심볼타입으로 생성되는 옵션
- (void) mTK_ChangeKeypadToSymbol:(BOOL) flag;

//취소버튼 삭제
- (void) mTK_DisableCancelBtn : (BOOL) flag;

//자판 높이 세팅
- (void) mTK_SetHeight:(float)value;

// 더미 커스텀 이미지 사용
- (void) mTK_UseCustomDummy : (BOOL) flag;

// 커스텀 더미 스트링 (@"!@#$")
- (void) mTK_CustomDummyString : (NSString *) mDummyString;

// 드래그 기능 막는 옵션
- (void) mTK_DisableDragEvent : (BOOL) flag;

// color 세팅이 추가된 SetHint API
- (void)mTK_SetHint:(NSString *)desc font:(UIFont *)font textAlignment:(NSTextAlignment)alignment textColor:(UIColor *)color;

// 타이틀 이미지의 크기수정
- (void) mTK_SetTitleHeight : (float) rate;

- (void)mTK_DisableButtonEffect:(BOOL)bDisable;
/*
 커스텀 타이틀바 옵션
 아래와 같이 파일명이 리소스에 등록되어 있어야 함
 1. 고객사 로고 이미지: custom_title_logo.png
 2. 백그라운드 이미지명: custom_titlebar_background.png
 */
- (void)mTK_UseCustomTitleImage:(BOOL)flag withWidth:(float)logoW withHeight:(float)logoH;

//오토포커싱 사용
- (void) mTK_SetAutoFocusing : (BOOL) flag;

// 키패드 버튼 사이 간격 조절
- (void) mTK_SetBtnMarginRatio : (float) value;

// 공개키를 통한 암호문 패킷 생성
- (NSString*)mTK_EncryptSecureKey:(NSString*)publicKey cipherString:(NSString*)cipherString;
- (NSString*)mTK_EncryptSecureKey:(NSString*)publicKey cipherString:(NSString *)cipherString nonce:(NSData*)nonce; // bugFix2 Merge

// iPhoneX 풀뷰, 상하단 Safe Area 블랙으로 처리하는 옵션
- (void) mTK_SetSafeAreaColor : (UIColor *) color;

// 미디어 볼륨으로 버튼음 재생하도록 설정 (Tock.caf)
- (void) mTK_UseButtonResSound : (BOOL) flag;

// 숫자 키보드를 랜덤으로 배열
- (void) mTK_UseRandomNumpad : (BOOL) useRandomNumpad;

// SafeArea 설정 (v44 추가)
- (void) mTK_SetBottomSafeArea : (BOOL) flag;

// 쿼티키패드 특수키와 재배열키의 배열을 바꾸는 옵션 - bugFix2 Merge
- (void) mTK_SwapSymbolToRearrange:(BOOL)isSwap;

// * 라이선스 체크. 반드시 진행해서 검증받아야 mTransKey 사용 가능
- (int) mTK_LicenseCheck : (NSString *) fileName;
@end
