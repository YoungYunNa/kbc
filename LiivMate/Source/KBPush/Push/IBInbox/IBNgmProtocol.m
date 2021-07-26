//
//  IBNgmProtocol.m
//  KBCard
//
//  Created by 정종현 on 2016. 12. 28..
//  Copyright © 2016년 정종현. All rights reserved.
//

#import "IBNgmProtocol.h"

static IBNgmProtocol *m_Instance = nil;

@implementation ContentsPayload
@synthesize key;
@synthesize value;
@end

@implementation ContentsData
@synthesize contentKey;
@synthesize title;
@synthesize text;
@synthesize payloadList;
@end

@implementation MessageContents
@synthesize contentsData;
@synthesize contentsPayloadsList;
@end

@implementation InboxMessageData
@synthesize serverMessageKey;
@synthesize title;
@synthesize text;
@synthesize payloadList;
@end

@implementation InboxCategotyData
@synthesize categoryName;
@synthesize iconUrl;
@synthesize iconName;
@end


@implementation IBNgmProtocol

@synthesize delegate;

+ (IBNgmProtocol *) getInstance
{
    @synchronized(self) {
        if (m_Instance == nil)
        {
            m_Instance = [[IBNgmProtocol alloc] init];
        }
    }
    return m_Instance;
}

-(id)init
{
    if ( (self = [super init]) )
    {
    }
    return self;
}

//+(void)loadWithListener:(id)listener
//{
//    
//}

//-(void)loadWithListener:(id<IBInboxDelegate>)ibdelegate
//{
//    delegate = ibdelegate;
//}

-(void)requestInboxListReqCategory:(int)page data:(NSDictionary *)requestData
{
//    NSString *appID = [[PushManager defaultManager].info.applicationID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    NSString *userID = [[PushManager defaultManager].info.clientUID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    
//    NSString *strRequest = [NSString stringWithFormat:@"http://211.241.199.136:3000/api/alarm/messages?APP_ID=%@&USER_ID=%@&PAGE=%d",appID, userID, page];
//    
//    NSURL *url = [NSURL URLWithString:strRequest];
//    
//    NSData *dataInboxMessageList = [[NSData alloc] initWithContentsOfURL:url];
//    
//    if(dataInboxMessageList != nil)
//    {
//        NSDictionary *jsonInboxMessage = [NSJSONSerialization JSONObjectWithData:dataInboxMessageList  options:NSJSONReadingMutableContainers error:nil];
//
//        NSLog(@"dantexx %@", jsonInboxMessage);
//        
//        if([[jsonInboxMessage objectForKey:@"RESULT_CODE"] isEqualToString:@"200"])
//        {
//            NSArray *arrMessage = [jsonInboxMessage objectForKey:@"DATA"];
//            
//            NSMutableArray *itemList = [[NSMutableArray alloc] init];
//            
//            for(NSDictionary *message in arrMessage)
//            {
//                PushMessage *pmsg = [[PushMessage alloc] initWithData:message];
//                [itemList addObject:pmsg];
//            }
//            [self performSelector:@selector(list:) withObject:itemList afterDelay:1.0];
//            //[delegate loadedInboxList:YES messageList:itemList];
//        }
//        else
//        {
//            [delegate loadedInboxList:NO messageList:nil];
//        }
//    }
//    else
//    {
//        [delegate loadedInboxList:NO messageList:nil];
//    }
}

-(void)list:(NSArray *)itemList
{
//    [delegate loadedInboxList:YES messageList:itemList];
}

-(void)delete:(NSArray *)itemList
{
//    [delegate removeMessages:YES sMsgKeys:nil];
}


-(void)requestContents:(NSString *)contentKey
{
}

-(void)requestDeleteMessages:(NSArray *)sMsgKeys
{
//    NSString *strKeys = @"";
//    NSString *userID = [PushManager defaultManager].info.clientUID;
//    for(NSString *msgkey in sMsgKeys)
//    {
//        strKeys = [NSString stringWithFormat:@"%@,%@",strKeys,msgkey];
//    }
//    
//    NSString *strRequest = [NSString stringWithFormat:@"http://211.241.199.136:3000/api/alarm/delete?MSG_IDS=%@&USER_ID=%@",strKeys, userID];
//    NSURL *url = [NSURL URLWithString:strRequest];
//    
//    NSData *dataDeleteMessage = [[NSData alloc] initWithContentsOfURL:url];
//    
//    if(dataDeleteMessage != nil)
//    {
//        NSDictionary *jsonDeleteMessage = [NSJSONSerialization JSONObjectWithData:dataDeleteMessage  options:NSJSONReadingMutableContainers error:nil];
//        
//        NSLog(@"dantexx %@", jsonDeleteMessage);
//        
//        if([[jsonDeleteMessage objectForKey:@"RESULT_CODE"] isEqualToString:@"200"])
//        {
//            [self performSelector:@selector(delete:) withObject:nil afterDelay:1.0];
//            //[delegate removeMessages:YES sMsgKeys:nil];
//        }
//        else
//        {
//            [delegate removeMessages:NO sMsgKeys:nil];
//        }
//    }
//    else
//    {
//        [delegate removeMessages:NO sMsgKeys:nil];
//    }
}

@end
