//
//  MainData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainData;
@protocol MainDataDelegate <NSObject>
@optional

- (void) mainData:(MainData *)mainData didFinishLodingData:(NSArray *)arrayItems withRecent:(NSString *)strRecent;
@end

@interface MainData : NSObject

- (void)fetchItems;

@property (nonatomic, assign) id <MainDataDelegate> delegate;
@property (nonatomic, assign) int tag;                                      // tag 값

@end
