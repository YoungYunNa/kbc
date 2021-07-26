//
//  virtual_keypad.h
//  virtual-keypad
//
//  Created by 하 지윤 on 2014. 5. 22..
//  Copyright (c) 2014년 Penta Security Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

/*!
 * @brief PentaKeypad 기능을 API 형태로 제공하는 클래스
 */
@interface PentaKeypad : NSObject

#pragma mark - 암복호화 관련 함수

/*!
 @brief 비밀키를 생성한다.
 @param key
        비밀키의 버퍼
 @param keySize
        비밀키의 버퍼 크기
 @return 없음
 */
+ (void)generateKey:(unsigned char *)key
            keySize:(unsigned int)keySize;

/*!
 @brief 암호화 된 문자열을 서버로 보내 복호화한다.
 @param encryptedText
        암호화 된 문자열
 @param serverURL
        복호화 서버의 URL
 @param sessionKey
        암호화 키
 @param sessionKeySize
        암호화 키의 크기
 @param publicKey
        서버의 공개키
 @param encryptID
        서버에서 사용할 암호화 ID
 @return 복호화 된 메시지
 */
+ (NSString *)getDecryptedText:(NSString *)encryptedText
                    fromServer:(NSString *)serverURL
                withSessionKey:(unsigned char *)sessionKey
                sessionKeySize:(unsigned int)sessionKeySize
                 withPublicKey:(NSString *)publicKey
                     encryptID:(NSString *)encryptID;

#pragma mark - 키패드 관련 함수 (전체 설정)

/*!
 @brief 키패드 이미지의 경로를 설정한다. (전체 설정)
 @param directory
        키패드 이미지의 경로
 @return 없음
 */
+ (void)setResourceDirectory:(NSString *)directory;

/*!
 @brief 키패드 상단 레이블에 사용할 폰트를 설정한다. (전체 설정)
 @param newFont
        변경할 폰트
 @return 없음
 */
+ (void)setUpperMessageFont:(UIFont *)newFont;

#pragma mark - 함수 호출만으로 사용하는 함수

/*!
 @brief 입력한 텍스트필드의 키패드를 보안키패드로 변경한다.
 @param textfield
        보안키패드로 대체할 텍스트필드
 @param textfieldName
        텍스트필드를 구분하는 이름 (한 화면에 여러개의 텍스트필드가 존재할 경우, 구분을 위한 값이 필요함)
 @param useEncryption
        입력값 암호화 여부
 @param encryptionKey
        암호화 키
 @param keyLength
        키의 길이
 @param maxLength
        입력값의 최대 길이
 @param useUpperDone
        키패드 상단 완료 버튼 사용 여부
 @param useUpperCancel
        키패드 상단 취소 버튼 사용 여부
 @param useUpperTextfield
        키패드 상단 텍스트필드 사용 여부
 @param upperMessage
        키패드 상단에 표시될 메시지 (폰트 변경은 setUpperMessageFont: 로 전체의 설정을 변경할 수 있다)
 @param delegate
        키패드 이벤트를 처리할 객체
 @return 없음
 */
+ (void)replaceKeypad:(UITextField *)textfield
        textfieldName:(NSString *)textfieldName
        useEncryption:(BOOL)useEncryption
              withKey:(const unsigned char *)encryptionKey
            keyLength:(unsigned int)keyLength
            maxLength:(unsigned int)maxLength
         useUpperDone:(BOOL)useUpperDone
       useUpperCancel:(BOOL)useUpperCancel
    useUpperTextfield:(BOOL)useUpperTextfield
         upperMessage:(NSString *)upperMessage
   enableChangeKeypad:(BOOL)enableChangeKeypad
        pentaDelegate:(id)delegate;

/*!
 @brief 보안키패드를 띄운다.
 @param textfieldName
        텍스트필드를 구분하는 이름 (텍스트필드는 내부에서 자체 생성)
 @param keyboardType
        텍스트필드의 타입
 @param superView
        텍스트필드가 추가될 View
 @param useEncryption
        입력값 암호화 여부
 @param encryptionKey
        암호화 키
 @param keyLength
        키의 길이
 @param maxLength
        입력값의 최대 길이
 @param useUpperDone
        키패드 상단 완료 버튼 사용 여부
 @param useUpperCancel
        키패드 상단 취소 버튼 사용 여부
 @param useUpperTextfield
        키패드 상단 텍스트필드 사용 여부
 @param upperMessage
        키패드 상단에 표시될 메시지 (폰트 변경은 setUpperMessageFont: 로 전체의 설정을 변경할 수 있다)
 @param delegate
        키패드 이벤트를 처리할 객체
 @return 없음
 */
+ (void)showKeypad:(NSString *)textfieldName
          withType:(UIKeyboardType)keyboardType
       inSuperView:(UIView *)superView
     useEncryption:(BOOL)useEncryption
           withKey:(const unsigned char *)encryptionKey
         keyLength:(unsigned int)keyLength
         maxLength:(unsigned int)maxLength
      useUpperDone:(BOOL)useUpperDone
    useUpperCancel:(BOOL)useUpperCancel
 useUpperTextfield:(BOOL)useUpperTextfield
      upperMessage:(NSString *)upperMessage
     pentaDelegate:(id)delegate;

/*!
 @brief showKeypad를 이용해 띄운 키패드를 모두 내린다.
 */
+ (void)allKeypadDown;

/*!
 @brief 팝업 형태의 입력화면을 띄운다.
 @param textfield
        보안키패드로 대체할 텍스트필드
 @param superView
        팝업을 띄우는 화면의 ViewController
 @param useEncryption
        입력값 암호화 여부
 @param encryptionKey
        암호화 키
 @param keyLength
        키의 길이
 @param maxLength
        입력값의 최대 길이
 @return 없음
 */
+ (void)popupKeypad:(UITextField *)textfield
        inSuperView:(UIViewController *)superView
      useEncryption:(BOOL)useEncryption
            withKey:(const unsigned char *)encryptionKey
          keyLength:(unsigned int)keyLength
          maxLength:(unsigned int)maxLength __attribute__((deprecated("관리되지 않는 함수입니다. 팝업은 PentaTextField 클래스를 이용하여 직접 만들 수 있습니다.")));

/*!
 @brief 텍스트필드에 입력된 값을 가져온다. (암호화 되었을 경우 암호화 된 문자열)
 @note  delegate를 사용하지 않고, 입력된 값을 명시적으로 가져오고 싶을 경우 사용하는 함수
 @param textfieldName
        텍스트필드를 구분하는 이름
 @return 입력된 문자열
 */
+ (NSString *)getInputText:(NSString *)textfieldName;

#pragma mark - Custom TextField를 만들었을 경우 사용하는 함수

/*!
 @brief 펜타시큐리티시스템의 키패드를 사용하는 UIViewController 를 생성한다.
 @param textfield
        보안키패드로 대체할 텍스트필드
 @return 생성된 키패드 UIViewController (이 객체의 view를 UITextField의 inputView 에 사용하면 됨)
 */
+ (UIViewController *)createInputViewController:(UITextField *)textfield;

/*!
 @brief 암호화에 사용할 키와 키의 길이를 입력한다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param encryptionKey
        암호화 키
 @param keyLength
        키의 길이
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
    encryptionKey:(const unsigned char *)encryptionKey
        keyLength:(unsigned int)keyLength;

/*!
 @brief 텍스트 필드에서 입력받을 최대값을 지정한다.
 @note 지정한 크기만큼 입력할 경우, 입력이 종료되고 키패드는 내려간다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param maxLength
        입력 최대값
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
        maxLength:(unsigned int)maxLength;

/*!
 @brief 키패드 상단의 완료 버튼을 사용할 지 여부를 설정한다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param useUpperDone
        상단 완료 버튼 사용 여부
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
     useUpperDone:(BOOL)useUpperDone;

/*!
 @brief 키패드 상단의 취소 버튼을 사용할 지 여부를 설정한다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param useUpperCancel
        상단 취소 버튼 사용 여부
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
   useUpperCancel:(BOOL)useUpperCancel;

/*!
 @brief 키패드 상단의 완료 버튼의 레이블을 변경한다. (for accessibility)
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param upperDoneLabel
        상단 완료 버튼에 사용할 레이블. Accessbility를 위한 값으로 실제 화면에 보이는 글씨는 이미지이기 때문에 해당 이미지를 변경해줘야 한다.
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
   upperDoneLabel:(NSString *)upperDoneLabel;

/*!
 @brief 키패드 상단의 취소 버튼의 레이블을 변경한다. (for accessibility)
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param upperCancelLabel
        상단 취소 버튼에 사용할 레이블. Accessbility를 위한 값으로 실제 화면에 보이는 글씨는 이미지이기 때문에 해당 이미지를 변경해줘야 한다.
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
 upperCancelLabel:(NSString *)upperCancelLabel;

/*!
 @brief 키패드 상단의 텍스트필드를 사용할 지 여부를 설정한다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param useUpperTextfield
        상단 텍스트필드 사용 여부
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
useUpperTextfield:(BOOL)useUpperTextfield;

/*!
 @brief 키패드 상단의 레이블에 출력할 메시지를 지정한다. (없으면 표시하지 않음)
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param upperMessage
        메시지
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
     upperMessage:(NSString *)upperMessage;

/*!
 @brief 키패드 상단의 레이블에 출력할 메시지의 폰트를 변경한다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param upperMessageFont
        변경할 폰트
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
 upperMessageFont:(UIFont *)upperMessageFont;

/*!
 @brief 키패드의 Delegate를 설정한다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param delegate
        delegate 객체
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
    pentaDelegate:(id)delegate;

/*!
 @brief 키패드가 제어할 텍스트 필드를 설정한다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param textfield
        키패드가 제어할 텍스트필드
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
  targetTextfield:(UITextField *)textfield;


/*!
 @brief 키패드 타입 변경을 가능하도록 한다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @param enable
        키패드 타입 변경 가능 여부
 @return 성공(YES), 실패(NO)
 */
+ (BOOL)setKeypad:(UIViewController *)controller
enableChangeKeypad:(BOOL)enable;

/*!
 @brief 키패드에서 입력받은 문자열을 가져온다.
 @param controller
        createInputViewController: 를 이용해 생성한 view controller
 @return 입력받은 문자열
 */
+ (NSString *)inputTextFromKeypad:(UIViewController *)controller;

@end
