//
//  UserSettingVC.m
//  LonelyStation
//
//  Created by zk on 2016/11/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UserSettingVC.h"
#import "UIUtil.h"
#import "ChangePwdViewController.h"
#import "AuthorManagerVC.h"
#import "LockManagerVC.h"
#import "CommonQuestionVC.h"
#import "EMAlertView.h"
#import "UserSettingCell.h"
#import "UserSettingViewModel.h"
#import "LoginViewController.h"
#import "LoginStatusObj.h"
#import "ViewModelCommom.h"
#import "AppDelegate.h"

@interface UserSettingVC ()<UITableViewDelegate,UITableViewDataSource,UserSettingViewDelegate,UserChargeSettingViewDelegate>{
    EMTableView *_tableView;
    NSArray *_sectionArray;
    NSMutableDictionary *_cellStatusDictory;
    UserSettingViewModel *_userVM;
    NSMutableDictionary *_dataDict;
}

@end

@implementation UserSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _userVM = [[UserSettingViewModel alloc] init];
    [self.viewNaviBar setTitle:Local(@"Setting") andColor:RGB(145,90,173)];
    
    [_userVM getMySettingWithBlock:^(NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            if ([dict[@"code"] intValue] == 1) {
                _dataDict = [NSMutableDictionary dictionaryWithDictionary:dict[@"data"]];
            }
        }
    }];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)initViews {
    _sectionArray = @[Local(@"NoticeSetting"),Local(@"CallSetting"),Local(@"AuthorSetting"),Local(@"LockSetting"),Local(@"ResetPwd"),Local(@"CommonQuestion"),Local(@"DeleteUserForever")];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.gender isEqualToString:@"F"]) {
        _sectionArray = @[Local(@"ChargeSetting"), Local(@"NoticeSetting"),Local(@"CallSetting"),Local(@"AuthorSetting"),Local(@"LockSetting"),Local(@"ResetPwd"),Local(@"CommonQuestion"),Local(@"DeleteUserForever")];
    }
    _cellStatusDictory = [NSMutableDictionary dictionary];
    for (int i = 0; i<_sectionArray.count; i++) {
        [_cellStatusDictory setObject:@"0" forKey:[NSString stringWithFormat:@"%d",i]];
    }
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentify = @"cell";
    UserSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        cell = [[UserSettingCell alloc] initWithSize:CGSizeMake(size.width, 44) reuseIdentifier:cellIdentify];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *stateStr = [_cellStatusDictory objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]];
    if ([stateStr intValue] == 0) {
        cell.hidden = YES;
    }else {
        cell.hidden = NO;
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        if ([user.gender isEqualToString:@"F"]) {
            if(indexPath.section == 2) {
                [cell setLabelHidden:YES];
                [cell setSettingHidden:NO];
                [cell setChartHidden:YES];
                cell.settingView.aDelegate = self;
                cell.chartSettingView.aDelegate = self;
                if (_dataDict) {
                    //判断是不是电台情人
                    LonelyUser *user = [ViewModelCommom getCuttentUser];
                    cell.settingView.aSwitchBtn.selected = ![_dataDict[@"allow_talk"] boolValue];
                    NSString *str = _dataDict[@"allow_talk_period"];
                    NSArray *arr = [str componentsSeparatedByString:@"-"];
                    if (arr.count == 2) {
                        cell.settingView.timeLabel.text = NOTNULLObj(_dataDict[@"allow_talk_period"]);
                        int start = [arr[0] intValue];
                        int end = [arr[1] intValue];
                        cell.settingView.nmSlider.lowerValue = start/24.f;
                        cell.settingView.nmSlider.upperValue = end/24.f;
                    }
                    if ([user.identity intValue] == 3) {
                        [cell setMaskOn:NO];
                    }else{
                        [cell setMaskOn:YES];
                    }
                }
            }else if(indexPath.section == 0){
                cell.chartSettingView.aDelegate = self;
                NSString *strTalk = _dataDict[@"talk_charge"];
                BOOL boolTalk = [strTalk isEqualToString:@"Y"]?NO:YES;
                NSString *strMsg = _dataDict[@"msg_charge"];
                BOOL boolMsg = [strMsg isEqualToString:@"Y"]?NO:YES;
                CGFloat addHeight = 0;
                if (!boolMsg) {
                    addHeight = addHeight + 132*kScale;
                }
                if (!boolTalk) {
                    addHeight = addHeight + 132*kScale;
                }
                [cell.chartSettingView setFrame:Rect(0, 0, kScreenW, addHeight+88*kScale)];
                [cell.chartSettingView setChatSwithchOn:boolTalk];
                [cell.chartSettingView setMsgSwithchOn:boolMsg];
                [cell.chartSettingView setMsgChildSelect:NOTNULLObj(_dataDict[@"msg_charge_rate"])];
                [cell.chartSettingView setChatChildSelect:NOTNULLObj(_dataDict[@"talk_charge_rate"])];
                [cell setLabelHidden:YES];
                [cell setSettingHidden:YES];
                [cell setChartHidden:NO];
            } else {
                [cell setLabelHidden:NO];
                [cell setSettingHidden:YES];
                [cell setChartHidden:YES];
            }
        }else{
            if(indexPath.section == 1) {
                [cell setLabelHidden:YES];
                [cell setSettingHidden:NO];
                [cell setChartHidden:YES];
                cell.settingView.aDelegate = self;
                if (_dataDict) {
                    //判断是不是电台情人
                    LonelyUser *user = [ViewModelCommom getCuttentUser];
                    cell.settingView.aSwitchBtn.selected = ![_dataDict[@"allow_talk"] boolValue];
                    NSString *str = _dataDict[@"allow_talk_period"];
                    NSArray *arr = [str componentsSeparatedByString:@"-"];
                    if (arr.count == 2) {
                        cell.settingView.timeLabel.text = NOTNULLObj(_dataDict[@"allow_talk_period"]);
                        int start = [arr[0] intValue];
                        int end = [arr[1] intValue];
                        cell.settingView.nmSlider.lowerValue = start/24.f;
                        cell.settingView.nmSlider.upperValue = end/24.f;
                    }
                    if ([user.identity intValue] == 3) {
                        [cell setMaskOn:NO];
                    }else{
                        [cell setMaskOn:YES];
                    }
                }
            }else {
                [cell setLabelHidden:NO];
                [cell setSettingHidden:YES];
                [cell setChartHidden:YES];
            }
        }
    }

    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = [_cellStatusDictory objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]];
    if ([str isEqualToString:@"0"]) {
        return 0.001;
    }else {
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        if ([user.gender isEqualToString:@"F"]) {
            if (indexPath.section == 2) {
                return 122*kScale;
            }else if (indexPath.section == 0) {
                NSString *ret = [_dataDict objectForKey:@"talk_charge"];
                CGFloat addHeight = 0;
                if ([ret isEqualToString:@"Y"]) {
                    addHeight = addHeight + 132*kScale;
                }
                NSString *msgRet = [_dataDict objectForKey:@"msg_charge"];
                if ([msgRet isEqualToString:@"Y"]) {
                    addHeight = addHeight + 132*kScale;
                }

                return 88*kScale +addHeight;
            }else{
                return 40*kScale;
            }
        }else {
            if (indexPath.section == 1) {
                return 122*kScale;
            }else{
                return 40*kScale;
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 42*kScale;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *headerStr = @"headSection";
    EMView *view = (EMView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:headerStr];
    if (!view) {
        view = [[EMView alloc] initWithFrame:Rect(0, 0, kScreenW, 42*kScale)];
        view.backgroundColor = RGB(255, 255, 255);
        EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(27*kScale, 0, kScreenW - 54*kScale , 42*kScale)];
        label.font = ComFont(14*kScale);
        label.textColor = RGB(51,51,51);
        label.text = _sectionArray[section];
        view.tag = section;
        [view addSubview:label];
        EMView *line = [[EMView alloc] initWithFrame:Rect(0, 42*kScale - 0.5, kScreenW, 0.5)];
        line.backgroundColor = RGB(171, 171, 171);
        [view addSubview:line];
    }
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:Rect(kScreenW - 50 * kScale, 16*kScale, 11*kScale, 16*kScale)];
    arrowImageView.tag = 101;
    arrowImageView.image = [UIImage imageNamed:@"set_go"];
    [view addSubview:arrowImageView];
    NSString *status = [_cellStatusDictory objectForKey:[NSString stringWithFormat:@"%d",(int)section]];
    if ([status intValue] == 1) {
        arrowImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClick:)];
    [view addGestureRecognizer:tapGesture];
    return view;
}

- (void)didSelectAction:(BOOL)ret {
    [_dataDict setObject:[NSString stringWithFormat:@"%d",!ret] forKey:@"allow_talk"];
}

- (void)didSelectCallChargeAction:(BOOL)ret {
    NSString *str = @"Y";
    if (ret) {
        str = @"N";
    }
    [_dataDict setObject:str forKey:@"talk_charge"];
    [_userVM updateMySettingWithField:@"talk_charge" andValue:str andBlock:^(NSDictionary *dict, BOOL ret) {
        if (ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyUser *user = [ViewModelCommom getCuttentUser];
                user.talkCharge = str;
                [ViewModelCommom saveUser:user];
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }];

}

- (void)didSelectmsgChargeChildAction:(NSString*)charge{
    [_dataDict setObject:charge forKey:@"msg_charge_rate"];
    [_userVM updateChargeNotifySetting:@"msg_charge_rate" andValue:charge andBlock:^(NSDictionary *dict, BOOL ret) {
        if (ret) {
            LonelyUser *user = [ViewModelCommom getCuttentUser];
            user.msgChargeRate = charge;
            [ViewModelCommom saveUser:user];
        }
    }];
}

- (void)didSelectchatChargeChildAction:(NSString*)charge{
    [_dataDict setObject:charge forKey:@"talk_charge_rate"];
    [_userVM updateChargeNotifySetting:@"talk_charge_rate" andValue:charge andBlock:^(NSDictionary *dict, BOOL ret) {
        if (ret) {
            LonelyUser *user = [ViewModelCommom getCuttentUser];
            user.talkChargeRate = charge;
            [ViewModelCommom saveUser:user];
        }
    }];
}

- (void)didSelectmsgChargeAction:(BOOL)ret {
    NSString *str = @"Y";
    if (ret) {
        str = @"N";
    }
    [_dataDict setObject:str forKey:@"msg_charge"];
    
    [_userVM updateMySettingWithField:@"msg_charge" andValue:str andBlock:^(NSDictionary *dict, BOOL ret) {
        if (ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyUser *user = [ViewModelCommom getCuttentUser];
                user.msgCharge = str;
                [ViewModelCommom saveUser:user];
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }];
}


- (void)didChangeSlider:(NSString*)text {
    [_dataDict setObject:text forKey:@"allow_talk_period"];

}


- (void)back:(id)sender {
    UserSettingCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    if (_dataDict) {
        [_userVM updateMySettingWithField:@"allow_talk" andValue:[NSString stringWithFormat:@"%d",[_dataDict[@"allow_talk"] intValue]] andBlock:^(NSDictionary *dict, BOOL ret) {
        }];
      
      
        if (![cell.settingView.timeLabel.text isEqualToString:@""]) {
            [_userVM updateMySettingWithField:@"allow_talk_period" andValue:_dataDict[@"allow_talk_period"] andBlock:^(NSDictionary *dict, BOOL ret) {
                
            }];
        }
    }
   
  
    [super back:sender];
}

- (void)cellClick:(UITapGestureRecognizer*)tapGesture {
    EMView *view = (EMView*)[tapGesture view];
    NSInteger tag = view.tag;
    NSArray *desTagArray = @[@2,@3,@4,@5,@6];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.gender isEqualToString:@"F"]){
        desTagArray = @[@3,@4,@5,@6,@7];
    }
    if (tag == [desTagArray[0] integerValue]) {
        AuthorManagerVC *authorManager = [[AuthorManagerVC alloc] init];
        [self.navigationController pushViewController:authorManager animated:YES];
    }else if (tag == [desTagArray[1] integerValue]) {
        LockManagerVC *lockManager = [[LockManagerVC alloc] init];
        [self.navigationController pushViewController:lockManager animated:YES];
    }else if (tag == [desTagArray[2] integerValue]) {
        ChangePwdViewController *changePwdVC = [[ChangePwdViewController alloc] init];
        [self.navigationController pushViewController:changePwdVC animated:YES];
    }else if (tag == [desTagArray[3] integerValue]) {
        CommonQuestionVC *commonQuestVC = [[CommonQuestionVC alloc] init];
        [self.navigationController pushViewController:commonQuestVC animated:YES];
    }else if (tag == [desTagArray[4] integerValue]) {
        EMAlertView *alert = [[EMAlertView alloc] initWithTitle:Local(@"Warning") message:Local(@"SureDeleteUser") clickedBlock:^(EMAlertView *alertView, BOOL cancelled, NSInteger buttonIndex){
            if (!cancelled) {
                [_userVM deleteSelfWithBlock:^(NSDictionary *dict, BOOL ret) {
                    if (dict && ret) {
                        if ([dict[@"code"] intValue] == 1) {
                              [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                            for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
                                if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LoginViewController"]) {
                                    LoginViewController *loginVC = self.navigationController.viewControllers[i];
                                    [loginVC setDefaultInfo];
                                    loginVC.isHiddenAnimation = YES;
                                    
                                    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
                                    loginStatus.isLogined = NO;
                                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                        [[(AppDelegate*)[[UIApplication sharedApplication] delegate ] callViewController] offLineAction];
                                    });
                                    [[FileAccessData sharedInstance] setAObject:loginStatus forEMKey:@"LoginStatus"];
                                    [self.navigationController popToViewController:loginVC animated:YES];
                                    break;
                                }
                            }
                        }else {
                            [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                        }
                    }else{
                         [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                    }
                }];
            }
        }
                                              cancelButtonTitle:Local(@"Cancel")otherButtonTitles:Local(@"Sure"), nil];
        [alert show];
    }else {
        UIImageView *imageView = [view viewWithTag:101];
        imageView.hidden = YES;
        NSString *str = [_cellStatusDictory objectForKey:[NSString stringWithFormat:@"%d",(int)tag]];
        if ([str isEqualToString:@"0"]) {
            [_cellStatusDictory setObject:@"1" forKey:[NSString stringWithFormat:@"%d",(int)tag]];
        }else {
            [_cellStatusDictory setObject:@"0" forKey:[NSString stringWithFormat:@"%d",(int)tag]];
        }
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:tag] withRowAnimation:UITableViewRowAnimationNone];
    }
}




@end
