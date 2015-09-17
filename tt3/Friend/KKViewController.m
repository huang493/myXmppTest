//
//  KKViewController.m
//  tt3
//
//  Created by apple on 15/7/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "KKViewController.h"
#import "KKLoginController.h"
#import "KKChatController.h"
#import "KKChatDelegate.h"
#import "AppDelegate.h"
#import "AddFriendViewController.h"
#import "MBProgressHUD.h"
#import "hintView.h"
#import "DataBaseManager.h"
#import "RoomViewController.h"

@interface KKViewController ()<UITableViewDataSource,UITableViewDelegate,KKChatDelegate>
{
    
    NSMutableArray *sectionTitles;
    NSMutableArray *onlineUsers;
    NSMutableArray *offlineUsers;
    NSMutableArray *rooms;
    AppDelegate    *appDel;
    NSString       *currentUserID;
}
@end

@implementation KKViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        sectionTitles = [NSMutableArray array];
        onlineUsers   = [NSMutableArray array];
        offlineUsers  = [NSMutableArray array];
        rooms = [NSMutableArray array];
        
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
    [self.tView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"userCell"];
    
    
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
-(void)loadFriendsFromLocal{
    
    DataBaseManager *dbManager = [DataBaseManager shareDataBaseManager];
    FMDatabase *db = [dbManager getDBWithPath:[NSString stringWithFormat:@"%@",[Tools getCurrentUserDoucmentPath]]];
    FMResultSet *set = [dbManager queryAllDatasFromTable:@"friends" forDB:db];
    [offlineUsers removeAllObjects];
    while(set.next) {
        [offlineUsers addObject:[set stringForColumn:@"jid"]];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [self loginSetup];

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
        
        [self loadFriendsFromLocal];

    }
}

#pragma -mark Notification and Action

-(void)addNotifications{
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc addObserver:self selector:@selector(receiveSubscriptionRequestNoc:) name:@"ReceiveSubscriptionRequest" object:nil];
}

-(void)receiveSubscriptionRequestNoc:(NSNotification *) no {
    NSLog(@"noc:%@",no);
    __weak KKViewController  *weakSelf = self;
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
    __weak KKViewController *weakSelf = self;
    loginVC.newAccount = ^(NSString *userid,NSString *password,NSString*server){
        [onlineUsers removeAllObjects];
        [weakSelf.tView reloadData];
    };
    [self.navigationController pushViewController:loginVC animated:YES];
}

#pragma -mark KKChatDelegate
//在线好友
-(void)newBuddyOnline:(NSString *)buddyName{
    
    if (![onlineUsers containsObject:buddyName]) {
        [onlineUsers addObject:buddyName];
        [offlineUsers removeObject:buddyName];
        [self.tView reloadData];
    }
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName{
    
    [onlineUsers removeObject:buddyName];
    [offlineUsers addObject:buddyName];
    [self.tView reloadData];
    
}

-(void)joinRoom:(NSString *)roomName{
    [rooms addObject:roomName];
    [self.tView reloadData];
}

-(void)didDisconnect{

    NSLog(@"disconnect");
}


#pragma mark UITableViewDelegate
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    if (indexPath.section == 0) {
        cell.textLabel.text = onlineUsers[indexPath.row];
        cell.textLabel.textColor = [UIColor blackColor];

    }
    else if(indexPath.section == 1){
        cell.textLabel.text = offlineUsers[indexPath.row];
        cell.textLabel.textColor = [UIColor grayColor];
    }
    else{
        cell.textLabel.text = rooms[indexPath.row];
        cell.textLabel.textColor = [UIColor blackColor];
    }

    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KKChatController *chatVC = [[KKChatController alloc] init];

    if(indexPath.section == 0){
        chatVC.chatWithUser = onlineUsers[indexPath.row];
    }
    else{
        chatVC.chatWithUser = offlineUsers[indexPath.row];
    }

    [self.navigationController pushViewController:chatVC animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
