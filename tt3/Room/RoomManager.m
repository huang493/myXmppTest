//
//  RoomManager.m
//  tt3
//
//  Created by apple on 15/9/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "RoomManager.h"
#import "XMPPRoomMemoryStorage.h"
#import "AppDelegate.h"

@implementation RoomManager

static RoomManager *manager;

+(RoomManager *)shareRoomManager{
    
    if (!manager)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[RoomManager alloc] init];
        });
    }
    return manager;
}

-(void)createRoom:(NSString *)name andJoinNickName:(NSString *)nickName{
    
    XMPPRoom *xmppRoom = [self getRoomByName:name];
    [xmppRoom fetchConfigurationForm];
    if (nickName.length>0) {
        [xmppRoom joinRoomUsingNickname:nickName history:nil];
    }
}

-(void)destroyRoom:(NSString *)name{

    XMPPRoom *room = [self  getRoomByName:name];
    [room destroyRoom];
}

-(void)getRoomInfoByRoomName:(NSString *)name{
    
    XMPPRoom *room = [self  getRoomByName:name];
    [self getRoomInfoByRoomJID:room.roomJID];

}

-(void)getRoomInfoByRoomJID:(XMPPJID *)roomJID{

    XMPPRoom *room = [self  getRoomByRoomJID:roomJID];
    [room fetchConfigurationForm];
    [room fetchMembersList];
    [room fetchBanList];
    
}

-(void)defalutConfigForRoomName:(NSString *)roomName{
    XMPPRoom *room = [self getRoomByName:roomName];
    [self defalutConfigForRoomJID:room.roomJID];
}

-(void)defalutConfigForRoomJID:(XMPPJID *)roomJID{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    NSXMLElement *persistentField = [NSXMLElement elementWithName:@"field"];
    NSXMLElement *persistentValue = [NSXMLElement elementWithName:@"value"];
    
    [persistentField addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];  // 永久属性
    
    [persistentField addAttributeWithName:@"type" stringValue:@"boolean"];
    
    [persistentValue setStringValue:@"1"];
    
    [x addChild:persistentField];
    
    [persistentField addChild:persistentValue];
    [[self getRoomByRoomJID:roomJID] configureRoomUsingOptions:x];
}


-(void)invite:(NSString *)name intoRoom:(NSString *)roomName{
    XMPPRoom *room = [self getRoomByName:roomName];
    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:@"server"];
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,server]];
    [room inviteUser:jid withMessage:[NSString stringWithFormat:@"wecome to %@",roomName]];
}


-(XMPPRoom *)getRoomByName:(NSString *)name{
    
    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:@"server"];
    NSString *roomID = [NSString stringWithFormat:@"%@@conference.%@",name,server];
    XMPPJID  *roomJID = [XMPPJID jidWithString:roomID];
   
    return [self getRoomByRoomJID:roomJID];
}

-(XMPPRoom *)getRoomByRoomJID:(XMPPJID *)roomJID{
    AppDelegate *appdele = [UIApplication sharedApplication].delegate;
    XMPPRoomMemoryStorage * roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:appdele.client.xmppStream];
    [xmppRoom addDelegate:appdele.client delegateQueue:dispatch_get_main_queue()];
    
    return xmppRoom;
}

@end
