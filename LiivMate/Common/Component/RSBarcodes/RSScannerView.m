//
//  RSScannerViewController.m
//  RSBarcodes
//
//  Created by R0CKSTAR on 12/19/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSScannerView.h"

#import "RSCornersView.h"

#import <AVFoundation/AVFoundation.h>

@interface RSScannerView () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession           *_session;
    AVCaptureDevice            *_device;
    AVCaptureDeviceInput       *_input;
    AVCaptureVideoPreviewLayer *_layer;
    AVCaptureMetadataOutput    *_output;
    BOOL _isStart;
    UIView *_scanBar;
	
	UIView *_cameraView;
}
@end

@implementation RSScannerView
@synthesize barcodeObjectTypes = _barcodeObjectTypes;
@synthesize barcodesHandler = _barcodesHandler;
@synthesize tapGestureHandler = _tapGestureHandler;
@synthesize highlightView = _highlightView;
@synthesize delegate = _delegate;
@synthesize isAutoStop = _isAutoStop;
@synthesize qrScopeRect = _qrScopeRect;
@synthesize minQrSize = _minQrSize;

#pragma mark - Private

- (void)__applicationWillEnterForeground:(NSNotification *)notification
{
    if(_startRunning)
        [self __startRunning];
}

- (void)__applicationDidEnterBackground:(NSNotification *)notification
{
    [self __stopRunning];
}

- (void)__handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
	if(_startRunning)
		[self __startRunning];
	
    CGPoint tapPoint = [tapGestureRecognizer locationInView:self];
    CGPoint focusPoint= CGPointMake(tapPoint.x / self.bounds.size.width, tapPoint.y / self.bounds.size.height);
    
    if (!_device
        && ![_device isFocusPointOfInterestSupported]
        && ![_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        return;
    } else if ([_device lockForConfiguration:nil]) {
        [_device setFocusPointOfInterest:focusPoint];
        [_device setFocusMode:AVCaptureFocusModeAutoFocus];
        [_device unlockForConfiguration];
        
        if (self.isFocusMarkVisible) {
            self.highlightView.focusPoint = tapPoint;
        }
        
        if (self.tapGestureHandler) {
            self.tapGestureHandler(tapPoint);
        }
    }
}

- (void)__setup
{
	_cameraView = [[UIView alloc] initWithFrame:self.bounds];
	_cameraView.backgroundColor = [UIColor blackColor];
	_cameraView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	[self insertSubview:_cameraView atIndex:0];
	
    self.isCornersVisible = YES;
    self.isBorderRectsVisible = NO;
    self.isFocusMarkVisible = YES;
    self.isAutoStop = YES;
    _minQrSize = CGSizeMake(80, 80);
    _highlightView = [[RSCornersView alloc] initWithFrame:self.bounds];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_cameraView addSubview:_highlightView];
	
    if (_session) {
        return;
    }
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_device) {
        NSLog(@"No video camera on this device!");
        return;
    }
    
    _session = [[AVCaptureSession alloc] init];
    NSError *error = nil;
    _input = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    if ([_session canAddInput:_input])
    {
        [_session addInput:_input];
    }
    
    _layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _layer.frame = _cameraView.bounds;
    [_cameraView.layer addSublayer:_layer];
	
    _output = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("com.pdq.RSBarcodes.metadata", 0);
    [_output setMetadataObjectsDelegate:self queue:queue];
    if ([_session canAddOutput:_output])
    {
        [_session addOutput:_output];
        if (!self.barcodeObjectTypes)
        {
            NSMutableArray *codeObjectTypes = [NSMutableArray arrayWithArray:_output.availableMetadataObjectTypes];
            [codeObjectTypes removeObject:AVMetadataObjectTypeFace];
            self.barcodeObjectTypes = [NSArray arrayWithArray:codeObjectTypes];
        }
        _output.metadataObjectTypes = self.barcodeObjectTypes;
    }
    
    [_cameraView bringSubviewToFront:self.highlightView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleTapGesture:)];
    [_cameraView addGestureRecognizer:tapGestureRecognizer];
	
	UIImage *maskImage = [UIImage imageNamed:@"img_qr_scan.png"];
	maskImage = [maskImage stretchableImageWithLeftCapWidth:maskImage.size.width/2 topCapHeight:maskImage.size.height - 10];
	_maskView = [[UIImageView alloc] initWithImage:maskImage];
	_maskView.frame = self.bounds;
	[self addSubview:_maskView];
	
	_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 340, CGRectGetWidth(_maskView.frame), 40)];
	_infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_infoLabel.textColor = UIColorFromRGB(0xffffff);
	_infoLabel.font = FONTSIZE(14);
	_infoLabel.backgroundColor = CLEARCOLOR;
	_infoLabel.numberOfLines = 2;
	_infoLabel.textAlignment = NSTextAlignmentCenter;
	_infoLabel.text = @"인식하고자 하는 QR코드를 해당 영역에\n맞춰주세요";
	[_maskView addSubview:_infoLabel];
	
//	if(CGRectGetWidth([UIScreen mainScreen].bounds) != 320)
	{
		_scanBar = [[UIView alloc] initWithFrame:CGRectZero];
		_scanBar.backgroundColor = UIColorFromRGBWithAlpha(0xfdbd47, 0.8);
		[self addSubview:_scanBar];
	}
	self.checkQRcodeArea = YES;
#ifdef DEBUG
	UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
	[button addTarget:self action:@selector(showImagePicker) forControlEvents:(UIControlEventTouchUpInside)];
	button.frame = CGRectMake(CGRectGetMidX(self.bounds)-25, 0, 50, 50);
	button.isAccessibilityElement = NO;
	[self addSubview:button];
#endif
}

-(void)dealloc
{
    _delegate = nil;
    [self __stopRunning];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self __setup];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [self __setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self __setup];
    }
    return self;
}

-(void)setStartRunning:(BOOL)startRunning
{
    _startRunning = startRunning;
    
    if(_startRunning)
        [self __startRunning];
    else
        [self __stopRunning];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _layer.frame = self.bounds;
	CGFloat width = MAX(CGRectGetWidth(self.bounds), 375);
	_maskView.frame = CGRectMake((CGRectGetWidth(self.bounds))/2-width/2,
								 0, width,
								 MAX(CGRectGetHeight(self.bounds), _maskView.image.size.height));
	
	if(_maskView.hidden == NO)
	{
		CGRect qrScopeRect = CGRectMake(80+CGRectGetMinX(_maskView.frame), 100, 214, 210);
		if(width > 375)
			qrScopeRect.size.width = CGRectGetWidth(qrScopeRect) + (width-375);
		_qrScopeRect = qrScopeRect;
	}
	
    if(!_startRunning && _scanBar)
    {
        [_scanBar.layer removeAllAnimations];
        _scanBar.frame = CGRectMake(CGRectGetMinX(_qrScopeRect), CGRectGetMidY(_qrScopeRect), CGRectGetWidth(_qrScopeRect), 2);
    }
}

-(void)scanBarAni
{
    if(!_startRunning || _scanBar == nil) return;
    CGFloat duration = 1;
    CGRect rect = _scanBar.frame;
    BOOL isDown = CGRectGetMidY(_qrScopeRect) > CGRectGetMinY(rect);
    CGFloat length = fabs(CGRectGetMinY(rect) - CGRectGetMinY(_qrScopeRect));
    rect.origin.y = isDown ? CGRectGetMaxY(_qrScopeRect) : CGRectGetMinY(_qrScopeRect);
    if(length != 0.0)
        duration = duration * (length / CGRectGetHeight(_qrScopeRect));
    [UIView animateWithDuration:duration animations:^{
        self->_scanBar.frame = rect;
    } completion:^(BOOL finished) {
        if(finished)
            [self scanBarAni];
    }];
}

-(void)__startRunning
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    if (_session.isRunning) {
        return;
    }
    
    self.highlightView.cornersArray = nil;
    [_session startRunning];
    [self scanBarAni];
}

- (void)__stopRunning
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    if (!_session.isRunning)
    {
        return;
    }
    
    [_session stopRunning];
    [self setNeedsLayout];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

+(NSString *)decodeQRformImage:(UIImage *)image
{
    CIImage *img = [[CIImage alloc]initWithImage:image];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    if (detector)
    {
        NSArray* featuresR = [detector featuresInImage:img];
        for (CIQRCodeFeature* featureR in featuresR)
        {
            NSLog(@"decode QR image : %@",featureR.messageString);
            return featureR.messageString;
        }
    }
    return nil;
}

static bool isChecking = NO;

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isChecking == YES) return;
        if (!self->_session.isRunning)
        {
            return;
        }
        
        isChecking = YES;
        
        NSMutableArray *barcodeObjects  = nil;
        NSMutableArray *cornersArray    = nil;
        NSMutableArray *borderRectArray = nil;
        
        for (AVMetadataObject *metadataObject in metadataObjects)
        {
            AVMetadataObject *transformedMetadataObject = [self->_layer transformedMetadataObjectForMetadataObject:metadataObject];
            if ([transformedMetadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
            {
                AVMetadataMachineReadableCodeObject *barcodeObject = (AVMetadataMachineReadableCodeObject *)transformedMetadataObject;
                if (!barcodeObjects)
                {
                    barcodeObjects = [NSMutableArray array];
                }
                [barcodeObjects addObject:barcodeObject];
                
                if (self.isCornersVisible) {
                    if ([barcodeObject respondsToSelector:@selector(corners)])
                    {
                        if (!cornersArray)
                        {
                            cornersArray = [NSMutableArray array];
                        }
                        [cornersArray addObject:barcodeObject.corners];
                    }
                }
                
                if (self.isBorderRectsVisible)
                {
                    if ([barcodeObject respondsToSelector:@selector(bounds)])
                    {
                        if (!borderRectArray)
                        {
                            borderRectArray = [NSMutableArray array];
                        }
                        [borderRectArray addObject:[NSValue valueWithCGRect:barcodeObject.bounds]];
                    }
                }
            }
        }
        
        
        if (self.isCornersVisible)
        {
            self.highlightView.cornersArray = cornersArray ? [NSArray arrayWithArray:cornersArray] : nil;

            if(self->_checkQRcodeArea && cornersArray)
            {
                CGFloat minX, minY, maxY, maxX;
                maxY = maxX = CGFLOAT_MIN;
                minY = minX = CGFLOAT_MAX;

                for (NSArray *corners in cornersArray) {
                    for (NSDictionary *corner in corners) {
                        CGPoint point = CGPointMake([[corner objectForKey:@"X"] floatValue], [[corner objectForKey:@"Y"] floatValue]);
                        if(CGRectContainsPoint(self->_qrScopeRect, point) == NO)
                        {
                            isChecking = NO;
                            break;
                        }

                        maxY = MAX(point.y, maxY);
                        maxX = MAX(point.x, maxX);
                        minY = MIN(point.y, minY);
                        minX = MIN(point.x, minX);
                    }
                }

                CGRect qrRect = CGRectMake(minX, minY, maxX-minX, maxY-minY);
                if((self->_minQrSize.width <= qrRect.size.width && self->_minQrSize.height <= qrRect.size.height) == NO)
                {
                    isChecking = NO;
                }
            }
        }
        
        if (self.isBorderRectsVisible)
        {
            self.highlightView.borderRectArray = borderRectArray ? [NSArray arrayWithArray:borderRectArray] : nil;
        }
        
        if (self->_barcodesHandler)
        {
            self->_barcodesHandler([NSArray arrayWithArray:barcodeObjects]);
        }
        
        if(barcodeObjects.count && self.delegate)
        {
            for(AVMetadataMachineReadableCodeObject *obj in barcodeObjects)
            {
                if([obj isKindOfClass:[AVMetadataObject class]])
                {
                    if([[obj type] isEqualToString:AVMetadataObjectTypeQRCode])
                    {//QR코드
                        if([self.delegate respondsToSelector:@selector(qrCodeScanner:didScanResult:)] && isChecking)
                            [self.delegate qrCodeScanner:self didScanResult:[obj stringValue]];
                        break;
                    }
                    else
                    {//바코드
                        if([self.delegate respondsToSelector:@selector(barCodeScanner:didScanResult:)])
                            [self.delegate barCodeScanner:self didScanResult:[obj stringValue]];
                        break;
                    }
                }
            }
        }
        
        isChecking = NO;
    });
}

#pragma mark - UIImagePickerController

-(void)showImagePicker
{
	self.startRunning = NO;
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.delegate = (id)self;
	imagePicker.allowsEditing = NO;
	imagePicker.modalPresentationStyle = UIModalPresentationCustom;
	[self.parentViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *choiceImage = info[UIImagePickerControllerEditedImage];
	if( choiceImage == nil )
	{
		choiceImage = info[UIImagePickerControllerOriginalImage];
	}
	[picker dismissViewControllerAnimated:YES completion:^{
		NSString *result = [[self class] decodeQRformImage:choiceImage];
		if([self.delegate respondsToSelector:@selector(qrCodeScanner:didScanResult:)] && result.length)
			[self.delegate qrCodeScanner:self didScanResult:result];
		else
			self.startRunning = YES;
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:^{
		self.startRunning = YES;
	}];
}

@end
