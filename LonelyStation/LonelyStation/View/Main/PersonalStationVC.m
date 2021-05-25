//
//  PersonalStationVC.m
//  LonelyStation
//
//  Created by zk on 16/9/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "PersonalStationVC.h"
#import "EMTableView.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AllStationsCell.h"
#import "SignalRecordShowVC.h"
#import "PersonalStationDetailVC.h"

@interface PersonalStationVC ()<UITableViewDelegate,UITableViewDataSource,AllStationsCellDelegate,PersonalStationDetailVCDelegate> {
    EMTableView *_tableView;
    MainViewVM *_mainViewVM;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
    BOOL _isLastPage;
}

@end

@implementation PersonalStationVC

- (void)setHaveSeen:(NSString*)time andPersonalStationDetail:(PersonalStationDetailVC *)sender{
    _currentStionUser.seenTime = time;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"PersonalStation")];
    [self initView];
    _dataArray = [NSMutableArray array];
    _from = 0;
    _cnt = 10;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData:YES];
}




- (void)initView {
    _mainViewVM = [[MainViewVM alloc] init];
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
    _tableView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 64, kScale, 2)];
    line.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.8);
    [self.view addSubview:line];
    
}


/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    if (!_isLastPage) {
        _from += _cnt;
        [self loadData:NO];
    }else{
        _tableView.mj_footer.state = MJRefreshStateNoMoreData;
    }
}

/**
 *  下拉刷新
 */
-(void)pushDownLoad{
    _from = 0;
    [self loadData:NO];
}


-(void)loadData:(BOOL)showHUD{
    if (_from == 0) {
        [_dataArray removeAllObjects];
    }
    if (showHUD) {
        [UIUtil showHUD:self.view];
    }
    
    [_mainViewVM getPersonalInfoWithMember:_currentStionUser andBlock:^(NSArray<BoardcastObj *> *arr, BOOL ret) {
        if (showHUD) {
            [UIUtil hideHUD:self.view];
        }
        if (arr && ret) {
            [_dataArray addObjectsFromArray:arr];
            if (_dataArray.count > _from + _cnt) {
                _isLastPage = NO;
            }else{
                _isLastPage = YES;
            }
            [_tableView reloadData];
            if (_dataArray.count == 0){
                [self.view.window makeToast:Local(@"ThereisNoAiring") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else {
            [_tableView reloadData];
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        [self endRefesh];
    } andFrom:[NSString stringWithFormat:@"%d",_from] andCnt:[NSString stringWithFormat:@"%d",_cnt]];
}


-(void)endRefesh{
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}

- (void)didClickPlayBtn:(UITableViewCell*)cell {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    BoardcastObj *obj = _dataArray[indexPath.row];
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.index =(int)indexPath.row;
    personalRecord.lonelyUser = _currentStionUser;
    personalRecord.shouldPlay = YES;
    personalRecord.stationDataArray = _dataArray;
    [self.navigationController pushViewController:personalRecord animated:YES];
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    AllStationsCell *cell = (AllStationsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AllStationsCell alloc] initWithSize:Size(kScreenW, 76*kScale) reuseIdentifier:cellIdentifier];
        
    }
    BoardcastObj *obj = _dataArray[indexPath.row];
    cell.lonelyStationUser = _currentStionUser;
    cell.boardcastObj = obj;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76*kScale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BoardcastObj *obj = _dataArray[indexPath.row];
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.index =(int)indexPath.row;
    personalRecord.delegate = self;
    personalRecord.lonelyUser = _currentStionUser;
    personalRecord.stationDataArray = _dataArray;
    [self.navigationController pushViewController:personalRecord animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
