//
//  AddMoneyMainVC.m
//  LonelyStation
//
//  Created by zk on 2016/10/16.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AddMoneyMainVC.h"
#import "ViewModelCommom.h"
#import "UIUtil.h"
#import "BuyVIPVC.h"
#import "ChatVIPVC.h"
#import "StationVIPVC.h"
#import "MyBuyListVC.h"
#import "MainViewVM.h"
#import "UserSettingViewModel.h"
#import "GetIncomeStepVC.h"
#import "BuyLimitVC.h"
#import "BuyVIPNewCell.h"
#import "BuyInApp.h"
#import "MissionPopView.h"
#import "SoundService.h"
#import "ChargePointViewController.h"

@interface AddMoneyMainVC ()<UITableViewDelegate,UITableViewDataSource> {
    EMLabel *talkLabel;
    EMLabel *stationLabel;
    EMLabel *freeTalkLabel;
}

@property (nonatomic,strong)EMButton *freeBtn; //免费获取聊天卡
@property (nonatomic,strong)EMLabel *freeLabel; //免费获取聊天卡

@property (nonatomic,strong)EMButton *vipBtn; //vip包月
@property (nonatomic,strong)EMButton *chatBtn; //聊天
@property (nonatomic,strong)EMButton *stationBtn; //电台

@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *subject;

@property (nonatomic,strong)EMLabel *leftCoinLabel;
@property (nonatomic,strong)UIImageView *imgView;
@property (nonatomic,strong)EMButton *missonBtn; //任务Btn
@property (nonatomic,strong)EMButton *chargeBtn; //兑换Btn

@property (nonatomic,strong)UITableView *infoTableView;
@property (nonatomic,strong)NSMutableArray *dataArray;

@property (nonatomic,strong)BuyInApp *buyInApp;

@property (nonatomic,copy)NSString *withDrawCoin;
@property (nonatomic,copy)NSString *leftCoin;


@end

@implementation AddMoneyMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.view.backgroundColor = RGB(231, 231, 231);
    _buyInApp = [BuyInApp new];
    [self.viewNaviBar setTitle:Local(@"AddMoneyTitle") andColor:RGB(145,90,173)];
    [self.viewNaviBar setBarColor:[UIColor whiteColor]];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (UIImageView*)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        [self.view addSubview:_imgView];
//        _imgView.image = [UIImage imageNamed:@"center_illustration"];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(128*kScale + StatusBarHeight + 44);
            make.left.mas_equalTo(11*kScale);
            make.right.mas_equalTo(-11*kScale);
            make.height.mas_equalTo(109*kScale);
        }];
    }
    return _imgView;
}

- (UITableView*)infoTableView {
    if (!_infoTableView) {
//        self.imgView.hidden = NO;
        _infoTableView = [UITableView new];
        [self.view addSubview:_infoTableView];
        [_infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imgView).offset(55*kScale);
            make.left.mas_equalTo(23*kScale);
            make.right.mas_equalTo(-23*kScale);
            make.bottom.mas_equalTo(-49*kScale);
        }];
        _infoTableView.backgroundColor = RGB(200, 200, 200);
        [_infoTableView registerClass:[BuyVIPNewCell class] forCellReuseIdentifier:@"BuyVIPNewCell"];
        _infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _infoTableView.delegate = self;
        _infoTableView.dataSource = self;
    }
    return _infoTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProgramObj *obj = self.dataArray[indexPath.row];
    // 内购
    PayTypeObj *payType = [[PayTypeObj alloc] initWithType:@"In-App"];
    [_buyInApp buyInApp:payType andProgramObj:obj andView:self.view andNavController:self.navigationController];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BuyVIPNewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuyVIPNewCell"];
    ProgramObj *obj = [self.dataArray objectAtIndex:indexPath.row];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setModel:obj];
    WS(weakSelf)
    [cell setClickBlock:^{
        ProgramObj *obj = weakSelf.dataArray[indexPath.row];
        // 内购
        PayTypeObj *payType = [[PayTypeObj alloc] initWithType:@"In-App"];
        [_buyInApp buyInApp:payType andProgramObj:obj andView:self.view andNavController:self.navigationController];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75*kScale;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self moneyAnimate];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    MainViewVM *mainViewVModel = [[MainViewVM alloc] init];
    [mainViewVModel getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict) {
            if ([dict[@"code"] intValue] == 1) {
                user.talkSecond = dict[@"data"][@"talk_second"];
                user.radioSecond = dict[@"data"][@"radio_second"];
                user.vipStartSecond = dict[@"data"][@"vip_start_time"];
                user.vipEndSecond = dict[@"data"][@"vip_end_time"];
                user.chat_point = dict[@"data"][@"chat_point"];
                user.chat_point_profit = [NSString stringWithFormat:@"%d",[dict[@"data"][@"chat_point_profit"] intValue]];
                self.withDrawCoin = [NSString stringWithFormat:@"%d",[dict[@"data"][@"chat_point_profit"] intValue]];
                self.leftCoin = dict[@"data"][@"chat_point"];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                if (talkLabel) {
                    talkLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"TalkLeft"),user.talkSecond,Local(@"Seconds")];
                }
                if (stationLabel) {
                    stationLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"RadioLeft"),user.radioSecond,Local(@"Seconds")];
                }
                [self configLabel:self.leftCoinLabel andUpText:Local(@"LeftCoin") andDownText:user.chat_point];

                if (freeTalkLabel) {
                    freeTalkLabel.text = [EMUtil getInitfiString];

                }
            }
        }
        [self request];
    }];

}

- (void)configLabel:(EMLabel*)label andUpText:(NSString*)upTxt andDownText:(NSString*)downTxt {
    label.font = ComFont(27*kScale);
    NSString *allText = [NSString stringWithFormat:@"%@\n%@",upTxt,downTxt];
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:allText];
    NSRange upRange = [allText rangeOfString:upTxt];
    NSDictionary * upAttributes = @{ NSFontAttributeName:ComFont(15*kScale)};
    [muStr setAttributes:upAttributes range:upRange];
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = muStr;
    label.textColor = RGB(51,51,51);
    label.numberOfLines = 0;
}

- (EMLabel*)leftCoinLabel {
    if (!_leftCoinLabel) {
        UIView *view = [UIView new];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.mas_equalTo(100*kScale);
            make.height.mas_equalTo(100*kScale);
            make.top.mas_equalTo(15*kScale + StatusBarHeight + 44);
        }];
        view.layer.cornerRadius = 50*kScale;
        view.layer.backgroundColor =RGB(209,172,255).CGColor;
        
        
        _leftCoinLabel = [EMLabel new];
        [self.view addSubview:_leftCoinLabel];
        [_leftCoinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.mas_equalTo(100*kScale);
            make.height.mas_greaterThanOrEqualTo(47*kScale);
            make.top.mas_equalTo(40*kScale + StatusBarHeight + 44);
        }];
        _leftCoinLabel.textColor = RGB(51,51,51);
        
        
    }
    return _leftCoinLabel;
}


- (EMButton*)missonBtn {
    if (!_missonBtn) {
        _missonBtn = [[EMButton alloc] initWithFrame:Rect(0, 0, 80*kScale, 30*kScale) andConners:15*kScale];
        [_missonBtn setTitle:@"任务" forState:UIControlStateNormal];
        [_missonBtn setTitleColor:RGB(145,90,173) forState:UIControlStateNormal];
        _missonBtn.borderColor = RGB(145,90,173);
        _missonBtn.borderWidth = 1;
        [self.view addSubview:_missonBtn];
        [_missonBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftCoinLabel.mas_left).offset(-40*kScale);
            make.top.equalTo(self.leftCoinLabel.mas_bottom).offset(30*kScale);
            make.size.mas_equalTo(Size(80*kScale, 30*kScale));
        }];
        [_missonBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        _missonBtn.titleLabel.font = ComFont(13);
        UIImageView *imageView = [UIImageView new];
        [_missonBtn addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(30*kScale, 30*kScale));
        }];
        
        imageView.image = [UIImage imageNamed:@"icon_coin"];
        [_missonBtn addTarget:self action:@selector(missionAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _missonBtn;
}

- (void)missionAction:(UIButton*)btn {
    MissionPopView *popView = [[MissionPopView alloc] initWithTitle:Local(@"MissionTitle") message:Local(@"MissionDes") clickedBlock:^(MissionPopView * _Nonnull alertView, BOOL cancelled, NSInteger buttonIndex) {
      
    } cancelButtonTitle:@"" otherButtonTitles:Local(@"Leave"), nil];
    [popView show];
}


- (EMButton*)chargeBtn {
    if (!_chargeBtn) {
        _chargeBtn = [[EMButton alloc] initWithFrame:Rect(0, 0, 80*kScale, 30*kScale) andConners:15*kScale];
        [_chargeBtn setTitle:@"兑换" forState:UIControlStateNormal];
        [_chargeBtn setTitleColor:RGB(145,90,173) forState:UIControlStateNormal];
        _chargeBtn.borderColor = RGB(145,90,173);
        _chargeBtn.borderWidth = 1;
        [self.view addSubview:_chargeBtn];
        [_chargeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftCoinLabel.mas_right).offset(-40*kScale);
            make.top.equalTo(self.leftCoinLabel.mas_bottom).offset(30*kScale);
            make.size.mas_equalTo(Size(80*kScale, 30*kScale));
        }];
        [_chargeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
        _chargeBtn.titleLabel.font = ComFont(13);
        [_chargeBtn addTarget:self action:@selector(chargeAction:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imageView = [UIImageView new];
        [_chargeBtn addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(30*kScale, 30*kScale));
        }];
        imageView.image = [UIImage imageNamed:@"icon_coin"];
    }
    return _chargeBtn;
}

- (void)chargeAction:(UIButton*)btn {
    ChargePointViewController *chargePointVC = [ChargePointViewController new];
    chargePointVC.leftCoin = self.leftCoin;
    chargePointVC.withDrawCoin = self.withDrawCoin;
    [self.navigationController pushViewController:chargePointVC animated:YES];
}

- (void)initViews {
    UserSettingViewModel *_userSetting = [[UserSettingViewModel alloc] init];
    [_userSetting getConfig:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict objectForKey:@"res"] && [[dict objectForKey:@"res"] intValue] == 0) {
                [[FileAccessData sharedInstance] setAObject:@"0" forEMKey:@"isChecking"];
            }else {
                [[FileAccessData sharedInstance] setAObject:@"1" forEMKey:@"isChecking"];
            }
        }else {
            [[FileAccessData sharedInstance] setAObject:@"1" forEMKey:@"isChecking"];
        }
    }];
    WS(weakSelf)
    [_userSetting getVIPProgramWithBlock:^(NSArray *array, BOOL ret) {
        if (ret) {
            NSLog(@"array==%@",array);
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:array];
            [weakSelf.infoTableView reloadData];
        }
    }];
    self.missonBtn.hidden = NO;
    self.chargeBtn.hidden = NO;
    EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(0, 0, kScreenW - 46*kScale, 53*kScale)];
    label.textColor = RGB(67,67,67);
    label.font = ComFont(16*kScale);
    label.text = @"MENU";
    label.textAlignment = NSTextAlignmentCenter;
    UIView *line = [[UIView alloc] initWithFrame:Rect(0, 53*kScale-1, kScreenW - 46*kScale, 1)];
    [label addSubview:line];
    line.backgroundColor = RGB(171,171,171);
    
    self.infoTableView.tableHeaderView = label;
    
    EMButton *buyListBtn = [UIUtil buttonWithName:Local(@"MyBuyList") andFrame:Rect(23*kScale, ScreenHeight-49*kScale, kScreenW - 46*kScale, 49*kScale) andSelector:@selector(myListAction:) andTarget:self isEnable:YES];
    [buyListBtn setTitleColor:RGB(67,67,67) forState:UIControlStateNormal];
    [buyListBtn.titleLabel setFont:ComFont(16*kScale)];
    [self.view addSubview:buyListBtn];
    [buyListBtn setBackgroundColor:RGB(200, 200, 200)];
    UIView *line1 = [[UIView alloc] initWithFrame:Rect(32*kScale,0, 249*kScale, 1)];
    [buyListBtn addSubview:line1];
    line1.backgroundColor = RGB(171,171,171);
}


- (void)moneyAnimate {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    //生成vip包月，聊天，电台券
    __block int chat_point = [user.chat_point intValue];
    MainViewVM *mainViewVModel = [[MainViewVM alloc] init];
    [mainViewVModel  getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict) {
            if ([dict[@"code"] intValue] == 1) {
                user.talkSecond = dict[@"data"][@"talk_second"];
                user.radioSecond = dict[@"data"][@"radio_second"];
                user.vipStartSecond = dict[@"data"][@"vip_start_time"];
                user.vipEndSecond = dict[@"data"][@"vip_end_time"];
                user.chat_point = dict[@"data"][@"chat_point"];
                user.chat_point_profit = [NSString stringWithFormat:@"%d",[dict[@"data"][@"chat_point_profit"] intValue]];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                self.withDrawCoin = [NSString stringWithFormat:@"%d",[dict[@"data"][@"chat_point_profit"] intValue]];
                self.leftCoin = dict[@"data"][@"chat_point"];
                if (talkLabel) {
                    talkLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"TalkLeft"),user.talkSecond,Local(@"Seconds")];
                }
                if (stationLabel) {
                    stationLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"RadioLeft"),user.radioSecond,Local(@"Seconds")];
                }
                [self.infoTableView reloadData];
                
                //                if (self.isComfromMain) {
                int point = [user.chat_point intValue] - chat_point;
                //                    point = 24;
                if (point > 0) {
                    
                    //播放声音
                    SystemSoundID soundID = 0;
                    // 2.根据音效文件,来生成SystemSoundID
                    NSURL *url = [[NSBundle mainBundle] URLForResource:@"money.mp3" withExtension:nil];
                    CFURLRef urlRef = (__bridge CFURLRef)(url);
                    AudioServicesCreateSystemSoundID(urlRef, &soundID);
                    AudioServicesPlaySystemSound(soundID);
                    __block int start = 1;
                    [NSTimer scheduledTimerWithTimeInterval:1.5/(point*1.f) repeats:YES block:^(NSTimer * _Nonnull timer) {
                        [self configLabel:self.leftCoinLabel andUpText:Local(@"LeftCoin") andDownText:[NSString stringWithFormat:@"%d",chat_point+start]];
                        start++;
                        if (start > point) {
                            [timer invalidate];
                        }
                    }];
                }
            }else{
                [self configLabel:self.leftCoinLabel andUpText:Local(@"LeftCoin") andDownText:user.chat_point];
            }
            
            //            }
        }
    }];
}

- (void)request {
    UserSettingViewModel *_settingViewMode = [[UserSettingViewModel alloc] init];
    [UIUtil showHUD:self.view];
    WS(weakSelf);
    [_settingViewMode getMyProfitDetailWithBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if (dict[@"withdraw_manual"] && [dict[@"withdraw_manual"] isKindOfClass:[NSDictionary class]]) {
                weakSelf.subject = dict[@"withdraw_manual"][@"subject"];
                weakSelf.content = dict[@"withdraw_manual"][@"content"];
            }
          
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

- (void)howToChangeAction:(EMButton*)btn {
    GetIncomeStepVC *getIncomeStep = [[GetIncomeStepVC alloc] init];
    getIncomeStep.subject = self.subject;
    getIncomeStep.content = self.content;
    [self.navigationController pushViewController:getIncomeStep animated:YES];
}

- (void)freeAction:(EMButton*)btn {
    BuyLimitVC *buyLimitVC = [[BuyLimitVC alloc] init];
    [self.navigationController pushViewController:buyLimitVC animated:YES];
}

- (void)vipAction:(EMButton*)btn {
    BuyVIPVC *buyVipVC = [[BuyVIPVC alloc] init];
    [self.navigationController pushViewController:buyVipVC animated:YES];
}

- (void)chatAction:(EMButton*)btn {
    ChatVIPVC *chatVIPVC = [[ChatVIPVC alloc] init];
    [self.navigationController pushViewController:chatVIPVC animated:YES];
}

- (void)stationAction:(EMButton*)btn {
    StationVIPVC *stationVIPVC = [[StationVIPVC alloc] init];
    [self.navigationController pushViewController:stationVIPVC animated:YES];
}


- (void)myListAction:(EMButton*)btn {
    MyBuyListVC *myBuyList = [[MyBuyListVC alloc] init];
    [self.navigationController pushViewController:myBuyList animated:YES];
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
