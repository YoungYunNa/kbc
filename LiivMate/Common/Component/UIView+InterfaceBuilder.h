//
//  UIView+InterfaceBuilder.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 7. 11..
//  Copyright © 2018년 KBCard. All rights reserved.
//

@import UIKit;
@interface UIView (InterfaceBuilder)
@property (nonatomic, copy)   IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@end

IB_DESIGNABLE
@interface LMView : UIView
@property (nonatomic, assign) IBInspectable CGFloat rotationDegrees;
@end

IB_DESIGNABLE
@interface LMImageView : UIImageView
@property (nonatomic, assign) IBInspectable CGPoint stretchRatio;
@end

IB_DESIGNABLE
@interface LMButton : UIButton
@property (nonatomic, copy)   IBInspectable UIColor *backgroundColorImage;
@property (nonatomic, assign) IBInspectable CGPoint stretchRatio;
@end



