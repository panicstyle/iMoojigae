//
//  ArticleView.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "ArticleView.h"
#import "CommentWriteView.h"
#import "ArticleWriteView.h"
#import "env.h"
#import "Utils.h"
#import "WebLinkView.h"
#import "DBInterface.h"
#import "NSString+HTML.h"
#import "HttpSessionRequest.h"
#import "LoginToService.h"
@import GoogleMobileAds;

@interface ArticleView () <ArticleWriteDelegate, HttpSessionRequestDelegate, LoginToServiceDelegate>
{
	UITableViewCell *m_contentCell;
	UITableViewCell *m_imageCell;
	UITableViewCell *m_replyCell;
	
	NSMutableArray *m_arrayItems;
	NSDictionary *m_dicAttach;
	long m_lContentHeight;
	float m_fTitleHeight;
	
	UIWebView *m_webView;
	
	NSMutableData *receiveData;
	NSString *paramTitle;
	NSString *paramWriter;

	NSString *htmlString;

	NSString *m_strCommentNo;
	NSString *m_strComment;
	NSString *m_strHit;
	int m_nMode;
	
	NSString *DeleteBoardID;
	NSString *DeleteBoardNO;
	
	NSString *m_strEditableTitle;
	NSString *m_strEditableContent;

	NSURLConnection *conn;
	
	NSString *m_strWebLink;
	int m_nFileType;
	
    NSString *m_strHtml;
    NSString *m_strContent;
    BOOL m_isLogin;
    long m_rowComment;
}
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
@property (nonatomic, strong) LoginToService *m_login;
@end

@implementation ArticleView

@synthesize tbView;
@synthesize buttonArticleMenu;
@synthesize m_strTitle;
@synthesize m_strDate;
@synthesize m_strName;
@synthesize m_boardId;
@synthesize m_boardNo;
@synthesize m_boardName;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryDidChangeNotification)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = m_boardName;
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	self.navigationItem.titleView = lblTitle;

	buttonArticleMenu.target = self;
	buttonArticleMenu.action = @selector(ArticleMenu);
	
	m_lContentHeight = 300;
	
    m_fTitleHeight = 77.0f;
    
    tbView.estimatedRowHeight = 150.0f;
    tbView.rowHeight = UITableViewAutomaticDimension;
    
	m_strHit = @"";

    // Replace this ad unit ID with your own ad unit ID.
    self.bannerView.adUnitID = kSampleAdUnitID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
/*
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
		self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
*/
/*
	// Do any additional setup after loading the view from its nib.
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"메뉴"
																			   style:UIBarButtonItemStylePlain
																			  target:self
																		  action:@selector(showMenu:)];
*/
	m_arrayItems = [[NSMutableArray alloc] init];

    [self fetchItemsWithBoardId:m_boardId withBoardNo:m_boardNo];
    
    // DB에 현재 읽는 글의 boardId, boardNo 를 insert
    DBInterface *db;
    db = [[DBInterface alloc] init];
    [db insertWithBoardId:m_boardId BoardNo:m_boardNo];
}

- (void)textViewDidChange:(UITextView *)textView;
{
    [tbView beginUpdates];
    [tbView endUpdates];
}

- (void)ArticleMenu
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* writecomment = [UIAlertAction actionWithTitle:@"댓글쓰기" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self WriteComment];
                                                   }];
    UIAlertAction* modify = [UIAlertAction actionWithTitle:@"글수정" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self ModifyArticle];
                                                   }];
    UIAlertAction* delete = [UIAlertAction actionWithTitle:@"글삭제" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self DeleteArticleConfirm];
                                                   }];
    
    UIAlertAction* showOnBrowser = [UIAlertAction actionWithTitle:@"웹브라우저로 보기" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self showOnBrowser];
                                                   }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        //action when pressed button
    }];
    
    [alert addAction:writecomment];
    [alert addAction:modify];
    [alert addAction:delete];
    [alert addAction:showOnBrowser];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contentSizeCategoryDidChangeNotification {
    [m_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:WWW_SERVER]];

    [self.tbView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            return UITableViewAutomaticDimension;
        } else if ([indexPath row] == 1) {
            return (float)m_lContentHeight;
        } else {
            return UITableViewAutomaticDimension;
        }
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	switch (section) {
		case 0 :
			return 2;
			break;
		case 1 :
			return [m_arrayItems count];
			break;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	NSString *strMsg;
	switch (section) {
		case 0 :
			return @"";
			break;
		case 1 :
			strMsg = [[NSString alloc] initWithFormat:@"%lu개의 댓글", (unsigned long)[m_arrayItems count]];
			return strMsg;
			break;
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifierTitle = @"Title";
	static NSString *CellIdentifierContent = @"Content";
	static NSString *CellIdentifierReply = @"Reply";
	static NSString *CellIdentifierReReply = @"ReReply";
	
    UIFont *titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFont *subFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
	long row = indexPath.row;
	long section = indexPath.section;
	
	UITableViewCell *cell;
	NSMutableDictionary *item;
	switch (section) {
		case 0 :
			if (row == 0) {
				cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle];
				if (cell == nil) {
					cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierTitle];
				}
				cell.showsReorderControl = YES;
				
				UITextView *textSubject = (UITextView *)[cell viewWithTag:101];
				textSubject.text = m_strTitle;
                [textSubject sizeToFit];
								
				UILabel *labelName = (UILabel *)[cell viewWithTag:100];
				NSString *strNameDate = [NSString stringWithFormat:@"%@  %@  %@명 읽음", m_strName, m_strDate, m_strHit];
				
				labelName.text = strNameDate;
                [textSubject setFont:titleFont];
                [labelName setFont:subFont];
			} else if (row == 1){
				m_contentCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierContent];
				if (m_contentCell == nil) {
					m_contentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierContent];
				}
				cell = m_contentCell;
				[cell addSubview:m_webView];
			}
			break;
		case 1 :
			item = [m_arrayItems objectAtIndex:[indexPath row]];
			if ([[item valueForKey:@"isRe"] intValue] == 1) {
				cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierReply];
				if (cell == nil) {
					cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierReply];
				}
				NSString *strName = [item valueForKey:@"name"];
				NSString *strDate = [item valueForKey:@"date"];
				NSString *strNameDate = [NSString stringWithFormat:@"%@  %@", strName, strDate];
				
				UILabel *labelName = (UILabel *)[cell viewWithTag:200];
				labelName.text = strNameDate;

				UITextView *viewComment = (UITextView *)[cell viewWithTag:202];
				viewComment.text = [item valueForKey:@"comment"];
                [viewComment sizeToFit];
								
                [labelName setFont:subFont];
                [viewComment setFont:titleFont];
                
				UIButton *buttonDelete = (UIButton *)[cell viewWithTag:211];
				[buttonDelete addTarget:self action:@selector(DeleteCommentConfirm:) forControlEvents:UIControlEventTouchUpInside];
			} else {
				cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierReReply];
				if (cell == nil) {
					cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierReReply];
				}
				
				NSString *strName = [item valueForKey:@"name"];
				NSString *strDate = [item valueForKey:@"date"];
				NSString *strNameDate = [NSString stringWithFormat:@"%@  %@", strName, strDate];
				
				UILabel *labelName = (UILabel *)[cell viewWithTag:300];
				labelName.text = strNameDate;
				
				UITextView *viewComment = (UITextView *)[cell viewWithTag:302];
				viewComment.text = [item valueForKey:@"comment"];
                [viewComment sizeToFit];
				
                [labelName setFont:subFont];
                [viewComment setFont:titleFont];

				UIButton *buttonDelete = (UIButton *)[cell viewWithTag:311];
				[buttonDelete addTarget:self action:@selector(DeleteCommentConfirm:) forControlEvents:UIControlEventTouchUpInside];
			}
			
			break;
	}
	return cell;
}

#pragma mark - WebView Delegate

- (void) webViewDidFinishLoad:(UIWebView *)sender {
    UIFont *titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    int pointSize = (titleFont.pointSize / 17.0f) * 100;
    NSString *fontSize = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", pointSize];
    NSString *padding = @"document.body.style.padding='0px 8px 0px 8px';";
    [sender stringByEvaluatingJavaScriptFromString:padding];
    [sender stringByEvaluatingJavaScriptFromString:fontSize];
    [self performSelector:@selector(calculateWebViewSize) withObject:nil afterDelay:0.1];
    [tbView beginUpdates];
    [tbView endUpdates];
}

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
	NSLog(@"request = %@", urlString);
	NSString *key = [Utils findStringRegex:urlString regex:@"(?<=&c=).*?(?=&)"];
	NSString *fileName = [m_dicAttach valueForKey:key];
	
	NSLog(@"fileName = %@", fileName);
	NSString *loweredExtension = [[fileName pathExtension] lowercaseString];
	NSLog(@"loweredExtension = %@", loweredExtension);
	// Valid extensions may change.  Check the UIImage class reference for the most up to date list.
	NSSet *validImageExtensions = [NSSet setWithObjects:@"tif", @"tiff", @"jpg", @"jpeg", @"gif", @"png", @"bmp", @"bmpf", @"ico", @"cur", @"xbm", nil];

	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		//	URLEncoding 되어 있지 않음.
		//		fileName = [fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		if ([validImageExtensions containsObject:loweredExtension]) {
			m_nFileType = FILE_TYPE_IMAGE;
			m_strWebLink = urlString;
			[self performSegueWithIdentifier:@"WebLink" sender:self];
		} else if ([loweredExtension hasSuffix:@"hwp"]|| [loweredExtension hasSuffix:@"pdf"]) {
			NSData	*tempData = [NSData dataWithContentsOfURL:url];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
			NSString *documentDirectory = [paths objectAtIndex:0];
			NSString *filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
			BOOL isWrite = [tempData writeToFile:filePath atomically:YES];
			NSString *tempFilePath;
			
			if (isWrite) {
				tempFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
			}
			NSURL *resultURL = [NSURL fileURLWithPath:tempFilePath];
			
			self.doic = [UIDocumentInteractionController interactionControllerWithURL:resultURL];
			self.doic.delegate = self;
			[self.doic presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
			return NO;
		} else {
            [[UIApplication sharedApplication] openURL:[request URL] options:@{} completionHandler:nil];
		}
			
		return NO;
	} else if (navigationType == UIWebViewNavigationTypeOther) {
		
		if ([[[request URL] absoluteString] hasPrefix:@"jscall:"]) {
			
			NSString *requestString = [[request URL] absoluteString];
			NSArray *components = [requestString componentsSeparatedByString:@"://"];
			NSString *functionName = [components objectAtIndex:1];

			NSLog(@"requestString = [%@]", requestString);
			NSLog(@"functionName = [%@]", functionName);
			
			NSString *fileName = [functionName stringByRemovingPercentEncoding];
			NSLog(@"fileName = [%@]", fileName);
			
			m_nFileType = FILE_TYPE_IMAGE;
			m_strWebLink = fileName;
			[self performSegueWithIdentifier:@"WebLink" sender:self];
			return NO;
		} else if ([loweredExtension hasSuffix:@"hwp"]|| [loweredExtension hasSuffix:@"pdf"]) {
			NSData	*tempData = [NSData dataWithContentsOfURL:url];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
			NSString *documentDirectory = [paths objectAtIndex:0];
			NSString *filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
			BOOL isWrite = [tempData writeToFile:filePath atomically:YES];
			NSString *tempFilePath;
			
			if (isWrite) {
				tempFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
			}
			NSURL *resultURL = [NSURL fileURLWithPath:tempFilePath];
			
			self.doic = [UIDocumentInteractionController interactionControllerWithURL:resultURL];
			self.doic.delegate = self;
			[self.doic presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
			return NO;
		} else {
			return YES;
		}
	}
	return YES;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long row = indexPath.row;
    long section = indexPath.section;
    if (section < 1) return;    // subject & content 에서 클릭되는 것은 무시한다.
    NSLog(@"selected section = %ld, row = %ld", section, row);
    
    NSMutableDictionary *item;
    item = [m_arrayItems objectAtIndex:[indexPath row]];
    
    NSString *strTitle = [NSString stringWithFormat:@"%@님의 댓글", [item valueForKey:@"name"]];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:strTitle
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
// moojigae_web 에서 comment modify 를 지원하지 않음.
/*
    UIAlertAction* modify = [UIAlertAction actionWithTitle:@"댓글수정" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self ModifyComment:row];
                                                   }];
*/
    UIAlertAction* delete = [UIAlertAction actionWithTitle:@"댓글삭제" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self DeleteCommentConfirm:row];
                                                   }];
    
    UIAlertAction* reply = [UIAlertAction actionWithTitle:@"댓글답변" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self WriteReComment:row];
                                                   }];
    
    UIAlertAction* copy = [UIAlertAction actionWithTitle:@"댓글복사" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self CopyComment:row];
                                                   }];
    
    UIAlertAction* share = [UIAlertAction actionWithTitle:@"댓글공유" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self ShareComment:row];
                                                   }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        //action when pressed button
    }];
    
//    [alert addAction:modify];
    [alert addAction:reply];
    [alert addAction:delete];
    [alert addAction:copy];
    [alert addAction:share];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - ArticleDataDelegate

- (void) alertWithError:(NSNumber *)nError
{
	if ([nError intValue] == RESULT_AUTH_FAIL) {
		NSLog(@"already login : auth fail");
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"권한오류"
																	   message:@"게시판을 볼 권한이 없습니다."
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
		[self presentViewController:alert animated:YES completion:nil];
	} else if ([nError intValue] == RESULT_LOGIN_FAIL) {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"로그인 오류"
																	   message:@"로그인 정보가 없거나 잘못되었습니다. 설정에서 로그인정보를 입력하세요."
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
		[self presentViewController:alert animated:YES completion:nil];
	}
}

#pragma mark Navigation Controller

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	if(item.tag==100)
	{
		[self DeleteArticleConfirm];
	}
}

#pragma mark - User Function

- (void)fetchItemsWithBoardId:(NSString *)boardId withBoardNo:(NSString *)boardNo
{
    NSString *url = [NSString stringWithFormat:@"%@/board-api-read.do", WWW_SERVER];
    NSLog(@"query = [%@]", url);
    
    m_boardId = boardId;
    m_boardNo = boardNo;
    
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    self.httpSessionRequest.httpMethod = @"GET";
    self.httpSessionRequest.tag = READ_ARTICLE;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:boardId, @"boardId",
                         boardNo, @"boardNo",
                         @"READ", @"command",
                         @"1", @"page",
                         @"-1", @"categoryId",
                         @"20", @"rid", nil];
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValues:dic withReferer:@""];
    
    
    m_arrayItems = [[NSMutableArray alloc] init];
    m_dicAttach = [[NSMutableDictionary alloc] init];
}

- (void)DeleteArticle:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo
{
    NSLog(@"DeleteArticleConfirm start");
    NSLog(@"boardID=[%@], boardNo=[%@]", strBoardNo, strArticleNo);

    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    self.httpSessionRequest.httpMethod = @"POST";
    self.httpSessionRequest.tag = DELETE_ARTICLE;
    
    NSString *url = [NSString stringWithFormat:@"%@/board-save.do", WWW_SERVER];
    NSLog(@"url = [%@]", url);

    NSString *postString = [NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&time=1334217622773&returnBoardNo=%@&boardNo=%@&command=DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1", strBoardNo, strArticleNo, strArticleNo];

    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValueString:postString withReferer:@""];
}

- (void)DeleteComment:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo commentNo:(NSString *)strCommentNo
{
    NSLog(@"DeleteArticleConfirm start");
    NSLog(@"boardID=[%@], boardNo=[%@]", strBoardNo, strArticleNo);

    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    self.httpSessionRequest.httpMethod = @"POST";
    self.httpSessionRequest.tag = DELETE_ARTICLE;
    
    NSString *url = [NSString stringWithFormat:@"%@/memo-save.do", WWW_SERVER];
    NSLog(@"url = [%@]", url);

    NSString *postString = [NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&time=&returnBoardNo=%@&boardNo=%@&command=MEMO_DELETE&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=710&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=&memoSeq=%@&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1", strBoardNo, strArticleNo, strArticleNo, strCommentNo];

    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValueString:postString withReferer:@""];
}

- (void) calculateWebViewSize {
    NSUInteger contentHeight = [[m_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollHeight;"]] intValue];
    m_lContentHeight = contentHeight;
    
    CGRect contentRect = m_contentCell.frame;
    contentRect.size.height = m_lContentHeight;
    m_contentCell.frame = contentRect;

    CGRect webRect = m_webView.frame;
    webRect.size.height = m_lContentHeight;
    m_webView.frame = webRect;

    [self.tbView reloadData];
}

- (void)showOnBrowser {
    NSString *url = [NSString stringWithFormat:@"%@/board-api-read.do?boardId=%@&boardNo=%@&command=READ&page=1&categoryId=-1&rid=20", WWW_SERVER, m_boardId, m_boardNo];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

- (void)CopyComment:(long)row
{
    NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
    NSString *strComment = [item valueForKey:@"comment"];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = strComment;
    
    NSString *message = @"댓글이 복사되었습니다.";

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [self presentViewController:alert animated:YES completion:nil];

    int duration = 1; // duration in seconds

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)ShareComment:(long)row
{
    NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
    NSString *strComment = [item valueForKey:@"comment"];
    
    NSMutableArray *shareItems = [[NSMutableArray alloc] init];
    [shareItems addObject:strComment];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop
, UIActivityTypeCopyToPasteboard
, UIActivityTypeMail
, UIActivityTypeMessage
, UIActivityTypePrint
]; //Exclude whichever aren't relevant
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)WriteComment
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    
    CommentWriteView *viewController = (CommentWriteView*)[storyboard instantiateViewControllerWithIdentifier:@"CommentWriteView"];
    if (viewController != nil) {
        viewController.m_nMode = [NSNumber numberWithInt:CommentWrite];
        viewController.m_boardId = m_boardId;
        viewController.m_boardNo = m_boardNo;
        viewController.m_strCommentNo = @"";
        viewController.m_strComment = @"";
        viewController.target = self;
        viewController.selector = @selector(didWrite:);
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)ModifyComment:(long)row
{
	NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    
    CommentWriteView *viewController = (CommentWriteView*)[storyboard instantiateViewControllerWithIdentifier:@"CommentWriteView"];
    if (viewController != nil) {
        viewController.m_nMode = [NSNumber numberWithInt:CommentModify];
        viewController.m_boardId = m_boardId;
        viewController.m_boardNo = m_boardNo;
        viewController.m_strCommentNo = [item valueForKey:@"no"];
        viewController.m_strComment = [item valueForKey:@"comment"];
        viewController.target = self;
        viewController.selector = @selector(didWrite:);
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)DeleteCommentConfirm:(long)row
{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
																   message:@"삭제하시겠습니까?"
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction * action) {
														[self DeleteComment:row];
													}];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction * action) {}];
	
	
	[alert addAction:okAction];
	[alert addAction:cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)DeleteComment:(long)row
{
	NSLog(@"DeleteArticleConfirm start");

	NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
	m_strCommentNo = [item valueForKey:@"no"];
	NSString *strCommentNo = m_strCommentNo;
	
    m_rowComment = row;
    [self DeleteComment:m_boardId articleNo:m_boardNo commentNo:strCommentNo];
}

- (void)WriteReComment:(long)row
{
    NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    
    CommentWriteView *viewController = (CommentWriteView*)[storyboard instantiateViewControllerWithIdentifier:@"CommentWriteView"];
    if (viewController != nil) {
        viewController.m_nMode = [NSNumber numberWithInt:CommentReply];
        viewController.m_boardId = m_boardId;
        viewController.m_boardNo = m_boardNo;
        viewController.m_strCommentNo = [item valueForKey:@"no"];
        viewController.m_strComment = @"";
        viewController.target = self;
        viewController.selector = @selector(didWrite:);
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)ModifyArticle
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    
    ArticleWriteView *viewController = (ArticleWriteView*)[storyboard instantiateViewControllerWithIdentifier:@"ArticleWriteView"];
    if (viewController != nil) {
        viewController.m_nMode = [NSNumber numberWithInt:ArticleModify];
        viewController.m_boardId = m_boardId;
        viewController.m_boardNo = m_boardNo;
        viewController.m_strTitle = m_strEditableTitle;
        viewController.m_strContent = m_strEditableContent;
        viewController.delegate = self;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)DeleteArticleConfirm
{
	NSLog(@"DeleteArticleConfirm start");

	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
																   message:@"삭제하시겠습니까?"
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction * action) {
														 [self DeleteArticle];
													 }];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction * action) {}];
	
	
	[alert addAction:okAction];
	[alert addAction:cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)DeleteArticle
{
	NSLog(@"DeleteArticleConfirm start");
	NSLog(@"boardID=[%@], boardNo=[%@]", m_boardId, m_boardNo);
	
    [self DeleteArticle:m_boardId articleNo:m_boardNo];
}

- (void)didWrite:(id)sender
{
	[m_arrayItems removeAllObjects];
	[self.tbView reloadData];
    [self fetchItemsWithBoardId:m_boardId withBoardNo:m_boardNo];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"WebLink"]) {
		WebLinkView *view = [segue destinationViewController];
		view.m_nFileType = [NSNumber numberWithInt:m_nFileType];
		view.m_strLink = m_strWebLink;
	}
}

#pragma mark - HttpSessionRequestDelegate

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest withError:(NSError *)error
{
}

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLodingData:(NSData *)data
{
    if (httpSessionRequest.tag == READ_ARTICLE) {
        [self readArticle:data];
    } else if (httpSessionRequest.tag == DELETE_ARTICLE) {
        [self deleteArticle:data];
    } else if (httpSessionRequest.tag == DELETE_COMMENT) {
        [self deleteComment:data];
    }
}

- (void) readArticle:(NSData *)data
{
    m_strHtml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"html = [%lu]", (unsigned long)[m_strHtml length]);
    
    // ./img/common/board/alert.gif 가 포함되어 있으면 다시 로그인해야 함.
    if ([Utils numberOfMatches:m_strHtml regex:@"./img/common/board/alert.gif"] > 0) {
        if (m_isLogin == FALSE) {
            NSLog(@"retry login");
            // 저장된 로그인 정보를 이용하여 로그인
            self.m_login = [[LoginToService alloc] init];
            self.m_login.delegate = self;
            [self.m_login LoginToService];
        } else {
            [self alertWithError:[NSNumber numberWithInt:RESULT_LOGIN_FAIL]];
        }
    }
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        return;
    }
    
    // Title, Name, Date, Hit
    
    m_strTitle = [parsedObject valueForKey:@"boardTitle"];
    m_strTitle = [m_strTitle stringByDecodingHTMLEntities];

    m_strName = [parsedObject valueForKey:@"userNick"];
    
    m_strDate = [parsedObject valueForKey:@"boardRegister_dt"];
    
    m_strHit = [parsedObject valueForKey:@"boardRead_cnt"];
    
    NSString *strContent = [parsedObject valueForKey:@"boardContent"];;
    
    m_strEditableContent = [Utils makeEditableContent:strContent];
    
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
//    [strHeader appendString:@"<style>body {font-family:\"고딕\";font-size:medium;}.title{text-margin:10px 0px;font-size:large}.name{color:gray;margin:10px 0px;font-size:small}.content{}.profile {text-align:left;color:gray;margin:10px 0px;font-size:small}.comment_header{text-align:left;color:white;background: lightgray;padding:20px 0px 10px 10px;font-size:small}.reply{border-bottom:1px solid gray;margin:10px 0px}.reply_header {color:gray;;font-size:small}.reply_content {margin:10px 0px}.re_reply{border-bottom:1px solid gray;margin:10px 0px 0px 20px;background:lightgray}</style>"];
    [strHeader appendString:@"<script>function myapp_clickImg(obj){window.location=\"jscall://\"+encodeURIComponent(obj.src);}</script>"];
    [strHeader appendString:@"</head>"];
    
//    [strHeader appendString:@"<script> \
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
//     [strHeader appendString:@"<script>window.onload=imageResize;</script></head>"];
    NSString *strBottom = @"</body></html>";
    //        String cssStr = "<link href=\"./css/default.css\" rel=\"stylesheet\">";
    NSString *strBody = @"<body>";
    
    /* 이미지 테크에 width 값과 click 시 javascript 를 호출하도록 수정한다. */
    m_strContent = [[NSString alloc] initWithFormat:@"%@%@%@%@%@<hr>%@%@",
                    strHeader,
                    strBody,
                    [strContent stringByReplacingOccurrencesOfString:@"<img " withString:@"<img onclick=\"myapp_clickImg(this)\" width=300 "],
                    [strImage stringByReplacingOccurrencesOfString:@"<img " withString:@"<img onclick=\"myapp_clickImg(this)\" width=300 "],
                    strAttach,
                    strProfile,
                    strBottom];
    
    htmlString = m_strContent;
    m_strEditableTitle = m_strTitle;
    NSLog(@"htmlString = [%@]", htmlString);
    
    m_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, m_contentCell.frame.size.width, m_contentCell.frame.size.height)];
    m_webView.delegate = self;
    m_webView.scrollView.scrollEnabled = YES;
    m_webView.scrollView.bounces = NO;
    m_webView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
    [m_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:WWW_SERVER]];

    [self.tbView reloadData];
}

- (void) deleteArticle:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    //history.go(-1);
    NSLog(@"returnData = [%@]", str);
    
    if ([Utils numberOfMatches:str regex:@"<b>시스템 메세지입니다</b>"] > 0) {
        NSString *errmsg = @"글을 삭제할 수 없습니다. 잠시후 다시 해보세요.";
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"글 삭제 오류"
                                                                       message:errmsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSLog(@"delete article success");
    if ([self.delegate respondsToSelector:@selector(articleView:didWrite:)] == YES)
        [self.delegate articleView:self didWrite:self];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) deleteComment:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    //history.go(-1);
    NSLog(@"returnData = [%@]", str);
    
    if ([Utils numberOfMatches:str regex:@"<b>시스템 메세지입니다</b>"] > 0) {
        NSString *errmsg = @"글을 삭제할 수 없습니다. 잠시후 다시 해보세요.";
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"글 삭제 오류"
                                                                       message:errmsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    // 삭제된 코멘트를 TableView에서 삭제한다.
    [m_arrayItems removeObjectAtIndex:m_rowComment];
    [self.tbView reloadData];

    NSLog(@"delete article success");
}

#pragma mark -
#pragma mark LoginToServiceDelegate

- (void) loginToService:(LoginToService *)loginToService withFail:(NSString *)result
{
    [self alertWithError:[NSNumber numberWithInt:RESULT_LOGIN_FAIL]];
}

- (void) loginToService:(LoginToService *)loginToService withSuccess:(NSString *)result
{
    m_isLogin = TRUE;
    [self fetchItemsWithBoardId:m_boardId withBoardNo:m_boardNo];
}
@end
