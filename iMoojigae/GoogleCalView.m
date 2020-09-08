//
//
//  GoogleCalView.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "GoogleCalView.h"
#import "env.h"

@interface GoogleCalView () <WKUIDelegate, WKNavigationDelegate>
@end

@implementation GoogleCalView
@synthesize webView;
@synthesize m_strLink;
@synthesize m_boardName;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = m_boardName;
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	self.navigationItem.titleView = lblTitle;

    NSString *urlCal = @"https://calendar.google.com/calendar/embed?height=600&wkst=1&bgcolor=%23ffffff&ctz=Asia%2FSeoul&src=aGlnaG1vb2ppZ2FlQGdtYWlsLmNvbQ&src=bXJhaW5ib3c3Nzc4QGdtYWlsLmNvbQ&src=ajduZzZnZXRoZGkzbjJjMWgxdHRlZGZubGNAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&src=a28uc291dGhfa29yZWEjaG9saWRheUBncm91cC52LmNhbGVuZGFyLmdvb2dsZS5jb20&src=ajUzZG1nZ2hnNjliamwwNWUybnRxODJkcm9AZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&src=YmljZjMybW9xMDdncDM4a3ZoZmxzZmI2NWdAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&src=c2RncXUyb3M4bHZlNTUxdTBibDh1aGJ2YThAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&color=%233F51B5&color=%237CB342&color=%23F09300&color=%23EF6C00&color=%230B8043&color=%23F6BF26&color=%23795548";
    NSURL *url = [NSURL URLWithString:urlCal];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView setUIDelegate:self];
    [webView setNavigationDelegate:self];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    [webView loadRequest:request];
}

@end
