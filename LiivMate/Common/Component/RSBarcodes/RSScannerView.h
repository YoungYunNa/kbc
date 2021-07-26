//
//  RSScannerViewController.h
//  RSBarcodes
//
//  Created by R0CKSTAR on 12/19/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSCornersView,RSScannerView;

@protocol RSScannerQRCodeDelegate <NSObject>

@optional
- (void)qrCodeScanner:(RSScannerView*)scanner didScanResult:(NSString *)result;
- (void)barCodeScanner:(RSScannerView*)scanner didScanResult:(NSString *)result;

@end
typedef void (^RSBarcodesHandler)(NSArray *barcodeObjects);

typedef void (^RSTapGestureHandler)(CGPoint tapPoint);

@interface RSScannerView : UIView

@property (nonatomic, readonly) UIImageView *maskView;
@property (nonatomic, retain) NSArray *barcodeObjectTypes;
@property (nonatomic, retain) RSCornersView *highlightView;
@property (nonatomic, copy) RSBarcodesHandler barcodesHandler;
@property (nonatomic, copy) RSTapGestureHandler tapGestureHandler;
@property (nonatomic, assign) BOOL isCornersVisible;     // Default is YES
@property (nonatomic, assign) BOOL isBorderRectsVisible; // Default is NO
@property (nonatomic, assign) BOOL isFocusMarkVisible;   // Default is YES
@property (nonatomic, assign) BOOL isAutoStop;			// Default is YES
@property (nonatomic, readonly) UILabel *infoLabel;

@property (nonatomic, assign) BOOL checkQRcodeArea; //defult is NO;
@property (nonatomic, assign) CGRect qrScopeRect;		//CGRectMake(70, 75, 180, 180);
@property (nonatomic, assign) CGSize minQrSize;			//CGSizeMake(100, 100);
@property (nonatomic, unsafe_unretained) id delegate;

@property (nonatomic, assign, getter=isStartRunning) BOOL startRunning;
+(NSString*)decodeQRformImage:(UIImage*)image;
-(void)showImagePicker;
@end
