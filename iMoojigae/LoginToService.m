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
//#import "HTTPRequest.h"

@implementation LoginToService

//@synthesize respData;
//@synthesize target;
//@synthesize selector;


- (BOOL)LoginToService
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
        return FALSE;
	}
    
    NSLog(@"Before Logout");
   [self Logout];
    NSLog(@"After Logout");
//    [self GetMain];
	
	NSString *url;
	url = [NSString stringWithFormat:@"%@/login-process.do", WWW_SERVER];
	////NSLog(@"url = [%@]", url);
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *strReferer = [NSString stringWithFormat:@"%@/MLogin.do", WWW_SERVER];
	
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request addValue:strReferer forHTTPHeaderField:@"Referer"];
 
	NSString *uid = [userid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *upwd = [userpwd stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"userId=%@&userPw=%@&boardId=&boardNo=&page=1&categoryId=-1&returnURI=&returnBoardNo=&beforeCommand=&command=LOGIN", uid, upwd]  dataUsingEncoding:NSUTF8StringEncoding]];
 
    [request setHTTPBody:body];
 
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"returnString = [%@]", returnString);
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
    if (returnString && [returnString rangeOfString:@"<script language=javascript>moveTop()</script>"].location != NSNotFound) {
		AppDelegate *getVar = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		getVar.strUserId = userid;
		if (switchPush == nil) {
			switchPush = [NSNumber numberWithBool:true];
		}
		getVar.switchPush = switchPush;
		
        return TRUE;
    } else {
		if ([Utils numberOfMatches:returnString regex:@"<b>시스템 메세지입니다</b>"] > 0) {
			return FALSE;
		} else {
			return TRUE;
		}
    }

    return FALSE;
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
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"{\"type\":\"iOS\",\"push_yn\":\"%@\",\"uuid\":\"%@\",\"userid\":\"%@\"}", strPushYN, tokenDevice, userId]  dataUsingEncoding:NSUTF8StringEncoding]];
 
	[request setHTTPBody:body];

	[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
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
	url = [NSString stringWithFormat:@"%@/push/PushRegisterUpdate", PUSH_SERVER];
	
	NSLog(@"URL : %@", url);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"{\"type\":\"iOS\",\"push_yn\":\"%@\",\"uuid\":\"%@\",\"userid\":\"%@\"}", strPushYN, tokenDevice, userId]  dataUsingEncoding:NSUTF8StringEncoding]];
 
	[request setHTTPBody:body];
	
	[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//	NSLog(@"returnString = [%@]", returnString);
}

- (void)Logout
{
	NSString *url;
	url = [NSString stringWithFormat:@"%@/logout.do", WWW_SERVER];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSMutableData *body = [NSMutableData data];
    [request setHTTPBody:body];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

- (void)GetMain
{
	NSString *url;
	url = [NSString stringWithFormat:@"%@/MLogin.do", WWW_SERVER];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSMutableData *body = [NSMutableData data];
    [request setHTTPBody:body];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

/*
- (void)didReceiveFinished:(NSString *)result
{
	NSString *resultStr;
	
	resultStr = [NSString stringWithString:result];
	
	NSLog(@"login result = [%@]", resultStr);
	
    if(target)
    {
        [target performSelector:selector withObject:resultStr];
    }
    [httpRequest release];
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector
{
    // 데이터 수신이 완료된 이후에 호출될 메서드의 정보를 담고 있는 셀렉터 설정
    self.target = aTarget;
    self.selector = aSelector;
}
*/

@end
