//
//  RecentData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "RecentData.h"
#import "env.h"
#import "LoginToService.h"

@interface RecentData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
	BOOL m_isConn;
	BOOL m_isLogin;
	LoginToService *m_login;
}
@end

@implementation RecentData

@synthesize m_strRecent;
@synthesize m_strType;
@synthesize m_arrayItems;
@synthesize target;
@synthesize selector;

- (void)fetchItems
{
	m_arrayItems = [[NSMutableArray alloc] init];

	NSString *url;
    NSString *doLink;
    if ([m_strType isEqualToString:@"list"]) {
        doLink = @"board-api-recent.do";
    } else {
        doLink = @"board-api-recent-memo.do";
    }
    
	url = [NSString stringWithFormat:@"%@/%@?part=index&rid=50&pid=%@", WWW_SERVER, doLink, m_strRecent];

	NSLog(@"fetchItems");
	m_receiveData = [[NSMutableData alloc] init];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"gzip,deflate,sxdch" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"ko,en-US;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
	[request addValue:@"windows-949,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
	
	NSData *body = [[NSData alloc] initWithData:[@"" dataUsingEncoding:g_encodingOption]];
	
	[request setHTTPBody:body];
	
	m_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	NSLog(@"fetchItems 2");
	m_isConn = TRUE;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"didReceiveData");
	if (m_isConn) {
		[m_receiveData appendData:data];
		NSLog(@"didReceiveData receiveData=[%lu], data=[%lu]", (unsigned long)[m_receiveData length], (unsigned long)[data length]);
	} else {
		NSLog(@"connect finish");
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	m_isConn = FALSE;
	NSLog(@"ListView receiveData Size = [%lu]", (unsigned long)[m_receiveData length]);
	
	if ([m_receiveData length] < 1800) {
		[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_AUTH_FAIL] afterDelay:0];
	}
	
//	NSString *str = [[NSString alloc] initWithData:m_receiveData encoding:g_encodingOption];

	NSError *localError = nil;
	NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:m_receiveData options:0 error:&localError];
	
	if (localError != nil) {
		return;
	}
	
	NSArray *jsonItems = [parsedObject valueForKey:@"item"];
	
	NSMutableDictionary *currItem;
	
	for (int i = 0; i < [jsonItems count]; i++) {
		NSDictionary *jsonItem = [jsonItems objectAtIndex:i];
		
		currItem = [[NSMutableDictionary alloc] init];
		
		// boardNo
		NSString *boardNo = [jsonItem valueForKey:@"boardNo"];
		[currItem setValue:boardNo forKey:@"boardNo"];
		
		// isNew
		NSString *isNew = [jsonItem valueForKey:@"recentArticle"];
		if ([isNew isEqualToString:@"Y"]) {
			[currItem setValue:[NSNumber numberWithInt:1] forKey:@"isNew"];
		} else {
			[currItem setValue:[NSNumber numberWithInt:0] forKey:@"isNew"];
		}
		
		// isUpdated
		NSString *isUpdated = [jsonItem valueForKey:@"updatedArticle"];
		if ([isUpdated isEqualToString:@"Y"]) {
			[currItem setValue:[NSNumber numberWithInt:1] forKey:@"isUpdated"];
		} else {
			[currItem setValue:[NSNumber numberWithInt:0] forKey:@"isUpdated"];
		}
		
		// 답변글 여부
		[currItem setValue:[jsonItem valueForKey:@"boardDep"] forKey:@"isRe"];
		
		// boardId
		[currItem setValue:[jsonItem valueForKey:@"boardId"] forKey:@"boardId"];
		// boardName
		[currItem setValue:[jsonItem valueForKey:@"boardName"] forKey:@"boardName"];
		
		// subject
		NSString *subject = [jsonItem valueForKey:@"boardTitle"];
		subject = [subject stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		subject = [subject stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
		subject = [subject stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
		subject = [subject stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
		subject = [subject stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
		[currItem setValue:[NSString stringWithString:subject] forKey:@"subject"];
		
		// writer
		[currItem setValue:[jsonItem valueForKey:@"userNick"] forKey:@"name"];
		
		// Comment
		[currItem setValue:[jsonItem valueForKey:@"boardMemo_cnt"] forKey:@"comment"];
		
		// Hit
		[currItem setValue:[jsonItem valueForKey:@"boardRead_cnt"] forKey:@"hit"];
		
		// date
		[currItem setValue:[jsonItem valueForKey:@"boardRegister_dt"] forKey:@"date"];
		
		[currItem setValue:[NSNumber numberWithFloat:77.0f] forKey:@"height"];
		
		[currItem setValue:[NSNumber numberWithFloat:77.0f] forKey:@"height"];

		[m_arrayItems addObject:currItem];
	}
	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
}

@end
