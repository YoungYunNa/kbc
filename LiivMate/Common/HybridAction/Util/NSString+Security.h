//
//  NSString+Security.h
//  SafeNo
//
//  Created by Oh Seung Yong on 2015. 1. 13..
//  Copyright (c) 2015년 Oh seung yong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (__Base64)
+ (NSData *)__hex:(NSString *)data;
+ (NSData *)__dataWithBase64EncodedString:(NSString *)string;
- (NSString *)__base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)__base64EncodedString;
- (NSString *)base64EncodedString;
@end

@interface NSString (__Security)

//key len 16 = aes128, 24 = aes192, 32 = aes256 || iv len = 16
+ (void)setAesBaseKey:(NSString*)key keySha384Hash:(BOOL)keySha384 ivSet:(BOOL)ivSet;

- (NSString*)encryptAes128;
- (NSString*)decryptAes128;
- (NSString*)encryptAes192;
- (NSString*)decryptAes192;
- (NSString*)encryptAes256;
- (NSString*)decryptAes256;
- (NSString*)aesEncryptForKey:(NSString *)key iv:(NSString *)iv;//key len 16 = aes128, 24 = aes192, 32 = aes256 || iv len = 16
- (NSString*)aesDecryptForKey:(NSString *)key iv:(NSString *)iv;//key len 16 = aes128, 24 = aes192, 32 = aes256 || iv len = 16
- (NSData*)aesCryptForDatakey:(NSData *)key iv:(NSData *)iv isEncrypt:(BOOL)isEncrypt;

- (NSString*)hashMD5;
- (NSString*)hashSHA1;
- (NSString*)hashSHA224;
- (NSString*)hashSHA256;
- (NSString*)hashSHA384;
- (NSString*)hashSHA512;

- (NSString*)hashMD5forKey:(NSString*)key;
- (NSString*)hashSHA1forKey:(NSString*)key;
- (NSString*)hashSHA224forKey:(NSString*)key;
- (NSString*)hashSHA256forKey:(NSString*)key;
- (NSString*)hashSHA384forKey:(NSString*)key;
- (NSString*)hashSHA512forKey:(NSString*)key;

+(NSString*)sha256HashForText:(NSString*)text;
@end

@interface NSData (__Security)
- (NSData*)encryptAes128;
- (NSData*)decryptAes128;
- (NSData*)encryptAes192;
- (NSData*)decryptAes192;
- (NSData*)encryptAes256;
- (NSData*)decryptAes256;
- (NSData*)aesCryptForDatakey:(NSData *)key iv:(NSData *)iv isEncrypt:(BOOL)isEncrypt;

- (NSData*)hashMD5;
- (NSData*)hashSHA1;
- (NSData*)hashSHA224;
- (NSData*)hashSHA256;
- (NSData*)hashSHA384;
- (NSData*)hashSHA512;

- (NSString*)hashMD5forKey:(NSString*)key;
- (NSString*)hashSHA1forKey:(NSString*)key;
- (NSString*)hashSHA224forKey:(NSString*)key;
- (NSString*)hashSHA256forKey:(NSString*)key;
- (NSString*)hashSHA384forKey:(NSString*)key;
- (NSString*)hashSHA512forKey:(NSString*)key;
@end

@interface CertDictionary : NSObject
+(instancetype)dictionary;
-(void)setObject:(id)anObject forKey:(id)aKey;
-(void)setValue:(id)value forKey:(NSString *)key;
-(id)objectForKey:(id)aKey;
-(id)valueForKey:(NSString *)key;
-(void)removeAllObjects;
-(void)removeObjectForKey:(id)key;
@end
