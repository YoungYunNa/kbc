//
//  IssacHEX.h
//  wasdk
//
//  Created by 하지윤 on 2021/06/14.
//

#ifndef IssacHEX_h
#define IssacHEX_h


@interface IssacHEX : NSObject {
}


/// HEX 문자열로 인코딩한다.
/// @param  data    원문
+(NSString *)encode:(NSData *)data toUpper:(BOOL)toUpper;

/// HEX 문자열을 디코딩한다.
/// @param  hex HEX 문자열
+(NSData *)decode:(NSString *)hex;

@end


#endif /* IssacHEX_h */
