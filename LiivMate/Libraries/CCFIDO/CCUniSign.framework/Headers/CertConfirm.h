//
//  CertConfirm.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 4. 27..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#ifndef CertConfirm_h
#define CertConfirm_h


#endif /* CertConfirm_h */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CertConfirm : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UILabel *lbCommonName;
@property (strong, nonatomic) IBOutlet UILabel *lbKeyUsage;
@property (strong, nonatomic) IBOutlet UILabel *lbValidityBeginDate;
@property (strong, nonatomic) IBOutlet UILabel *lbValidityEndDate;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selectorComplete;

@end