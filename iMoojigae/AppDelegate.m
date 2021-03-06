//
//  AppDelegate.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"
#import "LoginToService.h"
#import "ArticleView.h"
#import "SetTokenStorage.h"
@import GoogleMobileAds;

@interface AppDelegate () <LoginToServiceDelegate>
{
	NSDictionary *dUserInfo; //To storage the push data
}
@property (nonatomic, strong) LoginToService *m_login;
@property (nonatomic, strong) UNUserNotificationCenter *center;
@end

@implementation AppDelegate

@synthesize strDevice;
@synthesize strUserId;
@synthesize switchPush;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
//	[[UIApplication sharedApplication] cancelAllLocalNotifications];
/*
	// Register for Remote Notifications
	BOOL pushEnable = NO;
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
		pushEnable = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
	}
*/
	// 푸시 아이디를 달라고 폰에다가 요청하는 함수
    self.center = [UNUserNotificationCenter currentNotificationCenter];
    self.center.delegate = self;
    [self.center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
      if ( !error ) {
          // required to get the app to do anything at all about push notifications
          dispatch_async(dispatch_get_main_queue(), ^{
              [[UIApplication sharedApplication] registerForRemoteNotifications];
              NSLog( @"Push registration success." );
          });
      } else {
          NSLog( @"Push registration FAILED" );
          NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
          NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
      }
      }];

	// 앱이 완전히 종료된 상태에서 푸쉬 알림을 받으면 해당 푸쉬 알림 메시지가 launchOptions 에 포함되어서 실행된다.
	if (launchOptions) {
		dUserInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dUserInfo) {
			[self moveToViewController];
		}
	}
	
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    strDevice = [token copy];
	NSLog(@"converted device Device Token (%@)", strDevice);
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPath = [documentsDirectory stringByAppendingPathComponent:@"token.dat"];
    ////NSLog(@"myPath = %@", myPath);
    SetTokenStorage *storage = [[SetTokenStorage alloc] init];
    storage.token = strDevice;
    [NSKeyedArchiver archiveRootObject:storage toFile:myPath];
    
    self.m_login = [[LoginToService alloc] init];
    self.m_login.delegate = self;
    [self.m_login PushRegister];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Did Fail to Register for Remote Notifications");
	NSLog(@"%@, %@", error, error.localizedDescription);
	
}
/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo  {
	NSLog(@"remote notification: %@",[userInfo description]);
	
	if (userInfo) {
		NSLog(@"%@",userInfo);
		dUserInfo = userInfo;
	}
}
*/

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
   {
    if (response.notification.request.content.userInfo) {
        NSLog(@"%@", response.notification.request.content.userInfo);
        dUserInfo = response.notification.request.content.userInfo;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"applicationDidBecomeActive");
	//Data from the push.
	if (dUserInfo != nil) {
		[self moveToViewController];
	}
}

-(void)moveToViewController {
	//Do whatever you need
	NSLog(@"applicationDidBecomeActive with UserInfo");
	
	NSString *boardId;
	NSString *boardNo;
	NSString *boardName;
	if ([dUserInfo objectForKey:@"link"]) {
		boardId = [dUserInfo objectForKey:@"boardId"];
		boardNo = [dUserInfo objectForKey:@"boardNo"];
		boardName = [dUserInfo objectForKey:@"boardName"];
	} else {
		dUserInfo = nil;
		return;
	}
	
	if ([boardId isEqualToString:@""] || [boardNo isEqualToString:@""]) {
		dUserInfo = nil;
		return;
	}
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
	
	ArticleView *viewController = (ArticleView*)[storyboard instantiateViewControllerWithIdentifier:@"ArticleView"];
	if (viewController != nil) {
		viewController.m_strTitle = @"";
		viewController.m_strDate = @"";
		viewController.m_strName = @"";
		viewController.m_boardId = boardId;
		viewController.m_boardNo = boardNo;
		viewController.m_boardName = boardName;
        viewController.m_row = -1;
		viewController.delegate = nil;
	} else {
		return;
	}
	
	//		[self.window.rootViewController presentViewController:viewController animated:YES completion:NULL];
	
	UINavigationController *navController = (UINavigationController*)self.window.rootViewController;
	if (navController != nil) {
		[navController pushViewController:viewController animated:YES];
	}
	dUserInfo = nil;
}

@end
