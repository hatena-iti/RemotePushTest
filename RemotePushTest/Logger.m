//
//  Logger.m
//  RemotePushTest
//
//  Created by matoh on 2013/10/10.
//  Copyright (c) 2013年 ITI. All rights reserved.
//

#import "Logger.h"

@implementation Logger


static NSString        *docDir;
static NSDateFormatter *logFileDateFormat;
static NSDateFormatter *dateFormat;

+ (void)initialize {
    docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    logFileDateFormat = [[NSDateFormatter alloc] init];
    logFileDateFormat.dateFormat = @"yyyyMMdd";
    
    dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
}

+ (void)log:(NSString*)logFormat, ...
{
    @autoreleasepool {
        va_list ap;
        va_start(ap, logFormat);
        NSString *message = [[NSString alloc] initWithFormat:logFormat arguments:ap];
        va_end(ap);
        
        NSLog(@"%@", message);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *logMessage;
        
        NSString *logFileName = [NSString stringWithFormat:@"%@.log",
                                 [logFileDateFormat stringFromDate:[NSDate date]]];
        NSString *logFilePath = [docDir stringByAppendingPathComponent:logFileName];
        if (![fileManager fileExistsAtPath:logFilePath]) {
            [fileManager createFileAtPath:logFilePath
                                 contents:nil
                               attributes:nil];
        }
        
        logMessage = [NSString stringWithFormat:@"%@ %@\n",
                      [dateFormat stringFromDate:[NSDate date]], message];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
}

@end
