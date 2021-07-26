//
//  IBInbox.h
//  KBCard
//
//  Created by 정종현 on 2016. 12. 28..
//  Copyright © 2016년 정종현. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "IBProtocol.h"
#import "IBNgmProtocol.h"
#import <MPushLibrary/MPushLibrary.h>

@interface InboxRequestData : NSObject

@property (nonatomic) int maxCount;
@property (nonatomic) BOOL ascending;
@property (nonatomic) int32_t start;

@end

@interface IBInbox : NSObject
{
    
}

+ (void)loadWithListener:(id)listener;

//+ (void)requestInboxList;
//+ (void)requestInboxListWithReqData:(InboxRequestData *)reqData;
+ (void)requestInboxListWithReqCategory:(int)category data:(InboxRequestData *)reqData;
//+ (void)requestInboxCategoryInfo;
+ (void)requestDeleteMessages:(NSArray *)sMsgKeys;
//+ (void)requestReadMessageWithMsgKey:(NSArray *)sMsgKeys readMethod:(int)readMethod;
+ (void)requestContents:(NSString *)contentKey;
//+ (void)deviceFeedBack:(DeviceFeedBackData *)deviceFeedBackData;
//+ (NSObject *)getEntry:(NSString *)key value:(NSString *)value;
//+ (void)getKbPinCode:(NSString *)deviceCode;

+ (NSString *) removeCurrencyString:(NSString *)src;
@end
