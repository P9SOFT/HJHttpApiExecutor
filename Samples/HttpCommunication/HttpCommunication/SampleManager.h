//
//  SampleManager.h
//  HttpCommunication
//
//  Created by Tae Hyun Na on 2015. 12. 23.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <UIKit/UIKit.h>
#import <Hydra/Hydra.h>

#define		SampleManagerNotification                           @"sampleManagerNotification"

#define		SampleManagerNotifyParameterKeyServerApiUrl         @"sampleManagerNotifyParameterKeyServerApiUrl"
#define     SampleManagerNotifyParameterKeyFailedFlag           @"sampleManagerNotifyParameterKeyFailedFlag"
#define     SampleManagerNotifyParameterKeyCompletionBlock      @"sampleManagerNotifyParameterKeyCompletionBlock"
#define     SampleManagerNotifyParameterKeyRequestDict          @"sampleManagerNotifyParameterKeyRequestDict"
#define		SampleManagerNotifyParameterKeyResultDict           @"sampleManagerNotifyParameterKeyResultDict"

@interface SampleManager : HYManager

+ (SampleManager *)defaultManager;
- (BOOL)standbyWithWorkerName:(NSString *)workerName;

- (void)requestServerApi:(NSString *)serverApiUrl httpMethod:(NSString *)httpMethod parameterDict:(NSDictionary *)parameterDict completion:(void (^)(NSMutableDictionary *))completion;

@property (nonatomic, readonly) BOOL standby;

@end
