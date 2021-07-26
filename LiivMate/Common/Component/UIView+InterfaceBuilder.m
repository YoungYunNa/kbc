//
//  UIView+InterfaceBuilder.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 7. 11..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "UIView+InterfaceBuilder.h"
#import "EtcUtil.h"

//IB_DESIGNABLE
@implementation UIView (InterfaceBuilder)

-(void)setBorderColor:(UIColor *)borderColor
{
	self.layer.borderColor = borderColor.CGColor;
}

-(UIColor*)borderColor
{
	return [UIColor colorWithCGColor:self.layer.borderColor];
}

-(void)setBorderWidth:(CGFloat)borderWidth
{
	self.layer.borderWidth = borderWidth;
}

-(CGFloat)borderWidth
{
	return self.layer.borderWidth;
}

-(void)setCornerRadius:(CGFloat)cornerRadius
{
	self.layer.cornerRadius = cornerRadius;
}

-(CGFloat)cornerRadius
{
	return self.layer.cornerRadius;
}

@end

@implementation LMView
-(void)setRotationDegrees:(CGFloat)rotationDegrees
{
	_rotationDegrees = rotationDegrees;
	self.transform = CGAffineTransformMakeRotation((_rotationDegrees * M_PI/180));
}
@end
@implementation LMImageView
-(void)setStretchRatio:(CGPoint)stretchRatio
{
	_stretchRatio = stretchRatio;
	if(self.image)
	{
		CGSize imageSize = self.image.size;
		[super setImage:[self.image stretchableImageWithLeftCapWidth:imageSize.width*_stretchRatio.x topCapHeight:imageSize.height*_stretchRatio.y]];
	}
}

-(void)setImage:(UIImage *)image
{
	if(!CGPointEqualToPoint(_stretchRatio, CGPointZero) && image)
	{
		CGSize imageSize = image.size;
		image = [image stretchableImageWithLeftCapWidth:imageSize.width*_stretchRatio.x topCapHeight:imageSize.height*_stretchRatio.y];
	}
	
	[super setImage:image];
}
@end
@implementation LMButton
-(void)setStretchRatio:(CGPoint)stretchRatio
{
	_stretchRatio = stretchRatio;
	UIImage *image = [self backgroundImageForState:(UIControlStateNormal)];
	if(image)
	{
		CGSize imageSize = image.size;
		image = [image stretchableImageWithLeftCapWidth:imageSize.width*_stretchRatio.x topCapHeight:imageSize.height*_stretchRatio.y];
		[super setBackgroundImage:image forState:(UIControlStateNormal)];
	}
}

-(void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
	if(!CGPointEqualToPoint(_stretchRatio, CGPointZero) && image && state == UIControlStateNormal)
	{
		CGSize imageSize = image.size;
		image = [image stretchableImageWithLeftCapWidth:imageSize.width*_stretchRatio.x topCapHeight:imageSize.height*_stretchRatio.y];
	}
	[super setBackgroundImage:image forState:state];
}

-(void)setBackgroundColorImage:(UIColor *)backgroundColorImage
{
	_backgroundColorImage = backgroundColorImage;
	[super setBackgroundImage:[EtcUtil imageWithColor:_backgroundColorImage] forState:UIControlStateNormal];
}
@end


