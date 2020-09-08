//
//
//  GoogleCalView.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "LinkView.h"
#import "env.h"

@interface LinkView () <WKUIDelegate, WKNavigationDelegate>
@end

@implementation LinkView
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
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView setUIDelegate:self];
    [webView setNavigationDelegate:self];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    [webView loadRequest:request];
}

@end
