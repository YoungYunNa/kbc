//
//  PureAppLib.h
//  PureAppLib
//
//  Created by hongeiek on 10/12/12.
//  Copyright (c) 2012 hongeiek. All rights reserved.
//

@interface PureAppLib : NSObject

- (NSString *)firstRequest:(NSString *)urlString :(NSMutableDictionary*)addJsonEntryMap;
- (NSString *)getToken;
- (void)addJsonEntry:(NSString*)key :(NSString*)value;
- (void)addJsonEntry:(NSMutableDictionary*)map;
- (NSString*)getVerificationResponseData:(NSString*) key;
- (NSDictionary*)getVerificationResponseDatas;
- (NSString*)getCookie;
- (bool)IIllI: (NSString *)urlString :(NSString *)token;

bool IIII(bool llll);
extern NSString* const ERR_NET_MSG;
extern NSString* const ERR_AUTH_MSG;
extern int binNumData;
extern NSMutableDictionary *binData;


@end

