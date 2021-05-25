//
//  InComeDetailVC.m
//  LonelyStation
//
//  Created by zk on 2016/12/5.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "InComeDetailVC.h"
#import "UIUtil.h"
#import "LonelyUser.h"
#import "ViewModelCommom.h"
#import "UserSettingViewModel.h"
#import "GetIncomeStepVC.h"
#import "SettingGetFeeVC.h"
#import "LookFeeWebVC.h"
#import "GetFeeRecordsVC.h"
#import "ChangeFeeVC.h"
#import "EMWebViewController.h"
#import "WYPopoverController.h"

@interface InComeDetailVC ()<WYPopoverControllerDelegate>{
    UserSettingViewModel *_settingViewMode;
    
}

@property(nonatomic,strong)EMLabel *allCountLabel;

@property(nonatomic,strong)EMButton *viewFeeBtn;

@property(nonatomic,strong)EMLabel *todayFee;

@property(nonatomic,strong)EMLabel *currMonthFee;

@property(nonatomic,strong)EMLabel *notGetFee;

@property(nonatomic,strong)EMButton *getFeeBtn;

@property(nonatomic,strong)EMButton *getFeeHisBtn;

@property(nonatomic,strong)EMLabel *canGetFeeLabel;

@property(nonatomic,strong)EMLabel *waiteGetFeeLabel;

@property(nonatomic,strong)EMLabel *talkLabel;

@property(nonatomic,strong)EMLabel *stationLabel;

@property(nonatomic,strong)EMLabel *inifitChatLabel;


@property(nonatomic,strong)NSString *withDrawFeeURL;

@property(nonatomic,copy)NSString *withDrawSetURL;

@property(nonatomic,strong)NSString *content;

@property(nonatomic,strong)NSString *subject;

@property(nonatomic,strong)NSDictionary *withDarwDict;

@property(nonatomic,assign)float canDrawFee;

@property(nonatomic,copy)NSString *chatProfitStr;

@property(nonatomic,copy)NSString *msgProfitStr;

@property(nonatomic,copy)NSString *boardCastStr;

@property(nonatomic,copy)NSString *giftStr;

@property(nonatomic,strong)EMLabel *chatLabel;

@property(nonatomic,strong)EMLabel *msgLabel;

@property(nonatomic,strong)EMLabel *boardCastLabel;

@property(nonatomic,strong)EMLabel *giftLabel;




@property (nonatomic,strong)WYPopoverController *popoverController;

@end

@implementation InComeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"InComeDetail")];
    [self initViews];
    _settingViewMode = [[UserSettingViewModel alloc] init];
    
    
    // Do any additional setup after loading the view.
}


- (void)request {
    [UIUtil showHUD:self.view];
    WS(weakSelf);
    [_settingViewMode getMyProfitDetailWithBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            weakSelf.allCountLabel.text = [NSString stringWithFormat:@"$ %.2f USD",[dict[@"profit_history"] floatValue]];
            weakSelf.todayFee.text = [NSString stringWithFormat:@"$ %.2f",[dict[@"profit_today"] floatValue]];
            weakSelf.currMonthFee.text = [NSString stringWithFormat:@"$ %.2f",[dict[@"profit_thismonth"] floatValue]];
            weakSelf.notGetFee.text = [NSString stringWithFormat:@"$ %.2f",[dict[@"profit_available_withdraw"] floatValue]];
            weakSelf.canGetFeeLabel.text = [NSString stringWithFormat:@"%.2f USD",[dict[@"profit_available_withdraw"] floatValue]];
            weakSelf.waiteGetFeeLabel.text = [NSString stringWithFormat:@"%.2f USD",[dict[@"profit_waiting_for_withdraw"] floatValue]];
            weakSelf.canDrawFee =[dict[@"profit_available_withdraw"] floatValue];
            if (dict[@"withdraw_manual"] && [dict[@"withdraw_manual"] isKindOfClass:[NSDictionary class]]) {
                weakSelf.subject = dict[@"withdraw_manual"][@"subject"];
                weakSelf.content = dict[@"withdraw_manual"][@"content"];
            }
            weakSelf.withDrawFeeURL = dict[@"withdraw_fee_url"];
            weakSelf.withDarwDict = dict[@"withdraw"];
            weakSelf.withDrawSetURL = dict[@"withdraw_setup_url"];
            if (weakSelf.withDarwDict && ![weakSelf.withDarwDict isEqual:[NSNull null]]) {
                    [weakSelf.getFeeBtn setTitle:[NSString stringWithFormat:@"%@%@",Local(@"YouSettingAccount"),weakSelf.withDarwDict[@"current"]] forState:UIControlStateNormal];
            }
            LonelyUser *user = [ViewModelCommom getCuttentUser];
            weakSelf.talkLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"TalkLeft"),user.talkSecond,Local(@"Seconds")];
            weakSelf.stationLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"RadioLeft"),user.radioSecond,Local(@"Seconds")];
            weakSelf.inifitChatLabel.text = [EMUtil getInitfiString];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self request];
}

- (void)initViews {
    EMTableView *tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor clearColor];
    EMView *backView = [[EMView alloc] initWithFrame:Rect(0, 0, kScreenW, kScreenH - 64)];
    backView.backgroundColor = [UIColor clearColor];
    //历史金额
    _allCountLabel = [[EMLabel alloc] initWithFrame:Rect(0, 0, kScreenW , 34*kScale)];
    _allCountLabel.textColor = RGB(255,252,0);
    _allCountLabel.font = ComFont(15*kScale);
    _allCountLabel.textAlignment = NSTextAlignmentCenter;
    _allCountLabel.backgroundColor = RGBA(0, 0, 0, 0.3);
    [backView addSubview:_allCountLabel];
 
    //查看汇率
    _viewFeeBtn = [[EMButton alloc] initWithFrame:Rect(0, PositionY(_allCountLabel), kScreenW, 32*kScale)];
    [_viewFeeBtn setTitle:Local(@"ViewTransfer") forState:UIControlStateNormal];
    [_viewFeeBtn setTitleColor:RGB(235,173,255) forState:UIControlStateNormal];
    [_viewFeeBtn.titleLabel setFont:ComFont(13*kScale)];
    [_viewFeeBtn addTarget:self action:@selector(viewFeeAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_viewFeeBtn];
    //线
    [UIUtil addLineWithSuperView:backView andRect:Rect(0, PositionY(_viewFeeBtn), kScreenW, 1)];
    
    EMButton *todayButton = [[EMButton alloc] initWithFrame:Rect(0, PositionY(_viewFeeBtn), kScreenW , 34*kScale)];
    [todayButton addTarget:self action:@selector(todayProfitAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:todayButton];
    //今日收益
    EMLabel *todayLabel = [[EMLabel alloc] initWithFrame:Rect(12*kScale, PositionY(_viewFeeBtn), 100 , 34*kScale)];
    todayLabel.textColor = RGB(255,255,255);
    todayLabel.font = ComFont(14*kScale);
    todayLabel.text = Local(@"InComeToday");
    [backView addSubview:todayLabel];
    
    _todayFee = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 100 - 12*kScale, PositionY(_viewFeeBtn), 100 , 34*kScale)];
    _todayFee.textColor = RGB(255,252,0);
    _todayFee.font = ComFont(14*kScale);
    _todayFee.textAlignment = NSTextAlignmentRight;
    [backView addSubview:_todayFee];
    
    [UIUtil addLineWithSuperView:backView andRect:Rect(0, PositionY(_todayFee), kScreenW, 1)];

    
    EMButton *monthButton = [[EMButton alloc] initWithFrame:Rect(0, PositionY(_todayFee), kScreenW , 34*kScale)];
    [monthButton addTarget:self action:@selector(monthProfitAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:monthButton];
    //当月收益
    EMLabel *monthLabel = [[EMLabel alloc] initWithFrame:Rect(12*kScale, PositionY(_todayFee), 100 , 34*kScale)];
    monthLabel.textColor = RGB(255,255,255);
    monthLabel.font = ComFont(14*kScale);
    monthLabel.text = Local(@"InComeCurrentMonth");
    [backView addSubview:monthLabel];
    
    _currMonthFee = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 100 - 12*kScale, PositionY(_todayFee), 100 , 34*kScale)];
    _currMonthFee.textColor = RGB(255,252,0);
    _currMonthFee.font = ComFont(14*kScale);
    _currMonthFee.textAlignment = NSTextAlignmentRight;
    [backView addSubview:_currMonthFee];
    
    [UIUtil addLineWithSuperView:backView andRect:Rect(0, PositionY(_currMonthFee), kScreenW, 1)];

    
    //未领收益
    EMLabel *notGetLabel = [[EMLabel alloc] initWithFrame:Rect(12*kScale, PositionY(_currMonthFee), 100 , 34*kScale)];
    notGetLabel.textColor = RGB(255,255,255);
    notGetLabel.font = ComFont(14*kScale);
    notGetLabel.text = Local(@"NotGetFee");
    [backView addSubview:notGetLabel];
    
    _notGetFee = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 100 - 12*kScale, PositionY(_currMonthFee), 100 , 34*kScale)];
    _notGetFee.textColor = RGB(255,252,0);
    _notGetFee.font = ComFont(14*kScale);
    _notGetFee.textAlignment = NSTextAlignmentRight;
    [backView addSubview:_notGetFee];
    
    //设置提领账户
    _getFeeBtn = [[EMButton alloc] initWithFrame:Rect(0, PositionY(_notGetFee), kScreenW, 32*kScale)];
    [_getFeeBtn setTitle:Local(@"NotSetGetAccount") forState:UIControlStateNormal];
    [_getFeeBtn setTitleColor:RGB(0xff,0xff,0xff) forState:UIControlStateNormal];
    [_getFeeBtn setBackgroundColor:RGBA(0, 0, 0, 0.3)];
    [_getFeeBtn.titleLabel setFont:ComFont(13*kScale)];
    [_getFeeBtn addTarget:self action:@selector(setFeeAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_getFeeBtn];
    
    //领取记录
    _getFeeHisBtn = [[EMButton alloc] initWithFrame:Rect(12*kScale, PositionY(_getFeeBtn), kScreenW - 12*kScale, 32*kScale)];
    [_getFeeHisBtn setTitle:Local(@"GetFeeRecord") forState:UIControlStateNormal];
    _getFeeHisBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_getFeeHisBtn setTitleColor:RGB(0xff,0xff,0xff) forState:UIControlStateNormal];
    [_getFeeHisBtn.titleLabel setFont:ComFont(13*kScale)];
    [_getFeeHisBtn addTarget:self action:@selector(getFeeHisAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_getFeeHisBtn];
    
    //可提现金额和今日可提现金额
    EMView *canDrawBackView = [[EMView alloc] initWithFrame:Rect(0, PositionY(_getFeeHisBtn), kScreenW, 198*kScale)];
    canDrawBackView.backgroundColor = RGBA(0, 0, 0, 0.3);
    [backView addSubview:canDrawBackView];
    
    //可提现金额Label
    EMLabel *canDrawLabel = [[EMLabel alloc] initWithFrame:Rect(54*kScale, PositionY(_getFeeHisBtn) + 29*kScale,  80*kScale, 14*kScale)];
    canDrawLabel.textColor = RGB(255,252,0);
    canDrawLabel.font = ComFont(13*kScale);
    canDrawLabel.text = Local(@"CanGetMoney");
    [backView addSubview:canDrawLabel];
    
    //可提现金额
    _canGetFeeLabel = [[EMLabel alloc] initWithFrame:Rect(47*kScale, PositionY(canDrawLabel)+20*kScale, 80*kScale, 17*kScale)];
    _canGetFeeLabel.textColor = RGB(255,252,0);
    _canGetFeeLabel.font = ComFont(16*kScale);
    _canGetFeeLabel.text = @"0.00 USD";
    [backView addSubview:_canGetFeeLabel];
    
    //待收款金额Label
    EMLabel *waiteDrawLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 54*kScale - 80*kScale, PositionY(_getFeeHisBtn) +29*kScale, 80*kScale, 14*kScale)];
    waiteDrawLabel.textColor = RGB(255,252,0);
    waiteDrawLabel.font = ComFont(13*kScale);
    waiteDrawLabel.text = Local(@"TodayCanGetMoney");
    [backView addSubview:waiteDrawLabel];
    
    //待收款金额
    _waiteGetFeeLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 47*kScale - 80*kScale, PositionY(waiteDrawLabel)+20*kScale, 80*kScale, 17*kScale)];
    _waiteGetFeeLabel.textColor = RGB(255,252,0);
    _waiteGetFeeLabel.font = ComFont(16*kScale);
    _waiteGetFeeLabel.text = @"0.00 USD";
    [backView addSubview:_waiteGetFeeLabel];
    
    //提领
    EMButton *withDrawBtn = [[EMButton alloc] initWithFrame:Rect(75*kScale, PositionY(_waiteGetFeeLabel) + 10*kScale, kScreenW - 150*kScale, 40*kScale)];
    withDrawBtn.layer.cornerRadius = 20*kScale;
    withDrawBtn.layer.borderColor = [RGB(255,255,255) CGColor];
    withDrawBtn.layer.borderWidth = 1;
    withDrawBtn.layer.masksToBounds = YES;
    [withDrawBtn setTitle:Local(@"WithDraw") forState:UIControlStateNormal];
    [withDrawBtn addTarget:self action:@selector(withDrawAction:) forControlEvents:UIControlEventTouchUpInside];
    [withDrawBtn setTitleColor:RGB(255,252,0) forState:UIControlStateNormal];
    [withDrawBtn.titleLabel setFont:ComFont(16*kScale)];
    [backView addSubview:withDrawBtn];
    
    //兑换
    EMButton *changeBtn = [[EMButton alloc] initWithFrame:Rect(75*kScale, PositionY(withDrawBtn) + 10*kScale, kScreenW - 150*kScale, 40*kScale)];
    changeBtn.layer.cornerRadius = 20*kScale;
    changeBtn.layer.borderColor = [RGB(255,255,255) CGColor];
    changeBtn.layer.borderWidth = 1;
    changeBtn.layer.masksToBounds = YES;
    [changeBtn setTitle:Local(@"Change") forState:UIControlStateNormal];
    [changeBtn setTitleColor:RGB(255,252,0) forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
    [changeBtn.titleLabel setFont:ComFont(16*kScale)];
    [backView addSubview:changeBtn];
    
    
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    //尚存结余
    EMLabel *cacluLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, PositionY(changeBtn) + 25*kScale, kScreenW - 22*kScale, 15)];
    cacluLabel.text = Local(@"LeftCaclu");
    cacluLabel.font = ComFont(14);
    cacluLabel.textAlignment = NSTextAlignmentCenter;
    cacluLabel.textColor = RGB(0xff, 0xff, 0xff);
    cacluLabel.center = Point(kScreenW/2.f, cacluLabel.center.y);
    [backView addSubview:cacluLabel];
    
    EMView *line1 = [[EMView alloc] initWithFrame:Rect(11*kScale, PositionY(cacluLabel)+2, 56, 1)];
    line1.backgroundColor = RGB(255,255,255);
    line1.center = Point(kScreenW/2.f, line1.center.y);
    [backView addSubview:line1];
    
    _talkLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, PositionY(cacluLabel)+8, kScreenW - 22*kScale, 15)];
    _talkLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"TalkLeft"),user.talkSecond,Local(@"Seconds")];
    _talkLabel.font = ComFont(14);
    _talkLabel.textColor = RGB(255,252,0);
    _talkLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:_talkLabel];
    
    _stationLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, PositionY(_talkLabel)+5, kScreenW - 22*kScale, 15)];
    _stationLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"RadioLeft"),user.radioSecond,Local(@"Seconds")];
    _stationLabel.font = ComFont(14);
    _stationLabel.textColor = RGB(255,252,0);
    _stationLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:_stationLabel];
    
    _inifitChatLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, PositionY(_stationLabel)+5, kScreenW - 22*kScale, 15)];
    _inifitChatLabel.font = ComFont(14);
    _inifitChatLabel.textColor = RGB(255,252,0);
    _inifitChatLabel.textAlignment = NSTextAlignmentCenter;
    _inifitChatLabel.text = [EMUtil getInitfiString];
    [backView addSubview:_inifitChatLabel];

    
    
    [UIUtil addLineWithSuperView:backView andRect:Rect(22*kScale, PositionY(_inifitChatLabel) + 5, kScreenW - 44*kScale, 1)];
    
    EMButton *howtoWithDrawBtn = [[EMButton alloc] initWithFrame:Rect(75*kScale, PositionY(_inifitChatLabel) + 10*kScale, kScreenW - 150*kScale, 20*kScale)];
    [howtoWithDrawBtn setTitle:Local(@"HowToGetFee") forState:UIControlStateNormal];
    [howtoWithDrawBtn setTitleColor:RGB(255,252,0) forState:UIControlStateNormal];
    [howtoWithDrawBtn addTarget:self action:@selector(howToChangeAction:) forControlEvents:UIControlEventTouchUpInside];
    [howtoWithDrawBtn.titleLabel setFont:ComFont(13*kScale)];
    [backView addSubview:howtoWithDrawBtn];
    
    backView.frame = Rect(0, 0, kScreenW, PositionY(howtoWithDrawBtn));
    tableView.tableHeaderView = backView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)showPopView:(UIButton*)sender {
    if (!_popoverController) {
        UIViewController *controller = [[UIViewController alloc] init];
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        if ([user.gender isEqualToString:@"M"]) {
            controller.preferredContentSize = CGSizeMake(200, 100);
            EMLabel *boardCastLabel = [[EMLabel alloc] initWithFrame:Rect(0, 0, 100, 50)];
            boardCastLabel.textAlignment = NSTextAlignmentCenter;
            boardCastLabel.text = Local(@"Station");
            boardCastLabel.textColor  = RGB(255,252,0);
            boardCastLabel.font = ComFont(14*kScale);
            
            _boardCastLabel = [[EMLabel alloc] initWithFrame:Rect(100, 0, 100, 50)];
            _boardCastLabel.textAlignment = NSTextAlignmentCenter;
            _boardCastLabel.text = _boardCastStr;
            _boardCastLabel.textColor  = RGB(255,252,0);
            _boardCastLabel.font = ComFont(14*kScale);
            
            EMLabel *giftLabel = [[EMLabel alloc] initWithFrame:Rect(0, 50, 100, 50)];
            giftLabel.textAlignment = NSTextAlignmentCenter;
            giftLabel.text = Local(@"Gift");
            giftLabel.textColor  = RGB(255,252,0);
            giftLabel.font = ComFont(14*kScale);
            
            _giftLabel = [[EMLabel alloc] initWithFrame:Rect(100, 50, 100, 50)];
            _giftLabel.textAlignment = NSTextAlignmentCenter;
            _giftLabel.text = _giftStr;
            _giftLabel.textColor  = RGB(255,252,0);
            _giftLabel.font = ComFont(14*kScale);
            
            [controller.view addSubview:boardCastLabel];
            [controller.view addSubview:_boardCastLabel];
            [controller.view addSubview:giftLabel];
            [controller.view addSubview:_giftLabel];
        }else {
            controller.preferredContentSize = CGSizeMake(200, 200);
            
            EMLabel *chatLabel = [[EMLabel alloc] initWithFrame:Rect(0, 0, 100, 50)];
            chatLabel.textAlignment = NSTextAlignmentCenter;
            chatLabel.text = Local(@"Chat");
            chatLabel.textColor  = RGB(255,252,0);
            chatLabel.font = ComFont(14*kScale);
            
            _chatLabel = [[EMLabel alloc] initWithFrame:Rect(100, 0, 100, 50)];
            _chatLabel.textAlignment = NSTextAlignmentCenter;
            _chatLabel.text = _chatProfitStr;
            _chatLabel.textColor  = RGB(255,252,0);
            _chatLabel.font = ComFont(14*kScale);
            
            
            EMLabel *msgLabel = [[EMLabel alloc] initWithFrame:Rect(0, 50, 100, 50)];
            msgLabel.textAlignment = NSTextAlignmentCenter;
            msgLabel.text = Local(@"Message");
            msgLabel.textColor  = RGB(255,252,0);
            msgLabel.font = ComFont(14*kScale);
            
            _msgLabel = [[EMLabel alloc] initWithFrame:Rect(100, 50, 100, 50)];
            _msgLabel.textAlignment = NSTextAlignmentCenter;
            _msgLabel.text = _msgProfitStr;
            _msgLabel.textColor  = RGB(255,252,0);
            _msgLabel.font = ComFont(14*kScale);
            
            
            EMLabel *boardCastLabel = [[EMLabel alloc] initWithFrame:Rect(0, 100, 100, 50)];
            boardCastLabel.textAlignment = NSTextAlignmentCenter;
            boardCastLabel.text = Local(@"Station");
            boardCastLabel.textColor  = RGB(255,252,0);
            boardCastLabel.font = ComFont(14*kScale);
            
            _boardCastLabel = [[EMLabel alloc] initWithFrame:Rect(100, 100, 100, 50)];
            _boardCastLabel.textAlignment = NSTextAlignmentCenter;
            _boardCastLabel.text = _boardCastStr;
            _boardCastLabel.textColor  = RGB(255,252,0);
            _boardCastLabel.font = ComFont(14*kScale);
            
            EMLabel *giftLabel = [[EMLabel alloc] initWithFrame:Rect(0, 150, 100, 50)];
            giftLabel.textAlignment = NSTextAlignmentCenter;
            giftLabel.text = Local(@"Gift");
            giftLabel.textColor  = RGB(255,252,0);
            giftLabel.font = ComFont(14*kScale);
            
            _giftLabel = [[EMLabel alloc] initWithFrame:Rect(100, 150, 100, 50)];
            _giftLabel.textAlignment = NSTextAlignmentCenter;
            _giftLabel.text = _giftStr;
            _giftLabel.textColor  = RGB(255,252,0);
            _giftLabel.font = ComFont(14*kScale);
            
            [controller.view addSubview:chatLabel];
            [controller.view addSubview:_chatLabel];
            [controller.view addSubview:msgLabel];
            [controller.view addSubview:_msgLabel];
            [controller.view addSubview:boardCastLabel];
            [controller.view addSubview:_boardCastLabel];
            [controller.view addSubview:giftLabel];
            [controller.view addSubview:_giftLabel];
        }
        controller.view.backgroundColor = RGB(77, 78, 145);
        
        _popoverController = [[WYPopoverController alloc] initWithContentViewController:controller];
        _popoverController.delegate = self;
    }
    [_popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}


- (void)monthProfitAction:(EMButton*)btn {
    [UIUtil showHUD:self.view];
    [_settingViewMode getMyProfileMonthDetail:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                _chatProfitStr = [NSString stringWithFormat:@"$%@",dict[@"data"][@"talk"]];
                _msgProfitStr = [NSString stringWithFormat:@"$%@",dict[@"data"][@"message"]];
                _boardCastStr = [NSString stringWithFormat:@"$%@",dict[@"data"][@"radio"]];
                _giftStr = [NSString stringWithFormat:@"$%@",dict[@"data"][@"gift"]];
                [self showPopView:btn];
            }else{
                [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}


- (void)todayProfitAction:(EMButton*)btn {
    [UIUtil showHUD:self.view];
    [_settingViewMode getMyProfileTodayDetail:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                _chatProfitStr = [NSString stringWithFormat:@"$%@",dict[@"data"][@"talk"]];
                _msgProfitStr = [NSString stringWithFormat:@"$%@",dict[@"data"][@"message"]];
                _boardCastStr = [NSString stringWithFormat:@"$%@",dict[@"data"][@"radio"]];
                _giftStr = [NSString stringWithFormat:@"$%@",dict[@"data"][@"gift"]];
                [self showPopView:btn];
            }else{
                [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}


- (void)howToChangeAction:(id)sender {
    NSLog(@"content==%@,subject=%@",self.content,self.subject);
    GetIncomeStepVC *getIncomeStep = [[GetIncomeStepVC alloc] init];
    getIncomeStep.subject = self.subject;
    getIncomeStep.content = self.content;
    [self.navigationController pushViewController:getIncomeStep animated:YES];
}

//提领
- (void)withDrawAction:(id)sender {
    if (self.withDarwDict && ![self.withDarwDict isEqual:[NSNull null]]  && [self.withDarwDict[@"current"] length]>0 && [self.withDarwDict[@"account"] length]>0) {
        if (_canDrawFee <= 0) {
            [self.view.window makeToast:Local(@"CanDrawFeeNotEnough") duration:ERRORTime position:[CSToastManager defaultPosition]];
            return;
        }
        [UIUtil showHUD:self.view];
        [_settingViewMode doWithDrawWithBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:self.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                    [self request];
                }else{
                    [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
            }else {
                [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }];
    }else{
        [self.view.window makeToast:Local(@"NotSetGetAccount") duration:ERRORTime position:[CSToastManager defaultPosition]];
    }
}

//兑换
- (void)changeAction:(id)sender {
    ChangeFeeVC *changeVC = [[ChangeFeeVC alloc] init];
    changeVC.canChangeMoney = [NSString stringWithFormat:@"%.2f USD",_canDrawFee];
    [self.navigationController pushViewController:changeVC animated:YES];
}

//领取记录
- (void)getFeeHisAction:(id)sender {
    GetFeeRecordsVC *getFeeRecords = [[GetFeeRecordsVC alloc] init];
    [self.navigationController pushViewController:getFeeRecords animated:YES];
}

//设置提领账户
- (void)setFeeAction:(id)sender {
//    int index = 0;
//    if (self.withDarwDict) {
//        NSArray *array = @[@"paypal",@"allpay",@"wechat"];
//        for(int i = 0;i<array.count;i++){
//            NSString *str = array[i];
//            if (![self.withDarwDict isEqual:[NSNull null]]&& ![self.withDarwDict[@"current"] isEqual:[NSNull null]]&&[str isEqualToString:self.withDarwDict[@"current"]]) {
//                index = i;
//            }
//        }
//    }
//    SettingGetFeeVC *settingGetFee = [[SettingGetFeeVC alloc] init];
//    settingGetFee.selectIndex = index;
    EMWebViewController *webView = [[EMWebViewController alloc] init];
    webView.weburl = self.withDrawSetURL;
    [self.navigationController pushViewController:webView animated:YES];
}

//查看转账手续费
- (void)viewFeeAction:(id)sender {
    LookFeeWebVC *lookFee = [[LookFeeWebVC alloc] init];
    if (!self.withDrawFeeURL || [self.withDrawFeeURL isEqualToString:@""]) {
        lookFee.urlStr = @"https://kf.qq.com/faq/130807me2YZf140907zqme6V.html";
    }else {
        lookFee.urlStr = self.withDrawFeeURL;
    }
    lookFee.navTitle = Local(@"ViewTransfer");
    [self.navigationController pushViewController:lookFee animated:YES];
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
