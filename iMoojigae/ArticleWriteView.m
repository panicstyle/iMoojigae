    //
//  WriteArticleViewController.m
//  iGongdong
//
//  Created by Panicstyle on 10. 10. 18..
//  Copyright 2010 이니라인. All rights reserved.
//

#import "ArticleWriteView.h"

@interface ArticleWriteView ()
{
	int m_bUpMode;
	UITextField *m_titleField;
	UITextView *m_contentView;
	long m_lContentHeight;
	UITableViewCell *m_contentCell;
	UITableViewCell *m_imageCell;
}

@end

@implementation ArticleWriteView
@synthesize m_nMode;
@synthesize m_strBoardNo;
@synthesize m_strArticleNo;
@synthesize m_strTitle;
@synthesize m_strContent;
@synthesize target;
@synthesize selector;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	m_bUpMode = false;
	
	if ([m_nMode intValue] == ArticleWrite) {
		[(UILabel *)self.navigationItem.titleView setText:@"글쓰기"];
	} else if ([m_nMode intValue] == ArticleModify) {
		[(UILabel *)self.navigationItem.titleView setText:@"글수정"];
	}

	CGRect rectScreen = [self getScreenFrameForCurrentOrientation];
	m_lContentHeight = rectScreen.size.height;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithTitle:@"완료"
											   style:UIBarButtonItemStyleDone
											   target:self
											   action:@selector(doneEditing:)];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:@"취소"
											  style:UIBarButtonItemStylePlain
											  target:self
											  action:@selector(cancelEditing:)];

	// Listen for keyboard appearances and disappearances
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification
											   object:nil];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)keyboardDidShow: (NSNotification *) notif{
	// Do something here
	[self animateTextView:notif up:YES];
}

- (void)keyboardDidHide: (NSNotification *) notif{
	// Do something here
	[self animateTextView:notif up:NO];
}

-(void)animateTextView:(NSNotification *)notif up:(BOOL)up
{
	if (m_bUpMode == up) return;
	
	NSDictionary* keyboardInfo = [notif userInfo];
	NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
	CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
	
	const int movementDistance = keyboardFrameBeginRect.size.height; // tweak as needed
	const float movementDuration = 0.3f; // tweak as needed
	
	int movement = (up ? -movementDistance : movementDistance);

	[UIView beginAnimations: @"animateTextView" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: movementDuration];
	
	CGRect viewRect = self.view.frame;
	viewRect.size.height = viewRect.size.height + movement;
	self.view.frame = viewRect;
	
//	CGRect tableRect = self.tbView.frame;
//	tableRect.size.height = tableRect.size.height + movement;
//	self.tbView.frame = tableRect;
	
	CGRect contentRect = m_contentCell.frame;
	contentRect.size.height = contentRect.size.height + movement;
	m_contentCell.frame = contentRect;

	[self.tbView beginUpdates];
	[self.tbView endUpdates];
	
//	CGRect textRect = m_contentView.frame;
//	textRect.size.height = textRect.size.height + movement;
//	m_contentView.frame = textRect;
	
//	CGRect imageRect = m_imageCell.frame;
//	imageRect.size.height = imageRect.size.height;
//	m_imageCell.frame = imageRect;

	[UIView commitAnimations];
	m_bUpMode = up;
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

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath row] == 0) {
		return 40.0f;
	} else if ([indexPath row] == 1) {
		return (float)m_lContentHeight;
	} else {
		return 40.0f;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifierTitle = @"Title";
	static NSString *CellIdentifierContent = @"Content";
	static NSString *CellIdentifierImage = @"Image";
	
	UITableViewCell *cell;
	if ([indexPath row] == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierTitle];
		}
		m_titleField = (UITextField *)[cell viewWithTag:100];
		m_titleField.text = m_strTitle;
		return cell;
	} else if ([indexPath row] == 1){
		m_contentCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierContent];
		if (m_contentCell == nil) {
			m_contentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierContent];
		}
		m_contentView = (UITextView *)[m_contentCell viewWithTag:101];
		m_contentView.text = m_strContent;
		return m_contentCell;
	} else {
		m_imageCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierImage];
		if (m_imageCell == nil) {
			m_imageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierImage];
		}
		m_imageCell.textLabel.text = @"Image Line";
		return m_imageCell;
	}
}


- (void) cancelEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void) doneEditing:(id)sender
{
	if (m_titleField.text.length <= 0 || m_contentView.text.length <= 0) {
		// 쓰여진 내용이 없으므로 저장하지 않는다.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"확인"
														message:@"입력된 내용이 없습니다."
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:nil];
		[alert addButtonWithTitle:@"확인"];
		[alert show];
		return;
	}
	
	NSString *url = [NSString stringWithFormat:@"%@/board-save.do",
					 WWW_SERVER];
	
	//        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"http://121.134.211.159/board-edit.do" forHTTPHeaderField:@"Referer"];
	[request addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"ko,en-US;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
	[request addValue:@"windows-949,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
	
	/*
	 Accept-Encoding: gzip,deflate,sdch
	 Accept-Language: ko,en-US;q=0.8,en;q=0.6
	 Accept-Charset: windows-949,utf-8;q=0.7,*;q=0.3
	 */
	
	//        NSMutableData *body = [[NSMutableData data] autorelease];
	//        NSMutableData *body = [NSMutableData data];
	// usetag = n
	NSLog(@"boardID = %%7 [%@], subjectField.text=[%@], contentField.text=[%@]", m_strBoardNo, m_titleField.text, m_contentView.text);
	
	NSString *strCommand;
	if ([m_nMode intValue] == ArticleWrite) {
		strCommand = @"WRITE";
	} else {
		strCommand = @"MODIFY";
	}
	// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\n" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
	NSString *newContent = [regex stringByReplacingMatchesInString:m_contentView.text options:0 range:NSMakeRange(0, [m_contentView.text length]) withTemplate:@"<br />"];
	
	NSString *bodyString = [NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&boardNo=%@&command=%@&htmlImage=%%2Fout&file_cnt=5&tag_yn=Y&thumbnailSize=50&boardWidth=710&defaultBoardSkin=default&boardBackGround_color=&boardBackGround_picture=&boardSerialBadNick=&boardSerialBadContent=&totalSize=20&serialBadNick=&serialBadContent=&fileTotalSize=0&simpleFileTotalSize=0+Bytes&serialFileName=&serialFileMask=&serialFileSize=&userPoint=2530&userEmail=panicstyle%%40gmail.com&userHomepage=&boardPollFrom_time=&boardPollTo_time=&boardContent=%@&boardTitle=%@&boardSecret_fg=N&boardEdit_fg=M&userNick=&userPw=&fileName=&fileMask=&fileSize=&pollContent=&boardPoint=0&boardTop_fg=&totalsize=0&tag=0&tagsName=", m_strBoardNo, m_strArticleNo, strCommand, newContent, m_titleField.text];
	
	NSLog(@"bodyString = [%@]", bodyString);
	
	NSData *body = [[NSData alloc] initWithData:[bodyString dataUsingEncoding:0x80000000 + kCFStringEncodingEUC_KR]];
	
	[request setHTTPBody:body];
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	//        NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:0x80000000 + kCFStringEncodingEUC_KR] autorelease];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:0x80000000 + kCFStringEncodingEUC_KR];
	
	NSLog(@"returnString = [%@]", returnString);
	
	regex = [NSRegularExpression regularExpressionWithPattern:@"parent\\.checkLogin()" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
	NSUInteger numberOfMatches = [regex numberOfMatchesInString:returnString options:0 range:NSMakeRange(0, [returnString length])];
	
	if (numberOfMatches <= 0) {
		NSString *errmsg;
		errmsg = @"글 작성중 오류가 발생했습니다. 잠시후 다시 해보세요.";
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"글 작성 오류"
														message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
		return;
	}
	
	NSLog(@"write article success");
	[target performSelector:selector withObject:nil];
	
	[[self navigationController] popViewControllerAnimated:YES];
}

@end
