//
//  XMPPSender.m
//  tt3
//
//  Created by apple on 15/8/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "XMPPSender.h"
#import "XMPPFramework.h"
#import "DataBaseManager.h"
#import "AppDelegate.h"
#import "XMPPFileTransfer.h"
#import "XMPP"


@implementation XMPPSender

+ (ChatMessageModel *)sendMessage:(NSString *)message andData:(NSData *)data withType:(enum MessageType)type to:(NSString *)to{
    //本地输入框中的信息
    if (message.length > 0 || data.length>0) {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        
        NSString *bodyType = nil;
        switch (type) {
            case Text:
            {
                [body setStringValue:message];
                bodyType = @"text";
            }
                break;
            case Image:
            {
                NSString *dataStr = [data base64EncodedStringWithOptions:0];
                [body setStringValue:dataStr];
                bodyType = @"image";
            }
                break;
                
            default:
                break;
        }
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //body类型
        [mes addAttributeWithName:@"bodyType" stringValue:bodyType];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:to];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"userid"]];
        //组合
        [mes addChild:body];
        
        //发送消息
        AppDelegate *appdele = [UIApplication sharedApplication].delegate;
        [appdele.client.xmppStream sendElement:mes];
        
        //保存发送的消息到数据库
        DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
        FMDatabase *db = [manager getDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
        
        ChatMessageModel *model = [[ChatMessageModel alloc] init];
        [model setMessageWithNSXMLElement:mes];
        [model insertIntoTable:@"messages" forDB:db];
        
        [manager closeDB:db];
        return model;

    }
    return nil;
}

+(void)sendIq{
    
    
    UIImage *img = [UIImage imageNamed:@"[@pic019]"];
    NSData *data = UIImageJPEGRepresentation(img, 1);
    if (data.length >= 65535) {
        return;
    }
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    
    [iq addAttributeWithName:@"from" stringValue:@"text1@hsmdemacbook-pro.local"];
    [iq addAttributeWithName:@"id" stringValue:@"123456"];
    [iq addAttributeWithName:@"to" stringValue:@"text3@hsmdemacbook-pro.local"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    
    NSXMLElement *open = [NSXMLElement elementWithName:@"open"];
    [open addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/ibb"];
    [open addAttributeWithName:@"block-size" doubleValue:data.length];
    [open addAttributeWithName:@"sid" stringValue:@"i781hf64"];
    [open addAttributeWithName:@"stanza" stringValue:@"iq"];
    
    [iq addChild:open];
    
    
    AppDelegate *appdele = [UIApplication sharedApplication].delegate;
    [appdele.client.xmppStream sendElement:iq];
    
}

+(void)sendFile{
    
}


@end
