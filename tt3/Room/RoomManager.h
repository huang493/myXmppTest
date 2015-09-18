//
//  RoomManager.h
//  tt3
//
//  Created by apple on 15/9/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"




@interface RoomManager : NSObject



+(RoomManager *)shareRoomManager;

-(void)createRoom:(NSString *)name andJoinNickName:(NSString *)nickName;
-(void)destroyRoom:(NSString *)name;

-(void)invite:(NSString *)name intoRoom:(NSString *)roomName;
-(void)kit:(NSString *)name fromRoom:(NSString *)roomName;

-(void)getMemberList:(XMPPJID *)roomJid;
-(void)getRoomInfoByRoomName:(NSString *)name;
-(void)getRoomInfoByRoomJID:(XMPPJID *)roomJID;
-(void)getMemberInfo:(XMPPJID *)jid;

-(void)sendTextMessageToAll:(NSString *)msg;
-(void)sendTextMessage:(NSString *)msg To:(XMPPJID *)jid;

-(void)defalutConfigForRoomName:(NSString *)roomName;
-(void)defalutConfigForRoomJID:(XMPPJID *)roomJID;




@end
