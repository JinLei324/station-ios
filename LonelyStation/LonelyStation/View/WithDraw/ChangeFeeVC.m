//
//  ChangeFeeVC.m
//  LonelyStation
//
//  Created by zk on 2016/12/11.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ChangeFeeVC.h"
#import "UIUtil.h"
#import "UserSettingViewModel.h"
#import "ViewModelCommom.h"

@interface ChangeFeeVC (){
    EMTableView *_tableView;
    EMLabel *_chatMinLabel;
    EMLabel *_stationMinLabel;
    double topFee;
    double bottomFee;
    double allFee;
    UserSettingViewModel *_userSettingViewModel;
    
    double profitTalkExchange;
    double profitradioExchange;

    
}


@end

@implementation ChangeFeeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _userSettingViewModel = [[UserSettingViewModel alloc] init];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"Change")];
    
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 70*kScale, 30)];
    buyBtn.layer.borderColor = RGB(0xff, 0xff, 0xff).CGColor;
    buyBtn.layer.borderWidth = 1;
    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    
    [buyBtn setTitleColor:RGB(0xff, 0xff, 0xff) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Sure") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(complateAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    
    
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH- 64)];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor clearColor];
    EMView *backView = [[EMView alloc] initWithFrame:Rect(0, 0, kScreenW, kScreenH-64)];
    backView.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenW, 22*kScale)];
    view.backgroundColor = RGBA(0x0, 0x0, 0x0, 0.3);
    EMLabel *label = [UIUtil createLabel:[NSString stringWithFormat:@"%@%@",Local(@"YouCanChange"),_canChangeMoney] andRect:Rect(0, 0, kScreenW, 22*kScale) andTextColor:RGB(255,252,0) andFont:ComFont(14) andAlpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    [backView addSubview:view];
    
    EMView *backViewTop = [[EMView alloc] initWithFrame:Rect(0, PositionY(view)+10*kScale, kScreenW, 200*kScale)];
    backViewTop.backgroundColor = RGBA(0x0, 0x0, 0x0, 0.3);
    [backView addSubview:backViewTop];
    
    EMLabel *chatLabel = [UIUtil createLabel:[NSString stringWithFormat:@"%@",Local(@"ChatCard")] andRect:Rect(87*kScale, backViewTop.frame.origin.y+68*kScale, 55*kScale, 17*kScale) andTextColor:RGB(255,255,255) andFont:ComFont(16*kScale) andAlpha:1];
    [backView addSubview:chatLabel];
    
    _chatMinLabel = [UIUtil createLabel:[NSString stringWithFormat:@"0%@",Local(@"ATime")] andRect:Rect(87*kScale, PositionY(chatLabel)+29*kScale, 100*kScale, 17*kScale) andTextColor:RGB(255,252,0) andFont:ComFont(16*kScale) andAlpha:1];
    [backView addSubview:_chatMinLabel];
    
    EMButton *chatMinBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-170*kScale, backViewTop.frame.origin.y+64*kScale, 75*kScale, 70*kScale)];
    [chatMinBtn setImage:[UIImage imageNamed:@"withdrawal_add"] forState:UIControlStateNormal];
    [chatMinBtn setImage:[UIImage imageNamed:@"withdrawal_add_d"] forState:UIControlStateNormal];
    [chatMinBtn addTarget:self action:@selector(chatMinAction:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longChatMinAction:)];
    gesture.minimumPressDuration = 0.8;
    [chatMinBtn addGestureRecognizer:gesture];
    
    [backView addSubview:chatMinBtn];
    
    EMView *backViewBottom = [[EMView alloc] initWithFrame:Rect(0, PositionY(backViewTop)+5*kScale, kScreenW, 200*kScale)];
    backViewBottom.backgroundColor = RGBA(0x0, 0x0, 0x0, 0.3);
    [backView addSubview:backViewBottom];
    
    EMLabel *stationLabel = [UIUtil createLabel:[NSString stringWithFormat:@"%@",Local(@"StationCard")] andRect:Rect(87*kScale, backViewBottom.frame.origin.y+68*kScale, 55*kScale, 17*kScale) andTextColor:RGB(255,255,255) andFont:ComFont(16*kScale) andAlpha:1];
    [backView addSubview:stationLabel];
    
    _stationMinLabel = [UIUtil createLabel:[NSString stringWithFormat:@"0%@",Local(@"ATime")] andRect:Rect(87*kScale, PositionY(stationLabel)+29*kScale, 100*kScale, 17*kScale) andTextColor:RGB(255,252,0) andFont:ComFont(16*kScale) andAlpha:1];
    [backView addSubview:_stationMinLabel];
    
    EMButton *stationMinBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-170*kScale, backViewBottom.frame.origin.y+64*kScale, 75*kScale, 70*kScale)];
    [stationMinBtn setImage:[UIImage imageNamed:@"withdrawal_add"] forState:UIControlStateNormal];
    [stationMinBtn setImage:[UIImage imageNamed:@"withdrawal_add_d"] forState:UIControlStateNormal];
    [stationMinBtn addTarget:self action:@selector(stationMinAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILongPressGestureRecognizer *stationGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longStationMinAction:)];
    stationGesture.minimumPressDuration = 0.8;
    [stationMinBtn addGestureRecognizer:stationGesture];
    
    [backView addSubview:stationMinBtn];
    
    [UIUtil addLineWithSuperView:backView andRect:Rect(0, PositionY(backViewBottom)+37*kScale, kScreenW, 1)];
    
//    EMLabel *changeScaleLabel =  [UIUtil createLabel:Local(@"ChangeScale") andRect:Rect(87*kScale, PositionY(backViewBottom)+29*kScale+37*kScale, 190*kScale, 66*kScale) andTextColor:RGB(255,252,0) andFont:ComFont(14*kScale) andAlpha:1];
//    changeScaleLabel.numberOfLines = 3;
//    [backView addSubview:changeScaleLabel];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:Rect(62*kScale, PositionY(backViewBottom)+29*kScale+37*kScale, 270*kScale, 88*kScale)];
    [webView setOpaque:NO];
    webView.backgroundColor = [UIColor clearColor];
    [backView addSubview:webView];
    
    _tableView.tableHeaderView = backView;
    profitTalkExchange = 0.06;
    profitradioExchange = 0.02;
    // Do any additional setup after loading the view.
    [UIUtil showHUD:self.view];
    [_userSettingViewModel getChangeDetailWithBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                double fee = [dict[@"data"][@"profit_available_exchange"] doubleValue];
                if ([dict[@"data"][@"profit_to_talk_exchange_rate"] doubleValue] > 0) {
                    profitTalkExchange = [dict[@"data"][@"profit_to_talk_exchange_rate"] doubleValue];
                }
                if ([dict[@"data"][@"profit_to_radio_exchange_rate"] doubleValue] > 0) {
                    profitradioExchange = [dict[@"data"][@"profit_to_radio_exchange_rate"] doubleValue];
                }
                
                double halfFee = fee/2.f;
                allFee = fee;
                topFee = halfFee;
                bottomFee = halfFee;
                int chatmin = halfFee/profitTalkExchange;
                int stationmin = halfFee/profitradioExchange;
                _chatMinLabel.text = [NSString stringWithFormat:@"%d%@",chatmin,Local(@"ATime")];
                _stationMinLabel.text = [NSString stringWithFormat:@"%d%@",stationmin,Local(@"ATime")];
                [webView loadHTMLString:[NSString stringWithFormat:@"%@%@",dict[@"data"][@"exchange_manual"][@"subject"],dict[@"data"][@"exchange_manual"][@"content"]] baseURL:nil];
            }
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}


- (void)longChatMinAction:(id)sender {
    topFee = allFee;
    bottomFee = 0;
    int chatmin = allFee/profitTalkExchange;
    int stationmin = 0;
    _chatMinLabel.text = [NSString stringWithFormat:@"%d%@",chatmin,Local(@"ATime")];
    _stationMinLabel.text = [NSString stringWithFormat:@"%d%@",stationmin,Local(@"ATime")];
}

- (void)longStationMinAction:(id)sender {
    topFee = 0;
    bottomFee = allFee;
    int chatmin = 0;
    int stationmin = allFee/profitradioExchange;
    _chatMinLabel.text = [NSString stringWithFormat:@"%d%@",chatmin,Local(@"ATime")];
    _stationMinLabel.text = [NSString stringWithFormat:@"%d%@",stationmin,Local(@"ATime")];
}



- (void)stationMinAction:(id)sender {
    topFee -= profitradioExchange;
    bottomFee += profitradioExchange;
    if (bottomFee > allFee) {
        topFee = 0;
        bottomFee = allFee;
    }
    if (topFee < 0){
        topFee = 0;
        bottomFee = allFee;
    }
    int chatmin = topFee/profitTalkExchange;
    int stationmin = bottomFee/profitradioExchange;
    _chatMinLabel.text = [NSString stringWithFormat:@"%d%@",chatmin,Local(@"ATime")];
    _stationMinLabel.text = [NSString stringWithFormat:@"%d%@",stationmin,Local(@"ATime")];
}

- (void)chatMinAction:(id)sender {
    topFee += profitTalkExchange;
    bottomFee -= profitTalkExchange;
    if (topFee > allFee) {
        topFee = allFee;
        bottomFee = 0;
    }
    if (bottomFee < 0){
        topFee = allFee;
        bottomFee = 0;
    }
    int chatmin = topFee/profitTalkExchange;
    int stationmin = bottomFee/profitradioExchange;
    _chatMinLabel.text = [NSString stringWithFormat:@"%d%@",chatmin,Local(@"ATime")];
    _stationMinLabel.text = [NSString stringWithFormat:@"%d%@",stationmin,Local(@"ATime")];
}

- (void)complateAction:(id)sender {
    NSString *chatMin = [NSString stringWithFormat:@"%d",[_chatMinLabel.text intValue]*60];
    NSString *stationMin = [NSString stringWithFormat:@"%d",[_stationMinLabel.text intValue]*60];
    [UIUtil showHUD:self.view];
    [_userSettingViewModel doExchange:chatMin andRadioSecond:stationMin andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyUser *user = [ViewModelCommom getCuttentUser];
                int talkSec = user.talkSecond.intValue + [chatMin intValue];
                int radioSec = user.radioSecond.intValue + [stationMin intValue];
                user.talkSecond = [NSString stringWithFormat:@"%d",talkSec];
                user.radioSecond = [NSString stringWithFormat:@"%d",radioSec];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                [self.navigationController popViewControllerAnimated:YES];
            }
            [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
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
