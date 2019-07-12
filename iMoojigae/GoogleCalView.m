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
	NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
	
	webView.delegate = self;
	webView.scrollView.scrollEnabled = YES;
	[webView loadRequest:requestURL];
}

@end
