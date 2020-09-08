	//
//  WebLinkView.m
//  iGongdong
//
//  Created by dykim on 2016. 7. 24..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "WebLinkView.h"
#import "env.h"
#import "Utils.h"
#import "Photos/Photos.h"
#import "HttpSessionRequest.h"
#import <WebKit/WebKit.h>

@interface WebLinkView () <UIScrollViewDelegate, HttpSessionRequestDelegate, WKUIDelegate, WKNavigationDelegate>  {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
}
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
@end

@implementation WebLinkView
@synthesize mainView;
@synthesize m_strLink;
@synthesize m_nFileType;
@synthesize m_imageView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    
	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = @"이미지보기";
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	self.navigationItem.titleView = lblTitle;

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:@"저장"
											  style:UIBarButtonItemStyleDone
											  target:self
											  action:@selector(saveImage:)];
	
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	
	return m_imageView;
	
}

- (void)viewDidLayoutSubviews
{
	if ([m_nFileType intValue] == FILE_TYPE_IMAGE) {		
        NSDictionary *dic = [[NSDictionary alloc] init];
        NSString *escapedURL = [m_strLink stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self.httpSessionRequest requestURL:escapedURL withValues:dic withReferer:@""];
        
	} else {
        if ([[m_strLink substringToIndex:4] isEqualToString:@"http"]) {
            WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height)];
            [mainView addSubview:webView];
            [webView setUIDelegate:self];
            [webView setNavigationDelegate:self];
            [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            webView.backgroundColor = [UIColor clearColor];
            webView.opaque = NO;
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:m_strLink]]];
        } else {
            WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height)];
            [mainView addSubview:webView];
            [webView setUIDelegate:self];
            [webView setNavigationDelegate:self];
            [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            webView.backgroundColor = [UIColor clearColor];
            webView.opaque = NO;
            [webView loadHTMLString:m_strLink baseURL:nil];
        }
	}
}

- (void) saveImage:(id)sender
{
	UIImage *snapshot = self.m_imageView.image;
	
	[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
		PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:snapshot];
		changeRequest.creationDate          = [NSDate date];
	} completionHandler:^(BOOL success, NSError *error) {
		if (success) {
			NSLog(@"successfully saved");
			[self AlertSuccess];
		}
		else {
			NSLog(@"error saving to photos: %@", error);
			[self AlertFail:[error localizedDescription]];
		}
	}];
}

-(void)AlertSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"성공"
                                                                       message:@"이미지가 사진보관함에 저장되었습니다."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:^{}];
    });
/*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"성공"
													message:@"이미지가 사진보관함에 저장되었습니다." delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
	[alert performSelector:@selector(show)
				  onThread:[NSThread mainThread]
				withObject:nil
			 waitUntilDone:NO];
 */
}

-(void)AlertFail:(NSString *)errMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"오류"
                                                                       message:errMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:^{}];
    });
}

#pragma mark -
#pragma mark HttpSessionRequestDelegate

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest withError:(NSError *)error
{
}

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLodingData:(NSData *)data
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainView.bounds.size.width, mainView.bounds.size.height)];
    
    imageView.image = [UIImage imageWithData:data];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.m_imageView = imageView;
    mainView.maximumZoomScale = 3.0;
    mainView.minimumZoomScale = 0.6;
    mainView.clipsToBounds = YES;
    mainView.delegate = self;
    [mainView addSubview:m_imageView];
}
@end
