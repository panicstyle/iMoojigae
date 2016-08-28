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
@synthesize m_strBoardNo;
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
	NSString *url = [NSString stringWithFormat:@"%@%@%@&page=%d", WWW_SERVER, BOARD_LIST, m_strBoardNo, m_nPage];

	m_receiveData = [[NSMutableData alloc] init];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"http://121.134.211.159/board-list.do" forHTTPHeaderField:@"Referer"];
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
	
	if ([Utils numberOfMatches:str regex:@"<td><font style=font-size:12pt></td><b>시스템 메세지입니다</b></font><br>접근이 차단되었습니다<br>"] > 0) {
		[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_AUTH_FAIL] afterDelay:0];
		return;
	}
	if ([Utils numberOfMatches:str regex:@"parent.setMainBodyLogin"] > 0) {
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
	
	// parent.setMainBodyLogin 가 포함되어 있으면 다시 로그인해야 함.

	// <td><font style=font-size:12pt></td><b>시스템 메세지입니다</b></font><br>접근이 차단되었습니다<br> 가 나오면 접근할 수 없는 게시판
	
	
	int cnt = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *item;
	
	NSRange range0 = {0, [str length]};
	int i;
	for (i = 0; i < 30; i++) {
		NSRange find1 = [str rangeOfString:@" <tr height=22 align=center class=fAContent>" options:NSCaseInsensitiveSearch range:range0];
		NSLog(@"find1 loc=[%lu], len=[%lu]", (unsigned long)find1.location, (unsigned long)find1.length);
		if (find1.location == NSNotFound) {
			NSLog(@"start NotFound find1");
			//        [self alertNotFound];
			break;
		}
		NSRange range1 = {find1.location, [str length] - find1.location};
		NSRange find2 = [str rangeOfString:@"<td colspan=8 height=1 background=./img/skin/default/footer_line.gif>" options:NSCaseInsensitiveSearch range:range1];
		NSLog(@"find2 loc=[%lu], len=[%lu]", (unsigned long)find2.location, (unsigned long)find2.length);
		if (find2.location == NSNotFound) {
			NSLog(@"start NotFound find2");
			//        [self alertNotFound];
			break;
		}
		
		// -6은 <TR>\n<TD에서 <TR을 빼기 위함
		NSRange range2 = {find1.location, ((find2.location - 30) - find1.location)};
		NSString *str2 = [str substringWithRange:range2];
		NSLog(@"[%d] str2 = [%@]", cnt, str2);
		
		item = [[NSMutableDictionary alloc] init];
		
		[item setValue:str2 forKey:@"data"];
		
		NSRange find3 = [str2 rangeOfString:@"src=./img/skin/default/i_new.gif"];
		if (find3.location == NSNotFound) {
			[item setValue:@"0" forKey:@"isNew"];
		} else {
			[item setValue:@"1" forKey:@"isNew"];
			NSLog(@"isNew");
		}
		
		[array addObject:item];
		range0 = NSMakeRange(find2.location + find2.length, [str length] - (find2.location + find2.length));
		cnt++;
		NSLog(@"cnt = [%d]", cnt);
		
	}
	
	NSMutableDictionary *currItem;
	
	for (int i = 0; i < cnt; i++) {
		item = [array objectAtIndex:i];
		NSString *data = [item valueForKey:@"data"];
		
		currItem = [[NSMutableDictionary alloc] init];
		
		// link
		NSError *error = NULL;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<a href=).*?(?=[ ])" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
		NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:data options:0 range:NSMakeRange(0, [data length])];
		
		NSString *link;
		if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
			link = [data substringWithRange:rangeOfFirstMatch];
			NSLog(@"link=[%@]", link);
		} else {
			NSLog(@"link line not found");
			link = @"";
		}
		[currItem setValue:[NSString stringWithString:link] forKey:@"link"];
		
		// subject
		regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=class=\\\"list\\\">).*?(?=</a>)" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
		rangeOfFirstMatch = [regex rangeOfFirstMatchInString:data options:0 range:NSMakeRange(0, [data length])];
		
		NSString *subject;
		if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
			subject = [data substringWithRange:rangeOfFirstMatch];
			NSLog(@"subject=[%@]", subject);
		} else {
			NSLog(@"subject line not found");
			subject = @"";
		}
		subject = [subject stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		subject = [subject stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
		subject = [subject stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
		subject = [subject stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
		subject = [subject stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
		[currItem setValue:[NSString stringWithString:subject] forKey:@"subject"];
		
		// writer
		// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
		regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<td id=tBbsCol7 name=tBbsCol7 width=100 align=center>).*?(?=</td>)" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
		rangeOfFirstMatch = [regex rangeOfFirstMatchInString:data options:0 range:NSMakeRange(0, [data length])];
		
		NSString *writer;
		if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
			writer = [data substringWithRange:rangeOfFirstMatch];
			NSLog(@"writer=[%@]", writer);
		} else {
			NSLog(@"writer line not found");
			writer = @"";
		}
		
		//  <font onclick="viewCharacter('ib504', event)" style='cursor:pointer' onmouseover=this.style.textDecoration='underline' onmouseout=this.style.textDecoration='none'><img src=.//out/icon/20110811/20110811131302409212111_jpg onerror="this.src='.//out/icon/no.gif'" align=absmiddle>이봄</font>
		// 에서 아이콘 부분 삭제하기
		regex = [NSRegularExpression regularExpressionWithPattern:@"(<).*?(>)" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
		NSString *writer2 = [regex stringByReplacingMatchesInString:writer options:0 range:NSMakeRange(0, [writer length]) withTemplate:@""];
		
		NSString *trimmedwriter = [writer2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		//        trimmedwriter = [trimmedwriter substringWithRange:NSMakeRange(1, [trimmedwriter length] - 2)];
		
		[currItem setValue:[NSString stringWithString:trimmedwriter] forKey:@"name"];
		
		// Comment
		// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
		regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<font class=fAMemo>).*?(?=</font>)" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
		rangeOfFirstMatch = [regex rangeOfFirstMatchInString:data options:0 range:NSMakeRange(0, [data length])];
		
		NSString *comment;
		if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
			comment = [data substringWithRange:rangeOfFirstMatch];
			NSLog(@"comment=[%@]", comment);
		} else {
			NSLog(@"comment line not found");
			comment = @"";
		}
		[currItem setValue:[NSString stringWithString:comment] forKey:@"comment"];
		
		// date
		regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=class=mdlgray>)\\d\\d\\d\\d-\\d\\d-\\d\\d(?=</td>)" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
		rangeOfFirstMatch = [regex rangeOfFirstMatchInString:data options:0 range:NSMakeRange(0, [data length])];
		
		NSString *date;
		if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
			date = [data substringWithRange:rangeOfFirstMatch];
			NSLog(@"date=[%@]", date);
		} else {
			NSLog(@"date line not found");
			date = @"";
		}
		[currItem setValue:[NSString stringWithString:date] forKey:@"date"];
		
		// isNew
		// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
		regex = [NSRegularExpression regularExpressionWithPattern:@"i_new.gif" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
		NSUInteger numberOfMatches = [regex numberOfMatchesInString:data options:0 range:NSMakeRange(0, [data length])];
		NSString *isNew;
		if (numberOfMatches > 0) {
			isNew = @"1";
			NSLog(@"isNew");
		} else {
			isNew = @"0";
		}
		[currItem setValue:[NSString stringWithString:isNew] forKey:@"isNew"];
		
		// is Reply
		// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
		regex = [NSRegularExpression regularExpressionWithPattern:@"i_re.gif" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
		numberOfMatches = [regex numberOfMatchesInString:data options:0 range:NSMakeRange(0, [data length])];
		NSString *isReply;
		if (numberOfMatches > 0) {
			isReply = @"1";
			NSLog(@"isReply");
		} else {
			isReply = @"0";
		}
		[currItem setValue:[NSString stringWithString:isReply] forKey:@"isReply"];
		
		[currItem setValue:[NSNumber numberWithFloat:77.0f] forKey:@"height"];
		
		[m_arrayItems addObject:currItem];
	}
	
	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
}


@end
