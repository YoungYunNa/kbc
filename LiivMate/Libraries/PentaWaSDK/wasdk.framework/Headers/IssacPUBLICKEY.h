//
//  IssacPUBLICKEY.h
//  wasdk
//
//  Created by 하지윤 on 2021/06/14.
//

#ifndef IssacPUBLICKEY_h
#define IssacPUBLICKEY_h


@interface IssacPUBLICKEY : NSObject {
}

@property(class, readonly) int symmAlg_SEED;
@property(class, readonly) int symmAlg_ARIA;

/// Framework 내부용 API (사용금지)
-(void *)getCtx;

/// 공개키를 읽어들인다.
/// @param data 공개키
-(int)readData:(NSData *)data;

/// 공개키를 출력한다.
-(NSData *)write;

@end


#endif /* IssacPUBLICKEY_h */
