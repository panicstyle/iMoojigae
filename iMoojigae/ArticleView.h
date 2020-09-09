//
//  ArticleView.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;

@class ArticleView;
@protocol ArticleViewDelegate <NSObject>
@optional

- (void) articleView:(ArticleView *)articleView didDelete:(long)row;

@end

@interface ArticleView : UIViewController <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property(nonatomic, strong) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonArticleMenu;
@property (strong, nonatomic) NSString *m_strTitle;
@property (strong, nonatomic) NSString *m_strDate;
@property (strong, nonatomic) NSString *m_strName;
@property (strong, nonatomic) NSString *m_boardId;
@property (strong, nonatomic) NSString *m_boardNo;
@property (strong, nonatomic) NSString *m_boardName;
@property (assign, nonatomic) long m_row;
@property (nonatomic, retain) UIDocumentInteractionController *doic;

@property (nonatomic, assign) id <ArticleViewDelegate> delegate;
@property (nonatomic, assign) int tag;

@end
