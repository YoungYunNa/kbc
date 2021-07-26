//
//  SplashScreenManager.h
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 04/11/2019.
//  Copyright © 2019 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define KEY_IMG_TOP             @"top"
#define KEY_IMG_MIDDLE          @"middle"
#define KEY_BG_COLOR            @"color"
#define KEY_VERSION             @"ver"
#define DATA_FILENAME_FORMAT    @"splash_%@.plist"

@interface SplashScreenManager : NSObject

+ (NSDictionary *)getSplashData:(NSString *)version;
+ (void)setSplashDataToScreen:(UIView *)viewSplash slogan:(UIImageView *)imgSlogan main:(UIImageView *)imgMain settingData:(NSDictionary *)data;
+ (void)downloadData:(NSDictionary *)splashData;

@end

@interface LaunchScreen : UIView
- (UIView *)getLaunchScreen;
@end

NS_ASSUME_NONNULL_END
