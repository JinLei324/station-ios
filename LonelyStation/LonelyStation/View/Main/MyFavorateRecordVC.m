//
//  AllStationsVC.m
//  LonelyStation
//
//  Created by zk on 16/9/5.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyFavorateRecordVC.h"
#import "EMTableView.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AllStationsCell.h"
#import "PersonalStationVC.h"
#import "PersonalStationDetailVC.h"

@interface MyFavorateRecordVC ()<UITableViewDelegate,UITableViewDataSource,AllStationsCellDelegate> {
    EMTableView *_tableView;
    MainViewVM *_mainViewVM;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
    BOOL _isLastPage;
}

@end

@implementation MyFavorateRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"MyCollection") andColor:RGB(145,90,173)];
    [self initView];
    _dataArray = [NSMutableArray array];
    _from = 0;
    _cnt = 10;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIButton appearance] setTitleColor:nil forState:UIControlStateNormal];
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
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 63, kScreenW, 1)];
    line.backgroundColor = RGB(171, 171, 171);
    [self.viewNaviBar addSubview:line];
    
}


/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    _from += _cnt;
    [self loadData:NO];
}

/**
 *  下拉刷新
 */
-(void)pushDownLoad{
    _from = 0;
    [self loadData:NO];
}


-(void)loadData:(BOOL)showHUD{
    
    if (showHUD) {
        [UIUtil showHUD:self.view];
    }
    [_mainViewVM getCollectList:[NSString stringWithFormat:@"%d",_from] andCnt:[NSString stringWithFormat:@"%d",_cnt] andBlock:^(NSArray *arr, BOOL ret) {
        if (showHUD) {
            [UIUtil hideHUD:self.view];
        }
        if (arr && ret) {
            if (_from == 0) {
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:arr];
            if (_dataArray.count > _from + _cnt) {
                _isLastPage = NO;
            }else{
                _isLastPage = YES;
            }
            [_tableView reloadData];
        }else {
            [_tableView reloadData];
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        [self endRefesh];
    }];
}


-(void)endRefesh{
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    AllStationsCell *cell = (AllStationsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AllStationsCell alloc] initWithSize:Size(kScreenW, 76*kScale) reuseIdentifier:cellIdentifier];
        
    }
    BoardcastObj *obj = _dataArray[indexPath.row];
    cell.lonelyStationUser = obj.user;
    cell.boardcastObj = obj;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Local(@"CollectCancel") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        BoardcastObj *obj = _dataArray[indexPath.row];
                                        //取消收藏
                                        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"SureCancelCollect") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                                            if (!cancelled) {
                                                [_mainViewVM deleteCollectWithRecordId:obj.recordId andBlock:^(NSDictionary *dict, BOOL ret) {
                                                    if (dict && ret) {
                                                        if ([dict[@"code"] intValue] == 1) {
                                                            [self.view.window makeToast:Local(@"CollectCancelSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                                                            [self loadData:YES];
                                                        }else {
                                                            [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                                                            
                                                        }
                                                    }else {
                                                        [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                                                        
                                                    }
                                                }];
                                            }
                                        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
                                        [alert show];
                                        
                                    }];
    button.backgroundColor = RGB(238,238,238);
    [[UIButton appearance] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    return @[button];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76*kScale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BoardcastObj *obj = _dataArray[indexPath.row];
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.index = (int)indexPath.row;
    personalRecord.lonelyUser = obj.user;
    personalRecord.isFromAllStation = YES;
    [self.navigationController pushViewController:personalRecord animated:YES];
}

- (void)didClickPlayBtn:(UITableViewCell*)cell {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    BoardcastObj *obj = _dataArray[indexPath.row];
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.lonelyUser = obj.user;
    personalRecord.shouldPlay = YES;
    personalRecord.stationDataArray = _dataArray;
    personalRecord.isFromAllStation = YES;
    [self.navigationController pushViewController:personalRecord animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
