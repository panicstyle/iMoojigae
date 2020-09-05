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
#import "NSString+HTML.h"
#import "DBInterface.h"
#import "HttpSessionRequest.h"

@interface RecentData ()  <HttpSessionRequestDelegate>
{
	BOOL m_isLogin;
	LoginToService *m_login;
}
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
@end

@implementation RecentData

- (void)fetchItemsWithType:(NSString *)strType withRecent:(NSString *)strRecent
{
    NSString *doLink;
    if ([strType isEqualToString:@"list"]) {
        doLink = @"board-api-recent.do";
    } else {
        doLink = @"board-api-recent-memo.do";
    }

    NSString *url = [NSString stringWithFormat:@"%@/%@", WWW_SERVER, doLink];
    NSLog(@"query = [%@]", url);
    
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"index", @"part",
                         @"50", @"rid",
                         strRecent, @"pid", nil];
    
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
	if ([data length] < 1800) {
        if ([self.delegate respondsToSelector:@selector(recentData:withError:)] == YES)
            [self.delegate recentData:self withError:[NSNumber numberWithInt:RESULT_AUTH_FAIL]];
	}
	
	NSError *localError = nil;
	NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
	
	if (localError != nil) {
		return;
	}
	
    NSMutableArray *arrayItems = [[NSMutableArray alloc] init];
    
	NSArray *jsonItems = [parsedObject valueForKey:@"item"];
	
	NSMutableDictionary *currItem;
	
    // DB에 현재 읽는 글의 boardId, boardNo 를 insert
    DBInterface *db;
    db = [[DBInterface alloc] init];

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
        NSString *boardId = [jsonItem valueForKey:@"boardId"];
		[currItem setValue:boardId forKey:@"boardId"];
		// boardName
		[currItem setValue:[jsonItem valueForKey:@"boardName"] forKey:@"boardName"];
		
		// subject
		NSString *subject = [jsonItem valueForKey:@"boardTitle"];
        subject = [subject stringByDecodingHTMLEntities];
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

        int checked = [db searchWithBoardId:boardId BoardNo:boardNo];
        if (checked > 0) {
            [currItem setValue:[NSNumber numberWithInt:1] forKey:@"read"];
        } else {
            [currItem setValue:[NSNumber numberWithInt:0] forKey:@"read"];
        }

		[arrayItems addObject:currItem];
	}
    if ([self.delegate respondsToSelector:@selector(recentData:didFinishLodingData:)] == YES)
        [self.delegate recentData:self didFinishLodingData:arrayItems];}

@end
