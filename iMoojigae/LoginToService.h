//
//  LoginToService.h
//  iGongdong
//
//  Created by Panicstyle on 10. 10. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginToService;
@protocol LoginToServiceDelegate <NSObject>
@optional

- (void) loginToService:(LoginToService *)loginToService LoginWithFail:(NSString *)result;

- (void) loginToService:(LoginToService *)loginToService LoginWithSuccess:(NSString *)result;

- (void) loginToService:(LoginToService *)loginToService LogoutWithFail:(NSString *)result;

- (void) loginToService:(LoginToService *)loginToService LogoutWithSuccess:(NSString *)result;

- (void) loginToService:(LoginToService *)loginToService PushWithFail:(NSString *)result;

- (void) loginToService:(LoginToService *)loginToService PushWithSuccess:(NSString *)result;


@end

@interface LoginToService : NSObject {
	NSString *userid;
    NSString *userpwd;
	NSNumber *switchPush;
}
- (void)LoginToService;
- (void)Logout;
- (void)PushRegister;
- (void)PushUpdate;

@property (nonatomic, assign) id <LoginToServiceDelegate> delegate;
@property (nonatomic, assign) int tag;

@end
