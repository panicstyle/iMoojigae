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

@interface ArticleData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
	BOOL m_isConn;
	BOOL m_isLogin;
	LoginToService *m_login;
}
@end

@implementation ArticleData
@synthesize m_strTitle;
@synthesize m_strName;
@synthesize m_strDate;
@synthesize m_strHit;
@synthesize m_strHtml;
@synthesize m_strContent;
@synthesize m_strEditableContent;
@synthesize m_strLink;
@synthesize m_arrayItems;
@synthesize target;
@synthesize selector;

- (void)fetchItems
{
	m_isConn = TRUE;
	m_isLogin = FALSE;
	
	m_arrayItems = [[NSMutableArray alloc] init];
	m_receiveData = [[NSMutableData alloc] init];
	
	[self fetchItems2];
}

- (void)fetchItems2
{
	NSString *url = [NSString stringWithFormat:@"%@/%@", WWW_SERVER, m_strLink];

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
	m_strHtml = [[NSString alloc] initWithData:m_receiveData encoding: 0x80000000 + kCFStringEncodingEUC_KR];
	
	NSLog(@"html = [%lu]", (unsigned long)[m_strHtml length]);
	
	// parent.setMainBodyLogin 가 포함되어 있으면 다시 로그인해야 함.
	if ([Utils numberOfMatches:m_strHtml regex:@"parent.setMainBodyLogin"] > 0) {
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
	
	
	// Title, Name, Date, Hit
	
	m_strTitle = [Utils findStringRegex:m_strHtml regex:@"(?<=<font class=fTitle><b>제목 : <font size=3>).*?(?=</font>)"];
	
	NSString *strTitle = [Utils findStringWith:m_strHtml from:@"<td class=fSubTitle>" to:@"<td class=lReadTop></td>"];
	
	m_strName = [Utils findStringRegex:strTitle regex:@"(?<=textDecoration='none'>).*?(?=</font>)"];
	m_strName = [Utils replaceStringHtmlTag:m_strName];
	m_strDate = [Utils findStringRegex:strTitle regex:@"\\d\\d\\d\\d-\\d\\d-\\d\\d.\\d\\d:\\d\\d:\\d\\d"];
	m_strHit = [Utils findStringRegex:strTitle regex:@"(?<=<font style=font-style:italic>).*?(?=</font>)"];
	
	strTitle = [NSString stringWithFormat:@"<div class='title'>%@</div><div class='name'><span>%@</span>&nbsp;&nbsp;<span>%@</span>&nbsp;&nbsp;<span>%@</span>명이 읽음</div>", m_strTitle, m_strName, m_strDate, m_strHit];
	
	NSString *strContent = [Utils findStringWith:m_strHtml from:@"<!-- 내용 -->" to:@"<!-- 투표 -->"];
	
	if ([strContent isEqualToString:@""]) {
		NSLog(@"contents start NotFound url");
		[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_AUTH_FAIL] afterDelay:0];
		return;
	}
	
	strContent = [strContent stringByReplacingOccurrencesOfString:@"<td width=200 align=right class=fMemoSmallGray>" withString:@"<!--"];
	strContent = [strContent stringByReplacingOccurrencesOfString:@"<td width=10></td>" withString:@"-->"];
	strContent = [strContent stringByReplacingOccurrencesOfString:@"<!-- 메모에 대한 답변 -->" withString:@"<!--"];
	strContent = [strContent stringByReplacingOccurrencesOfString:@"<!-- <font class=fMemoSmallGray>" withString:@"--><!--"];
	strContent = [strContent stringByReplacingOccurrencesOfString:@"<nobr class=bbscut id=subjectTtl name=subjectTtl>" withString:@""];
	strContent = [strContent stringByReplacingOccurrencesOfString:@"(</nobr)" withString:@""];
	strContent = [NSString stringWithFormat:@"<div class='content'>%@</div>", strContent];
	
	m_strEditableContent = [Utils replaceStringHtmlTag:strContent];
	
	NSString *strAttach = [Utils findStringWith:m_strHtml from:@"<!-- 업로드 파일 정보  수정본 Edit By Yang -->" to:@"<!-- 평가 -->"];
	strAttach = [NSString stringWithFormat:@"<div class='attach'>%@</div>", strAttach];
	
	NSString *strProfile = [Utils findStringWith:m_strHtml from:@"<!-- 별점수 -->" to:@"<!-- 관련글 -->"];
	
	strProfile = [Utils findStringRegex:strProfile regex:@"(?<=<td class=cContent>).*?(?=</td>)"];
	strProfile = [NSString stringWithFormat:@"<div class='profile'>%@</div>", strProfile];
	
	NSString *mComment = [Utils findStringWith:m_strHtml from:@"<!-- 메모글 반복 -->" to:@"<!-- 메모 입력 -->"];
	
	NSArray *commentItems = [mComment componentsSeparatedByString:@"<tr onMouseOver=this.style.backgroundColor='#F0F8FF'; onMouseOut=this.style.backgroundColor=''; class=bMemo>"];
	
	NSMutableDictionary *currItem;
	
	for (int i = 1; i < [commentItems count]; i++) {
		NSString *s = [commentItems objectAtIndex:i];
		currItem = [[NSMutableDictionary alloc] init];
		
		NSRange find1 = [s rangeOfString:@"i_memo_reply.gif"];
		if (find1.location == NSNotFound) {
			[currItem setValue:[NSNumber numberWithInt:0] forKey:@"isRe"];
		} else {
			[currItem setValue:[NSNumber numberWithInt:1] forKey:@"isRe"];
		}
		
		NSString *strNo = [Utils findStringRegex:s regex:@"(?<=<span id=memoReply_).*?(?=>)"];
		[currItem setValue:strNo forKey:@"no"];
		
		// Name
		NSString *strName = [Utils findStringRegex:s regex:@"(<font onclick=\\\"viewCharacter).*?(</font>)"];
		strName = [Utils replaceStringRegex:strName regex:@"(<).*?(>)" replace:@""];
		strName = [strName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		[currItem setValue:strName forKey:@"name"];
		
		// Date
		NSString *strDate = [Utils findStringRegex:s regex:@"(?<=<td width=200 align=right class=fMemoSmallGray>).*?(?=</td>)"];
		strDate = [Utils replaceStringRegex:strDate regex:@"(<).*?(>)" replace:@""];
		strDate = [strDate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		[currItem setValue:strDate forKey:@"date"];
		
		// Comment
		NSString *strComm = [Utils findStringRegex:s regex:@"(<span id=memoReply_).*?(<!-- 메모에 대한 답변 -->)"];
		strComm = [Utils replaceStringHtmlTag:strComm];
		[currItem setValue:strComm forKey:@"comment"];
		
		[currItem setValue:[NSNumber numberWithFloat:80.0f] forKey:@"height"];
		
		[m_arrayItems addObject:currItem];
	}
	
	/*    NSString *strHeader = @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=euc-kr\"></head><body>";
	 NSString *strBottom = @"</table></body></html>";
	 NSString *strResize = @"<script>function resizeImage2(mm){var width = eval(mm.width);var height = eval(mm.height);if( width > 300 ){var p_height = 300 / width;var new_height = height * p_height;eval(mm.width = 300);eval(mm.height = new_height);}} function image_open(src, mm) { var width = eval(mm.width); window.open(src,'image');}</script>";
	 NSString *cssStr = @"<link href=\"./css/default.css\" rel=\"stylesheet\">";
	 NSString *strBody = @"<body><table border=0 width=100%>";
	 NSString *strBody2 = @"</table><table border=0 width=100%>";
	 */
	NSMutableString *strHeader = [[NSMutableString alloc] init];
	[strHeader appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"];
	[strHeader appendString:@"<html><head>"];
	[strHeader appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=euc-kr\">"];
	[strHeader appendString:@"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, target-densitydpi=medium-dpi\">"];
	[strHeader appendString:@"<style>body {font-family:\"고딕\";font-size:medium;}.title{text-margin:10px 0px;font-size:large}.name{color:gray;margin:10px 0px;font-size:small}.content{}.profile {text-align:left;color:gray;margin:10px 0px;font-size:small}.comment_header{text-align:left;color:white;background: lightgray;padding:20px 0px 10px 10px;font-size:small}.reply{border-bottom:1px solid gray;margin:10px 0px}.reply_header {color:gray;;font-size:small}.reply_content {margin:10px 0px}.re_reply{border-bottom:1px solid gray;margin:10px 0px 0px 20px;background:lightgray}</style>"];
	[strHeader appendString:@"</head>"];
	NSString *strBottom = @"</body></html>";
	NSString *strResize = @"<script>function resizeImage2(mm){var width = eval(mm.width);var height = eval(mm.height);if( width > 300 ){var p_height = 300 / width;var new_height = height * p_height;eval(mm.width = 300);eval(mm.height = new_height);}} function image_open(src, mm) { var width = eval(mm.width); window.open(src,'image');}</script>";
	//        String cssStr = "<link href=\"./css/default.css\" rel=\"stylesheet\">";
	NSString *strBody = @"<body>";
	
	
	m_strContent = [[NSString alloc] initWithFormat:@"%@%@%@%@%@%@%@", strHeader, strResize, strBody, strContent, strAttach, strProfile, strBottom];
	
	/*
	 CGRect rectScreen = m_webView.frame;
	 m_lContentHeight = rectScreen.size.height;
	 
	 CGRect contentRect = m_contentCell.frame;
	 contentRect.size.height = m_lContentHeight;
	 m_contentCell.frame = contentRect;
	 */
	[target performSelector:selector withObject:[NSNumber numberWithInt:RESULT_OK] afterDelay:0];
	return;
}

- (bool)DeleteArticle:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo
{
	NSLog(@"DeleteArticleConfirm start");
	NSLog(@"boardID=[%@], boardNo=[%@]", strBoardNo, strArticleNo);
	
	// http://121.134.211.159/board-save.do
	// boardId=mvHorizonLivingStory&page=1&categoryId=-1&time=1334217622773&returnBoardNo=133404944519504&boardNo=133404944519504&command=DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1
	
	NSString *url = [NSString stringWithFormat:@"%@/board-save.do", WWW_SERVER];
	NSLog(@"url = [%@]", url);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"http://121.134.211.159/board-read.do" forHTTPHeaderField:@"Referer"];
	[request addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"ko,en-US;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
	[request addValue:@"windows-949,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
	
	NSMutableData *body = [NSMutableData data];
	// usetag = n
	[body appendData:[[NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&time=1334217622773&returnBoardNo=%@&boardNo=%@&command=DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1", strBoardNo, strArticleNo, strArticleNo] dataUsingEncoding:0x80000000 + kCFStringEncodingEUC_KR]];
	
	[request setHTTPBody:body];
	
	//returningResponse:(NSURLResponse **)response error:(NSError **)error
	NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:0x80000000 + kCFStringEncodingEUC_KR];
	//history.go(-1);
	NSLog(@"returnData = [%@]", str);
	
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"parent.checkLogin" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
	NSUInteger numberOfMatches = [regex numberOfMatchesInString:str options:0 range:NSMakeRange(0, [str length])];
	
	if (numberOfMatches <= 0) {
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
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"http://121.134.211.159/board-read.do" forHTTPHeaderField:@"Referer"];
	[request addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"ko,en-US;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
	[request addValue:@"windows-949,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
	
	NSMutableData *body = [NSMutableData data];
	// usetag = n
	NSString *bodyString = [NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&time=&returnBoardNo=%@&boardNo=%@&command=MEMO_DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=%@&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1", strBoardNo, strArticleNo, strArticleNo, strCommentNo];
	
	NSLog(@"bodyString = [%@]", bodyString);
	
	[body appendData:[bodyString dataUsingEncoding:0x80000000 + kCFStringEncodingEUC_KR]];
	
	[request setHTTPBody:body];
	
	//returningResponse:(NSURLResponse **)response error:(NSError **)error
	NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:0x80000000 + kCFStringEncodingEUC_KR];
	//history.go(-1);
	NSLog(@"returnData = [%@]", str);
	
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"function redirect" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
	NSUInteger numberOfMatches = [regex numberOfMatchesInString:str options:0 range:NSMakeRange(0, [str length])];
	
	if (numberOfMatches <= 0) {
		return false;
	}
	
	return true;
}

@end
