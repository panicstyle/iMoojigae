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
#import "HttpSessionRequest.h"

@interface CommentWriteView () <HttpSessionRequestDelegate> {
	int m_bUpMode;
	NSString *m_strErrorMsg;
	long m_lContentHeight;
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
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

- (void)viewDidLoad
{
	m_strErrorMsg = @"";
	m_bUpMode = false;
	
	UILabel *lblTitle = [[UILabel alloc] init];

	if ([m_nMode intValue] == CommentWrite) {
		lblTitle.text = @"댓글쓰기";
	} else if ([m_nMode intValue] == CommentModify) {
		lblTitle.text = @"댓글수정";
		m_textView.text = m_strComment;
	} else {
		lblTitle.text = @"댓글답변쓰기";
	}
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	self.navigationItem.titleView = lblTitle;
	
//	CGRect rectScreen = [self getScreenFrameForCurrentOrientation];
//	m_lContentHeight = rectScreen.size.height;
	
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryDidChangeNotification)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];

    UIFont *titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    m_textView.font = titleFont;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contentSizeCategoryDidChangeNotification {
    UIFont *titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    m_textView.font = titleFont;
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
	
	CGRect contentRect = m_textView.frame;
	contentRect.size.height = contentRect.size.height + movement;
	m_textView.frame = contentRect;
	
	[UIView commitAnimations];
	m_bUpMode = up;
}

- (void) cancelEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	[[self navigationController] popViewControllerAnimated:YES];
}	

- (void)AlertShow
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

- (void)AlertDismiss
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
}

- (void)doneEditing:(id)sender
{
    [self writeComment];
}

- (void)writeComment
{
	[self AlertShow];

	NSString *strContent = self.m_textView.text;
	
	NSString *url = [NSString stringWithFormat:@"%@/memo-save.do", WWW_SERVER];

	NSLog(@"url = [%@]", url);
    
    NSString *strReferer;
    
    if ([m_nMode intValue] == CommentReply) {
        strReferer = [NSString stringWithFormat:@"%@/board-api-read.do", WWW_SERVER];
    } else {		// CommentWrite
        strReferer = [NSString stringWithFormat:@"%@/board-api-read.do?boardId=%@&boardNo=%@&command=READ&page=1&categoryId=-1", WWW_SERVER, m_boardId, m_boardNo];
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\n" options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSString *newContent = [regex stringByReplacingMatchesInString:strContent options:0 range:NSMakeRange(0, [strContent length]) withTemplate:@"<br />"];
    NSString *escapedContent = [newContent stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    NSString *strCommand;
    if ([m_nMode intValue] == CommentReply) {
        strCommand = @"MEMO_REPLY";
    } else {	// CommentWrite
        strCommand = @"MEMO_WRITE";
	}
	
	NSString *strCommentNo;
	strCommentNo = m_strCommentNo;
	
	NSString *bodyString = [NSString stringWithFormat:@"boardId=%@&page=1&categoryId=-1&time=&returnBoardNo=%@&boardNo=%@&command=%@&totalPage=0&totalRecords=0&serialBadNick=&serialBadContent=&htmlImage=%%2Fout&thumbnailSize=50&memoWriteable=true&list_yn=N&replyList_yn=N&defaultBoardSkin=default&boardWidth=690&multiView_yn=Y&titleCategory_yn=N&category_yn=N&titleNo_yn=Y&titleIcon_yn=N&titlePoint_yn=N&titleMemo_yn=Y&titleNew_yn=Y&titleThumbnail_yn=N&titleNick_yn=Y&titleTag_yn=Y&anonymity_yn=N&titleRead_yn=Y&boardModel_cd=A&titleDate_yn=Y&tag_yn=Y&thumbnailSize=50&readOver_color=%%23336699&boardSerialBadNick=&boardSerialBadContent=&userPw=&userNick=&memoContent=%@&memoSeq=%@&pollSeq=&returnURI=&beforeCommand=&starPoint=&provenance=board-read.do&tagsName=&pageScale=&searchOrKey=&searchType=&tag=1", m_boardId, m_boardNo, m_boardNo, strCommand, escapedContent, strCommentNo];
    
    NSLog(@"bodyString = [%@]", bodyString);
    
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    self.httpSessionRequest.httpMethod = @"POST";
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValueString:bodyString withReferer:strReferer];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - HttpSessionRequestDelegate

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest withError:(NSError *)error
{
}

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLodingData:(NSData *)data
{
    NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"returnString = [%@]", returnString);
    
    [self AlertDismiss];
    
    if ([Utils numberOfMatches:returnString regex:@"<b>시스템 메세지입니다</b>"] > 0) {
        NSString *errmsg;
        NSString *errmsg2 = [Utils findStringRegex:returnString regex:@"(?<=<b>시스템 메세지입니다</b></font><br>).*?(?=<br>)"];
        errmsg = [NSString stringWithFormat:@"댓글 작성중 오류가 발생했습니다. 잠시후 다시 해보세요.[%@]", errmsg2];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"댓글 작성 오류"
                                                                       message:errmsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    [target performSelector:selector withObject:nil afterDelay:0];
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
