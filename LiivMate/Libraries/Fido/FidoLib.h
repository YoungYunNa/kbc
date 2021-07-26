//
//  FidoLib.h
//  FidoLib
//
//  Created by jh on 2016. 4. 8..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef CF_ENUM(NSInteger, FidoType)
{
    FidoTypeNone,
    FidoTypeLogin,               // 로그인 사용 L
    FidoTypeETC,                 // 기타시 사용 E (등록)
    FidoTypeAuthentication       // 인증시 사용 A
};

typedef CF_ENUM(NSInteger, KBType)
{
    KBType00,   // 모션
    KBType01,   // 통합
    KBType02,   // 리브메이트
    KBType03    // 라이프샾
};

@protocol VPFidoLibDelegate;

@interface FidoLib : NSObject

@property(nonatomic, weak) id<VPFidoLibDelegate> m_deletegate;

- (void)setDelegate:(id<VPFidoLibDelegate>)deletegate withKBType:(KBType)type;

- (void)fido_Registration:(FidoType)fidoType server:(NSString *)server;
- (void)fido_Authentication:(FidoType)fidoType server:(NSString *)server;
- (void)fido_Deregistration:(FidoType)fidoType server:(NSString *)server;

/*!
 *  isLogOn
 *
 *  Discussion:
 *        Sets whether Log is on/off.
 *        YES : Shows logs
 *        NO : Does not show logs        (default)
 */
@property (nonatomic, assign) BOOL isLogOn;

@end

@protocol VPFidoLibDelegate<NSObject>;

@required
- (void)result_Register:(BOOL)success;
- (void)result_Auth:(BOOL)success postData:(NSString *)postData userId:(NSString *)userId;
- (void)result_Deregister:(BOOL)success;
- (void)OnFidoError:(int) reason;

@end
