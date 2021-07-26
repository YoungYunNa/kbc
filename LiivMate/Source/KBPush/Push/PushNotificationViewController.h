//
//  PushNotificationViewController.h
//

#import <UIKit/UIKit.h>
#import <MPushLibrary/MPushLibrary.h>

@class PushDefaultNotification;
@interface PushNotificationViewController : MDViewController <PushManagerDelegate>

- (id)initWithNotification:(PushDefaultNotification *)notification;
- (IBAction)didTouchPushTest:(id)sender;

@end
