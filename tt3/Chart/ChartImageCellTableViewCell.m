//
//  ChartImageCellTableViewCell.m
//  tt3
//
//  Created by hsm on 15/9/3.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "ChartImageCellTableViewCell.h"
#define kDequeueTag 100
@implementation ChartImageCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _senderImgView.layer.cornerRadius = 16.0f;
    _senderImgView.clipsToBounds = YES;
    _senderImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(senderImgViewClick:)];
    [_senderImgView addGestureRecognizer:tap];
    
}
-(void)senderImgViewClick:(UITapGestureRecognizer *)tap{
    NSLog(@"点击了头像:%@",_model.messageFrom);
    if (_imgClickBlock) {
        _imgClickBlock(_model.messageFrom);
    }
}

-(void)loadFromChartMessageModel:(ChatMessageModel *)model{
    
    [self loadValues:model];
    [self relayout];
    
}

-(void)loadValues:(ChatMessageModel *)model{
    
//    NSData *imgData = [[NSData alloc] initWithBase64Encoding:model.message];
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    form.timeZone = [NSTimeZone systemTimeZone];
    
    _model = model;
//    _imgView.image = [UIImage imageWithData:imgData];
    _timeLabel.text = [form stringFromDate:model.time];

}

-(void)relayout{
    [self frameReturnOriginal];
    [self senderImgViewFrame];
    [self imageViewFrame];
    [self cellfFrame];

}

-(CGSize)imgViewSize{
    
    return _imgView.image.size;
}


-(void)frameReturnOriginal{
    
    CGRect senderImgFrame = CGRectMake(8, 30, 32, 32);
    CGRect imageViewFrame = CGRectMake(53, 30, 260, 100);
    
    _senderImgView.frame = senderImgFrame;
    _imgView.frame = imageViewFrame;
    
    CGRect cellFrame = CGRectMake(0, 0, SCREENWIDTH, 85);
    self.frame = cellFrame;
    self.contentView.frame = cellFrame;
    
}

-(void)senderImgViewFrame{
    
    if (!_model.isme) {
        CGRect frame = _senderImgView.frame;
        frame.origin = CGPointMake(SCREENWIDTH - frame.origin.x - frame.size.width, frame.origin.y);
        _senderImgView.frame = frame;
    }
    
}

-(void)imageViewFrame{
    NSData *imgData = [[NSData alloc] initWithBase64Encoding:_model.message];
    UIImage *img = [UIImage imageWithData:imgData];
    CGRect frame = _imgView.frame;
    frame.origin.y = 30;
    //大小调整
    CGSize size  = CGSizeZero;
    CGSize imgSize = CGSizeMake(img.size.width, img.size.height);
    CGFloat maxWidth =  SCREENWIDTH - 40 - 8 - 8;
    if(imgSize.width > maxWidth) {
        //宽度>极限宽度
        CGFloat q = maxWidth/imgSize.width;
        size.width = maxWidth;
        size.height = q*imgSize.height;
    }
    else if(imgSize.width <= maxWidth && imgSize.width > 60){
        //60<宽度<极限宽度
        size = imgSize;
    }
    else {
        //宽度<60
        CGFloat q = 60.0/imgSize.width;
        size.height = q*imgSize.height;
        size.width = 60.0;
    }

    
    //位置调整
    CGPoint point = CGPointZero;
    if(!_model.isme){
        point.x = SCREENWIDTH - size.width - 48;
    }
    else{
        point.x = 48;
    }
    point.y = frame.origin.y;

    frame = CGRectMake(point.x, point.y, size.width, size.height);
    _imgView.frame = frame;
    _imgView.image = img;//[UIImage imageNamed:@"3"];//img;

    _imgView.hidden = YES;
    //autolayout sizeclass 出现问题，手动修改
    UIImageView *showImgView = (UIImageView *)[self.contentView viewWithTag:kDequeueTag];
    if (!showImgView) {
        showImgView = [[UIImageView alloc] initWithFrame:frame];
        showImgView.tag = kDequeueTag;
        [self.contentView addSubview:showImgView];
    }
    showImgView.frame = frame;
    showImgView.image = img;
    
}

-(void)cellfFrame{
    CGRect frame = self.frame;
    CGRect frame1 = self.contentView.frame;
    frame.size.height = CGRectGetMaxY(_imgView.frame) + 5;
    frame1.size.height = CGRectGetMaxY(_imgView.frame) + 5;
    self.frame = frame;
    self.contentView.frame = frame1;
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
