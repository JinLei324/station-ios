//
//  EffectSelectViewController.m
//  LonelyStation
//
//  Created by zk on 16/8/18.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EffectSelectViewController.h"
#import "EMTableView.h"
#import "EMView.h"
#import "UIUtil.h"
#import "RecordAiringVM.h"
#import "AudioPlayerVM.h"

@interface EffectSelectViewController ()<UITableViewDelegate,UITableViewDataSource> {
    EMTableView *_tableView;
    RecordAiringVM *_recordAiring;
    NSMutableArray *_dataArray;
    AudioPlayerVM *_audioPlayer;
    EMButton *_currentPlayBtn;
}


@end

@implementation EffectSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"SelectEffect")];
    [self initView];
    // Do any additional setup after loading the view.
}


- (void)initView {
    _recordAiring = [[RecordAiringVM alloc] init];
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.tableFooterView = [[UIView alloc] init];
    _dataArray = [NSMutableArray array];
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _audioPlayer = [[AudioPlayerVM alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIUtil showHUD:self.view];
    [_recordAiring getEffectWithBlock:^(NSArray<BgAudioObj *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:arr];
            [_tableView reloadData];
        }else {
            [self.view makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
    
//    //测试数据
//    BgAudioObj *bgAudio = [[BgAudioObj alloc] init];
//    bgAudio.fileURL = @"http://data.5sing.kgimg.com/G061/M0A/03/13/HZQEAFb493iAOeg5AHMiAfzZU0E739.mp3";
//    bgAudio.desc = @"你大爷的测试";
//    [_dataArray removeAllObjects];
//    [_dataArray addObject:bgAudio];
//    [_tableView reloadData];
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
        label.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:label];
        
        CGFloat width = 21*kScale;
        CGFloat x = kScreenW - width - 14 * kScale;
        CGFloat y = 12*kScale;
        EMButton *playBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, width)];
        [playBtn setImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"record_stop"] forState:UIControlStateSelected];
        [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        playBtn.tag = 101;
        [cell.contentView addSubview:playBtn];
        
        EMView *line = [[EMView alloc] initWithFrame:Rect(0, 44*kScale - 0.5, kScreenW, 0.5)];
        line.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.7);
        [cell.contentView addSubview:line];
    }
    BgAudioObj *bgAudio = [_dataArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    EMLabel *label = [cell.contentView viewWithTag:100];
    label.text = bgAudio.desc;
    EMButton *btn = [cell.contentView viewWithTag:101];
    btn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    return cell;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_audioPlayer.isPlaying) {
        [_audioPlayer stopRemoteAudio];
    }
}


- (void)playAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        if (_currentPlayBtn) {
            _currentPlayBtn.selected = NO;
        }
        BgAudioObj *bgAudio = [_dataArray objectAtIndex:[btn.titStr integerValue]];
        [_audioPlayer playRemoteAudio:bgAudio.fileURL andBlock:^(float currentTime, float allTime, BOOL isStop) {
            if (isStop) {
                btn.selected = NO;
            }
        } andAllTime:@""];
        _currentPlayBtn = btn;
    }else {
        [_audioPlayer stopRemoteAudio];
        _currentPlayBtn = nil;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44 * kScale;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectEffect:andController:)]) {
        BgAudioObj *bgAudio = [_dataArray objectAtIndex:indexPath.row];
        [_delegate didSelectEffect:bgAudio andController:self];
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
