//
//  BaseViewController.h
//  tt3
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tools.h"
#import "BaseMacro.h"
#import "MBProgressHUD.h"

@interface BaseViewController : UIViewController

@property (nonatomic ,strong) MBProgressHUD *hud;

-(void)showHud:(BOOL)hidden;
-(void)showHudOnKeyWindowTitle:(NSString *)title subTitle:(NSString *)subTitle ActivityAlarm:(BOOL)yesOrNo;
-(void)showHudOnKeyWindowTitle:(NSString *)title subTitle:(NSString *)subTitle ActivityAlarm:(BOOL)yesOrNo after:(CGFloat)seconds;


@end
