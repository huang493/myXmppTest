//
//  DataBaseManager.m
//  tt3
//
//  Created by apple on 15/7/21.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "DataBaseManager.h"


static DataBaseManager *manager = nil;

@implementation DataBaseManager

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


+(DataBaseManager *)shareDataBaseManager{
    
    if (manager) {
        return manager;
    }
    else{
        manager = [[DataBaseManager alloc] init];
        return manager;
    }
}

/**
 *  创建数据和表
 *
 *  @param path      数据库路径
 *  @param dbName    数据库名称
 *  @param tabelName 表名
 *
 *  @return 是否成功
 */
-(BOOL)createDataBaseWithPath:(NSString *)path andBaseName:(NSString *)dbName andTable:(NSString *)tabelName {
    
    _db = [[FMDatabase alloc] initWithPath:[NSString stringWithFormat:@"%@/%@",path,dbName]];
    if (![_db open]) {
        NSLog(@"db open fail");
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement)",tabelName];
    BOOL result = [_db executeUpdate:sql];
    [_db close];
    return result;
    
}
/**
 *  创建数据库
 *
 *  @return 返回创建的数据库
 */
-(FMDatabase *)createDBWithPath:(NSString *)path{
    
    _db = [[FMDatabase alloc] initWithPath:[NSString stringWithFormat:@"%@/%@",path,@"Message.db"]];
    if ([_db open]) {
        DebugLog_DATABASE(@"db create success");
    }
    else{
        DebugLog_DATABASE(@"db create fail");
    }
    
    return _db;
}
/**
 *  获取数据库
 *
 *  @param path 数据库路径
 *
 *  @return 返回数据库
 */
-(FMDatabase *)getDBWithPath:(NSString *)path{
    FMDatabase *db = [[FMDatabase alloc] initWithPath:[NSString stringWithFormat:@"%@/%@",path,@"Message.db"]];
    if ([db open]) {
        DebugLog_DATABASE(@"db create success path:%@",[db databasePath]);
    }
    else{
        DebugLog_DATABASE(@"db create fail:%@",[db databasePath]);
    }

    return db;
}
/**
 *  关闭数据库
 *
 *  @param db 数据库名
 *
 *  @return 是否成功
 */
-(BOOL)closeDB:(FMDatabase *)db{
    
    if (!db) {
        return NO;
    }
    
    return [db close];
}



/**
 *  创建表
 *
 *  @param name 表名
 *  @param dic  柱字典
 *  @param db1  数据库
 *
 *  @return 是否成功
 */
-(BOOL)createTable:(NSString *)name withParams:(NSArray *)params toDataBase:(FMDatabase *)db1 {
    
    if (![db1 open]) {
        NSLog(@"db open fail");
        return NO;
    }
    
    if (params.count==0) {
        return NO;
    }
    
    if (name.length == 0) {
        return NO;
    }
    
    
    NSMutableString *paramStr = [[NSMutableString alloc] initWithString:@"("];
    
    for (NSString *str in params) {
        NSArray *arr = [str componentsSeparatedByString:@":"];
        [paramStr appendString:[NSString stringWithFormat:@"%@ %@,",arr[0],arr[1]]];
    }
    [paramStr deleteCharactersInRange:NSMakeRange(paramStr.length-1, 1)];
    [paramStr appendString:@")"];
    
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ %@",name,paramStr];
    DebugLog_DATABASE(@"create table sql:%@",sql);
    BOOL result = [db1 executeUpdate:sql];
//    [db1 close];
    return result;
}


-(BOOL)insertDatasDictionary:(NSDictionary *)dataDic intoTable:(NSString *)tabelName forDB:(FMDatabase *)db{
    
    if (dataDic.count == 0) {
        return NO;
    }
    if (tabelName == nil || tabelName.length == 0) {
        return NO;
    }
    if (db == nil) {
        return NO;
    }
    
    NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"insert into %@ () values ()",tabelName]];
    NSArray *keys = [dataDic allKeys];
    NSInteger index = sql.length - 11;

    for (NSInteger i=0; i<keys.count; i++) {
        NSString *key = keys[i];
        NSString *keyV = nil;
        if (i == 0) {
            keyV = key;
        }
        else{
            keyV = [NSString stringWithFormat:@",%@",key];
        }
        
        [sql insertString:keyV atIndex:index];
        
        index = index + keyV.length;
        
        if (i == 0) {
            [sql insertString:[NSString stringWithFormat:@"'%@'",dataDic[key]] atIndex:sql.length - 1];
        }
        else{
            [sql insertString:[NSString stringWithFormat:@",'%@'",dataDic[key]] atIndex:sql.length - 1];
        }
    }
    
    DebugLog_DATABASE(@"insert into sql:%@",sql);
    
    BOOL res = [db executeUpdate:sql];
//    [db close];
    
    return res;
}


-(BOOL)deleteDataDic:(NSDictionary *)dataDic fromTableName:(NSString *)tableName forDB:(FMDatabase *)db{
    if (dataDic.count == 0) {
        return NO;
    }
    if (tableName == nil || tableName.length == 0) {
        return NO;
    }
    if (db == nil) {
        return NO;
    }
    
    NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"delete from %@ where ",tableName]];

    [dataDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
        if ([sql containsString:@"="]) {
            [sql appendString:[NSString stringWithFormat:@",%@ = '%@'",key,obj]];
        }
        else{
            [sql appendString:[NSString stringWithFormat:@"%@ = '%@'",key,obj]];
        }
        
    }];
    
    DebugLog_DATABASE(@"detele sql:%@",sql);
    
    BOOL res = [db executeUpdate:sql];
//    [db close];
    return res;
}

/**
 *  更新数据库数据
 *
 *  @param tabelName 表名
 *  @param db        数据库名
 *  @param newDic    新的数据
 *  @param oldDic    旧的数据
 *
 *  @return 是否成功
 */
-(BOOL)updateIntoTabel:(NSString *)tabelName forDB:(FMDatabase *)db newDataDic:(NSDictionary *)newDic replacedDataDic:(NSDictionary *)oldDic{
    
    if(![Tools checkVaild:tabelName withType:NSSTRING]){
        return NO;
    }
    if (![Tools checkVaild:db withType:OTHER]) {
        return NO;
    }
    if (![Tools checkVaild:newDic withType:NSDICTIONARY]) {
        return NO;
    }
    if (![Tools checkVaild:oldDic withType:NSDICTIONARY]) {
        return NO;
    }
    
    NSMutableArray *condtions = [[NSMutableArray alloc] init];
    
    [oldDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
        [condtions addObject:[NSDictionary dictionaryWithObjectsAndKeys:obj,key,nil]];
    }];
    
    FMResultSet *res = [self queryDatasWhereConditionArray:condtions FromTable:tabelName forDB:db withTpye:@"select"];
    
    if (res.next) {
        
        NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"update %@",tabelName];

        NSMutableString *newDatasStr = [[NSMutableString alloc] init];
        NSMutableString *oldDatasStr = [[NSMutableString alloc] init];
        
        NSArray *newKeys = [newDic allKeys];
        NSArray *oldKeys = [oldDic allKeys];
        
        for (NSString *key in newKeys) {
            if (!newDatasStr.length) {
                [newDatasStr appendString:[NSString stringWithFormat:@" set %@ = '%@'",key,newDic[key]]];
            }
            else{
                [newDatasStr appendString:[NSString stringWithFormat:@" ,%@ = '%@'",key,newDic[key]]];
                
            }
        }
        
        
        for (NSString *key in oldKeys) {
            if (!oldDatasStr.length) {
                [oldDatasStr appendString:[NSString stringWithFormat:@" where %@ = '%@'",key,oldDic[key]]];
            }
            else{
                [oldDatasStr appendString:[NSString stringWithFormat:@" and %@ = '%@'",key,oldDic[key]]];
                
            }
        }
        
        
        [sql appendFormat:@"%@ %@",newDatasStr,oldDatasStr];
        DebugLog_DATABASE(@"sql update:%@",sql);
        return  [db executeUpdate:sql];

    }
    else{
        return  [self insertDatasDictionary:newDic intoTable:tabelName forDB:db];
    }
    
}


-(FMResultSet *)queryAllDatasFromTable:(NSString *)tablName forDB:(FMDatabase *)db{
    
    return [self queryDatasWhereConditionArray:nil FromTable:tablName forDB:db withTpye:@"select"];
    
}

/*
 select 字段名（*代表所有字段，如果有多个字段用英文的,分割） from 表名字 where 字段名=‘’ order by 字段名 desc|asc;
 select 字段名 from 表名 where  属性 like '%关键字%';
 select 字段名 from 表名 where 字段名 in ('关键字','关键字');

 1.
 @[
   @{"jid = text1@hsmdemacbook-pro.local"},
   @{@"jid >= 1111"}
   ]
 
 2.
 "like text1"
 
 3.
 "in text1,text2"
 
 */
-(FMResultSet *)queryDatasWhereConditionArray:(NSArray *)conditions FromTable:(NSString *)tableName forDB:(FMDatabase *)db withTpye:(NSString *)type {
    if (tableName == nil || tableName.length == 0) {
        return nil;
    }
    if (db == nil) {
        return nil;
    }
    if (type.length == 0 || type ==  nil) {
        return nil;
    }
    
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ ",tableName];

    //无条件查询
    //and
    //not
    //or
    //>
    //<
    //=
    //!=
    //>=
    //<=
    //<>
    //in
    //not in
    //like
    //not like
    //is null
    //is not null
    if (conditions.count > 0) {
        if ([type isEqualToString:@"in"]){
            
        }
        else if ([type isEqualToString:@"like"]){
            
        }
        else if ([type isEqualToString:@"select"]){
            
            
            [sql appendString:@"where "];
            for (NSDictionary *con in conditions) {
                [sql appendFormat:@"%@ = '%@'",[con allKeys][0],[con allValues][0]];
            }
        }

    }

    
    
    DebugLog_DATABASE(@"query sql:%@",sql);
    return [db executeQuery:sql];
}


@end
