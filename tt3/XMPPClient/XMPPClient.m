//
//  XMPPClient.m
//  tt3
//
//  Created by apple on 15/8/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//
/*********************************************************************
 1.xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
 didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
 forJID:(XMPPJID *)jid
 其中：
 vCardTempModule为我的vCardTempModule。
 vCardTemp为好友的vCardTemp。
 
 **********************************************************************/
#import "XMPPClient.h"
#import "MBProgressHUD.h"
#import "Tools.h"
#import "DataBaseManager.h"
#import "ChatMessageModel.h"
#import "FriendInfoModel.h"
#import "PersionInfoModel.h"
#import "XMPPRoomMemoryStorage.h"
#import "RoomManager.h"
#import "FriendListModel.h"

@implementation XMPPClient
@synthesize xmppStream;
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self connect];
    }
    return self;
}


-(void)postNotificationWith:(NotificationType)type andObject:(id) obj{
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    switch (type) {
        case SubscriptionRequest:
        {
            [noc postNotificationName:@"SubscriptionRequest" object:obj];
        }
            break;
            
        default:
            break;
    }
}

#pragma -mark XMPPSetUp-------------------------------
-(void)setupStream{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    });
}

-(void)setupRoster{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _rosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
        _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterCoreDataStorage];
        [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        _roster.autoFetchRoster = YES;
        _roster.autoAcceptKnownPresenceSubscriptionRequests = YES;
        [_roster activate:xmppStream];
    });

}

-(void)setupVCard{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _vcardCoreDataStorage = [[XMPPvCardCoreDataStorage alloc] init];
        _vCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vcardCoreDataStorage ];
        _vCardAvtarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCardTempModule];
        
        [_vCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_vCardAvtarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        [_vCardTempModule activate:xmppStream];
        [_vCardAvtarModule activate:xmppStream];
    });
    
}

-(void)setupReconnect{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        XMPPReconnect *reconnect = [[XMPPReconnect alloc] init];
        reconnect.autoReconnect = YES;
        [reconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [reconnect activate:xmppStream];
    });

    
}


-(void)goOnline{
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

-(void)goOffline{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}


-(BOOL)connect{
    
    [self setupStream];
    [self setupRoster];//roster init 只能执行一次，不然就蹦，原因：未明。
    //        [self setupVCard];
    [self setupReconnect];

    NSLog(@"Begin connect...");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userid"];
    NSString *pass   = [defaults stringForKey:@"password"];
    NSString *server = [defaults stringForKey:@"server"];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (userId == nil || pass == nil) {
        return NO;
    }
    
    //设置用户
    [xmppStream setMyJID:[XMPPJID jidWithString:userId]];
    //设置服务器
    [xmppStream setHostName:server];
    //密码
    password = pass;
    
    //连接服务器
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:1000 error:&error]) {
        NSLog(@"cant connect %@", server);
        return NO;
    }
    
    return YES;
    
}

-(BOOL)anonymousConnect{
    
    [self setupStream];
//    [self setupRoster];//roster init 只能执行一次，不然就蹦，原因：未明。
    //        [self setupVCard];
    NSLog(@" Begin anonymous connect...");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *server = [defaults stringForKey:@"server"];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }

    //设置用户
    [xmppStream setMyJID:[XMPPJID jidWithString:@"anonymous@hsmdemacbook-pro.local"]];
    //设置服务器
//    [xmppStream setHostName:@"hsmdemacbook-pro.local"];
    //连接服务器
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:1000 error:&error]) {
        NSLog(@"cant connect %@", server);
        return NO;
    }
    
    return YES;

}


-(void)disconnect{
    
    [self goOffline];
    [xmppStream disconnect];
    _isConect = NO;
    
}

#pragma -mark  XMPPStreamDelegate-------------------------------
//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@" Connect OK");
    _isConect = YES;
    NSError *error = nil;
    if (![sender.myJID.user isEqualToString:@"anonymous"]) {
        //验证密码
        [[self xmppStream] authenticateWithPassword:password error:&error];
    }
    else{
        
        NSString *regsiteUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kRegisteUserId];
        NSString *regsitePassword = [[NSUserDefaults standardUserDefaults] objectForKey:kRegistePassword];
        self.xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",regsiteUserID,@"hsmdemacbook-pro.local"]];
        [self.xmppStream registerWithPassword:regsitePassword error:nil];
    }
    
}



- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
//    NSLog(@"xmppStreamDidDisconnect");
}


//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    NSLog(@" Authenticate pass");
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc postNotificationName:@"AuthenticateResult" object:nil];
    
    [self goOnline];
//    [self dicof];
    [self setupRoom];

}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    
    NSLog(@" Authenticate fail");
    NSLog(@"fial-jid:%@",sender.myJID);
    
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc postNotificationName:@"AuthenticateResult" object:error];
    
}


- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"xmpp register success:%@",sender.myJID.user);
    [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteSuccess object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error;{
    NSLog(@"xmpp register fail:%@ with:%@",sender.myJID.user,error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteFail object:nil];

}



//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    //消息过滤---防止空的消息
    if (![Tools checkVaild:msg withType:NSSTRING]) {
        return;
    }
    
    ChatMessageModel *model = [[ChatMessageModel alloc] init];
    [model setMessageWithXMPPMessage:message];
    NSLog(@"receive message:%@",model.message);

    DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
    FMDatabase *db = [manager getDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
    [model insertIntoTable:@"messages" forDB:db];
    [manager closeDB:db];
    
    [_messageDelegate newMessageReceived:model];
    
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    NSString *userId = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    //Room presence
    NSString *conference = [[presence attributeForName:@"from"] stringValue];
    if ([conference containsString:@"@conference"]) {
        if ([_chatDelegate respondsToSelector:@selector(joinRoom:)]) {
            [_chatDelegate joinRoom:conference];
        }
        return;
    }
    //friend or me presence
    if (![presenceFromUser isEqualToString:userId]) {
        
        //在线状态
        if ([presenceType isEqualToString:@"available"]) {
            
            [_chatDelegate newBuddyOnline:[presence from].bare];
            NSLog(@" Friend online presence");
        }else if ([presenceType isEqualToString:@"unavailable"]) {
            [_chatDelegate buddyWentOffline:[presence from].bare];
            NSLog(@" Friend offine presence:%@",presenceFromUser);
        }
    }
    else{
        NSLog(@" I'm (%@) online presence",userId);
    }
    
    
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    NSLog(@" iq in:%@",iq);
    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq{
//    NSLog(@" iq out:%@",iq);
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    
    ChatMessageModel *model = [[ChatMessageModel alloc] init];
    [model setMessageWithXMPPMessage:message];
    NSLog(@"send message:%@",model.message);}

- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence{
    
}


#pragma -mark XMPPRosterDelegate-------------------------------
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    //接受添加好友请求：acceptPresenceSubscriptionRequestFrom:
    //拒接添加好友请求：rejectPresenceSubscriptionRequestFrom:
    
    NSLog(@" ask subscribe come from:%@",[presence from]);
    NSDictionary *objDic = [NSDictionary dictionaryWithObjectsAndKeys:sender,@"XMPPRoster",presence,@"XMPPPresence", nil];
    NSNotificationCenter *noc  = [NSNotificationCenter defaultCenter];
    [noc postNotificationName:@"ReceiveSubscriptionRequest" object:objDic];
    
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item{
    
//    NSLog(@" receive rosterItem:%@",item);
    DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
    FMDatabase *db = [manager createDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
    FriendInfoModel *model = [FriendInfoModel setFriendInfoModelWith:item];
    FMResultSet *set = [manager queryDatasWhereConditionArray:@[@{@"jid":model.ID}] FromTable:@"friends" forDB:db withTpye:@"select"];
    if (set.next) {
        FriendInfoModel *oldModel = [[FriendInfoModel alloc] init];
        oldModel.ID = model.ID;
        [model updateFromTable:@"friends" forDB:db newInfo:model oldInfo:oldModel];
    }
    else{
        [model insertIntoTable:@"friends" forDB:db];
        [self setupVCard];
        [_vCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:model.ID] ignoreStorage:YES];
    }

}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    NSLog(@" receive push:%@",iq);
}


#pragma -mark XMPPvCardTempModuleDelegate-------------------------------
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    NSLog(@" receive vCard:%@",vCardTemp);
    //保存我的个人资料
    if ([jid isEqualToJID:xmppStream.myJID options:XMPPJIDCompareUser|XMPPJIDCompareDomain]) {
        //更新本地UserInfo
        PersionInfoModel *model = [PersionInfoModel loadDatasFrom:vCardTempModule.myvCardTemp];
        [model saveUserInfoDicArrToLocal];
    }
    //保存好友的个人资料
    else{
        
        DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
        FMDatabase *db = [manager createDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
        FriendInfoModel *model = [FriendInfoModel loadDataFrom:vCardTemp];
        //保存头像
        if(model.photo.length>0){
            NSString *path = [Tools getCurrentUserDoucmentPath];
            path = [NSString stringWithFormat:@"%@/%@.png",path,[jid user]];
            [model.photo writeToFile:path atomically:YES];
            model.photo = nil;
        }
        //保存其他vCard个人信息
        FMResultSet *set = [manager queryDatasWhereConditionArray:@[@{@"jid":[jid bare]}] FromTable:@"friends" forDB:db withTpye:@"select"];
        if (set.next) {
            FriendInfoModel *oldModel = [[FriendInfoModel alloc] init];
            oldModel.ID = [jid bare];
            [model updateFromTable:@"friends" forDB:db newInfo:model oldInfo:oldModel];
        }
        else{
            [model insertIntoTable:@"friends" forDB:db];
        }

        NSLog(@"nick %@ tell:%@",model.nickName,model.tell);
    }
    //通知代理
    if (_vcardDelegate) {
        [_vcardDelegate xmppvCardTempModule:vCardTempModule didReceivevCardTemp:vCardTemp forJID:jid];
    }
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    //更新本地UserInfo
    PersionInfoModel *model = [PersionInfoModel loadDatasFrom:vCardTempModule.myvCardTemp];
    [model saveUserInfoDicArrToLocal];
    
    //通知代理
    if (_vcardDelegate) {
        [_vcardDelegate xmppvCardTempModuleDidUpdateMyvCard:vCardTempModule];
    }
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    if (_vcardDelegate) {
        [_vcardDelegate xmppvCardTempModule:vCardTempModule failedToUpdateMyvCard:error];
    }
}

#pragma -mark XMPPReconnectDelegate-------------------------------
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@" Disconnect:%@",sender);

}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@" should attempt reconnect:%@",sender);
    return YES;
}

-(void)dicof{
    NSString* server = DOMAINNAME;//@"chat.shakespeare.lit"; //or whatever the server address for muc is
    XMPPJID *servrJID = [XMPPJID jidWithString:server];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].bare];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
}

-(void)setupRoom{
    
    RoomManager *roomManager = [RoomManager shareRoomManager];
    [roomManager createRoom:@"room999" andJoinNickName:@"my3"];
}

#pragma -mark XMPPRoomDelegate-------------------------------
- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"\\\\create room success :%@",sender);
    
    RoomManager *manager = [RoomManager shareRoomManager];
//    [manager defalutConfigForRoomJID:sender.roomJID];
//    [manager configRoomWithRoomJID:sender.roomJID
//               roomconfig_roomname:@"roomNickName"
//               roomconfig_roomdesc:@"this is my test room"
//       isRoomconfig_persistentroom:YES
//           isRoomconfig_publicroom:YES
//isRoomconfig_passwordprotectedroom:YES
//             roomconfig_roomsecret:@"123456"
//               roomconfig_maxusers:Maxusers10
//                  roomconfig_whois:ModeratorsKnowWhois
//          isRoomconfig_membersonly:YES
//        isRoomconfig_moderatedroom:YES
//                members_by_default:YES
//        isRoomconfig_changesubject:YES
//          isAllow_private_messages:YES
//allow_private_messages_from_visitors:ModeratorsOnlyPrivateMessage
//               isAllow_query_users:YES
//         isRoomconfig_allowinvites:YES
//   isRoomconfig_allowvisitorstatus:YES
//isRoomconfig_allowvisitornickchange:YES
//   isRoomconfig_allowvoicerequests:YES
//roomconfig_voicerequestmininterval:2000
//       roomconfig_captcha_whitelis:nil
//                   isDefaultConfig:YES];

}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    NSLog(@"\\\\didFetchConfigurationForm:%@",sender);
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm{
    NSLog(@"------》》。。。。%s:%@",__FUNCTION__,sender);
    
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    NSLog(@"\\\\room:%@ config success:%@",sender.roomJID,iqResult);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult{
    NSLog(@"\\\\room:%@ config fail:%@",sender.roomJID,iqResult);
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{

    NSLog(@"\\\\join room %@  %@",sender.myRoomJID,sender.roomJID);
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
    NSLog(@"\\\\leave room %@ %@",sender.myRoomJID,sender.roomJID);
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender{
    NSLog(@"------》》。。。。%s:%@",__FUNCTION__,sender);
}
- (void)xmppRoom:(XMPPRoom *)sender didFailToDestroy:(XMPPIQ *)iqError{
    NSLog(@"------》》。。。。%s:%@",__FUNCTION__,sender);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"------》》。。。。%s:%@",__FUNCTION__,sender);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"------》》。。。。%s:%@",__FUNCTION__,sender);
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"------》》。。。。%s:%@",__FUNCTION__,sender);
}



@end
