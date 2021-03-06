//
//  AppDelegate.m
//  tt3
//
//  Created by hsm on 15/7/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end


@implementation AppDelegate
//@synthesize xmppStream;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    //异常捕获处理
    NSSetUncaughtExceptionHandler(&caughtExceptionHandler);
    
    //启动XMPPClient
    _client = [[XMPPClient alloc] init];

    return YES;
}

void caughtExceptionHandler(NSException *exception){
    
    NSString *name = [exception name];
    NSString *reason  =[exception reason];
    NSArray  *stackSymbols = [exception callStackSymbols];
    NSString *crashStr = [NSString stringWithFormat:@"\n%@ \n%@ \n%@ \n%@",
                          @"===================异常信息===================",
                          name,
                          reason,
                          [stackSymbols componentsJoinedByString:@"\n"]];
    //打印
    NSLog(@"%@",crashStr);
    
    //保存
    NSDateFormatter *forr = [[NSDateFormatter alloc] init];
    [forr setDateFormat:@"yyyyMMdd_HH:mm:ss"];
    NSString *path = [NSString stringWithFormat:@"%@/Documents/CrashFile%@",NSHomeDirectory(),[forr stringFromDate:[NSDate date]]];
    [crashStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

#pragma -mark applicationDelegate////////////////////////////////
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
