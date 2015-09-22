//
//  FriendInfoModel.h
//  tt3
//
//  Created by hsm on 15/7/26.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "PersionInfoModel.h"
#import "FMDB.h"
#import "Tools.h"
#import "BaseMacro.h"

@interface FriendInfoModel : NSObject
/* friends table structure
 @[
 @"id:integer primary key autoincrement",
 @"jid:text",            //JID
 @"nickName:text",       //昵称
 @"gender:bool",         //性别
 @"subscription:bool",   //订阅状态
 @"headImg:text"         //头像
 ];
 */

@property (nonatomic,strong) NSString *ID;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *group;      //所在的列表
@property (nonatomic,strong) NSString *subscription;
@property (nonatomic,assign) BOOL     gender;

@property (nonatomic,strong) NSData   *photo;
@property (nonatomic,strong) NSString *bday;
@property (nonatomic,strong) NSString *adrStreet;
@property (nonatomic,strong) NSString *tell;
//@property (nonatomic,strong) UIImage  *headImg;

+(FriendInfoModel *)loadDataFrom:(XMPPvCardTemp*)vCardTemp;
+(FriendInfoModel *)setFriendInfoModelWith:(NSXMLElement *)item;
+(FriendInfoModel *)loadFriendInfoFromLocal:(NSString *)jid;
+(NSMutableArray *)loadAllFrendsFromLocal;

-(BOOL)insertIntoTable:(NSString *)tableName forDB:(FMDatabase *)db;
-(BOOL)deleteFromTable:(NSString *)tabelName forDB:(FMDatabase *)db;
-(BOOL)updateFromTable:(NSString *)tabelName forDB:(FMDatabase *)db newInfo:(FriendInfoModel *)newFriendInfo oldInfo:(FriendInfoModel *)oldFriendInfo;

@end
