//
//  Tools.h
//  tt3
//
//  Created by apple on 15/7/23.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseMacro.h"

@interface Tools : NSObject


+(NSString *)getCurrentUserDoucmentPath;

+(NSString *)getCurrentUserId;


+(BOOL)checkVaild:(id) obj withType:(NSCLASSENUM)type;

+(CGFloat)getHighOfString:(NSString *)str andSize:(CGSize)size andFont:(UIFont*)font;

@end
