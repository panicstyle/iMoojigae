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

@interface AppDelegate ()
{
	NSDictionary *dUserInfo; //To storage the push data
}
@end

@implementation AppDelegate

@synthesize strDevice;
@synthesize strUserId;
@synthesize switchPush;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo  {
	NSLog(@"remote notification: %@",[userInfo description]);
	
	if (userInfo) {
		NSLog(@"%@",userInfo);
		dUserInfo = userInfo;
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"applicationDidBecomeActive");
	//Data from the push.
	if (dUserInfo != nil)
	{
		//Do whatever you need
		NSLog(@"applicationDidBecomeActive with UserInfo");
		
		NSString *strLink;
		if ([dUserInfo objectForKey:@"link"]) {
			strLink = [dUserInfo objectForKey:@"link"];
		} else {
			return;
		}
		
		if ([strLink isEqualToString:@""]) {
			return;
		}
		
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
		
		ArticleView *viewController = (ArticleView*)[storyboard instantiateViewControllerWithIdentifier:@"ArticleView"];
		if (viewController != nil) {
			viewController.m_strTitle = @"";
			viewController.m_strDate = @"";
			viewController.m_strName = @"";
			viewController.m_strLink = strLink;
			viewController.target = nil;
			viewController.selector = nil;
		} else {
			return;
		}
		
//		[self.window.rootViewController presentViewController:viewController animated:YES completion:NULL];
		
		UINavigationController *navController = (UINavigationController*)self.window.rootViewController;
		if (navController != nil) {
			[navController pushViewController:viewController animated:YES];
		}
	}
}

@end
