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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Replace this ad unit ID with your own ad unit ID.
	self.bannerView.adUnitID = kSampleAdUnitID;
	self.bannerView.rootViewController = self;
	
	GADRequest *request = [GADRequest request];
	// Requests test ads on devices you specify. Your test device ID is printed to the console when
	// an ad request is made. GADBannerView automatically returns test ads when running on a
	// simulator.
	request.testDevices = @[
							@"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
							];
	[self.bannerView loadRequest:request];
	
	NSString *s;
	if ([m_strLink isEqualToString:@"ama"]) {
		s = @"https://www.google.com/calendar/embed?showTitle=0&mode=AGENDA&height=900&wkst=1&bgcolor=%239999ff&src=eltkpocrfnkkrpv9b0m2bkigeg%40group.calendar.google.com&color=%23BE6D00&src=moojigae1004%40gmail.com&color=%230D7813&ctz=Asia%2FSeoul";
	} else if ([m_strLink isEqualToString:@"maul-cal"]) {
		s = @"https://www.google.com/calendar/embed?showTitle=0&height=600&wkst=1&hl=ko&bgcolor=%23388faf&src=vmoojigae%40gmail.com&color=%232F6309&src=ko.south_korea%23holiday%40group.v.calendar.google.com&color=%232952A3&ctz=Asia%2FSeoul";
	} else if ([m_strLink isEqualToString:@"school2-cal"]) {
		s = @"https://www.google.com/calendar/embed?height=600&wkst=1&bgcolor=%23ff9900&src=highmoojigae%40gmail.com&color=%23182C57&src=mrainbow7778%40gmail.com&color=%232F6309&src=ko.south_korea%23holiday%40group.v.calendar.google.com&color=%23691426&src=j53dmgghg69bjl05e2ntq82dro%40group.calendar.google.com&color=%23125A12&ctz=Asia%2FSeoul";
	}
	
	NSURL *url = [NSURL URLWithString:s];
	NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
	
	webView.delegate = self;
	webView.scrollView.scrollEnabled = YES;
	[webView loadRequest:requestURL];
}

@end
