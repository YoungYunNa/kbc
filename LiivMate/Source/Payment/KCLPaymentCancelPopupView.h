//
//  KCLPaymentCancelPopupView.h
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLPaymentCancelPopupView
@date 2021.04.21
@brief 결제취소 알림화면
*/

#import <UIKit/UIKit.h>

#import "BarCodeImageView.h"

typedef enum
{
    KCLPaymentCancelPopupTypeBarcode = 100,
    KCLPaymentCancelPopupTypeQR = 200,
    KCLPaymentCancelPopupTypeTimeout = 300
}
KCLPaymentCancelPopupType;

typedef enum
{
    KCLPaymentCancelPopupCloseTypeCloseButton = 0,
    KCLPaymentCancelPopupCloseTypeTimeout,
    KCLPaymentCancelPopupCloseTypeRecreationButton,
}
KCLPaymentCancelPopupCloseType;

typedef void (^KCLPaymentCancelPopupCallback)(KCLPaymentCancelPopupCloseType closeType);

@interface KCLPaymentCancelPopupView : UIView
{
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UILabel *_descriptionLabel;
    __weak IBOutlet UIButton *_barcodeRecreateButton;
    
    __weak IBOutlet UIView *_remainTimeView;
    
    __weak IBOutlet UILabel *_remainTimeLabel;              // 유효시간
    __weak IBOutlet BarCodeImageView *_barcodeImageView;    // 바코드 이미지뷰 (barcode, QR)
    __weak IBOutlet UILabel *_barcodeValueLabel;            // 바코드 번호
    
    NSTimeInterval _remainSeconds;
    KCLPaymentCancelPopupType _type;
    
    NSTimeInterval _checkTime;
    NSString *_checkFunction;
    id<WebView> _checkWebView;
}

+ (KCLPaymentCancelPopupView *)showPopupWithType:(KCLPaymentCancelPopupType)type
                             barcodeValue:(NSString *)barcodeValue
                               remainTime:(NSTimeInterval)remainTime
                                checkTime:(NSTimeInterval)checkTime
                            checkFunction:(NSString *)checkFunction
                             checkWebView:(id<WebView>)checkWebView
                          dismissCallback:(KCLPaymentCancelPopupCallback)dismissCallback;
@end

@interface KCLPaymentRequestPopupView : KCLPaymentCancelPopupView
@end

