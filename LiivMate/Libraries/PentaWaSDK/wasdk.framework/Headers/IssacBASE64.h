//
//  IssacBASE64.h
//  wasdk
//
//  Created by 하지윤 on 2021/06/14.
//

#ifndef IssacBASE64_h
#define IssacBASE64_h


@interface IssacBASE64 : NSObject {
}


/// Base64 문자열로 인코딩한다.
/// @param  data    원문
+(NSString *)encode:(NSData *)data;

/// Base64 문자열을 디코딩한다.
/// @param  base64  Base64 문자열
+(NSData *)decode:(NSString *)base64;

@end


#endif /* IssacBASE64_h */
