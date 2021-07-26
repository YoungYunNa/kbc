//
//  IssacKeychainHandler.h
//  Swap
//
//  Created by Subi Lee on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

enum
{
    BG_ERR_KEYCHAIN_FULL = -50000
};

#import <Foundation/Foundation.h>
#import "CertItem.h"

@interface IssacKeychainHandler : NSObject {
}

-(id) initWithAccessGroup:(NSString *)accessGroup;
-(id) initWithAccessGroup:(NSString *)accessGroup capacity:(int) capacity;

/// @brief 저장된 인증서를 가져온다.
/// @return noErr(성공), 그 외(오류).
-(OSStatus) loadCertItem:(CertItem *) certItem
             certificate:(CERTIFICATE *) cert
              privateKey:(PRIVATEKEY *) privKey
                     pin:(NSString *) pin;

/// @brief 인증서를 저장한다.
/// @return noErr(성공), 그 외(오류).
-(OSStatus) saveCertItem:(CertItem *) certItem
             certificate:(CERTIFICATE *) cert
              privateKey:(PRIVATEKEY *) privKey
                     pin:(NSString *) pin;

/// @brief 인증서를 저장한다. (암호화된 개인키)
/// @return noErr(성공), 그 외(오류).
-(OSStatus) saveCertItem:(CertItem *) certItem
             certificate:(CERTIFICATE *)cert
                    epki:(EPRIVATEKEY *)epki;

/// @brief 인증서를 삭제한다.
/// @return noErr(성공), 그 외(오류).
-(OSStatus) deleteCertItem:(CertItem *) certItem;

/// @brief 인증서 리스트를 가져온다.
/// @return 0(성공). 현재는 성공만 리턴함.
-(int) getCertificateList:(NSMutableArray *) certList;

@end
