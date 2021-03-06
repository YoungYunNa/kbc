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
 ?????? ?????????
 =============================================================================================================*/
- (id)mTK_Init;

/*=============================================================================================================
 ?????? ????????? ?????????
 type_     : ?????? ????????? ??????(0 - ?????????, 1 - ??????)
 crypt_    : ????????? ?????? ??????(0 - ??????, 1 - ????????????)
 bUpper_   : ?????? ?????????(????????? ??????)
 language_ : ??????(0 - ??????, 1 - ??????)
 =============================================================================================================*/
- (void)SetSecureKeyboardType:(NSInteger)type_ crypt:(NSInteger)crypt_ isUpper:(BOOL)upper_ language:(NSInteger)language_;

/*=============================================================================================================
 ?????? ????????? ?????? ?????????
 type_ : ?????? ????????? ?????? ??????(0 - ??????, 1 - ????????????)
 title_ : ?????? ?????????(????????????, ??????, ???????????? ???)
 max_ : ?????? ???????????? ????????? ??????(?????????:16) - 16 ?????? ??? 16?????? ??????
 min_ : ?????? ???????????? ????????? ??????(?????????:0) - ????????????
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
 ??????????????? API
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
 ?????? API
 =============================================================================================================*/
- (NSString*)mTK_GetVersion;
- (NSInteger)mTK_GetLanguage;
- (NSString*)CK_GetSecureData;
- (void)mTK_SetLabelBackColor:(UIColor*)labelBackColor;

// VoiceOver ??????
- (void)mTK_UseVoiceOver:(BOOL)bUse;

// Navi Bar ??????
- (void)mTK_UseNativeBackground;
- (void)mTK_ShowNaviBar:(BOOL)show;

- (void)mTK_SetEnableCancelButton:(BOOL)enable;
- (void)mTK_SetDisableCancelButtonImageName:(NSString *)name;
- (void)mTK_SetCancelButtonAccessibilityLabel:(NSString *)label;

- (void)mTK_SetEnableCompleteButton:(BOOL)enable;
- (void)mTK_SetDisableCompleteButtonImageName:(NSString *)name;
- (void)mTK_SetCompleteButtonAccessibilityLabel:(NSString *)label;

//???????????? ???????????? ??????
- (void)mTK_SetSecureFieldHidden:(BOOL)hidden;

- (void)mTK_UseShiftOptional:(BOOL)bUse;

- (void)mTK_ClearDelegateSubviews;

- (NSInteger)mTK_GetInputLength;

- (void)mTK_EnableSamekeyInputDataEncrypt:(BOOL)bEnable;

- (void)showModalViewAnimated:(BOOL)animated;

- (void)hideModalView;

- (void)mTK_SetModalPositionWithPosX:(CGFloat)PosX PosY:(CGFloat)PosY;

- (void)mTK_SetPBKDF_RandKey:(NSData*)randkey;

// ??????????????? ???????????? ??????????????? ????????? ????????? ?????? - bugFix2 Merge
- (void) mTK_SwapSymbolToRearrange:(BOOL)isSwap;

//???????????? ??????
- (int) mTK_LicenseCheck : (NSString *) fileName;
@end
