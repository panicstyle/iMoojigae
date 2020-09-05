//
//  ArticleData.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 13..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ArticleData;
@protocol ArticleDataDelegate <NSObject>
@optional

- (void) articleData:(ArticleData *)articleData withError:(NSNumber *)nError;

- (void) articleData:(ArticleData *)articleData didFinishLodingData:(NSString *)strTitle
        withName:(NSString *)strName withDate:(NSString *)strDate withHit:(NSString *)strHit
     withContent:(NSString *)strContent withEditableContent:(NSString *)strEditableContent
    withCommentItems:(NSArray *)arrayItems withAttach:(NSDictionary *)dicAttach;

@end

@interface ArticleData : NSObject

- (void)fetchItemsWithBoardId:(NSString *)boardId withBoardNo:(NSString *)boardNo;
- (bool)DeleteArticle:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo;
- (bool)DeleteComment:(NSString *)strBoardNo articleNo:(NSString *)strArticleNo commentNo:(NSString *)strCommentNo;

@property (nonatomic, assign) id <ArticleDataDelegate> delegate;
@property (nonatomic, assign) int tag;

@property (strong, nonatomic) NSString *m_strHtml;
@property (strong, nonatomic) NSString *m_strTitle;
@property (strong, nonatomic) NSString *m_strName;
@property (strong, nonatomic) NSString *m_strDate;
@property (strong, nonatomic) NSString *m_strHit;
@property (strong, nonatomic) NSString *m_strContent;
@property (strong, nonatomic) NSString *m_strEditableContent;
@property (strong, nonatomic) NSMutableArray *m_arrayItems;
@property (strong, nonatomic) NSMutableDictionary *m_dicAttach;

@end
