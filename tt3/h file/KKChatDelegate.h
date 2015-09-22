//
//  KKChatDelegate.h
//  tt3
//
//  Created by hsm on 15/7/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//
#import "FriendListModel.h"

@protocol KKChatDelegate <NSObject>

-(void)newBuddyOnline:(NSString *) buddyID;
-(void)buddyWentOffline:(NSString *) buddyID;
-(void)joinRoom:(NSString *)roomID;
-(void)didDisconnect;


@end
