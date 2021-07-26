//
//  PentaTextField.h
//  virtual-keypad
//
//  Created by 하 지윤 on 2014. 11. 29..
//  Copyright (c) 2014년 Penta Security Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PentaTextField : UITextField<UITextFieldDelegate> {
    
    /**
     @brief 키패드 이벤트를 처리할 객체
     */
    id pentaDelegate;
    
    /**
     @brief 키패드를 자동으로 내리기 위해 텍스트 최대 길이
     */
    unsigned int maxLength;
    
    /**
     @brief 키패드 상단 완료버튼 사용 여부
     */
    BOOL useUpperDone;
    
    /**
     @brief 키패드 상단 취소버튼 사용 여부
     */
    BOOL useUpperCancel;
    
    /**
     @brief 키패드 상단 텍스트필드 사용 여부
     */
    BOOL useUpperTextfield;
    
    /**
     @brief 키패드 상단에 표시될 메시지
     */
    NSString *upperMessage;
    
    /**
     @brief 키패드 상단에 표시될 메시지의 폰트
     */
    UIFont *upperMessageFont;
    
    /**
     @brief 키패드 전환이 가능하도록 한다.
     */
    BOOL enableChangeKeypad;
}

@property(retain) id pentaDelegate;
@property() unsigned int maxLength;
@property() BOOL useUpperDone;
@property() BOOL useUpperCancel;
@property() BOOL useUpperTextfield;
@property(retain) NSString *upperMessage;
@property(retain) UIFont *upperMessageFont;
@property() BOOL enableChangeKeypad;

/**
 @brief 암호화 관련 값을 설정한다.
 @param encryptionKey
        암호화 키 (nil 일 경우 암호화 해제됨)
 @param keyLength
        암호화 키의 길이 (0 일 경우 암호화 해제됨)
 @return 없음
 */
- (void)setEncryptionKey:(unsigned char *)encryptionKey keyLength:(unsigned int)keyLength;

/**
 @brief 키패드로 입력된 텍스트를 가져온다.
 @return 키패드로 입력한 텍스트
 */
- (NSString *)inputText;

@end
