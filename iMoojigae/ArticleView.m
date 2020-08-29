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
#import "ArticleData.h"
#import "WebLinkView.h"
#import "DBInterface.h"
@import GoogleMobileAds;

@interface ArticleView ()
{
	UITableViewCell *m_contentCell;
	UITableViewCell *m_imageCell;
	UITableViewCell *m_replyCell;
	
	CGRect m_rectScreen;
	
	NSMutableArray *m_arrayItems;
	NSDictionary *m_dicAttach;
	long m_lContentHeight;
	float m_fTitleHeight;
	
	UIWebView *m_webView;
	ArticleData *m_articleData;
	
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
	
}
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
@synthesize target;
@synthesize selector;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = m_boardName;
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	self.navigationItem.titleView = lblTitle;

	buttonArticleMenu.target = self;
	buttonArticleMenu.action = @selector(ArticleMenu);
	
	m_lContentHeight = 300;
	m_rectScreen = [self getScreenFrameForCurrentOrientation];
	
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

	m_articleData = [[ArticleData alloc] init];
	m_articleData.m_boardId = m_boardId;
	m_articleData.m_boardNo = m_boardNo;
	m_articleData.target = self;
	m_articleData.selector = @selector(didFetchItems:);
	[m_articleData fetchItems];
    
    // DB에 현재 읽는 글의 boardId, boardNo 를 insert
    DBInterface *db;
    db = [[DBInterface alloc] init];
    [db insertWithBoardId:m_boardId BoardNo:m_boardNo];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//	[self.tbView beginUpdates];
//	[self.tbView endUpdates];
	[self.tbView reloadData];
}

- (CGRect)getScreenFrameForCurrentOrientation {
	return [self getScreenFrameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGRect)getScreenFrameForOrientation:(UIInterfaceOrientation)orientation {
	
	CGRect fullScreenRect = [[UIScreen mainScreen] bounds];
	
	// implicitly in Portrait orientation.
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		CGRect temp = CGRectZero;
		temp.size.width = fullScreenRect.size.height;
		temp.size.height = fullScreenRect.size.width;
		fullScreenRect = temp;
	}
	
	CGFloat statusBarHeight = 20; // Needs a better solution, FYI statusBarFrame reports wrong in some cases..
	fullScreenRect.size.height -= statusBarHeight;
	fullScreenRect.size.height -= self.navigationController.navigationBar.frame.size.height;
	fullScreenRect.size.height -= 40 + 40;
	
	return fullScreenRect;
}
/*
- (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
	if ([textView respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
	{
		// This is the code for iOS 7. contentSize no longer returns the correct value, so
		// we have to calculate it.
		//
		// This is partly borrowed from HPGrowingTextView, but I've replaced the
		// magic fudge factors with the calculated values (having worked out where
		// they came from)
		
		CGRect frame = textView.bounds;
		
		// Take account of the padding added around the text.
		
		UIEdgeInsets textContainerInsets = textView.textContainerInset;
		UIEdgeInsets contentInsets = textView.contentInset;
		
		CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
		CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
		
		frame.size.width -= leftRightPadding;
		frame.size.height -= topBottomPadding;
		
		NSString *textToMeasure = textView.text;
		if ([textToMeasure hasSuffix:@"\n"])
		{
			textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
		}
		
		// NSString class method: boundingRectWithSize:options:attributes:context is
		// available only on ios7.0 sdk.
		
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
		
		NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
		
		CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:attributes
												  context:nil];
		
		CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
		return measuredHeight;
	}
	else
	{
		return textView.contentSize.height;
	}
}
*/
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        //action when pressed button
    }];
    
    [alert addAction:writecomment];
    [alert addAction:modify];
    [alert addAction:delete];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
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
				
				UIButton *buttonDelete = (UIButton *)[cell viewWithTag:311];
				[buttonDelete addTarget:self action:@selector(DeleteCommentConfirm:) forControlEvents:UIControlEventTouchUpInside];
			}
			
			break;
	}
	return cell;
}

#pragma mark - WebView Delegate

- (void) webViewDidFinishLoad:(UIWebView *)sender {
	NSString *padding = @"document.body.style.padding='0px 8px 0px 8px';";
	[sender stringByEvaluatingJavaScriptFromString:padding];
	[self performSelector:@selector(calculateWebViewSize) withObject:nil afterDelay:0.1];
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
			[[UIApplication sharedApplication] openURL:[request URL]];
		}
			
		return NO;
	} else if (navigationType == UIWebViewNavigationTypeOther) {
		
		if ([[[request URL] absoluteString] hasPrefix:@"jscall:"]) {
			
			NSString *requestString = [[request URL] absoluteString];
			NSArray *components = [requestString componentsSeparatedByString:@"://"];
			NSString *functionName = [components objectAtIndex:1];

			NSLog(@"requestString = [%@]", requestString);
			NSLog(@"functionName = [%@]", functionName);
			
			NSString *fileName = [functionName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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


#pragma mark Data Function

- (void)didFetchItems:(NSNumber *)result
{
	if ([result intValue] == RESULT_AUTH_FAIL) {
		NSLog(@"already login : auth fail");
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"권한오류"
																	   message:@"게시판을 볼 권한이 없습니다."
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
		[self presentViewController:alert animated:YES completion:nil];
	} else if ([result intValue] == RESULT_LOGIN_FAIL) {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"로그인 오류"
																	   message:@"로그인 정보가 없거나 잘못되었습니다. 설정에서 로그인정보를 입력하세요."
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		htmlString = m_articleData.m_strContent;
		m_strEditableContent = m_articleData.m_strEditableContent;
		m_strEditableTitle = m_articleData.m_strTitle;
		m_strTitle = m_articleData.m_strTitle;
		m_strName = m_articleData.m_strName;
		m_strDate = m_articleData.m_strDate;
		m_strHit = m_articleData.m_strHit;
		
		m_arrayItems = m_articleData.m_arrayItems;
		m_dicAttach = m_articleData.m_dicAttach;
		
		NSLog(@"htmlString = [%@]", htmlString);
		
		m_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, m_contentCell.frame.size.width, m_contentCell.frame.size.height)];
		m_webView.delegate = self;
		m_webView.scrollView.scrollEnabled = YES;
		m_webView.scrollView.bounces = NO;
        m_webView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
		[m_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:WWW_SERVER]];

		[self.tbView reloadData];
	}
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

#pragma mark Navigation Controller

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	if(item.tag==100)
	{
		[self DeleteArticleConfirm];
	}
}

#pragma mark WriteComment
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
	
	bool result = [m_articleData DeleteComment:m_boardId articleNo:m_boardNo commentNo:strCommentNo];

	if (result == false) {
		NSString *errmsg = @"글을 삭제할 수 없습니다. 잠시후 다시 해보세요.";
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"글 삭제 오류"
														message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
		return;
	}

	// 삭제된 코멘트를 TableView에서 삭제한다.
	[m_arrayItems removeObjectAtIndex:row];
	[self.tbView reloadData];

	NSLog(@"delete article success");
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
        viewController.target = self;
        viewController.selector = @selector(didWrite:);
        
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
	
	bool result = [m_articleData DeleteArticle:m_boardId articleNo:m_boardNo];
	
	if (result == false) {
        NSString *errmsg = @"글을 삭제할 수 없습니다. 잠시후 다시 해보세요.";
		
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"글 삭제 오류"
																	   message:errmsg
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
        return;
    }
    
    NSLog(@"delete article success");
	if (target != nil) {
		[target performSelector:selector withObject:nil afterDelay:0];
	}
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)didWrite:(id)sender
{
	[m_arrayItems removeAllObjects];
	[self.tbView reloadData];
	[m_articleData fetchItems];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
/*	if ([[segue identifier] isEqualToString:@"Comment"]) {
		CommentWriteView *view = [segue destinationViewController];
		view.m_nMode = [NSNumber numberWithInt:CommentWrite];
		view.m_boardId = m_boardId;
		view.m_boardNo = m_boardNo;
		view.m_strCommentNo = @"";
		view.m_strComment = @"";
		view.target = self;
		view.selector = @selector(didWrite:);
	} else if ([[segue identifier] isEqualToString:@"CommentModify"]) {
		UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
		NSIndexPath *clickedButtonPath = [self.tbView indexPathForCell:clickedCell];
//		[self tableView:self.tbView didSelectRowAtIndexPath:clickedButtonPath];
		
		CommentWriteView *view = [segue destinationViewController];
//		NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
		long row = clickedButtonPath.row;
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
		view.m_nMode = [NSNumber numberWithInt:CommentModify];
		view.m_boardId = m_boardId;
		view.m_boardNo = m_boardNo;
		view.m_strCommentNo = [item valueForKey:@"no"];
		view.m_strComment = [item valueForKey:@"comment"];
		view.target = self;
		view.selector = @selector(didWrite:);
	} else if ([[segue identifier] isEqualToString:@"CommentReply"]) {
		UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
		NSIndexPath *clickedButtonPath = [self.tbView indexPathForCell:clickedCell];
//		[self tableView:self.tbView didSelectRowAtIndexPath:clickedButtonPath];

		CommentWriteView *view = [segue destinationViewController];
//		NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
		long row = clickedButtonPath.row;
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
		view.m_nMode = [NSNumber numberWithInt:CommentReply];
		view.m_boardId = m_boardId;
		view.m_boardNo = m_boardNo;
		view.m_strCommentNo = [item valueForKey:@"no"];
		view.m_strComment = @"";
		view.target = self;
		view.selector = @selector(didWrite:);
	} else if ([[segue identifier] isEqualToString:@"ArticleModify"]) {
		ArticleWriteView *view = [segue destinationViewController];
		view.m_nMode = [NSNumber numberWithInt:ArticleModify];
		view.m_boardId = m_boardId;
		view.m_boardNo = m_boardNo;
		view.m_strTitle = m_strEditableTitle;
		view.m_strContent = m_strEditableContent;
		view.target = self;
		view.selector = @selector(didWrite:);
	} else */ if ([[segue identifier] isEqualToString:@"WebLink"]) {
		WebLinkView *view = [segue destinationViewController];
		view.m_nFileType = [NSNumber numberWithInt:m_nFileType];
		view.m_strLink = m_strWebLink;
	}
}
@end
