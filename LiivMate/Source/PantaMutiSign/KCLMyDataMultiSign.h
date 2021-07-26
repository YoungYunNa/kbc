//
//  KCLMyDataMultiSign.h
//  LiivMate
//
//  Created by KB on 2021/06/15.
//  Copyright © 2021 KBCard. All rights reserved.
//

#ifndef KCLMyDataMultiSign_h
#define KCLMyDataMultiSign_h

#import <wasdk/IssacCERTIFICATE.h>
#import <wasdk/IssacPRIVATEKEY.h>

@interface KCLMyDataMultiSign : NSObject {
    IssacCERTIFICATE *signerCert; //
    IssacPRIVATEKEY *signerPriKey;
}

-(id)initWithSignerCert:(IssacCERTIFICATE *)signerCert
           signerPriKey:(IssacPRIVATEKEY *)signerPriKey;

-(NSData *)genResponse:(NSString *)caOrg
           requestData:(NSData *)requestData;

@end

#endif /* KCLMyDataMultiSign_h */
