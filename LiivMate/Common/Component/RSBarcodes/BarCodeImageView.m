//
//  BarCodeImageView.m
//  NewKBCardShop
//
//  Created by SeungYong Oh on 13. 2. 22..
//
//

#import "BarCodeImageView.h"
#import "RSUnifiedCodeGenerator.h"

@implementation BarCodeImageView
@synthesize codeStr = _codeStr;

-(void)dealloc
{
	
}

- (void)paste:(id)sender
{
	[[UIPasteboard generalPasteboard] setImage:self.code];
}

-(void)setCodeStr:(NSString *)codeStr
{
    codeStr = codeStr == nil || [codeStr isEqual:[NSNull null]] ? @"" : codeStr;
	[self setIsAccessibilityElement:YES];
	if(_isQRType)
	{
		if (codeStr.length == 0)
		{
			self.code = nil;
			return;
		}
		
		_codeStr = codeStr;
		self.code = [[RSUnifiedCodeGenerator codeGen] genCodeWithContents:codeStr machineReadableCodeObjectType:AVMetadataObjectTypeQRCode];
		[self setAccessibilityLabel:[NSString stringWithFormat:@"큐알코드이미지"]];
	}
	else
	{
		NSLog(@"OB_BARCODE_TYPE = [org.iso.Code128], code = [%@]", codeStr);
		if ([codeStr length] > 0)
		{
			codeStr = [codeStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
			codeStr = [codeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
		}
		if (codeStr.length == 0)
		{
			self.code = nil;
			return;
		}
		
		_codeStr = codeStr;
		self.code = [[RSUnifiedCodeGenerator codeGen] genCodeWithContents:codeStr machineReadableCodeObjectType:AVMetadataObjectTypeCode128Code];
		[self setAccessibilityLabel:[NSString stringWithFormat:@"바코드이미지 %@",codeStr]];
	}
}


@end

@implementation BarCodeButton
@synthesize codeStr = _codeStr;

-(void)dealloc
{
	
}

- (void)paste:(id)sender
{
	[[UIPasteboard generalPasteboard] setImage:[self imageForState:(UIControlStateNormal)]];
}

-(void)setCodeStr:(NSString *)codeStr
{
	codeStr = codeStr == nil || [codeStr isEqual:[NSNull null]] ? @"" : codeStr;
	[self setIsAccessibilityElement:YES];
	
	if(_isQRType)
	{
		if (codeStr.length == 0)
		{
			[self setBackgroundImage:nil forState:(UIControlStateNormal)];
			return;
		}
		_codeStr = codeStr;
		UIImage *image = [[RSUnifiedCodeGenerator codeGen] genCodeWithContents:codeStr machineReadableCodeObjectType:AVMetadataObjectTypeQRCode];
		[self setBackgroundImage:image forState:(UIControlStateNormal)];
		[self setAccessibilityLabel:[NSString stringWithFormat:@"큐알코드"]];
	}
	else
	{
		NSLog(@"OB_BARCODE_TYPE = [org.iso.Code128], code = [%@]", codeStr);
		if ([codeStr length] > 0)
		{
			codeStr = [codeStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
			codeStr = [codeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
		}
		if (codeStr.length == 0)
		{
			[self setBackgroundImage:nil forState:(UIControlStateNormal)];
			return;
		}
		_codeStr = codeStr;
		UIImage *image = [[RSUnifiedCodeGenerator codeGen] genCodeWithContents:codeStr machineReadableCodeObjectType:AVMetadataObjectTypeCode128Code];
		[self setBackgroundImage:image forState:(UIControlStateNormal)];
		[self setAccessibilityLabel:[NSString stringWithFormat:@"바코드 %@",codeStr]];
	}
}


@end
