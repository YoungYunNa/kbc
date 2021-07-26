//
//  MobileWeb+KBOpenApi.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 8. 7..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "MobileWeb.h"
#import "GifProgress.h"

#ifndef SELECT_SERVER
//운영
#define OPEN_API_SERVER_URL             @"https://m.kbcard.com"
#define OPEN_API_CLIENT_ID              @"l7xx030af156d68f4c3696e72bd12c3b8a1e"
#define OPEN_API_CLIENT_SECRET          @"7347dd91b2f7455d9946182aea0af6ba"
#else
//개발
#define OPEN_API_SERVER_URL2            @"https://sm.kbcard.com"   //스테이징
#define OPEN_API_SERVER_URL             @"https://dm.kbcard.com"   //개발
#define OPEN_API_CLIENT_ID              @"l7xx245ef6a9327d417ebc81a6a80f88d2a4"
#define OPEN_API_CLIENT_SECRET          @"a2a797179b054d4bb4f01eb7fb0498db"
#endif

#define OPENAPI_PARAM_KEY_SAML      @"SAML"
#define OPENAPI_PARAM_KEY_TOKEN     @"TOKEN"
#define OPENAPI_PARAM_KEY_TERM      @"TERM"
#define OPENAPI_PARAM_KEY_API       @"API"

typedef NS_ENUM(NSInteger, openApiType) {
    openApiType_requestBalance = 0,
    openApiType_requestKBBankOpenAPI,
    openApiType_requestKBOpenApi
};

@protocol OpenApiTermCellgDelegate<NSObject>
- (void)onClickedTrimChecked:(id)sender;
- (void)onClickedDetailTrimButton:(id)sender;
@end

@interface KBOpenApiTermDetailVC : WebViewController
@property (nonatomic, strong) NSString *agreeBody;
@end

@interface OpenApiTermCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton * btnTitle;
@property (nonatomic, unsafe_unretained) id delegate;

- (IBAction)onClickedTrimChecked:(id)sender;
- (IBAction)onClickedDetailTrimButton:(id)sender;
@end

@interface OpenAPIAuth_V2 : MobileWeb
@property (nonatomic, retain) MobileWeb *service;
@property (nonatomic, retain) NSMutableDictionary * authData;
@property (nonatomic, retain) NSString * samlAssertion;
@property (nonatomic, retain) NSString * accessToken;

- (void)goAuthProcess:(openApiType)type callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback;
- (void)requestUserCI:(openApiType)type callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback;
- (void)requestAuthOpenApi:(NSString *)reqType type:(openApiType)type callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback;
- (void)requestAuthOpenApi:(NSString *)reqType type:(openApiType)type param:(NSMutableDictionary *)reqParam callback:(void (^)(BOOL success, NSString * step, NSDictionary *result, NSInteger statusCd))finishedCallback;

- (Request *)settingRequest:(NSString *)reqCMS;
- (NSDictionary *)jsonDataToDictionary:(NSData *)data;
- (NSString *)getCMSUrl:(NSString *)cms;
- (void)requestDelAgree;
- (NSMutableDictionary *)getDefaultData:(NSString *)actionKey;
- (NSString *)getBase64Str:(NSString *)str;
@end

//잔액조회
@interface requestBalance : MobileWeb
- (void)requestBalance:(NSString *)accessToken;
@end

//중금리대출
@interface requestKBBankOpenAPI : MobileWeb
- (void)requestKBBankOpenAPI;
@end

// 손보 openapi (여행자 보험)
@interface requestOpenApi : MobileWeb
- (void)requestOpenApi;
@end

// KB Open API (신규)
@interface  requestKBOpenAPI : MobileWeb
@end
