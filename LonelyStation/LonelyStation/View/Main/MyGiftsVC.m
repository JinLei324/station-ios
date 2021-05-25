//
//  AllStationsVC.m
//  LonelyStation
//
//  Created by zk on 16/9/5.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyGiftsVC.h"
#import "EMTableView.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AllStationsCell.h"
#import "PersonalStationVC.h"
#import "PersonalStationDetailVC.h"
#import "MyGiftsCell.h"
#import "ChatViewController.h"
#import "AddMoneyMainVC.h"

@interface MyGiftsVC ()<UITableViewDelegate,UITableViewDataSource,MyGiftsCellDelegate> {
    EMTableView *_tableView;
    MainViewVM *_mainViewVM;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
    BOOL _isLastPage;
    BoardCastType currentType;
    
}

@end

@implementation MyGiftsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"MyVoice") andColor:RGB(145,90,173)];
    [self initView];
    _dataArray = [NSMutableArray array];
    _from = 0;
    _cnt = 10;
    currentType = BoardCastDefault;
}

- (void)didClickPlayBtn:(UITableViewCell*)cell {
    //聊天
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    LonelyStationUser *lonelyUser = _dataArray[index.row];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.gender isEqualToString:@"M"]) {
        //做判断，1.如果对方是收费，自己有秒数，弹提示1
        //2.如果聊天卡用完，弹购买提示
        //3.如果对方免费，谈提示无限畅聊卡，如果有聊天卡，使用聊天卡
        //4.如果无限畅聊卡都没有，谈提示
        WS(weakSelf)
        [EMUtil chatWithUser:lonelyUser andFirstBlock:^{
            SS(weakSelf, strongSelf);
            [EMUtil pushToChat:lonelyUser andViewController:strongSelf];
        } andSecondBlock:^{
            SS(weakSelf, strongSelf);
            AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
            [strongSelf.navigationController pushViewController:addMoneyMainVC animated:YES];
        }];
    }else {
        [EMUtil pushToChat:lonelyUser andViewController:self];
    }
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
//    _tableView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
//    _tableView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 63, kScreenW, 1)];
    line.backgroundColor = RGBA(171, 171, 171, 1);
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
    [_mainViewVM getMyGiftListWithBlock:^(NSArray *array, BOOL ret) {
        if (showHUD) {
            [UIUtil hideHUD:self.view];
        }
        if (array && ret) {
//            if (_from == 0) {
//            }
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:array];
//            if (_dataArray.count > _from + _cnt) {
//                _isLastPage = NO;
//            }else{
//                _isLastPage = YES;
//            }
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
    MyGiftsCell *cell = (MyGiftsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MyGiftsCell alloc] initWithSize:Size(kScreenW, 76*kScale) reuseIdentifier:cellIdentifier];
        
    }
    cell.delegate = self;
    cell.lonelyStationUser = _dataArray[indexPath.row];
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
    LonelyStationUser *lonelyUser = _dataArray[indexPath.row];
    PersonalDetailInfoVC *personalVC = [[PersonalDetailInfoVC alloc] init];
    personalVC.lonelyUser = lonelyUser;
    [self.navigationController pushViewController:personalVC animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
