    //
//  WriteArticleViewController.m
//  iGongdong
//
//  Created by Panicstyle on 10. 10. 18..
//  Copyright 2010 이니라인. All rights reserved.
//

#import "ArticleWriteView.h"
#import "Utils.h"

@interface ArticleWriteView ()
{
	int m_bUpMode;
	long m_lContentHeight;
	UIAlertView *alertWait;
	int m_selectedImage;
	int m_ImageStatus[5];
}

@end

@implementation ArticleWriteView
@synthesize viewTitle;
@synthesize viewContent;
@synthesize viewImage0;
@synthesize viewImage1;
@synthesize viewImage2;
@synthesize viewImage3;
@synthesize viewImage4;
@synthesize m_nMode;
@synthesize m_boardId;
@synthesize m_boardNo;
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
	
	viewImage0.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	viewImage1.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	viewImage2.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	viewImage3.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	viewImage4.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	m_ImageStatus[0] = 0;
	m_ImageStatus[1] = 0;
	m_ImageStatus[2] = 0;
	m_ImageStatus[3] = 0;
	m_ImageStatus[4] = 0;
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
	NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
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
	
	CGRect contentRect = viewContent.frame;
	contentRect.size.height = contentRect.size.height + movement;
	viewContent.frame = contentRect;

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

- (void)AlertShow
{
	alertWait = [[UIAlertView alloc] initWithTitle:@"저장중입니다." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
	[alertWait show];
	
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(alertWait.bounds.size.width / 2, alertWait.bounds.size.height - 50);
	[indicator startAnimating];
	[alertWait addSubview:indicator];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)AlertDismiss
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[alertWait dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) cancelEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void) doneEditing:(id)sender
{
	if (viewTitle.text.length <= 0 || viewContent.text.length <= 0) {
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
	
	[self AlertShow];
	
	NSString *url = [NSString stringWithFormat:@"%@/board-save.do",
					 WWW_SERVER];
	
	//        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSString *strReferer = [NSString stringWithFormat:@"%@/board-edit.do", WWW_SERVER];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request addValue:strReferer forHTTPHeaderField:@"Referer"];
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
	NSLog(@"boardID = %%7 [%@], subjectField.text=[%@], contentField.text=[%@]", m_boardId, viewTitle.text, viewContent.text);
	
	NSString *strCommand;
	if ([m_nMode intValue] == ArticleWrite) {
		strCommand = @"WRITE";
	} else {
		strCommand = @"MODIFY";
	}
	// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\n" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
	NSString *newContent = [regex stringByReplacingMatchesInString:viewContent.text options:0 range:NSMakeRange(0, [viewContent.text length]) withTemplate:@"<br />"];
	
	NSString *bodyString = [NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&boardNo=%@&command=%@&htmlImage=%%2Fout&file_cnt=5&tag_yn=Y&thumbnailSize=50&boardWidth=710&defaultBoardSkin=default&boardBackGround_color=&boardBackGround_picture=&boardSerialBadNick=&boardSerialBadContent=&totalSize=20&serialBadNick=&serialBadContent=&fileTotalSize=0&simpleFileTotalSize=0+Bytes&serialFileName=&serialFileMask=&serialFileSize=&userPoint=2530&userEmail=panicstyle%%40gmail.com&userHomepage=&boardPollFrom_time=&boardPollTo_time=&boardContent=%@&boardTitle=%@&boardSecret_fg=N&boardEdit_fg=M&userNick=&userPw=&fileName=&fileMask=&fileSize=&pollContent=&boardPoint=0&boardTop_fg=&totalsize=0&tag=0&tagsName=", m_boardId, m_boardNo, strCommand, newContent, viewTitle.text];
	
	NSLog(@"bodyString = [%@]", bodyString);
	
	NSData *body = [[NSData alloc] initWithData:[bodyString dataUsingEncoding:g_encodingOption]];
	
	[request setHTTPBody:body];
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	//        NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:g_encodingOption] autorelease];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:g_encodingOption];
	
	NSLog(@"returnString = [%@]", returnString);
	
	[self AlertDismiss];
	
	if ([Utils numberOfMatches:returnString regex:@"<b>시스템 메세지입니다</b>"] > 0) {
		NSString *errmsg;
		NSString *errmsg2 = [Utils findStringRegex:returnString regex:@"(?<=<b>시스템 메세지입니다</b></font><br>).*?(?=<br>)"];
		errmsg = [NSString stringWithFormat:@"글 작성중 오류가 발생했습니다. 잠시후 다시 해보세요.[%@]", errmsg2];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"글 작성 오류"
														message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
		return;
	}
	
	NSLog(@"write article success");
	[target performSelector:selector withObject:nil];
	
	[[self navigationController] popViewControllerAnimated:YES];
}
- (IBAction)AddImage:(id)sender {
	NSLog(@"AddImage Push");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//You can retrieve the actual UIImage
	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	//Or you can get the image url from AssetsLibrary
	NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
	
	if (m_selectedImage == 0) {
		viewImage0.image = image;
		m_ImageStatus[0] = 1;
	} else if (m_selectedImage == 1) {
		viewImage1.image = image;
		m_ImageStatus[1] = 1;
	} else if (m_selectedImage == 2) {
		viewImage2.image = image;
		m_ImageStatus[2] = 1;
	} else if (m_selectedImage == 3) {
		viewImage3.image = image;
		m_ImageStatus[3] = 1;
	} else if (m_selectedImage == 4) {
		viewImage4.image = image;
		m_ImageStatus[4] = 1;
	}
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	int imageStatus;
	UIImageView *viewImage;
	if ([touch view] == viewImage0) {
		NSLog(@"viewImage1 touched");
		m_selectedImage = 0;
		imageStatus = m_ImageStatus[0];
		viewImage = viewImage0;
	} else if ([touch view] == viewImage1) {
		NSLog(@"viewImage2 touched");
		m_selectedImage = 1;
		imageStatus = m_ImageStatus[1];
		viewImage = viewImage1;
	} else if ([touch view] == viewImage2) {
		NSLog(@"viewImage3 touched");
		m_selectedImage = 2;
		imageStatus = m_ImageStatus[2];
		viewImage = viewImage2;
	} else if ([touch view] == viewImage3) {
		NSLog(@"viewImage4 touched");
		m_selectedImage = 3;
		imageStatus = m_ImageStatus[3];
		viewImage = viewImage3;
	} else if ([touch view] == viewImage4) {
		NSLog(@"viewImage5 touched");
		m_selectedImage = 4;
		imageStatus = m_ImageStatus[4];
		viewImage = viewImage4;
	}
	if (imageStatus == 0) {
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.delegate = self;
		[self presentViewController:imagePickerController animated:YES completion:nil];
	} else {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
																	   message:@"삭제하시겠습니까?"
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction * action) {
															 [self DeleteImage];
														 }];
		UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
															 handler:^(UIAlertAction * action) {}];
		
		
		[alert addAction:okAction];
		[alert addAction:cancelAction];
		[self presentViewController:alert animated:YES completion:nil];
	}
}

- (void)DeleteImage {
	if (m_selectedImage == 0) {
		viewImage0.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[0] = 0;
	} else if (m_selectedImage == 1) {
		viewImage1.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[1] = 0;
	} else if (m_selectedImage == 2) {
		viewImage2.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[2] = 0;
	} else if (m_selectedImage == 3) {
		viewImage3.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[3] = 0;
	} else if (m_selectedImage == 4) {
		viewImage4.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[4] = 0;
	}
}


@end
