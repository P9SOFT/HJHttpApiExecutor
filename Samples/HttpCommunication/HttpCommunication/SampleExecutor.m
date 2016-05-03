//
//  SampleExecutor.m
//  HttpCommunication
//
//  Created by Tae Hyun Na on 2015. 12. 23.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "SampleExecutor.h"

@implementation SampleExecutor

- (NSString *)name
{
	return SampleExecutorName;
}

- (NSString *)brief
{
    return @"sample api executor";
}

- (NSString *)apiUrlFromQuery:(id)anQuery
{
    NSString *serverApiUrl = [anQuery parameterForKey:SampleExecutorParameterServerApiUrlKey];
    if( serverApiUrl.length == 0 ) {
        return nil;
    }
    
    return serverApiUrl;
}

- (NSDictionary *)apiParameterFromQuery:(id)anQuery
{
    id anObject = [anQuery parameterForKey:SampleExecutorParameterRequestParameterKey];
    if( [anQuery isKindOfClass:[NSDictionary class]] == NO ) {
        return nil;
    }
    
    return (NSDictionary *)anObject;
}

- (HJHttpApiExecutorHttpMethodType)httpMethodType:(id)anQuery
{
    NSString *httpMethod = [anQuery parameterForKey:SampleExecutorParameterHttpMethodKey];
    if( [httpMethod isEqualToString:@"GET"] == YES ) {
        return HJHttpApiExecutorHttpMethodTypeGet;
    }
    
    return HJHttpApiExecutorHttpMethodTypePost;
}

- (HJAsyncHttpDelivererPostContentType)postContentTypeFromQuery:(id)anQuery
{
    return HJAsyncHttpDelivererPostContentTypeUrlEncoded;
}

- (BOOL)appendResultParameterToQuery:(id)anQuery withParsedObject:(id)parsedObject
{
    if( [parsedObject isKindOfClass:[NSDictionary class]] == NO ) {
        return NO;
    }
    
    [anQuery setParameter:parsedObject forKey:SampleExecutorParameterResultParameterKey];
    
    return YES;
}

- (NSArray *)trustedHosts
{
#warning set trust host if you deal with server by HTTPS
    // set trust host if you deal with server by HTTPS
    // and if you consider that support iOS 9 over then check 'NSAppTransportSecurity' key at Info.plist.
    return @[@"www.p9soft.com"];
}

@end
