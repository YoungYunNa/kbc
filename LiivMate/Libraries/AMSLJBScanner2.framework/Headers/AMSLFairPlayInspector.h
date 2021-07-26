//
//  AMSLFairPlayInspector.h
//
//  Copyright © 2018 AhnLab, Inc. All rights reserved.
//

#ifndef __AMSL_Fair_Play_Inspector_H__
#define __AMSL_Fair_Play_Inspector_H__

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    #error "AMSLJBScanner2's minimum iOS version is 8.0"
#endif

#if TARGET_OS_SIMULATOR
    #error "AMSLJBScanner2 does NOT SUPPORT iOS Simulator."
#endif

NS_ASSUME_NONNULL_BEGIN

// MARK: AMSLFairPlayInspectorError
@interface AMSLFairPlayInspectorError : NSError

@end

FOUNDATION_EXTERN NSInteger const kAMSFPJailbroken;
FOUNDATION_EXTERN NSInteger const kAMSFPWrongSecret;
FOUNDATION_EXTERN NSInteger const kAMSFPWrongCallSequence;

FOUNDATION_EXTERN NSString* const kAMSFPUserInfoKeyCode;
FOUNDATION_EXTERN NSString* const kAMSFPUserInfoKeyReason;
FOUNDATION_EXTERN NSString* const kAMSFPUserInfoKeyCallstack;


// MARK: AMSLFairPlayInspector
@interface AMSLFairPlayInspector : NSObject

+ (instancetype)fairPlayInspector NS_SWIFT_UNAVAILABLE("");
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (nullable NSData *)responseForChallenge:(NSData *)challenge;
- (NSData *)fairPlayWithResponseAck:(NSData *)responseAck;
+ (NSData *)hmacWithSierraEchoCharlieRomeoEchoTango:(NSUUID *)secret
                                            andData:(NSData *)data;
+ (nullable NSDictionary*)unarchive:(NSData*)data;

@end

FOUNDATION_EXTERN NSString* const kAMSFPKeyConfirm;
FOUNDATION_EXTERN NSString* const kAMSFPKeyConfirmValidation;


NS_ASSUME_NONNULL_END

#endif // __AMLS_Fair_Play_Inspector_H__
