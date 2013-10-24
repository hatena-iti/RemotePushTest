//
//  DownloadManager.h
//  RemotePushTest
//
//  Created by matoh on 2013/10/10.
//  Copyright (c) 2013年 ITI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject <NSURLSessionDownloadDelegate>

+ (DownloadManager *)defaultManager;
- (void)downloadWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)downloadCustomWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
