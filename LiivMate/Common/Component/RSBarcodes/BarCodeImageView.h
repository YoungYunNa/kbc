//
//  BarCodeImageView.h
//  NewKBCardShop
//
//  Created by SeungYong Oh on 13. 2. 22..
//
//

/**
 @file BarCodeImageView.h
 @date 2013/02/22
 @author 오승용
 @brief 바코드를 입력받아 이미지로 보여주는 뷰
 */

#import <UIKit/UIKit.h>
#import "RSCodeView.h"
@interface BarCodeImageView : RSCodeView
@property (nonatomic, assign) BOOL isQRType;
@property (nonatomic, retain) NSString *codeStr;
@end

@interface BarCodeButton : UIButton
@property (nonatomic, assign) BOOL isQRType;
@property (nonatomic, retain) NSString *codeStr;
@end