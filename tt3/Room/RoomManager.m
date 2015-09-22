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
    if (nickName.length>0) {
        [xmppRoom joinRoomUsingNickname:nickName history:nil];
    }
}

-(void)destroyRoom:(NSString *)name{

    XMPPRoom *room = [self  getRoomByName:name];
    [room destroyRoom];
}


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
                         isDefaultConfig:(BOOL)isDefaultConfig{
    
    if (!isDefaultConfig) {
        NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
        NSXMLElement *roomName = [self createElement:@"muc#roomconfig_roomname" Value:roomconfig_roomname];
        NSXMLElement *roomDesc = [self createElement:@"muc#roomconfig_roomdesc" Value:roomconfig_roomdesc];
        NSXMLElement *persistentroom = [self createElement:@"muc#roomconfig_persistentroom" Value:[NSNumber numberWithBool:isRoomconfig_persistentroom]];
        NSXMLElement *publicRoom = [self createElement:@"muc#roomconfig_publicroom" Value:[NSNumber numberWithBool:isRoomconfig_publicroom]];
        NSXMLElement *passwordprotectedroom = [self createElement:@"muc#roomconfig_passwordprotectedroom" Value:[NSNumber numberWithBool:isRoomconfig_passwordprotectedroom]];
        NSXMLElement *secret = nil;
        if (isRoomconfig_passwordprotectedroom) {
            secret = [self createElement:@"muc#roomconfig_roomsecret" Value:roomconfig_roomsecret];
        }
        
        NSXMLElement *maxUsers = [self createElement:@"muc#roomconfig_maxusers" Value:[NSNumber numberWithInteger:roomconfig_maxusers]];
        
        NSXMLElement *knowWhois = nil;
        switch (roomconfig_whois) {
            case ModeratorsKnowWhois:
            {
                knowWhois = [self createElement:@"muc#roomconfig_whois" Value:@"moderators"];
            }
                break;
            case AnyoneKnowWhois:
            {
                knowWhois = [self createElement:@"muc#roomconfig_whois" Value:@"anyone"];

            }
                break;
            default:
                break;
        }
        
        NSXMLElement *memberOnly = [self createElement:@"muc#roomconfig_membersonly" Value:[NSNumber numberWithBool:isRoomconfig_membersonly]];
        
        NSXMLElement *moderatedRoom = [self createElement:@"muc#roomconfig_moderatedroom" Value:[NSNumber numberWithBool:isRoomconfig_moderatedroom]];
        
        NSXMLElement *membersByDefault = [self createElement:@"members_by_default" Value:[NSNumber numberWithBool:isMembers_by_default]];
        
        NSXMLElement *changeSubject = [self createElement:@"muc#roomconfig_changesubject" Value:[NSNumber numberWithBool:isRoomconfig_changesubject]];
        
        NSXMLElement *allowPrivateMessages = [self createElement:@"allow_private_messages_from_visitors" Value:[NSNumber numberWithBool:isAllow_private_messages]];
        
        NSXMLElement *allowPrivateMessagesFromVisitors = nil;
        switch (allow_private_messages_from_visitors) {
            case NobodyPrivateMessage:
            {
                allowPrivateMessagesFromVisitors = [self createElement:@"allow_private_messages_from_visitors" Value:@"nobody"];
            }
                break;
            case ModeratorsOnlyPrivateMessage:
            {
                allowPrivateMessagesFromVisitors = [self createElement:@"allow_private_messages_from_visitors" Value:@"moderators"];

            }
                break;
            case AnyonePrivateMessage:
            {
                allowPrivateMessagesFromVisitors = [self createElement:@"allow_private_messages_from_visitors" Value:@"anyone"];

            }
                break;
                
            default:
                break;
        }
        
        
        NSXMLElement *allowQueryUsers = [self createElement:@"allow_query_users" Value:[NSNumber numberWithBool:isAllow_query_users]];
        NSXMLElement *allowinvites = [self createElement:@"muc#roomconfig_allowinvites" Value:[NSNumber numberWithBool:isRoomconfig_allowinvites]];
        NSXMLElement *allowvisitorstatus = [self createElement:@"muc#roomconfig_allowvisitorstatus" Value:[NSNumber numberWithBool:isRoomconfig_allowvisitorstatus]];
        
        NSXMLElement *allowVisitorNickChange = [self createElement:@"muc#roomconfig_allowvisitornickchange" Value:[NSNumber numberWithBool:isRoomconfig_allowvisitornickchange]];
        
        NSXMLElement *allowVoiceRequests = [self createElement:@"muc#roomconfig_allowvoicerequests" Value:[NSNumber numberWithBool:isRoomconfig_allowvoicerequests]];
        NSXMLElement *voiceRequestMinInterval = [self createElement:@"muc#roomconfig_voicerequestmininterval" Value:[NSString stringWithFormat:@"%ld",(long)roomconfig_voicerequestmininterval]];
     
#pragma -mark TODO: roomconfig_captcha_whitelis 暂时 不知道 怎么用
        
        
        [x addChild:roomName];
        [x addChild:roomDesc];
        [x addChild:persistentroom];
        [x addChild:publicRoom];
        [x addChild:passwordprotectedroom];
        if (isRoomconfig_passwordprotectedroom) {
            [x addChild:secret];
        }
        [x addChild:maxUsers];
        [x addChild:knowWhois];
        [x addChild:memberOnly];
        [x addChild:moderatedRoom];
        [x addChild:membersByDefault];
        [x addChild:changeSubject];
        [x addChild:allowPrivateMessages];
        [x addChild:allowPrivateMessagesFromVisitors];
        [x addChild:allowQueryUsers];
        [x addChild:allowinvites];
        [x addChild:allowvisitorstatus];
        [x addChild:allowVisitorNickChange];
        [x addChild:allowVoiceRequests];
        [x addChild:voiceRequestMinInterval];
     
        
        XMPPRoom *room = [self getRoomByRoomJID:roomJID];
        [room configureRoomUsingOptions:x];
        
        NSLog(@"xxxx:%@",x);
    }
    
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

-(NSXMLElement *)createElement:(NSString *)name Value:(id)value {
    NSXMLElement *varElement = [NSXMLElement elementWithName:@"var" stringValue:name];
    NSXMLElement *valueElement = nil;
    
    
    if ([value isKindOfClass:[NSNumber class]]) {
        valueElement = [NSXMLElement elementWithName:@"value" numberValue:value];

    }
    else if ([value isKindOfClass:[NSString class]]){
        valueElement = [NSXMLElement elementWithName:@"value" stringValue:value];

    }
    
    [varElement addChild:valueElement];
    return varElement;
}

@end
