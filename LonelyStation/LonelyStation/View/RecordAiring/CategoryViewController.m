//
//  MyRecordsViewController.m
//  LonelyStation
//
//  Created by zk on 16/8/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "CategoryViewController.h"
#import "EMTableView.h"
#import "EMView.h"
#import "UIUtil.h"
#import "StandViewController.h"

@interface  CategoryViewController()<UITableViewDelegate,UITableViewDataSource> {
    EMTableView *_tableView;
    RecordAiringVM *_recordAiring;
    NSMutableArray *_dataArray;
}

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    [self.viewNaviBar setTitle:Local(@"SelectCategory") andColor:RGB(145,90,173)];
    [self initView];
    // Do any additional setup after loading the view.
}


- (void)initView {
    _recordAiring = [[RecordAiringVM alloc] init];
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIUtil showHUD:self.view];
    [_recordAiring getCategoryWithBlock:^(NSArray<RecordBigCategoryObj *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:arr];
            [_tableView reloadData];
        }else {
            [self.view makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(20, 0, kScreenW - 40, 44)];
        label.tag = 100;
        label.font = ComFont(14);
        label.textColor = [UIColor blackColor];
        [cell.contentView addSubview:label];
    }
    RecordBigCategoryObj *category = [_dataArray objectAtIndex:indexPath.section];
    RecordCategoryObj *cate = [category.categoryArr objectAtIndex:indexPath.row];
//    cell.backgroundColor = [UIColor clearColor];
    EMLabel *label = [cell.contentView viewWithTag:100];
    label.text = cate.categoryName;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RecordBigCategoryObj *category = [_dataArray objectAtIndex:section];
    if (category) {
        return category.categoryArr.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    RecordBigCategoryObj *category = [_dataArray objectAtIndex:section];
    UIView *view = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenW, 44)];
    view.backgroundColor = RGB(123,76,143);
    EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(11, 0, kScreenW-22, 44)];
    label.textColor = [UIColor whiteColor];
    label.font = BoldFont(16);
    label.text = category.categoryName;
    [view addSubview:label];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectCategory:andController:)]) {
        RecordBigCategoryObj *category = [_dataArray objectAtIndex:indexPath.section];
        RecordCategoryObj *cate = [category.categoryArr objectAtIndex:indexPath.row];
        [_delegate didSelectCategory:cate andController:self];
        [self.navigationController popViewControllerAnimated:YES];
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
