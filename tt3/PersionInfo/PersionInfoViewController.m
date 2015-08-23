//
//  PersionInfoViewController.m
//  tt3
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//
/*******************************************************************
 黄诗猛：
 1.头像上传要求:1>.使用jpeg类型；
              2>.图片不能太大。
 
 2.上传图片的成功是以调用xmppvCardTempModuleDidUpdateMyvCard:为标志。
 
 3.通用方法:1>.判断是否为PNG图片   isPNG:
           2>.按尺寸压缩图片      imageWithImage: scaledToSize:
 
 *******************************************************************/
#import "PersionInfoViewController.h"
#import "XMPPvCardTemp.h"
#import "PersionInfoCellTableViewCell.h"

@interface PersionInfoViewController ()
<UITableViewDataSource,UITableViewDelegate,
 UIImagePickerControllerDelegate>
{
    XMPPStream *xmppStream;
    XMPPvCardTempModule *vcardTempModule;
    NSArray *leftTitles;
    NSArray *rightViews;
    NSArray *rowHeighs;
    
    UIImageView *headImgView;
    UITextField *nickTF;
    UITextField *bdayTF;
    UITextField *addTF;
    UITextField *tellTF;
}
@property (weak, nonatomic) IBOutlet UIButton *OKBtn;
@end

@implementation PersionInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self vCardSetUp];
    
    if (!_isMe) {
        _OKBtn.hidden = YES;
    }
    
    if (_isMe) {
        _model = [PersionInfoModel loadDatasFromLocal];
        _userInfoDicArr = [_model createArray];
    }
    
    if (_userInfoDicArr) {
        [self loadTbaleViewDatas];
        [self tableViewSetUp];
    }
    
    if (!_isMe || !_userInfoDicArr) {
        [vcardTempModule  fetchvCardTempForJID:_jid ignoreStorage:YES];
    }

    [self tableViewSetUp];

}

-(void)loadTbaleViewDatas{
    
    rowHeighs   = @[@100,@44,@44,@44,@44];//[self loadRowHeighs];
    leftTitles  = @[@"头像",@"昵称",@"生日",@"地址",@"电话"];//[self loadLeftTitles];
//    rightTitles = [self loadRightTitles];

    headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 250, 10, 80, 80)];
    headImgView.layer.cornerRadius = 5.0f;
    headImgView.clipsToBounds = YES;
    headImgView.image = [UIImage imageWithData:_model.photo];
    [headImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTap:)]];
    headImgView.userInteractionEnabled = YES;
    
    
    
    nickTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREENWIDTH - 250, 2, 200, 40)];
    nickTF.text = _model.nickName;
    
    bdayTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREENWIDTH - 250, 2, 200, 40)];
    bdayTF.text = _model.bday;
    
    addTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREENWIDTH - 250, 2, 200, 40)];
    addTF.text = [NSString stringWithFormat:@"%@%@%@%@",_model.adrCtry,_model.adrStreet,_model.adrRegion,_model.adrExtadd];
    
    tellTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREENWIDTH - 250, 2, 200, 40)];
    tellTF.text = _model.tell;
    
    rightViews = [NSArray arrayWithObjects:headImgView,nickTF,bdayTF,addTF,tellTF, nil];

}

-(NSArray *)loadRowHeighs{
    NSMutableArray *rowHeighsTemp = [NSMutableArray array];
    NSNumber *num = nil;
    for (NSUInteger i=0; i<_userInfoDicArr.count; i++) {
        NSDictionary *dic = _userInfoDicArr[i];
        if ([dic.allValues[0] isKindOfClass:[NSData class]]) {
            num = @100;
        }
        else{
            num = @40;
        }
        [rowHeighsTemp addObject:num ];
    }
    
    return  [NSArray arrayWithArray:rowHeighsTemp];
}

-(NSArray *)loadLeftTitles{
    NSMutableArray *leftTitlesTmp = [NSMutableArray array];
    [_userInfoDicArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *  stop) {
        NSDictionary *dic = obj;
        [leftTitlesTmp  addObject:dic.allKeys[0]];
    }];
    return [NSArray arrayWithArray:leftTitlesTmp];
}

-(NSArray *)loadRightTitles{
    
    NSMutableArray *arr = [NSMutableArray array];
    
    [_userInfoDicArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *  stop) {
        NSDictionary *dic = obj;
        [arr addObject:dic.allValues[0]];
    }];
    
    return [NSArray arrayWithArray:arr];
}

-(void)tableViewSetUp{
    _tableview.delegate = self;
    _tableview.dataSource = self;
//    _tableview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backGround"]];
    [_tableview registerNib:[UINib nibWithNibName:@"PersionInfoCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell1"];
    ;
}
-(void)vCardSetUp{

    AppDelegate *appdele = [UIApplication sharedApplication].delegate;
    appdele.vcardDelegate = self;
    [appdele setupVCard];
    xmppStream = appdele.xmppStream;
    vcardTempModule = appdele.vCardTempModule;
}


-(void)imgTap:(UITapGestureRecognizer *)sender{
    NSInteger supportSource = 0;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        supportSource = supportSource | 0x01;
        NSLog(@"支持相册");
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        supportSource = supportSource | 0x02;
        NSLog(@"支持相机");
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        supportSource = supportSource | 0x04;
        NSLog(@"支持图库");
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if (supportSource >= 0x01) {
        UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.sourceType = type;
        picker.delegate  = self;
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:^{
            nil;
        }];
    }
    
    
}
//这个地方写的巨烂~~
- (IBAction)OKBtnAction:(id)sender {
    
    NSInteger i = 1;
    for (; i<rightViews.count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
        UITableViewCell *cell = [_tableview cellForRowAtIndexPath:index];
        UITextField *tf = (UITextField *)[cell.contentView viewWithTag:100 + index.row];
        if (![Tools checkVaild:tf.text withType:NSSTRING]) {
            i = -1;
            break;
        }
    }
    
    if (i == -1) {
        [self showHudOnKeyWindowTitle:@"请输入完整信息" subTitle:nil ActivityAlarm:NO after:1.5];
    }
    
    [self submit];
}


-(void)submit{
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"更新vCard。。。";
    
    XMPPvCardTemp *vcard = [XMPPvCardTemp vCardTemp];
    vcard.photo = UIImageJPEGRepresentation(headImgView.image, 0.5);
    vcard.nickname = nickTF.text;
    
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"yyyy-MM-dd"];
    vcard.bday = [form dateFromString:bdayTF.text];
    vcard.telecomsAddresses = @[tellTF.text];
    
    NSLog(@"send data length:%ld",vcard.photo.length);
    [vcardTempModule updateMyvCardTemp:vcard];

}
/**
 *  判断是不是PNG图片
 *
 *  @param data 图片data
 *
 *  @return 是PNG，返回YES
 */
-(BOOL)isPNG:(NSData *)data{
    if (data ) //request返回状态码
    {
        Byte pngHead[] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};//文件头数据
        //NSLog(@"tempData = %@", tempData);
        int cmpResult = memcmp(data.bytes, pngHead, 8);//判断是否为png格式
        //NSLog(@"PNG head 8 bytes cmpResult = %d", cmpResult);
        if (cmpResult == 0)
        {
            return YES;
        }
        
    }
    return NO;
}
/**
 *  压缩图片到指定大小
 *
 *  @param image   原图片
 *  @param newSize 压缩的大小
 *
 *  @return 压缩图片
 */
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}


#pragma -mark UITableViewDelegate&UItabelViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return leftTitles.count;
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [rowHeighs[indexPath.row] floatValue];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    PersionInfoCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    cell.rightTextTF.hidden = YES;
//    cell.rightImgView.hidden = YES;
//    cell.cellHeigh = [rowHeighs[indexPath.row] floatValue];
//    PersionInfoViewController *weafSelf = self;
//    cell.headerBlick = ^(){
//        [weafSelf imgTap:nil];
//    };
//    
//    cell.leftLabel.text = leftTitles[indexPath.row];
//    if ([rightTitles[indexPath.row] isKindOfClass:[NSData class]]) {
//        cell.rightImgView.image = [UIImage imageWithData:rightTitles[indexPath.row]];
//        cell.rightImgView.hidden = NO;
//    }
//    else{
//        cell.rightTextTF.text = rightTitles[indexPath.row];
//        cell.rightTextTF.hidden = NO;
//    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:rightViews[indexPath.row]];
    
    UILabel *lab = (UILabel *)[cell.contentView viewWithTag:100+indexPath.row];
    if (!lab) {
        lab = [[UILabel   alloc] initWithFrame:CGRectMake(10, 10, 80, 40)];
        lab.tag = 100 + indexPath.row;
        [cell.contentView addSubview:lab];
    }
    
    lab.text = leftTitles[indexPath.row];
    
    return cell;
}

#pragma -mark UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"picture info :%@",info);
    [self dismissViewControllerAnimated:picker completion:^{
    }];
    if ([info[@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]) {
        UIImage *img = info[@"UIImagePickerControllerOriginalImage"];
        CGSize size =  CGSizeMake(100, 100);
        headImgView.image = [self imageWithImage:img scaledToSize:size];
    }
}

#pragma -mark VCardDeleage
-(void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid{
    
    NSLog(@"2didreceive Vcard");
    [self handleVcardTemp:vCardTemp];
}

-(void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    self.hud.labelText = @"上传图片成功";
    self.hud.mode = MBProgressHUDModeText;
    [self.hud hide:YES afterDelay:1.5];
    NSLog(@"1didreceive Vcard:%@",vCardTempModule.myvCardTemp.photo);
}

-(void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(DDXMLElement *)error{
    NSLog(@"3didreceive Vcard");
}


-(void)handleVcardTemp:(XMPPvCardTemp *)vCardTemp{

    _model = [PersionInfoModel loadDatasFrom:vCardTemp];
    
    if (_isMe) {
        [_model saveUserInfoDicArrToLocal];
    }
    
    _userInfoDicArr = [_model createArray];
    [self loadTbaleViewDatas];
    [_tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
