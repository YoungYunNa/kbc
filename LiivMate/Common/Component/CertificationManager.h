//
//  CertificationManager.h
//  LiivMate
//
//  Created by kbcard-macpro-a on 2019. 3. 12..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizveraCertMove.h"
#import "WizveraPKCS12.h"
#import "WizveraCertificate.h"
#import "TransKey+Extension.h"
#import "IssacKeychainHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface CertificationManager : NSObject
{
    int failCnt;    //공인인증서 비밀번호 실패 횟수
}


+ (CertificationManager *)shared;


typedef void (^CertManagerFinish)(NSDictionary * _Nullable result, BOOL isSuccess);
@property (nonatomic, strong)CertManagerFinish certManagerFinish;

- (void)getCertWizvera:(NSString *)authCode completion:(CertManagerFinish)completion;
- (void)getCertWizvera:(NSDictionary *)info authCode:(NSString *)authCode completion:(CertManagerFinish)completion;
- (void)deleteCertification:(NSDictionary *)param completion:(CertManagerFinish)completion;
- (void)openSecureKeyboard:(void (^ __nullable)(char *plainText, BOOL isCancel))completion;
- (void)openSecureKeyboard:(NSDictionary *)info completion:(void (^ __nullable)(char *plainText, BOOL isCancel))completion;

- (CertItem * _Nullable)getCertItem:(NSDictionary * _Nonnull)param;
- (void)loadCertifiCation:(CertItem * _Nonnull)certItem pass:(char * _Nonnull)plainText completion:(CertManagerFinish)completion;
- (NSArray<CertItem *> *)getCertificationList;
- (NSArray<NSDictionary *> *)getCertificationList2;
- (BOOL)verifyPassword:(NSString*)subjectID certPassword:(char*)plainText;

// 자산연동 인증서 검증
- (NSMutableDictionary *)getCertVerify:(NSString *)subject epiryData:(NSString *)date planText: (char * _Nonnull) plainText;
- (void)openSecureRaonKeyboard:(void (^ __nullable)(char *plainText, BOOL isCancel))completion title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
