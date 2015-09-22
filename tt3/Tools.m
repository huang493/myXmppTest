//
//  Tools.m
//  tt3
//
//  Created by apple on 15/7/23.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "Tools.h"

@implementation Tools

/**
 *  check NSString,NSArray,NSDictionary的有效性
 *
 *  @param obj NSString,NSArray,NSDictionary 类型
 *
 *  @return 是否有效
 */
+(BOOL)checkVaild:(id) obj withType:(NSCLASSENUM)type {
    
    
    switch (type) {
        case NSSTRING:
        {
            NSString *str = (NSString *)obj;
            if (str.length==0 || str == nil) {
                return NO;
            }
            
        }
            break;

        case NSARRAY:
        {
            NSArray *arr = (NSArray *)obj;
            if (arr.count==0 || arr == nil) {
                return NO;
            }

        }
            break;

        case NSDICTIONARY:
        {
            NSDictionary *dic = (NSDictionary *) obj;
            if (dic.count==0 || dic == nil) {
                return NO;
            }
        }
            break;
            
        case NSDATA:
        {
            NSData *data = (NSData *) obj;
            if (data.length==0 || data == nil) {
                return NO;
            }
        }
            break;
            
        case NSDATE:
        {
            NSDate *date = (NSDate *) obj;
            if ( [date isEqualToDate:[date laterDate:[NSDate date]]] || date == nil) {
                return NO;
            }
        }
            break;
        case OTHER:
        {
            if (obj == nil) {
                return NO;
            }
        }
            break;

        default:
            return NO;
    }
    
    return YES;
}



+(NSString *)getCurrentUserDoucmentPath{
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [NSString stringWithFormat:@"%@/%@",path,[self getCurrentUserId]];
}

+(NSString *)getCurrentUserId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults objectForKey:@"userid"];
}



+(CGFloat)getHighOfString:(NSString *)str andSize:(CGSize)size andFont:(UIFont*)font
{
    CGRect f = CGRectZero;
    
    if (IOS7) {
        f = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    }
    else{
        f.size = [str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    }
    return f.size.height;
}


@end
