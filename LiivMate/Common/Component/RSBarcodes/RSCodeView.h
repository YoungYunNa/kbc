//
//  RSCodeView.h
//  RSBarcodes
//
//  Created by R0CKSTAR on 12/25/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSCodeView : UIView

@property (nonatomic, retain) UIImage  *code;
@property (nonatomic, assign) UIEdgeInsets imageInsets;
@property (nonatomic, retain) NSString *contents;

@end
