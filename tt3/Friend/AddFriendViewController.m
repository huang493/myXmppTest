//
//  AddFriendViewController.m
//  tt3
//
//  Created by hsm on 15/7/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "AddFriendViewController.h"
#import "XMPPFramework.h"
#import "AppDelegate.h"


@implementation AddFriendViewController
{
    UITextField *textField;
    UIButton    *okBtn;
}
-(void)viewDidLoad{
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSubView];
}

-(void)addSubView{
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, SCREENWIDTH - 20, 40)];
    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textField.layer.cornerRadius = 5.0;
    textField.placeholder = @"please input accout(juest jid) for subscrib";
    [self.view addSubview:textField];
    
    okBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [okBtn setFrame:CGRectMake(10, CGRectGetMaxY(textField.frame) + 20, SCREENWIDTH - 20, 40)];
    [okBtn setTitle:@"Add new friend" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [okBtn setBackgroundColor:[UIColor greenColor]];
    [okBtn addTarget:self action:@selector(okBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    
}


-(void)okBtnAction:(UIButton *)sender
{
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",textField.text,DOMAINNAME];
    XMPPJID *friendJID = [XMPPJID   jidWithString:jidStr];
    [[self xmppRoster] subscribePresenceToUser:friendJID];
    

}

-(AppDelegate *)getDelegate
{
    return  (AppDelegate *)[UIApplication sharedApplication].delegate;
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return del.client.xmppStream;
}
//获取当前XMPPRoster
-(XMPPRoster *)xmppRoster{
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return del.client.roster;
}

@end
