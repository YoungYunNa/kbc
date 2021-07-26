//
//  KCLQRScannerViewController.m
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLQRScannerViewController.h"

#import "RSScannerView.h"

@interface KCLQRScannerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet RSScannerView *scanner;
@property (weak, nonatomic) IBOutlet UIImageView *scannerImageView;
@property (weak, nonatomic) IBOutlet UIView *scannerScopeView;
@property (weak, nonatomic) IBOutlet UIImageView *scannerScopeImageView;

@end

@implementation KCLQRScannerViewController

#pragma mark - QRScanner Init
-(void)initPreprocessingCallback:(void (^)(BOOL success))callback
{
    [Permission checkCameraSettingAlert:YES permission:^(PERMISSION_STATUS statusNextProccess) {
        if(callback)
            callback(statusNextProccess == PERMISSION_USE);
    }];
}

-(void)initSettings
{
    [super initSettings];
    self.modalPresentationStyle = UIModalPresentationCustom;
    _type = NSNotFound;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _scanner.maskView.hidden = YES;
    _scanner.delegate = self;
    
    CGRect statusBarRect = [UIApplication sharedApplication].statusBarFrame;
    
    NSInteger nTopY = statusBarRect.size.height+50+48;
    NSInteger nScanHeight = self.scannerScopeImageView.image.size.height-40;

    CGRect qrScopeRect = CGRectMake(80, nTopY, 214, nScanHeight);
    if(CGRectGetWidth([UIScreen mainScreen].bounds) > 375)
        qrScopeRect.size.width = CGRectGetWidth(qrScopeRect) + (CGRectGetWidth([UIScreen mainScreen].bounds)-375);
    else
        qrScopeRect.origin.x -= (375 - CGRectGetWidth([UIScreen mainScreen].bounds)) / 2;
    
//    _scanner.qrScopeRect = [UIScreen mainScreen].bounds;  //qrScopeRect; //qr스캔 영역만 넓혀주면 스캔영역 전체화면으로 늘어남.
    _scanner.qrScopeRect = qrScopeRect;
    
    if(_type == 1)
    {//결제취소
        _descriptionLabel.hidden = YES;
        _infoLabel.text = @"인식하고자 하는 QR코드를 해당 영역에\n맞춰주세요";
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([Permission getCameraPermission] != PERMISSION_USE)
    {
        [Permission checkCameraSettingAlert:YES permission:^(PERMISSION_STATUS statusNextProccess) {
            if(statusNextProccess == PERMISSION_USE)
                self->_scanner.startRunning = YES;
        }];
    }
    else
        _scanner.startRunning = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _scanner.startRunning = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Button Action
- (IBAction)backButtonAction:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if(self->_finishedCallback)
            self->_finishedCallback(nil, YES);
    }];
}

#pragma mark -  RSScannerQRCodeDelegate
- (void)qrCodeScanner:(RSScannerView*)scanner didScanResult:(NSString *)result
{
    scanner.startRunning = NO;
    NSLog(@"%@",result);
    [self dismissViewControllerAnimated:YES completion:^{
        if(self->_finishedCallback)
            self->_finishedCallback(result,NO);
    }];
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
