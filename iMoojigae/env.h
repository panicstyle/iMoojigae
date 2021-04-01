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

#ifdef DEBUG
#define NSLog( s, ... ) NSLog(@"%s(%d) %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define NSLog( s, ... )
#endif

#ifdef DEBUG
	#define WWW_SERVER  @"https://jumin.moojigae.or.kr"
	#define PUSH_SERVER  @"https://jumin.moojigae.or.kr"
#else
	#define WWW_SERVER  @"https://jumin.moojigae.or.kr"
	#define PUSH_SERVER  @"https://jumin.moojigae.or.kr"
#endif

#define BOARD_LIST    @"/board-api-list.do?boardId="
#define BOARD_READ    @"/board-api-read.do?boardId="
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

#define FILE_TYPE_HTML	0
#define FILE_TYPE_IMAGE	1

#define SCALE_SIZE		600

#define READ_ARTICLE        1
#define DELETE_ARTICLE      2
#define DELETE_COMMENT      3

#define POST_FILE       1
#define POST_DATA       2

#define LOGIN_TO_SERVER             1
#define PUSH_REGISTER               2
#define PUSH_UPDATER                3
#define LOGOUT_TO_SERVER            4

extern NSStringEncoding g_encodingOption;

#endif
