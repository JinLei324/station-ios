//
//  InComeAccountVC.m
//  LonelyStation
//
//  Created by zk on 2016/12/10.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "InComeAccountVC.h"
#import "UIUtil.h"
#import "LookFeeWebVC.h"
#import "UserSettingViewModel.h"

@interface InComeAccountVC (){
    NSArray *_imageArray;
    NSArray *_accountArray;
    NSArray *_signAccountArray;
    EMTextField *_textField;
    UserSettingViewModel *_userSettingViewModel;
}

@end

@implementation InComeAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"AccountInfo")];
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 70*kScale, 30)];
    buyBtn.layer.borderColor = RGB(0xff, 0xff, 0xff).CGColor;
    buyBtn.layer.borderWidth = 1;
    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    
    [buyBtn setTitleColor:RGB(0xff, 0xff, 0xff) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Sure") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(complateAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    _userSettingViewModel = [[UserSettingViewModel alloc] init];
    _imageArray = @[@"withdrawal_paypal",@"withdrawal_allpay",@"withdrawal_wechat"];
    _accountArray = @[@"paypal",@"allpay",@"wechat"];
    
    _signAccountArray = @[@"https://www.paypal.com/",@"https://www.allpay.com.tw/",@"https://open.weixin.qq.com/"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:Rect((kScreenW-180*kScale)/2.f, 64+22*kScale, 180*kScale, 44*kScale)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:_imageArray[_selectIndex]];
    [self.view addSubview:imageView];
    
    _textField = [UIUtil textFieldWithPlaceHolder:[NSString stringWithFormat:@"%@%@%@",Local(@"PlsInput"),_accountArray[_selectIndex],Local(@"Account")] andName:@"" andFrame:Rect(56*kScale, PositionY(imageView)+10*kScale, kScreenW - 112*kScale, 30) andSuperView:self.view];
    
    EMLabel *label = [UIUtil createLabel:Local(@"Or") andRect:Rect(12*kScale, PositionY(_textField)+10, kScreenW-24*kScale, 14) andTextColor:[UIColor whiteColor] andFont:ComFont(13) andAlpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    EMButton *btn = [[EMButton alloc] initWithFrame:Rect(22*kScale, PositionY(label)+10, kScreenW-44*kScale, 15)];
    btn.titleLabel.font = ComFont(14*kScale);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",Local(@"GoTo"),_accountArray[_selectIndex],Local(@"Sign")]];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:strRange];
    [btn setAttributedTitle:str forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    // Do any additional setup after loading the view.
}


- (void)btnAction:(id)sender {
    LookFeeWebVC *lookFee = [[LookFeeWebVC alloc] init];
    lookFee.urlStr = _signAccountArray[_selectIndex];
    [self.navigationController pushViewController:lookFee animated:YES];
}

- (void)complateAction:(id)sender {
    if ([_textField.text length] == 0) {
        [self.view.window makeToast:[NSString stringWithFormat:@"%@%@%@",Local(@"PlsInput"),_accountArray[_selectIndex],Local(@"Account")] duration:ERRORTime position:[CSToastManager defaultPosition]];
    }else{
        [_userSettingViewModel updateWithDrawSettingWithAccount:_textField.text andCurrent:_accountArray[_selectIndex] andBlock:^(NSDictionary *dict, BOOL ret) {
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
                        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"InComeDetailVC"]) {
                            [self.navigationController popToViewController:self.navigationController.viewControllers[i] animated:YES];
                            break;
                        }
                    }
                }else {
                    [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
            }else {
                [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];

            }
        }];

    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
