//
//  SplashScreenManager.m
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 04/11/2019.
//  Copyright © 2019 KBCard. All rights reserved.
//

#import "SplashScreenManager.h"

@implementation SplashScreenManager

+ (NSDictionary *)getSplashData:(NSString *)version
{
    if (nilCheck(version)) return nil;
    
    // 경로에 파일이 존재 하는가?
    NSString * filePath = [DOCUMENT_PATH stringByAppendingPathComponent:[NSString stringWithFormat:DATA_FILENAME_FORMAT, version]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) return nil;
        
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

+ (void)setSplashDataToScreen:(UIView *)viewSplash
                       slogan:(UIImageView *)imgSloganView
                         main:(UIImageView *)imgMainView
                  settingData:(NSDictionary *)data
{
    NSData * imgMiddleData = data[KEY_IMG_MIDDLE];
    NSData * imgtopData = data[KEY_IMG_TOP];
    NSString * strColor = data[KEY_BG_COLOR];
    
    UIImage * imgMiddle = [UIImage imageWithData:imgMiddleData];
    UIImage * imgTop = [UIImage imageWithData:imgtopData];
    
    if (imgMiddle && imgTop) {
        imgMainView.image = imgMiddle;
        imgSloganView.image = imgTop;
    }
    
    if (!nilCheck(strColor)) {
        UIColor * color = [EtcUtil colorWithHexString:strColor];
        viewSplash.backgroundColor = color;
    }
}

+ (void)downloadData:(NSDictionary *)splashData
{
    NSString * scale = [UIScreen mainScreen].scale == 3.0f ? @"3x" : @"2x";
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     dispatch_async(dispatch_get_main_queue(), ^{
        
         @try {
             NSData * topData = [NSData dataWithContentsOfURL:[NSURL URLWithString:splashData[@"imgs"][scale][KEY_IMG_TOP]] options:NSDataReadingUncached error:nil];
             NSData * middleData = [NSData dataWithContentsOfURL:[NSURL URLWithString:splashData[@"imgs"][scale][KEY_IMG_MIDDLE]] options:NSDataReadingUncached error:nil];
             NSString *strColor = splashData[KEY_BG_COLOR];
             NSString *version = splashData[KEY_VERSION];
             
             if (topData && middleData) {
                 
                 NSMutableDictionary * fileData = [NSMutableDictionary dictionary];
                 
                 [fileData setObject:topData forKey:KEY_IMG_TOP];
                 [fileData setObject:middleData forKey:KEY_IMG_MIDDLE];
                 [fileData setObject:strColor forKey:KEY_BG_COLOR];
                 
                 NSString * filePath = [DOCUMENT_PATH stringByAppendingPathComponent:[NSString stringWithFormat:DATA_FILENAME_FORMAT, version]];
                 if([fileData writeToFile:filePath atomically:YES]) {
                     [UserDefaults sharedDefaults].splashVer = version;
                     [[NSNotificationCenter defaultCenter] postNotificationName:SplashImageDownloadNotification object:nil]; // splash 다운로드 완료 노티피케이션
                 }
             }
         } @catch (NSException *exception) {
             
         } @finally {
             
         }
    });
}

@end

@interface LaunchScreen( ){
    __weak IBOutlet UIImageView *_imgSloganView;
    __weak IBOutlet UIImageView *_imgMainView;
}

@end

@implementation LaunchScreen

- (UIView *)getLaunchScreen
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:nil options:nil];
    LaunchScreen * view = (LaunchScreen *)nibViews.firstObject;
    
    NSDictionary * splashData = [SplashScreenManager getSplashData:[UserDefaults sharedDefaults].splashVer];
    
    if (splashData) {
        // 스플래시 Data셋팅
       [SplashScreenManager setSplashDataToScreen:view
                                           slogan:view->_imgSloganView
                                             main:view->_imgMainView
                                      settingData:splashData];
    }
    
    return view;
}

@end
