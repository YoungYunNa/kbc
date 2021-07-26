//
//  InsertManager.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 3. 30..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#ifndef InsertManager_h
#define InsertManager_h


#endif /* InsertManager_h */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface InsertManager : NSObject

+(instancetype) sharedManager;

-(void) startManager;
-(void) stopManager;

-(void) showMessageInViewController:(UIViewController *)viewController;

-(BOOL) isManagerRunning;

@end