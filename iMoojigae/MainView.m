//
//  MainViewControllerTableViewController.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "MainView.h"
#import "SetView.h"
#import "AboutView.h"
#import "BoardView.h"
#import "RecentView.h"
#import "SetInfo.h"
#import "LoginToService.h"
#import "env.h"
#import "LinkView.h"
#import "DBInterface.h"
#import "HttpSessionRequest.h"

@import GoogleMobileAds;

@interface MainView () <HttpSessionRequestDelegate, LoginToServiceDelegate, SetViewDelegate>
{
	NSMutableArray *m_arrayItems;
	LoginToService *m_login;
	NSString *m_strRecent;
}
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
@end

@implementation MainView
@synthesize tbView;
@synthesize loginButton;

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryDidChangeNotification)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = @"무지개교육마을";
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	
	self.navigationItem.titleView = lblTitle;

	// Replace this ad unit ID with your own ad unit ID.
    self.bannerView.adUnitID = kSampleAdUnitID;
    self.bannerView.rootViewController = self;
	[self.bannerView loadRequest:[GADRequest request]];

	SetInfo *setInfo = [[SetInfo alloc] init];

	if (![setInfo CheckVersionInfo]) {
/*
		// 버전 업데이트 안내 다이얼로그 표시
		NSString *NotiMessage = @"새글 알림을 설정했는데도 알림이 오지 않을 경우 설정->알림->무지개교육마을 에서 알림 허용을 재설정 하시거나, 앱을 다시 설치해 보시기 바랍니다.";
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"알림"
																	   message:NotiMessage
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
		[self presentViewController:alert animated:YES completion:nil];
*/
		[setInfo SaveVersionInfo];
	}

	m_arrayItems = [[NSMutableArray alloc] init];

    [self fetchItems];

    // DB에 6개월 지난 데이터는 삭제
    DBInterface *db;
    db = [[DBInterface alloc] init];
    [db delete];
	
	if (m_login == nil) {
		// 저장된 로그인 정보를 이용하여 로그인
		m_login = [[LoginToService alloc] init];
        m_login.delegate = self;
		[m_login LoginToService];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contentSizeCategoryDidChangeNotification {
    [self.tbView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGFloat cellHeight = 44.0 - 17.0 + titleFont.pointSize;
    return cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [m_arrayItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"reuseIdentifier";
    static NSString *linkIdentifier = @"linkIdentifier";
    static NSString *recentIdentifier = @"recentIdentifier";

	UITableViewCell *cell;
	NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
    if ([[item valueForKey:@"type"] isEqualToString:@"recent"]) {
        cell = [tableView
                dequeueReusableCellWithIdentifier:recentIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:recentIdentifier];
        }
    } else if ([[item valueForKey:@"type"] isEqualToString:@"link"]) {
        cell = [tableView
                dequeueReusableCellWithIdentifier:linkIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:linkIdentifier];
        }
    } else {
        cell = [tableView
                dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:reuseIdentifier];
        }
    }
	// Configure the cell...
	cell.textLabel.text = [item valueForKey:@"title"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Recent"]) {
        RecentView *viewController = [segue destinationViewController];
        NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
        long row = currentIndexPath.row;
        NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
        viewController.m_strType = [item valueForKey:@"value"];
        viewController.m_strRecent = m_strRecent;
    } else if ([[segue identifier] isEqualToString:@"Link"]) {
        LinkView *viewController = [segue destinationViewController];
        NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
        long row = currentIndexPath.row;
        NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
        viewController.m_strLink = [item valueForKey:@"value"];
        viewController.m_boardName = [item valueForKey:@"title"];
    } else if ([[segue identifier] isEqualToString:@"Board"]) {
		BoardView *viewController = [segue destinationViewController];
		NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
		long row = currentIndexPath.row;
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
		viewController.m_strCommNo = [item valueForKey:@"value"];
		viewController.m_strCommTitle = [item valueForKey:@"title"];
	} else if ([[segue identifier] isEqualToString:@"SetLogin"]) {
		SetView *viewController = [segue destinationViewController];
		viewController.delegate = self;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - User Function

- (void)fetchItems
{
    NSString *url = [NSString stringWithFormat:@"%@/board-api-menu.do", WWW_SERVER];
    NSLog(@"query = [%@]", url);
    
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"moo_menu", @"comm", nil];
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValues:dic withReferer:@""];
}

#pragma mark - HttpSessionRequestDelegate

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest withError:(NSError *)error
{
}

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLodingData:(NSData *)data
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        return;
    }

    m_strRecent = [parsedObject valueForKey:@"recent"];
    NSLog(@"m_strRecent %@", m_strRecent);

    NSArray *jsonItems = [parsedObject valueForKey:@"menu"];
    
    NSMutableDictionary *currItem;
    
    for (int i = 0; i < [jsonItems count]; i++) {
        NSDictionary *jsonItem = [jsonItems objectAtIndex:i];
        
        currItem = [[NSMutableDictionary alloc] init];
        
        // title
        NSString *strTitle = [jsonItem valueForKey:@"title"];
        [currItem setValue:strTitle forKey:@"title"];
        
        // type
        NSString *strType = [jsonItem valueForKey:@"type"];
        [currItem setValue:strType forKey:@"type"];
        
        // boardId
        NSString *strValue = [jsonItem valueForKey:@"value"];
        [currItem setValue:strValue forKey:@"value"];
        
        [m_arrayItems addObject:currItem];
    }
        
    [self.tbView reloadData];
}

#pragma mark - LoginToServiceDelegate

- (void) loginToService:(LoginToService *)loginToService withFail:(NSString *)result
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"로그인 오류"
                                                                   message:@"로그인 정보가 없거나 잘못되었습니다. 설정에서 로그인정보를 입력하세요."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) loginToService:(LoginToService *)loginToService withSuccess:(NSString *)result
{
    m_login = [[LoginToService alloc] init];
    m_login.delegate = self;
    [m_login PushRegister];
}


#pragma mark - SetViewDelegate

- (void) setView:(SetView *)setView withFail:(NSString *)result
{
}

- (void) setView:(SetView *)setView withSuccess:(NSString *)result
{
}

@end
