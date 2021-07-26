//
//  USCertificate.h
//  UniSignLibrary
//
//  Created by 근영 최 on 13. 6. 18..
//
//

#import <Foundation/Foundation.h>

#define kUSCertificateNumberOfTypes 4

typedef enum _USCertificateType {
    kUSSignCert     = 0x11,
    kUSSignPrikey   = 0x12,
    kUSKMCert       = 0x21,
    kUSKMPrikey     = 0x22,
    kUSUnknownType      = 0xFF
} USCertificateType;

typedef enum _USCertificateOwner {
    kUSUser         = 0x0100,
    kUSCA           = 0x0200,
    kUSRoot         = 0x0300,
    kUSUnknownOwner = 0x0F00
} USCertificateOwner;

typedef enum _USCertificateCA {
    kUSCrossCert    = 0x01,
    kUSYesSign      = 0x02,
    kUSSignKorea    = 0x04,
    kUSTradeSign    = 0x08,
    kUSINIPASS      = 0x09,
    kUSKICA         = 0x10,
    kUSNCASign      = 0x20,

    kUSALL          = 0xFF
} USCertificateCA;

typedef enum _USCertificateSource {
    kUSKeyChain     = 0x10,
    kUSKTShow       = 0x20,
    kUSTransfer     = 0x30,
    kUSFileSystem   = 0x40,
    kUSUnknownSource      = 0xFF
} USCertificateSource;

typedef enum _US_CERT_TYPE {
	US_CERT_TYPE_ROOT               = 0x10,
	US_CERT_TYPE_CA_CROSSCERT       = 0x21,
	US_CERT_TYPE_CA_YESSIGN         = 0x22,
	US_CERT_TYPE_CA_KICA            = 0x23,
	US_CERT_TYPE_CA_SIGNKOREA       = 0x24,
	US_CERT_TYPE_CA_TRADESIGN       = 0x25,
	US_CERT_TYPE_CA_CROSSCERT_2048  = 0x26,
	US_CERT_TYPE_CA_YESSIGN_2048    = 0x27,
	US_CERT_TYPE_CA_KICA_2048       = 0x28,
	US_CERT_TYPE_CA_SIGNKOREA_2048  = 0x29,
	US_CERT_TYPE_USER               = 0x30,
	US_CERT_TYPE_KM                 = 0x40,
    //20170321. jwchoi
    US_CERT_TYPE_CA_CROSSCERT_3     = 0x51,
    US_CERT_TYPE_CA_YessignCAClass2 = 0x52,
    US_CERT_TYPE_CA_KICACA4         = 0x53,
    US_CERT_TYPE_CA_KICACA5         = 0x54,
    US_CERT_TYPE_CA_TradeSignCA3    = 0x55,
    US_CERT_TYPE_CA_SignKoreaCA3    = 0x56,

    US_CERT_TYPE_CA_INIPASS         = 0x57,

} US_CERT_TYPE;

typedef enum {
	US_PRIKEY_TYPE_SIGN = 0x50,
	US_PRIKEY_TYPE_KM = 0x60
} US_PRIKEY_TYPE;

@interface USCertificate : NSMutableDictionary {
}

@property (readonly) NSString *version;                 ///< 버전
@property (readonly) NSString *serial;                  ///< 일련 번호
@property (readonly) NSString *signatureAlgorithm;      ///< 서명 알고리즘
@property (readonly) NSInteger signatureAlgorithmType;  ///< 서명 알고리즘 타입
@property (readonly) NSString *issuerDN;                ///< 발급자 식별 명칭
@property (readonly) NSString *certValidityFrom;        ///< 인증서 유효기간 시작일 (yyyy-mm-dd hh:mm:ss)
@property (readonly) NSString *certValidityTo;          ///< 인증서 유효기간 만료일 (yyyy-mm-dd hh:mm:ss)
@property (readonly) NSInteger expireDays;              ///< 만료 후 지난 날
@property (readonly) NSString *subjectDN;               ///< 소유자 식별 명칭
@property (readonly) NSString *publicKeyAlgorithm;      ///< 공개키 알고리즘
@property (readonly) NSInteger publicKeyAlgorithmType;  ///< 공개키 알고리즘 타입
@property (readonly) NSString *publicKey;               ///< 공개키
@property (readonly) NSString *authorityKeyId;          ///< 기관키 ID
@property (readonly) NSString *authorityKeyIdInfo;      /// 기관키 ID 상세정보
@property (readonly) NSString *subjectKeyId;            ///< 소유자키 식별자
@property (readonly) NSString *subjectAltName;          ///< 소유자 대체 이름
@property (readonly) NSString *CRLDP;                   ///< 폐지목록 분배점
@property (readonly) NSString *keyUsage;                ///< 키 용
@property (readonly) NSString *policy;                  ///< 정책
@property (readonly) NSString *CPS;                     ///< CPS (Certificate Practices Statement)
@property (readonly) NSString *userNotice;              ///< 사용자 알림
@property (readonly) NSString *AIA;                     ///< 기관 정보 접근 (Authority Information Access)
@property (readonly) NSString *OCSPAddr;                ///< OCSP 주소 (Online Certificate Status Protocol)
@property (readonly) NSString *basicConstraints;
@property (readonly) BOOL isCA;                         ///< CA 여부
@property (readonly) NSInteger pathLength;              ///< 경로 길이

#pragma mark 추가 프로퍼티
@property (readonly) USCertificateOwner certType;       /// 인증서 타입
@property (readonly) NSString *commonName;              /// 인증서 cn
@property (readonly) NSString *issuerCN;                /// 인증서 발급기관 cn
@property (readonly) NSString *organization;            /// 인증서 기관
@property (readonly) NSString *validityBeginDate;       /// 인증서 발행일 (yyyy-mm-dd)
@property (readonly) NSString *validityEndDate;         /// 인증서 만료일 (yyyy-mm-dd)
@property (readonly) NSString *validityPeriod;          /// 인증서 유효기간 (발행일 ~ 만료일)
@property (readonly) NSString *subjectAltNameContents;  /// 주체 대체이름 값
@property (readonly) NSString *policyHumanReadableForm; ///< 인증서 정책 (인간이 읽기 쉬운 형태)
@property (readonly) NSString *sha1hashValue;           ///< 인증서 해쉬 값
@property (readonly) NSString *sha256hashValue;         ///< 인증서 해쉬 값
@property (readonly) USCertificate* higherAuthorityCert;///< 상위기관 인증서
@property (readonly) NSString *certImageName;           ///< 인증서 이미지 파일명
@property (readonly) NSString *CRLDP_IP;                ///< CRDLP의 IP
@property (readonly) NSString *CRLDP_PORT;              ///< CRLDP의 Port

- (id) initWithSignCert:(NSData *)signCert signPrikey:(NSData *)signPrikey kmCert:(NSData *)kmCert kmPrikey:(NSData *)kmPrikey;
- (id) initWithSignCert:(NSData *)signCert signPrikey:(NSData *)signPrikey kmCert:(NSData *)kmCert kmPrikey:(NSData *)kmPrikey source:(USCertificateSource)src;
- (id) initCACertificate:(USCertificateCA)ca keyLength:(NSInteger)len;
- (id) initRootCACertificate:(NSInteger)len;
- (id) initWithFile:(NSString *)name;


@end

@interface USCertificate (UniSign)

- (void) setToolkit:(id)toolkit;
- (BOOL) checkUniSign;
+ (const NSString *) typeToString:(USCertificateType)type;
+ (NSInteger) stringToType:(NSString *)type;
- (BOOL) setData:(NSData *)data forType:(USCertificateType)type;
- (NSData *) dataForType:(USCertificateType)type;
- (const unsigned char *) binaryForType:(USCertificateType)type;
- (unsigned int) lengthForType:(USCertificateType)type;
- (BOOL) setBinary:(const unsigned char *)bin length:(unsigned int)len forType:(USCertificateType)type;
- (BOOL) loadDataFromKeyChain:(NSString *)subjectDN type:(USCertificateType)type;
- (void) deAllocation;

@end
