//
//  KKChatController.m
//  tt3
//
//  Created by apple on 15/7/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "KKChatController.h"
#import "ChatCellTableViewCell.h"
#import "ChartImageCellTableViewCell.h"
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
#import "XMPPSender.h"
#import "FriendInfoModel.h"


@interface KKChatController ()<UITableViewDelegate,UITableViewDataSource,KKMessageDelegate>
{
    NSMutableArray  *messages;
    AppDelegate     *appDel;
    NSString        *currentUserId;
    sendMessageView *sendView;
    UIImage         *myHeaderPhoto;
    UIImage         *friendHeaderPhoto;
    PersionInfoModel *myInfo;
    FriendInfoModel  *friendInfo;
}
@end

@implementation KKChatController

-(void)viewWillAppear:(BOOL)animated{
    [_tView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self config];
    [self loadTalkerInfo];
    [self addTableView];
    [self addSendView];
    [self initNavgationBarItem];
}

-(void)config{
    self.view.backgroundColor = [UIColor whiteColor];

    messages = [[NSMutableArray alloc] init];
    appDel = [self getDelegate];
    appDel.client.messageDelegate = self;
    currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
}

-(void)loadTalkerInfo{
    
    myInfo = [PersionInfoModel loadDatasFromLocal];
    friendInfo = [FriendInfoModel loadFriendInfoFromLocal:_chatWithUser];
    
    if (!myInfo) {
        [appDel.client setupVCard];
        [appDel.client.vCardTempModule fetchvCardTempForJID:appDel.client.xmppStream.myJID ignoreStorage:YES];
    }
    
    if (!friendInfo) {
        [appDel.client setupVCard];
        [appDel.client.vCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:_chatWithUser] ignoreStorage:YES];
    }
    
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
    [_tView registerNib:[UINib nibWithNibName:@"ChatCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"chatTextCell"];
    [_tView registerNib:[UINib nibWithNibName:@"ChartImageCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"chatImageCell"];
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
    return del.client.xmppStream;
}

#pragma mark KKMessageDelegate
-(void)newMessageReceived:(ChatMessageModel*)message{
    
    [messages addObject:message];
    [_tView reloadData];
    
}
#pragma -mark UITableViewDelegate & UITableViewDataDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatMessageModel *model = messages[indexPath.row];
    if ([model.bodyType isEqualToString:@"text"]) {
        return  model.cellHeigt + 60 - 21;
    }
    else {
        return  model.cellHeigt + 35;
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *idenfitif = nil;
    ChatMessageModel *model     = [messages objectAtIndex:indexPath.row];
    UITableViewCell *cell1 = nil;
    
    if ([model.bodyType isEqualToString:@"text"]) {
        idenfitif = @"chatTextCell";
        ChatCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idenfitif forIndexPath:indexPath];
        
        [cell loadDatasFromChatMessageModel:model];
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
        
        if (model.isme) {
            cell.senderImgView.image = [UIImage imageWithData:myInfo.photo];
        }
        else{
            cell.senderImgView.image = [UIImage imageWithData:friendInfo.photo];
        }

        cell1 = cell;
    }
    else if([model.bodyType isEqualToString:@"image"]){
        idenfitif = @"chatImageCell";
        ChartImageCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idenfitif forIndexPath:indexPath];
        [cell loadFromChartMessageModel:model];
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
        
        if (model.isme) {
            cell.senderImgView.image = [UIImage imageWithData:myInfo.photo];
        }
        else{
            cell.senderImgView.image = [UIImage imageWithData:friendInfo.photo];
        }
        
        cell1 = cell;
    }
    
    return cell1;
}
#pragma -mark vCardTempDelegate ----
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    if ([[jid bare] isEqualToString:_chatWithUser]) {
        friendInfo = [FriendInfoModel loadFriendInfoFromLocal:_chatWithUser];
    }
    else{
        myInfo = [PersionInfoModel loadDatasFromLocal];
    }
    
    [_tView reloadData];
}
#pragma -mark xmpp 发送消息-----
- (void)sendMessage:(NSString *)message andData:(NSData *)data withType:(enum MessageType)type{
    
    ChatMessageModel *model = [XMPPSender sendMessage:message andData:data withType:type to:_chatWithUser];
//    [XMPPSender sendIq];
    if (model) {
        //更新UI
        [messages addObject:model];
        [self.tView reloadData];
    }
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    [sendView.messageTF resignFirstResponder];
}



@end
