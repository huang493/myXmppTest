//
//  FriendListViewController.m
//  tt3
//
//  Created by apple on 15/7/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "FriendListViewController.h"
#import "KKLoginController.h"
#import "ChatMainViewController.h"
#import "KKChatDelegate.h"
#import "AppDelegate.h"
#import "AddFriendViewController.h"
#import "MBProgressHUD.h"
#import "hintView.h"
#import "DataBaseManager.h"
#import "RoomViewController.h"
#import "FriendListModel.h"
#import "FriendListCell.h"

@interface FriendListViewController ()<UITableViewDataSource,UITableViewDelegate,KKChatDelegate>
{
    
    NSMutableArray *sectionTitles;
    NSMutableArray *onlineUsers;
    NSMutableArray *offlineUsers;
    NSMutableArray *rooms;
    AppDelegate    *appDel;
    NSString       *currentUserID;
    dispatch_queue_t refreshQueue;
    FMDatabaseQueue *dbQueue;
}
@end

@implementation FriendListViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        sectionTitles = [NSMutableArray array];
        onlineUsers   = [NSMutableArray array];
        offlineUsers  = [NSMutableArray array];
        rooms = [NSMutableArray array];
        refreshQueue = dispatch_queue_create("messageRefreshQueue", NULL);
        NSString *path = [Tools getCurrentUserDoucmentPath];
        path = [NSString stringWithFormat:@"%@/Message.db",path];
        dbQueue      = [[FMDatabaseQueue alloc] initWithPath:path];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setNav];
    [self setSectionTitles];
    [self addNotifications];
    
    self.tView.delegate = self;
    self.tView.dataSource = self;
    [self.tView registerNib:[UINib nibWithNibName:@"FriendListCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    
    appDel = [self getDelegate];
    appDel.client.chatDelegate = self;
#if 0 //好友列表调试
    DataBaseManager *manager = [DataBaseManager shareDataBaseManager];
    FMDatabase *db = [manager getDBWithPath:[Tools getCurrentUserDoucmentPath]];
    
    FMResultSet *res = [manager queryAllDatasFromTable:@"friends" forDB:db];
    NSLog(@"friend  strat ----------------------------------------------------------------------------");
    while (res.next) {
        
        NSLog(@"jid:%@ nickName:%@",[res stringForColumn:@"jid"],[res stringForColumn:@"nickName"]);
    }
    NSLog(@"friend  end   ----------------------------------------------------------------------------");
    
    [manager closeDB:db];
#endif
    
}
-(void)refreshList{
    
    [offlineUsers removeAllObjects];
    
    dispatch_async(refreshQueue, ^{
        NSMutableArray *infos = [FriendInfoModel loadAllFrendsFromLocal];
        [infos enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
            FriendInfoModel *model = obj;
            FriendListModel *listModel = [[FriendListModel alloc] init];
            NSString *sql1 = [NSString stringWithFormat:@"select * from messages where messageTo = '%@' and messageFrom = '%@' order by time desc",[Tools getCurrentUserId],model.ID];
            NSString *sql2 = [NSString stringWithFormat:@"select * from messages where messageTo = '%@' and messageFrom = '%@' order by time desc",model.ID,[Tools getCurrentUserId]];
            [dbQueue inDatabase:^(FMDatabase *db) {
                FMResultSet *set1 = [db executeQuery:sql1];
                ChatMessageModel *lastMessage1 = [ChatMessageModel setMessageWithFMResultSet:set1];

                FMResultSet *set2 = [db executeQuery:sql2];
                ChatMessageModel *lastMessage2 = [ChatMessageModel setMessageWithFMResultSet:set2];
                [set1 close];
                [set2 close];
                
                NSDate* date = [lastMessage1.time laterDate:lastMessage2.time];
                if ([date isEqualToDate:lastMessage1.time]) {
                    listModel.lastMessage = lastMessage1;
                }
                else{
                    listModel.lastMessage = lastMessage2;
                }
                listModel.infoModel = model;
                [offlineUsers addObject:listModel];
            }];

        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tView  reloadData];
 
        });
    });

}

-(void)viewWillAppear:(BOOL)animated
{
    [self loginSetup];
    [self refreshList];
    
    NSUserDefaults *defau = [NSUserDefaults standardUserDefaults];
    NSString *accountStr = [defau objectForKey:@"userid"];
    accountStr = [accountStr componentsSeparatedByString:@"@"].count>0 ?  [accountStr componentsSeparatedByString:@"@"][0]:@"";
    self.navigationItem.title = [NSString stringWithFormat:@"%@",accountStr];
    
}

-(void)loginSetup{
    BOOL needReLogin = NO;
    if (!currentUserID) {
        currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        needReLogin   = YES;
    }
    else{
        if (![currentUserID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]]) {
            currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
            needReLogin = YES;
        }
    }
    
    if (!currentUserID) {
        //设定用户
        [self Account:self];
        return;
    }
    
    if (needReLogin) {
        
        [[self getDelegate].client disconnect];
        if ([[self getDelegate].client connect]) {
            NSLog(@"------------>>>Account location login success");
        }
        
    }
}

#pragma -mark Notification and Action

-(void)addNotifications{
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc addObserver:self selector:@selector(receiveSubscriptionRequestNoc:) name:@"ReceiveSubscriptionRequest" object:nil];
}

-(void)receiveSubscriptionRequestNoc:(NSNotification *) no {
    NSLog(@"noc:%@",no);
    __weak FriendListViewController  *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic             = no.object;
        XMPPRoster   *roster          = dic[@"XMPPRoster"];
        XMPPPresence *presence        = dic[@"XMPPPresence"];
        
        hintView *hintV               = [[NSBundle mainBundle] loadNibNamed:@"hintView" owner:self options:nil][0];
        [self showHudOnKeyWindowCustomView:hintV after:0.0];
        self.hud.color = [UIColor lightGrayColor];
        hintV.hintMessage.text        = [NSString stringWithFormat:@"%@请求添加为好友。",[presence from]];
        hintV.btnBlock                = ^(NSInteger index){
                                            if (index == 1) {
                                                [roster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
                                            }
                                            else{
                                                [roster rejectPresenceSubscriptionRequestFrom:[presence from]];
                                            }
                                            [weakSelf showHud:NO];
        };
    });
}



-(void)setNav{
    
    UIButton *addFriendBtn = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    addFriendBtn.frame = CGRectMake(0, 0, 60, 30);
    [addFriendBtn setTitle:@"+Friend" forState:UIControlStateNormal];
    addFriendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addFriendBtn addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addFriend = [[UIBarButtonItem alloc] initWithCustomView:addFriendBtn];
    
    UIButton *addRoomBtn = [UIButton  buttonWithType:UIButtonTypeRoundedRect];
    addRoomBtn.frame = CGRectMake(0, 0, 60, 30);
    [addRoomBtn setTitle:@"+Room" forState:UIControlStateNormal];
    addRoomBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addRoomBtn addTarget:self action:@selector(addRoom:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addRoom = [[UIBarButtonItem alloc] initWithCustomView:addRoomBtn];
    
    self.navigationItem.rightBarButtonItems = @[addRoom,addFriend];
    
}
-(void)setSectionTitles{
    [sectionTitles addObject:@"online friends"];
    [sectionTitles addObject:@"offline friends"];
    [sectionTitles addObject:@"room"];
}
-(void)getSubscribed{
    XMPPRosterCoreDataStorage *rosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
    XMPPRoster *roster = [[XMPPRoster alloc] initWithRosterStorage:rosterCoreDataStorage];
    [roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

-(void)addFriend:(UIButton *)sender
{
    AddFriendViewController *addFirendVC = [[AddFriendViewController alloc] init];
    [self.navigationController pushViewController:addFirendVC animated:YES];
}
-(void)addRoom:(UIButton *)sender{
#pragma -mark TODO:添加房间
    
    RoomViewController *roomVC = [[RoomViewController alloc] init];
    [self.navigationController pushViewController:roomVC animated:YES];
    
}

-(AppDelegate *)getDelegate
{
    return  (AppDelegate *)[UIApplication sharedApplication].delegate;
    
}

- (IBAction)Account:(id)sender {
    KKLoginController *loginVC = [[KKLoginController alloc] init];
    __weak FriendListViewController *weakSelf = self;
    loginVC.newAccount = ^(NSString *userid,NSString *password,NSString*server){
        [onlineUsers removeAllObjects];
        [weakSelf.tView reloadData];
    };
    [self.navigationController pushViewController:loginVC animated:YES];
}

#pragma -mark KKChatDelegate
//在线好友
-(void)newBuddyOnline:(FriendListModel *)model{
    
//    if (![onlineUsers containsObject:model]) {
//        [onlineUsers addObject:model];
//        [offlineUsers removeObject:model];
//        [self.tView reloadData];
//    }
}

//好友下线
-(void)buddyWentOffline:(FriendListModel *)model{
    
//    [onlineUsers removeObject:model];
//    [offlineUsers addObject:model];
//    [self.tView reloadData];
    
}

-(void)joinRoom:(FriendListModel *)model{
//    [rooms addObject:model];
//    [self.tView reloadData];
}

-(void)didDisconnect{

    NSLog(@"disconnect");
}


#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return sectionTitles[section];
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionTitles.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return [onlineUsers count];
    }
    else if(section == 1){
        return [offlineUsers count];
    }
    else {
        return [rooms count];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSArray *datas = nil;
    
    if (indexPath.section == 0) {
        datas = onlineUsers;
    }
    else if(indexPath.section == 1){
        datas = offlineUsers;
    }
    else{
        datas = rooms;
    }
    
    cell.model = datas[indexPath.row];
    
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatMainViewController *chatVC = [[ChatMainViewController alloc] init];
    FriendListModel *model = nil;
    if(indexPath.section == 0){
        model = onlineUsers[indexPath.row];
    }
    else if(indexPath.section == 1){
        model = offlineUsers[indexPath.row];
    }
    else {
        model = rooms[indexPath.row];
    }
    
    chatVC.chatWithUser = model.infoModel.ID;
    [self.navigationController pushViewController:chatVC animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
