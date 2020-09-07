//
//  HttpRequest.h
//  NavigationUpdagter
//
//  Created by bhchae76 on 2017. 4. 10..
//  Copyright © 2017년 bhchae76. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HttpSessionRequest;
@protocol HttpSessionRequestDelegate <NSObject>
@optional
/*
    요청시 오류가 발생할 경우 호출되는 함수
    파라미터:
        httpSessionRequest : HttpSessionRequest객체
        error : 오류정보 객체
 */
- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest withError:(NSError *)error;

/*
    요청 성공시 호출되는 함수
    파라미터:
        httpSessionRequest : HttpSessionRequest객체
        data : 서버에서 수신된 데이터
 */
- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLodingData:(NSData *)data;

/*
    헤더정보 요청 성공시 호출되는 함수
    파라미터:
        httpSessionRequest : HttpSessionRequest객체
        headerInfo : 헤더 정보
 */
- (void) httpSessionRequest:(HttpSessionRequest *)httpSessionRequest didFinishLoadHeaderInfo:(NSDictionary *)headerInfo;

@end

/*
    HTTP 통신 객체(10.9이상 지원)
 */
@interface HttpSessionRequest : NSObject

- (void)requestURL:(NSString *)url withMultipartBody:(NSData *)body withBoundary:(NSString *)boundary;

/*
    파라미터 url과 values로 URL 요청을 한다.
    요청이 성공하면 httpSessionRequest:didFinishLodingData: 델리게이트 함수가 호출된다.
    요청이 실패하면 httpSessionRequest:withError: 델리게이트 함수가 호출된다.
    파라미터:
        url : 요청할 URL
        values : 요청시 전달할 데이터
        fileName : Multipart 로 전달할 파일명
        filePath : Muttipart 로 전달할 파일의 경로명
 */
- (void)requestURL:(NSString *)url withValues:(NSDictionary *)values withFileName:(NSString *)fileName withFilePath:(NSString *)filePath;

/*
    파라미터 url과 values로 URL 요청을 한다.
    요청이 성공하면 httpSessionRequest:didFinishLodingData: 델리게이트 함수가 호출된다.
    요청이 실패하면 httpSessionRequest:withError: 델리게이트 함수가 호출된다.
    파라미터:
        url : 요청할 URL
        values : 요청시 전달할 데이터
 */
- (void)requestURL:(NSString *)url withValues:(NSDictionary *)values;

/*
    파라미터 json 데이터를 서버에 보낸댜.
    요청이 성공하면 httpSessionRequest:didFinishLodingData: 델리게이트 함수가 호출된다.
    요청이 실패하면 httpSessionRequest:withError: 델리게이트 함수가 호출된다.
    파라미터:
        url : 요청할 URL
        jsonString : 보낼 json 데이터
 */
- (void)requestURL:(NSString *)url withJsonString:(NSString *)jsonString;

/*
    파라미터 json 데이터를 서버에 보낸댜.
    요청이 성공하면 httpSessionRequest:didFinishLodingData: 델리게이트 함수가 호출된다.
    요청이 실패하면 httpSessionRequest:withError: 델리게이트 함수가 호출된다.
    파라미터:
        url : 요청할 URL
        valueString : 보낼 value 데이터
 */
- (void)requestURL:(NSString *)url withValueString:(NSString *)valueString;

/*
    헤더 정보를 요청한다.
    요청이 성공하면 httpSessionRequest:didFinishLoadHeaderInfo: 델리게이트 함수가 호출된다.
    요청이 실패하면 httpSessionRequest:withError: 델리게이트 함수가 호출된다.
    파라미터:
        url : 요청할 URL
 */

- (void)requestHeaderInfo:(NSString *)url;

/*
    현재 URL 요청을 취소한다.
 */
- (void)cancelForRequest;

/*
    생성된 세션을 Close 한다.
 */
- (void)closeSession;

@property (nonatomic, assign) NSTimeInterval timeout;                       // 요청 타임아웃
@property (nonatomic, assign) id <HttpSessionRequestDelegate> delegate;
@property (nonatomic, assign) int tag;                                      // tag 값
@property (nonatomic, strong) NSObject *data;                               // 사용자 정의 데이터
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSString *httpMethod;                         // HTTP 메쏘드(GET, POST)
@end
