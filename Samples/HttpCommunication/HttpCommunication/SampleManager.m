//
//  SampleManager.m
//  HttpCommunication
//
//  Created by Tae Hyun Na on 2015. 12. 23.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "SampleManager.h"
#import "SampleExecutor.h"

@interface SampleManager (SampleManagerPrivate)

- (NSMutableDictionary *)sampleExecutorHandlerWithResult:(HYResult *)result;

@end

@implementation SampleManager

@synthesize standby = _standby;

- (NSString *) name
{
	return SampleManagerNotification;
}

- (NSString *) brief
{
	return @"Sample manager";
}

+ (SampleManager *)defaultManager
{
	static dispatch_once_t	once;
	static SampleManager	*sharedInstance;
	
	dispatch_once(&once, ^{ sharedInstance = [[self alloc] init];});
	
	return sharedInstance;
}

- (BOOL)standbyWithWorkerName:(NSString *)workerName
{
	if( (self.standby == YES) || ([workerName length] <= 0) ) {
		return NO;
	}
	
	// regist executor with handling method
	[self registExecuter: [[SampleExecutor alloc] init] withWorkerName:workerName action:@selector(sampleExecutorHandlerWithResult:)];
	
	_standby = YES;
	
	return YES;
}

- (void)requestServerApi:(NSString *)serverApiUrl httpMethod:(NSString *)httpMethod parameterDict:(NSDictionary *)parameterDict completion:(void (^)(NSMutableDictionary *))completion
{
    // check parameter
    if( ([serverApiUrl length] == 0) || (([httpMethod isEqualToString:@"GET"] == NO) && ([httpMethod isEqualToString:@"POST"] == NO)) ) {
        if( completion != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }
    
    // make query
    HYQuery *query;
    if( (query = [self queryForExecutorName:SampleExecutorName]) == nil ) {
        if( completion != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }
    
    // set url string of server api with its key.
    [query setParameter:serverApiUrl forKey:SampleExecutorParameterServerApiUrlKey];
    
    // set operation of executor by checking http method parameter.
    [query setParameter:httpMethod forKey:SampleExecutorParameterHttpMethodKey];
    
    // set parameter dictionary with its key, and it'll used query string of http GET method or post parameter of http POST method.
    [query setParameter:parameterDict forKey:SampleExecutorParameterRequestParameterKey];
    
    // set completion handler for task after http communiation.
    [query setParameter:completion forKey:SampleManagerNotifyParameterKeyCompletionBlock];
    
    // now, query object prepared, push it to hydra.
    [[Hydra defaultHydra] pushQuery:query];
}

- (NSMutableDictionary *)sampleExecutorHandlerWithResult:(HYResult *)result
{
    // get complete handler.
    void (^completionBlock)(NSMutableDictionary *) = [result parameterForKey:SampleManagerNotifyParameterKeyCompletionBlock];
    
    // prepare dictionary object, and it'll have values for notification feedback.
    NSMutableDictionary *paramDict = [NSMutableDictionary new];
    if( paramDict == nil ) {
        if( completionBlock != nil ) {
            completionBlock(nil);
        }
        return nil;
    }
    
    // check parameters and set to dicationary object for feedback if need.
    // here check server api string,
    NSString *serverApiUrl = [result parameterForKey:SampleExecutorParameterServerApiUrlKey];
    if( serverApiUrl == nil ) {
        if( completionBlock != nil ) {
            completionBlock(nil);
        }
        return nil;
    }
    [paramDict setObject:serverApiUrl forKey:SampleManagerNotifyParameterKeyServerApiUrl];
    
    // and request parameters,
    NSMutableDictionary *requestDict = [result parameterForKey:SampleExecutorParameterRequestParameterKey];
    if( requestDict != nil ) {
        [paramDict setObject:requestDict forKey:SampleManagerNotifyParameterKeyRequestDict];
    }
    
    // and received result parameters,
    NSMutableDictionary * resultDict = [result parameterForKey:SampleExecutorParameterResultParameterKey];
    if( resultDict != nil ) {
        [paramDict setObject:resultDict forKey:SampleManagerNotifyParameterKeyResultDict];
    }
    
    // and failed flag.
    HJHttpApiExecutorStatus status = (HJHttpApiExecutorStatus)[[result parameterForKey:HJHttpApiExecutorParameterKeyStatus] integerValue];
    if( (status != HJHttpApiExecutorStatusReceived) && (status != HJHttpApiExecutorStatusEmptyData) ) {
        [paramDict setObject:@"Y" forKey:SampleManagerNotifyParameterKeyFailedFlag];
    }
    
    // if completion block specified, then call it.
    if( completionBlock != nil ) {
        completionBlock(paramDict);
    }
    
    // if 'paramDict' is empty, then we don't have to notification, so return 'nil'.
    if( [paramDict count] == 0 ) {
        return nil;
    }
	
	// 'paramDict' will be 'userInfo' of notification, 'SampleManagerNotification'.
	return paramDict;
}

@end
