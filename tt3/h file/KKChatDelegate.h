//
//  KKChatDelegate.h
//  tt3
//
//  Created by hsm on 15/7/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

@protocol KKChatDelegate <NSObject>

-(void)newBuddyOnline:(NSString*) buddyName;
-(void)buddyWentOffline:(NSString *) buddyName;
-(void)joinRoom:(NSString *)roomName;
-(void)didDisconnect;


@end
