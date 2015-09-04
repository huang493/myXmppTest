//
//  AppDelegate.h
//  tt3
//
//  Created by hsm on 15/7/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPClient.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) XMPPClient                *client;
@property (strong, nonatomic) UIWindow                  *window;

@end

