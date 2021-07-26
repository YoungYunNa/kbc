//
//  KCLPaymentCancelPopupView.m
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLPaymentCancelPopupView.h"

@implementation KCLPaymentCancelPopupView

#pragma mark - Payment Cancel Popup View
+ (KCLPaymentCancelPopupView *)showPopupWithType:(KCLPaymentCancelPopupType)type
                             barcodeValue:(NSString *)barcodeValue
                               remainTime:(NSTimeInterval)remainTime
                                checkTime:(NSTimeInterval)checkTime
                            checkFunction:(NSString *)checkFunction
                             checkWebView:(id<WebView>)checkWebView
                          dismissCallback:(KCLPaymentCancelPopupCallback)dismissCallback {
    // ???? TODO
    KCLPaymentCancelPopupView *popupView = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PaymentPopup" owner:nil options:nil];
    for (id obj in objects)
    {
        if ([obj isKindOfClass:[KCLPaymentCancelPopupView class]] && ((KCLPaymentCancelPopupView *)obj).tag == type)
        {
            popupView = obj;
            break;
        }
    }

    if (popupView->_remainTimeView && remainTime <= 0)
    {
        popupView->_remainTimeView.hidden = YES;
        popupView.bounds = CGRectMake(0, 0, popupView.bounds.size.width, popupView.bounds.size.height - (popupView->_remainTimeView.frame.origin.y + popupView->_remainTimeView.frame.size.height));
    }
    
    if (popupView)
    {
        [(KCLPaymentCancelPopupView *)popupView setupWithType:type
                                          barcodeValue:barcodeValue
                                            remainTime:remainTime];
        
        // check javascript 실행
        if (checkWebView && checkFunction.length > 0 && checkTime > 0)
        {
            popupView->_checkTime = checkTime;
            popupView->_checkFunction = checkFunction;
            popupView->_checkWebView = checkWebView;
            
            [popupView performSelector:@selector(processCheckFunction) withObject:nil afterDelay:checkTime];
        }

        [BlockAlertView showBlockAlertCustomCallback:^(BlockAlertView *alertView) {
            alertView.isShowClosedBtn = NO;
            alertView.isFullCustomView = YES;
            alertView.isTouchDisable = YES;
            alertView.message = popupView;
        } dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == KCLPaymentCancelPopupCloseTypeTimeout)
            {
                KCLPaymentCancelPopupView *recreationPopupView = [self showPopupWithType:KCLPaymentCancelPopupTypeTimeout
                                                                     barcodeValue:nil
                                                                       remainTime:0
                                                                        checkTime:checkTime
                                                                    checkFunction:checkFunction
                                                                     checkWebView:checkWebView
                                                                  dismissCallback:dismissCallback];

                if (type == KCLPaymentCancelPopupTypeQR)
                {
                    recreationPopupView->_descriptionLabel.text = [recreationPopupView->_descriptionLabel.text stringByReplacingOccurrencesOfString:@"바코드" withString:@"QR코드"];
                    [recreationPopupView->_barcodeRecreateButton setTitle:[[recreationPopupView->_barcodeRecreateButton titleForState:UIControlStateNormal] stringByReplacingOccurrencesOfString:@"바코드" withString:@"QR코드"] forState:UIControlStateNormal];
                }
            }
            else
            {
                if (dismissCallback) dismissCallback((KCLPaymentCancelPopupCloseType)buttonIndex);
            }
        }];
        
        return popupView;
    }
    else
    {
        return nil;
    }
}

- (void)setupWithType:(KCLPaymentCancelPopupType)type barcodeValue:(NSString *)barcodeValue remainTime:(NSTimeInterval)remainTime {
    _type = type;
    
    _remainSeconds = remainTime;
    if (remainTime > 0) [self updateRemainTime];
    
    _barcodeImageView.isQRType = (type == KCLPaymentCancelPopupTypeQR);
    _barcodeImageView.codeStr = barcodeValue;
    
    _barcodeValueLabel.text = barcodeValue;
    
    // 팝업 종료 노티피케이션
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePopup:) name:HideQRNotification object:nil];
}

#pragma mark - Check Process / Update Time
- (void)updateRemainTime {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateRemainTime) object:nil];
    int minute = (int)_remainSeconds / 60;
    int seconds = (int)_remainSeconds % 60;
    _remainTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", minute, seconds];
    
    if (_remainSeconds <= 0)
    {
        // 유효시간 종료
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(processCheckFunction) object:nil];
        [[BlockAlertView currentAlert] dismissWithClickedButtonIndex:KCLPaymentCancelPopupCloseTypeTimeout animated:YES];
    }
    else
    {
        _remainSeconds -= 0.2;
        [self performSelector:@selector(updateRemainTime) withObject:nil afterDelay:0.2];
    }
}

- (void)processCheckFunction {
    NSString *javascript = [NSString stringWithFormat:@"%@();", _checkFunction];
    [(HybridWKWebView *)_checkWebView stringByEvaluatingJavaScriptFromString:javascript completionHandler:^(NSString *result){}];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(processCheckFunction) object:nil];
    [self performSelector:@selector(processCheckFunction) withObject:nil afterDelay:_checkTime];
}

#pragma mark - Button Action
-(void)closePopup:(NSNotification*)noti {
    [self closeButtonClicked:nil];
}

- (IBAction)closeButtonClicked:(id)sender {
    // 팝업 닫기 버튼 클릭
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateRemainTime) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(processCheckFunction) object:nil];
    [[BlockAlertView currentAlert] dismissWithClickedButtonIndex:KCLPaymentCancelPopupCloseTypeCloseButton animated:YES];
}

- (IBAction)barcodeRecreateButtonClicked:(id)sender {
    // 바코드 재생성 버튼 클릭
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateRemainTime) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(processCheckFunction) object:nil];
    [[BlockAlertView currentAlert] dismissWithClickedButtonIndex:KCLPaymentCancelPopupCloseTypeRecreationButton animated:YES];
}

@end

#pragma mark - Payment Request Popup
@implementation KCLPaymentRequestPopupView

+ (KCLPaymentCancelPopupView *)showPopupWithType:(KCLPaymentCancelPopupType)type
                             barcodeValue:(NSString *)barcodeValue
                               remainTime:(NSTimeInterval)remainTime
                                checkTime:(NSTimeInterval)checkTime
                            checkFunction:(NSString *)checkFunction
                             checkWebView:(id<WebView>)checkWebView
                          dismissCallback:(KCLPaymentCancelPopupCallback)dismissCallback {
    
    KCLPaymentCancelPopupView *popup = [super showPopupWithType:type
                                            barcodeValue:barcodeValue
                                              remainTime:remainTime
                                               checkTime:checkTime
                                           checkFunction:checkFunction
                                            checkWebView:checkWebView
                                         dismissCallback:dismissCallback];
    {
        if (type == KCLPaymentCancelPopupTypeQR) {
            popup->_titleLabel.text = @"결제요청";
            popup->_descriptionLabel.text = @"결제 요청 QR코드를\n고객에게 보여주세요.";
        }
        else if (type == KCLPaymentCancelPopupTypeTimeout) {
            popup->_titleLabel.text = @"결제요청";
            popup->_descriptionLabel.text = @"결제요청 유효시간이 초과되었습니다.\nQR코드를 다시 생성해주세요.";
            [popup->_barcodeRecreateButton setTitle:@"QR코드 재생성" forState:UIControlStateNormal];
        }
    }
    
    return popup;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
