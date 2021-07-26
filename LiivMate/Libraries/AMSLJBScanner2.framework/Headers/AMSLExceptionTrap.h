//
//  AMSLExceptionTrap.h
//
//  Copyright © 2018 AhnLab, Inc. All rights reserved.
//

#ifndef AMSLExceptionTrap_h
#define AMSLExceptionTrap_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface __AMSLExceptionTrap : NSObject 

+ (void)tryBlock:(void (^)(void))tryBlock
      catchBlock:(void (^)(id))catchBlock
    finallyBlock:(void (^)(void))finallyBlock;

@end

NS_ASSUME_NONNULL_END

#endif /* AMSLExceptionTrap_h */
