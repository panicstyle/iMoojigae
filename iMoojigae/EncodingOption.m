//
//  EncodingOption.m
//  iMoojigae
//
//  Created by dykim on 2016. 8. 28..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "EncodingOption.h"
#import "env.h"

@implementation EncodingOption

- (BOOL)GetEncodingOption
{
	NSString *url;
	url = [NSString stringWithFormat:@"%@/encoding.info", WWW_SERVER];
	////NSLog(@"url = [%@]", url);
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
	NSError *requestError;
	NSURLResponse *urlResponse = nil;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
	if (returnData == nil) {
		g_encodingOption = NSUTF8StringEncoding;
		return FALSE;
	} else {
		NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
		
		NSLog(@"returnString = [%@]", returnString);
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		if (returnString && [returnString length] < 10) {
			if ([returnString rangeOfString:@"euc-kr"].location != NSNotFound) {
				g_encodingOption = 0x80000000 + kCFStringEncodingEUC_KR;
			} else {
				g_encodingOption = NSUTF8StringEncoding;
			}
			return TRUE;
		} else {
			g_encodingOption = NSUTF8StringEncoding;
			return FALSE;
		}
	}
}

@end
