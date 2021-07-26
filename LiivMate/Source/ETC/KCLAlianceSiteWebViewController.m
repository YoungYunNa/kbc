//
//  KCLAlianceSiteWebViewController.m
//  LiivMate
//
//  Created by KB on 4/21/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

#import "KCLAlianceSiteWebViewController.h"

@interface KCLAlianceSiteWebViewController ()

@end

@implementation KCLAlianceSiteWebViewController

- (void)setFirstOpenUrl:(NSString *)firstOpenUrl
{
    if([AppInfo userInfo].cId.length && [firstOpenUrl rangeOfString:@"cID="].location == NSNotFound)
    {
        if ([firstOpenUrl rangeOfString:@"?"].location == NSNotFound)
            firstOpenUrl = [firstOpenUrl stringByAppendingFormat:@"?cID=%@", [AppInfo userInfo].cId];
        else
            firstOpenUrl = [firstOpenUrl stringByAppendingFormat:@"&cID=%@", [AppInfo userInfo].cId];
    }
    [super setFirstOpenUrl:firstOpenUrl];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
