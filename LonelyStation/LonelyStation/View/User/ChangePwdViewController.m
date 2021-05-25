//
//  ChangePwdViewController.m
//  LonelyStation
//
//  Created by zk on 16/6/2.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "EMButton.h"
#import "EMLabel.h"
#import "UIUtil.h"
#import "UserSettingViewModel.h"


@interface ChangePwdViewController (){
    NSMutableDictionary *_textFieldDict;
    NSArray *_labelStrArray;
    UserSettingViewModel *_userSettingVM;
}

@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"ResetPwd") andColor:RGB(145,90,173)];
    _userSettingVM = [[UserSettingViewModel alloc] init];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)completeAction:(EMButton*)btn {
    EMTextField *oldField = [_textFieldDict objectForKey:_labelStrArray[0]];
    EMTextField *newField = [_textFieldDict objectForKey:_labelStrArray[1]];
    EMTextField *newSureField = [_textFieldDict objectForKey:_labelStrArray[2]];
    if ([oldField.text isEqualToString:@""]) {
        [self.view makeToast:Local(@"PlsInputOldPwd") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if ([newField.text isEqualToString:@""]) {
        [self.view makeToast:Local(@"PlsInputNewPwd") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if (![newField.text isEqualToString:newSureField.text]) {
        [self.view makeToast:Local(@"PlsInputSamePwd") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    
    [_userSettingVM changePwdWithNewPwd:newSureField.text andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
        }else{
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}


-(void)initViews{
    _labelStrArray = @[Local(@"OriginPwd"),Local(@"NewPwd"),Local(@"ReInputPwd")];
    _textFieldDict = [NSMutableDictionary dictionary];
    
    EMButton *rightBtn = [[EMButton alloc] initWithFrame:Rect(0, 0, 70, 30)];
    rightBtn = [[EMButton alloc] initWithFrame:Rect(0, 33, 70, 30)];
    [rightBtn setTitle:Local(@"Complate") forState:UIControlStateNormal];
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"upperRightButton"] forState:UIControlStateNormal];
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"upperRightButton_d"] forState:UIControlStateHighlighted];
    [rightBtn.layer setBackgroundColor:RGB(145,90,173).CGColor];
    [rightBtn.layer setCornerRadius:15];
    [rightBtn.layer setMasksToBounds:YES];
    [rightBtn.titleLabel setFont:ComFont(16)];
    
    [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,1) forState:UIControlStateNormal];
    [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,0.5) forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:rightBtn];
    
    
    CGFloat x = 80;
    CGFloat y = 186;
    CGFloat width = kScreenW - 2 * x;
    CGFloat hightLabel = 14;
    CGFloat hightTextField = 30;
    for (int i = 0; i < _labelStrArray.count; i++) {
        EMLabel *label = [UIUtil createLabel:_labelStrArray[i] andRect:Rect(x, y, width, hightLabel) andTextColor:RGB(51, 51, 51) andFont:ComFont(14) andAlpha:1];
        [self.view addSubview:label];
        
        EMTextField *field = [UIUtil textFieldWithPlaceHolder:@"" andName:_labelStrArray[i] andFrame:Rect(x, PositionY(label)+11, width, hightTextField) andSuperView:self.view];
        field.secureTextEntry = YES;
        [_textFieldDict setObject:field forKey:_labelStrArray[i]];
        y = PositionY(field) + 35;
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
