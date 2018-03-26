	//
//  ArticleData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 13..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "ArticleData.h"
#import "Utils.h"
#import "env.h"
#import "LoginToService.h"
#import "Utils.h"

@interface ArticleData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
	BOOL m_isConn;
	BOOL m_isLogin;
	LoginToService *m_login;
}
@end

@implementation ArticleData
@synthesize m_boardId;
@synthesize m_boardNo;
@synthesize m_strTitle;
@synthesize m_strName;
@synthesize m_strDate;
@synthesize m_strHit;
@synthesize m_strHtml;
@synthesize m_strContent;
@synthesize m_strEditableContent;
@synthesize m_arrayItems;
@synthesize m_dicAttach;
@synthesize target;
@synthesize selector;

- (void)fetchItems
{
	m_isConn = TRUE;
	m_isLogin = FALSE;
	
	m_arrayItems = [[NSMutableArray alloc] init];
	m_dicAttach = [[NSMutableDictionary alloc] init];
	m_receiveData = [[NSMutableData alloc] init];
	
	[self fetchItems2];
}

- (void)fetchItems2
{
	NSString *url = [NSString stringWithFormat:@"%@/board-api-read.do?boardId=%@&boardNo=%@&command=READ&page=1&categoryId=-1&rid=20", WWW_SERVER, m_boardId, m_boardNo];

	m_connection = [[NSURLConnection alloc]
			initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_receiveData appendData:data];
	NSLog(@"didReceiveData = [%lu][%lu]", (unsigned long)[m_receiveData length], (unsigned long)[data length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self doFetch];
}

- (void)doFetch
{
	m_strHtml = [[NSString alloc] initWithData:m_receiveData encoding: g_encodingOption];
	
	NSLog(@"html = [%lu]", (unsigned long)[m_strHtml length]);
	
	// ./img/common/board/alert.gif 가 포함되어 있으면 다시 로그인해야 함.
	if ([Utils numberOfMatches:m_strHtml regex:@"./img/common/board/alert.gif"] > 0) {
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
	
	// Title, Name, Date, Hit
	
	m_strTitle = [parsedObject valueForKey:@"boardTitle"];

	m_strName = [parsedObject valueForKey:@"userNick"];
	
	m_strDate = [parsedObject valueForKey:@"boardRegister_dt"];
	
	m_strHit = [parsedObject valueForKey:@"boardRead_cnt"];
	
	NSString *strContent = [parsedObject valueForKey:@"boardContent"];;
	
	m_strEditableContent = [Utils replaceStringHtmlTag:strContent];
	
	NSArray *imageItems = [parsedObject valueForKey:@"image"];
	
	NSMutableString *strImage = [[NSMutableString alloc]init];
	[strImage appendString:@""];
	
	for (int i = 0; i < [imageItems count]; i++) {
		NSDictionary *jsonItem = [imageItems objectAtIndex:i];
		NSString *fileName = [jsonItem valueForKey:@"fileName"];
		NSString *link = [jsonItem valueForKey:@"link"];

		/* 이미지 파일목록중 파일명이 이미지인 것들만 이미지에 포함시킨다. */
		fileName = [fileName lowercaseString];
		if ([fileName containsString:@".jpg"]
			|| [fileName containsString:@".jpeg"]
			|| [fileName containsString:@".png"]
			|| [fileName containsString:@".gif"]
			) {
			[strImage appendString:link];
		}
	}
	
	NSMutableString *strAttach = [[NSMutableString alloc]init];
	[strAttach appendString:@""];

	NSArray *attachItems = [parsedObject valueForKey:@"attachment"];
	
	if ([attachItems count] > 0) {
		[strAttach appendString:@"<table boader=1><tr><th>첨부파일</th></tr>"];
	}
	for (int i = 0; i < [attachItems count]; i++) {
		NSDictionary *jsonItem = [attachItems objectAtIndex:i];
		NSString *link = [jsonItem valueForKey:@"link"];
		[strAttach appendString:@"<tr><td>"];
		[strAttach appendString:link];
		[strAttach appendString:@"</td></tr>"];
		
		NSString *n = [jsonItem valueForKey:@"fileSeq"];
		NSString *f = [jsonItem valueForKey:@"fileName"];

		[m_dicAttach setValue:f forKey:n];
	}
	if ([attachItems count] > 0) {
		[strAttach appendString:@"</tr></table>"];
	}

	NSString *strProfile = [NSString stringWithFormat:@"<div class='profile'>%@</div>", [parsedObject valueForKey:@"userComment"]];
	
	NSArray *memoItems = [parsedObject valueForKey:@"memo"];

	NSMutableDictionary *currItem;
	
	for (int i = 0; i < [memoItems count]; i++) {
		NSDictionary *jsonItem = [memoItems objectAtIndex:i];
		currItem = [[NSMutableDictionary alloc] init];
		
		// ieRe
		[currItem setValue:[jsonItem valueForKey:@"memoDep"] forKey:@"isRe"];

		// no
		[currItem setValue:[jsonItem valueForKey:@"memoSeq"] forKey:@"no"];
		
		// Name
		[currItem setValue:[jsonItem valueForKey:@"userNick"] forKey:@"name"];
		
		// Date
		[currItem setValue:[jsonItem valueForKey:@"memoRegister_dt"] forKey:@"date"];
		
		// Comment
		NSString *strComm = [jsonItem valueForKey:@"memoContent"];
		strComm = [Utils replaceStringHtmlTag:strComm];
		[currItem setValue:strComm forKey:@"comment"];
		
		[currItem setValue:[NSNumber numberWithFloat:80.0f] forKey:@"height"];
		
		[m_arrayItems addObject:currItem];
	}
	
	NSMutableString *strHeader = [[NSMutableString alloc] init];
	[strHeader appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"];
	[strHeader appendString:@"<html><head>"];
	[strHeader appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
	[strHeader appendString:@"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, target-densitydpi=medium-dpi\">"];
	[strHeader appendString:@"<style>body {font-family:\"고딕\";font-size:medium;}.title{text-margin:10px 0px;font-size:large}.name{color:gray;margin:10px 0px;font-size:small}.content{}.profile {text-align:left;color:gray;margin:10px 0px;font-size:small}.comment_header{text-align:left;color:white;background: lightgray;padding:20px 0px 10px 10px;font-size:small}.reply{border-bottom:1px solid gray;margin:10px 0px}.reply_header {color:gray;;font-size:small}.reply_content {margin:10px 0px}.re_reply{border-bottom:1px solid gray;margin:10px 0px 0px 20px;background:lightgray}</style>"];
	[strHeader appendString:@"<script>function myapp_clickImg(obj){window.location=\"jscall://\"+encodeURIComponent(obj.src);}</script>"];
	[strHeader appendString:@"</head>"];
	
//	[strHeader appendString:@"<script> \
		function imageResize() { \
			var boardWidth = window.innerWidth - 30; \
			if (document.cashcow && document.cashcow.boardWidth) \
				boardWidth = document.cashcow.boardWidth.value - 70; \
			var obj = document.getElementsByName('unicornimage'); \
			for (var i = 0; i < obj.length; i++) { \
				if (obj[i].width > boardWidth) \
					obj[i].width = boardWidth; \
			} \
		}</script>"];
//	 [strHeader appendString:@"<script>window.onload=imageResize;</script></head>"];
	NSString *strBottom = @"</body></html>";
	//        String cssStr = "<link href=\"./css/default.css\" rel=\"stylesheet\">";
	NSString *strBody = @"<body>";
	
	/* 이미지 테크에 width 값과 click 시 javascript 를 호출하도록 수정한다. */
	m_strContent = [[NSString alloc] initWithFormat:@"%@%@%@%@%@%@%@",
					strHeader,
					strBody,
					[strContent stringByReplacingOccurrencesOfString:@"<img " withString:@"<img onclick=\"myapp_clickImg(this)\" width=300 "],
					[strImage stringByReplacingOccurrencesOfString:@"<img " withString:@"<img onclick=\"myapp_clickImg(this)\" width=300 "],
					strAttach,
					strProfile,
					strBottom];
	
	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
	return;
}

- (bool)DeleteArticle:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo
{
	NSLog(@"DeleteArticleConfirm start");
	NSLog(@"boardID=[%@], boardNo=[%@]", strBoardNo, strArticleNo);
		
	NSString *url = [NSString stringWithFormat:@"%@/board-save.do", WWW_SERVER];
	NSLog(@"url = [%@]", url);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"http://www.moojijgae.or.kr/board-read.do" forHTTPHeaderField:@"Referer"];
	[request addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"ko,en-US;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
	[request addValue:@"windows-949,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
	
	NSMutableData *body = [NSMutableData data];
	// usetag = n
	[body appendData:[[NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&time=1334217622773&returnBoardNo=%@&boardNo=%@&command=DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1", strBoardNo, strArticleNo, strArticleNo] dataUsingEncoding:g_encodingOption]];
	
	[request setHTTPBody:body];
	
	//returningResponse:(NSURLResponse **)response error:(NSError **)error
	NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:g_encodingOption];
	//history.go(-1);
	NSLog(@"returnData = [%@]", str);
	
	if ([Utils numberOfMatches:str regex:@"<b>시스템 메세지입니다</b>"] > 0) {
		return false;
	}
	
	NSLog(@"delete article success");
	return true;
}

- (bool)DeleteComment:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo commentNo:(NSString *)strCommentNo
{
	//boardId=mvHorizonLivingStory&page=1&categoryId=-1&time=1334217591651&returnBoardNo=133404944519504&boardNo=133404944519504&command=MEMO_DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=4&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1
	
	NSString *url = [NSString stringWithFormat:@"%@/memo-save.do", WWW_SERVER];
	NSLog(@"url = [%@]", url);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString *strReferer = [NSString stringWithFormat:@"%@/board-read.do", WWW_SERVER];
	
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:strReferer forHTTPHeaderField:@"Referer"];
	[request addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"ko,en-US;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
	[request addValue:@"windows-949,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
	
	NSMutableData *body = [NSMutableData data];
	// usetag = n
	NSString *bodyString = [NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&time=&returnBoardNo=%@&boardNo=%@&command=MEMO_DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=%@&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1", strBoardNo, strArticleNo, strArticleNo, strCommentNo];
	
	NSLog(@"bodyString = [%@]", bodyString);
	
	[body appendData:[bodyString dataUsingEncoding:g_encodingOption]];
	
	[request setHTTPBody:body];
	
	//returningResponse:(NSURLResponse **)response error:(NSError **)error
	NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:g_encodingOption];
	//history.go(-1);
	NSLog(@"returnData = [%@]", str);
	
	if ([Utils numberOfMatches:str regex:@"<b>시스템 메세지입니다</b>"] > 0) {
		return false;
	}
	
	return true;
}

@end
