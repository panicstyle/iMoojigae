//
//  MainData.m
//  iMoojigae
//
//  Created by dykim on 2016. 3. 16..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "MainData.h"
#import "env.h"
#import "HttpSessionRequest.h"

@interface MainData () <HttpSessionRequestDelegate>
@property (nonatomic, strong) HttpSessionRequest *httpSessionRequest;
@end

@implementation MainData

- (void)fetchItems
{
    NSString *url = [NSString stringWithFormat:@"%@/board-api-menu.do", WWW_SERVER];
    NSLog(@"query = [%@]", url);
    
    self.httpSessionRequest = [[HttpSessionRequest alloc] init];
    self.httpSessionRequest.delegate = self;
    self.httpSessionRequest.timeout = 30;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"moo_menu", @"comm", nil];
    
    NSString *escapedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.httpSessionRequest requestURL:escapedURL withValues:dic];
}

#pragma mark -
#pragma mark HttpSessionRequestDelegate

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest withError:(NSError *)error
{
}

- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLodingData:(NSData *)data
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        return;
    }

    NSMutableArray *arrayItems = [[NSMutableArray alloc] init];

    NSString *strRecent = [parsedObject valueForKey:@"recent"];
    NSLog(@"m_strRecent %@", strRecent);

    NSArray *jsonItems = [parsedObject valueForKey:@"menu"];
    
    NSMutableDictionary *currItem;
    
    for (int i = 0; i < [jsonItems count]; i++) {
        NSDictionary *jsonItem = [jsonItems objectAtIndex:i];
        
        currItem = [[NSMutableDictionary alloc] init];
        
        // title
        NSString *strTitle = [jsonItem valueForKey:@"title"];
        [currItem setValue:strTitle forKey:@"title"];
        
        // type
        NSString *strType = [jsonItem valueForKey:@"type"];
        [currItem setValue:strType forKey:@"type"];
        
        // boardId
        NSString *strValue = [jsonItem valueForKey:@"value"];
        [currItem setValue:strValue forKey:@"value"];
        
        [arrayItems addObject:currItem];
    }
        
    if ([self.delegate respondsToSelector:@selector(mainData:didFinishLodingData:withRecent:)] == YES)
        [self.delegate mainData:self didFinishLodingData:arrayItems withRecent:strRecent];
}


@end
