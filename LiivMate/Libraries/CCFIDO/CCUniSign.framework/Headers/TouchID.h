//
//  TouchID.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 8. 5..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#ifndef TouchID_h
#define TouchID_h


#endif /* TouchID_h */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TouchID : UIViewController

@property (nonatomic, copy) void (^touchIDResult)(NSString *response);

@property (nonatomic, strong) NSString *tcContent;

-(void)finishViewControll;

-(void)showOwerCodeInput;

@end
