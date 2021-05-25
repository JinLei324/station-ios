//
//  ValidateSMSCodeVC.m
//  LonelyStation
//
//  Created by zk on 2016/10/31.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ValidateSMSCodeVC.h"
#import "UIUtil.h"
#import "MainViewVM.h"
#import "MainTabBarController.h"
#import "LeftSortsViewController.h"

@interface ValidateSMSCodeVC (){
    EMTextField *_smsTextField;
    MainViewVM *_mainViewVM;
}

@end

@implementation ValidateSMSCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self initViews];
    _mainViewVM = [[MainViewVM alloc] init];
    // Do any additional setup after loading the view.
}

     
- (void)initViews {
    EMLabel *despLabel = [[EMLabel alloc] initWithFrame:Rect(20*kScale, 64+80*kScale, kScreenW - 40*kScale, 20)];
    despLabel.font = ComFont(15);
    despLabel.textColor = RGB(255,252,0);
    despLabel.text = Local(@"InputCodeValidate");
    despLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:despLabel];
    
    _smsTextField = [UIUtil textFieldWithPlaceHolder:Local(@"InputCode") andName:@"" andFrame:Rect(20, PositionY(despLabel)+20, kScreenW - 40, 35) andSuperView:self.view];
    
    EMButton *completeBtn = [UIUtil createPurpleBtnWithFrame:Rect(20, PositionY(_smsTextField)+50, kScreenW - 40, 35) andTitle:Local(@"Complate") andSelector:@selector(completeAction:) andTarget:self];
    [self.view addSubview:completeBtn];
    
    EMButton *regetBtn = [UIUtil createPurpleBtnWithFrame:Rect(20, PositionY(completeBtn)+20, kScreenW - 40, 35) andTitle:Local(@"RegetSMSCode") andSelector:@selector(regetAction:) andTarget:self];
    [self.view addSubview:regetBtn];
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(20, kScreenH - 50, kScreenW-40, 1)];
    line.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.8);
    [self.view addSubview:line];
    
    NSArray *labelArr = @[Local(@"Tips"),Local(@"TipsDetail")];
    CGFloat y = PositionY(line) + 5;
    for (int i = 0; i<labelArr.count; i++) {
        EMLabel *label = [self labelWithFrame:Rect(20, y, kScreenW-40, 35) andSpace:5 andText:labelArr[i]];
        label.alpha = 0.9;
        [self.view addSubview:label];
        y = PositionY(label);
    }
    
}

-(EMLabel*)labelWithFrame:(CGRect)rect andSpace:(CGFloat)space andText:(NSString*)str{
    NSString * cLabelString = str;
    EMLabel * cLabel = [[EMLabel alloc]initWithFrame:rect];
    cLabel.numberOfLines = 0;
    cLabel.font = ComFont(14);
    cLabel.textColor = RGB(0xff,0xff,0xff);
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:cLabelString];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:space];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [cLabelString length])];
    [cLabel setAttributedText:attributedString1];
    [cLabel sizeToFit];
    return cLabel;
}

- (void)regetAction:(EMButton*)btn {
    //重新获取验证码
    [self.view endEditing:YES];
    [UIUtil showHUD:self.view];
    [_mainViewVM getSMSCodeWithPhoneCode:_phoneCode andPhoneNumber:_phoneNumber andBlock:^(NSDictionary *adict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (adict){
            [self.view.window makeToast:adict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
         
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

- (void)jumpToMain {
    MainTabBarController *mainTab = [[MainTabBarController alloc] init];
    mainTab.isHiddenNavigationBar = YES;
    mainTab.shouldLogin3rd = YES;
    LeftSortsViewController *leftVC = [[LeftSortsViewController alloc] init];
    LeftSlideViewController *leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:mainTab];
    mainTab.slideViewCtl = leftSlideVC;
    [self.navigationController pushViewController:leftSlideVC animated:YES];
    mainTab = nil;
}

- (void)completeAction:(EMButton*)btn {
    if(_smsTextField.text.length == 0){
        [self.view.window makeToast:Local(@"InputCode") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    [self.view endEditing:YES];
    //验证验证码
    [UIUtil showHUD:self.view];
    [_mainViewVM validateSMSCode:_smsTextField.text andBlock:^(NSDictionary *adict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (adict){
            [self.view.window makeToast:adict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
            if ([adict[@"code"] intValue] == 1) {
                //进入主页
                [self jumpToMain];
            }
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
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
