//
//  LoginToService.m
//  iGongdong
//
//  Created by Panicstyle on 10. 10. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginToService.h"
#import "env.h"
#import "SetStorage.h"
#import "SetTokenStorage.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "HttpSessionRequest.h"

@interface LoginToService () <HttpSessionRequestDelegate>
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
@end

@implementation LoginToService

- (void)LoginToService
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *myPath = [documentsDirectory stringByAppendingPathComponent:@"set.dat"];
	
	SetStorage *storage = (SetStorage *)[NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
	
    userid = storage.userid;
    userpwd = storage.userpwd;
	switchPush = storage.switchPush;
    
	NSLog(@"LoginToService...");
	NSLog(@"id = %@", userid);
	NSLog(@"pwd = %@", userpwd);
	NSLog(@"push = %@", switchPush);
	
	if (userid == nil || [userid isEqualToString:@""] || userpwd == nil || [userpwd isEqualToString:@""]) {
        NSLog(@"userid and userpw is not set");
        return;
	}
    
    NSLog(@"Before Logout");
//   [self Logout];
    NSLog(@"After Logout");
	
	NSString *url = [NSString stringWithFormat:@"%@/login-process.do", WWW_SERVER];
    NSString *strReferer = [NSString stringWithFormat:@"%@/MLogin.do", WWW_SERVER];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	NSString *uid = [userid stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *upwd = [userpwd stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *postString = [NSString stringWithFormat:@"userId=%@&userPw=%@&boardId=&boardNo=&page=1&categoryId=-1&returnURI=&returnBoardNo=&beforeCommand=&command=LOGIN", uid, upwd];
 
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    self.httpSessionRequest.httpMethod = @"POST";
    self.httpSessionRequest.tag = LOGIN_TO_SERVER;
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValueString:postString withReferer:strReferer];
}

- (void)PushRegister
{
	AppDelegate *getVar = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *tokenDevice = getVar.strDevice;
	NSString *userId = getVar.strUserId;
	NSNumber *nPushYN = getVar.switchPush;
	NSString *strPushYN = @"Y";

    if (userId == nil) {
        NSLog(@"PushRegister fail. userId is nil\n");
        return;
    }
    
    if (tokenDevice == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPath = [documentsDirectory stringByAppendingPathComponent:@"token.dat"];
        
        SetTokenStorage *storage = (SetTokenStorage *)[NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
        
        if (storage == nil) {
            tokenDevice = nil;
        } else {
            tokenDevice = storage.token;
            getVar.strDevice = tokenDevice;
        }
        
        if (tokenDevice == nil) {
            NSLog(@"PushRegister fail. tokenDevice or userId is nil\n");
            return;
        }
    }
    
	if ([nPushYN boolValue] == true) {
		strPushYN = @"Y";
	} else {
		strPushYN = @"N";
	}
	
	NSLog(@"Device : %@", tokenDevice);
	 
	NSString *url;
	url = [NSString stringWithFormat:@"%@/push/PushRegister", PUSH_SERVER];
	
	NSLog(@"URL : %@", url);
	
	NSString *postString = [NSString stringWithFormat:@"{\"type\":\"iOS\",\"push_yn\":\"%@\",\"uuid\":\"%@\",\"userid\":\"%@\"}", strPushYN, tokenDevice, userId];
 
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    self.httpSessionRequest.httpMethod = @"POST";
    self.httpSessionRequest.tag = PUSH_REGISTER;
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValueString:postString withReferer:@""];
}

- (void)PushUpdate
{
	AppDelegate *getVar = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *tokenDevice = getVar.strDevice;
	NSString *userId = getVar.strUserId;
	NSNumber *nPushYN = getVar.switchPush;
	NSString *strPushYN = @"Y";
	
    if (userId == nil) {
        NSLog(@"PushRegister fail. userId is nil\n");
        return;
    }
    
    if (tokenDevice == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPath = [documentsDirectory stringByAppendingPathComponent:@"token.dat"];
        
        SetTokenStorage *storage = (SetTokenStorage *)[NSKeyedUnarchiver unarchiveObjectWithFile:myPath];

        if (storage == nil) {
            tokenDevice = nil;
        } else {
            tokenDevice = storage.token;
            getVar.strDevice = tokenDevice;
        }

        tokenDevice = storage.token;
        getVar.strDevice = tokenDevice;
        if (tokenDevice == nil) {
            NSLog(@"PushRegister fail. tokenDevice is nil\n");
            return;
        }
    }
	
	if ([nPushYN boolValue] == true) {
		strPushYN = @"Y";
	} else {
		strPushYN = @"N";
	}
	
	NSLog(@"Device : %@", tokenDevice);
	
	NSString *url;
	url = [NSString stringWithFormat:@"%@/push/PushRegisterUpdate", PUSH_SERVER];
	
	NSLog(@"URL : %@", url);
	
	NSString *postString = [NSString stringWithFormat:@"{\"type\":\"iOS\",\"push_yn\":\"%@\",\"uuid\":\"%@\",\"userid\":\"%@\"}", strPushYN, tokenDevice, userId];
 
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    self.httpSessionRequest.httpMethod = @"POST";
    self.httpSessionRequest.tag = PUSH_UPDATER;
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValueString:postString withReferer:@""];
}

- (void)Logout
{
	NSString *url;
	url = [NSString stringWithFormat:@"%@/logout.do", WWW_SERVER];
    
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    self.httpSessionRequest.httpMethod = @"GET";
    self.httpSessionRequest.tag = LOGOUT_TO_SERVER;
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValueString:@"" withReferer:@""];
}

#pragma mark - HttpSessionRequestDelegate

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(loginToService:withFail:)] == YES)
        [self.delegate loginToService:self withFail:@""];
}

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLodingData:(NSData *)data
{
    if (httpSessionRequest.tag == LOGIN_TO_SERVER) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"returnString = [%@]", returnString);
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (returnString != nil && [returnString rangeOfString:@"<script language=javascript>moveTop()</script>"].location != NSNotFound) {
            AppDelegate *getVar = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            getVar.strUserId = userid;
            if (switchPush == nil) {
                switchPush = [NSNumber numberWithBool:true];
            }
            getVar.switchPush = switchPush;
            
            if ([self.delegate respondsToSelector:@selector(loginToService:withSuccess:)] == YES)
                [self.delegate loginToService:self withSuccess:@""];
            return;
        } else {
            if ([Utils numberOfMatches:returnString regex:@"<b>시스템 메세지입니다</b>"] > 0) {
                if ([self.delegate respondsToSelector:@selector(loginToService:withFail:)] == YES)
                    [self.delegate loginToService:self withFail:@""];
            } else {
                if ([self.delegate respondsToSelector:@selector(loginToService:withSuccess:)] == YES)
                    [self.delegate loginToService:self withSuccess:@""];
            }
            return;
        }
    } else if (httpSessionRequest.tag == PUSH_REGISTER) {
        
    }
}
@end

