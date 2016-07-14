//
//  ArticleData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 13..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleData : NSObject
@property (strong, nonatomic) NSString *m_strHtml;
@property (strong, nonatomic) NSString *m_strTitle;
@property (strong, nonatomic) NSString *m_strName;
@property (strong, nonatomic) NSString *m_strDate;
@property (strong, nonatomic) NSString *m_strHit;
@property (strong, nonatomic) NSString *m_strContent;
@property (strong, nonatomic) NSString *m_strEditableContent;
@property (strong, nonatomic) NSString *m_strLink;
@property (strong, nonatomic) NSMutableArray *m_arrayItems;
@property id target;
@property SEL selector;

- (void)fetchItems;
- (bool)DeleteArticle:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo;
- (bool)DeleteComment:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo commentNo:(NSString *)strCommentNo;

@end
