//
//  CrashController.h
//  CrashKit
//
//  Created by Oh seung yong on 13. 10. 18..
//  Copyright (c) 2013년 Lilac Studio. All rights reserved.
//

#ifdef DEBUG
#import <Foundation/Foundation.h>
@interface CrashController : NSObject 
+(void)start;
@end
#endif