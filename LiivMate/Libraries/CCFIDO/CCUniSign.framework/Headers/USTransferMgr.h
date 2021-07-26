//
//  USTransferMgr.h
//  UniSignLibrary
//
//  Created by 근영 최 on 13. 6. 19..
//
//

#import <Foundation/Foundation.h>

#import "OBJCCertTransfer.h"

@interface USTransferMgr : OBJCCertTransfer

+ (void) setLicense:(NSString *)license;
+ (id) getInstance:(USTransVersion)version error:(USError **)error;

- (id) init:(USTransVersion)version
      appID:(NSString *)appID
     appKey:(NSString *)appKey
       type:(USTransUserType)type
      error:(USError **)error;

- (BOOL) TRANS_Exportcert:(USCertificate *)cert error:(USError **)error;
- (BOOL) TRANS_V2_Exportcert:(USCertificate *)cert error:(USError **)error;
+ (NSString *) TRANS_V2_GetAuthnumFromURI:(NSString *)uri;

@end
