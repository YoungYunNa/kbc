//
//  TranskeyParam.h
//  mTrankeyDemo_xib
//
//  Created by lion on 13. 5. 24..
//  Copyright (c) 2013년 lumensoft. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    MultiFinishBtnOption,
    MultiContinueBtnOption
};

@interface TranskeyParam : NSObject

@property (nonatomic, assign) NSInteger keypadType;
@property (nonatomic, assign) NSInteger inputType;
@property (nonatomic, assign) NSInteger cryptType;
@property (nonatomic, assign) NSInteger mt_maxLength;
@property (nonatomic, assign) NSInteger mt_minLength;

@property (nonatomic, retain) NSString *inputTitle;
@property (nonatomic, retain) NSString *maxMessage;
@property (nonatomic, retain) NSString *minMessage;

@property (nonatomic, retain) NSString *inputEditBoxHint;
@property (nonatomic, retain) UIFont *inputEditBoxFont;
@property (nonatomic, assign) NSTextAlignment hintAlignment;

@property (nonatomic, retain) NSString *specialKeyMessage;

@property (nonatomic, assign) NSInteger cancelBtnOption;
@property (nonatomic, assign) NSInteger completeBtnOption;

@property (nonatomic, retain) UIColor   *navibarBackgroundColor;
@property (nonatomic, retain) NSString  *navibarBackgroundImageName;

@property (nonatomic, assign) BOOL upper;

@end
