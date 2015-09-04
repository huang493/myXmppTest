//
//  XMPPClient.h
//  tt3
//
//  Created by apple on 15/8/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//
/**************************************************
 1.接收XMPPServer消息；
 2.转发接收到消息。
**************************************************/
#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "BaseMacro.h"

#import "XMPPFramework.h"
#import "XMPP.h"

#import "KKMessageDelegate.h"
#import "KKChatDelegate.h"
#import "KKVcarDelegate.h"
typedef enum {
    SubscriptionRequest = 0,
    
}NotificationType;
@interface XMPPClient : NSObject
{
    XMPPStream *xmppStream;
    NSString *password;
}

//stream
@property (strong, nonatomic) XMPPStream                *xmppStream;
//花名册
@property (strong, nonatomic) XMPPRoster                *roster;
@property (strong, nonatomic) XMPPRosterCoreDataStorage *rosterCoreDataStorage;
//vCard
@property (strong, nonatomic) XMPPvCardTempModule       *vCardTempModule;
@property (strong, nonatomic) XMPPvCardAvatarModule     *vCardAvtarModule;
@property (strong, nonatomic) XMPPvCardCoreDataStorage  *vcardCoreDataStorage;

@property (weak,    nonatomic) id<KKChatDelegate>       chatDelegate;
@property (weak,    nonatomic) id<KKMessageDelegate>    messageDelegate;
@property (weak,    nonatomic) id<KKVcarDelegate>       vcardDelegate;

//是否连接到服务器
@property (assign, nonatomic)  BOOL                     isConect;

-(BOOL)connect;
//匿名连接
-(BOOL)anonymousConnect;
-(void)disconnect;
-(void)setupStream;
-(void)setupRoster;
-(void)setupVCard;
-(void)goOnline;
-(void)goOffline;

@end
