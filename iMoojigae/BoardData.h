//
//  BoardData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BoardData;
@protocol BoardDataDelegate <NSObject>
@optional

- (void) boardData:(BoardData *)boardData didFinishLodingData:(NSArray *)arrayItems withRecent:(NSString *)strRecent;
@end

@interface BoardData : NSObject

- (void)fetchItemsWithCommNo:(NSString *)strCommNo;

@property (nonatomic, assign) id <BoardDataDelegate> delegate;
@property (nonatomic, assign) int tag;                                      // tag 값

@end
