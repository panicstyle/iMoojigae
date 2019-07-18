//
//  ViewController.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

@import GoogleMobileAds;

#import <UIKit/UIKit.h>

@interface BoardView : UIViewController  <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property(nonatomic, strong) GADBannerView *bannerView;
@property (strong, nonatomic) NSString *m_strCommNo;
@property (strong, nonatomic) NSString *m_strCommTitle;
@end

