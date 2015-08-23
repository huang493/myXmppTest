//
//  ChatMessageModel.m
//  tt3
//
//  Created by apple on 15/7/25.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ChatMessageModel.h"
#import "FMDB.h"
#import "DataBaseManager.h"
#import "AppDelegate.h"

@implementation ChatMessageModel
{
    DataBaseManager *manager;
    FMDatabase      *db;
}

-(void)setMessageWithXMPPMessage:(XMPPMessage *)xmppMessage{
    
    _message     = [[xmppMessage elementForName:@"body"] stringValue];
    _messageFrom = [[xmppMessage attributeForName:@"from"] stringValue];
    _messageTo   = [[xmppMessage attributeForName:@"to"] stringValue];
    _type        = [[xmppMessage attributeForName:@"type"] stringValue];
    _messsageid  = [[xmppMessage attributeForName:@"id"] stringValue];
    _bodyType    = [[xmppMessage attributeForName:@"bodyType"] stringValue];
    _isme        = NO;

    if ([_message isEqualToString:@"image"]) {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:_message options:0];
        UIImage *img = [UIImage imageWithData:data];
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        imgView.image = img;
        [win addSubview:imgView];
    }


    
    
    
    
    
    //添加时间
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _time        = [form dateFromString:[NSString stringWithFormat:@"%@",[NSDate date]]];
    _cellHeigt   = [self calculateHeighWithMessage:_message];
    
    

}

-(void)setMessageWithNSXMLElement:(NSXMLElement *) mes{
    
    _message     = [[mes elementForName:@"body"] stringValue];
    _messageFrom = [[mes attributeForName:@"from"] stringValue];
    _messageTo   = [[mes attributeForName:@"to"] stringValue];
    _type        = [[mes attributeForName:@"type"] stringValue];
    _messsageid  = [[mes attributeForName:@"id"] stringValue];
    
    //添加时间
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _time        = [form dateFromString:[[NSDate date] description]];
    _cellHeigt   = [self calculateHeighWithMessage:_message];
    _isme        = YES;
}


-(BOOL)insertIntoTable:(NSString *)tableName forDB:(FMDatabase *)db1{
    
    if (!self) {
        return NO;
    }
    
    if (!manager) {
        NSString *path = [Tools getCurrentUserDoucmentPath];
        manager = [DataBaseManager shareDataBaseManager];
        db = [manager getDBWithPath:path];
    }
    
    return [manager insertDatasDictionary:[self createAndCheck] intoTable:@"messages" forDB:db];

}



-(BOOL)deleteFromTable:(NSString *)tabelName forDB:(FMDatabase *)db1{
    
    
    if (!self) {
        return NO;
    }
    
    if (!manager) {
        NSString *path = [Tools getCurrentUserDoucmentPath];
        manager = [DataBaseManager shareDataBaseManager];
        db = [manager getDBWithPath:path];
    }
    
    return [manager deleteDataDic:[self createAndCheck] fromTableName:@"messages" forDB:db];
}



-(BOOL)updateFromTable:(NSString *)tabelName forDB:(FMDatabase *)db1 newMessage:(ChatMessageModel *)newMessageM oldMessage:(ChatMessageModel *)oldMessageM;
{
    
    if(![Tools checkVaild:tabelName withType:NSSTRING]){
        return NO;
    }
    
    if (![Tools checkVaild:db withType:OTHER]) {
        return NO;
    }
    
    if (![Tools checkVaild:newMessageM withType:OTHER]) {
        return NO;
    }
    
    if (![Tools checkVaild:oldMessageM withType:OTHER]) {
        return NO;
    }
    
    if (!manager) {
        NSString *path = [Tools getCurrentUserDoucmentPath];
        manager = [DataBaseManager shareDataBaseManager];
        db = [manager getDBWithPath:path];
    }
    
    return [manager updateIntoTabel:@"messages" forDB:db newDataDic:[newMessageM createAndCheck] replacedDataDic:[oldMessageM createAndCheck]];
}

/*数据库消息格式
 @[@"id:integer primary key autoincrement",
 @"messageTo:text",              //toJID
 @"messageFrom:text",            //fromJID
 @"isme:bool",                   //是否是我
 @"isread:bool",                 //是否已读
 @"isgroup:bool",                //是否群
 @"time:date",                   //时间
 @"message:text",                //文本信息
 @"photo:text",                  //图片地址
 @"photoIndex:integer",          //图片偏移
 @"sound:text"                   //音频地址
 ];
 */

-(NSDictionary *)createAndCheck{
    NSMutableDictionary *dic =[[NSMutableDictionary alloc] init];
    
    if ([Tools checkVaild:_message withType:NSSTRING]) {
        [dic setObject:_message forKey:@"message"];
    }
    if ([Tools checkVaild:_messageTo withType:NSSTRING]) {
        [dic setObject:_messageTo forKey:@"messageTo"];
    }
    
    if ([Tools checkVaild:_messageFrom withType:NSSTRING]) {
        [dic setObject:_messageFrom forKey:@"messageFrom"];
    }

    if ([Tools checkVaild:_time withType:NSDATE]) {
        [dic setObject:_time forKey:@"time"];
    }
    
    if ([Tools checkVaild:_photo withType:NSSTRING]) {
        [dic setObject:_photo forKey:@"photo"];
    }
    
    if ([Tools checkVaild:_sound withType:NSSTRING]) {
        [dic setObject:_sound forKey:@"sound"];
    }
    
    if (_photoIndex >= 0){
        [dic setObject:[NSNumber numberWithInteger:_photoIndex] forKey:@"photoIndex"];
    }
    
    [dic setObject:[NSNumber numberWithBool:_isgroup] forKey:@"isgroup"];
    [dic setObject:[NSNumber numberWithBool:_isread] forKey:@"isread"];
    
    return dic;
}

-(CGFloat)calculateHeighWithMessage:(NSString *)mes{
    
    CGFloat heigh = [Tools getHighOfString:mes andSize:CGSizeMake(255.0/320.0*SCREENWIDTH, 10000) andFont:[UIFont systemFontOfSize:17.0]];
    return heigh;
}

@end
