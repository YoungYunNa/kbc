//
//  KCLBarcodeZoomViewController.m
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLBarcodeZoomViewController.h"

#import "BarCodeImageView.h"

@interface KCLBarcodeZoomViewController ()

@property (strong, nonatomic) IBOutlet UIView *containView;
@property (weak, nonatomic) IBOutlet BarCodeImageView *barcodeView;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation KCLBarcodeZoomViewController

#pragma mark - Barcode Zoom View Init
-(void)initSettings
{
    [super initSettings];
    self.modalPresentationStyle = UIModalPresentationCustom;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _barcodeView.codeStr = self.codeString;
    _codeLabel.text = _barcodeView.codeStr.formatOtcNum;
    
    if(_endTime)
        [self runTime];
    else
        _timeLabel.superview.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.frame), 0);
    [UIView animateWithDuration:0.2 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    [AppInfo sharedInfo].lcdBrightnessValue = [UIScreen mainScreen].brightness;
    [[UIScreen mainScreen] setBrightness:1.0];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runTime) object:nil];
    if([AppInfo sharedInfo].lcdBrightnessValue > 0)
        [[UIScreen mainScreen] setBrightness:[AppInfo sharedInfo].lcdBrightnessValue];
    [AppInfo sharedInfo].lcdBrightnessValue = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Button Action
- (IBAction)backButtonAction:(UIButton*)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.frame), 0);
    }completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - Barcod Timer
-(void)runTime
{
    int time = _endTime - [NSDate date].timeIntervalSince1970;
    if(time >= 0)
    {
        _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", time/60, time%60];
        NSString *timeStr2 = [NSString stringWithFormat:@"유효시간 %02d분%02d초", time/60, time%60];
        [_timeLabel.superview setAccessibilityLabel:timeStr2];
        //NSLog(@"유효시간 : %@",_timeLabel.text);
        [self performSelector:@selector(runTime) withObject:nil afterDelay:1];
        
        if(UIAccessibilityIsVoiceOverRunning() && _timeLabel.superview.accessibilityElementIsFocused && time%10 == 0)
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, timeStr2);
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
