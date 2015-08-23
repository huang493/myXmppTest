//
//  PersionInfoModel.m
//  tt3
//
//  Created by apple on 15/8/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "PersionInfoModel.h"
/*
 黄诗猛：
 1.只解析了昵称，电话，邮件，头像，地址，生日;
 2.头像类型：image/gif, image/jpeg, or image/png;
 3.photo 子节点 BINVAL：为Base64-encoded;
 
 */
@implementation PersionInfoModel
#pragma -mark 归档及解归档协议
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        
        _fullName = [coder decodeObjectForKey:@"_fullName"];
        _givenName = [coder decodeObjectForKey:@"_givenName"];
        _familyName = [coder decodeObjectForKey:@"_familyName"];
        _nickName = [coder decodeObjectForKey:@"_nickName"];
        _url = [coder decodeObjectForKey:@"_url"];
        _adrStreet = [coder decodeObjectForKey:@"_adrStreet"];
        _adrExtadd = [coder decodeObjectForKey:@"_adrExtadd"];
        _adrLocality = [coder decodeObjectForKey:@"_adrLocality"];
        _adrPcode = [coder decodeObjectForKey:@"_adrPcode"];
        _adrCtry = [coder decodeObjectForKey:@"_adrCtry"];
        _adrRegion = [coder decodeObjectForKey:@"_adrRegion"];
        _tell = [coder decodeObjectForKey:@"_tell"];
        _email = [coder decodeObjectForKey:@"_email"];
        _orgName = [coder decodeObjectForKey:@"_orgName"];
        _orgUnit = [coder decodeObjectForKey:@"_orgUnit"];
        _title = [coder decodeObjectForKey:@"_title"];
        _bday = [coder decodeObjectForKey:@"_bday"];
        _desc = [coder decodeObjectForKey:@"_desc"];
        _photoType = [coder decodeObjectForKey:@"_photoType"];
        _photo = [coder decodeObjectForKey:@"_photo"];
  
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_fullName forKey:@"_fullName"];
    [coder encodeObject:_familyName forKey:@"_familyName"];
    [coder encodeObject:_givenName forKey:@"_givenName"];
    [coder encodeObject:_nickName forKey:@"_nickName"];
    [coder encodeObject:_url forKey:@"_url"];
    [coder encodeObject:_adrStreet forKey:@"_adrStreet"];
    [coder encodeObject:_adrExtadd forKey:@"_adrExtadd"];
    [coder encodeObject:_adrLocality forKey:@"_adrLocality"];
    [coder encodeObject:_adrPcode forKey:@"_adrPcode"];
    [coder encodeObject:_adrRegion forKey:@"_adrRegion"];
    [coder encodeObject:_adrCtry forKey:@"_adrCtry"];
    [coder encodeObject:_tell forKey:@"_tell"];
    [coder encodeObject:_email forKey:@"_email"];
    [coder encodeObject:_orgName forKey:@"_orgName"];
    [coder encodeObject:_orgUnit forKey:@"_orgUnit"];
    [coder encodeObject:_title forKey:@"_title"];
    [coder encodeObject:_bday forKey:@"_bday"];
    [coder encodeObject:_desc forKey:@"_desc"];
    [coder encodeObject:_photoType forKey:@"_photoType"];
    [coder encodeObject:_photo forKey:@"_photo"];

}




+(PersionInfoModel *)loadDatasFrom:(XMPPvCardTemp *)vcardTemp{
    
    NSArray *arrTmp = nil;
    PersionInfoModel *model = [[PersionInfoModel alloc] init];
    //nickName
    arrTmp = [vcardTemp elementsForName:@"NICKNAME"];
    if (arrTmp.count) {
        NSXMLElement *nickElement = arrTmp[0];
        model.nickName = [nickElement stringValue];
    }

    //tell
    arrTmp = [vcardTemp elementsForName:@"TEL"];
    if (arrTmp.count) {
        NSXMLElement *tellElement = arrTmp[0];
        model.tell = [[tellElement elementsForName:@"NUMBER"][0] stringValue];
    }
    
    //mail
    arrTmp = [vcardTemp elementsForName:@"EMAIL"];
    if (arrTmp.count) {
        NSXMLElement *emailElement = arrTmp[0];
        model.email = [[emailElement elementsForName:@"USERID"][0] stringValue];
    }

    
    //photo
    arrTmp = [vcardTemp elementsForName:@"PHOTO"];
    if (arrTmp.count) {
        NSXMLElement *photoElement = arrTmp[0];
        model.photoType = [[photoElement elementsForName:@"TYPE"][0] stringValue];
        NSString *photoDataStr = [[photoElement elementsForName:@"BINVAL"][0] stringValue];
        model.photo = [[NSData alloc] initWithBase64Encoding:photoDataStr];
    }

    
    //adr
    arrTmp = [vcardTemp elementsForName:@"ADR"];
    if (arrTmp.count) {
        NSXMLElement *adrElment = arrTmp[0];
        NSArray *arrTmp1 = nil;
        arrTmp1 = [adrElment elementsForName:@"STREET"];
        if (arrTmp1.count) {
            model.adrStreet = [arrTmp1[0] stringValue];
        }
        
        arrTmp1 = [adrElment elementsForName:@"EXTADD"];
        if (arrTmp1.count) {
            model.adrExtadd = [arrTmp1[0] stringValue];
        }
        
        arrTmp1 = [adrElment elementsForName:@"LOCALITY"];
        if (arrTmp1.count) {
            model.adrLocality = [arrTmp1[0] stringValue];
        }
        
        arrTmp1 = [adrElment elementsForName:@"PCODE"];
        if (arrTmp1.count) {
            model.adrPcode = [arrTmp1[0] stringValue];
        }
        
        arrTmp1 = [adrElment elementsForName:@"CTRY"];
        if (arrTmp1.count) {
            model.adrCtry = [arrTmp1[0] stringValue];
        }
        
        arrTmp1 = [adrElment elementsForName:@"REGION"];
        if (arrTmp1.count) {
            model.adrRegion = [arrTmp1[0] stringValue];
        }

    }

    //bday
    arrTmp = [vcardTemp elementsForName:@"BDAY"];
    if (arrTmp.count) {
        NSXMLElement *badyElment = arrTmp[0];
        model.bday = [badyElment stringValue];
    }
    
    return model;
}

+(PersionInfoModel * )loadDatasFromLocal{
    
    NSString *prePath = [Tools getCurrentUserDoucmentPath];
    PersionInfoModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/Userinfo",prePath]];
    
    return model;
}

-(void)saveUserInfoDicArrToLocal{
    
    NSString *prePath = [Tools getCurrentUserDoucmentPath];
    NSString *path = [NSString stringWithFormat:@"%@/Userinfo",prePath];
    
    BOOL isSuccess = [NSKeyedArchiver archiveRootObject:self toFile:path];
    if (isSuccess) {
        NSLog(@"saveUserInfoDicArrToLocal Success");
    }
    else{
        NSLog(@"saveUserInfoDicArrToLocal fail");
        
    }
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@%@", _photo,_nickName];
}

-(NSArray *)createArray{
    
    NSMutableArray *arr = [NSMutableArray array];
    
    if ([Tools checkVaild:_photo withType:NSDATA]) {
        [arr addObject:@{@"_photo":_photo}];
    }
    
    if ([Tools checkVaild:_nickName withType:NSSTRING]) {
        [arr addObject:@{@"_nickName":_nickName}];
    }
    if ([Tools checkVaild:_tell withType:NSSTRING]) {
        [arr addObject:@{@"_tell":_tell}];
    }
    
    if ([Tools checkVaild:_email withType:NSSTRING]) {
        [arr addObject:@{@"_email":_email}];
    }
    
    if ([Tools checkVaild:_bday withType:NSSTRING]) {
        [arr addObject:@{@"_bday":_bday}];
    }
    if ([Tools checkVaild:_desc withType:NSSTRING]) {
        [arr addObject:@{@"_desc":_desc}];
    }
    
    if ([Tools checkVaild:_familyName withType:NSSTRING]) {
        [arr addObject:@{@"_familyName":_familyName}];
    }
    if ([Tools checkVaild:_givenName withType:NSSTRING]) {
        [arr addObject:@{@"_givenName":_givenName}];
    }
    if ([Tools checkVaild:_url withType:NSSTRING]) {
        [arr addObject:@{@"_url":_url}];
    }
    if ([Tools checkVaild:_adrStreet withType:NSSTRING]) {
        [arr addObject:@{@"_adrStreet":_adrStreet}];
    }
    
    if ([Tools checkVaild:_adrExtadd withType:NSSTRING]) {
        [arr addObject:@{@"_adrExtadd":_adrExtadd}];
    }
    
    if ([Tools checkVaild:_adrLocality withType:NSSTRING]) {
        [arr addObject:@{@"_adrLocality":_adrLocality}];
    }
    
    if ([Tools checkVaild:_adrPcode withType:NSSTRING]) {
        [arr addObject:@{@"_adrPcode":_adrPcode}];
    }
    
    if ([Tools checkVaild:_adrCtry withType:NSSTRING]) {
        [arr addObject:@{@"_adrCtry":_adrCtry}];
    }
    
    if ([Tools checkVaild:_adrRegion withType:NSSTRING]) {
        [arr addObject:@{@"_adrRegion":_adrRegion}];
    }
    

    
    if ([Tools checkVaild:_orgName withType:NSSTRING]) {
        [arr addObject:@{@"_orgName":_orgName}];
    }
    
    if ([Tools checkVaild:_orgUnit withType:NSSTRING]) {
        [arr addObject:@{@"_orgUnit":_orgUnit}];
    }
    
    if ([Tools checkVaild:_title withType:NSSTRING]) {
        [arr addObject:@{@"_title":_title}];
    }
    
    if ([Tools checkVaild:_role withType:NSSTRING]) {
        [arr addObject:@{@"_role":_role}];
    }
    

    
    return [NSArray arrayWithArray:arr];
}

-(XMPPvCardTemp *)getPersionInfoXMPPvCardTemp{
    
    XMPPvCardTemp *vCard = [[XMPPvCardTemp alloc] init];
    
    vCard.nickname = _nickName;
    vCard.photo = _photo;
    vCard.title = _title;
    vCard.desc = _desc;
    vCard.familyName = _familyName;
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.dateFormat = @"yyyy-MM-dd";
    vCard.bday = [form dateFromString:_bday];
    vCard.addresses = @[_adrCtry,_adrRegion,_adrLocality,_adrPcode,_adrLocality,_adrExtadd];
    
    return vCard;
}

@end
