//
//  PersionInfoCellTableViewCell.m
//  tt3
//
//  Created by apple on 15/8/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "PersionInfoCellTableViewCell.h"

@implementation PersionInfoCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _rightImgView.layer.cornerRadius = 10.0f;
    _rightImgView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    _rightImgView.userInteractionEnabled = YES;
    [_rightImgView addGestureRecognizer:tap];
    
    
    self.contentView.backgroundColor = [UIColor colorWithHue:arc4random()%255/255.0 saturation:arc4random()%255/255.0 brightness:arc4random()%255/255.0 alpha:1];
    
}
-(void)tapAction:(UITapGestureRecognizer *)sender{
    if (_headerBlick) {
        _headerBlick();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellHeigh:(CGFloat )cellHeigh{
    _cellHeigh = cellHeigh;
    CGRect frame = _leftLabel.frame;
    CGRect frame1 = _rightTextTF.frame;
    CGRect frame2 = _rightImgView.frame;
    
    if ( fabs(_cellHeigh - 40) > 10) {
        frame.origin.y = 36.0;
        frame1.origin.y = 32.0;
        frame2.origin.y = 7.0;
    }
    else{
        frame.origin.y = 10.0f;
        frame1.origin.y = 6.0f;
        frame2.origin.y = 10.0f;
    }
    
    _leftLabel.frame = frame;
    _rightTextTF.frame = frame1;
    _rightImgView.frame = frame2;
    
}



@end
