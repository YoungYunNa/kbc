//
//  TimeSelecterView.h
//  ios_user
//
//  Created by HD7650 on 2018. 5. 18..
//  Copyright © 2018년 Dongbu NTS. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^ValidateHandler)(BOOL isValidate, NSString *description);
typedef void (^DateChangeHandler)(NSDate *date);

@interface DCCDatePicker : UIView

@property (assign, nonatomic) BOOL visibleOutbound;
@property (assign, nonatomic) int visibleRows;
@property (assign, nonatomic) NSInteger minDateIntervalMinutes;
@property (assign, nonatomic) NSInteger maxDateIntervalMinutes;
@property (assign, nonatomic) NSInteger minPossibleTime;
@property (assign, nonatomic) NSInteger maxPossibleTime;
@property (assign, nonatomic) BOOL forAccident;
@property (assign, nonatomic) BOOL forReturn;
@property (assign, nonatomic) BOOL isEmart;
@property (assign, nonatomic) BOOL useOutboundury;
@property (assign, nonatomic) BOOL useKeepingServiceTime;
@property (strong, nonatomic) NSDate *baseDate;
@property (strong, nonatomic) NSDate *date;

@property (weak, nonatomic) ValidateHandler blockValidateHandler;
@property (weak, nonatomic) DateChangeHandler blockDateChangeHandler;

- (void)update;
- (void)updateWithForReturn:(BOOL)forReturn;
- (void)reloadAllComponents;

@end



@interface TimeSelecterView : UIViewController

@property (strong, nonatomic) NSString *rentYn;

@property (weak, nonatomic) IBOutlet DCCDatePicker * datePicker;

@property (weak, nonatomic) DateChangeHandler blockDateChangeHandler;

@property (weak, nonatomic) IBOutlet UIView *BackgroundView;
@property (weak, nonatomic) IBOutlet UIView *icon;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UILabel *Descryption;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerBottom;

@end
