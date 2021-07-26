//
//  AccountManager.m
//  KBSmartPay
//
//  Created by admin on 2015. 9. 1..
//  Copyright (c) 2015년 Seeroo Inc. All rights reserved.
//

#import "AccountManager.h"
#import "KKClient.h"
//#import "IBConfigDefaults.h"

static AccountManager * sharedInstance = nil;

@implementation AccountManager

+ (AccountManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[AccountManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)destroyInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (sharedInstance)
            
            sharedInstance = nil;
    });
}

-(void)registerUser:(NSString *)userId
{
    //고객식별자를 불러온다.
    NSString *clientIdentifier = [CONF valueForKey:kConfigKeyAlimeClientIdentifier];
    if ([clientIdentifier isEqual:[NSNull null]] && [clientIdentifier isEqualToString:@""]) {
        //(구)모바일 홈에서는 'clientIdentifier' 로 kb-pin을 저장해서 쓴다.
        clientIdentifier = [CONF valueForKey:@"clientIdentifier"];
    }
    
    //사용자 등록을 요청한다.
    if(clientIdentifier && ![clientIdentifier isEqualToString:@""])
    {
        UINavigationController *navigationController = (UINavigationController *)[UIApplication sharedApplication].windows.firstObject.rootViewController;
        
        [[PushManager defaultManager] registerService:[navigationController.viewControllers lastObject] completionHandler:^(BOOL success) {
            if (success == YES) {
                [[PushManager defaultManager] registerUser:[navigationController.viewControllers lastObject] clientUID:clientIdentifier clientName:userId completionHandler:^(BOOL success)
                 {
                     if(success == YES)
                     {
                         [IBConfigDefaults setObject:@"YES" forKey:@"RenewalAccountIpns"];
                         //사용자 등록 완료 시 noti
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountSuccess" object:nil];
                     }
                     else
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알리미 이용 등록에 실패하였습니다." message:nil delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                         [alert show];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountFail" object:nil];
                     }
                     
                 }];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알리미 서비스 등록에 실패하였습니다." message:nil delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                [alert show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountFail" object:nil];
            }
        }];
    }
    
}

-(void)unRegisterUser
{
    UINavigationController *navigationController = (UINavigationController *)[UIApplication sharedApplication].windows.firstObject.rootViewController;
    
    [[PushManager defaultManager] unregisterUser:navigationController.viewControllers[0] completionHandler:^(BOOL success) {
        if (success) {
            [[PushManager defaultManager] unregisterService:[navigationController.viewControllers lastObject] completionHandler:^(BOOL success) {
                if (success) {
                    [IBConfigDefaults setObject:@"NO" forKey:@"RenewalAccountIpns"];
                    //사용자 해제 완료 시 noti
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountSuccess" object:nil];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알리미 서비스 해제에 실패하였습니다." message:nil delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                    [alert show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountFail" object:nil];
                }
            }];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알리미 사용자 삭제에 실패하였습니다." message:nil delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [alert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountFail" object:nil];
        }
    }];
}

@end
