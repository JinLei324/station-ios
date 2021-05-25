//
//  SettingGetFeeVC.m
//  LonelyStation
//
//  Created by zk on 2016/12/10.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "SettingGetFeeVC.h"
#import "SettingGetFeeCell.h"
#import "UIUtil.h"
#import "InComeAccountVC.h"

@interface SettingGetFeeVC ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_imageArray;
}

@end

@implementation SettingGetFeeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    _tableView = [[UITableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _imageArray = @[@"withdrawal_paypal",@"withdrawal_allpay",@"withdrawal_alipy",@"withdrawal_wechat"];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    EMLabel *label = [UIUtil createLabel:Local(@"WarningInfo") andRect:Rect(0, 0, kScreenW, 44*kScale) andTextColor:RGB(235,173,255) andFont:ComFont(14) andAlpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 1;
    _tableView.tableFooterView = label;
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 70*kScale, 30)];
    buyBtn.layer.borderColor = RGB(0xff, 0xff, 0xff).CGColor;
    buyBtn.layer.borderWidth = 1;
    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    
    [buyBtn setTitleColor:RGB(0xff, 0xff, 0xff) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Complate") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(complateAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    // Do any additional setup after loading the view.
    [_tableView setAllowsMultipleSelection:NO];

    [self performSelector:@selector(selectCell) withObject:nil afterDelay:0.5];
}

- (void)selectCell {
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)complateAction:(id)sender {
    if (_selectIndex == -1){
        [self.view.window makeToast:Local(@"PlsSelectType") duration:ERRORTime position:[CSToastManager defaultPosition]];
    }else{
        InComeAccountVC *incomeAccount = [[InComeAccountVC alloc] init];
        incomeAccount.selectIndex = _selectIndex;
        [self.navigationController pushViewController:incomeAccount animated:YES];
    }
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify = @"Cell";
    SettingGetFeeCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SettingGetFeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
  
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.cellImageView.image = [UIImage imageNamed:_imageArray[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _imageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22*kScale;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectIndex = (int)indexPath.row;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenW, 22*kScale)];
    view.backgroundColor = RGBA(0x0, 0x0, 0x0, 0.3);
    EMLabel *label = [UIUtil createLabel:Local(@"PlsSelectType") andRect:Rect(0, 0, kScreenW, 22*kScale) andTextColor:RGB(255,252,0) andFont:ComFont(14) andAlpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88*kScale;
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
