//
//  PersionInfoCellTableViewCell.h
//  tt3
//
//  Created by apple on 15/8/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^imgClickBlock)(void);

@interface PersionInfoCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UITextField *rightTextTF;
@property (assign, nonatomic) CGFloat cellHeigh;
@property (strong,nonatomic) imgClickBlock headerBlick;
@end
