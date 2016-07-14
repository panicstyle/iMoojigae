//
//  MainData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "MainData.h"

@implementation MainData
@synthesize m_arrayItems;
@synthesize target;
@synthesize selector;

- (void)fetchItems
{
	m_arrayItems = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *currItem;
	
	currItem = [[NSMutableDictionary alloc] init];
	[currItem setValue:@"무지개교육마을" forKey:@"title"];
	[currItem setValue:@"maul" forKey:@"link"];
	[m_arrayItems addObject:currItem];
	
	currItem = [[NSMutableDictionary alloc] init];
	[currItem setValue:@"초등무지개학교" forKey:@"title"];
	[currItem setValue:@"school1" forKey:@"link"];
	[m_arrayItems addObject:currItem];
	
	currItem = [[NSMutableDictionary alloc] init];
	[currItem setValue:@"중등무지개학교" forKey:@"title"];
	[currItem setValue:@"school2" forKey:@"link"];
	[m_arrayItems addObject:currItem];
	
	[target performSelector:selector withObject:nil afterDelay:0];
}
@end
