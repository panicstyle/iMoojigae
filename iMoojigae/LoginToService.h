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

- (void) loginToService:(LoginToService *)loginToService withFail:(NSString *)result;

- (void) loginToService:(LoginToService *)loginToService withSuccess:(NSString *)result;

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
