//
//  IssacPRIVATEKEY.h
//  wasdk
//
//  Created by 하지윤 on 2021/05/11.
//

#ifndef IssacPRIVATEKEY_h
#define IssacPRIVATEKEY_h


@interface IssacPRIVATEKEY : NSObject {
}

@property(class, readonly) int symmAlg_SEED;
@property(class, readonly) int symmAlg_ARIA;

/// Framework 내부용 API (사용금지)
-(void *)getCtx;

/// 개인키를 읽어들인다. (PKCS#8 개인키)
/// @param data PKCS#8 개인키
/// @param pin 개인키 비밀번호
-(int)readData:(NSData *)data
           pin:(NSString *)pin;

/// 개인키를 출력한다. (PKCS#8 개인키)
/// @param pin PKCS#8 개인키 비밀번호
/// @param symmAlg 개인키 암호 알고리즘 [SYMM_ALG_SEED, SYMM_ALG_ARIA]
-(NSData *)write:(NSString *)pin
         symmAlg:(int)symmAlg;

@end


#endif /* IssacPRIVATEKEY_h */
