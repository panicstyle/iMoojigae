//
//  BoardData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "BoardData.h"
#import "env.h"

@interface BoardData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
}
@end

@implementation BoardData
@synthesize m_strCommNo;
@synthesize m_strRecent;
@synthesize m_arrayItems;
@synthesize target;
@synthesize selector;

- (void)fetchItems
{
	m_arrayItems = [[NSMutableArray alloc] init];
	
	[self fetchItems2];
}

- (void)fetchItems2
{
	NSLog(@"fetchItems2");
	m_receiveData = [[NSMutableData alloc] init];

	NSString *url;
	url = [NSString stringWithFormat:@"%@/board-api-menu.do?comm=%@", WWW_SERVER, m_strCommNo];
	
	NSLog(@"query = [%@]", url);
	
	m_connection = [[NSURLConnection alloc]
				  initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
	NSLog(@"fetchItems 3");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"didReceiveData");
	[m_receiveData appendData:data];
	NSLog(@"didReceiveData receiveData=[%lu], data=[%lu]", (unsigned long)[m_receiveData length], (unsigned long)[data length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"ListView receiveData Size = [%lu]", (unsigned long)[m_receiveData length]);
	
//	NSString *html = [[NSString alloc] initWithData:m_receiveData encoding:NSUTF8StringEncoding];
//	NSLog(@"html=[%@]", html);
	
	NSError *localError = nil;
	NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:m_receiveData options:0 error:&localError];
	
	if (localError != nil) {
		return;
	}
	
	m_strRecent = [parsedObject valueForKey:@"recent"];
	NSLog(@"m_strRecent %@", m_strRecent);
	
	NSString *strNew = [parsedObject valueForKey:@"new"];
	NSLog(@"strNew %@", strNew);

	NSArray *jsonItems = [parsedObject valueForKey:@"menu"];
	
	NSMutableDictionary *currItem;
	
	for (int i = 0; i < [jsonItems count]; i++) {
		NSDictionary *jsonItem = [jsonItems objectAtIndex:i];
		
		currItem = [[NSMutableDictionary alloc] init];
		
		// title
		NSString *strTitle = [jsonItem valueForKey:@"title"];
		[currItem setValue:strTitle forKey:@"title"];

		// type
		NSString *strType = [jsonItem valueForKey:@"type"];
		[currItem setValue:strType forKey:@"type"];

		// boardId
		NSString *strBoardId = [jsonItem valueForKey:@"boardId"];
		[currItem setValue:strBoardId forKey:@"boardId"];
		
		[m_arrayItems addObject:currItem];
	}
	
	// icon_new 찾기. 게시판 이름을 찾아서 그 다음에 icon_new가 있는지 확인
	for (int i = 0; i < [m_arrayItems count]; i++) {
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:i];
		NSString *link = [item valueForKey:@"boardId"];
		link = [NSString stringWithFormat:@"[%@]", link];

		if ([strNew rangeOfString:link].location != NSNotFound) {
			// strNew 최근글이 포함된 게시판 목록 리스트에서 해당 게시판 아이가 있는지 찾고, 있으면 N 아이콘을 표시한다.
			[item setValue:[NSNumber numberWithInt:1] forKey:@"isNew"];
		} else {
			[item setValue:[NSNumber numberWithInt:0] forKey:@"isNew"];
		}
	}
	
	[target performSelector:selector withObject:nil afterDelay:0];
}

@end
