//
//  DBInterface.h
//  iMoojigae
//
//  Created by dykim on 2018. 6. 3..
//  Copyright © 2018년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBInterface : NSObject
-(int)searchWithBoardId:(NSString *)boardId BoardNo:(NSString *)boardNo;
-(void)insertWithBoardId:(NSString *)boardId BoardNo:(NSString *)boardNo;
-(void)delete;
@end
