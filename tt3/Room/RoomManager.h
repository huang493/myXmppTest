//
//  RoomManager.h
//  tt3
//
//  Created by apple on 15/9/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

typedef enum {
    
    Maxusers5 = 5,
    Maxusers10 = 10,
    Maxusers20 = 20,
    Maxusers30 = 30,
    Maxusers50 = 50,
    Maxusers100 = 100,
    Maxusers200 = 200
    
} RoomconfigMaxusers;

typedef enum {
    ModeratorsKnowWhois = 1,
    AnyoneKnowWhois
} RoomconfigWhois;

typedef enum {
    NobodyPrivateMessage = 1,
    ModeratorsOnlyPrivateMessage,
    AnyonePrivateMessage
} AllowPrivateMessagesFromVisitors;

typedef enum {
    
    KNSInteger = 1,
    KNSString = 2,
    KBOOL = 3
    
} CreateElementType;





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

-(void)configRoomWithRoomJID:(XMPPJID *)roomJID
         roomconfig_roomname:(NSString *)roomconfig_roomname
         roomconfig_roomdesc:(NSString *)roomconfig_roomdesc
 isRoomconfig_persistentroom:(BOOL)isRoomconfig_persistentroom
     isRoomconfig_publicroom:(BOOL)isRoomconfig_publicroom
isRoomconfig_passwordprotectedroom:(BOOL)isRoomconfig_passwordprotectedroom
       roomconfig_roomsecret:(NSString *)roomconfig_roomsecret
         roomconfig_maxusers:(RoomconfigMaxusers )roomconfig_maxusers
            roomconfig_whois:(RoomconfigWhois)roomconfig_whois
    isRoomconfig_membersonly:(BOOL)isRoomconfig_membersonly
  isRoomconfig_moderatedroom:(BOOL)isRoomconfig_moderatedroom
          members_by_default:(BOOL)isMembers_by_default
  isRoomconfig_changesubject:(BOOL)isRoomconfig_changesubject
    isAllow_private_messages:(BOOL)isAllow_private_messages
allow_private_messages_from_visitors:(AllowPrivateMessagesFromVisitors)allow_private_messages_from_visitors
         isAllow_query_users:(BOOL)isAllow_query_users
   isRoomconfig_allowinvites:(BOOL)isRoomconfig_allowinvites
isRoomconfig_allowvisitorstatus:(BOOL)isRoomconfig_allowvisitorstatus
isRoomconfig_allowvisitornickchange:(BOOL)isRoomconfig_allowvisitornickchange
isRoomconfig_allowvoicerequests:(BOOL)isRoomconfig_allowvoicerequests
roomconfig_voicerequestmininterval:(NSInteger)roomconfig_voicerequestmininterval
 roomconfig_captcha_whitelis:(id)roomconfig_captcha_whitelis
             isDefaultConfig:(BOOL)isDefaultConfig;



@end
