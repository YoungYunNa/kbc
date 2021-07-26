//
//  IssacPFX.h
//  wasdk
//
//  Created by 하지윤 on 2021/06/08.
//

#ifndef IssacPFX_h
#define IssacPFX_h

#include <wasdk/IssacCERTIFICATE.h>
#include <wasdk/IssacCERTIFICATES.h>
#include <wasdk/IssacPRIVATEKEY.h>


@interface IssacPFX : NSObject {
}

/// PFX를 읽어들인다. (PKCS#12)
/// @param data PFX
/// @param pin PFX 비밀번호
-(int)readData:(NSData *)data
           pin:(NSString *)pin;

-(NSArray *)getLocalKeyIDs;

/// localKeyID 에 해당하는 인증서를 가져온다.
/// @param localKeyID 키쌍 구분을 위한 ID
-(IssacCERTIFICATE *)getCertificate:(NSData *)localKeyID;

/// localKeyID 에 해당하는 개인키를 가져온다.
/// @param localKeyID 키쌍 구분을 위한 ID
/// @param password 개인키 비밀번호 (암호화되지 않았다면 nil)
-(IssacPRIVATEKEY *)getPrivateKey:(NSData *)localKeyID
                         password:(NSString *)password;

-(IssacCERTIFICATES *)getOtherCertificates;

@end

#endif /* IssacPFX_h */
