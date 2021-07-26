//
//  IBInbox.m
//  KBCard
//
//  Created by 정종현 on 2016. 12. 28..
//  Copyright © 2016년 정종현. All rights reserved.
//

#import "IBInbox.h"

@implementation InboxRequestData

@end


@implementation IBInbox

//리스너 등록
+(void)loadWithListener:(id)listener
{
    [[IBNgmProtocol getInstance] setDelegate:listener];
}

//리스트 조회
+ (void)requestInboxListWithReqCategory:(int)category data:(NSDictionary *)reqData
{
    NSString *appID = [[PushManager defaultManager].info.applicationID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *userID = [[PushManager defaultManager].info.clientUID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *strRequest = [NSString stringWithFormat:@"http://211.241.199.136:3000/api/alarm/messages?APP_ID=%@&USER_ID=%@&PAGE=%d",appID, userID, 1];
    
    NSURL *url = [NSURL URLWithString:strRequest];
    
    NSData *dataInboxMessageList = [[NSData alloc] initWithContentsOfURL:url];
    
    if(dataInboxMessageList != nil)
    {
        NSDictionary *jsonInboxMessage = [NSJSONSerialization JSONObjectWithData:dataInboxMessageList  options:NSJSONReadingMutableContainers error:nil];
        
        if([[jsonInboxMessage objectForKey:@"RESULT_CODE"] isEqualToString:@"200"])
        {
            NSArray *arrMessage = [jsonInboxMessage objectForKey:@"DATA"];
            
            NSMutableArray *messageList = [[NSMutableArray alloc] init];
            
            NSLog(@"dantexx %@", jsonInboxMessage);
            
            for(NSDictionary *message in arrMessage)
            {
                InboxMessageData *ibm = [[InboxMessageData alloc] init];
                ibm.date = [[self removeCurrencyString:[message objectForKey:@"DATE"]] longLongValue];
                ibm.readTime = 0;
                ibm.exp = 0;
                ibm.expiryTime = 0;
                ibm.categoryId = [[message objectForKey:@"CATEGORY_CODE"] longLongValue];
                ibm.serverMessageKey = [message objectForKey:@"MSG_ID"];
                ibm.title = [message objectForKey:@"TITLE"];
                ibm.text = [message objectForKey:@"MSG"];
                
                ContentsPayload *cp = [[ContentsPayload alloc] init];
                cp.key = @"ck";
                cp.value = [message objectForKey:@"MSG_ID"];
                
                ibm.payloadList = @[cp];
                
                [messageList addObject:ibm];
            }
            
            [[IBNgmProtocol getInstance].delegate loadedInboxList:YES messageList:messageList];
        }
        else
        {
            [[IBNgmProtocol getInstance].delegate inboxLoadFailed:999];
            //[[IBNgmProtocol getInstance].delegate loadedInboxList:YES messageList:nil];
        }
    }
    else
    {
        [[IBNgmProtocol getInstance].delegate inboxLoadFailed:999];
        //[[IBNgmProtocol getInstance].delegate loadedInboxList:YES messageList:nil];
    }
    
}

//컨텐츠 조회
+(void)requestContents:(NSString *)contentKey
{
    NSString *strRequest = [NSString stringWithFormat:@"http://211.241.199.136:3000/api/inbox/content?CK=%@", contentKey];
    
    NSURL *url = [NSURL URLWithString:strRequest];
    
    NSData *dataInboxContent = [[NSData alloc] initWithContentsOfURL:url];
    
    if(dataInboxContent != nil)
    {
        NSDictionary *jsonInboxContent = [NSJSONSerialization JSONObjectWithData:dataInboxContent  options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"dantexx %@", jsonInboxContent);
        
        NSArray *itemarr = [jsonInboxContent objectForKey:@"entry"];
        
        ContentsData *contents = [[ContentsData alloc] init];
        contents.contentKey = contentKey;
        contents.title = @"";
        contents.text = @"";
        contents.contentType = 0;
        contents.date = 0;
        
        NSMutableArray *payloadList = [[NSMutableArray alloc] init];
        
        for(int i=0; i<[itemarr count]; i++)
        {
            
            NSDictionary *contentitem = [itemarr objectAtIndex:i];
            NSString *contentItemKey = [contentitem objectForKey:@"key"];
            NSString *contentItemValue = [contentitem objectForKey:@"value"];
            
            ContentsPayload *cp = [[ContentsPayload alloc] init];
            cp.key = contentItemKey;
            cp.value = contentItemValue;
            
            [payloadList addObject:cp];
        }
        
        contents.payloadList = [payloadList mutableCopy];
        
        [[IBNgmProtocol getInstance].delegate loadedContents:YES contents:contents];
    }
    else
    {
        [[IBNgmProtocol getInstance].delegate inboxLoadFailed:888];
        //[[IBNgmProtocol getInstance].delegate loadedContents:NO contents:nil];
    }
}

//메시지 삭제
+ (void)requestDeleteMessages:(NSArray *)sMsgKeys
{
    NSString *strKeys = @"";
    NSString *userID = [PushManager defaultManager].info.clientUID;
    for(NSString *msgkey in sMsgKeys)
    {
        strKeys = [NSString stringWithFormat:@"%@,%@",strKeys,msgkey];
    }
    
    NSString *strRequest = [NSString stringWithFormat:@"http://211.241.199.136:3000/api/alarm/delete?MSG_IDS=%@&USER_ID=%@",strKeys, userID];
    NSURL *url = [NSURL URLWithString:strRequest];
    
    NSData *dataDeleteMessage = [[NSData alloc] initWithContentsOfURL:url];
    
    if(dataDeleteMessage != nil)
    {
        NSDictionary *jsonDeleteMessage = [NSJSONSerialization JSONObjectWithData:dataDeleteMessage  options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"dantexx %@", jsonDeleteMessage);
        
        if([[jsonDeleteMessage objectForKey:@"RESULT_CODE"] isEqualToString:@"200"])
        {
            [[IBNgmProtocol getInstance].delegate removedMessages:YES sMsgKeys:nil];
        }
        else
        {
            [[IBNgmProtocol getInstance].delegate inboxLoadFailed:777];
            //[[IBNgmProtocol getInstance].delegate removedMessages:NO sMsgKeys:nil];
        }
    }
    else
    {
        [[IBNgmProtocol getInstance].delegate inboxLoadFailed:777];
        //[[IBNgmProtocol getInstance].delegate removedMessages:NO sMsgKeys:nil];
    }
}


#pragma mark -
#pragma mark DataConvert Util

//숫자 아니면 제거
+ (NSString *) removeCurrencyString:(NSString *)src
{
    if([src length] == 0)
    {
        return src;
    }
    
    NSMutableString *retStr = [NSMutableString stringWithFormat:@"%@", src];
    
    for( int i = (int)([src length]-1); i > 0; i-- )
    {
        NSInteger code = [src characterAtIndex:i];
        if(code < 48 || code > 57)
        {
            NSRange range = { i, 1 };
            [retStr deleteCharactersInRange:range];
        }
    }
    
    return retStr;
}


@end
