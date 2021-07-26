//
//  NSString+Security.m
//  SafeNo
//
//  Created by Oh Seung Yong on 2015. 1. 13..
//  Copyright (c) 2015년 Oh seung yong. All rights reserved.
//

#import "NSString+Security.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (__Base64)

+ (NSData *)__hex:(NSString *)data
{
    if (data.length == 0) { return nil; }
    
    static const unsigned char HexDecodeChars[] =
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //49
        2, 3, 4, 5, 6, 7, 8, 9, 0, 0, //59
        0, 0, 0, 0, 0, 10, 11, 12, 13, 14,
        15, 0, 0, 0, 0, 0, 0, 0, 0, 0,  //79
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 10, 11, 12,   //99
        13, 14, 15
    };
    
    // convert data(NSString) to CString
    const char *source = [data cStringUsingEncoding:NSUTF8StringEncoding];
    // malloc buffer
    unsigned char *buffer;
    NSUInteger length = strlen(source) / 2;
    buffer = malloc(length);
    for (NSUInteger index = 0; index < length; index++) {
        buffer[index] = (HexDecodeChars[source[index * 2]] << 4) + (HexDecodeChars[source[index * 2 + 1]]);
    }
    // init result NSData
    NSData *result = [NSData dataWithBytes:buffer length:length];
    free(buffer);
    source = nil;
    
    return  result;
}

+ (NSData *)__dataWithBase64EncodedString:(NSString *)string
{
    if (![string length]) return nil;
    
    NSData *decoded = nil;
    
//#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9 || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
//    
//    if (![NSData instancesRespondToSelector:@selector(initWithBase64EncodedString:options:)])
//    {
//        decoded = [[self alloc] initWithBase64Encoding:[string stringByReplacingOccurrencesOfString:@"[^A-Za-z0-9+/=]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [string length])]];
//    }
//    else
//        
//#endif
	
    {
        decoded = [[self alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
	
	if(decoded.length == 0)
		decoded = nil;
	
    return decoded;
}

- (NSString *)__base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    if (![self length]) return nil;
    
    NSString *encoded = nil;
    
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9 || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    
    if (![NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
    {
        encoded = [self performSelector:@selector(base64Encoding)];
    }
    else

#endif
        
    {
        switch (wrapWidth)
        {
            case 64:
            {
                return [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            }
            case 76:
            {
                return [self base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
            }
            default:
            {
                encoded = [self base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
            }
        }
    }
    
    if (!wrapWidth || wrapWidth >= [encoded length])
    {
        return encoded;
    }
    
    wrapWidth = (wrapWidth / 4) * 4;
    NSMutableString *result = [NSMutableString string];
    for (NSUInteger i = 0; i < [encoded length]; i+= wrapWidth)
    {
        if (i + wrapWidth >= [encoded length])
        {
            [result appendString:[encoded substringFromIndex:i]];
            break;
        }
        [result appendString:[encoded substringWithRange:NSMakeRange(i, wrapWidth)]];
        [result appendString:@"\r\n"];
    }
    
    return result;
}

- (NSString *)__base64EncodedString
{
    return [self __base64EncodedStringWithWrapWidth:0];
}

- (NSString *)base64EncodedString
{
	return [self __base64EncodedString];
}

@end

@interface NSString (__Base64)
+ (NSString *)__stringWithBase64EncodedString:(NSString *)string;
- (NSString *)__base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)__base64EncodedString;
- (NSString *)__base64DecodedString;
- (NSData *)__base64DecodedData;
@end

@implementation NSString (__Base64)

+ (NSString *)__stringWithBase64EncodedString:(NSString *)string
{
    NSData *data = [NSData __dataWithBase64EncodedString:string];
    if (data)
    {
        return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)__base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data __base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)__base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data __base64EncodedString];
}

- (NSString *)__base64DecodedString
{
    return [NSString __stringWithBase64EncodedString:self];
}

- (NSData *)__base64DecodedData
{
    return [NSData __dataWithBase64EncodedString:self];
}

@end

@implementation NSString (__Security)

static NSData *AESBASEKEY = nil;
static NSData *AESBASEIV =  nil;

+ (void)initialize
{
	[super initialize];
    if(AESBASEKEY == nil)
    {
        NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
        [self setAesBaseKey:bundleIdentifier keySha384Hash:YES ivSet:YES];
    }
}

+ (void)setAesBaseKey:(NSString*)key keySha384Hash:(BOOL)keySha384 ivSet:(BOOL)ivSet
{
    AESBASEKEY = nil;
    AESBASEIV = nil;
    if(key)
    {
        if(keySha384)
        {
            NSData *ssh384Data = [[key dataUsingEncoding:NSUTF8StringEncoding] hashSHA384];
            AESBASEKEY = [[NSData alloc] initWithData:[ssh384Data subdataWithRange:NSMakeRange(0, 32)]];
            if(ivSet)
                AESBASEIV = [[NSData alloc] initWithData:[ssh384Data subdataWithRange:NSMakeRange(ssh384Data.length - 16, 16)]];
        }
        else
        {
            NSData *hashData = [key dataUsingEncoding:NSUTF8StringEncoding];
            AESBASEKEY = [[NSData alloc] initWithData:[hashData subdataWithRange:NSMakeRange(0, 32)]];
            if(ivSet)
                AESBASEIV = [[NSData alloc] initWithData:[hashData subdataWithRange:NSMakeRange(hashData.length - 16, 16)]];
        }
    }
}

-(NSString*)encryptAes128
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES128)];
    return [self aesEncryptForDatakey:key iv:AESBASEIV];
}

-(NSString*)decryptAes128
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES128)];
    return [self aesDecryptForDatakey:key iv:AESBASEIV];
}

-(NSString*)encryptAes192
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES192)];
    return [self aesEncryptForDatakey:key iv:AESBASEIV];
}

-(NSString*)decryptAes192
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES192)];
    return [self aesDecryptForDatakey:key iv:AESBASEIV];
}

-(NSString*)encryptAes256
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES256)];
    return [self aesEncryptForDatakey:key iv:AESBASEIV];
}

-(NSString*)decryptAes256
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES256)];
    return [self aesDecryptForDatakey:key iv:AESBASEIV];
}

- (NSString*)aesEncryptForKey:(NSString *)keyStr iv:(NSString *)ivStr
{
    NSData *key = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *iv = [ivStr dataUsingEncoding:NSUTF8StringEncoding];

    return [self aesEncryptForDatakey:key iv:iv];
}

- (NSString*)aesEncryptForDatakey:(NSData *)key iv:(NSData *)iv
{
    NSData *encryptData = [self aesCryptForDatakey:key iv:iv isEncrypt:YES];
    NSString *encryptStr = [encryptData __base64EncodedString];
    //NSLog(@"Encrypt : %@ > %@",self,encryptStr);
    return encryptStr;
}

- (NSString*)aesDecryptForKey:(NSString *)keyStr iv:(NSString *)ivStr
{
    NSData *key = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *iv = [ivStr dataUsingEncoding:NSUTF8StringEncoding];

    return [self aesDecryptForDatakey:key iv:iv];
}

- (NSString*)aesDecryptForDatakey:(NSData *)key iv:(NSData *)iv
{
    NSData *decryptData = [self aesCryptForDatakey:key iv:iv isEncrypt:NO];
    NSString *decryptStr = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
    //NSLog(@"Decrypt : %@ > %@",self,decryptStr);
    return decryptStr;
}

- (NSData*)aesCryptForDatakey:(NSData *)key iv:(NSData *)iv isEncrypt:(BOOL)isEncrypt
{
    NSData *data = nil;
    if(isEncrypt)
        data = [self dataUsingEncoding:NSUTF8StringEncoding];
    else//decrypt
        data = [NSData __dataWithBase64EncodedString:self];
    
    return [data aesCryptForDatakey:key iv:iv isEncrypt:isEncrypt];
}

-(NSString*)hashMD5
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashMD5] __base64EncodedString];
}

- (NSString*)hashMD5forKey:(NSString*)key
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashMD5forKey:key] __base64EncodedString];
}

-(NSString*)hashSHA1
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA1] __base64EncodedString];
}

- (NSString*)hashSHA1forKey:(NSString*)key
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA1forKey:key] __base64EncodedString];
}

-(NSString*)hashSHA224
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA224] __base64EncodedString];
}

- (NSString*)hashSHA224forKey:(NSString*)key
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA224forKey:key] __base64EncodedString];
}

-(NSString*)hashSHA256
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA256] __base64EncodedString];
}

- (NSString*)hashSHA256forKey:(NSString*)key
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA256forKey:key] __base64EncodedString];
}

-(NSString*)hashSHA384
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA384] __base64EncodedString];
}

- (NSString*)hashSHA384forKey:(NSString*)key
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA384forKey:key] __base64EncodedString];
}

-(NSString*)hashSHA512
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA512] __base64EncodedString];
}

- (NSString*)hashSHA512forKey:(NSString*)key
{
    NSData *hashData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [[hashData hashSHA512forKey:key] __base64EncodedString];
}

+(NSString*)sha256HashForText:(NSString*)text
{
    if(text != nil){
        const char* utf8chars = [text UTF8String];
        unsigned char result[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(utf8chars, (CC_LONG)strlen(utf8chars), result);

        NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
        for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
            [ret appendFormat:@"%02x",result[i]];
        }
         return ret;
    }
    return @"";
}
@end

@implementation NSData (__Security)

-(NSData*)encryptAes128
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES128)];
    return [self aesCryptForDatakey:key iv:AESBASEIV isEncrypt:YES];
}

-(NSData*)decryptAes128
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES128)];
    return [self aesCryptForDatakey:key iv:AESBASEIV isEncrypt:NO];
}

-(NSData*)encryptAes192
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES192)];
    return [self aesCryptForDatakey:key iv:AESBASEIV isEncrypt:YES];
}

-(NSData*)decryptAes192
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES192)];
    return [self aesCryptForDatakey:key iv:AESBASEIV isEncrypt:NO];
}

-(NSData*)encryptAes256
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES256)];
    return [self aesCryptForDatakey:key iv:AESBASEIV isEncrypt:YES];
}

-(NSData*)decryptAes256
{
    NSData *key = [AESBASEKEY subdataWithRange:NSMakeRange(0, kCCKeySizeAES256)];
    return [self aesCryptForDatakey:key iv:AESBASEIV isEncrypt:NO];
}

- (NSData*)aesCryptForDatakey:(NSData *)key iv:(NSData *)iv isEncrypt:(BOOL)isEncrypt
{
    if ([iv length] != 0 && [iv length] != 16)
    {
        NSLog(@"Length of iv is wrong. Length of iv should be 16(128bits)");
        NSInteger appendLenth = 16;
        appendLenth = appendLenth - (key.length % appendLenth);
        NSMutableData *data = [NSMutableData dataWithData:iv];
        [data increaseLengthBy:appendLenth];
        iv = data;
    }
    if ([key length] != 16 && [key length] != 24 && [key length] != 32 )
    {
        NSLog(@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)");
        if(key.length > 32)
        {
            key = [key subdataWithRange:NSMakeRange(0, 32)];
        }
        else
        {
            NSInteger appendLenth = key.length < 16 ? 16 : 8;
            appendLenth = appendLenth - (key.length % appendLenth);
            NSMutableData *data = [NSMutableData dataWithData:key];
            [data increaseLengthBy:appendLenth];
            key = data;
        }
    }
    
    NSData *data = self;
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t cryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt((isEncrypt ? kCCEncrypt : kCCDecrypt),
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          (iv.length == 0 ? NULL : [iv bytes]),// IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &cryptedSize);
    
    if (cryptStatus != kCCSuccess)
    {
        free(buffer);
        return nil;
    }
    
    NSData *cryptData = [NSData dataWithBytes:buffer length:cryptedSize];
    free(buffer);
    return cryptData;
}


-(NSData*)hashMD5
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_MD5_DIGEST_LENGTH);
    
    CC_MD5([hashData bytes], (CC_LONG)[hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

- (NSData*)hashMD5forKey:(NSString*)key
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_MD5_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

-(NSData*)hashSHA1
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA1_DIGEST_LENGTH);
    
    CC_SHA1([hashData bytes], (CC_LONG)[hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

- (NSData*)hashSHA1forKey:(NSString*)key
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA1_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

-(NSData*)hashSHA224
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA224_DIGEST_LENGTH);
    
    CC_SHA224([hashData bytes], (CC_LONG)[hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

- (NSData*)hashSHA224forKey:(NSString*)key
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA224_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA224, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

-(NSData*)hashSHA256
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA256_DIGEST_LENGTH);
    
    CC_SHA256([hashData bytes], (CC_LONG)[hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

- (NSData*)hashSHA256forKey:(NSString*)key
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA256_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

-(NSData*)hashSHA384
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA384_DIGEST_LENGTH);
    
    CC_SHA384([hashData bytes], (CC_LONG)[hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

- (NSData*)hashSHA384forKey:(NSString*)key
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA384_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA384, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

-(NSData*)hashSHA512
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA512_DIGEST_LENGTH);
    
    CC_SHA512([hashData bytes], (CC_LONG)[hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}

- (NSData*)hashSHA512forKey:(NSString*)key
{
    NSData *hashData = self;
    unsigned char *digest;
    digest = malloc(CC_SHA512_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    hashData = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    free(digest);
    
    return hashData;
}


@end

@implementation CertDictionary
{
	NSMutableDictionary *_dic;
}

-(void)dealloc
{
	[_dic removeAllObjects];
	_dic = nil;
}

+(instancetype)dictionary
{
	return [[CertDictionary alloc] init];
}

-(void)removeAllObjects
{
	[_dic removeAllObjects];
}

-(void)removeObjectForKey:(id)aKey
{
	if([aKey respondsToSelector:@selector(encryptAes128)])
		aKey = [aKey encryptAes128];
	[_dic removeObjectForKey:aKey];
}

-(void)setObject:(id)anObject forKey:(id)aKey
{
	if(_dic == nil)
		_dic = [[NSMutableDictionary alloc] init];
	
	if([anObject respondsToSelector:@selector(encryptAes128)])
		anObject = [anObject encryptAes128];
	if([aKey respondsToSelector:@selector(encryptAes128)])
		aKey = [aKey encryptAes128];
	[_dic setValue:anObject forKey:aKey];
}

-(void)setValue:(id)value forKey:(NSString *)key
{
	[self setObject:value forKey:key];
}

-(id)objectForKey:(id)aKey
{
	if([aKey respondsToSelector:@selector(encryptAes128)])
		aKey = [aKey encryptAes128];
	id value = [_dic valueForKey:aKey];
	if([value respondsToSelector:@selector(decryptAes128)])
		value = [value decryptAes128];
	return value;
}

-(id)valueForKey:(NSString *)key

{
	return [self objectForKey:key];
}

-(NSString*)description
{
	return _dic.description;
}

-(NSString*)debugDescription
{
	return _dic.debugDescription;
}

@end
