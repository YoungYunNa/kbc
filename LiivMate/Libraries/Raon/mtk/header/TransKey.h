/*==============================================================================
 - TransKey.h (컨트롤 분리 secureKeyboard)
 ==============================================================================*/

#import <Foundation/Foundation.h>
@class TransKey;

enum {
    NormalKey,
    DeleteKey,
    ClearallKey
};

enum{
    CancelCmdType,
    CompleteCmdType,
    NaviCancelCmdType,
    NaviCompleteCmdType,
    NaviBeforeCmdType,
    NaviNextCmdType,
};

/*==============================================================================
 secureKeyboard(컨트롤분리) keypad type
 ==============================================================================*/
enum {
    TransKeyKeypadTypeText                      = 1,
    TransKeyKeypadTypeNumber                    = 2,
    TransKeyKeypadTypeTextWithPassword          = -1,
    TransKeyKeypadTypeTextWithPasswordOnly      = -3,
    TransKeyKeypadTypeNumberWithPassword        = -2,
    TransKeyKeypadTypeNumberWithPasswordOnly    = -4,
    TransKeyKeypadTypeTextWithPasswordLastShow  = -5,
    TransKeyKeypadTypeNumberWithPasswordLastShow  = -6
};

/*==============================================================================
 support device
 
 SupportedByDevicePortrait               : Only Portrait
 SupportedByDevicePortraitUpsideDown     : Portrait & PortraitUpsideDown
 SupportedByDeviceLandscape              : LandscapeLeft & LandscapeRight
 SupportedByDevicePortraitAndLandscape   : Portrait & PortraitUpsideDown
 LandscapeLeft & LandscapeRight
 SupportedByDeviceLandscapeLeft
 SupportedByDeviceLandscapeRight
 SupportedByDevicePortraitUpsideDownOnly
 
 ==============================================================================*/
enum {
    SupportedByDevicePortrait,
    SupportedByDevicePortraitUpsideDown,    //
    SupportedByDeviceLandscape,             // LandscapeLeft & LandscapeRight
    SupportedByDevicePortraitAndLandscape,
    SupportedByDeviceLandscapeLeft,
    SupportedByDeviceLandscapeRight,
    SupportedByDevicePortraitUpsideDownOnly
};
/*==============================================================================
 언어 설정 정의
 
 mTK_Language_Korean            :   한국어
 mTK_Language_English           :   영어
 mTK_Language_Chinese           :   중국어
 mTK_Language_Japanese          :   일본어
 mTK_Language_Vietnames         :   베트남어
 mTK_Language_Mongolian         :   몽골어
 mTK_Language_Thai              :   태국어
 mTK_Language_Indonesian        :   인도네시아어
 
 ==============================================================================*/
typedef enum {
    mTK_Language_Korean=0,
    mTK_Language_English,
    mTK_Language_Chinese,
    mTK_Language_Japanese,
    mTK_Language_Vietnames,
    mTK_Language_Mongolian,
    mTK_Language_Thai,
    mTK_Language_Indonesian
}MTransKey_Language_Option;
typedef NSInteger TransKeyKeypadType;

enum {
    TransKeyResourceTypeNormal,
    TransKeyResourceTypeNew,
    TransKeyResourceTypeRandom
};
typedef NSInteger TransKeyResourceType;

/*=============================================================================================================
 secureKeyboard(컨트롤분리) delegate
 =============================================================================================================*/
@protocol TransKeyDelegate<NSObject>

@optional

- (void)TransKeyDidBeginEditing:(TransKey *)transKey;
- (void)TransKeyDidEndEditing:(TransKey *)transKey;
- (void)TranskeyWillBeginEditing:(TransKey *)transKey;
- (void)TranskeyWillEndEditing:(TransKey *)transKey;
- (void)TransKeyInputKey:(NSInteger)keytype;
- (BOOL)TransKeyShouldInternalReturn:(TransKey *)transKey btnType:(NSInteger)type;
//키패드 생성이 완료된 후에 받는 delegate.
- (void)TransKeyEndCreating:(TransKey *)transKey;
//키패드가 터치되면 콜백을 줌(mTK_RemoveFieldTouchEvent 옵션 사용시)
- (void)TranskeyFieldTouched:(TransKey *)transKey;

//최소 입력 길이 미만 일때 받는 delegate (min length) - bugFix2 Merge
- (void)TransKeyMinLengthCallback:(TransKey *)transkey;

//최대 입력 길이가 초과되면 받는 delegate (max length) - bugFix2 Merge
- (void)TransKeyMaxLengthCallback:(TransKey *)transkey;

@required
- (BOOL)TransKeyShouldReturn:(TransKey *)transKey;
@end

/*=============================================================================================================
 secureKeyboard(컨트롤분리) interface
 =============================================================================================================*/
@interface TransKey : UIView
@property (nonatomic, assign) id <TransKeyDelegate>delegate;
@property (nonatomic, retain) id parent;

/*=============================================================================================================
 MTranskey 기본 API
 =============================================================================================================*/
// 암호키 설정한다. 128bit
-(void)setSecureKey:(NSData*)securekey;
// 컨트롤 분리모드에서 디바이스지원 범위 설정
// secureKeyboard(컨트롤분리) support device 참조
- (void)mTK_SupportedByDeviceOrientation:(NSInteger)supported_;
// 보안 키패드의 타입 및 최대/최소 길이를 설정한다.
- (void)setKeyboardType:(TransKeyKeypadType)type maxLength:(NSInteger)maxlength minLength:(NSInteger)minlength;
// 커서 사용유무
- (void)mTK_UseCursor:(BOOL)bUse;
// 전체삭제 버튼 사용유무
- (void)mTK_UseAllDeleteButton:(BOOL)bUse;
// 입력에디트필드의 백그라운드 이미지 적용(transkey_inputbox.png)
- (void)mTK_SetInputEditboxImage:(BOOL)bUse;
// 입력에디트필드의 초기 문구를 설정
- (void)mTK_SetHint:(NSString*)desc font:(UIFont*)font;
- (void)mTK_SetHint:(NSString*)desc font:(UIFont*)font textAlignment:(NSTextAlignment)alignment;
// VoiceOver 사용
- (void)mTK_UseVoiceOver:(BOOL)bUse;
// Navi Bar 설정
- (void)mTK_ShowNaviBar:(BOOL)show;
// Navi Bar 이전/다음/완료 버튼 숨김,보이스오버 설정
- (void)mTK_SetHiddenBeforeButton:(BOOL)hidden;
- (void)mTK_SetEnableBeforeButton:(BOOL)enable;
- (void)mTK_SetDisableBeforeButtonImageName:(NSString *)name;
- (void)mTK_SetBeforeButtonAccessibilityLabel:(NSString *)label;

- (void)mTK_SetHiddenNextButton:(BOOL)hidden;
- (void)mTK_SetEnableNextButton:(BOOL)enable;
- (void)mTK_SetDisableNextButtonImageName:(NSString *)name;
- (void)mTK_SetNextButtonAccessibilityLabel:(NSString *)label;

- (void)mTK_SetHiddenCompleteButton:(BOOL)hidden;
- (void)mTK_SetEnableCompleteButton:(BOOL)enable;
- (void)mTK_SetDisableCompleteButtonImageName:(NSString *)name;
- (void)mTK_SetCompleteButtonAccessibilityLabel:(NSString *)label;

- (void)mTK_textAlignCenter:(BOOL)bCenter;

- (void)mTK_UseShiftOptional:(BOOL)bUse;
// 보안키패드의 언어설정(0:한글(default), 1:영어)
// 한글 문구가 들어간 버튼만 이미지 변경(입력완료, 취소 등)
- (void)mTK_SetLanguage:(NSInteger)languageType;
- (void) mTK_SetKeypadBackColor:(UIColor*)backColor;

/*=============================================================================================================
 MTranskey additional API
 =============================================================================================================*/
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
// textfield에 입력길이만큼 '*' 출력
- (void)setDummyCharacterWithLength:(NSInteger)length;
// 보안 키패드로 입력한 데이터 길이를 얻는다.
- (NSInteger)length;
// 암호화 키를 얻는다.
-(NSData*)getSecureKey;
// 보안 키패드를 사용하여 입력된 암호화 값을  얻는다.
- (NSString *)getCipherData;
- (NSString *)getCipherDataEx;
- (NSString *)getCipherDataExWithPadding;
// 보안키패드 랜덤키 설정
- (void)makeSecureKey;
// 보안 키패드를 사용하여 입력된 원문 값을 얻는다.
- (void)getPlainDataWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;
- (void)getPlainDataExWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;
- (void)getPlainDataExWithPaddingWithKey:(NSData*)key cipherString:(NSString*)cipherString plainString:(char*)plainData length:(NSInteger)length;

// TransKey의 키패드를 띄운다.
- (void)TranskeyBecomeFirstResponder;

// TransKey의 키패드를 내린다.
- (void)TranskeyResignFirstResponder;

// TransKey를 통해 입력한 데이터를 초기화한다.
- (void)clear;

// 특수문자키 사용유무
- (void)mTK_UseSpecialKey:(BOOL)bUse message:(NSString*)text;

// 입력문자의 사이즈 조절(텍스트모드)
- (void)mTK_SetSizeOfInputKeyImage:(CGFloat)width height:(CGFloat)height_;

// 입력문자의 사이즈 조절(암호모드)
- (void)mTK_SetSizeOfInputPwKeyImage:(CGFloat)width height:(CGFloat)height_;

// 팝오버 사용(아이패드 전용)
- (void)mTK_UsePopOver:(BOOL)bUse;

// 현재 키패드가 팝오버 인지 확인.
- (void)mTK_IsPopOver;

//키패드를 대문자모드로 불러옴
- (void)setKeyboardUpper:(BOOL)bUpper;

// 현재 보안키패드에 설정된 언어 리턴
- (NSInteger)mTK_GetLanguage;

// 허용입력 초과시 메세지 박스 사용
- (void)mTK_ShowMessageIfMaxLength:(NSString*)message;

// 최소입력 미만시 메세지 박스 사용
- (void)mTK_ShowMessageIfMinLength:(NSString*)message;

// 버전
- (NSString*)mTK_GetVersion;

// navigation bar 사용할 경우 셋팅
- (void)mTK_UseNavigationBar:(BOOL)bUse;

// 숫자입력 4가지로 표현
- (void)mTK_SetFixed;

// 팝오버 옵션
- (void)mTK_SetPopOverOpt:(UIColor*)labelBackColor textColor:(UIColor*)labelColor alignment:(NSTextAlignment)textAlignment;

// 암호화 데이터 값
- (NSString*)mTK_GetSecureData;
- (NSString*)CK_GetSecureData;

// Navi Bar 백그라운드 색상 설정
- (void)mTK_SetNaviBarBackgroundColor:(UIColor *)color;
// Navi Bar 백그라운드 이미지 설정
- (void)mTK_SetNaviBarBackgroundImage:(NSString *)name;

// Navi Bar 마지막 입력값 보여주기 설정
- (void)mTK_ShowLastInput:(BOOL)show;

//최상위 버튼의 Top 마진
- (void)mTK_SetHighestTopMargin:(int)height;

// NaviBar 마지막 글자 커스터마이징 설정
- (void)mTK_SetNaviLastInputImageNamePrefix:(NSString*)prefixStr;
- (NSString*)GetLastInputKeyImg;

- (void)mTK_ClearDelegateSubviews;

- (NSInteger)mTK_GetInputLength;

- (void)mTK_EnableSamekeyInputDataEncrypt:(BOOL)bEnable;

- (void)mTK_setHideInputPasswordDelay:(NSInteger)delaySecond;

- (void)mTK_setReArrangeKeypad:(BOOL)bReArrange;

- (void)mTK_UseKeypadAnimation:(BOOL)bUseAnimation;

- (void)mTK_setVerticalKeypadPosition:(int)position;

- (void)mTK_InputDone;
- (void)mTK_InputCancel;
- (void)mTK_InputBackSpace;

- (void)mTK_UseAtmMode:(BOOL)bUseAtm;

- (void)mTK_setCustomPostfixInputBoxImage:(NSString*)postfixImgName;

- (void)mTK_SetInputBoxTransparent:(BOOL)bTransparent;

- (void)mTK_SetPBKDF_RandKey:(NSData*)randkey;
- (void)mTK_SetPBKDF_RandKey:(NSData*)randkey withSalt:(NSData *)salt withIterator:(NSInteger)iterator;

- (NSString*)getPBKDF2DataEncryptCipherData;
- (NSString*)getPBKDF2DataEncryptCipherDataEx;
- (NSString*)getPBKDF2DataEncryptCipherDataExWithPadding;

- (void)mTK_UseFocusColor:(BOOL)isUse;
- (void)mTK_SetAlertTitle:(NSString*)title;

// 입력필드 중앙정렬 유지하기 위해  - (void)viewDidDisappear:(BOOL)animated 하단에 선언
- (void)mTK_RemainTextAlignCenter;
// 말풍선(balloon) 사용유무
- (void)mTK_SetUseBalloonImageButton:(BOOL)bUse;

- (void)mTK_DisableButtonEffect:(BOOL)bDisable;

//취소버튼 삭제
- (void) mTK_DisableCancelBtn : (BOOL) flag;

//오토포커싱 사용
- (void) mTK_SetAutoFocusing : (BOOL) flag;

// qwerty 키패드 높이 설정
- (void) mTK_SetHeight : (float) value;

// 키패드 높이 리턴
- (float) mTK_GetCurrentKeypadHeight;

// 더미 커스텀 이미지 사용
- (void) mTK_UseCustomDummy : (BOOL) flag;

// 커스텀 더미 스트링 (@"!@#$")
- (void) mTK_CustomDummyString : (NSString *) mDummyString;

// 드래그 기능 막는 옵션
- (void) mTK_DisableDragEvent : (BOOL) flag;

// color 세팅이 추가된 SetHint API
- (void)mTK_SetHint:(NSString *)desc font:(UIFont *)font textAlignment:(NSTextAlignment)alignment textColor:(UIColor *)color;

// 키패드 버튼 사이 간격 조절
- (void) mTK_SetBtnMarginRatio : (float) value;

// 키패드 입력완료 버튼 감춤/보이기 (동작중 사용가능)
- (void) mTK_SetCompleteBtnHide : (BOOL) flag;

// 공개키를 통한 암호문 패킷 생성
- (NSString*)mTK_EncryptSecureKey:(NSString*)publicKey cipherString:(NSString*)cipherString;
- (NSString*) mTK_EncryptSecureKey:(NSString*)publicKey cipherString:(NSString *)cipherString nonce:(NSData*)nonce; //- bugFix2 Merge

// ChangeView 형태를 사용할때 옵션
- (void) mTK_SetChangeView : (BOOL) flag;

// 하단 Safe Area 적용 여부
- (void) mTK_SetBottomSafeArea : (BOOL) flag;

// 보안입력필드 터치시 발생하는 이벤트를 없애고 TranskeyFieldTouched() 콜백 던져줌
- (void) mTK_RemoveFieldTouchEvent : (BOOL) flag;

// 미디어 볼륨으로 버튼음 재생하도록 설정 (Tock.caf)
- (void) mTK_UseButtonResSound : (BOOL) flag;

// 숫자 키보드를 랜덤으로 배열
- (void) mTK_UseRandomNumpad : (BOOL) useRandomNumpad;

// * 라이선스 체크. 반드시 진행해서 검증받아야 mTransKey 사용 가능
- (int) mTK_LicenseCheck : (NSString *) fileName;

// 완료버튼 선택시에 키패드를 내리지 않고 결과값 리턴
- (void) mTK_SetDisableCompleteClose : (BOOL) useDisableClose;

// 키보드 리소스 타입 설정 (default : TransKeyResourceTypeNormal)
- (void) mTK_SetKeypadResourceType : (TransKeyResourceType) resourceType;

// 미리 리소스를 로드하는 옵션
+ (void) mTK_initTransKeyResourceFull:(UIViewController*) parentViewController;
+ (void) mTK_initTransKeyResourceType:(NSInteger)padType_ parentViewController:(UIViewController*) parentViewController;

//키패드 X 리턴
- (float) mTK_GetCurrentKeypadX;

// 쿼티키패드 특수키와 재배열키의 배열을 바꾸는 옵션 - bugFix2 Merge
- (void) mTK_SwapSymbolToRearrange:(BOOL)isSwap;

// 랜덤키패드 백스패이스키와 입력완료키의 배열을 바꾸는 옵션 - bugFix2 Merge
- (void) mTK_SwapBackspaceToComplete:(BOOL)isSwap;

// 랜덤키패드 입력완료키 제거 옵션 (더미이미지 : transkey_number_cmd_random_dummy.png) - bugFix2 Merge
- (void) mTK_RemoveRandomNumpadCompleteButton:(BOOL)isRemove;

@end
