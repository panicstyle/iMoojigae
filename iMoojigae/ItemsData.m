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
#import "HttpSessionRequest.h"

@interface ItemsData () <HttpSessionRequestDelegate>
{
	BOOL m_isConn;
	BOOL m_isLogin;
    NSString *m_boardId;
	int m_nPage;
	LoginToService *m_login;
}
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
@end

@implementation ItemsData

- (id)init
{
    self = [super init];
    if (self)
    {
        self.httpSessionRequest = [[HttpSessionRequest alloc] init];
        self.httpSessionRequest.delegate = self;
        self.httpSessionRequest.timeout = 30;
    }
    
    return self;
}

- (void)fetchItemsWithBoardId:(NSString *)boardId withPage:(int)nPage
{
    NSString *url = [NSString stringWithFormat:@"%@/board-api-list.do", WWW_SERVER];
    NSLog(@"query = [%@]", url);
    
    m_boardId = boardId;
    m_nPage = nPage;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:boardId, @"boardId",
                         [NSString stringWithFormat:@"%d", nPage], @"page", nil];
    
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
    m_isConn = FALSE;
	
	NSString *str = [[NSString alloc] initWithData:data
										  encoding:NSUTF8StringEncoding];
	
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
				[self fetchItemsWithBoardId:m_boardId withPage:m_nPage];
				return;
			} else {
                if ([self.delegate respondsToSelector:@selector(itemsData:withError:)] == YES)
                    [self.delegate itemsData:self withError:[NSNumber numberWithInt:RESULT_LOGIN_FAIL]];
				return;
			}
		} else {
            if ([self.delegate respondsToSelector:@selector(itemsData:withError:)] == YES)
                [self.delegate itemsData:self withError:[NSNumber numberWithInt:RESULT_LOGIN_FAIL]];
            return;
		}
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

		[arrayItems addObject:currItem];
	}
	
    if ([self.delegate respondsToSelector:@selector(itemsData:didFinishLodingData:)] == YES)
        [self.delegate itemsData:self didFinishLodingData:arrayItems];
}

@end
