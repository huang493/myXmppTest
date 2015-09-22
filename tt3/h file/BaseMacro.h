//
//  BaseMacro.h
//  tt3
//
//  Created by hsm on 15/7/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//


#define ISHSMSERVER                 1

#if ISHSMSERVER
#define DOMAINNAME                  @"hsmdemacbook-pro.local"
#else
#define DOMAINNAME                  @"appledemac-mini.local"
#endif

#define SCREENWIDTH                 [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGH                 [UIScreen mainScreen].bounds.size.height
#define IOS7                        ([[UIDevice currentDevice].systemVersion doubleValue] > 7.0 ? 1 : 0)


#define KmyPhoto                    @"myPhoto"


/*数据库debug*/
#define DATABASE_DEBUG                       1
#if DATABASE_DEBUG
#define DebugLog_DATABASE(frmt, ...)         {NSLog((frmt),##__VA_ARGS__);}
#else
#define DebugLog_DATABASE(frmt, ...)
#endif


typedef enum {
    
    NSSTRING =0,
    NSARRAY  = 1,
    NSDICTIONARY =2,
    NSDATA = 3,
    NSDATE = 4,
    OTHER = 5,
    
} NSCLASSENUM;

enum EmotionType{
    
    QQEmotion = 0,
    EggEmotion,
    CarEmotion,
    HjyEmotion,
    Other
} ;

enum MessageType{
    Text = 0,
    Image,
    Vido,
    Voice,
    File,
};

#pragma -mark NSUserdefault--
#define kRegisteUserId      @"regsiteUserId"
#define kRegistePassword    @"regsitePassword"

#pragma -mark Notification--
#define didReceiveVcardInfo @"didReceiveVcardInfo"
#define kRegisteSuccess     @"registeSuccess"
#define kRegisteFail        @"registeFail"




