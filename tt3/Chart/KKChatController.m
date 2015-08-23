//
//  KKChatController.m
//  tt3
//
//  Created by apple on 15/7/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "KKChatController.h"
#import "ChatCellTableViewCell.h"
#import "sendMessageView.h"
#import "KKChatDelegate.h"
#import "KKMessageDelegate.h"
#import "AppDelegate.h"
#import "XMPP.h"
#import "XMPPFramework.h"
#import "ChatMessageModel.h"
#import "DataBaseManager.h"
#import "PersionInfoViewController.h"
#import "KKVcarDelegate.h"


@interface KKChatController ()<UITableViewDelegate,UITableViewDataSource,KKMessageDelegate>
{
    NSMutableArray  *messages;
    AppDelegate     *appDel;
    XMPPRoster      *roster;
    sendMessageView *sendView;
    UIImage         *myHeaderPhoto;
    UIImage         *friendHeaderPhoto;
}
@end

@implementation KKChatController

-(void)viewWillAppear:(BOOL)animated{
    
//    [sendView.messageTF becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    messages = [[NSMutableArray alloc] init];
    appDel = [self getDelegate];
    appDel.messageDelegate = self;
    appDel.vcardDelegate = self;
    PersionInfoModel *model = [PersionInfoModel loadDatasFromLocal];
    if (!model.photo) {
        [appDel setupVCard];
        [appDel.vCardTempModule fetchvCardTempForJID:appDel.xmppStream.myJID ignoreStorage:YES];
        myHeaderPhoto = [UIImage imageNamed:@"3"];
    }
    myHeaderPhoto = [UIImage imageWithData:model.photo];
    
    
    
    
    [self addTableView];
    [self addSendView];
    [self initNavgationBarItem];
}
-(void)addTableView{
    _tView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                           0,
                                                           SCREENWIDTH,
                                                           SCREENHEIGH - CGRectGetMaxY(_sendBtn.frame) -64
                                                           )
                                          style:UITableViewStylePlain];
    _tView.delegate = self;
    _tView.dataSource = self;
    [_tView registerNib:[UINib nibWithNibName:@"ChatCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"chatCell"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    [_tView addGestureRecognizer:tap];
    
    [self.view addSubview:_tView];
}

-(void)initNavgationBarItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(chartHistory:)];
}

-(void)chartHistory:(UIButton *)btn{
    
    DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
    FMDatabase *db = [manager getDBWithPath:[Tools getCurrentUserDoucmentPath]];
    
    FMResultSet *res = [manager queryAllDatasFromTable:@"messages" forDB:db];
    NSLog(@"chart history strat ----------------------------------------------------------------------------");
    while (res.next) {
        
        NSLog(@"time:%@ text:%@ from:%@",[res stringForColumn:@"time"],[res stringForColumn:@"message"],[res stringForColumn:@"messageFrom"]);
    }
    NSLog(@"chart history end   ----------------------------------------------------------------------------");

    [manager closeDB:db];

}

-(void)addSendView
{
    __weak KKChatController *weafSef = self;
    sendView = [[sendMessageView alloc] initWithFrame:CGRectMake(0, SCREENHEIGH - 40, SCREENWIDTH, 40)];
    sendView.clickBlock = ^(NSString * message,NSData *data,enum MessageType type){
        NSLog(@"message:%@",message);
        [weafSef sendMessage:message andData:(NSData *)data withType:type];
    };
    sendView.chanegeHiBlock = ^(CGFloat heigh){
        [weafSef resetSendViewOriginY:heigh];
    };
    
    [self.view addSubview:sendView];
     
}
-(void)resetSendViewOriginY:(CGFloat) heigh{
    CGRect frame = sendView.frame;
    frame.origin.y -=heigh;
    sendView.frame = frame;
}

-(AppDelegate *)getDelegate
{
    return  (AppDelegate *)[UIApplication sharedApplication].delegate;
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return del.xmppStream;
}

-(XMPPRoster *)roster{
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return del.roster;
}


#pragma mark KKMessageDelegate
-(void)newMessageReceived:(ChatMessageModel*)message{
    
    [messages addObject:message];
    [_tView reloadData];
    
}
#pragma -mark UITableViewDelegate & UITableViewDataDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatMessageModel *model = messages[indexPath.row];
    return  model.cellHeigt + 60 - 21;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    ChatMessageModel *model     = [messages objectAtIndex:indexPath.row];
    [cell loadDatasFromChatMessageModel:model];
    if (model.isme) {
        cell.senderImgView.image = myHeaderPhoto;
    }
    else{
        
    }
    KKChatController *weakSelf = self;
    
    cell.imgClickBlock = ^(NSString *messageFrom){
        PersionInfoViewController *persionVC = [[PersionInfoViewController alloc] init];
        persionVC.messageFrom = messageFrom;
        XMPPJID *jid = [XMPPJID jidWithString:messageFrom];
        if ([jid.user isEqualToString:[self xmppStream].myJID.user]) {
            persionVC.isMe = YES;
        }
        persionVC.jid = jid;
        [weakSelf.navigationController pushViewController:persionVC animated:YES];
    };
    
    return cell;
}
#pragma -mark vCardTempDelegate ----
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    
    PersionInfoModel *model = [PersionInfoModel loadDatasFromLocal];
    if (model.photo) {
        myHeaderPhoto = [UIImage imageWithData:model.photo];
    }
    
}
#pragma -mark xmpp 发送消息-----
- (void)sendMessage:(NSString *)message andData:(NSData *)data withType:(enum MessageType)type{
    //本地输入框中的信息
    if (message.length > 0 || data.length>0) {
        
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        
        NSString *bodyType = nil;
        switch (type) {
            case Text:
            {
                [body setStringValue:message];
                bodyType = @"text";
            }
                break;
            case Image:
            {
                NSString *dataStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                [body setStringValue:dataStr];
                bodyType = @"image";

            }
                break;
                
            default:
                break;
        }

        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //body类型
        [mes addAttributeWithName:@"bodyType" stringValue:bodyType];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"userid"]];
        //组合
        [mes addChild:body];
        
        //发送消息
        [[self xmppStream] sendElement:mes];
        
        
        //保存发送的消息到数据库
        DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
        FMDatabase *db = [manager getDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
        
        ChatMessageModel *model = [[ChatMessageModel alloc] init];
        [model setMessageWithNSXMLElement:mes];
        [model insertIntoTable:@"messages" forDB:db];
        
        [manager closeDB:db];
        
        //更新UI
        [messages addObject:model];
        [self.tView reloadData];
        
    }
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    [sendView.messageTF resignFirstResponder];
}



@end
