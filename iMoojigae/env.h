//
//  env.h
//  iMoojigae
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#ifndef iMoojigae_env_h
#define iMoojigae_env_h

#import <UIKit/UIKit.h>

#define USE_LOG
//#define TEST_MODE

#ifdef USE_LOG
#define NSLog( s, ... ) NSLog(@"%s(%d) %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define NSLog( s, ... )
#endif

#define WWW_SERVER  @"http://www.moojigae.or.kr"
#define BOARD_LIST    @"/board-list.do?boardId="
#define kSampleAdUnitID @"ca-app-pub-9032980304073628/9510593996"
#define AdPubID @"a1513842aba33a7"

#define CommentWrite	1
#define CommentModify	2
#define CommentReply	3

#define ArticleWrite	1
#define ArticleModify	2

#define RESULT_OK		0
#define RESULT_AUTH_FAIL	1
#define RESULT_LOGIN_FAIL	2

#endif
