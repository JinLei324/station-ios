//
//  MyRecordsViewController.m
//  LonelyStation
//
//  Created by zk on 16/8/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyRecordsViewController.h"
#import "EMTableView.h"
#import "RecordAiringVM.h"
#import "EMView.h"
#import "UIUtil.h"
#import "StandViewController.h"
#import "MyRecordsTableViewCell.h"
#import "SignalRecordShowVC.h"
#import "ViewModelCommom.h"

@interface MyRecordsViewController ()<UITableViewDelegate,UITableViewDataSource> {
    EMTableView *_tableView;
    RecordAiringVM *_recordAiring;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
}

@end

@implementation MyRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"MyRecord") andColor:RGB(145,90,173)];
    [self initView];
    _dataArray = [NSMutableArray array];
    _from = 0;
    _cnt = 10;
    // Do any additional setup after loading the view.
}


- (void)initView {
    _recordAiring = [[RecordAiringVM alloc] init];
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64 - 54*kScale)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
    _tableView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];

    [self createFootView];
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
    [_recordAiring getAllRecordAiringWithBlock:^(NSArray<BoardcastObj *> *arr, BOOL ret) {
        [self endRefesh];
        if (showHUD) {
            [UIUtil hideHUD:self.view];
        }
        if (arr && ret) {
            if (_from == 0) {
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:arr];
            [_tableView reloadData];
        }else {
            [self.view makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    } andFrom:[NSString stringWithFormat:@"%d",_from] andCnt:[NSString stringWithFormat:@"%d",_cnt]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData:YES];
}

-(void)endRefesh{
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}


- (void)createFootView {
    
    CGFloat hight = 54*kScale;
    CGFloat x = 26 * kScale;
    CGFloat y = 0;
    CGFloat lineWidth = kScreenW - 2 * x;
    CGFloat lineHight = 1;
    EMView *footView = [[EMView alloc] initWithFrame:Rect(0, kScreenH- hight, kScreenW, hight)];
    EMView *line = [[EMView alloc] initWithFrame:Rect(x, y, lineWidth, lineHight)];
    line.backgroundColor = RGB(171,171,171);
    [footView addSubview:line];
    
    CGFloat labelHight = 14;
    EMButton *ruleBtn = [[EMButton alloc] initWithFrame:Rect(x, PositionY(line) + 20 * kScale, lineWidth, labelHight)];
    ruleBtn.alpha = 0.8;
    ruleBtn.titleLabel.font = ComFont(13);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:Local(@"PlsObserveRule")];
    [str
     addAttribute:NSForegroundColorAttributeName value:RGB(145,90,173) range:NSMakeRange(Local(@"PlsObserveRule").length-Local(@"Standed").length,Local(@"Standed").length)];
    [str
     addAttribute:NSForegroundColorAttributeName value:RGB(51, 51, 51) range:NSMakeRange(0,Local(@"PlsObserveRule").length-Local(@"Standed").length)];
    [ruleBtn setAttributedTitle:str forState:UIControlStateNormal];
    [ruleBtn addTarget:self action:@selector(standAction:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:ruleBtn];
    [self.view addSubview:footView];
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    MyRecordsTableViewCell *cell = (MyRecordsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MyRecordsTableViewCell alloc] initWithSize:Size(kScreenW, 73*kScale) reuseIdentifier:cellIdentifier];
        
    }
    BoardcastObj *obj = _dataArray[indexPath.row];
    cell.user = [ViewModelCommom getCuttentUser];
    cell.boardcastObj = obj;
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73*kScale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BoardcastObj *obj = _dataArray[indexPath.row];
    SignalRecordShowVC *signalRecord = [[SignalRecordShowVC alloc] init];
    signalRecord.boardcastObj = obj;
    [self.navigationController pushViewController:signalRecord animated:YES];
}


- (void)standAction:(id)sender {
    StandViewController *standController = [[StandViewController alloc] init];
    standController.backStr = Local(@"IKnowAndandBack");
    [self.navigationController pushViewController:standController animated:YES];
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
