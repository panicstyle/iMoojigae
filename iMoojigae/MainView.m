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
#import "MainData.h"
#import "GoogleCalView.h"
#import "DBInterface.h"
@import GoogleMobileAds;

@interface MainView ()
{
	NSMutableArray *m_arrayItems;
	LoginToService *m_login;
	MainData *m_mainData;
	NSString *m_strRecent;
}
@end

@implementation MainView
@synthesize tbView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = @"무지개교육마을";
	lblTitle.backgroundColor = [UIColor clearColor];
//	lblTitle.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
//	lblTitle.shadowColor = [UIColor whiteColor];
//	lblTitle.shadowOffset = CGSizeMake(0, 1);
//	lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
	[lblTitle sizeToFit];
	
	self.navigationItem.titleView = lblTitle;

	// Replace this ad unit ID with your own ad unit ID.
    self.bannerView = [[GADBannerView alloc]
                       initWithAdSize:kGADAdSizeBanner];
    
    [self addBannerViewToView:self.bannerView];
	
	GADRequest *request = [GADRequest request];
	// Requests test ads on devices you specify. Your test device ID is printed to the console when
	// an ad request is made. GADBannerView automatically returns test ads when running on a
	// simulator.
	request.testDevices = @[
							@"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
							];
	[self.bannerView loadRequest:request];

	SetInfo *setInfo = [[SetInfo alloc] init];

	if (![setInfo CheckVersionInfo]) {
		
		// 버전 업데이트 안내 다이얼로그 표시
		NSString *NotiMessage = @"글 작성때 오류가 발생되는 문제가 해결되었습니다.";
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"알림"
																	   message:NotiMessage
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
		[self presentViewController:alert animated:YES completion:nil];
		[setInfo SaveVersionInfo];
	}

	m_arrayItems = [[NSMutableArray alloc] init];
	
	m_mainData = [[MainData alloc] init];
	m_mainData.target = self;
	m_mainData.selector = @selector(didFetchItems);
    
    // DB에 6개월 지난 데이터는 삭제
    DBInterface *db;
    db = [[DBInterface alloc] init];
    [db delete];
	
	if (m_login == nil) {
		
		// 저장된 로그인 정보를 이용하여 로그인
		m_login = [[LoginToService alloc] init];
		BOOL result = [m_login LoginToService];
		
		if (result) {
			[m_login PushRegister];
			
			[m_mainData fetchItems];
		} else {
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"로그인 오류"
																		   message:@"로그인 정보가 없거나 잘못되었습니다. 설정에서 로그인정보를 입력하세요."
																	preferredStyle:UIAlertControllerStyleAlert];
			
			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
																  handler:^(UIAlertAction * action) {}];
			
			[alert addAction:defaultAction];
			[self presentViewController:alert animated:YES completion:nil];
		}
	}
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0f;
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
        GoogleCalView *viewController = [segue destinationViewController];
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
		viewController.target = self;
		viewController.selector = @selector(didChangedSetting:);
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Data Function

- (void)didFetchItems
{
	m_strRecent = m_mainData.m_strRecent;
	
	m_arrayItems = [NSMutableArray arrayWithArray:m_mainData.m_arrayItems];
	[self.tbView reloadData];
}

- (void)didChangedSetting:(NSNumber *)result
{
	if ([result boolValue]) {
		[m_arrayItems removeAllObjects];
		[self.tbView reloadData];
		[m_mainData fetchItems];
	}
}

#pragma mark - Goolgle Admob Banner
- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:bannerView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.bottomLayoutGuide
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:bannerView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]
                                ]];
}
@end
