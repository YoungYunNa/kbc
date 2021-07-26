//
//  TranskeyResult.h
//  mTrankeyDemo_xib
//
//  Created by lion on 13. 5. 27..
//  Copyright (c) 2013년 lumensoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TranskeyResult : NSObject

@property (nonatomic, assign) NSData *secureKey;
@property (nonatomic, assign) NSString *cipherData;
@property (nonatomic, assign) NSString *cipherDataEx;
@property (nonatomic, assign) NSString *cipherDataExWithPadding;

@end
