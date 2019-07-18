//
//  ViewController.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "BoardView.h"
#import "env.h"
#import "ItemsView.h"
#import "RecentView.h"
#import "GoogleCalView.h"
#import "BoardData.h"
@import GoogleMobileAds;

@interface BoardView ()
{
    NSMutableArray *m_arrayItems;
	BoardData *m_boardData;
	NSString *m_strRecent;
}
@end

@implementation BoardView
@synthesize m_strCommNo;
@synthesize m_strCommTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = m_strCommTitle;
	lblTitle.backgroundColor = [UIColor clearColor];
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

	m_arrayItems = [[NSMutableArray alloc] init];

	m_boardData = [[BoardData alloc] init];
	m_boardData.m_strCommNo = m_strCommNo;
	m_boardData.target = self;
	m_boardData.selector = @selector(didFetchItems);
    [m_boardData fetchItems];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
	if ([[item valueForKey:@"type"] isEqualToString:@"group"]) {
		return 25.0f;
	} else {
		return 44.0f;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [m_arrayItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"reuseIdentifier";
	
	NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
	UITableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	if ([[item valueForKey:@"isNew"] intValue] == 0) {
		[cell.imageView setImage:[UIImage imageNamed:@"circle-blank"]];
	} else {
		[cell.imageView setImage:[UIImage imageNamed:@"circle"]];
	}
	
	cell.textLabel.text = [item valueForKey:@"title"];
	
	if (![[item valueForKey:@"type"] isEqualToString:@"group"])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	// Configure the cell.
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
	
	if ([[item valueForKey:@"type"] isEqualToString:@"group"]) return;
	
	if ([[item valueForKey:@"type"] isEqualToString:@"recent"]) {
		[self performSegueWithIdentifier:@"Recent" sender:self];
	} else if ([[item valueForKey:@"type"] isEqualToString:@"link"]) {
		[self performSegueWithIdentifier:@"Calendar" sender:self];
	} else {
		[self performSegueWithIdentifier:@"Items" sender:self];
	}
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
	if ([[segue identifier] isEqualToString:@"Items"]) {
		ItemsView *view = [segue destinationViewController];
		NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
		long row = currentIndexPath.row;
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
		view.m_strCommNo = m_strCommNo;
		view.m_boardId = [item valueForKey:@"boardId"];
		view.m_boardName = [item valueForKey:@"title"];
	} else if ([[segue identifier] isEqualToString:@"Recent"]) {
		RecentView *view = [segue destinationViewController];
		view.m_strRecent = m_strRecent;
		view.m_strType = @"list";
	}
	if ([[segue identifier] isEqualToString:@"Calendar"]) {
		GoogleCalView *view = [segue destinationViewController];
		NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
		long row = currentIndexPath.row;
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
		view.m_strLink = [item valueForKey:@"boardId"];
		view.m_boardName = [item valueForKey:@"title"];
	}
}

#pragma mark - Board Data Function

- (void)didFetchItems
{
	m_strRecent = m_boardData.m_strRecent;
	
	m_arrayItems = [NSMutableArray arrayWithArray:m_boardData.m_arrayItems];
	[self.tbView reloadData];
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

