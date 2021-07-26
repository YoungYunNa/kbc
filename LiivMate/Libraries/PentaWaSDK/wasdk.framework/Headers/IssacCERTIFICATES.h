//
//  IssacCERTIFICATES.h
//  wasdk
//
//  Created by 하지윤 on 2021/06/08.
//

#ifndef IssacCERTIFICATES_h
#define IssacCERTIFICATES_h

#include <wasdk/IssacCERTIFICATE.h>


@interface IssacCERTIFICATES : NSObject {
}

/// Framework 내부용 API (사용금지)
-(void *)getCtx;

/// 포함된 인증서의 개수
-(int)count;

/// 인증서를 추가한다.
/// @param  cert    추가할 인증서
-(BOOL)add:(IssacCERTIFICATE *)cert;

/// 인증서를 가져온다.
/// @param  index   가져올 인증서의 인덱스
-(IssacCERTIFICATE *)get:(int)index;

@end


#endif /* IssacCERTIFICATES_h */
