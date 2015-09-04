//
//  sendMessageView.m
//  tt3
//
//  Created by apple on 15/7/23.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "sendMessageView.h"
#import "EmotionView.h"

@implementation sendMessageView 
{
    UIButton            *sendBtn;
    UIButton            *emotionsBtn;
    CGFloat             changeHigh;
    EmotionView         *emotionView;
    enum MessageType    currentTpye;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = 5.0;
        currentTpye = Text;
        [self addSubviews];
        [self resgisteNotifications];

    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubviews];
        [self resgisteNotifications];
    }
    return self;
}

-(void)resgisteNotifications{
    
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [noc addObserver:self selector:@selector(keyboardWillDisAppear:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc{
    NSNotificationCenter *noc = [NSNotificationCenter defaultCenter];
    [noc removeObserver:self];
}

-(void)addSubviews{
    
    __weak sendMessageView *weakSelf = self;
    
    
    emotionsBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    emotionsBtn.frame = CGRectMake(5, 5, 30, 30);
    [emotionsBtn setTitle:@"em" forState:UIControlStateNormal];
    [emotionsBtn addTarget:sendBtn action:@selector(enmotionsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:emotionsBtn];
    
    
    emotionView = [[EmotionView alloc] init];
    emotionView.frame = CGRectMake(0, 0, SCREENWIDTH, 200);
    emotionView.selectPictureBlock = ^(NSString *pictureName,NSData *data ,enum MessageType tpye){
        
        if (tpye == Text) {
            weakSelf.messageTF.text = [NSString stringWithFormat:@"%@%@",weakSelf.messageTF.text,pictureName];

        }
        else if (tpye == Image){
            if (weakSelf.clickBlock) {
                weakSelf.clickBlock(nil,data,tpye);
            }
        }
        
        
    };
    
    
    _messageTF = [[UITextField  alloc] initWithFrame:CGRectMake(CGRectGetMaxX(emotionsBtn.frame)+5, 5, self.frame.size.width*4/5 - CGRectGetMaxX(emotionsBtn.frame)-5, 30)];
    _messageTF.backgroundColor = [UIColor whiteColor];
    _messageTF.layer.cornerRadius = 3.0;
    _messageTF.layer.borderWidth = 1.0;
    _messageTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _messageTF.textColor = [UIColor blackColor];
    _messageTF.placeholder = @"回复:";
    _messageTF.delegate = self;
    [self addSubview:_messageTF];
    
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(CGRectGetMaxX(_messageTF.frame) + 5, 5, self.frame.size.width - CGRectGetMaxX(_messageTF.frame) - 5 -5, 30);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor magentaColor]];
    sendBtn.layer.cornerRadius = 3.0;
    [sendBtn addTarget:self action:@selector(sendBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendBtn];
    
}

#pragma -mark --------Button Action--------
-(void)enmotionsBtnAction:(UIButton*)btn{
    
    btn.selected = !btn.selected;
    if (btn.selected) {
        currentTpye = Image;
        _messageTF.inputView = emotionView;
    }
    else{
        currentTpye = Text;
        _messageTF.inputView = nil;
    }
    
    [_messageTF resignFirstResponder];
    [_messageTF becomeFirstResponder];
    
}

-(void)sendBtnAction:(UIButton *)btn{
    if (_clickBlock) {
        _clickBlock(_messageTF.text,nil,currentTpye);
        _messageTF.text = @"";
    }
}
#pragma -mark --------UITextFieldDelegate--------
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (_clickBlock) {
        _clickBlock(_messageTF.text,nil,currentTpye);
        _messageTF.text = @"";
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    currentTpye = Text;
    return YES;
}

#pragma -mark --------KeyBoardNotification Action--------
-(void)keyboardWillAppear:(NSNotification *)no{
    
    NSDictionary *dic = no.userInfo;
    NSValue *va = [dic objectForKey:UIKeyboardFrameEndUserInfoKey];
    [self resetFrame:[va CGRectValue]];
    
}

-(void)keyboardWillDisAppear:(NSNotification *)no{
    
    NSDictionary *dic = no.userInfo;
    NSValue *va = [dic objectForKey:UIKeyboardFrameEndUserInfoKey];
    [self resetFrame:[va CGRectValue]];
}

#pragma -mark --------persionalFunction--------
-(void)resetFrame:(CGRect)frame
{
    CGFloat heigh = 0.0;
    if (CGRectGetMaxY(self.frame)<[UIScreen mainScreen].bounds.size.height) {
        heigh = -1 * frame.size.height;
    }
    else{
        heigh = frame.size.height;
    }
    
    if (self.chanegeHiBlock) {
        self.chanegeHiBlock(heigh);
    }
}



@end
