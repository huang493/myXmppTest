//
//  FriendListModel.h
//  tt3
//
//  Created by hsm on 15/9/19.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendInfoModel.h"
#import "ChatMessageModel.h"
@interface FriendListModel : NSObject

@property (nonatomic,strong) FriendInfoModel *infoModel;
@property (nonatomic,strong) ChatMessageModel *lastMessage;

@end
