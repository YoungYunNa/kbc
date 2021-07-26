//
//  ScrappingManager.h
//  LiivMate
//
//  Created by kbcard-macpro-a on 2019. 3. 15..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OmniDoc/FHOmniDoc.h>
#import "CertificationManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScrappingManager : NSObject
{
    FHOmniDoc *omniDoc;
    int count;
    void *handle;
    int progress[1];
    int stop[1];
    NSArray *issueRes;
    
    NSMutableDictionary *resultDic;
    int failCnt;
    NSInteger scrappingErrCd;
}

+ (ScrappingManager *)shared;

typedef void (^ScrappingFinish)(NSDictionary * _Nullable result, BOOL isSuccess);
@property (nonatomic, strong)ScrappingFinish scrappingFinish;
- (void)startScrapping:(NSDictionary *)param retry:(BOOL)retry completion:(ScrappingFinish)completion;
@end

NS_ASSUME_NONNULL_END
