//
//  BuyVIPVC.m
//  LonelyStation
//
//  Created by zk on 2016/10/16.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "BuyVIPVC.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "BuyVIPCell.h"
#import "ProgramObj.h"
#import "ViewModelCommom.h"
#import "UserSettingViewModel.h"
#import "BuyInApp.h"


@interface BuyVIPVC ()<UITableViewDelegate,UITableViewDataSource>{
    UserSettingViewModel *_mainViewVM;
    EMTableView *_tableView;
    NSMutableArray *_programArray;
    int selectIndex;
    BuyInApp *_buyInApp;
}

@end

@implementation BuyVIPVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _buyInApp = [[BuyInApp alloc] init];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"BuyVIP")];
    selectIndex = -1;
    [self initViews];
    [UIUtil showHUD:self.view];
    [_mainViewVM getVIPProgramWithBlock:^(NSArray *array, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (array && ret) {
            _programArray = nil;
            _programArray = [NSMutableArray arrayWithArray:array];
            [_tableView reloadData];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
    // Do any additional setup after loading the view.
}

- (void)initViews {
    _mainViewVM = [[UserSettingViewModel alloc] init];
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 70*kScale, 30)];
    buyBtn.layer.borderColor = RGB(0xff, 0xff, 0xff).CGColor;
    buyBtn.layer.borderWidth = 1;
    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    
    [buyBtn setTitleColor:RGB(0xff, 0xff, 0xff) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Buy") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 66, kScreenW, kScreenH - 66)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectIndex = (int)indexPath.row;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify = @"Cell";
    BuyVIPCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[BuyVIPCell alloc] initWithSize:Size(kScreenW, 66*kScale) reuseIdentifier:identify];
    }
    ProgramObj *obj = [_programArray objectAtIndex:indexPath.row];
    cell.likeCard = obj.title;
    cell.cardDesp = obj.memo;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66*kScale;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _programArray.count;
}



- (void)buyAction:(EMButton*)btn {
    if (selectIndex < 0) {
        [self.view.window makeToast:Local(@"PlsSelectProduct") duration:ERRORTime position:[CSToastManager defaultPosition]];
    }else {
        ProgramObj *obj = _programArray[selectIndex];
            // 内购
            PayTypeObj *payType = [[PayTypeObj alloc] initWithType:@"In-App"];
            [_buyInApp buyInApp:payType andProgramObj:obj andView:self.view andNavController:self.navigationController];
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
