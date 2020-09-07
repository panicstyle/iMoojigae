//
//  AppDelegate.h
//  iMoojigae
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>  

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *strDevice;
@property (strong, nonatomic) NSString *strUserId;
@property (strong, nonatomic) NSNumber *switchPush;

-(void)moveToViewController;
@end

