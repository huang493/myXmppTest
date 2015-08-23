//
//  ChatCellTableViewCell.m
//  tt3
//
//  Created by apple on 15/7/27.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ChatCellTableViewCell.h"
#import "Tools.h"
#import "PersionInfoModel.h"

@implementation ChatCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _senderImgView.layer.cornerRadius = 16.0f;
    _senderImgView.clipsToBounds = YES;
    _senderImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(senderImgViewClick:)];
    [_senderImgView addGestureRecognizer:tap];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)senderImgViewClick:(UITapGestureRecognizer *)tap{
    NSLog(@"点击了头像:%@",_model.messageFrom);
    if (_imgClickBlock) {
        _imgClickBlock(_model.messageFrom);
    }
}

-(void)setModel:(ChatMessageModel *)model{
    _model = model;
    [self loadDatasFromChatMessageModel:_model];
}

-(void)loadDatasFromChatMessageModel:(ChatMessageModel *)model{
    
    _model = model;
    _timeLabel.text      = @"2015-08-01";//[model.time description];
    _messageLabel.text   = model.message;
    [self setCellHeigh:model.cellHeigt];
    if (model.isme) {
//        PersionInfoModel *model = [PersionInfoModel loadDatasFromLocal];
//        _senderImgView.image = [UIImage imageWithData:model.photo];
    }else{
        _senderImgView.image = [UIImage imageNamed:@"4"];
    }
    
    [self frameReturnBegin];
    [self frameChange];
    [self setCellHeigh:model.cellHeigt];

}

#pragma -mark  根据发送者，从新布局
-(void)frameReturnBegin{
    
        CGRect frame1 = self.senderImgView.frame;
        CGRect frame2 = self.messageLabel.frame;
    
        frame1.origin.x  =  8;
        frame2.origin.x  =  57;
        
        self.senderImgView.frame = frame1;
        self.messageLabel.frame = frame2;
        
        _messageLabel.textAlignment = NSTextAlignmentLeft;
}

-(void)frameChange{
    
    if (!_model.isme) {
        CGRect frame1 = self.senderImgView.frame;
        CGRect frame2 = self.messageLabel.frame;
        
        frame1.origin.x  =  SCREENWIDTH - CGRectGetMaxX(self.senderImgView.frame);
        frame2.origin.x -=  CGRectGetWidth(self.senderImgView.frame);
        
        self.senderImgView.frame = frame1;
        self.messageLabel.frame = frame2;
        
        
        _messageLabel.textAlignment = NSTextAlignmentRight;
    }
}

#pragma -mark 修改cell的高度
-(void)setCellHeigh:(CGFloat)cellHeigh{
    
    //复原
    CGRect frame = self.frame;
    CGRect frame1 = _messageLabel.frame;
    frame.size.height =  60;
    frame1.size.height = 21;
    self.frame = frame;
    _messageLabel.frame = frame1;
    
    _cellHeigh = cellHeigh;
    
    //修改
    if (cellHeigh > 21) {
    
        CGRect frame = self.frame;
        CGRect frame1 = _messageLabel.frame;
        
        frame.size.height += _cellHeigh - 21;
        frame1.size.height = _cellHeigh;
        
        self.frame = frame;
        _messageLabel.frame = frame1;
        
        _messageLabel.textAlignment = NSTextAlignmentLeft;
    }

}

@end
