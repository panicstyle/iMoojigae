//
//  ItemsData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ItemsData;
@protocol ItemsDataDelegate <NSObject>
@optional

- (void) itemsData:(ItemsData *)itemsData withError:(NSNumber *)nError;

- (void) itemsData:(ItemsData *)itemsData didFinishLodingData:(NSArray *)arrayItems;

@end

@interface ItemsData : NSObject

- (void)fetchItemsWithBoardId:(NSString *)boardId withPage:(int)nPage;

@property (nonatomic, assign) id <ItemsDataDelegate> delegate;
@property (nonatomic, assign) int tag;                                      // tag 값

@end
