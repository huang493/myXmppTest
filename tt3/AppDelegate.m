//
//  AppDelegate.m
//  tt3
//
//  Created by hsm on 15/7/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Tools.h"
#import "DataBaseManager.h"
#import "ChatMessageModel.h"
#import "FriendInfoModel.h"
#import "PersionInfoModel.h"

@interface AppDelegate ()

@end


@implementation AppDelegate
@synthesize xmppStream;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    return YES;
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
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

-(void)setupRoster{
    _rosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterCoreDataStorage];
    [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _roster.autoFetchRoster = YES;
    _roster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    [_roster activate:xmppStream];
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
-(void)goOnline{
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

-(void)goOffline{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}


-(BOOL)connect{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupStream];
        [self setupRoster];//roster init 只能执行一次，不然就蹦，原因：未明。
//        [self setupVCard];
    });
    
    NSLog(@"------------>>>Begin connect...");
    
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

-(void)disconnect{
    
    [self goOffline];
    [xmppStream disconnect];
    
}

#pragma -mark  XMPPStreamDelegate-------------------------------
//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"------------>>>Connect OK");
    isOpen = YES;
    NSError *error = nil;
    //验证密码
    [[self xmppStream] authenticateWithPassword:password error:&error];
    
}


//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    NSLog(@"------------>>>Authenticate pass");
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc postNotificationName:@"AuthenticateResult" object:nil];
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    
    NSLog(@"------------>>>Authenticate fail");
    NSLog(@"fial-jid:%@",sender.myJID);
    
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc postNotificationName:@"AuthenticateResult" object:error];
    
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    
//    NSLog(@"------------>>>iq in:%@",iq);
    
    return YES;
}

//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{

    NSString *msg = [[message elementForName:@"body"] stringValue];
    //消息过滤---防止空的消息
    if (![Tools checkVaild:msg withType:NSSTRING]) {
        return;
    }
    NSLog(@"receive message:%@",message);
    ChatMessageModel *model = [[ChatMessageModel alloc] init];
    [model setMessageWithXMPPMessage:message];
    
    DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
    FMDatabase *db = [manager getDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
    [model insertIntoTable:@"messages" forDB:db];
    
    [manager closeDB:db];

    //消息委托(这个后面讲)
    [_messageDelegate newMessageReceived:model];
    
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{

    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    //当前用户
    NSString *userId = [[sender myJID] user];
    //在线用户
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:userId]) {
        
        //在线状态
        if ([presenceType isEqualToString:@"available"]) {
            
            //用户列表委托(后面讲)
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, DOMAINNAME]];
            NSLog(@"------------>>>Friend online presence");
        }else if ([presenceType isEqualToString:@"unavailable"]) {
            //用户列表委托(后面讲)
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, DOMAINNAME]];
            NSLog(@"------------>>>Friend offine presence");
        }
    }
    else{
        NSLog(@"------------>>>I'm (%@) online presence",userId);
    }
    

}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq{
    NSLog(@"------------>>>iq out:%@",iq);
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    
}

- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence{
    
}


#pragma -mark XMPPRosterDelegate-------------------------------
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{

    //接受添加好友请求：acceptPresenceSubscriptionRequestFrom:
    //拒接添加好友请求：rejectPresenceSubscriptionRequestFrom:
    
    NSLog(@"------------>>>ask subscribe come from:%@",[presence from]);
    NSDictionary *objDic = [NSDictionary dictionaryWithObjectsAndKeys:sender,@"XMPPRoster",presence,@"XMPPPresence", nil];
    NSNotificationCenter *noc  = [NSNotificationCenter defaultCenter];
    [noc postNotificationName:@"ReceiveSubscriptionRequest" object:objDic];
        
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item{
    
    NSLog(@"------------>>>receive rosterItem:%@",item);
//    DDXMLNode *jidNode = [item attributeForName:@"jid"];
//    DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
//    FMDatabase *db = [manager createDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
//    
//    FriendInfoModel *model = [[FriendInfoModel alloc] init];
//    [model setFriendInfoModelWith:item];
    
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    
    
    
}


#pragma -mark XMPPvCardTempModuleDelegate
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    
    if ([jid isEqualToJID:xmppStream.myJID options:XMPPJIDCompareUser|XMPPJIDCompareDomain]) {
        //更新本地UserInfo
        PersionInfoModel *model = [PersionInfoModel loadDatasFrom:vCardTempModule.myvCardTemp];
        [model saveUserInfoDicArrToLocal];
    }
    

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












#pragma -mark applicationDelegate////////////////////////////////
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
