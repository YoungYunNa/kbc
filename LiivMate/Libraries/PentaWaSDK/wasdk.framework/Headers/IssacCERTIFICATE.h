//
//  IssacCERTIFICATE.h
//  wasdk
//
//  Created by 하지윤 on 2021/05/11.
//

#ifndef IssacCERTIFICATE_h
#define IssacCERTIFICATE_h


@interface IssacCERTIFICATE : NSObject {
}

/// Framework 내부용 API (사용금지)
-(void *)getCtx;

/// 인증서를 읽어들인다.
/// @param  data    인증서
-(int)readData:(NSData *)data;

/// 인증서를 BER 형식으로 가져온다.
-(NSData *)write;

/// 인증서의 주체(Subject) DN을 가져온다.
-(NSString *)subjectDn;

/// 인증서의 발급자(Issuer) DN을 가져온다.
-(NSString *)issuerDn;

/// 인증서의 일련번호(HEX 문자열)를 가져온다.
-(NSString *)serialNumber;

/// 인증서의 유효기간 시작시각을 가져온다.
/// @param  format  표시방법 (ex. YYYYMMDD hhmmss)
-(NSString *)validityNotBefore:(NSString *)format;

/// 인증서의 유효기간 만료시각을 가져온다.
/// @param  format  표시방법 (ex. YYYYMMDD hhmmss)
-(NSString *)validityNotAfter:(NSString *)format;

/// 인증서의 정책 OID를 가져온다.
-(NSString *)policyOid;

/// 인증서의 키 사용용도를 가져온다.
-(NSString *)keyUsage;

/// 인증서의 주체(Subject) 공개키 ID(SHA1 해시값)를 가져온다.
-(NSData *)skid;

/// 인증서의 발급자(Issuer) 공개키 ID(SHA1 해시값)를 가져온다.
-(NSData *)akid;

/// 인증서의 발급자의 발급자(IssuerOfIssuer) DN을 가져온다. (발급자 인증서를 특정하기 위해 사용)
-(NSString *)issuerOfIssuerDn;

/// 인증서의 발급자 일련번호(HEX 문자열)를 가져온다. (발급자 인증서를 특정하기 위해 사용)
-(NSString *)issuerSerialNumber;

/// 인증서의  CDP(CRL 배포 지점)를 가져온다.
-(NSString *)cdp;

/// 인증서의 서명값을 검증한다.
/// @param  issuer  발급자의 인증서
-(BOOL)verifySignature:(IssacCERTIFICATE *)issuer;

/// 인증서의 유효기간을 검증한다.
/// @param  date    검증할 시각
-(BOOL)verifyTime:(NSDate *)date;

@end


#endif /* IssacCERTIFICATE_h */
