//
//  HJHttpApiExecutor.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2013. 10. 24.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
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

typedef NS_ENUM(NSInteger, HJHttpApiExecutorStatus)
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
};

typedef NS_ENUM(NSInteger, HJHttpApiExecutorHttpMethodType)
{
	HJHttpApiExecutorHttpMethodTypeGet,
	HJHttpApiExecutorHttpMethodTypePost,
    HJHttpApiExecutorHttpMethodTypePut,
    HJHttpApiExecutorHttpMethodTypeDelete
};

typedef NS_ENUM(NSInteger, HJHttpApiExecutorReceiveBodyType)
{
	HJHttpApiExecutorReceiveBodyTypeStream,
    HJHttpApiExecutorReceiveBodyTypeCustom
};


@interface HJHttpApiExecutor : HYExecuter

// you must override and implement these methods.

- (NSString * _Nullable) apiUrlFromQuery: (id _Nullable)anQuery;

// override these methods if need.

- (BOOL) isValidParameterForQuery: (id _Nullable)anQuery;
- (BOOL) isUsingCustomBodyForQuery: (id _Nullable)anQuery;
- (NSDictionary * _Nullable) apiParameterFromQuery: (id _Nullable)anQuery;
- (NSData * _Nullable) customBodyFromQuery: (id _Nullable)anQuery;
- (NSString * _Nullable) contentTypeForCustomBodyFromQuery: (id _Nullable)anQuery;
- (HJHttpApiExecutorHttpMethodType) httpMethodType: (id _Nullable)anQuery;
- (HJAsyncHttpDelivererPostContentType) postContentTypeFromQuery: (id _Nullable)anQuery;
- (HJHttpApiExecutorReceiveBodyType) receiveBodyTypeFromQuery: (id _Nullable)anQuery;
- (NSString * _Nullable) activeLimiterName;
- (NSInteger) activeLimiterCount;
- (id _Nullable) objectFromData:(NSMutableData * _Nullable)data fromQuery: (id _Nullable)anQuery;
- (BOOL) customSetupWithDeliverer: (HJAsyncHttpDeliverer * _Nullable)deliverer fromQuery: (id _Nullable)anQuery;
- (BOOL) additionalSetupWithDeliverer: (HJAsyncHttpDeliverer * _Nullable)deliverer fromQuery: (id _Nullable)anQuery;
- (BOOL) appendResultParameterToQuery: (id _Nullable)anQuery withParsedObject: (id _Nullable)parsedObject;
- (NSTimeInterval) timeoutIntervalFromQuery: (id _Nullable)anQuery;
- (NSArray * _Nullable) trustedHosts;

@end
