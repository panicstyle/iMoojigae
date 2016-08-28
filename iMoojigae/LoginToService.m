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
    
	NSLog(@"LoginToService...");
	NSLog(@"id = %@", userid);
	NSLog(@"pwd = %@", userpwd);
	
	if (userid == nil || [userid isEqualToString:@""] || userpwd == nil || [userpwd isEqualToString:@""]) {
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
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"http://121.134.211.159/MLogin.do" forHTTPHeaderField:@"Referer"];
 
	NSString *uid = [userid stringByAddingPercentEscapesUsingEncoding:g_encodingOption ];
    NSString *upwd = [userpwd stringByAddingPercentEscapesUsingEncoding:g_encodingOption];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"userId=%@&userPw=%@&boardId=&boardNo=&page=1&categoryId=-1&returnURI=&returnBoardNo=&beforeCommand=&command=LOGIN", uid, upwd]  dataUsingEncoding:g_encodingOption]];
 
    [request setHTTPBody:body];
 
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:g_encodingOption];
    
    NSLog(@"returnString = [%@]", returnString);
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
 
    if (returnString && [returnString rangeOfString:@"<script language=javascript>moveTop()</script>"].location != NSNotFound) {
        return TRUE;
    } else {
        return FALSE;
    }	

    return FALSE;
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
