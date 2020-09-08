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

	NSURL *url = [NSURL URLWithString:m_strLink];
	
    long lCurrentHeight = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 40;
    url = [NSURL URLWithString:@"http://jumin.moojigae.or.kr"];
    NSString *urlCal = [NSString stringWithFormat:@"<iframe src=\"https://calendar.google.com/calendar/b/4/embed?amp;wkst=1&amp;bgcolor=%%23ffffff&amp;ctz=Asia\%%2FSeoul&amp;src=aGlnaG1vb2ppZ2FlQGdtYWlsLmNvbQ&amp;src=bXJhaW5ib3c3Nzc4QGdtYWlsLmNvbQ&amp;src=a28uc291dGhfa29yZWEjaG9saWRheUBncm91cC52LmNhbGVuZGFyLmdvb2dsZS5jb20&amp;src=ajUzZG1nZ2hnNjliamwwNWUybnRxODJkcm9AZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&amp;src=YmljZjMybW9xMDdncDM4a3ZoZmxzZmI2NWdAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&amp;src=c2RncXUyb3M4bHZlNTUxdTBibDh1aGJ2YThAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ&amp;color=%%233F51B5&amp;color=%%237CB342&amp;color=%%23EF6C00&amp;color=%%230B8043&amp;color=%%23F6BF26&amp;color=%%23795548&amp;showTitle=0&amp;showNav=1&amp;showPrint=0&amp;showTabs=0\" width=\"100%%\" height=\"%ld\" frameborder=\"0\" scrolling=\"no\"></iframe>", lCurrentHeight];

    urlCal = @"https://calendar.google.com/calendar/embed?src=highmoojigae%40gmail.com&ctz=Asia%2FSeoul";
    url = [NSURL URLWithString:urlCal];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView setUIDelegate:self];
    [webView setNavigationDelegate:self];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
//    [webView loadHTMLString:urlCal baseURL:url];
    [webView loadRequest:request];
}

@end
