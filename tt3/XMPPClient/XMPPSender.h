//
//  XMPPSender.h
//  tt3
//
//  Created by apple on 15/8/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseMacro.h"
#import "ChatMessageModel.h"


@interface XMPPSender : NSObject

+ (ChatMessageModel *)sendMessage:(NSString *)message andData:(NSData *)data withBodyType:(enum MessageType)bodyType1 to:(NSString *)to;

+(void)sendIq;
@end
