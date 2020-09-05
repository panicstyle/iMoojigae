//
//  RecentData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RecentData;
@protocol RecentDataDelegate <NSObject>
@optional

- (void) recentData:(RecentData *)recentData withError:(NSNumber *)nError;

- (void) recentData:(RecentData *)recentData didFinishLodingData:(NSArray *)arrayItems;

@end

@interface RecentData : NSObject

- (void)fetchItemsWithType:(NSString *)strType withRecent:(NSString *)strRecent;

@property (nonatomic, assign) id <RecentDataDelegate> delegate;
@property (nonatomic, assign) int tag;

@end
