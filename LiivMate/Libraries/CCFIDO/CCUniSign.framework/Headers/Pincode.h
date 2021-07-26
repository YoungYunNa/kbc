//
//  Pincode.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 6. 17..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#ifndef Pincode_h
#define Pincode_h


#endif /* Password_h */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PopView.h"

@interface Pincode : UIViewController<UITextFieldDelegate>


@property (nonatomic, assign) IBOutlet UIButton *btVerify;
//현제 비밀번호
@property (strong, nonatomic) IBOutlet UILabel *lbCurrentPW;
@property (strong, nonatomic) IBOutlet UITextField *tfCurrentPW;
//@property (strong, nonatomic) IBOutlet UITextField *tfCurrentPW1;
//@property (strong, nonatomic) IBOutlet UITextField *tfCurrentPW2;
//@property (strong, nonatomic) IBOutlet UITextField *tfCurrentPW3;
//@property (strong, nonatomic) IBOutlet UITextField *tfCurrentPW4;

//신규 비밀번호
@property (strong, nonatomic) IBOutlet UILabel *lbNewPW;
@property (strong, nonatomic) IBOutlet UITextField *tfNewPW;
//@property (strong, nonatomic) IBOutlet UITextField *tfPW1;
//@property (strong, nonatomic) IBOutlet UITextField *tfPW2;
//@property (strong, nonatomic) IBOutlet UITextField *tfPW3;
//@property (strong, nonatomic) IBOutlet UITextField *tfPW4;

//신규 비밀번호 확인
@property (strong, nonatomic) IBOutlet UILabel *lbRetryPW;
@property (strong, nonatomic) IBOutlet UITextField *tfConfirmPW;
//@property (strong, nonatomic) IBOutlet UITextField *tfPW5;
//@property (strong, nonatomic) IBOutlet UITextField *tfPW6;
//@property (strong, nonatomic) IBOutlet UITextField *tfPW7;
//@property (strong, nonatomic) IBOutlet UITextField *tfPW8;


//@property (nonatomic, assign) IBOutlet UITextField *tfPW1;
//@property (nonatomic, assign) IBOutlet UITextField *tfPW2;
//@property (nonatomic, assign) IBOutlet UITextField *tfPW3;
//@property (nonatomic, assign) IBOutlet UITextField *tfPW4;
//
//@property (nonatomic, assign) IBOutlet UITextField *tfPW5;
//@property (nonatomic, assign) IBOutlet UITextField *tfPW6;
//@property (nonatomic, assign) IBOutlet UITextField *tfPW7;
//@property (nonatomic, assign) IBOutlet UITextField *tfPW8;


@property (nonatomic, copy) void (^pincodeResult)(NSString *response);
//핀코드 타입 등록, 수정, 삭제
@property (nonatomic) int pincodeType;
//핀코드 설정 길이
@property (nonatomic) int pincodeLength;

@property (nonatomic, strong) NSString *textCurrentPincode;
@property (nonatomic, strong) NSString *textNewPincode;
@property (nonatomic, strong) NSString *textConfirmPincode;

//핀코드 배경 색상
@property (nonatomic, strong) NSString *pincodeBgColor;
//핀코드 배경 알파값
@property (nonatomic) long pincodeBgColorA;

-(void)textFieldDidEndEditing:(UITextField *)textField;

-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

-(void)finishViewControll;

/**
 @discussion 입력된 핀코드와 저장된 핀코드를 비교한다.
 */
-(BOOL)checkPincodeWithEnrolledPincode:(NSString *)pincode;

/**
 @discussion 핀코드를 등록한다.
 */
-(BOOL)insertPincode:(NSString *)pincode;

/**
 @discussion 핀코드를 변경한다.
 */
-(BOOL)changePincode:(NSString *)pincode;

/**
 @discussion 핀코드를 삭제한다.
 */
-(BOOL)deletePincode;

/**
 @discussion 핀코드를 확인실패 횟수를 증가 시킨다.
 */
-(void)increasePasswordVerificationFailureCount;

/**
 @discussion 핀코드를 확인실패 횟수를 초기화 한다.
 */
-(void)resetPasswordVerificationFailureCount;

/**
 @discussion 핀코드를 확인실패 횟수를 가져온다.
 */
-(int)getPasswordVerificationFailureCount;
@end
