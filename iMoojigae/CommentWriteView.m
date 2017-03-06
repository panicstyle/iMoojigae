//
//  CommentWriteView.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//


#import "CommentWriteView.h"
#import "Utils.h"
#import "env.h"

@interface CommentWriteView () {
	NSString *m_strErrorMsg;
	long m_lContentHeight;
	UIAlertView *alertWait;
}
@end

@implementation CommentWriteView
@synthesize m_nMode;
@synthesize m_textView;
@synthesize m_boardId;
@synthesize m_boardNo;
@synthesize m_strCommentNo;
@synthesize m_strComment;
@synthesize target;
@synthesize selector;

- (CommentWriteView *) initWithBoard:(NSString *)boardId boardNo:(NSString *)boardNo Comment:(NSString *)strCommentNo
{
	////NSLog(@"WriteArticleViewController start");
	m_boardId = boardId;
	m_boardNo = boardNo;
	m_strCommentNo = strCommentNo;
	
	return self;
}

- (void)setDelegate:(id)aTarget selector:(SEL)aSelector
{
	// 데이터 수신이 완료된 이후에 호출될 메서드의 정보를 담고 있는 셀렉터 설정
	self.target = aTarget;
	self.selector = aSelector;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

- (void)viewDidLoad
{
	m_strErrorMsg = @"";
	
	CGRect rectScreen = [self getScreenFrameForCurrentOrientation];
	m_lContentHeight = rectScreen.size.height;
	
	if ([m_nMode intValue] == CommentWrite) {
		[(UILabel *)self.navigationItem.titleView setText:@"댓글쓰기"];
	} else if ([m_nMode intValue] == CommentModify) {
		[(UILabel *)self.navigationItem.titleView setText:@"댓글수정"];
		m_textView.text = m_strComment;
	} else {
		[(UILabel *)self.navigationItem.titleView setText:@"댓글답변쓰기"];
	}
	
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


	// Prepare the Navigation Item
	[(UILabel *)self.navigationItem.titleView setBackgroundColor:[UIColor clearColor]];
	[(UILabel *)self.navigationItem.titleView setTextColor:[UIColor whiteColor]];
	[(UILabel *)self.navigationItem.titleView setTextAlignment:NSTextAlignmentCenter];
	[(UILabel *)self.navigationItem.titleView setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
}

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
	
	//	CGRect tableRect = self.tbView.frame;
	//	tableRect.size.height = tableRect.size.height + movement;
	//	self.tbView.frame = tableRect;
	
	CGRect contentRect = m_textView.frame;
	contentRect.size.height = contentRect.size.height + movement;
	m_textView.frame = contentRect;
	
	//	CGRect textRect = m_contentView.frame;
	//	textRect.size.height = textRect.size.height + movement;
	//	m_contentView.frame = textRect;
	
	//	CGRect imageRect = m_imageCell.frame;
	//	imageRect.size.height = imageRect.size.height;
	//	m_imageCell.frame = imageRect;
	
	[UIView commitAnimations];
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

- (void) cancelEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	[[self navigationController] popViewControllerAnimated:YES];
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

- (void)doneEditing:(id)sender
{
	BOOL result = [self writeComment];
	
	if (result) {
		[target performSelector:selector withObject:nil afterDelay:0];
		[[self navigationController] popViewControllerAnimated:YES];
	} else {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"댓글 쓰기 오류"
																	   message:m_strErrorMsg
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
	}
}

- (BOOL)writeComment
{
	[self AlertShow];

	NSString *strContent = self.m_textView.text;
	
	NSString *url;
	url = [NSString stringWithFormat:@"%@/memo-save.do", WWW_SERVER];
	NSLog(@"url = [%@]", url);
    
    NSString *referer;
    
    if ([m_nMode intValue] == CommentReply) {
        referer = [NSString stringWithFormat:@"%@/board-api-read.do", WWW_SERVER];
    } else {		// CommentWrite
        referer = [NSString stringWithFormat:@"%@/board-api-read.do?boardId=%@&boardNo=%@&command=READ&page=1&categoryId=-1", WWW_SERVER, m_boardId, m_boardNo];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request addValue:referer forHTTPHeaderField:@"Referer"];
    [request addValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
    [request addValue:@"ko,en-US;q=0.8,en;q=0.6" forHTTPHeaderField:@"Accept-Language"];
    [request addValue:@"windows-949,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];

    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\n" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSString *newContent = [regex stringByReplacingMatchesInString:strContent options:0 range:NSMakeRange(0, [strContent length]) withTemplate:@"<br />"];
    
    NSMutableData *body = [NSMutableData data];
    // usetag = n
    
    NSString *strCommand;
    if ([m_nMode intValue] == CommentReply) {
        strCommand = @"MEMO_REPLY";
    } else {	// CommentWrite
        strCommand = @"MEMO_WRITE";
	}
	
	NSString *strCommentNo;
	strCommentNo = m_strCommentNo;
	
	NSString *bodyString = [NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&time=&returnBoardNo=%@&boardNo=%@&command=%@&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=690&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=%@&memoSeq=%@&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1", m_boardId, m_boardNo, m_boardNo, strCommand, newContent, strCommentNo];
    
    NSLog(@"bodyString = [%@]", bodyString);
    
    [body appendData:[bodyString dataUsingEncoding:g_encodingOption]];
    
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:g_encodingOption];
    
    NSLog(@"returnString = [%@]", returnString);
    
	[self AlertDismiss];
	
	if ([Utils numberOfMatches:returnString regex:@"<b>시스템 메세지입니다</b>"] > 0) {
		NSString *errmsg;
		NSString *errmsg2 = [Utils findStringRegex:returnString regex:@"(?<=<b>시스템 메세지입니다</b></font><br>).*?(?=<br>)"];
		errmsg = [NSString stringWithFormat:@"댓글 작성중 오류가 발생했습니다. 잠시후 다시 해보세요.[%@]", errmsg2];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"댓글 작성 오류"
														message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
		return false;
	}
	return true;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
@end
