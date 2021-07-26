//
//  IssueInfo.h
//  FidoFrameWork
//
//  Created by jwchoi on 2017. 12. 26..
//  Copyright © 2017년 jwchoi. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CCJSONModel.h"


@interface IssueInfo : CCJSONModel

@property (strong, nonatomic) NSString *response;
@property (strong, nonatomic) NSString *message;

@end


