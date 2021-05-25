//
//  MyFocousVC.m
//  LonelyStation
//
//  Created by zk on 16/9/5.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "CallRecordVC.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "CallRecordCell.h"
#import "EMUtil.h"
#import "PersonalStationVC.h"
#import "MyFocousCell.h"
#import "EMAlertView.h"
#import "ViewModelCommom.h"
#import "PersonalDetailInfoVC.h"

@interface CallRecordVC()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>{
    EMTableView *_tableView;
    MainViewVM *_mainViewVM;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
    BOOL _isLastPage;
}

@end

@implementation CallRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"VoiceHistory") andColor:RGB(145,90,173)];
    [self initView];
    _mainViewVM = [[MainViewVM alloc] init];
    _dataArray = [NSMutableArray array];
    _from = 0;
    _cnt = 30;
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
    _tableView.rowHeight = 76*kScale;
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 63, kScreenW, 1)];
    line.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.8);
    [self.viewNaviBar addSubview:line];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIButton appearance] setTitleColor:nil forState:UIControlStateNormal];}

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
    [_mainViewVM getCallRecordWithBlock:^(NSArray *arr, BOOL ret) {
        //这里没有做分页
        [_dataArray removeAllObjects];
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
    CallRecordCell *cell = (CallRecordCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CallRecordCell alloc] initWithSize:CGSizeMake(kScreenW, 76*kScale) reuseIdentifier:cellIdentifier];
    }
    CallRecordObj *obj = _dataArray[indexPath.row];
    LonelyStationUser *srcUser = obj.srcUser;
    LonelyStationUser *dstUser = obj.dstUser;
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    LonelyStationUser *aUser = nil;
    if ([user.userID isEqualToString:srcUser.userID]) {
        aUser = dstUser;
        cell.isCallOut = YES;
    }else {
        aUser = srcUser;
        cell.isCallOut = NO;
    }
    cell.lonelyStationUser = aUser;
    cell.callRecordObj = obj;
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
    CallRecordObj *obj = _dataArray[indexPath.row];
    LonelyStationUser *srcUser = obj.srcUser;
    LonelyStationUser *dstUser = obj.dstUser;
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    LonelyStationUser *aUser = nil;
    if ([user.userID isEqualToString:srcUser.userID]) {
        aUser = dstUser;
    }else {
        aUser = srcUser;
    }
    PersonalDetailInfoVC *personalVC = [[PersonalDetailInfoVC alloc] init];
    personalVC.lonelyUser = aUser;
    
    [self.navigationController pushViewController:personalVC animated:YES];
}




@end
