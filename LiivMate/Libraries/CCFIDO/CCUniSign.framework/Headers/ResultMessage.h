//
//  ResultMessage.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 5. 9..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#ifndef ResultMessage_h
#define ResultMessage_h


#endif /* ResultMessage_h */
#import <Foundation/Foundation.h>
#import "ConstantData.h"


@interface ResultMessage :NSObject  

@property (nonatomic) BOOL result;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) int errorCode;
@property (nonatomic) FidoOPType operationType;
@property (nonatomic, strong) NSString *p7Data;
@property (nonatomic, strong) NSString *errorMessage;


@end
