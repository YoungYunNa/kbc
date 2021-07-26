//
//  KCLQRScannerViewController.h
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLQRScannerViewController
@date 2021.04.21
@brief QR 스캔
*/

#import "ViewController.h"


@interface KCLQRScannerViewController : ViewController

@property (nonatomic, assign) NSInteger type;//0 = 포인트리 보내기, 1 = 결제취소
@property (nonatomic, copy) void (^finishedCallback)(NSString *result, BOOL isCancel);

@end
