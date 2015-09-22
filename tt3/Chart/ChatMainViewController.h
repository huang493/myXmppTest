//
//  ChatMainViewController.h
//  tt3
//
//  Created by apple on 15/7/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMainViewController : UIViewController

@property (strong, nonatomic) UITableView *tView;
@property (strong, nonatomic) UITextField *messageTextField;
@property (strong, nonatomic) UIButton    *sendBtn;
@property (nonatomic,strong ) NSString    *chatWithUser;

@end
