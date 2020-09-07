//
//  HttpRequest.m
//  NavigationUpdagter
//
//  Created by bhchae76 on 2017. 4. 10..
//  Copyright © 2017년 bhchae76. All rights reserved.
//

#import "HttpSessionRequest.h"

#define SESSION_ERROR_DOMAIN    @"HttpSessionRequest"

@interface HttpSessionRequest() <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableData *receiveDate;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@end

@implementation HttpSessionRequest

/*
    초기화 함수
 */
- (id)init
{
    self = [super init];
    if (self)
    {
        self.timeout = 5;
        self.httpMethod = @"GET";
    }
    
    return self;
}

- (void)closeSession
{
    if (_sessionDataTask != nil && _sessionDataTask.state == NSURLSessionTaskStateRunning) {
        [_sessionDataTask cancel];
        [_session invalidateAndCancel];
    }
    else {
        [_session finishTasksAndInvalidate];
    }
}

- (void)requestURL:(NSString *)url withValues:(NSDictionary *)values withFileName:(NSString *)fileName withFilePath:(NSString *)filePath
{
    _url = url;
    
    // sessionDataTask 가 작업중이면 작업종료
    if (_sessionDataTask != nil && _sessionDataTask.state == NSURLSessionTaskStateRunning) {
        [_sessionDataTask cancel];
        [_session invalidateAndCancel];
    }

    // session 객체가 nil이면 session객체 생성
    if (_session == nil)
    {
        NSOperationQueue *queue;
        if (_queue == nil)
            queue = [NSOperationQueue mainQueue];
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:queue];
    }

    NSString *urlString;

    NSString *boundary = @"0xKhTmLbOuNdArY";  // important!!!
    NSMutableData *body = [NSMutableData data];
    
    // Post Parameter
    NSArray *keys = [[values allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (int i=0; i<keys.count; i++)
    {
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [values objectForKey:key];

        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    // Multipart Parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:fileData];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    urlString = url;
    
    // Request 객체 생성
    NSURL *dataURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dataURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:self.timeout];
    [request setHTTPMethod:self.httpMethod];
    
    if ([self.httpMethod isEqualToString:@"POST"] == YES)
    {
        NSString *postLength = [NSString stringWithFormat:@"%ld",[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:body];
    }
    
    
    // request 요청
    _sessionDataTask = [self.session dataTaskWithRequest:request];
    _sessionDataTask.taskDescription = @"task_data";
    [_sessionDataTask resume];
}

- (void)requestURL:(NSString *)url withMultipartBody:(NSData *)body withBoundary:(NSString *)boundary
{
    _url = url;
    
    // sessionDataTask 가 작업중이면 작업종료
    if (_sessionDataTask != nil && _sessionDataTask.state == NSURLSessionTaskStateRunning) {
        [_sessionDataTask cancel];
        [_session invalidateAndCancel];
    }

    // session 객체가 nil이면 session객체 생성
    if (_session == nil)
    {
        NSOperationQueue *queue;
        if (_queue == nil)
            queue = [NSOperationQueue mainQueue];
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:queue];
    }

    NSString *urlString;
    
    urlString = url;
    
    // Request 객체 생성
    NSURL *dataURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dataURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:self.timeout];
    [request setHTTPMethod:self.httpMethod];
    
    if ([self.httpMethod isEqualToString:@"POST"] == YES)
    {
        NSString *postLength = [NSString stringWithFormat:@"%ld",[body length]];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:body];
    }
    
    
    // request 요청
    _sessionDataTask = [self.session dataTaskWithRequest:request];
    _sessionDataTask.taskDescription = @"task_data";
    [_sessionDataTask resume];
}


- (void)requestURL:(NSString *)url withJsonString:(NSString *)jsonString
{
    _url = url;
    
    // sessionDataTask 가 작업중이면 작업종료
    if (_sessionDataTask != nil && _sessionDataTask.state == NSURLSessionTaskStateRunning) {
        [_sessionDataTask cancel];
        [_session invalidateAndCancel];
    }
    
    // session 객체가 nil이면 session객체 생성
    if (_session == nil)
    {
        NSOperationQueue *queue;
        if (_queue == nil)
            queue = [NSOperationQueue mainQueue];
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:queue];
    }
    
    NSString *jsonStringForSend = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSData *postData = [jsonStringForSend dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Request 객체 생성
    NSURL *dataURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dataURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:self.timeout];
    [request setHTTPMethod:@"POST"];
    
    NSString *postLength = [NSString stringWithFormat:@"%ld", [postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    
    // request 요청
    _sessionDataTask = [self.session dataTaskWithRequest:request];
    _sessionDataTask.taskDescription = @"task_data";
    [_sessionDataTask resume];
}

- (void)requestURL:(NSString *)url withValues:(NSDictionary *)values
{
    _url = url;
    
    // sessionDataTask 가 작업중이면 작업종료
    if (_sessionDataTask != nil && _sessionDataTask.state == NSURLSessionTaskStateRunning) {
        [_sessionDataTask cancel];
        [_session invalidateAndCancel];
    }

    // session 객체가 nil이면 session객체 생성
    if (_session == nil)
    {
        NSOperationQueue *queue;
        if (_queue == nil)
            queue = [NSOperationQueue mainQueue];
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:queue];
    }

    NSData *postData;
    NSString *urlString;
    if ([self.httpMethod isEqualToString:@"GET"] == YES)
    {
        NSString *getString = @"";
        NSArray *keys = [[values allKeys] sortedArrayUsingSelector: @selector(compare:)];
        if ([keys count] > 0) {
            for (int i=0; i<keys.count; i++)
            {
                NSString *key = [keys objectAtIndex:i];
                NSString *safeKey= [key
                     stringByAddingPercentEncodingWithAllowedCharacters:
                         [NSCharacterSet URLQueryAllowedCharacterSet]
                ];
                NSString *value = [values objectForKey:key];
                NSString *safeValue= [value
                     stringByAddingPercentEncodingWithAllowedCharacters:
                                      [NSCharacterSet URLQueryAllowedCharacterSet]];
                if (i == 0)
                    value = [NSString stringWithFormat:@"%@=%@", safeKey, safeValue];
                else
                    value = [NSString stringWithFormat:@"&%@=%@", safeKey, safeValue];
                
                getString = [getString stringByAppendingString:value];
            }
            
            urlString = [NSString stringWithFormat:@"%@?%@", url, getString];
        } else {
            urlString = [NSString stringWithFormat:@"%@", url];
        }
    }
    else {      // POST
        NSString *postString = @"";
        NSArray *keys = [[values allKeys] sortedArrayUsingSelector: @selector(compare:)];
        for (int i=0; i<keys.count; i++)
        {
            NSString *key = [keys objectAtIndex:i];
            NSString *value;
            if (i == 0)
                value = [NSString stringWithFormat:@"%@=%@", key, [values objectForKey:key]];
            else
                value = [NSString stringWithFormat:@"&%@=%@", key, [values objectForKey:key]];
            
            postString = [postString stringByAppendingString:value];
        }
        
        postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        urlString = url;
    }
    
    // Request 객체 생성
    NSURL *dataURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dataURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:self.timeout];
    [request setHTTPMethod:self.httpMethod];
    
    if ([self.httpMethod isEqualToString:@"POST"] == YES)
    {
        NSString *postLength = [NSString stringWithFormat:@"%ld",[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    }
        
    // request 요청
    _sessionDataTask = [self.session dataTaskWithRequest:request];
    _sessionDataTask.taskDescription = @"task_data";
    [_sessionDataTask resume];
}

- (void)requestURL:(NSString *)url withValueString:(NSString *)valueString
{
    _url = url;
    
    // sessionDataTask 가 작업중이면 작업종료
    if (_sessionDataTask != nil && _sessionDataTask.state == NSURLSessionTaskStateRunning) {
        [_sessionDataTask cancel];
        [_session invalidateAndCancel];
    }

    // session 객체가 nil이면 session객체 생성
    if (_session == nil)
    {
        NSOperationQueue *queue;
        if (_queue == nil)
            queue = [NSOperationQueue mainQueue];
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:queue];
    }

    NSData *postData;
    NSString *urlString;
    if ([self.httpMethod isEqualToString:@"GET"] == YES)
    {
        if (valueString == nil || valueString.length > 0) {
            urlString = [NSString stringWithFormat:@"%@?%@", url, valueString];
        } else {
            urlString = [NSString stringWithFormat:@"%@", url];
        }
    }
    else {      // POST
        NSString *postString = @"";
        if (valueString != nil) {
            postString = [postString stringByAppendingString:valueString];
        }
        
        postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        urlString = url;
    }
    
    // Request 객체 생성
    NSURL *dataURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dataURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:self.timeout];
    [request setHTTPMethod:self.httpMethod];
    
    if ([self.httpMethod isEqualToString:@"POST"] == YES)
    {
        NSString *postLength = [NSString stringWithFormat:@"%ld",[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    }
        
    // request 요청
    _sessionDataTask = [self.session dataTaskWithRequest:request];
    _sessionDataTask.taskDescription = @"task_data";
    [_sessionDataTask resume];
}

- (void)requestHeaderInfo:(NSString *)url
{
    _url = url;
    
    // sessionDataTask 가 작업중이면 작업종료
    if (_sessionDataTask != nil && _sessionDataTask.state == NSURLSessionTaskStateRunning) {
        [_sessionDataTask cancel];
        [_session invalidateAndCancel];
    }
    
    // session 객체가 nil이면 session객체 생성
    if (_session == nil)
    {
        NSOperationQueue *queue;
        if (_queue == nil)
            queue = [NSOperationQueue mainQueue];
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:queue];
    }
    
    // Request 객체 생성
    NSURL *dataURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dataURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:self.timeout];
    [request setHTTPMethod:@"HEAD"];
    
    // request 요청
    _sessionDataTask = [self.session dataTaskWithRequest:request];
    _sessionDataTask.taskDescription = @"task_head";
    [_sessionDataTask resume];
}

- (void)cancelForRequest
{
    [_sessionDataTask cancel];
}

#pragma mark -
#pragma mark NSURLSessionDataDelegate
/*
    서버로 부터 응답이 있을 경우 호출되는 함수
    정상(200)이 아닌경우 httpSessionRequest:withError: 델리게이트 함수가 호출된다.
    정상이면서 헤더정보 요청인경우 httpSessionRequest:didFinishLoadHeaderInfo: 델리게이트 함수가 호출된다.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = [httpResponse statusCode];
    
    // status코드가 200이 아니면 에러 발생 후 루틴 종료
    if (statusCode != 200) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]
                   forKey:NSLocalizedDescriptionKey];
        [details setValue:_url forKey:@"url"];

        NSError *error = [NSError errorWithDomain:SESSION_ERROR_DOMAIN code:statusCode userInfo:details];
        if ([self.delegate respondsToSelector:@selector(httpSessionRequest:withError:)] == YES)
            [self.delegate httpSessionRequest:self withError:error];
        
        return;
    }
    
    // 정상인 경우 데이터 수신작업 수행
    if ([dataTask.taskDescription isEqualToString:@"task_head"] == YES)
    {
        NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
        if ([self.delegate respondsToSelector:@selector(httpSessionRequest:didFinishLoadHeaderInfo:)] == YES)
            [self.delegate httpSessionRequest:self didFinishLoadHeaderInfo:headers];
    }
    else {
        _receiveDate = [[NSMutableData alloc] init];
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

/*
    데이터 수신시 호출되는 함수
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {    
    [_receiveDate appendData:data];
}

/*
    HTTP 통신 완료시 호출되는 함수
    정상인 경우 httpSessionRequest:didFinishLodingData: 델리게이트 함수가 호출되며, 비정상인경우에는 httpSessionRequest:withError: 
    델리게이트 함수가 호출된다.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    @try {
        // 다운로드 파일 포인터가 열려있으면 파일 close
        if (error == nil)       // Success
        {
            // delegate 함수 호출
            if ([task.taskDescription isEqualToString:@"task_head"] == NO)
            {
                if ([self.delegate respondsToSelector:@selector(httpSessionRequest:didFinishLodingData:)] == YES)
                    [self.delegate httpSessionRequest:self didFinishLodingData:self.receiveDate];
            }
        }
        else {  // failed
                        
                        // v0.71.1 에서 발생한 SSL Verify 오류 등이 발생할 때 -999 오류로 인해 그냥 리턴됨. 이 경우 프로그램 종료 등 오류 화면 밣생하지 않음
                        // task가 취소된 경우 루틴 종료
            //            if (error.code == -999) {
            //                return;
            //            }
            
            NSMutableDictionary *details = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
            [details setValue:_url forKey:@"url"];
            NSError *newError = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:details];
            
            // delegate 함수 호출
            if ([self.delegate respondsToSelector:@selector(httpSessionRequest:withError:)] == YES)
                [self.delegate httpSessionRequest:self withError:newError];
        }
    } @finally {
        _receiveDate = nil;
        _sessionDataTask = nil;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [session finishTasksAndInvalidate];
        });
    }
}

/*
    세션이 무효화 될때 호출되는 함수이다.  
    세션이 무효시 에러인 경우 httpSessionRequest:withError: 함수가 호출된다.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    self.session = nil;
    
    if (error != nil)
    {
        NSMutableDictionary *details = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
        [details setValue:_url forKey:@"url"];
        NSError *newError = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:details];

        if ([self.delegate respondsToSelector:@selector(httpSessionRequest:withError:)] == YES)
            [self.delegate httpSessionRequest:self withError:newError];
    }
}

#ifdef DEBUG

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod
                           isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
            if([challenge.protectionSpace.host
                               isEqualToString:@"api.map-care.com"])
            {
                NSURLCredential *credential =
                              [NSURLCredential credentialForTrust:
                                              challenge.protectionSpace.serverTrust];
                completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
            }
            else
            {
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            }
    }
}

#endif

@end
