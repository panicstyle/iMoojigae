//
//  BoardData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "BoardData.h"
#import "env.h"

@interface BoardData () {
	NSMutableData *m_receiveData;
	NSURLConnection *m_connection;
}
@end

@implementation BoardData
@synthesize m_strCommNo;
@synthesize m_arrayItems;
@synthesize target;
@synthesize selector;

- (void)fetchItems
{
	m_arrayItems = [[NSMutableArray alloc] init];

	NSArray *maul = @[
					  @"recent", @"최근글보기",
					  @"-", @"이야기방",
					  @"mvTopic", @" > 이야기방",
					  @"mvTopic10Year", @" > 10주년 행사",
					  @"mvTopicGoBackHome", @" > 무지개 촌(村)",
					  @"mvEduBasicRight", @"교육기본권",
					  @"mvGongi", @"마을 공지사항",
					  @"-", @"공동체사업부",
					  @"mvGongDong", @" > 공동체사업부",
					  @"mvGongDongFacility", @" > 시설기획팀",
					  @"mvGongDongEvent", @" > 행사기획팀",
					  @"mvGongDongLocalcommunity",  @" > 지역사업팀",
					  @"-", @"마을 동아리방",
					  @"mvDonghowhe", @" > 마을 동아리방",
					  @"mvDonghowheMoojigaeFC", @" > 무지개FC",
					  @"-",  @"어울림품앗이",
					  @"mvPoomASee", @" > 어울림품앗이",
					  @"mvPoomASeeWantBiz", @" > 거래하고싶어요",
					  @"mvPoomASeeBized", @" > 거래했어요",
					  @"-", @"교육사업부",
					  @"mvEduLove", @" > 교육사랑방",
					  @"mvEduVillageSchool", @" > 마을학교",
					  @"mvEduDream", @" > 또하나의꿈",
					  @"mvEduSpring", @" > 교육샘",
					  @"mvEduSpring", @" > 만두",
					  @"mvMarketBoard", @"무지개장터",
					  @"-", @"무지개지평선",
					  @"mvHorizonIntroduction", @" > 가족소개",
					  @"mvHorizonLivingStory", @" > 사는 얘기",
					  @"-", @"사무국",
					  @"mvSecretariatAddress", @" > 마을주민 연락처",
					  @"mvSecretariatOldData", @" > 마을 자료실",
					  @"mvMinutes", @"회의록방",
					  @"mvDirectors", @"이사회",
					  @"mvCommittee", @"운영위",
					  @"mvEduResearch", @"교육연구회",
					  @"-", @"건축위",
					  @"mvBuilding", @" > 위원방",
					  @"mvBuildingComm", @" > 소통방",
					  @"-", @"기금위",
					  @"mvDonationGongi", @" > 공지사항",
					  @"mvDonationQnA", @" > Q & A",
					  @"maul-cal", @"전체일정",
					  @"toHomePageAdmin", @"홈피관련질문",
					  @"mvUpgrade", @"등업요청(메일인증)",
					  ];
	
	NSArray *school1 = @[
						 @"recent", @"최근글보기",
						 @"mjGongi", @"초등 공지사항",
						 @"mjFreeBoard", @"자유게시판",
						 @"mjTeacher", @"교사방",
						 @"mjTeachingData", @"교사회의록",
						 @"mjJunior", @"아이들방",
						 @"mjParent", @"학부모방",
						 @"mjParentMinutes", @"학부모 회의록",
						 @"mjAmaDiary", @"품앗이분과",
						 @"mjSchoolFood", @"급식분과",
						 @"mjPhoto", @"사진첩&동영상",
						 @"mjData", @"학교 자료실",
						 @"ama", @"아마표",
						 ];
	
	NSArray *school2 = @[
						 @"recent", @"최근글보기",
						 @"msGongi", @"중등 공지사항",
						 @"msFreeBoard", @"학교이야기방",
						 @"msOverRainbow", @"무지개너머",
						 @"msFreeComment", @"자유게시판",
						 @"msTeacher", @"교사방",
						 @"msSenior", @"숙제방",
						 @"msStudent", @"아이들방",
						 @"ms5Class", @"5학년방",
						 @"msStudentAssociation", @"학생회방",
						 @"msParent", @"학부모방",
						 @"msRepresentative", @"대표자회",
						 @"msMinutes", @"회의록",
						 @"msPhoto", @"사진첩&동영상",
						 @"msData", @"학교자료실",
						 @"school2-cal", @"전체일정",
						 ];
	
	NSArray *tmp;
	if ([m_strCommNo isEqualToString:@"maul"]) {
		tmp = maul;
	} else if ([m_strCommNo isEqualToString:@"school1"]) {
		tmp = school1;
	} else {
		tmp = school2;
	}
	
	NSMutableDictionary *currItem;
	int i;
	for (i = 0; i < tmp.count; i+=2) {
		currItem= [[NSMutableDictionary alloc] init];
		[currItem setValue:tmp[i] forKey:@"link"];
		[currItem setValue:tmp[i + 1] forKey:@"title"];
		[m_arrayItems addObject:currItem];
	}
	
	[self fetchItems2];
}

- (void)fetchItems2
{
	NSLog(@"fetchItems2");
	m_receiveData = [[NSMutableData alloc] init];
		
	NSString *url = [NSString stringWithFormat:@"%@/board-api-new.do", WWW_SERVER];
	NSLog(@"query = [%@]", url);
	
	m_connection = [[NSURLConnection alloc]
				  initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
	NSLog(@"fetchItems 3");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"didReceiveData");
	[m_receiveData appendData:data];
	NSLog(@"didReceiveData receiveData=[%lu], data=[%lu]", (unsigned long)[m_receiveData length], (unsigned long)[data length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"ListView receiveData Size = [%lu]", (unsigned long)[m_receiveData length]);
	
	NSString *html = [[NSString alloc] initWithData:m_receiveData
										   encoding:NSUTF8StringEncoding];
	
	NSLog(@"html=[%@]", html);
	
	NSError *localError = nil;
	NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:m_receiveData options:0 error:&localError];
	
	if (localError != nil) {
		return;
	}
	
	NSString *strNew = [parsedObject valueForKey:@"newIconBoard"];
	NSLog(@"strNew %@", strNew);
	
	
	// icon_new 찾기. 게시판 이름을 찾아서 그 다음에 icon_new가 있는지 확인
	for (int i = 0; i < [m_arrayItems count]; i++) {
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:i];
		NSString *link = [item valueForKey:@"link"];

		if ([strNew rangeOfString:link].location != NSNotFound) {
			// strNew 최근글이 포함된 게시판 목록 리스트에서 해당 게시판 아이가 있는지 찾고, 있으면 N 아이콘을 표시한다.
			[item setValue:[NSNumber numberWithInt:1] forKey:@"isNew"];
		} else {
			[item setValue:[NSNumber numberWithInt:0] forKey:@"isNew"];
		}
	}
	
	[target performSelector:selector withObject:nil afterDelay:0];
}

@end
