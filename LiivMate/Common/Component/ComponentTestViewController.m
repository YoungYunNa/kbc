//
//  ComponentTestViewController.m
//  LiivMate
//
//  Created by KB on 03/03/2020.
//  Copyright © 2020 KBCard. All rights reserved.
//

#import "ComponentTestViewController.h"
#import "TimeSelecterView.h"
#import "MobileWeb.h"
@interface ComponentTestViewController ()

@end

@implementation ComponentTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)didTouchAddressBook:(id)sender{
    NSLog(@"%s", __FUNCTION__);
}

typedef void(^completionHandler)(UIViewController *vc);
typedef void (^DateChangeHandler)(NSDate *date);
static DateChangeHandler deliveryDateChangeHandler;

- (IBAction)didTouchTimePicker:(id)sender{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Component" bundle:nil] instantiateViewControllerWithIdentifier:@"TimeSelecterView"];
    
    deliveryDateChangeHandler = ^(NSDate *date){
//        self->date = date;
//        self.AccidentDate.text = [Utility timeStringFromDate:date format:@"M월 dd일 (EEE) HH:mm"];
    };
    
    completionHandler completion = ^(id vc){
        TimeSelecterView *timeSelecterView = vc;
        timeSelecterView.Title.text = @"시간을 선택해 주세요";
        timeSelecterView.blockDateChangeHandler = deliveryDateChangeHandler;
        timeSelecterView.datePicker.date = [NSDate date]; //[[NSDate date] dateByAddingTimeInterval:(24 * 60 * 60)];
        timeSelecterView.datePicker.baseDate = [NSDate date];
        
        NSInteger gap = [NSDate date].timeIntervalSince1970 - timeSelecterView.datePicker.date.timeIntervalSince1970;
        timeSelecterView.datePicker.minDateIntervalMinutes = 0;
        timeSelecterView.datePicker.maxDateIntervalMinutes = gap / (10 * 60);
        timeSelecterView.datePicker.minPossibleTime = @"0000".integerValue;
        timeSelecterView.datePicker.maxPossibleTime = @"2400".integerValue;
        [timeSelecterView.datePicker setUseOutboundury:YES];
        [timeSelecterView.datePicker setForAccident:YES];
        [timeSelecterView.datePicker updateWithForReturn:NO];
    };

    if(vc) {
        vc.view.layer.shadowOpacity = 0.3;
        vc.view.layer.shadowColor = UIColor.blackColor.CGColor;
        vc.view.layer.shadowRadius = 20;
        vc.view.clipsToBounds = NO;
        vc.view.backgroundColor = UIColor.clearColor;

        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        vc.providesPresentationContextTransitionStyle = YES;
        vc.definesPresentationContext = YES;
        if(self){
            [self presentViewController:vc animated:YES completion:^(){
                vc.view.clipsToBounds = YES;
                if(completion) completion(vc);
            }];
        } else {
            if(completion) completion(vc);
        }
    } else {
        if(completion) completion(vc);
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
