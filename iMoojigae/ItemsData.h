//
//  ItemsData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemsData : NSObject
@property (nonatomic, strong) NSString *m_strCommNo;
@property (nonatomic, strong) NSString *m_strBoardNo;
@property (strong, nonatomic) NSMutableArray *m_arrayItems;
@property id target;
@property SEL selector;

- (void)fetchItems:(int) nPage;

@end
