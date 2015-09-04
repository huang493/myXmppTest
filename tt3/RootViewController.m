//
//  RootViewController.m
//  tt3
//
//  Created by apple on 15/8/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "RootViewController.h"
#import "KKViewController.h"

@implementation RootViewController

-(void)viewDidLoad{
    
    UIStoryboard *stord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KKViewController *listVC = [stord instantiateViewControllerWithIdentifier:@"KKViewController"];
    [self addChildViewController:listVC];
    [self.view addSubview:listVC.view];
    
}

@end
