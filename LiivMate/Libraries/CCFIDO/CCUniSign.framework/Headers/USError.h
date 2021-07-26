//
//  USError.h
//  UniSign
//
//  Created by gychoi on 13. 6. 7..
//  Copyright 2013 Crosscert. All rights reserved.
//

#import <Foundation/Foundation.h>

extern	NSString *const USErrorDomain;

extern  NSString *const USToolkitErrorDomain;
extern  NSString *const USToolkitCMSErrorDomain;
extern  NSString *const USToolkitCertPathValidateErrorDomain;
extern  NSString *const USToolkitCryptoErrorDomain;
extern  NSString *const USToolkitCryptoKeyErrorDomain;
extern  NSString *const USToolkitInitializeErrorDomain;
extern  NSString *const USToolkitMalformedDataErrorDomain;
extern  NSString *const USToolkitNoSuchAlgorithmErrorDomain;
extern  NSString *const USToolkitNoSuchPaddingTypeErrorDomain;
extern  NSString *const USToolkitPKCSErrorDomain;
extern  NSString *const USToolkitNoHashData;


extern  NSString *const USTransferErrorDomain;
extern  NSString *const USXMLSignErrorDomain;

extern  NSString *const USErrorMessage;


#define kUSErrorSuccess     @"0"
#define kUSErrorFail        @"-1"

@interface USError : NSError {
}

+ (id) errorWithDomain:(NSString *)domain code:(NSInteger)code errorMessage:(NSString *)message;
+ (NSString *) codeToMessage:(NSInteger)code;

@end
