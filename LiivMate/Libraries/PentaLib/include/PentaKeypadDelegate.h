//
//  PentaKeypadDelegate.h
//  virtual-keypad
//
//  Created by pki on 2014. 12. 17..
//  Copyright (c) 2014년 Penta Security Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PentaKeypadDelegate <UITextFieldDelegate>

@optional

/**
 @brief done button clicked
 */
- (void)pentaKeypadReleased:(UITextField *)textfield
                      value:(NSString *)value
 __attribute__((deprecated("구버전 호환용. pentaKeypadEditingDone:inputText: 로 변경됨")));

/**
 @brief cancel button clicked
 */
- (void)pentaKeypadReleased:(UITextField *)textfield
__attribute__((deprecated("구버전 호환용. pentaKeypadEditingCancel: 으로 변경됨")));

/**
 @brief end editing
 */
- (void)pentaKeypadEditingDone:(UITextField *)textfield
                     inputText:(NSString *)inputText;

/**
 @brief cancel editing
 */
- (void)pentaKeypadEditingCancel:(UITextField *)textfield;

@end
