//
//  ChatMessageModel.h
//  tt3
//
//  Created by apple on 15/7/25.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "XMPPFramework.h"
#import "Tools.h"
#import "BaseMacro.h"

@interface ChatMessageModel : NSObject

@property (nonatomic,strong) NSString       *messageTo;
@property (nonatomic,strong) NSString       *messageFrom;
@property (nonatomic,strong) NSString       *type;
@property (nonatomic,strong) NSString       *messsageid;
@property (nonatomic,strong) NSString       *message;
@property (nonatomic,strong) NSString       *photo;
@property (nonatomic,strong) NSString       *sound;
@property (nonatomic,strong) NSDate         *time;
@property (nonatomic,assign) NSInteger      photoIndex;
@property (nonatomic,assign) BOOL           isme;
@property (nonatomic,assign) BOOL           isread;
@property (nonatomic,assign) BOOL           isgroup;
@property (nonatomic,strong) NSString       *bodyType;
/*动态显示cell高度使用*/
@property (nonatomic,assign) CGFloat        cellHeigt;

/**
 *  接受到消息的模型设置
 *
 *  @param xmppMessage 接受到得XMPPMessags
 */
-(void)setMessageWithXMPPMessage:(XMPPMessage *) xmppMessage;

/**
 *  发生消息的模型设置
 *
 *  @param mes 发送的NSXMLELement
 */
-(void)setMessageWithNSXMLElement:(NSXMLElement *) mes;

/**
 *  取本地数据库的模型设置
 *
 *  @param set 数据库Item
 */
+(ChatMessageModel *)setMessageWithFMResultSet:(FMResultSet *)set;

-(BOOL)insertIntoTable:(NSString *)tableName forDB:(FMDatabase *)db;
-(BOOL)deleteFromTable:(NSString *)tabelName forDB:(FMDatabase *)db;
-(BOOL)updateFromTable:(NSString *)tabelName forDB:(FMDatabase *)db newMessage:(ChatMessageModel *)newMessageM oldMessage:(ChatMessageModel *)oldMessageM;


@end
