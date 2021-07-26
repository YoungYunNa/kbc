//
//  ViewCertificate.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 4. 20..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#import "CCJSONModel.h"
//#import "CCJSONModel.h"
@interface ViewCertificate : CCJSONModel

@property (nonatomic) int index;


/**
 인증서 정보 유무
 */
@property (nonatomic) BOOL includeCertInfo;

/**
 버전
 */
@property (nonatomic, strong) NSString *version;
/**
 일련번호
 */
@property (nonatomic, strong) NSString *serial;


/**
 발급자
 */
@property (nonatomic, strong) NSString *issuerDN;

/**
 발급일
 */
@property (nonatomic, strong) NSString *validityBeginDate;
/**
 만료일
 */
@property (nonatomic, strong) NSString *validityEndDate;

/**
 인증서DN
 */
@property (nonatomic, strong) NSString *subjectDN;
/**
 공개키 알고리즘
 */
@property (nonatomic) NSInteger publicKeyAlgorithm;

/**
 공개키
 */
@property (nonatomic, strong) NSData *publicKeyInfo;

/**
 주체대체이름
 */
@property (nonatomic, strong) NSString *subjectAltName;

/**
 기관키 ID
 */
@property (nonatomic, strong) NSString *authorityKeyIdentifier;


/**
 기관키 식별자 정보
 */
@property (nonatomic, strong) NSString *authorityKeyIdentifierInfo;

/**
 인증서 주체키 ID
 */
@property (nonatomic, strong) NSString *subjectKeyIdentifier;


/**
 인증서 정책
 */
@property (nonatomic, strong) NSString *certPolicy;

/**
 인증서 CPS
 */
@property (nonatomic, strong) NSString *certCPS;

/**
 인증서 사용자 알림 정보
 */
@property (nonatomic, strong) NSString *certUserNotice;


/**
 인증서 사용자 정보
 */
@property (nonatomic, strong) NSString *commonName;

/**
 인증서 용도
 */
@property (nonatomic, strong) NSString *keyUsage;

/**
 인증서 유효기간
 */
@property (nonatomic, strong) NSString *validityPeriod;

/**
 종류
 */
@property (nonatomic, strong) NSString *policyHumanReadableForm;

/**
 상태
 */
@property (nonatomic) BOOL state;

/**
 인증서 서명알고리즘
 */
@property (nonatomic, strong) NSString *signatureAlgorithm;


/*
 패스사인, TouchID, PIN등 Registration을 수행한 Authenticator 구분
 */
@property (nonatomic, assign) int mRegistrationType;

@end

