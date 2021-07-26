//
//  USListMgr.h
//  UniSignLibrary
//
//  Created by 근영 최 on 13. 8. 7..
//
//

#import <Foundation/Foundation.h>

#import "USCertificate.h"

@interface USListMgr : NSObject

+ (NSArray *) certificatesWithOwner:(USCertificateOwner)owner;
+ (NSArray *) certificatesWithType:(USCertificateType)type subjectDN:(NSString *)dn;
+ (NSArray *) CACertificates:(USCertificateCA)type;
+ (NSArray *) RootCACertificates;
+ (NSArray *) UserCertificates;
+ (NSArray *) AllCertificates;
+ (void) initCAandRootCACertificate;

+ (BOOL) add:(USCertificate *)cert subjectDN:(NSString *)dn;
+ (BOOL) remove:(USCertificate *)cert subjectDN:(NSString *)dn;
+ (BOOL) clear;

+ (NSDate *) prikeyLastModified:(USCertificate *)cert;

@end

@interface USListMgr (UniSign)

- (id) init:(id)toolkit;
+ (USCertificate *) certificateFromKeyChainItem:(NSDictionary *)item;

@end
