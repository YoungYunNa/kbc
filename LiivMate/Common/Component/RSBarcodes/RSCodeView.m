//
//  RSCodeView.m
//  RSBarcodes
//
//  Created by R0CKSTAR on 12/25/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSCodeView.h"

@implementation RSCodeView
@synthesize code = _code;
@synthesize contents = _contents;

- (void)__init
{
    self.backgroundColor = [UIColor clearColor];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self __init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __init];
    }
    return self;
}

-(void)dealloc
{
	
}

- (void)setCode:(UIImage *)code
{
    _code = code;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)drawRect:(CGRect)rect
{
    if (!_code) {
        return;
    }
    [self.code drawInRect:UIEdgeInsetsInsetRect(self.bounds, _imageInsets)];
}

@end
