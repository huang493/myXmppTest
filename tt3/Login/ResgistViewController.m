//
//  ResgistViewController.m
//  tt3
//
//  Created by hsm on 15/8/22.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "ResgistViewController.h"
#import "AppDelegate.h"

@interface ResgistViewController ()

@end

@implementation ResgistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupView];
    
    
}

-(void)setupView{
    _accountTF.layer.cornerRadius = 5.0f;
    _accountTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _accountTF.layer.borderWidth = 0.5f;
    
    
    _passWordTF.layer.cornerRadius = 5.0f;
    _passWordTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _passWordTF.layer.borderWidth = 0.5f;;
    
    _passWordAgainTF.layer.cornerRadius = 5.0f;
    _passWordAgainTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _passWordAgainTF.layer.borderWidth = 0.5f;;
    
    _bdayTF.layer.cornerRadius = 5.0f;
    _bdayTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bdayTF.layer.borderWidth = 0.5f;;
    
    _tellTF.layer.cornerRadius = 5.0f;
    _tellTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tellTF.layer.borderWidth = 0.5f;
    
    
    _accountTF.text = @"text7";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)OKAction:(id)sender {
    
    if([self checkVaild]){
     
        [[NSUserDefaults standardUserDefaults] setObject:_accountTF.text forKey:kRegisteUserId];
        [[NSUserDefaults standardUserDefaults] setObject:_passWordTF.text forKey:kRegistePassword];
        
        AppDelegate *appdele = [UIApplication sharedApplication].delegate;
        [appdele.client goOffline];

        
        
        
        
        [appdele.client disconnect];
        [appdele.client anonymousConnect];
        
    }
}


-(BOOL)checkVaild{
    
    NSUInteger errIndex = 0;
    
    if (![Tools checkVaild:_accountTF.text withType:NSSTRING]) {
        errIndex = errIndex | 0x01;
    }
    
    if (![Tools checkVaild:_passWordTF.text withType:NSSTRING]) {
        errIndex = errIndex | 0x02;
    }
    
    if (![Tools checkVaild:_passWordAgainTF.text withType:NSSTRING]) {
        errIndex = errIndex | 0x04;
    }
    
    if (![Tools checkVaild:_bdayTF.text withType:NSSTRING]) {
        errIndex = errIndex | 0x08;
    }
    
    if (![Tools checkVaild:_tellTF.text withType:NSSTRING]) {
        errIndex = errIndex | 0x10;
    }
    
    if (![_passWordTF.text isEqualToString:_passWordAgainTF.text]) {
        errIndex = errIndex | 0x20;
    }
    
    if (errIndex == 0) {
        return YES;
    }
    else{
        NSString *errInfo = nil;
        NSString *errSubInfo = nil;
        if (errIndex & 0b11011111 ) {
            errSubInfo = @"两次密码不匹配";
        }
        if (errIndex | 0b00010000) {
            errInfo = @"输入数据不能为空";
        }

        [self showHudOnKeyWindowTitle:errInfo subTitle:errSubInfo ActivityAlarm:NO after:1.5];
        
        return NO;
     }
}

@end
