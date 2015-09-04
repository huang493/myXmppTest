//
//  KKLoginController.m
//  tt3
//
//  Created by apple on 15/7/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "KKLoginController.h"
#import "AppDelegate.h"
#import "DataBaseManager.h"
#import "MBProgressHUD.h"
#import "XMPPFramework.h"
#import "ResgistViewController.h"
#import "XMPPClient.h"

@interface KKLoginController () <UITextFieldDelegate>
{
    UITextField *accountTextField;
    UITextField *passwordTextField;
    UITextField *serverTextField;
    MBProgressHUD *hub;
}
@end

@implementation KKLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNav];
    [self addSubViews];
    [self addNotifications];

}

-(void)initNav{
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginBtn.frame = CGRectMake(0, 0, 60, 30);
    [loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginActopn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *resgistBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    resgistBtn.frame = CGRectMake(0, 0, 60, 30);
    [resgistBtn setTitle:@"Resgist" forState:UIControlStateNormal];
    [resgistBtn addTarget:self action:@selector(resgistActopn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithCustomView:loginBtn],
                                                [[UIBarButtonItem alloc] initWithCustomView:resgistBtn]
                                                ];
    
}

-(void)addSubViews{
    UILabel *accountlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 100, 30)];
    accountlabel.text = @"Account:";
    [self.view addSubview:accountlabel];
    
    
    UILabel *passwordlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 100, 30)];
    passwordlabel.text = @"Password:";
    [self.view addSubview:passwordlabel];
    
    
    UILabel *serverlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 100, 30)];
    serverlabel.text = @"Server:";
    [self.view addSubview:serverlabel];
    
    
    accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(120, 100, 200, 30)];
    accountTextField.layer.borderWidth = 1.0;
    accountTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    accountTextField.layer.cornerRadius = 3.0;
    accountTextField.delegate = self;
    [self.view addSubview:accountTextField];
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(120, 150, 200, 30)];
    passwordTextField.layer.borderWidth = 1.0;
    passwordTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    passwordTextField.layer.cornerRadius = 3.0;
    [self.view addSubview:passwordTextField];
    
    serverTextField = [[UITextField alloc] initWithFrame:CGRectMake(120, 200, 200, 30)];
    serverTextField.layer.borderWidth = 1.0;
    serverTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    serverTextField.layer.cornerRadius = 3.0;
    [self.view addSubview:serverTextField];
}

-(void)addNotifications{
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc addObserver:self selector:@selector(receivesNotAuthenticateResult:) name:@"AuthenticateResult" object:nil];
}

-(void)receivesNotAuthenticateResult:(NSNotification *)no{
    
    [self.hud hide:YES];
    NSXMLElement *err = (NSXMLElement *)no.object;
    if (err) {
        [self showHudOnKeyWindowTitle:@"please try again!" subTitle:nil ActivityAlarm:NO after:1.5];
        //移除失败的用户信息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"userid"];
        [defaults removeObjectForKey:@"password"];
        [defaults removeObjectForKey:@"server"];
        [defaults synchronize];
    }
    else{
        [self showHudOnKeyWindowTitle:@"login success!" subTitle:nil ActivityAlarm:NO after:1.5];
        [self loginSuccessAction];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self.navigationController selector:@selector(popViewControllerAnimated:) userInfo:nil repeats:NO];
    }
}

-(void)loginSuccessAction{
    //创建保存账号资料文件夹
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [NSString stringWithFormat:@"%@/%@",path,accountTextField.text];
    BOOL result = [fileManger createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    NSLog(@"------------>>>create file path:\n%@",path);
    
    
    //创建数据库
    if (result) {
        DataBaseManager *dbManager = [DataBaseManager shareDataBaseManager];
        FMDatabase *db = [dbManager createDBWithPath:path];
        NSArray *params = @[@"id:integer primary key autoincrement",
                            @"messageTo:text",              //toJID
                            @"messageFrom:text",            //fromJID
                            @"isme:bool",                   //是否是我
                            @"isread:bool",                 //是否已读
                            @"isgroup:bool",                //是否群
                            @"time:datetime",               //时间 YYYY-MM-DD HH:MM:SS 支持的范围是'1000-01-01 00:00:00'到'9999-12-31 23:59:59'
                            @"message:text",                //文本信息
                            @"photo:text",                  //图片地址
                            @"photoIndex:integer",          //图片偏移
                            @"sound:text"                   //音频地址
                            ];
        
        if (![dbManager createTable:@"messages" withParams:params toDataBase:db]) {
            NSLog(@"table messages create fial");
        }
        
        params = @[
                   @"id:integer primary key autoincrement",
                   @"jid:text",             //JID
                   @"nickName:text",        //昵称
                   @"gender:bool",          //性别
                   @"subscription:text",    //订阅状态
                   @"headImg:text",         //头像
                   @"listName:text",        //所在组的组名
                   @"photo:text",           //头像
                   @"bday:text",            //生日
                   @"adrStreet:text",       //地址
                   @"tell:text",             //电话
                   @"groupName:text"
                   ];
        //                   @"group:text",           //群

        if (![dbManager createTable:@"friends" withParams:params toDataBase:db]) {
            NSLog(@"table friends create fial");
        }
        else{
            //创建好友DB成功，请求好友列表
            AppDelegate *appdele = [UIApplication sharedApplication].delegate;
            [appdele.client setupRoster];
            [appdele.client.roster fetchRoster];
        }
        
        [dbManager closeDB:db];
    }
    
    
    //保存为当前用户的信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accountTextField.text forKey:@"userid"];
    [defaults setObject:passwordTextField.text forKey:@"password"];
    [defaults setObject:serverTextField.text forKey:@"server"];
    [defaults synchronize];
    
    //请求vCard
    AppDelegate *appdele = [UIApplication sharedApplication].delegate;
    [appdele.client setupVCard];
    XMPPStream  *stream = appdele.client.xmppStream;
    XMPPvCardTempModule *vCardTempModule = appdele.client.vCardTempModule;
    [vCardTempModule fetchvCardTempForJID:stream.myJID ignoreStorage:YES];
    
    //回传新登入的用户数据
    if (_newAccount) {
        _newAccount(accountTextField.text,passwordTextField.text,serverTextField.text);
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    accountTextField.text  = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    passwordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    serverTextField.text   = [[NSUserDefaults standardUserDefaults] objectForKey:@"server"];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [accountTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [serverTextField resignFirstResponder];
}


-(void)loginActopn:(UIButton *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![accountTextField.text isEqualToString:[defaults objectForKey:@"userid"]]) {
        if (accountTextField.text && passwordTextField.text && serverTextField.text) {
            
            [self showHudOnViewTitle:@"loging..." subTitle:@"please waiting..." ActivityAlarm:YES after:0];

            [defaults setObject:accountTextField.text forKey:@"userid"];
            [defaults setObject:passwordTextField.text forKey:@"password"];
            [defaults setObject:serverTextField.text forKey:@"server"];
            
            AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [del.client disconnect];
            [del.client connect];
        }
    }
    
    [defaults synchronize];

}

-(void)resgistActopn:(UIButton *)seder{
    ResgistViewController* resgistVC = [[ResgistViewController alloc] init];
    [self.navigationController pushViewController:resgistVC animated:YES];
}


-(BOOL)validateWithUser:(NSString *)userText andPass:(NSString *)passText andServer:(NSString *)serverText{
    
    if (userText.length > 0 && passText.length > 0 && serverText.length > 0) {
        return YES;
    }
    
    return NO;
}

#pragma -mark ----------UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSArray *arr = [textField.text componentsSeparatedByString:@"@"];
    if (arr.count>1) {
        serverTextField.text = arr[1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
