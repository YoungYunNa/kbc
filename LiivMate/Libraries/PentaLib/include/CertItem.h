//
//  certItem.h
//  Swap
//
//  Created by Subi Lee on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import "_Issacwebapi.h"
#import "Issacweb_static.h"

@interface CertItem : NSObject {
    NSInteger _pk;
    NSString *_identifier;      ///< ID
    
    NSString *_strSubjectDN;    ///< 소유자 DN
    NSString *_strIssuerDN;     ///< 발급자 DN
    NSString *_strSerial;       ///< 시리얼 번호
    NSString *_strIssueDate;    ///< 발급일
    NSString *_strExpireDate;   ///< 만료일
}

/// @brief 입력받은 인증서로 초기화
-(id) initWithCertificate:(CERTIFICATE *) cert;

/// @brief 입력받은 인증서와 ID로 초기화
-(id) initWithIdentifier:(NSString *) identifier
             certificate:(CERTIFICATE *) cert;

@property NSInteger pk;

@property (retain, nonatomic) NSString *identifier;

@property (retain, nonatomic) NSString *strSubjectDN;
@property (retain, nonatomic) NSString *strIssuerDN;
@property (retain, nonatomic) NSString *strSerial;
@property (retain, nonatomic) NSString *strIssueDate;
@property (retain, nonatomic) NSString *strExpireDate;

@end