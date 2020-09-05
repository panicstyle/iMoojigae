//
//  BoardData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "BoardData.h"
#import "env.h"
#import "HttpSessionRequest.h"

@interface BoardData () <HttpSessionRequestDelegate>
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
@end

@implementation BoardData

- (void)fetchItemsWithCommNo:(NSString *)strCommNo
{
    NSString *url = [NSString stringWithFormat:@"%@/board-api-menu.do", WWW_SERVER];
    NSLog(@"query = [%@]", url);
    
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strCommNo, @"comm", nil];
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValues:dic];
}

#pragma mark -
#pragma mark HttpSessionRequestDelegate

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest withError:(NSError *)error
{
}

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLodingData:(NSData *)data
{
	NSError *localError = nil;
	NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
	
	if (localError != nil) {
		return;
	}
    
    NSMutableArray *arrayItems = [[NSMutableArray alloc] init];

	NSString *strRecent = [parsedObject valueForKey:@"recent"];
	NSLog(@"strRecent %@", strRecent);
	
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
		
		[arrayItems addObject:currItem];
	}
	
	// icon_new 찾기. 게시판 이름을 찾아서 그 다음에 icon_new가 있는지 확인
	for (int i = 0; i < [arrayItems count]; i++) {
		NSMutableDictionary *item = [arrayItems objectAtIndex:i];
		NSString *link = [item valueForKey:@"boardId"];
		link = [NSString stringWithFormat:@"[%@]", link];

		if ([strNew rangeOfString:link].location != NSNotFound) {
			// strNew 최근글이 포함된 게시판 목록 리스트에서 해당 게시판 아이가 있는지 찾고, 있으면 N 아이콘을 표시한다.
			[item setValue:[NSNumber numberWithInt:1] forKey:@"isNew"];
		} else {
			[item setValue:[NSNumber numberWithInt:0] forKey:@"isNew"];
		}
	}
        
    if ([self.delegate respondsToSelector:@selector(boardData:didFinishLodingData:withRecent:)] == YES)
        [self.delegate boardData:self didFinishLodingData:arrayItems withRecent:strRecent];
}

@end
