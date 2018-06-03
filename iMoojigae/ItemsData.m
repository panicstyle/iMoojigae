//
//  ItemsData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "ItemsData.h"
#import "env.h"
#import "LoginToService.h"
#import "Utils.h"
#import "NSString+HTML.h"
#import "DBInterface.h"

@interface ItemsData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
	BOOL m_isConn;
	BOOL m_isLogin;
	int m_nPage;
	LoginToService *m_login;
}
@end

@implementation ItemsData

@synthesize m_strCommNo;
@synthesize m_boardId;
@synthesize m_arrayItems;
@synthesize target;
@synthesize selector;

- (void)fetchItems:(int) nPage
{
	m_arrayItems = [[NSMutableArray alloc] init];

	m_isConn = TRUE;
	m_isLogin = FALSE;
	m_nPage = nPage;
	
	[self fetchItems2];
}

- (void)fetchItems2
{
	NSString *url = [NSString stringWithFormat:@"%@/board-api-list.do?boardId=%@&page=%d", WWW_SERVER, m_boardId, m_nPage];

	m_receiveData = [[NSMutableData alloc] init];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *strReferer = [NSString stringWithFormat:@"%@/board-list.do", WWW_SERVER];
	
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:strReferer forHTTPHeaderField:@"Referer"];
	[request addValue:@"gzip,deflate,sxdch" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"ko,en-US;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
	[request addValue:@"windows-949,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
	
	NSData *body = [[NSData alloc] initWithData:[@"" dataUsingEncoding:g_encodingOption]];
	
	[request setHTTPBody:body];
	
	m_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	NSLog(@"fetchItems 2");
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
	
	NSString *str = [[NSString alloc] initWithData:m_receiveData
										  encoding:g_encodingOption];
	
	if ([Utils numberOfMatches:str regex:@"./img/common/board/alert.gif"] > 0) {
		if (m_isLogin == FALSE) {
			NSLog(@"retry login");
			// 저장된 로그인 정보를 이용하여 로그인
			m_login = [[LoginToService alloc] init];
			//            [login setDelegate:self selector:@selector(didReceiveFinished:)];
			BOOL result = [m_login LoginToService];
			if (result) {
				NSLog(@"login ok");
				m_isLogin = TRUE;
				[self fetchItems2];
				return;
			} else {
				[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_LOGIN_FAIL] afterDelay:0];
				return;
			}
		} else {
			[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_LOGIN_FAIL] afterDelay:0];
			return;
		}
	}
	
	NSError *localError = nil;
	NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:m_receiveData options:0 error:&localError];
	
	if (localError != nil) {
		return;
	}
	
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
        
        int checked = [db searchWithBoardId:boardId BoardNo:boardNo];
        if (checked > 0) {
            [currItem setValue:[NSNumber numberWithInt:1] forKey:@"read"];
        } else {
            [currItem setValue:[NSNumber numberWithInt:0] forKey:@"read"];
        }

		[m_arrayItems addObject:currItem];
	}
	
	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
}


@end
