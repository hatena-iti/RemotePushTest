//
//  DownloadManager.m
//  RemotePushTest
//
//  Created by matoh on 2013/10/10.
//  Copyright (c) 2013年 ITI. All rights reserved.
//

#import "DownloadManager.h"

#import "Logger.h"


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// Please note that you should specify any URL
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#define TARGET_URL @"http://..."


@implementation DownloadManager {
    NSURLSession *session_;
    
    void (^completionHandler_)(UIBackgroundFetchResult);
}

static DownloadManager *defaultManager = nil;


+ (DownloadManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[DownloadManager alloc] init];
    });
    return defaultManager;
}

- (id)init {
    self = [super init];
    if (self) {
        completionHandler_ = nil;
    }
    return self;
}

- (void)downloadWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
#if 1
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
#else
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"sessionId"];
#endif
    
    [session_ invalidateAndCancel];
    session_ = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    NSURL *url = [NSURL URLWithString:TARGET_URL];
    
    NSURLSessionDownloadTask *downloadTask = [session_ downloadTaskWithURL:url
                                completionHandler:^(NSURL *targetPath, NSURLResponse *response, NSError *error)
                     {
                         
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         UIBackgroundFetchResult result = UIBackgroundFetchResultFailed;    // default
                         
                         if (error) {
                             FLog(@"[E]%@", [error localizedDescription]);
                         } else {
                             if([response isKindOfClass:[NSHTTPURLResponse class]]){
                                 NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
                                 NSInteger statusCode = [httpURLResponse statusCode];
                                 FLog(@"[statusCode]%d", statusCode);
                                 
                                 if (statusCode == 200) {
                                     if([targetPath isFileURL]){
                                         NSString *fromPath = [targetPath path];
                                         
                                         NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                                         NSString *fileName = [NSString stringWithFormat:@"download_%f.pdf", [[NSDate date] timeIntervalSince1970]];
                                         NSString *toPath = [docDir stringByAppendingPathComponent:fileName];
                                         
                                         [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:nil];
                                         result = UIBackgroundFetchResultNewData;
                                     }
                                 }
                             }
                             
                             [session_ invalidateAndCancel];
                         }
                         
                         completionHandler(result);
                     }];
    
    if (downloadTask) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        // start download...
        [downloadTask resume];
    } else {
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
}


- (void)downloadCustomWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
#if 0
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
#else
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"sessionId"];
#endif
    
    [session_ invalidateAndCancel];
    session_ = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    if (completionHandler_) {
        completionHandler_(UIBackgroundFetchResultFailed);
    }
    completionHandler_ = completionHandler;
    
    NSURL *url = [NSURL URLWithString:TARGET_URL];
    
    NSURLSessionDownloadTask *sessionDownloadTask = [session_ downloadTaskWithURL:url];
    if (sessionDownloadTask) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        // start download...
        [sessionDownloadTask resume];
    } else {
        completionHandler(UIBackgroundFetchResultFailed);
    }
}


#pragma mark NSURLSessionTaskDelegate implementation

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandle
{
	FLog(@"newRequest");
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
	FLog(@"didReceiveChallenge");
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengeUseCredential;
    completionHandler(disposition, nil);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
	FLog(@"needNewBodyStream");
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
	FLog(@"didSendBodyData");
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
	FLog(@"didCompleteWithError");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (error) {
        FLog(@"[E]%@", [error localizedDescription]);
    }
    
    [session invalidateAndCancel];
    
    if (completionHandler_) {
        completionHandler_(UIBackgroundFetchResultFailed);
    } else {
        FLog(@"completionHandler_ is nil");
    }
    completionHandler_ = nil;
}



#pragma mark NSURLSessionDownloadDelegate implementation

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
	FLog(@"didFinishDownloadingToURL");
    
    UIBackgroundFetchResult result = UIBackgroundFetchResultFailed;    // default

    if([location isFileURL]){
        NSString *fromPath = [location path];
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [NSString stringWithFormat:@"download_%f.pdf", [[NSDate date] timeIntervalSince1970]];
        NSString *toPath = [docDir stringByAppendingPathComponent:fileName];
        
        [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:nil];
        result = UIBackgroundFetchResultNewData;
    }
    
    [session invalidateAndCancel];
    
    if (completionHandler_) {
        completionHandler_(result);
    } else {
        FLog(@"completionHandler_ is nil");
    }
    completionHandler_ = nil;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    FLog(@"[progress] %f", progress);
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
	FLog(@"didResumeAtOffset");
}

@end
