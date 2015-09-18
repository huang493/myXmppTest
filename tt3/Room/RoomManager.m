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

typedef enum {
    
    Maxusers5 = 1,
    Maxusers10,
    Maxusers20,
    Maxusers30,
    Maxusers50,
    Maxusers100,
    Maxusers200
    
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


-(void)configRoomWithroomconfig_roomname:(NSString *)roomconfig_roomname
                        isPersistentroom:(BOOL)isPersistentroom
                     roomconfig_roomdesc:(NSString *)roomconfig_roomdesc
             isRoomconfig_persistentroom:(BOOL)isRoomconfig_persistentroom
                 isRoomconfig_publicroom:(BOOL)isRoomconfig_publicroom
      isRoomconfig_passwordprotectedroom:(BOOL)isRoomconfig_passwordprotectedroom
                   roomconfig_roomsecret:(NSString *)roomconfig_roomsecret
                     roomconfig_maxusers:(RoomconfigMaxusers )roomconfig_maxusers
                        roomconfig_whois:(RoomconfigWhois)roomconfig_whois
                isRoomconfig_membersonly:(BOOL)isRoomconfig_membersonly
              isRoomconfig_moderatedroom:(BOOL)isRoomconfig_moderatedroom
                      members_by_default:(BOOL) isMembers_by_default
              isRoomconfig_changesubject:(BOOL) isRoomconfig_changesubject
                isAllow_private_messages:(BOOL)isAllow_private_messages
    allow_private_messages_from_visitors:(AllowPrivateMessagesFromVisitors)allow_private_messages_from_visitors
                     isAllow_query_users:(BOOL)isAllow_query_users
               isRoomconfig_allowinvites:(BOOL)isRoomconfig_allowinvites
         isRoomconfig_allowvisitorstatus:(BOOL)isRoomconfig_allowvisitorstatus
     isRoomconfig_allowvisitornickchange:(BOOL)isRoomconfig_allowvisitornickchange
         isRoomconfig_allowvoicerequests:(BOOL)isRoomconfig_allowvoicerequests
      roomconfig_voicerequestmininterval:(NSString *)roomconfig_voicerequestmininterval
             roomconfig_captcha_whitelis:(id)roomconfig_captcha_whitelis
                         isDefaultConfig:(BOOL)isDefaultConfig{
    
    if (!isDefaultConfig) {
        NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
        NSXMLElement *roomName = [self createElement:@"muc#roomconfig_roomname" Value:roomconfig_roomname valueType:KNSString];
        NSXMLElement *roomDesc = [self createElement:@"muc#roomconfig_roomdesc" Value:roomconfig_roomdesc valueType:KNSString];
        NSXMLElement *persistentroom = [self createElement:@"muc#roomconfig_persistentroom" Value:isRoomconfig_persistentroom valueType:KBOOL];
        NSXMLElement *
        
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

-(NSXMLElement *)createElement:(NSString *)name Value:(id) value valueType:(CreateElementType)type{
    NSXMLElement *varElement = [NSXMLElement elementWithName:@"var" stringValue:name];
    NSXMLElement *valueElement = nil;
    
    
    if ([value isKindOfClass:[NSString class]]) {
        
    }
    
    if (value) {
        <#statements#>
    }
    
    
    
    switch (type) {
        case KNSInteger:
        {
            valueElement = [NSXMLElement elementWithName:@"value" numberValue:value];
        }
            break;
        case KBOOL:
        {
            valueElement = [NSXMLElement elementWithName:@"value" numberValue:value];
        }
            break;
        case KNSString:
        {
            valueElement = [NSXMLElement elementWithName:@"value" stringValue:value];
        }
            break;
            
        default:
            break;
    }
    
    [varElement addChild:valueElement];
    return varElement;
}

@end
