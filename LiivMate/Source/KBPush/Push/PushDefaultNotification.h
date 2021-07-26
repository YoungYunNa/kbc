//
//  PushNotification.h
//  SeoulCourse.iOS
//
//  Created by ProgDesigner on 2015. 3. 18..
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PushNotificationCategory ){
    PushNotificationCagegoryUnknown = -1,
    PushNotificationCategoryDefault = 0,
    PushNotificationCategoryWebPage = 1,
    PushNotificationCategoryVideo = 2,
    PushNotificationCategoryImage = 3,
    PushNotificationCategorySecurity = 4
};

@class PushDefaultNotification;

typedef void(^PushNotificationExtLoadHandler)(BOOL success, PushDefaultNotification *notification, NSError *error);

@interface PushDefaultNotification : NSObject

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSArray *extComponents;
@property (nonatomic, readonly) NSDictionary *aps;
@property (nonatomic, readonly) NSDictionary *mps;
@property (nonatomic, readonly) NSString *ext;
@property (nonatomic, readonly) NSURL *requestURL;
@property (nonatomic, readonly) BOOL hasExtURL;
@property (nonatomic, readonly) PushNotificationCategory category;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSURL *contentURL;
@property (nonatomic, readonly) BOOL isWebContent;
@property (nonatomic, readonly) BOOL isTemplateContent;

- (id)initWithUserInfo:(NSDictionary *)userInfo;

- (void)load:(id)sender completionHandler:(PushNotificationExtLoadHandler)completionHandler;

@end

