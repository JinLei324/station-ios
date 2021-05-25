//
//  TelValidateVC.m
//  LonelyStation
//
//  Created by zk on 2016/10/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "TelValidateVC.h"
#import "LeftSortsViewController.h"
#import "MainViewController.h"
#import "UIUtil.h"
#import "MainViewVM.h"
#import "EMActionSheet.h"
#import "ValidateSMSCodeVC.h"
#import "LoginStatusObj.h"
#import "AddMoneyMainVC.h"

@interface TelValidateVC (){
    EMTextField *_countryTextField;
    EMTextField *_countryIDTextField;
    EMTextField *_telTextField;
    MainViewVM *_mainViewVM;
    NSMutableArray *_countryArray;
}

@end

@implementation TelValidateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainViewVM = [[MainViewVM alloc] init];
    [self.viewNaviBar setLeftBtn:nil];
    
    [self initViews];
    // Do any additional setup after loading the view.
}


- (void)initViews {
    EMButton *rightBtn = [[EMButton alloc] initWithFrame:Rect(0, 25, 70, 30)];
    [rightBtn setTitle:Local(@"Skip") forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"upperRightButton"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"upperRightButton_d"] forState:UIControlStateHighlighted];
    [rightBtn.titleLabel setFont:ComFont(16)];
    
    [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,1) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:rightBtn];
    
    EMButton *_forgetBtn = [self buttonWithName:Local(@"WelcomeUseVoicer") andFrame:Rect(44, 70, 150*kScale, 44)];
    _forgetBtn.selected = YES;
    _forgetBtn.enabled = NO;
    _forgetBtn.titleLabel.font = ComFont(18*kScale);
    [self.view addSubview:_forgetBtn];
    EMView *_slideView = [[EMView alloc] initWithFrame:Rect(44, PositionY(_forgetBtn), 150, 3)];
    _slideView.backgroundColor = RGB(145,90,173);
    _slideView.center = Point(_forgetBtn.center.x, _slideView.center.y);
    [self.view addSubview:_slideView];
    
    CGFloat y = PositionY(_slideView) + 10;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:Rect(0, y, kScreenW, kScreenH - y)];
    [self.view addSubview:scrollView];
    NSArray *labelArr = @[Local(@"VolidateWillGet"),Local(@"EightMin"),Local(@"Tips"),Local(@"TipsDetail")];
    y = 0;
    for (int i = 0; i<labelArr.count; i++) {
        EMLabel *label = [self labelWithFrame:Rect(30, y, kScreenW-50, 35) andSpace:6 andText:labelArr[i]];
        label.alpha = 0.9;
        [scrollView addSubview:label];
        y = PositionY(label)+5;
    }
    
    _countryTextField = [UIUtil textFieldWithPlaceHolder:Local(@"Country") andName:@"" andFrame:Rect(15, y+10, kScreenW - 30, 30) andSuperView:scrollView];
    _countryTextField.enabled = NO;
    
    _countryIDTextField = [UIUtil textFieldWithPlaceHolder:Local(@"CountryId") andName:@"" andFrame:Rect(15, PositionY(_countryTextField)+15, kScreenW - 30, 30) andSuperView:scrollView];
    _countryIDTextField.enabled = NO;
    
    _telTextField = [UIUtil textFieldWithPlaceHolder:Local(@"Tel") andName:@"" andFrame:Rect(15, PositionY(_countryIDTextField)+15, kScreenW - 30, 30) andSuperView:scrollView];
    
    EMButton *btn =  [UIUtil createPurpleBtnWithFrame:Rect(15, PositionY(_telTextField) + 15, kScreenW - 30, 40) andTitle:Local(@"GetTel") andSelector:@selector(getTelAction:)  andTarget:self];
    [scrollView addSubview:btn];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFiledTextAction:)];
    [scrollView addGestureRecognizer:tapGesture];

    scrollView.contentSize = Size(0, PositionY(btn)+20);
}

- (void)textFiledTextAction:(UIGestureRecognizer*)tapGesture {
    [self.view endEditing:YES];
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    if (CGRectContainsPoint(_countryTextField.frame, point)) {
        [self countryAction:_countryTextField];
    }else if (CGRectContainsPoint(_countryIDTextField.frame, point)){
        [self countryAction:_countryIDTextField];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)getTelAction:(EMButton*)btn {
    if (_countryTextField.text.length == 0) {
        [self.view.window makeToast:Local(@"PlsInputCountry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if (_telTextField.text.length == 0) {
        [self.view.window makeToast:Local(@"Tel") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    [self.view endEditing:YES];

   //获取验证码
    [UIUtil showHUD:self.view];
    [_mainViewVM getSMSCodeWithPhoneCode:_countryIDTextField.text andPhoneNumber:_telTextField.text andBlock:^(NSDictionary *adict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (adict){
            [self.view.window makeToast:adict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
            if ([adict[@"code"] intValue] == 1) {
                ValidateSMSCodeVC *validateSMSCode = [[ValidateSMSCodeVC alloc] init];
                validateSMSCode.phoneCode = _countryIDTextField.text;
                validateSMSCode.phoneNumber = _telTextField.text;
                [self.navigationController pushViewController:validateSMSCode animated:YES];
            }
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

- (void)getCountryListAndShow:(EMTextField*)texfield {
    [UIUtil showHUD:self.view];
    [_mainViewVM getTelCountryListWithBlock:^(NSArray<LonelyCountry *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _countryArray = nil;
            _countryArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showCountrySheet:texfield];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示国家列表
- (void)showCountrySheet:(EMTextField*)texfield {
    NSString *title = Local(@"CountryId");
    if (texfield == _countryTextField) {
        title = Local(@"Country");
    }
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:title clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelyCountry *country = _countryArray[buttonIndex-1];
            _countryTextField.text = country.countryName;
            _countryIDTextField.text = country.countryId;
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _countryArray.count; i++) {
        LonelyCountry *country = _countryArray[i];
        if (_countryTextField == texfield) {
            [sheet addButtonWithTitle:country.countryName];
        }else {
            [sheet addButtonWithTitle:country.countryId];
        }
    }
    [sheet showInView:self.view];
    sheet = nil;
}

//国家
- (void)countryAction:(EMTextField*)texfield {
    if (!_countryArray) {
        [self getCountryListAndShow:texfield];
    }else {
        if (_countryArray.count == 0) {
            [self getCountryListAndShow:texfield];
        }else {
            [self showCountrySheet:texfield];
        }
    }
}



-(EMButton*)buttonWithName:(NSString*)name andFrame:(CGRect)rect{
    EMButton *btn = [[EMButton alloc] initWithFrame:rect];
    btn.titStr = name;
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setTitleColor:RGB(0x99, 0x99, 0x99) forState:UIControlStateNormal];
    [btn setTitleColor:RGB(0x51, 0x51, 0x51) forState:UIControlStateSelected];
    return btn;
}

-(EMLabel*)labelWithFrame:(CGRect)rect andSpace:(CGFloat)space andText:(NSString*)str{
    NSString * cLabelString = str;
    EMLabel * cLabel = [[EMLabel alloc]initWithFrame:rect];
    cLabel.numberOfLines = 0;
    cLabel.font = ComFont(14);
    cLabel.textColor = RGB(51,51,51);
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:cLabelString];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:space];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [cLabelString length])];
    [cLabel setAttributedText:attributedString1];
    [cLabel sizeToFit];
    return cLabel;
}

- (void)completeAction:(EMButton*)btn {
        MainTabBarController *mainTab = [[MainTabBarController alloc] init];
        mainTab.isHiddenNavigationBar = YES;
        LoginStatusObj *loginedStatus = [[LoginStatusObj alloc] init];
        loginedStatus.isLogined = YES;
        loginedStatus.shouldGetUserMsg = YES;
        [[FileAccessData sharedInstance] setAObject:loginedStatus forEMKey:@"LoginStatus"];
        loginedStatus = nil;
        LeftSortsViewController *leftVC = [[LeftSortsViewController alloc] init];
        LeftSlideViewController *leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:mainTab];
        mainTab.slideViewCtl = leftSlideVC;
        [self.navigationController pushViewController:leftSlideVC animated:YES];
        mainTab = nil;
    
        //提示绑定成功加金币
    AllPopView *popView = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"FirstInitEncourage") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex){
        AddMoneyMainVC *addMoney = [[AddMoneyMainVC alloc] init];
        addMoney.isComfromMain = YES;
        [self.navigationController pushViewController:addMoney animated:YES];
    }  cancelButtonTitle:@"a" otherButtonTitles:Local(@"GetFeeDone"), nil];
    [popView show];
    
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
