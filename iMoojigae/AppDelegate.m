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

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize strDevice;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
//	[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
//	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	// Register for Remote Notifications
	BOOL pushEnable = NO;
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
		pushEnable = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
	} else {
		UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
		pushEnable = types & UIRemoteNotificationTypeAlert;
	}
	
	// 푸시 아이디를 달라고 폰에다가 요청하는 함수
//	UIApplication *application = [UIApplication sharedApplication];
	if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
		NSLog(@"upper ios8");
		// iOS 8 Notifications
		[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
		[application registerForRemoteNotifications];
	} else {
		NSLog(@"down ios8");
		// iOS < 8 Notifications
		[application registerForRemoteNotificationTypes:
		 (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
	}

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

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
	strDevice = [[[[deviceToken description]
							stringByReplacingOccurrencesOfString:@"<"withString:@""]
						   stringByReplacingOccurrencesOfString:@">" withString:@""]
						  stringByReplacingOccurrencesOfString: @" " withString: @""];
	NSLog(@"converted device Device Token (%@)", strDevice);
	
	LoginToService *login = [[LoginToService alloc] init];
	[login PushRegister];

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
		
		if ([userInfo objectForKey:@"aps"]) {
			if([[userInfo objectForKey:@"aps"] objectForKey:@"badge"]) {
				[UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badge"] intValue];
			}
		}
	}
}
*/
@end
