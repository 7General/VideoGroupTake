//
//  AppDelegate.m
//  VideoTake
//
//  Created by zzg on 2018/2/6.
//  Copyright © 2018年 zzg. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "PlayerView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:[MainViewController new]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
//    PlayerView * player = [[PlayerView alloc] init];
//    if (player.playState == AVPlayerStatusUnknown) {
//        UIDevice* device = [UIDevice currentDevice];
//        if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
//            if(device.multitaskingSupported) {
//                if(device.multitaskingSupported) {
//                    if (player.backgroundTaskIdentifier ==UIBackgroundTaskInvalid) {
//                        player.backgroundTaskIdentifier = [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:NULL];
//                    }
//                }
//            }
//        }
//    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
//    PlayerView * player = [[PlayerView alloc] init];
//    
//        if (player.backgroundTaskIdentifier !=UIBackgroundTaskInvalid) {
//            [[UIApplication sharedApplication] endBackgroundTask: player.backgroundTaskIdentifier];
//            player.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
//        }
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
