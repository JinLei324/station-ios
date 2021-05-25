//
//  MyFocousVC.m
//  LonelyStation
//
//  Created by zk on 16/9/5.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyFocousVC.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AllStationsCell.h"
#import "EMUtil.h"
#import "PersonalStationVC.h"
#import "MyFocousCell.h"
#import "EMAlertView.h"
#import "PersonalDetailInfoVC.h"
#import "PersonalDetailInfoOldVC.h"

@interface MyFocousVC()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,PersonalDetailInfoOldVCDelegate>{
    EMTableView *_tableView;
    MainViewVM *_mainViewVM;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
    BOOL _isLastPage;
}

@end

@implementation MyFocousVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"MyCare") andColor:RGB(145,90,173)];
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
    [_mainViewVM getFavoriteListWithBlock:^(NSArray<LonelyStationUser *> *arr, BOOL ret) {
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
    AllStationsCell *cell = (AllStationsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AllStationsCell alloc] initWithSize:CGSizeMake(kScreenW, 76*kScale) reuseIdentifier:cellIdentifier];
        
    }
    LonelyStationUser *obj = _dataArray[indexPath.row];
    cell.lonelyStationUser = obj;
    [cell hideOther];
    cell.lastOnlineLabel.text = [EMUtil getTimeToNow:obj.favoriteTime];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76*kScale;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Local(@"CancelCare") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        LonelyStationUser *lonelyUser = _dataArray[indexPath.row];
                                        //取消关注
                                        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"SureCancelCare") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                                            if (!cancelled) {
                                                [_mainViewVM deleteCareActionWithOtherId:lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
                                                    if (dict && ret) {
                                                        if ([dict[@"code"] intValue] == 1) {
                                                            [self.view.window makeToast:Local(@"CareCancelSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
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



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}


//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return Local(@"CancelCare");
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    LonelyStationUser *lonelyUser = _dataArray[indexPath.row];
//    PersonalDetailInfoVC *personalVC = [[PersonalDetailInfoVC alloc] init];
//    personalVC.lonelyUser = lonelyUser;
//    [self.navigationController pushViewController:personalVC animated:YES];

    LonelyStationUser *lonelyUser = _dataArray[indexPath.row];
    PersonalDetailInfoOldVC *personalVC = [[PersonalDetailInfoOldVC alloc] init];
    personalVC.lonelyUser = lonelyUser;
    personalVC.delegate = self;
    [self.navigationController pushViewController:personalVC animated:YES];
    
}

- (void)shouldReload:(LonelyStationUser*)aLoneyUser {
    
}




@end
