//
//  DataBaseManager.h
//  tt3
//
//  Created by apple on 15/7/21.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "BaseMacro.h"
#import "Tools.h"

typedef void(^managerActionBlock)(FMDatabase *db);
typedef void(^compeletedBlock)(FMDatabase *db);

@interface DataBaseManager : NSObject

@property (nonatomic,strong) FMDatabase *db;

/**
 *  获取数据库单例
 *
 *  @return 返回数据库单例
 */
+(DataBaseManager *)shareDataBaseManager;


/**
 *  创建数据库
 *
 *  @return 返回创建的数据库
 */
-(FMDatabase *)createDBWithPath:(NSString *)path;

/**
 *  获取数据库
 *
 *  @param path 数据库路径
 *
 *  @return 返回数据库
 */
-(FMDatabase *)getDBWithPath:(NSString *)path;

/**
 *  关闭数据库
 *
 *  @param db 数据库名
 *
 *  @return 是否成功
 */
-(BOOL)closeDB:(FMDatabase *)db;


/**
 *  执行sql语句
 *
 *  @param sql
 *
 *  @return 是否成功
 */
-(BOOL)dataBase:(FMDatabase*) db executeSql:(NSString *)sql;

/**
 *  创建表
 *
 *  @param name 表名
 *  @param dic  柱字典
 *  @param db1  数据库
 *
 *  @return 是否成功
 */
-(BOOL)createTable:(NSString *)name withParams:(NSArray *)params toDataBase:(FMDatabase *)db1;


/**
 *  插入数据:@{att1:value1,att2:value2}
 *
 *  @param dataDic   要插入数据字典
 *  @param tabelName 表名
 *  @param db        数据库
 *
 *  @return 是否成功
 */
-(BOOL)insertDatasDictionary:(NSDictionary *)dataDic intoTable:(NSString *)tabelName forDB:(FMDatabase *)db;

/**
 *  @brief 删除数据 @{att1:value1,att2:value2}
 *
 *  @param dataDic   要删除的数据字典
 *  @param tableName 表名
 *  @param db        数据库
 *
 *  @return 是否成功
 */
-(BOOL)deleteDataDic:(NSDictionary *)dataDic fromTableName:(NSString *)tableName forDB:(FMDatabase *)db;

/**
 *  更新数据库数据 @{att1:value1,att2:value2}
 *
 *  @param tabelName 表名
 *  @param db        数据库名
 *  @param newDic    新的数据
 *  @param oldDic    旧的数据
 *
 *  @return 是否成功
 */
-(BOOL)updateIntoTabel:(NSString *)tabelName forDB:(FMDatabase *)db newDataDic:(NSDictionary *)newDic replacedDataDic:(NSDictionary *)oldDic;

/**
 *  查询所有的数据
 *
 *  @param tablName 表明
 *  @param db       数据库
 *
 *  @return 是否成功
 */
-(FMResultSet *)queryAllDatasFromTable:(NSString *)tablName forDB:(FMDatabase *)db;


/**
 *  条件查询数据库 {}
 *
 *  @param conditions 条件字典{@"and":@"name" = @"111",@">":@"> number"}
 *  @param tableName  表名
 *  @param db         数据库
 *  @param type       条件类型:in(x),like(x),select(√)
 *
 *  @return 是否成功
 */
-(FMResultSet *)queryDatasWhereConditionArray:(NSArray *)conditions FromTable:(NSString *)tableName forDB:(FMDatabase *)db withTpye:(NSString *)type;



@end
