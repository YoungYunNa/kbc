//
//  PushReceiver.m
//
//

#import "PushReceiver.h"
#import "KCLIntroViewController.h"

typedef void(^PushReceiverExtLoadHandler)(BOOL success, NSString *richData, NSError *error);

@interface PushReceiver () <PushManagerDelegate>

@end

@implementation PushReceiver

- (void)dealloc {
    NSLog( @"PushReceiver - dealloc" );
}

- (id)init {
    self = [super init];
    if (self) {
        NSLog( @"PushReceiver - init" );
#ifdef DEBUG
        [[PushManager defaultManager].info changeHost:@"https://dpush.kbcard.com:1176"];
        /// 개발용 푸쉬 설정
        [[PushManager defaultManager].info changeMode:@"DEV"];
#endif

    }
    return self;
}

- (void)manager:(PushManager *)manager didLoadPushInfo:(PushManagerInfo *)pushInfo {
    NSLog( @"PushReceiver - manager didLoadPushInfo: %@", pushInfo );
}

- (void)managerDidRegisterForRemoteNotifications:(PushManager *)manager userInfo:(NSDictionary *)userInfo {
    NSLog( @"PushReceiver - managerDidRegisterForRemoteNotifications userInfo: %@", userInfo );
}

- (void)manager:(PushManager *)manager didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog( @"PushReceiver - didFailToRegisterForRemoteNotificationsWithError error: %@", error );
}

- (void)manager:(PushManager *)manager didReceiveUserNotification:(NSDictionary *)userInfo status:(NSString *)status messageUID:(NSString *)messageUID {
    NSLog( @"PushReceiver - didReceiveUserNotification: %@ status: %@ messageUID:%@", userInfo, status, messageUID );
    
    NSString *extHTML = [[userInfo objectForKey:@"mps"] objectForKey:@"ext"];

    NSLog( @"PushReceiver - extHTML :%@", extHTML );
    
    if ( extHTML != nil && ([extHTML hasSuffix:@"_msp.html"] || [extHTML hasSuffix:@"_ext.html"]) ) {
        [self loadExtData:extHTML handler:^(BOOL success, NSString *richData, NSError *error) {
            NSLog( @"PushReceiver - richData : %@", richData );
        
            NSMutableDictionary *notification = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            NSMutableDictionary *mspData = [NSMutableDictionary dictionaryWithDictionary:[notification objectForKey:@"mps"]];
            [mspData setObject:richData forKey:@"ext"];
            [notification setObject:mspData forKey:@"mps"];
            
            //NSLog( @"notification: %@", notification );
            
            [self onReceiveNotification:[NSDictionary dictionaryWithDictionary:notification] status:status messageUID:messageUID];
        }];
    }
    else {
        //NSLog( @"notification: %@", userInfo );

        [self onReceiveNotification:userInfo status:status messageUID:messageUID];
    }
}

- (void)loadExtData:(NSString *)extHTML handler:(PushReceiverExtLoadHandler)handler {

    NSURL *url = [NSURL URLWithString:extHTML];
    
    if (!url) {
        handler(NO, extHTML, nil);
        return;
    }
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
        
        if ( connectionError != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO, extHTML, connectionError);
            });
            return;
        }
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)response;
            
        if ( httpResponse.statusCode != 200 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO, extHTML, nil);
            });
            return;
        }
        
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *richData = [NSString stringWithString:result];
        
        richData = [richData stringByRemovingPercentEncoding];
        
        #if ! __has_feature(objc_arc)
        [result release];
        #endif
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(YES, richData, nil);
        });
    }];
    
    [task resume];
}

- (void)onReceiveNotification:(NSDictionary *)payload status:(NSString *)status messageUID:(NSString *)messageUID {
    NSString *pushType = @"APNS";
    
    //    NSDictionary *apsInfo = [payload objectForKey:@"aps"];
    //    NSString *message = [apsInfo objectForKey:@"alert"];
    
    if ([@"ACTIVE" isEqualToString:status]) {
        [APP_DELEGATE showRemoteNotificationPopup:payload];
        
    } else {
        
        if([APP_DELEGATE.window.rootViewController isKindOfClass:[KCLIntroViewController class]])
        {//인트로 화면인경우
            [AppInfo sharedInfo].launchOptions = [NSDictionary dictionaryWithObjectsAndKeys:payload, UIApplicationLaunchOptionsRemoteNotificationKey, nil];
        }
        else
        {
            if(AppInfo.sharedInfo.isLogin)
            {//로그인상태였으면 킵얼라이브 체크후 처리해야함.
                [AppInfo sharedInfo].launchOptions = [NSDictionary dictionaryWithObjectsAndKeys:payload, UIApplicationLaunchOptionsRemoteNotificationKey, nil];
                if([MateRequest isSendKeepAlive] == NO)
                {//어플을 백그라운드로 보내지 않고 위젯등의 화면에서 푸시가 올경우
                    [Request sendKeepAlive:NO callback:^{
                        [AppInfo sharedInfo].launchOptions = nil;
                        [APP_DELEGATE showRemoteNotificationPopup:payload];
                    }];
                }
                //else 어플이 백그라운드로 나가있다가 푸시으로 들어온경우 -> applicationWillEnterForeground: 에서 처리
            }
            else
            {
                [APP_DELEGATE showRemoteNotificationPopup:payload];
            }
        }
    }

    NSDictionary *notificationInfo = @{@"status":status, @"payload":payload, @"type":pushType, @"messageUID": messageUID};

    NSLog( @"PushReceiver - notificationInfo: %@", notificationInfo );
    
    NSInteger temp = [[payload null_valueForKey:@"aps"][@"badge"] integerValue];
    if(temp > 0)
    {
        temp--;
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = temp;
    [[PushManager defaultManager] read:nil notification:payload badgeOption:PushManagerBadgeOptionKeep completionHandler:^(BOOL success){}];
    [[PushManager defaultManager] update:nil badge:@(temp) completionHandler:^(BOOL success) {}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATIONREFRESH" object:@""];
}


@end
