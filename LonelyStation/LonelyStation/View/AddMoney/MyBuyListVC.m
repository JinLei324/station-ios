//
//  MyBuyListVC.m
//  LonelyStation
//
//  Created by zk on 2016/10/19.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyBuyListVC.h"
#import "UIUtil.h"
#import "MyBuyListCell.h"
#import "BuyListObj.h"
#import "UserSettingViewModel.h"
#import "LonelyUser.h"
#import "ViewModelCommom.h"
#import "MainViewVM.h"

@interface MyBuyListVC ()<UITableViewDelegate,UITableViewDataSource>{
    UserSettingViewModel *_mainViewVM;
    EMTableView *_tableView;
    NSMutableArray *_dataArray;
    EMLabel *talkLabel;
    EMLabel *stationLabel;
    EMLabel *freeTalkLabel;
}

@end

@implementation MyBuyListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"MyBuyList") andColor:RGB(145,90,173)];
    [self initViews];

  
    
    // Do any additional setup after loading the view.
}


- (void)initViews {
    _mainViewVM = [[UserSettingViewModel alloc] init];
    
    MainViewVM *mainViewVModel = [[MainViewVM alloc] init];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [mainViewVModel  getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict) {
            if ([dict[@"code"] intValue] == 1) {
                user.talkSecond = dict[@"data"][@"talk_second"];
                user.radioSecond = dict[@"data"][@"radio_second"];
                user.vipStartSecond = dict[@"data"][@"vip_start_time"];
                user.vipEndSecond = dict[@"data"][@"vip_end_time"];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                if (talkLabel) {
                    talkLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"TalkLeft"),user.talkSecond,Local(@"Seconds")];
                }
                if (stationLabel) {
                    stationLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"RadioLeft"),user.radioSecond,Local(@"Seconds")];
                }
                
            }
        }
    }];
    
    _dataArray = [NSMutableArray array];
//    //测试数据 开始
//    for (int i = 0; i<3; i++) {
//        BuyListObj *obj = [[BuyListObj alloc] init];
//        obj.buyTime = @"购买日期：20160520";
//        obj.productName = @"单月VIP套餐：$30 USD";
//        obj.productDesp = @"赠享乐卡1张+800分钟电台收听";
//        [_dataArray addObject:obj];
//    }
//    //测试数据结束
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [UIUtil showHUD:self.view];
    [_mainViewVM getAllOrdersWithBlock:^(NSArray *array, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (array && ret) {
            [_dataArray addObjectsFromArray:array];
            [_tableView reloadData];
        }else{
            [self.view.window makeToast:Local(@"PlsSelectProduct") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
    
//    EMLabel *cacluLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, kScreenH - 84*kScale, kScreenW - 22*kScale, 15)];
//    cacluLabel.text = Local(@"LeftCaclu");
//    cacluLabel.font = ComFont(14);
//    cacluLabel.textColor = RGB(0xff, 0xff, 0xff);
//    [self.view addSubview:cacluLabel];
//
//    EMView *line1 = [[EMView alloc] initWithFrame:Rect(11*kScale, PositionY(cacluLabel)+2, 56, 1)];
//    line1.backgroundColor = RGB(255,255,255);
//    [self.view addSubview:line1];
    
//    talkLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, PositionY(cacluLabel)+8, kScreenW - 22*kScale, 15)];
//    talkLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"TalkLeft"),user.talkSecond,Local(@"Seconds")];
//    talkLabel.font = ComFont(14);
//    talkLabel.textColor = RGB(255,252,0);
//    [self.view addSubview:talkLabel];
//
//    stationLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, PositionY(talkLabel)+8, kScreenW - 22*kScale, 15)];
//    stationLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"RadioLeft"),user.radioSecond,Local(@"Seconds")];
//    stationLabel.font = ComFont(14);
//    stationLabel.textColor = RGB(255,252,0);
//    [self.view addSubview:stationLabel];
//
//    freeTalkLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, PositionY(stationLabel)+8, kScreenW - 22*kScale, 15)];
//    freeTalkLabel.text = [EMUtil getInitfiString];
//    freeTalkLabel.font = ComFont(14);
//    freeTalkLabel.textColor = RGB(255,252,0);
//    [self.view addSubview:freeTalkLabel];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify = @"Cell";
    MyBuyListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[MyBuyListCell alloc] initWithSize:Size(kScreenW, 89*kScale) reuseIdentifier:identify];
    }
    cell.buyListObj = _dataArray[indexPath.row];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 89*kScale;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
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
