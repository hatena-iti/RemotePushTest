//
//  AppDelegate.m
//  RemotePushTest
//
//  Created by matoh on 2013/10/23.
//  Copyright (c) 2013年 ITI. All rights reserved.
//

#import "AppDelegate.h"

#import "DownloadManager.h"
#import "Logger.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    FLog(@"didFinishLaunchingWithOptions");
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif) {
        FLog(@"Remote notification is: %@", remoteNotif);
    }
    
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    FLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    FLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    FLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    FLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    FLog(@"applicationWillTerminate");
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	FLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	FLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	FLog(@"User data is: %@", userInfo);
    
#if 0
    [[DownloadManager defaultManager] downloadWithCompletionHandler:^(UIBackgroundFetchResult result) {
#else
    [[DownloadManager defaultManager] downloadCustomWithCompletionHandler:^(UIBackgroundFetchResult result) {
#endif
        switch (result) {
            case UIBackgroundFetchResultNewData:
                FLog(@"UIBackgroundFetchResultNewData");
                break;
 
            case UIBackgroundFetchResultNoData:
                FLog(@"UIBackgroundFetchResultNoData");
                break;
             
            case UIBackgroundFetchResultFailed:
                FLog(@"UIBackgroundFetchResultFailed");
                break;
        }
        completionHandler(result);
    }];
}
     
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    FLog(@"[identifier]%@", identifier);
    completionHandler();
}
     
@end
