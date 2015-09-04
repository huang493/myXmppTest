//
//  BaseViewController.m
//  tt3
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController

-(void)showHud:(BOOL)hidden{
    [_hud hide:hidden];
}
-(void)showHudOnViewTitle:(NSString *)title subTitle:(NSString *)subTitle ActivityAlarm:(BOOL)yesOrNo after:(CGFloat)seconds{
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (yesOrNo) {
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    else{
        _hud.mode = MBProgressHUDModeText;
    }
    
    _hud.labelText = title;
    _hud.detailsLabelText = subTitle;
    
    if (seconds > 0) {
        BaseViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.hud hide:YES];
        });
    }
    
}

-(void)showHudOnKeyWindowTitle:(NSString *)title subTitle:(NSString *)subTitle ActivityAlarm:(BOOL)yesOrNo{
    [self showHudOnKeyWindowTitle:title subTitle:subTitle ActivityAlarm:yesOrNo after:0.0];
}

-(void)showHudOnKeyWindowTitle:(NSString *)title subTitle:(NSString *)subTitle ActivityAlarm:(BOOL)yesOrNo after:(CGFloat)seconds{
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    _hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
    
    if (yesOrNo) {
        _hud.mode = MBProgressHUDModeIndeterminate;
    }
    else{
        _hud.mode = MBProgressHUDModeText;
    }
    
    _hud.labelText = title;
    _hud.detailsLabelText = subTitle;

    if (seconds > 0) {
        BaseViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.hud hide:YES];
        });
    }
}

-(void)showHudOnKeyWindowCustomView:(UIView *)csView after:(CGFloat)seconds{
    
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    _hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
    _hud.mode = MBProgressHUDModeCustomView;
    _hud.customView.userInteractionEnabled = YES;
    _hud.customView = csView;
    
    if (seconds > 0) {
        BaseViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.hud hide:YES];
        });
    }
}
@end
