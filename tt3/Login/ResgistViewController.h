//
//  ResgistViewController.h
//  tt3
//
//  Created by hsm on 15/8/22.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface ResgistViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passWordTF;
@property (weak, nonatomic) IBOutlet UITextField *passWordAgainTF;
@property (weak, nonatomic) IBOutlet UITextField *bdayTF;
@property (weak, nonatomic) IBOutlet UITextField *tellTF;
- (IBAction)OKAction:(id)sender;

@end
