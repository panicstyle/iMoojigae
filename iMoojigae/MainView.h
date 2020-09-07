//
//  MainViewControllerTableViewController.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//
@import GoogleMobileAds;

#import <UIKit/UIKit.h>

@interface MainView : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (nonatomic, strong) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;

@end
