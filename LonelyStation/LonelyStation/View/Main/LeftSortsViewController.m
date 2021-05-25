//
//  LeftSortsViewController.m
//  LGDeckViewController
//
//  Created by jamie on 15/3/31.
//  Copyright (c) 2015年 Jamie-Ling. All rights reserved.
//

#import "LeftSortsViewController.h"
#define HeaderHight 238 * kScale
#define FooterHight 88 * kScale
#import "LoginViewController.h"
#import "EMAlertView.h"
#import "LoginStatusObj.h"
#import "ViewModelCommom.h"
#import "UICycleImgView.h"
#import "UIUtil.h"
#import "AddMoneyMainVC.h"
#import "MyVoicesVC.h"
#import "MyInfoVC.h"
#import "NotifyVC.h"
#import "AppDelegate.h"
#import "UserSettingViewModel.h"
#import "InComeDetailVC.h"
#import "MainViewVM.h"
#import "RCDCustomerServiceViewController.h"
#import "RegisterViewController.h"

@interface LeftSortsViewController () <UITableViewDelegate,UITableViewDataSource> {
    NSArray *_cellInfoArray;
    NSArray *_cellImgNameArray;
    NSArray *_selectCellArray;
    UIImageView *_alarmView;
    
    EMLabel *_nameLabel;
    
    UserSettingViewModel *_userSetting;
    ProfitObj *_profit;
    EMButton *_getMoneyBtn;
    EMButton *_addMoneyBtn;
    UIView *_collectBackView;
    MainViewVM *_mainViewVM;
}

//新UI
@property(nonatomic,strong) UIImageView *headerImageView;
@property(nonatomic,strong) EMLabel *nameLabel;
@property(nonatomic,strong) EMLabel *leftCoinLabel;

@property(nonatomic,strong) UITableView *infoTableView;
//@property(nonatomic,strong)




@end

@implementation LeftSortsViewController

- (UIImageView*)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [UIImageView new];
        [self.view addSubview:_headerImageView];
        [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(59*kScale);
            make.centerX.equalTo(self.view.mas_centerX).multipliedBy(0.8);
            make.size.mas_equalTo(Size(55*kScale, 55*kScale));
        }];
    }
    return _headerImageView;
}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    imageview.image = [UIImage imageNamed:@"leftbackiamge"];
//    imageview.backgroundColor = RGB(54, 79, 135);
//    [self.view addSubview:imageview];
    self.view.backgroundColor = RGB(228,228,228);
    self.fd_interactivePopDisabled = YES;
    _userSetting = [[UserSettingViewModel alloc] init];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined) {
        _cellInfoArray = @[Local(@"PersonalInfo"),Local(@"VoiceHistory"),Local(@"Setting"),Local(@"FeedBack"),Local(@"Logout")];
        _cellImgNameArray = @[@"center_information",@"center_call",@"center_set",@"center_contact",@"center_sign_out"];

        _selectCellArray = @[@"MyInfoVC",@"CallRecordVC",@"UserSettingVC",@"RCDCustomerServiceViewController",@"Logout"];
        UITableView *tableview = [[UITableView alloc] init];
        [self.view addSubview:tableview];
        self.tableview = tableview;
        self.tableview.frame = Rect(0, 0, kScreenW*0.8, kScreenH- 74*kScale);
        tableview.dataSource = self;
        tableview.delegate  = self;
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;

//        UIImageView *footView = [[UIImageView alloc] initWithFrame:Rect(0, kScreenH- 74*kScale, kScreenW*0.8, 74*kScale)];
//        footView.image = [UIImage imageNamed:@"center_illustration"];
//        [self.view addSubview:footView];
        if(!IsIPhone4){
            tableview.scrollEnabled = NO;
        }
        
//        self.headerImageView.hidden = NO;
        _mainViewVM = [[MainViewVM alloc] init];
        
        
    }else {
        CGFloat width = 84;
        CGFloat x = 100*kScale;
        CGFloat y = 132*kScale;
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:Rect(x, y, width, width)];
        if ([loginStatus.gender isEqualToString:@"M"]) {
            [headImageView setImage:[UIImage imageNamed:@"gender_M"]];
        }else{
            [headImageView setImage:[UIImage imageNamed:@"gender_F"]];
        }
        [self.view addSubview:headImageView];
        
        x = 34;
        y += 68 + width;
        
        EMButton *loginBtn = [UIUtil createPurpleBtnWithFrame:Rect(x, y, 223*kScale, 40) andTitle:Local(@"IWANTLOGIN") andSelector:@selector(IWantLogin:) andTarget:self];
//        [loginBtn setBackgroundImage:[UIUtil imageWithColor:RGBA(0xff, 0xff, 0xff, 0.14) andSize:loginBtn.frame.size] forState:UIControlStateNormal];
        [self.view addSubview:loginBtn];
        
        y += 68;
        EMButton *registerBtn = [UIUtil createPurpleBtnWithFrame:Rect(x, y, 223*kScale, 40) andTitle:Local(@"IWANTREGISTER") andSelector:@selector(IWantRegister:) andTarget:self];
//        [registerBtn setBackgroundImage:[UIUtil imageWithColor:RGBA(0xff, 0xff, 0xff, 0.14) andSize:loginBtn.frame.size] forState:UIControlStateNormal];
        [self.view addSubview:registerBtn];
    }
}


- (void)IWantLogin:(EMButton*)btn {
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LoginViewController"]) {
            LoginViewController *loginVC = self.navigationController.viewControllers[i];
            [loginVC setDefaultInfo];
            loginVC.isHiddenAnimation = YES;
            
            LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
            loginStatus.isLogined = NO;
            [[FileAccessData sharedInstance] setAObject:loginStatus forEMKey:@"LoginStatus"];
            [self.navigationController popToViewController:loginVC animated:YES];
            break;
        }
    }
}

- (void)IWantRegister:(EMButton*)btn {
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LoginViewController"]) {
            LoginViewController *loginVC = self.navigationController.viewControllers[i];
            [loginVC setDefaultInfo];
            loginVC.isHiddenAnimation = YES;
            [loginVC scrollRight];
            
            LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
            loginStatus.isLogined = NO;
            [[FileAccessData sharedInstance] setAObject:loginStatus forEMKey:@"LoginStatus"];
            [self.navigationController popToViewController:loginVC animated:YES];
            break;
        }
    }

}

- (void)chageAddBtn {
    CGFloat x = 29*kScale;
    CGFloat y = 20+132*kScale;
    CGFloat width = 200*kScale;
    CGFloat height = 35*kScale;
    x = (self.tableview.bounds.size.width - width)/2.f;
    _addMoneyBtn.frame = Rect(x, y, width, height);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setCollect:@"0.00" andStationCollect:@"0.00" andGiftCollect:@"0.00" andMsgCollect:@"0.00"];
    WS(weakSelf)
    [_userSetting getMyProfitWithBlock:^(ProfitObj *profit, BOOL ret) {
        SS(weakSelf, strongSelf)
        if (profit && ret){
            _profit = nil;
            _profit = profit;
            [[FileAccessData sharedInstance] setMemObject:profit forKey:@"profit"];

            [strongSelf setCollect:profit.talk andStationCollect:profit.radio andGiftCollect:profit.gift andMsgCollect:profit.message];
        }
        [self.tableview reloadData];
    }];
    if (_mainViewVM) {
        [_mainViewVM  getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
            if (ret) {
                LonelyUser *user = [ViewModelCommom getCuttentUser];
                user.chat_point = dict[@"data"][@"chat_point"];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                _leftCoinLabel.text = [NSString stringWithFormat:@"%@:%@",Local(@"LeftCoin"),user.chat_point];
            }
        }];

    }
    
    [[FileAccessData sharedInstance] setAObject:@"0" forEMKey:@"isChecking"];

    [self.tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        //图片
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:Rect(75 * kScale, 8*kScale, 30*kScale, 30*kScale)];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
        //标题
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:Rect(129 * kScale, 8 * kScale, 90 * kScale, 30 * kScale)];
        infoLabel.tag = 101;
        infoLabel.font = [UIFont systemFontOfSize:20.0f * kScale];
        infoLabel.textColor = RGB(51, 51, 51);
        [cell.contentView addSubview:infoLabel];
        
        
        //指示文字
        EMLabel *bridgeLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(infoLabel), 8 * kScale, 20 * kScale, 20 * kScale) andConners:20*kScale/2];
        bridgeLabel.tag = 102;
        bridgeLabel.font = [UIFont systemFontOfSize:12.f * kScale];
        bridgeLabel.textColor = [UIColor whiteColor];
        bridgeLabel.textAlignment = NSTextAlignmentCenter;
        bridgeLabel.backgroundColor = RGB(178,0,0);
        [cell.contentView addSubview:bridgeLabel];
        bridgeLabel.hidden = YES;
        //预留设置选择背景view
//        UIView *selectView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
//        selectView.backgroundColor = [UIColor clearColor];
//        cell.selectedBackgroundView = selectView;

    }
    
    UIImageView *imageView = [cell.contentView viewWithTag:100];
    imageView.image = [UIImage imageNamed:_cellImgNameArray[indexPath.row]];
    UILabel *infoLabel = [cell.contentView viewWithTag:101];
    infoLabel.text = _cellInfoArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    EMLabel *bridgeLabel = [cell.contentView viewWithTag:102];
    if (indexPath.row == 0) {
        int nums = [_profit.listenMeNums intValue] + [_profit.favoriteMeNums intValue] + [_profit.giftNums intValue];
        if (nums>0) {
            bridgeLabel.hidden = NO;
            bridgeLabel.text = [NSString stringWithFormat:@"%d",nums];
            CGFloat width = bridgeLabel.text.length * 15 * kScale;
            bridgeLabel.frame = Rect(PositionX(infoLabel) - 5, 15 * kScale, width, 15 * kScale);
        }else {
            bridgeLabel.hidden = YES;
        }
    }
//    if (indexPath.row == 2) {
//        if ([_profit.favoriteMeNums intValue]>0) {
//            bridgeLabel.hidden = NO;
//            bridgeLabel.text = [NSString stringWithFormat:@"%d",[_profit.favoriteMeNums intValue]];
//            CGFloat width = bridgeLabel.text.length * 15 * kScale;
//            bridgeLabel.frame = Rect(PositionX(infoLabel) - 5, 15 * kScale, width, 15 * kScale);
//        }else {
//            bridgeLabel.hidden = YES;
//
//        }
//    }
//    if (indexPath.row == 5) {
//        if ([_profit.giftNums intValue]>0) {
//            bridgeLabel.hidden = NO;
//            bridgeLabel.text = [NSString stringWithFormat:@"%d",[_profit.giftNums intValue]];
//            CGFloat width = bridgeLabel.text.length * 15 * kScale;
//            bridgeLabel.frame = Rect(PositionX(infoLabel) - 5, 16 * kScale, width, 15 * kScale);
//        }else {
//            bridgeLabel.hidden = YES;
//
//        }
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f * kScale;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *cla = _selectCellArray[indexPath.row];
    if([cla isEqualToString:@"Logout"]){
        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"MakeSureLogout") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                //登出
                for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
                    if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LoginViewController"]) {
                        LoginViewController *loginVC = self.navigationController.viewControllers[i];
                        [loginVC setDefaultInfo];
                        loginVC.isHiddenAnimation = YES;
                        
                        LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
                        loginStatus.isLogined = NO;
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            [[(AppDelegate*)[[UIApplication sharedApplication] delegate ] callViewController] offLineAction];
                            [[RCIM sharedRCIM] disconnect:NO];
                        });
                        [[FileAccessData sharedInstance] setAObject:loginStatus forEMKey:@"LoginStatus"];
                        [self.navigationController popToViewController:loginVC animated:YES];
                        break;
                    }
                }
            }
        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
        [alert show];
    }else if (![cla isEqualToString:@""]) {
        if ([cla isEqualToString:@"RCDCustomerServiceViewController"]){
            if ([UIUtil alertProfileWarning:self andMsg:Local(@"YOUMUSTCOMPLETEINFO")]) {
                return;
            }
            RCDCustomerServiceViewController *controller =  [[RCDCustomerServiceViewController alloc] init];
            controller.conversationType = ConversationType_CUSTOMERSERVICE;
            controller.targetId = @"KEFU147783196148332";
            [self.navigationController pushViewController:controller animated:YES];

        }else{
            if ([cla isEqualToString:@"WhoListenedMeVC"] || [cla isEqualToString:@"WhoCareMeVC"]|| [cla isEqualToString:@"MyGiftsVC"]) {
                if ([UIUtil alertProfileWarning:self andMsg:Local(@"YOUMUSTCOMPLETEINFO")]) {
                    return;
                }
            }
            UIViewController *controller =  [[NSClassFromString(cla) alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }

    }
    
//    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    otherViewController *vc = [[otherViewController alloc] init];
//    [tempAppDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
//    
//    [tempAppDelegate.mainNavGate pushViewController:vc animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    NSString *str = [[[FileAccessData sharedInstance] objectForEMKey:@"isChecking"] lastObject];
//    if ([str isEqualToString:@"1"]) {
//        CGFloat height = HeaderHight-67*kScale+20;
//        return height;
//    }
    return HeaderHight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FooterHight;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth*0.8, FooterHight)];
    EMButton *btn = [[EMButton alloc] initWithFrame:Rect(0, FooterHight - 41*kScale, 101*kScale, 41*kScale)];
    [view addSubview:btn];
    btn.center = Point(view.center.x, view.center.y);
    btn.layer.borderColor = RGB(145,90,173).CGColor;
    btn.layer.borderWidth = 1;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 20*kScale;
    btn.backgroundColor = RGB(209,172,255);
    [btn setTitle:Local(@"AddMoney") forState:UIControlStateNormal];
    btn.titleLabel.font = ComFont(14);
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [btn setTitleColor:RGB(145,90,173) forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"recharge"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addMoneyAction:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth*0.8, HeaderHight)];
    view.backgroundColor = [UIColor clearColor];
    UICycleImgView *headImageView = [[UICycleImgView alloc] initWithFrame:Rect(kScreenW*0.4-27*kScale, 59 * kScale + StatusBarHeight, 55*kScale, 55*kScale)];
    [view addSubview:headImageView];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [headImageView yy_setImageWithURL:[NSURL URLWithString:user.file] placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:user.gender]]];
    if (!_nameLabel){
        _nameLabel = [EMLabel new];
    }
    _nameLabel.frame = Rect(100*kScale, PositionY(headImageView)+13*kScale, kScreenW*0.8-200*kScale, 20*kScale);
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.font = ComFont(18*kScale);
    _nameLabel.textColor = RGB(51, 51, 51);
    [view addSubview:_nameLabel];
    if (!_currentCollect) {
        _currentCollect = [[EMLabel alloc] initWithFrame:Rect(60*kScale, PositionY(headImageView)+50*kScale, 184*kScale, 36*kScale)];
    }
    _currentCollect.font = ComFont(16*kScale);
    _currentCollect.textColor = RGB(0xff, 0xff, 0xff);
    [view addSubview:_currentCollect];
    [_currentCollect setText:[NSString stringWithFormat:@"%@ %d%@",Local(@"CurrentCollect"),[_profit.total intValue],Local(@"ChatMoney")]];
    [_currentCollect.layer setBorderColor:RGB(255,255,255).CGColor];
    [_currentCollect.layer setBorderWidth:3];
    [_currentCollect.layer setBackgroundColor:RGB(209,172,255).CGColor];
    [_currentCollect.layer setCornerRadius:18*kScale];
    [_currentCollect.layer setMasksToBounds:YES];
    _currentCollect.textAlignment = NSTextAlignmentCenter;
    
    _alarmView = [[UIImageView alloc] initWithFrame:Rect(tableView.bounds.size.width - 65*kScale, 30, 32*kScale, 20*kScale)];
    _leftCoinLabel = [[EMLabel alloc] initWithFrame:Rect(20*kScale, 20, 150 * kScale, 32*kScale)];
    _leftCoinLabel.textColor = RGB(145,90,173);
    _leftCoinLabel.font = ComFont(16*kScale);
    _leftCoinLabel.text = [NSString stringWithFormat:@"%@:%@",Local(@"LeftCoin"),user.chat_point];
    [view addSubview:_leftCoinLabel];
    
    _alarmView.image = [UIImage imageNamed:@"center_circular"];
    [view addSubview:_alarmView];
    
    _alarmView.userInteractionEnabled = YES;
    UITapGestureRecognizer *alarmTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notifyAction)];
    [_alarmView addGestureRecognizer:alarmTapGesture];
    
    //报警的label
    if (!_alarmLabel) {
        _alarmLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_alarmView)-20*kScale, _alarmView.frame.origin.y-8*kScale, 30, 16*kScale)];
    }
    [view addSubview:_alarmLabel];

    _alarmLabel.backgroundColor = RGB(255,252,0);
    _alarmLabel.layer.cornerRadius = 8*kScale;
    _alarmLabel.layer.masksToBounds = YES;
    _alarmLabel.textColor = RGB(3,41,172);
    _alarmLabel.text = user.unread;
    _alarmLabel.textAlignment = NSTextAlignmentCenter;
    _alarmLabel.font = ComFont(10);
    _alarmLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notifyAction)];
    [_alarmLabel addGestureRecognizer:tapGesture];
//    CGFloat x = 41*kScale;
    CGFloat y = 20+70*kScale;
//    CGFloat width = 30*kScale;
    CGFloat height = 15*kScale;
    
    if (!_collectBackView) {
        _collectBackView = [[UIView alloc] initWithFrame:Rect(0, y, tableView.bounds.size.width, height*2+7*kScale)];
    }
    [view addSubview:_collectBackView];
//    y = 0;
//
//    NSArray *textArray = @[Local(@"Chat"),Local(@"Station"),Local(@"SendGift"),Local(@"MSG")];
//
//    if (!_chatCollect) {
//        _chatCollect = [[EMLabel alloc] init];
//    }
//    if (!_stationCollect) {
//        _stationCollect = [[EMLabel alloc] init];
//    }
//    if (!_giftCollect) {
//        _giftCollect = [[EMLabel alloc] init];
//    }
//    if (!_msgCollect) {
//        _msgCollect = [[EMLabel alloc] init];
//    }
//    NSArray *labelArray = @[_chatCollect,_stationCollect,_giftCollect,_msgCollect];
//    if([user.gender isEqualToString:@"M"]){
//        textArray = @[Local(@"Station"),Local(@"SendGift")];
//        labelArray = @[_stationCollect,_giftCollect];
//        x = 90*kScale;
//    }
//
//    for (int i = 0; i < textArray.count; i++) {
//        EMLabel *aLabel = [[EMLabel alloc] initWithFrame:Rect(x, y, width, height)];
//        aLabel.font = ComFont(14*kScale);
//        aLabel.text = textArray[i];
//        aLabel.textColor = RGB(255,255,255);
//        [_collectBackView addSubview:aLabel];
//        EMView *line = [[EMView alloc] initWithFrame:Rect(x - 10*kScale, PositionY(aLabel) + 6*kScale, 47*kScale, 1)];
//        line.backgroundColor = RGB(255,255,255);
//        [_collectBackView addSubview:line];
//
//        EMLabel *valueLable = labelArray[i];
//        valueLable.frame = Rect(x - 8, PositionY(line)+7*kScale, 80*kScale, height);
//        valueLable.textColor = RGB(255,252,0);
//        valueLable.font = ComFont(14*kScale);
////        valueLable.textAlignment = NSTextAlignmentCenter;
//        [_collectBackView addSubview:valueLable];
//        if(textArray.count == 2){
//            x += width + 66 * kScale;
//        }else {
//            x += width + 33*kScale;
//        }
//    }
    
    //提领
//    UIImage *btnImage = [UIImage imageNamed:@"center_button"];
//    btnImage = [btnImage stretchableImageWithLeftCapWidth:floorf(btnImage.size.width/2) topCapHeight:floorf(btnImage.size.height/2)];
//    UIImage *btnImageSelect = [UIImage imageNamed:@"center_button_d"];
//    btnImageSelect = [btnImageSelect stretchableImageWithLeftCapWidth:floorf(btnImageSelect.size.width/2) topCapHeight:floorf(btnImageSelect.size.height/2)];
//    //加值
//    x = 27*kScale;
//    _addMoneyBtn = [UIUtil buttonWithName:Local(@"AddMoney") andFrame:Rect(x, y, width, height) andSelector:@selector(addMoneyAction:) andTarget:self isEnable:YES];
//    [_addMoneyBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
//    [_addMoneyBtn setBackgroundImage:btnImageSelect forState:UIControlStateHighlighted];
//    [_addMoneyBtn setImage:[UIImage imageNamed:@"center_bonus"] forState:UIControlStateNormal];
//    _addMoneyBtn.titleLabel.font = ComFont(15*kScale);
//    [_addMoneyBtn setTitleColor:RGB(3,41,172)
//                      forState:UIControlStateNormal];
//    [_addMoneyBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
//    [view addSubview:_addMoneyBtn];
//    [self chageAddBtn];
    return view;
}





- (void)notifyAction {
    NotifyVC *notifyVC = [[NotifyVC alloc] init];
    [self.navigationController pushViewController:notifyVC animated:YES];
}

- (void)getMoneyAction:(EMButton*)btn {
    if ([UIUtil alertProfileWarning:self andMsg:Local(@"YOUMUSTCOMPLETEINFO")]) {
        return;
    }
    InComeDetailVC *getMoneyVC = [[InComeDetailVC alloc] init];
    [self.navigationController pushViewController:getMoneyVC animated:YES];
}

- (void)addMoneyAction:(EMButton*)btn {
    AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
    [self.navigationController pushViewController:addMoneyMainVC animated:YES];
}

-(void)setCollect:(NSString*)chatCollect andStationCollect:(NSString*)stationCollect andGiftCollect:(NSString*)giftCollect andMsgCollect:(NSString*)msgCollect {
    _chatCollect.text = [NSString stringWithFormat:@"$%.2f",chatCollect.floatValue];
    _stationCollect.text = [NSString stringWithFormat:@"$%.2f",stationCollect.floatValue];
    _giftCollect.text = [NSString stringWithFormat:@"$%.2f",giftCollect.floatValue];
    _msgCollect.text = [NSString stringWithFormat:@"$%ld",msgCollect.integerValue];
    _nameLabel.text = [ViewModelCommom getCuttentUser].nickName;
}



-(EMLabel*)labelWithFrame:(CGRect)rect andSpace:(CGFloat)space andText:(NSString*)str{
    NSString * cLabelString = str;
    EMLabel * cLabel = [[EMLabel alloc]initWithFrame:rect];
    cLabel.numberOfLines = 0;
    cLabel.font = ComFont(14*kScale);
    cLabel.textColor = RGB(0xff,0xff,0xff);
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:cLabelString];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:space];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [cLabelString length])];
    [cLabel setAttributedText:attributedString1];
    [cLabel sizeToFit];
    return cLabel;
}
@end
