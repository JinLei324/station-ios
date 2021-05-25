//
//  AllStationsVC.m
//  LonelyStation
//
//  Created by zk on 16/9/5.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AllStationsVC.h"
#import "EMTableView.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AllStationsCell.h"
#import "PersonalStationVC.h"
#import "PersonalStationDetailVC.h"
#import "WYPopoverController.h"

@interface AllStationsVC ()<UITableViewDelegate,UITableViewDataSource,WYPopoverControllerDelegate,AllStationsCellDelegate> {
    EMTableView *_tableView;
    MainViewVM *_mainViewVM;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
    BOOL _isLastPage;
    WYPopoverController *popoverController;
    BoardCastType currentType;
    
}

@end

@implementation AllStationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"AllStation")];
    [self initView];
    _dataArray = [NSMutableArray array];
    _from = 0;
    _cnt = 10;
    currentType = BoardCastDefault;
    EMButton *moreBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 40 - 15 , 22, 40, 40)];
    [moreBtn setImage:[UIImage imageNamed:@"BTmore"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar addSubview:moreBtn];
}

- (void)more:(UIButton*)sender {
    UIViewController *controller = [[UIViewController alloc] init];
    //注释掉语音传情
    //    controller.preferredContentSize = CGSizeMake(100, 139);
    controller.preferredContentSize = CGSizeMake(100, 94);
    controller.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = Rect(0, 0, 88, 44);
    EMButton *searchBtn = [[EMButton alloc] initWithFrame: frame isRdius:NO];
    [searchBtn setTitle:Local(@"BestVoice") forState:UIControlStateNormal];
    [searchBtn.titleLabel setFont:ComFont(14)];
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn addTarget:self action:@selector(bestVoiceAction:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitleColor:RGB(128,128,128) forState:UIControlStateSelected];
    [searchBtn setTitleColor:RGB(0x03,0x29,0xac) forState:UIControlStateNormal];
    [controller.view addSubview:searchBtn];
    UIImageView *searchImgView = [[UIImageView alloc] initWithFrame:Rect(5, frame.origin.y+ (44-21)/2.f , 21, 21)];
    searchImgView.image = [UIImage imageNamed:@"bestVoice"];
    [controller.view addSubview:searchImgView];
    EMView *line1 = [[EMView alloc] initWithFrame:Rect(11, 44, 80, 1)];
    line1.backgroundColor = RGB(3,41,172);
    [controller.view addSubview:line1];
    
    frame.origin.y = 45;
    EMButton *articleBtn = [[EMButton alloc] initWithFrame: frame isRdius:NO];
    [articleBtn addTarget:self action:@selector(myboardcastAction:) forControlEvents:UIControlEventTouchUpInside];
    [articleBtn setTitle:Local(@"MyBoardCast") forState:UIControlStateNormal];
    articleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [articleBtn.titleLabel setFont:ComFont(14)];
    [articleBtn setTitleColor:RGB(128,128,128) forState:UIControlStateSelected];
    [articleBtn setTitleColor:RGB(0x03,0x29,0xac) forState:UIControlStateNormal];
    [controller.view addSubview:articleBtn];
    
    UIImageView *articleImgView = [[UIImageView alloc] initWithFrame:Rect(5, frame.origin.y+ (44-21)/2.f , 21, 21)];
    articleImgView.image = [UIImage imageNamed:@"myboardCast"];
    [controller.view addSubview:articleImgView];
    popoverController = [[WYPopoverController alloc] initWithContentViewController:controller];
    popoverController.delegate = self;
    [popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}


- (void)bestVoiceAction:(UIButton*)btn {
    [popoverController dismissPopoverAnimated:YES];
    currentType = BoardCastLike;
    _from = 0;
    [self loadData:YES];

}

- (void)myboardcastAction:(UIButton*)btn {
    [popoverController dismissPopoverAnimated:YES];
    currentType = BoardCastMine;
    _from = 0;
    [self loadData:YES];
}


- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    popoverController.delegate = nil;
    popoverController = nil;
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
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 63, kScreenW, 1)];
    line.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.8);
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
    [_mainViewVM getAllBoardCastWithBlock:^(NSArray<BoardcastObj *> *arr, BOOL ret) {
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
    } andBoardCastType:currentType andFrom:[NSString stringWithFormat:@"%d",_from] andCnt:[NSString stringWithFormat:@"%d",_cnt]];
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
    LonelyUser *me = [ViewModelCommom getCuttentUser];
    if ([me.gender isEqualToString:@"F"]) {
        obj.user.gender = @"M";
    }else {
        obj.user.gender = @"F";
    }
    cell.lonelyStationUser = obj.user;
    cell.boardcastObj = obj;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}



- (void)didClickPlayBtn:(UITableViewCell*)cell {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    BoardcastObj *obj = _dataArray[indexPath.row];
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.index =(int)indexPath.row;
    personalRecord.lonelyUser = obj.user;
    personalRecord.shouldPlay = YES;
    personalRecord.stationDataArray = _dataArray;
    [self.navigationController pushViewController:personalRecord animated:YES];
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
    personalRecord.isFromAllStation = YES;
    personalRecord.lonelyUser = obj.user;
    personalRecord.stationDataArray = _dataArray;
    personalRecord.index = (int)indexPath.row;
    [self.navigationController pushViewController:personalRecord animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
