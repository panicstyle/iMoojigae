//
//  ListView.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;

@interface RecentView : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property(nonatomic, strong) GADBannerView *bannerView;
@property (strong, nonatomic) NSString *m_strRecent;
@property (strong, nonatomic) NSString *m_strType;
@end
