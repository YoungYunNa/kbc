//
//  WizveraCertificate.h
//  DelfinoMobileLib
//
//  Created by brson on 2017. 4. 13..
//  Copyright © 2017년 wizvera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizveraCertificate : NSObject
+ (WizveraCertificate*)certificateWithData:(NSData*)data;
- (NSString*)getSubject;
- (NSString*)getSubjectValue:(NSString*)type;
- (NSArray<NSString*>*)getSubjectValues:(NSString*)type;
- (NSString*)getIssuer;
- (NSString*)getIssuerValue:(NSString*)type;
- (NSArray<NSString*>*)getIssuerValues:(NSString*)type;
- (NSString*)getPolicyOID;
- (NSArray<NSString*>*)getPolicyOIDs;
- (NSString*)getSerialNumber;
- (NSDate*) getNotAfter;
- (NSDate*)getNotBefore;

@end
