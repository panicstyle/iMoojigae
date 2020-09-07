//
//  SetViewController.h
//  iGongdong
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetView;
@protocol SetViewDelegate <NSObject>
@optional

- (void) setView:(SetView *)setView withFail:(NSString *)result;

- (void) setView:(SetView *)setView withSuccess:(NSString *)result;

@end

@interface SetView : UIViewController
@property (nonatomic, weak) IBOutlet UITextField *idField;
@property (nonatomic, weak) IBOutlet UITextField *pwdField;
@property (nonatomic, weak) IBOutlet UISwitch *switchPush;
@property (nonatomic, weak) IBOutlet UILabel *labelId;
@property (nonatomic, weak) IBOutlet UILabel *labelPwd;
@property (nonatomic, weak) IBOutlet UILabel *labelNotice;

@property (nonatomic, assign) id <SetViewDelegate> delegate;
@property (nonatomic, assign) int tag;
@end
