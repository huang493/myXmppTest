//
//  FriendListCell.m
//  tt3
//
//  Created by hsm on 15/9/19.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "FriendListCell.h"

@implementation FriendListCell

- (void)awakeFromNib {
    // Initialization code
    

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setModel:(FriendListModel *)model{
    _model = model;
    _headImgView.image = [UIImage imageWithData:model.infoModel.photo];
    _nameLabel.text = model.infoModel.nickName?model.infoModel.nickName:model.infoModel.ID;
    
    _nameLabel.text = model.infoModel.nickName;
    if (_nameLabel.text.length == 0) {
        XMPPJID *jid = [XMPPJID jidWithString:model.infoModel.ID];
        _nameLabel.text = jid.user;
    }
    
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    [dateForm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _timeLabel.text = [dateForm stringFromDate:model.lastMessage.time];
    NSDate *date = [NSDate date];

    if (model.lastMessage.isme) {
        _lastMessageLabel.text = [NSString stringWithFormat:@"me:%@",model.lastMessage.message];
    }
    else{
        _lastMessageLabel.text = model.lastMessage.message;

    }
    _dotView.hidden = model.lastMessage.isread;
    
    CGRect frame = _timeLabel.frame;
    frame.origin.x = 190*SCREENWIDTH/320.0;
    frame.size.width = 120*SCREENWIDTH/320.0;
    
    _timeLabel.frame = frame;
}


@end
