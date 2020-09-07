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
#import "HttpSessionRequest.h"
@import GoogleMobileAds;

@interface BoardView () <HttpSessionRequestDelegate>
{
    NSMutableArray *m_arrayItems;
	NSString *m_strRecent;
}
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
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

    [self fetchItemsWithCommNo:m_strCommNo];
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

#pragma mark - User Function

- (void)fetchItemsWithCommNo:(NSString *)strCommNo
{
    NSString *url = [NSString stringWithFormat:@"%@/board-api-menu.do", WWW_SERVER];
    NSLog(@"query = [%@]", url);
    
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strCommNo, @"comm", nil];
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValues:dic];
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
    
    NSString *m_strRecent = [parsedObject valueForKey:@"recent"];
    NSLog(@"strRecent %@", m_strRecent);
    
    NSString *strNew = [parsedObject valueForKey:@"new"];
    NSLog(@"strNew %@", strNew);

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
        NSString *strBoardId = [jsonItem valueForKey:@"boardId"];
        [currItem setValue:strBoardId forKey:@"boardId"];
        
        [m_arrayItems addObject:currItem];
    }
    
    // icon_new 찾기. 게시판 이름을 찾아서 그 다음에 icon_new가 있는지 확인
    for (int i = 0; i < [m_arrayItems count]; i++) {
        NSMutableDictionary *item = [m_arrayItems objectAtIndex:i];
        NSString *link = [item valueForKey:@"boardId"];
        link = [NSString stringWithFormat:@"[%@]", link];

        if ([strNew rangeOfString:link].location != NSNotFound) {
            // strNew 최근글이 포함된 게시판 목록 리스트에서 해당 게시판 아이가 있는지 찾고, 있으면 N 아이콘을 표시한다.
            [item setValue:[NSNumber numberWithInt:1] forKey:@"isNew"];
        } else {
            [item setValue:[NSNumber numberWithInt:0] forKey:@"isNew"];
        }
    }
        
    [self.tbView reloadData];
}
@end

