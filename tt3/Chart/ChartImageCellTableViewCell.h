//
//  ChartImageCellTableViewCell.h
//  tt3
//
//  Created by hsm on 15/9/3.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessageModel.h"
typedef void(^senderImgClickBlock)(NSString *name);

@interface ChartImageCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *senderImgView;
@property (weak, nonatomic) IBOutlet UILabel     *timeLabel;
@property (strong,nonatomic) ChatMessageModel    *model;
@property (nonatomic,assign) CGFloat             cellHeigh;
@property (nonatomic,strong) senderImgClickBlock imgClickBlock;


-(void)loadFromChartMessageModel:(ChatMessageModel *)model;

@end
