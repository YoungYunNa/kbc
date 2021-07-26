//
//  RSLicenseUtil.h
//  RSLicenseSDK
//  Copyright © 2018년 RAONSECURE All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSLicense.h"
#import "RSErrorCode.h"

@interface RSLicenseChecker : NSObject <NSURLSessionDelegate> {
    RSLicense *mRSLicenseData;
    RSLicenseInfo *mRSLicenseInfo;
    RSLicenseSchema *mRSLicenseSchema;
    RSFeature *mRSFreature;
}

+ (RSLicenseChecker *) sharedInstance;
- (int)checkLicenseFile:(NSString *)filePath;
- (BOOL)doubleCheckLicense;
- (void)requestLicense:(NSString *)serverUrl withSuccessBlock:(void (^)(int resultCode))aSuccessEvent errorBlock:(void (^)(int resultCode))aFailEvent;
- (RSLicense *)getRaonLicense;
- (NSString *)getSdkVersion;
- (void)setFLAG:(BOOL)aFlag;
@end
