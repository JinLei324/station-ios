//
//  GetFeeRecordsVC.m
//  LonelyStation
//
//  Created by zk on 2016/12/11.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "GetFeeRecordsVC.h"
#import "UserSettingViewModel.h"
#import "GetFeeRecordCell.h"
#import "WithDrawObj.h"
#import "UIUtil.h"

@interface GetFeeRecordsVC ()<UITableViewDelegate,UITableViewDataSource>{
    UserSettingViewModel *_settingViewModel;
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}

@end

@implementation GetFeeRecordsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"GetFeeRecord")];
    _settingViewModel = [[UserSettingViewModel alloc] init];
    _tableView = [[UITableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _dataArray = [NSMutableArray array];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [UIUtil showHUD:self.view];
    [_settingViewModel getWithDrawListWithBlock:^(NSArray *array, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (array && ret) {
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:array];
            [_tableView reloadData];
        }
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify = @"Cell";
    GetFeeRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[GetFeeRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    WithDrawObj *obj = _dataArray[indexPath.row];
    cell.timeLabel.text = [EMUtil getYearAndMonthAndDayWithString:obj.updateTime];
    cell.isDoneLabel.text = [obj.isDone isEqualToString:@"Y"]?Local(@"GetFeeDone"):Local(@"GetFeeUnDone");
    cell.currentLabel.text = obj.current;
    cell.countLabel.text = [NSString stringWithFormat:@"$ %.3fUSD",[obj.bookAmount doubleValue]];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44*kScale;
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
