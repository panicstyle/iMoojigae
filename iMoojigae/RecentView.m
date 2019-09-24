//
//  RecentView.m
//  iMoojigae
//
//  Created by Kim DY on 12. 6. 11..
//  Copyright (c) 2012년 이니라인. All rights reserved.
//

#import "RecentView.h"
#import "env.h"
#import "LoginToService.h"
#import "ArticleView.h"
#import "RecentData.h"
@import GoogleMobileAds;

@interface RecentView ()
{
	NSMutableArray *m_arrayItems;
	RecentData *m_recentData;
	CGRect m_rectScreen;

//	NSString *m_strTitle;
//	NSString *m_strURL;
//	int m_nPage;
	
//	BOOL m_isLogin;
//	LoginToService *m_login;
//	NSMutableData *m_receiveData;
//	NSURLConnection *m_conn;
//	BOOL m_isConn;
}
@end

@implementation RecentView

@synthesize tbView;
@synthesize m_strRecent;
@synthesize m_strType;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UILabel *lblTitle = [[UILabel alloc] init];
    if ([m_strType isEqualToString:@"list"]) {
        lblTitle.text = @"최신글보기";
    } else {
        lblTitle.text = @"최신댓글보기";
    }
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	self.navigationItem.titleView = lblTitle;

	m_rectScreen = [self getScreenFrameForCurrentOrientation];
    
    tbView.estimatedRowHeight = 78.0f;
    tbView.rowHeight = UITableViewAutomaticDimension;

    // Replace this ad unit ID with your own ad unit ID.
    self.bannerView.adUnitID = kSampleAdUnitID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
	
	m_arrayItems = [[NSMutableArray alloc] init];
	
	m_recentData = [[RecentData alloc] init];
    m_recentData.m_strRecent = m_strRecent;
    m_recentData.m_strType = m_strType;
	m_recentData.target = self;
	m_recentData.selector = @selector(didFetchItems:);
	[m_recentData fetchItems];
}

- (void)textViewDidChange:(UITextView *)textView;
{
    [tbView beginUpdates];
    [tbView endUpdates];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_arrayItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Item";
	
	UITableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
	cell.showsReorderControl = YES;
	
	UILabel *labelBoardName = (UILabel *)[cell viewWithTag:102];
    [labelBoardName setTextColor:[UIColor grayColor]];
	NSString *strBoardName = [item valueForKey:@"boardName"];
	labelBoardName.text = strBoardName;
	
	UILabel *labelName = (UILabel *)[cell viewWithTag:100];
    [labelName setTextColor:[UIColor grayColor]];
	NSString *strName = [item valueForKey:@"name"];
	NSString *strDate = [item valueForKey:@"date"];
	NSString *strNameDate = [NSString stringWithFormat:@"%@  %@", strName, strDate];
	
	labelName.text = strNameDate;
	
	UITextView *textSubject = (UITextView *)[cell viewWithTag:101];
    if ([[item valueForKey:@"read"] intValue] == 1) {
        [textSubject setTextColor:[UIColor grayColor]];
    } else {
        if (@available(iOS 13.0, *)) {
            [textSubject setTextColor:[UIColor labelColor]];
        } else {
            // Fallback on earlier versions
            [textSubject setTextColor:[UIColor blackColor]];
        }
    }	textSubject.text = [item valueForKey:@"subject"];
	
	UILabel *labelComment = (UILabel *)[cell viewWithTag:103];
	NSString *strComment = [item valueForKey:@"comment"];
	if ([strComment isEqualToString:@""]) {
		[labelComment setHidden:YES];
	} else {
		[labelComment setHidden:NO];
		labelComment.layer.cornerRadius = 8;
		labelComment.layer.borderWidth = 1.0;
		//					labelComment.layer.borderColor = [UIColor orangeColor].CGColor;
		labelComment.layer.borderColor = labelComment.textColor.CGColor;
		labelComment.text = strComment;
	}
	
	return cell;

}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
    [item setValue:[NSNumber numberWithInt:1] forKey:@"read"];
    
    [tableView beginUpdates];
    NSArray *array = [NSArray arrayWithObjects:indexPath, nil];
    [tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
	if ([[segue identifier] isEqualToString:@"Article"]) {
		ArticleView *view = [segue destinationViewController];
		NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
		long row = currentIndexPath.row;
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
		view.m_strTitle = [item valueForKey:@"subject"];
		view.m_strDate = [item valueForKey:@"date"];
		view.m_strName = [item valueForKey:@"writer"];
		view.m_boardId = [item valueForKey:@"boardId"];
		view.m_boardNo = [item valueForKey:@"boardNo"];
		view.m_boardName = [item valueForKey:@"boardName"];
        
        [item setValue:[NSNumber numberWithInt:1] forKey:@"read"];
	}
}

#pragma mark - Screen Function

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

#pragma mark WriteArticle

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
		m_arrayItems = [NSMutableArray arrayWithArray:m_recentData.m_arrayItems];
		[self.tbView reloadData];
	}
}
@end
