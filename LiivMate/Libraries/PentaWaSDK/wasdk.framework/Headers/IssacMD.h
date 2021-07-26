//
//  IssacMD.h
//  wasdk
//
//  Created by 하지윤 on 2021/06/08.
//

#ifndef IssacMD_h
#define IssacMD_h


@interface IssacMD : NSObject {
}

-(BOOL)initialize:(int)mdId;

-(BOOL)update:(NSData *)data;

-(NSData *)finalize;

@end

#endif /* IssacMD_h */
