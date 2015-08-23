//
//  PersionInfoModel.h
//  tt3
//
//  Created by apple on 15/8/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "Tools.h"

@interface PersionInfoModel : NSObject

@property(nonatomic,strong) NSString *fullName;
@property(nonatomic,strong) NSString *familyName;
@property(nonatomic,strong) NSString *givenName;
@property(nonatomic,strong) NSString *nickName;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) NSString *adrStreet;
@property(nonatomic,strong) NSString *adrExtadd;
@property(nonatomic,strong) NSString *adrLocality;
@property(nonatomic,strong) NSString *adrPcode;
@property(nonatomic,strong) NSString *adrCtry;
@property(nonatomic,strong) NSString *adrRegion;
@property(nonatomic,strong) NSString *tell;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *orgName;
@property(nonatomic,strong) NSString *orgUnit;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *role;
@property(nonatomic,strong) NSString *bday;
@property(nonatomic,strong) NSString *desc;
@property(nonatomic,strong) NSString *photoType;
@property(nonatomic,strong) NSData   *photo;

+(PersionInfoModel *)loadDatasFrom:(XMPPvCardTemp *)vcardTemp;
+(PersionInfoModel * )loadDatasFromLocal;

/**
 *  直接替换掉本地保存的UserVcard
 */
-(void)saveUserInfoDicArrToLocal;

-(NSArray *)createArray;

-(XMPPvCardTemp *)getPersionInfoXMPPvCardTemp;

@end
