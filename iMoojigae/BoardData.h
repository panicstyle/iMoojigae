//
//  BoardData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardData : NSObject
@property (nonatomic, strong) NSString *m_strCommNo;
@property (nonatomic, strong) NSString *m_strRecent;
@property (strong, nonatomic) NSMutableArray *m_arrayItems;
@property id target;
@property SEL selector;

- (void)fetchItems;
@end
