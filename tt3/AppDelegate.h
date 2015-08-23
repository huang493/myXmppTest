//
//  AppDelegate.h
//  tt3
//
//  Created by hsm on 15/7/16.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseMacro.h"

#import "XMPPFramework.h"
#import "XMPP.h"

#import "KKMessageDelegate.h"
#import "KKChatDelegate.h"
#import "KKVcarDelegate.h"



typedef enum {
    SubscriptionRequest = 0,
    
}NotificationType;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    XMPPStream *xmppStream;
    NSString *password;
    BOOL isOpen;
}

@property (strong, nonatomic) UIWindow                  *window;
//stream
@property (strong, nonatomic) XMPPStream                *xmppStream;
//花名册
@property (strong, nonatomic) XMPPRoster                *roster;
@property (strong, nonatomic) XMPPRosterCoreDataStorage *rosterCoreDataStorage;
//vCard
@property (strong, nonatomic) XMPPvCardTempModule       *vCardTempModule;
@property (strong, nonatomic) XMPPvCardAvatarModule     *vCardAvtarModule;
@property (strong, nonatomic) XMPPvCardCoreDataStorage  *vcardCoreDataStorage;






@property (weak,    nonatomic) id<KKChatDelegate>    chatDelegate;
@property (weak,    nonatomic) id<KKMessageDelegate> messageDelegate;
@property (weak,    nonatomic) id<KKVcarDelegate>    vcardDelegate;



-(BOOL)connect;
-(void)disconnect;
-(void)setupStream;
-(void)setupRoster;
-(void)setupVCard;
-(void)goOnline;
-(void)goOffline;

@end

