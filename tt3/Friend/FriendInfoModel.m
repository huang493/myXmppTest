//
//  FriendInfoModel.m
//  tt3
//
//  Created by hsm on 15/7/26.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "FriendInfoModel.h"
#import "DataBaseManager.h"
#import "FMDB.h"

@implementation FriendInfoModel
{
    DataBaseManager *manager;
    FMDatabase      *db;
}

-(BOOL)insertIntoTable:(NSString *)tableName forDB:(id)db1{
    if (!self) {
        return NO;
    }
    
    if (!manager) {
        NSString *path = [Tools getCurrentUserDoucmentPath];
        manager = [DataBaseManager shareDataBaseManager];
        db = [manager getDBWithPath:path];
    }
    
    return [manager insertDatasDictionary:[self createAndCheck] intoTable:tableName forDB:db];
}

-(BOOL)deleteFromTable:(NSString *)tabelName forDB:(id)db1{
    if (!self) {
        return NO;
    }
    
    if (!manager) {
        NSString *path = [Tools getCurrentUserDoucmentPath];
        manager = [DataBaseManager shareDataBaseManager];
        db = [manager getDBWithPath:path];
    }
    
    return [manager deleteDataDic:[self createAndCheck] fromTableName:tabelName forDB:db];
}

-(BOOL)updateFromTable:(NSString *)tabelName forDB:(FMDatabase *)db1 newInfo:(FriendInfoModel *)newFriendInfo oldInfo:(FriendInfoModel *)oldFriendInfo{
    if(![Tools checkVaild:tabelName withType:NSSTRING]){
        return NO;
    }
    
    if (![Tools checkVaild:db1 withType:OTHER]) {
        return NO;
    }
    
    if (![Tools checkVaild:newFriendInfo withType:OTHER]) {
        return NO;
    }
    
    if (![Tools checkVaild:oldFriendInfo withType:OTHER]) {
        return NO;
    }
    
    if (!manager) {
        NSString *path = [Tools getCurrentUserDoucmentPath];
        manager = [DataBaseManager shareDataBaseManager];
        db = [manager getDBWithPath:path];
    }
    
    return [manager updateIntoTabel:tabelName forDB:db1 newDataDic:[newFriendInfo createAndCheck] replacedDataDic:[oldFriendInfo createAndCheck]];
    
}


+(FriendInfoModel *)setFriendInfoModelWith:(NSXMLElement *)item{
    
    FriendInfoModel *model = [[FriendInfoModel alloc] init];
    model.subscription = [item attributeStringValueForName:@"subscription"];
    model.ID = [item attributeStringValueForName:@"jid"];
    
    return model;
}

+(FriendInfoModel *)loadDataFrom:(XMPPvCardTemp*)vCardTemp{
    
    FriendInfoModel *model = [[FriendInfoModel alloc] init];
    PersionInfoModel *pModel = [PersionInfoModel loadDatasFrom:vCardTemp];
    
    
    model.nickName = pModel.nickName;
    model.bday = pModel.bday;
    model.photo = pModel.photo;
    model.tell = pModel.tell;
    model.adrStreet = pModel.adrStreet;
    
    return model;
}

+(FriendInfoModel *)loadFriendInfoFromLocal:(NSString *)jid{
    
    if (![Tools checkVaild:jid withType:NSSTRING]) {
        return  nil;
    }
    
    FriendInfoModel *model = [[FriendInfoModel alloc] init];
    NSString *path = [Tools getCurrentUserDoucmentPath];
    DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
    FMDatabase  *db = [manager getDBWithPath:path];
    FMResultSet *set = [manager queryDatasWhereConditionArray:@[@{@"jid":jid}] FromTable:@"friends" forDB:db withTpye:@"select"];
    if (set.next) {
        model.nickName = [set stringForColumn:@"nickName"];
        XMPPJID *jidd = [XMPPJID jidWithString:jid];
        model.photo = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png",path,[jidd user]]];
        model.group = [set stringForColumn:@"groupName"];
        model.gender = [set boolForColumn:@"gender"];
        model.subscription = [set stringForColumn:@"subscription"];
        model.bday = [set stringForColumn:@"bday"];
        model.tell =[set stringForColumn:@"adrStreet"];
        model.adrStreet =[set stringForColumn:@"tell"];
        return model;
    }
    else{
        return nil;
    }
}

+(NSMutableArray *)loadAllFrendsFromLocal{
    NSMutableArray *arr = [NSMutableArray array];
    NSString *path = [Tools getCurrentUserDoucmentPath];
    DataBaseManager *dbManager = [DataBaseManager shareDataBaseManager];
    FMDatabase *db = [dbManager getDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
    FMResultSet *set = [dbManager queryAllDatasFromTable:@"friends" forDB:db];
    
    while (set.next) {
        FriendInfoModel *model = [[FriendInfoModel alloc] init];
        model.ID = [set stringForColumn:@"jid"];
        model.nickName = [set stringForColumn:@"nickName"];
        XMPPJID *jid = [XMPPJID jidWithString:model.ID];
        model.photo = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png",path,jid.user]];
        if (model.photo.length==0) {
            model.photo = UIImageJPEGRepresentation([UIImage imageNamed:@"3"], 1);
        }
        model.group = [set stringForColumn:@"groupName"];
        model.gender = [set boolForColumn:@"gender"];
        model.subscription = [set stringForColumn:@"subscription"];
        model.bday = [set stringForColumn:@"bday"];
        model.tell =[set stringForColumn:@"adrStreet"];
        model.adrStreet =[set stringForColumn:@"tell"];
        
        [arr addObject:model];
    }
    [set close];
    return arr;
}

-(NSDictionary *)createAndCheck{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    if ([Tools checkVaild:_ID withType:NSSTRING]) {
        [dic setObject:_ID forKey:@"jid"];
    }
    
    if ([Tools checkVaild:_nickName withType:NSSTRING]) {
        [dic setObject:_nickName forKey:@"nickName"];
    }
    
    if ([Tools checkVaild:_group withType:NSSTRING]) {
        [dic setObject:_group forKey:@"groupName"];
    }
    
    if ([Tools checkVaild:_subscription withType:NSSTRING]) {
        [dic setObject:_subscription forKey:@"subscription"];
    }
    
    if ([Tools checkVaild:_photo withType:NSDATA]) {
        [dic setObject:_photo forKey:@"photo"];
    }
    
    if ([Tools checkVaild:_bday withType:NSSTRING]) {
        [dic setObject:_bday forKey:@"bday"];
    }
    
    if ([Tools checkVaild:_adrStreet withType:NSSTRING]) {
        [dic setObject:_adrStreet forKey:@"adrStreet"];
    }
    
    if ([Tools checkVaild:_tell withType:NSSTRING]) {
        [dic setObject:_tell forKey:@"tell"];
    }
    
    return dic;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"jid:%@ nickName:%@", _ID,_nickName];
}

@end
