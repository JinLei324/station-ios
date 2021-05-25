//
//  MyRecordsViewController.m
//  LonelyStation
//
//  Created by zk on 16/8/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "InnerImgViewController.h"
#import "EMTableView.h"
#import "EMView.h"
#import "UIUtil.h"
#import "StandViewController.h"

@interface  InnerImgViewController()<UITableViewDelegate,UITableViewDataSource> {
    EMTableView *_tableView;
    RecordAiringVM *_recordAiring;
    NSMutableArray *_dataArray;
}

@end

@implementation InnerImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"SelectInnerImg") andColor:RGB(145,90,173)];
    [self initView];
    // Do any additional setup after loading the view.
}


- (void)initView {
    _recordAiring = [[RecordAiringVM alloc] init];
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _dataArray = [NSMutableArray array];
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIUtil showHUD:self.view];
    [_recordAiring getInnerImgWithBlock:^(NSArray<InnerRecBgImgObj *> *arr, BOOL ret) {
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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:Rect(0, 0, kScreenW, 221*kScale)];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
    }
    InnerRecBgImgObj *innnerBgImg = [_dataArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = [cell.contentView viewWithTag:100];
    [imageView yy_setImageWithURL:[NSURL URLWithString:innnerBgImg.fileUrl] options:YYWebImageOptionShowNetworkActivity];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 221 * kScale;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectInnerImg:andController:)]) {
        InnerRecBgImgObj *innnerBgImg = [_dataArray objectAtIndex:indexPath.row];
        [_delegate didSelectInnerImg:innnerBgImg andController:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)standAction:(id)sender {
    StandViewController *standController = [[StandViewController alloc] init];
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
