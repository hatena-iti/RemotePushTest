//
//  Logger.h
//  RemotePushTest
//
//  Created by matoh on 2013/10/10.
//  Copyright (c) 2013年 ITI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject

#define FLog(messageFormat, ...) [Logger log:messageFormat, ##__VA_ARGS__]

+ (void)log:(NSString*)logFormat, ...;

@end
