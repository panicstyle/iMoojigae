//
//  GoogleCalView.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@import GoogleMobileAds;

@interface GoogleCalView : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet WKWebView *webView;
@property (strong, nonatomic) NSString *m_strLink;
@property (strong, nonatomic) NSString *m_boardName;
@end
