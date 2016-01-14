//
//  HJHttpApiExecutor.h
//	HJBox
//
//  Created by Na Tae Hyun on 13. 10. 24..
//  Copyright (c) 2013년 Na Tae Hyun. All rights reserved.
//
//  Licensed under the MIT license.

#import <UIKit/UIKit.h>
#import <Hydra/Hydra.h>
#import <HJAsyncHttpDeliverer/HJAsyncHttpDeliverer.h>


#define		HJHttpApiExecutorName									@"HJHttpApiExecutorName"

#define		HJHttpApiExecutorParameterKeyStatus						@"HJHttpApiExecutorParameterKeyStatus"
#define		HJHttpApiExecutorParameterKeyBodyStream					@"HJHttpApiExecutorParameterKeyBodyStream"
#define		HJHttpApiExecutorParameterKeyCloseQueryCall				@"HJHttpApiExecutorParameterKeyCloseQueryCall"
#define		HJHttpApiExecutorParameterKeyDelivererIssuedId			@"HJHttpApiExecutorParameterKeyDelivererIssuedId"

typedef enum _HJHttpApiExecutorStatus_
{
	HJHttpApiExecutorStatusDummy,
	HJHttpApiExecutorStatusRequested,
	HJHttpApiExecutorStatusReceived,
	HJHttpApiExecutorStatusCanceled,
	HJHttpApiExecutorStatusExpired,
	HJHttpApiExecutorStatusInvalidParameter,
	HJHttpApiExecutorStatusInternalError,
	HJHttpApiExecutorStatusNetworkError,
	HJHttpApiExecutorStatusFailedResponse,
	HJHttpApiExecutorStatusDataParsingError,
	HJHttpApiExecutorStatusEmptyData
    
} HJHttpApiExecutorStatus;

typedef enum _HJHttpApiExecutorHttpMethodType_
{
	HJHttpApiExecutorHttpMethodTypeGet,
	HJHttpApiExecutorHttpMethodTypePost
    
} HJHttpApiExecutorHttpMethodType;

typedef enum _HJHttpApiExecutorReceiveBodyType_
{
	HJHttpApiExecutorReceiveBodyTypeStream,
    HJHttpApiExecutorReceiveBodyTypeCustom
    
} HJHttpApiExecutorReceiveBodyType;


@interface HJHttpApiExecutor : HYExecuter

// you must override and implement these methods.

- (NSString *) apiUrlFromQuery: (id)anQuery;

// override these methods if need.

- (BOOL) isValidParameterForQuery: (id)anQuery;
- (NSDictionary *) apiParameterFromQuery: (id)anQuery;
- (HJHttpApiExecutorHttpMethodType) httpMethodType: (id)anQuery;
- (HJAsyncHttpDelivererPostContentType) postContentTypeFromQuery: (id)anQuery;
- (HJHttpApiExecutorReceiveBodyType) receiveBodyTypeFromQuery: (id)anQuery;
- (NSString *) activeLimiterName;
- (NSInteger) activeLimiterCount;
- (id) objectFromData:(NSMutableData *)data fromQuery: (id)anQuery;
- (BOOL) customSetupWithDeliverer: (HJAsyncHttpDeliverer *)deliverer fromQuery: (id)anQuery;
- (BOOL) additionalSetupWithDeliverer: (HJAsyncHttpDeliverer *)deliverer fromQuery: (id)anQuery;
- (BOOL) appendResultParameterToQuery: (id)anQuery withParsedObject: (id)parsedObject;
- (NSTimeInterval) timeoutIntervalFromQuery: (id)anQuery;
- (NSArray *) trustedHosts;

@end
