//
//  KCLBarcodeZoomViewController.h
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLBarcodeZoomViewController
@date 2021.04.21
@brief 바코드 확대
*/

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KCLBarcodeZoomViewController : ViewController

@property (nonatomic, retain) NSString *codeString;
@property (nonatomic, assign) NSTimeInterval endTime;

@end

NS_ASSUME_NONNULL_END
