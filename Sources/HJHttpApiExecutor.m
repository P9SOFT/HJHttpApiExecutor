//
//  HJHttpApiExecutor.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2013. 10. 24.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "HJHttpApiExecutor.h"


@interface HJHttpApiExecutor() <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
{
    NSURLSession        *_session;
    NSMutableDictionary *_taskDict;
}

- (void)setTask:(HJAsyncHttpDeliverer *)deliverer forKey:(NSString *)key;
- (HJAsyncHttpDeliverer *)taskForKey:(NSString *)key;
- (void)removeTaskForKey:(NSString *)key;
- (HYResult *) resultForQuery: (id)anQuery withStatus: (HJHttpApiExecutorStatus)status;

@end


@implementation HJHttpApiExecutor

- (instancetype)init
{
    if( (self = [super init]) != nil ) {
        if( (_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil]) == nil ) {
            return nil;
        }
        if( (_taskDict = [NSMutableDictionary new]) == nil ) {
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_session invalidateAndCancel];
    _session = nil;
}

- (NSString *) name
{
	return HJHttpApiExecutorName;
}

- (NSString *) brief
{
	return @"executor for communication with server API based on HTTP";
}

- (void)setTask:(HJAsyncHttpDeliverer *)deliverer forKey:(NSString *)key
{
    if( (deliverer == nil) && (key == nil) ) {
        return;
    }
    @synchronized (self) {
        _taskDict[key] = deliverer;
    }
}

- (HJAsyncHttpDeliverer *)taskForKey:(NSString *)key
{
    if( key == nil ) {
        return nil;
    }
    HJAsyncHttpDeliverer *deliverer = nil;
    @synchronized (self) {
        deliverer = _taskDict[key];
    }
    return deliverer;
}

- (void)removeTaskForKey:(NSString *)key
{
    if( key == nil ) {
        return;
    }
    @synchronized (self) {
        [_taskDict removeObjectForKey:key];
    }
}

- (BOOL) calledExecutingWithQuery: (id)anQuery
{
	HYQuery                 *closeQuery;
	HJAsyncHttpDeliverer    *deliverer;
	NSMutableData           *receivedData;
	id                      parsedObject;
	NSString                *apiUrlString;
	
	if( [[anQuery parameterForKey: HJHttpApiExecutorParameterKeyCloseQueryCall] boolValue] == YES ) {
		
		if( [[anQuery parameterForKey: HJAsyncHttpDelivererParameterKeyFailed] boolValue] == YES ) {
			[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusNetworkError]];
            [self removeTaskForKey:[[anQuery parameterForKey:HJAsyncHttpDelivererParameterKeyIssuedId] stringValue]];
			return YES;
		}
		
		receivedData = [anQuery parameterForKey: HJAsyncHttpDelivererParameterKeyBody];
		
		if( receivedData.length > 0 ) {
			switch( [self receiveBodyTypeFromQuery: anQuery] ) {
				case HJHttpApiExecutorReceiveBodyTypeCustom :
                    if( (parsedObject = [self objectFromData: receivedData fromQuery:anQuery]) != nil ) {
						if( [self appendResultParameterToQuery: anQuery withParsedObject:parsedObject] == YES ) {
							[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusReceived]];
						} else {
                            [anQuery setParameter: receivedData forKey: HJHttpApiExecutorParameterKeyBodyStream];
							[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusDataParsingError]];
						}
					} else {
                        [anQuery setParameter: receivedData forKey: HJHttpApiExecutorParameterKeyBodyStream];
						[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusDataParsingError]];
					}
					break;
				default :
					[anQuery setParameter: receivedData forKey: HJHttpApiExecutorParameterKeyBodyStream];
					[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusReceived]];
					break;
			}
		} else {
			[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusEmptyData]];
		}
        
        [self removeTaskForKey:[[anQuery parameterForKey:HJAsyncHttpDelivererParameterKeyIssuedId] stringValue]];
		
	} else {
		
		apiUrlString = [self apiUrlFromQuery: anQuery];
		if( apiUrlString.length <= 0 ) {
			[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusInvalidParameter]];
			return YES;
		}
		
		if( [self isValidParameterForQuery: anQuery] == NO ) {
			[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusInvalidParameter]];
			return YES;
		}
		
		if( (closeQuery = [HYQuery queryWithWorkerName: [self.employedWorker name] executerName: self.name]) == nil ) {
			[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusInternalError]];
			return YES;
		}
		
		[closeQuery setParametersFromDictionary: [anQuery paramDict]];
		[closeQuery setParameter: @"Y" forKey: HJHttpApiExecutorParameterKeyCloseQueryCall];
        [closeQuery setParameter:_session forKey:HJAsyncHttpDelivererParameterKeySession];
		
		if( (deliverer = [[HJAsyncHttpDeliverer alloc] initWithCloseQuery: closeQuery]) == nil ) {
			[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusInternalError]];
			return YES;
		}
		deliverer.trustedHosts = [self trustedHosts];
		
		[anQuery setParameter: @((NSUInteger)deliverer.issuedId) forKey: HJHttpApiExecutorParameterKeyDelivererIssuedId];
		[closeQuery setParameter: @((NSUInteger)deliverer.issuedId) forKey: HJHttpApiExecutorParameterKeyDelivererIssuedId];
		
		if( [self customSetupWithDeliverer: deliverer fromQuery: anQuery] == NO ) {
			switch( [self httpMethodType: anQuery] ) {
				case HJHttpApiExecutorHttpMethodTypeGet :
					[deliverer setGetWithUrlString: apiUrlString queryStringDict: [self apiParameterFromQuery: anQuery]];
					break;
				case HJHttpApiExecutorHttpMethodTypePost :
					[deliverer setPostWithUrlString: apiUrlString formDataDict: [self apiParameterFromQuery: anQuery] contentType: [self postContentTypeFromQuery: anQuery]];
					break;
                case HJHttpApiExecutorHttpMethodTypePut :
                    [deliverer setPutWithUrlString: apiUrlString formDataDict: [self apiParameterFromQuery: anQuery] contentType: [self postContentTypeFromQuery: anQuery]];
                    break;
                case HJHttpApiExecutorHttpMethodTypeDelete :
                    [deliverer setDeleteWithUrlString: apiUrlString formDataDict: [self apiParameterFromQuery: anQuery] contentType: [self postContentTypeFromQuery: anQuery]];
                    break;
				default :
					[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusInternalError]];
					return YES;
			}
			if( [self additionalSetupWithDeliverer: deliverer fromQuery: anQuery] == NO ) {
				[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusInternalError]];
				return YES;
			}
		}
        if( ([self activeLimiterName] != nil) && ([self activeLimiterCount] > 0) ) {
            [deliverer activeLimiterName: [self activeLimiterName] withCount: [self activeLimiterCount]];
        }
		deliverer.timeoutInterval = [self timeoutIntervalFromQuery: anQuery];
        if( [self bindAsyncTask: deliverer] == YES ) {
            [self setTask:deliverer forKey:[@(deliverer.issuedId) stringValue]];
        }
		[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusRequested]];
		
	}
	
	return YES;
}

- (BOOL) calledCancelingWithQuery: (id)anQuery
{
	[self storeResult: [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusCanceled]];
	
	return YES;
}

- (id) resultForExpiredQuery: (id)anQuery
{
	return [self resultForQuery: anQuery withStatus: HJHttpApiExecutorStatusExpired];
}

- (HYResult *) resultForQuery: (id)anQuery withStatus: (HJHttpApiExecutorStatus)status
{
	HYResult	*result;
	
	if( (result = [HYResult resultWithName: self.name]) != nil ) {
		[result setParametersFromDictionary: [anQuery paramDict]];
		[result setParameter: @(status) forKey: HJHttpApiExecutorParameterKeyStatus];
	}
	
	return result;
}

- (NSString *) apiUrlFromQuery: (id)anQuery
{
	return nil;
}

- (BOOL) isValidParameterForQuery: (id)anQuery
{
	return YES;
}

- (NSDictionary *) apiParameterFromQuery: (id)anQuery
{
	return nil;
}

- (HJHttpApiExecutorHttpMethodType) httpMethodType: (id)anQuery
{
	return HJHttpApiExecutorHttpMethodTypeGet;
}

- (HJAsyncHttpDelivererPostContentType) postContentTypeFromQuery: (id)anQuery
{
	return HJAsyncHttpDelivererPostContentTypeUrlEncoded;
}

- (HJHttpApiExecutorReceiveBodyType) receiveBodyTypeFromQuery: (id)anQuery
{
	return HJHttpApiExecutorReceiveBodyTypeCustom;
}

- (NSString *) activeLimiterName
{
    return nil;
}

- (NSInteger) activeLimiterCount
{
    return 0;
}

- (id) objectFromData:(NSMutableData *)data fromQuery: (id)anQuery
{
    return [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: nil];
}

- (BOOL) customSetupWithDeliverer: (HJAsyncHttpDeliverer *)deliverer fromQuery: (id)anQuery
{
	return NO;
}

- (BOOL) additionalSetupWithDeliverer: (HJAsyncHttpDeliverer *)deliverer fromQuery: (id)anQuery
{
	return YES;
}

- (BOOL) appendResultParameterToQuery: (id)anQuery withParsedObject: (id)parsedObject
{
	return YES;
}

- (NSTimeInterval) timeoutIntervalFromQuery: (id)anQuery
{
	return 8.0f;
}

- (NSArray *) trustedHosts
{
	return nil;
}

#pragma mark -
#pragma mark NSURLSessionTaskDelegate, NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    if( completionHandler != nil ) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    HJAsyncHttpDeliverer *deliverer = [self taskForKey:dataTask.taskDescription];
    [deliverer receiveResponse:response];
    if( completionHandler != nil ) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    HJAsyncHttpDeliverer *deliverer = [self taskForKey:dataTask.taskDescription];
    [deliverer receiveData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    HJAsyncHttpDeliverer *deliverer = [self taskForKey:task.taskDescription];
    [deliverer sendBodyData:bytesSent totalBytesWritten:totalBytesSent totalBytesExpectedToWrite:totalBytesExpectedToSend];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    HJAsyncHttpDeliverer *deliverer = [self taskForKey:task.taskDescription];
    if( error != nil ) {
        [deliverer failWithError:error];
    } else {
        [deliverer finishLoading];
    }
}

@end
