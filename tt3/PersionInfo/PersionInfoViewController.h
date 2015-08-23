//
//  PersionInfoViewController.h
//  tt3
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "PersionInfoModel.h"

@interface PersionInfoViewController : BaseViewController <KKVcarDelegate>

@property (nonatomic,strong) PersionInfoModel    *model;
@property (nonatomic,strong) NSString *messageFrom;
@property (nonatomic,strong) NSArray *userInfoDicArr;//本地UserInfo
@property (nonatomic,assign) BOOL     isMe;
@property (nonatomic,strong) XMPPJID  *jid;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end
