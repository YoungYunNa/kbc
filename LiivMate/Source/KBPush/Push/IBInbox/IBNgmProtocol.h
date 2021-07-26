//
//  IBInbox.h
//  KBCard
//
//  Created by 정종현 on 2016. 12. 28..
//  Copyright © 2016년 정종현. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "IBInbox.h"
#import "IBProtocol.h"

#pragma mark -
#pragma mark ContentsPayload

@interface ContentsPayload : NSObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * value;

@end


/*
 int64_t date;
 NSString * contentKey;
 NSString * title;
 NSString * text;
 Entry * payload;
 ContentType contentType;
 */
#pragma mark -
#pragma mark ContentsData

@interface ContentsData : NSObject

@property (nonatomic, retain) NSString * contentKey;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * text;
@property (nonatomic) int contentType;
@property (nonatomic) int64_t	 date;
@property (nonatomic, retain) NSArray * payloadList;

@end


#pragma mark -
#pragma mark MessageContents

@interface MessageContents : NSObject

@property (nonatomic, retain) ContentsData    * contentsData;
@property (nonatomic, retain) NSArray * contentsPayloadsList;

@end

#pragma mark -
#pragma mark InboxMessageData

@interface InboxMessageData : NSObject

@property (nonatomic) int64_t date;
@property (nonatomic) int64_t readTime;
@property (nonatomic) int64_t exp;
@property (nonatomic) int64_t expiryTime;
@property (nonatomic) int64_t categoryId;
@property (nonatomic, retain) NSString *serverMessageKey;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSArray *payloadList;
@property (nonatomic, retain) ContentsData *contents;

@end


#pragma mark -
#pragma mark InboxCategotyData

@interface InboxCategotyData : NSObject

@property (nonatomic) int32_t categoryId;
@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * iconName;
@property (nonatomic) int32_t totalCount;
@property (nonatomic) int32_t unreadCount;

@end

@protocol IBInboxProtocol <NSObject>

- (void)inboxLoadFailed:(int)responseCode;

- (void)loadedInboxList:(BOOL)success messageList:(NSArray *)messageList;

- (void)loadedContents:(BOOL)success contents:(ContentsData *)contents;

- (void)removedMessages:(BOOL)success sMsgKeys:(NSArray *)sMsgKeys;

@end

@interface IBNgmProtocol : NSObject
{
    
}

@property (nonatomic, retain) id<IBInboxProtocol> delegate;

+ (IBNgmProtocol *) getInstance;

//-(void)setWithListener:(id<IBInboxProtocol>)ibdelegate;

-(void)requestInboxListReqCategory:(int)page data:(NSDictionary *)requestData;

-(void)requestContents:(NSString *)contentKey;

-(void)requestDeleteMessages:(NSArray *)sMsgKeys;

@end
