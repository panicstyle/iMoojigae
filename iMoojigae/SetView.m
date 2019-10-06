//
//  SetViewController.m
//  iGongdong
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "SetView.h"
#import "env.h"
#import "SetStorage.h"
#import "LoginToService.h"

@implementation SetView

@synthesize idField;
@synthesize pwdField;
@synthesize switchPush;
@synthesize target;
@synthesize selector;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	UILabel *lblTitle = [[UILabel alloc] init];
	lblTitle.text = @"설정";
	lblTitle.backgroundColor = [UIColor clearColor];
	[lblTitle sizeToFit];
	self.navigationItem.titleView = lblTitle;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *myPath = [documentsDirectory stringByAppendingPathComponent:@"set.dat"];
    
	SetStorage *storage = (SetStorage *)[NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
	
	idField.text = storage.userid;
	pwdField.text = storage.userpwd;
	if (storage.switchPush == nil) {
		[switchPush setOn:true];
	} else {
		[switchPush setOn:[storage.switchPush intValue]];
	}
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithTitle:@"완료" 
											   style:UIBarButtonItemStyleDone 
											   target:self 
											   action:@selector(ActionSave:)];
}

- (void)ActionSave:(id)sender
{
	// 입력된 id와 pwd를 저장한다.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *myPath = [documentsDirectory stringByAppendingPathComponent:@"set.dat"];
	////NSLog(@"myPath = %@", myPath);
	SetStorage *storage = [[SetStorage alloc] init];
	storage.userid = idField.text;
	storage.userpwd = pwdField.text;
	storage.switchPush = [NSNumber numberWithBool:switchPush.on];
	[NSKeyedArchiver archiveRootObject:storage toFile:myPath];
	
	LoginToService *login = [[LoginToService alloc] init];
	BOOL result = [login LoginToService];
	
	if (result) {
		
		// Push 정보 업데이트
		[login PushUpdate];

		[target performSelector:selector withObject:[NSNumber numberWithBool:YES] afterDelay:0];
	} else {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"로그인 오류"
																	   message:@"로그인 정보가 없거나 잘못되었습니다. 설정에서 로그인정보를 입력하세요."
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alert addAction:defaultAction];
		[self presentViewController:alert animated:YES completion:nil];
		
		[target performSelector:selector withObject:[NSNumber numberWithBool:NO] afterDelay:0];
	}
	
	[[self navigationController] popViewControllerAnimated:YES];
}

@end
