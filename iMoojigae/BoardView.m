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

@interface BoardView () <BoardDataDelegate>
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryDidChangeNotification)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = m_strCommTitle;
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	self.navigationItem.titleView = lblTitle;

    // Replace this ad unit ID with your own ad unit ID.
    self.bannerView.adUnitID = kSampleAdUnitID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
	m_arrayItems = [[NSMutableArray alloc] init];

    self.boardData = [[BoardData alloc] init];
    self.boardData.delegate = self;
    [self.boardData fetchItemsWithCommNo:m_strCommNo];
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
	NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
    UIFont *titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	if ([[item valueForKey:@"type"] isEqualToString:@"group"]) {
        return 25.0f - 17.0 + titleFont.pointSize;
	} else {
        return 44.0f - 17.0 + titleFont.pointSize;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [m_arrayItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifierRecent = @"Recent";
    static NSString *CellIdentifierBoard = @"Board";
    static NSString *CellIdentifierCalendar = @"Calendar";

	NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
	UITableViewCell *cell;
    if ([[item valueForKey:@"type"] isEqualToString:@"recent"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierRecent];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierRecent];
        }
        [cell.imageView setImage:[UIImage imageNamed:@"circle-blank"]];
    } else if ([[item valueForKey:@"type"] isEqualToString:@"calendar"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCalendar];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierCalendar];
        }
        [cell.imageView setImage:[UIImage imageNamed:@"circle-blank"]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBoard];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBoard];
        }
        if ([[item valueForKey:@"isNew"] intValue] == 0) {
            [cell.imageView setImage:[UIImage imageNamed:@"circle-blank"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"circle"]];
        }
    }
	
	cell.textLabel.text = [item valueForKey:@"title"];
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
	return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
	
	if ([[item valueForKey:@"type"] isEqualToString:@"recent"]) {
		[self performSegueWithIdentifier:@"Recent" sender:self];
	} else if ([[item valueForKey:@"type"] isEqualToString:@"link"]) {
		[self performSegueWithIdentifier:@"Calendar" sender:self];
	} else {
		[self performSegueWithIdentifier:@"Items" sender:self];
	}
}
*/

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

#pragma mark - BoardDataDelegate

- (void) boardData:(BoardData *)boardData didFinishLodingData:(NSArray *)arrayItems withRecent:(NSString *)strRecent;
{
	m_strRecent = strRecent;
	m_arrayItems = [NSMutableArray arrayWithArray:arrayItems];
	[self.tbView reloadData];
}
@end

