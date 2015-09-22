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

@implementation ChatMessageModel
{
    DataBaseManager *manager;
    FMDatabase      *db;
}

-(void)setMessageWithXMPPMessage:(XMPPMessage *)xmppMessage{
    
    _message     = [[xmppMessage elementForName:@"body"] stringValue];
    _messageFrom = [[xmppMessage attributeForName:@"from"] stringValue];
    XMPPJID *jid = [XMPPJID  jidWithString:[[xmppMessage attributeForName:@"from"] stringValue]];
    _messageFrom = [jid bare];
    jid          = [XMPPJID jidWithString:[[xmppMessage attributeForName:@"to"] stringValue]];
    _messageTo   = [jid bare];
    _type        = [[xmppMessage attributeForName:@"type"] stringValue];
    _messsageid  = [[xmppMessage attributeForName:@"id"] stringValue];
    _bodyType    = [[xmppMessage attributeForName:@"bodyType"] stringValue];
    _isme        = NO;
    _isread      = NO;
    _time        = [NSDate date];
    
    [self caculateCellHeigh]; //兼容Adium,没有用可以直接删掉
//    //兼容Adium
//    if (!_bodyType) {
//        _bodyType = @"text";
//    }
//    
//    if ([_bodyType isEqualToString:@"image"]) {
//        NSData *data = [[NSData alloc] initWithBase64EncodedString:_message options:0];
//        UIImage *img = [UIImage imageWithData:data];
//        
//        CGFloat maxWidth =  SCREENWIDTH - 40 - 8 - 8;
//        if(img.size.width > maxWidth) {
//            //宽度>极限宽度
//            CGFloat q = maxWidth/img.size.width;
//            _cellHeigt = q*img.size.height;
//        }
//        else if(img.size.width <= maxWidth && img.size.width > 60){
//            //60<宽度<极限宽度
//            _cellHeigt = img.size.height;
//        }
//        else {
//            //宽度<60
//            _cellHeigt = 60.0;
//        }
// 
//    }
//    else{
//        _cellHeigt   = [self calculateHeighWithMessage:_message];
//
//    }

}

-(void)setMessageWithNSXMLElement:(NSXMLElement *) mes{
    
    _message     = [[mes elementForName:@"body"] stringValue];
    _messageFrom = [[mes attributeForName:@"from"] stringValue];
    _messageTo   = [[mes attributeForName:@"to"] stringValue];
    _type        = [[mes attributeForName:@"type"] stringValue];
    _messsageid  = [[mes attributeForName:@"id"] stringValue];
    _time        = [NSDate date];
    _cellHeigt   = [self calculateHeighWithMessage:_message];
    _isme        = YES;
    _bodyType    = [[mes attributeForName:@"bodyType"] stringValue];
    [self caculateCellHeigh];  //兼容Adium,没有用可以直接删掉
}
/*
 NSArray *params = @[@"id:integer primary key autoincrement",
 @"messageTo:text",              //toJID
 @"messageFrom:text",            //fromJID
 @"isme:bool",                   //是否是我
 @"isread:bool",                 //是否已读
 @"isgroup:bool",                //是否群
 @"time:datetime",               //时间 YYYY-MM-DD HH:MM:SS 支持的范围是'1000-01-01 00:00:00'到'9999-12-31 23:59:59'
 @"message:text",                //文本信息
 @"photo:text",                  //图片地址
 @"photoIndex:integer",          //图片偏移
 @"sound:text"                   //音频地址
 ];
 */
+(ChatMessageModel *)setMessageWithFMResultSet:(FMResultSet *)set{
    
    if (set.next) {
        ChatMessageModel *model = [[ChatMessageModel alloc] init];
        model.messageTo = [set stringForColumn:@"messageTo"];
        model.messageFrom = [set stringForColumn:@"messageFrom"];
        model.isme = [set boolForColumn:@"isme"];
        model.isread = [set boolForColumn:@"isread"];
        model.isgroup = [set boolForColumn:@"isgroup"];
        NSString *timeStrTmp = [set stringForColumn:@"time"];
        NSString *timeStr = [timeStrTmp substringToIndex:timeStrTmp.length - 6];
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        [form setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        model.time  = [form dateFromString:timeStr];
        model.message = [set stringForColumn:@"message"];
        model.photo = [set stringForColumn:@"photo"];
        model.photoIndex = [set intForColumn:@"photoIndex"];
        model.sound = [set stringForColumn:@"sound"];
        model.type = [set stringForColumn:@"type"];
        model.bodyType = [set stringForColumn:@"bodyType"];
        model.cellHeigt = [model calculateHeighWithMessage:model.message];
        [model caculateCellHeigh];  //兼容Adium,没有用可以直接删掉
        return model;
    }
    
    return nil;
}

-(void)caculateCellHeigh{
    //兼容Adium
#if 1
    if (!_bodyType) {
        _bodyType = @"text";
    }
    
    if ([_bodyType isEqualToString:@"image"]) {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:_message options:0];
        UIImage *img = [UIImage imageWithData:data];
        
        CGFloat maxWidth =  SCREENWIDTH - 40 - 8 - 8;
        if(img.size.width > maxWidth) {
            //宽度>极限宽度
            CGFloat q = maxWidth/img.size.width;
            _cellHeigt = q*img.size.height;
        }
        else if(img.size.width <= maxWidth && img.size.width > 60){
            //60<宽度<极限宽度
            _cellHeigt = img.size.height;
        }
        else {
            //宽度<60
            _cellHeigt = 60.0;
        }
        
    }
    else{
        _cellHeigt   = [self calculateHeighWithMessage:_message];
        
    }
#endif

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
    
    if ([Tools checkVaild:_bodyType withType:NSSTRING]){
        [dic setObject:_bodyType forKey:@"bodyType"];
    }
    
    if ([Tools checkVaild:_type withType:NSSTRING]) {
        [dic setObject:_type forKey:@"type"];
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
    [dic setObject:[NSNumber numberWithBool:_isme] forKey:@"isme"];
    return dic;
}

-(CGFloat)calculateHeighWithMessage:(NSString *)mes{
    
    CGFloat heigh = [Tools getHighOfString:mes andSize:CGSizeMake(255.0/320.0*SCREENWIDTH, 10000) andFont:[UIFont systemFontOfSize:17.0]];
    return heigh;
}

@end
