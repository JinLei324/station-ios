//
//  SignalRecordShowVC.m
//  LonelyStation
//
//  Created by zk on 16/8/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "SignalRecordShowVC.h"
#import "UICycleImgView.h"
#import "ViewModelCommom.h"
#import "EMLabel.h"
#import "EMView.h"
#import "EMAlertView.h"
#import "RecordAiringVM.h"
#import "EMUtil.h"
#import "VoiceSliderView.h"
#import "AudioRemotePlayView.h"
#import "EMTableView.h"
#import "RateCell.h"
#import "UIUtil.h"
#import "MainViewVM.h"
#import "EMTextView.h"

@interface SignalRecordShowVC ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate> {
    AudioRemotePlayView *_audioPlayerView;
    RecordAiringVM *_recordAiringVM;
    EMTableView *_rateTableView;
    NSMutableArray *_dataArray;
    MainViewVM *_mainViewVM;
    BoardcastObj *_boardcastObjDetail;
    EMTextView *_commentTextView;
}

@property (nonatomic,strong)EMLabel *nameLabel;

@property (nonatomic,strong)EMLabel *collectLabel;

@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)UIImageView *backImgView;

@property (nonatomic,strong)EMButton *playBtn;

@property (nonatomic,strong)EMLabel *playLabel;

@property (nonatomic,strong)EMButton *sayGoodBtn;

@property (nonatomic,strong)EMLabel *sayGoodLabel;

@property (nonatomic,strong)EMButton *rateBtn;

@property (nonatomic,strong)EMLabel *rateLabel;

@property (nonatomic,strong)EMButton *deleteBtn;

@property (nonatomic,strong)EMLabel *deleteLabel;

@property (nonatomic,strong)VoiceSliderView *slideView;

@property (nonatomic,strong)EMButton *isChargeBtn;

@property (nonatomic,strong)EMLabel *isChargeLabel;

@end

@implementation SignalRecordShowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"MyRecord") andColor:RGB(145,90,173)];

    [self initView];
    
    _recordAiringVM = [[RecordAiringVM alloc] init];
    _mainViewVM = [[MainViewVM alloc] init];
    
    [self getBasicInfo:_boardcastObj.recordId];
    // Do any additional setup after loading the view.
}

- (void)setBoardcastObj:(BoardcastObj *)boardcastObj {
    _boardcastObj = nil;
    _boardcastObj = boardcastObj;
  
}

- (void)rateAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    _rateTableView.hidden = btn.selected;
}

- (void)getBasicInfo:(NSString*)recordId {
    [UIUtil showHUD:self.navigationController.view];
    //获取该广播的基本信息
    [_mainViewVM getRecordInfo:_boardcastObj.recordId andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.navigationController.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                _boardcastObjDetail = nil;
                _boardcastObjDetail = [[BoardcastObj alloc] initWithJSONDict:dict[@"data"]];
                _rateLabel.text = [NSString stringWithFormat:@"%d",_boardcastObjDetail.comments.intValue];
                _sayGoodLabel.text = [NSString stringWithFormat:@"%d",_boardcastObjDetail.likes.intValue];
                //获取该广播的所有评论
                [UIUtil showHUD:self.navigationController.view];
                [_dataArray removeAllObjects];
                [_mainViewVM getRateListByRecordId:recordId andBlock:^(NSArray *array, BOOL ret) {
                    if (array) {
                        [_dataArray addObjectsFromArray:array];
                        [_rateTableView reloadData];
                    }
                    [UIUtil hideHUD:self.navigationController.view];
                }];
            }
        }
    }];
}


//textView的委托
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location>50)
    {
        return  NO;
    }
    else
    {
        return YES;
    }
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:Local(@"IWantRate")]) {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = Local(@"IWantRate");
    }
}

- (void)initView {
    _dataArray = [NSMutableArray array];
    UIScrollView *backView = [[UIScrollView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH)];
    
    UICycleImgView *headImgView = [[UICycleImgView alloc] initWithFrame:Rect(11*kScale, 10*kScale, 42*kScale, 42*kScale)];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [headImgView yy_setImageWithURL:[NSURL URLWithString:[ViewModelCommom getCurrentHeadImgPath]] placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:user.gender]]];
    [backView addSubview:headImgView];
    
    _nameLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(headImgView) + 14*kScale, headImgView.frame.origin.y + 5*kScale, 150, 12*kScale)];
    _nameLabel.text = [NSString stringWithFormat:@"%@:%@",@"角色",[[ViewModelCommom getCuttentUser] nickName]];
    _nameLabel.textColor = RGB(51,51,51);
    _nameLabel.font = ComFont(11*kScale);
    [backView addSubview:_nameLabel];
    
    _collectLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(headImgView) + 14*kScale, PositionY(_nameLabel)+10*kScale, 180, 12*kScale)];
    _collectLabel.textColor = RGB(145,90,173);
    _collectLabel.font = ComFont(11*kScale);
    _collectLabel.text = [NSString stringWithFormat:@"%@:%@",Local(@"ThisAiringCollect"),@"123 USD"];

    [backView addSubview:_collectLabel];
    
    _isChargeLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 150 - 12*kScale - 43*kScale, headImgView.frame.origin.y + 5*kScale, 150, 12*kScale)];
    _isChargeLabel.textColor = RGB(51,51,51);
    _isChargeLabel.font = ComFont(11*kScale);
    _isChargeLabel.text = Local(@"IsCharge");
    _isChargeLabel.textAlignment = NSTextAlignmentRight;
    [backView addSubview:_isChargeLabel];
    
    _isChargeBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 12 *kScale - 43*kScale, headImgView.frame.origin.y, 43*kScale, 21*kScale)];
    [_isChargeBtn setImage:[UIImage imageNamed:@"set_off"] forState:UIControlStateNormal];
    [_isChargeBtn setImage:[UIImage imageNamed:@"set_on"] forState:UIControlStateSelected];
    [_isChargeBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_isChargeBtn];
    if (_boardcastObj.isCharge && [_boardcastObj.isCharge isEqualToString:@"Y"]) {
        [_isChargeBtn setSelected:YES];
    }
    
    CGFloat timelabelWidth = 150;
    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW - timelabelWidth - 12*kScale, PositionY(_nameLabel)+10*kScale, timelabelWidth, 12*kScale)];
    _timeLabel.textColor = RGB(51,51,51);
    _timeLabel.font = ComFont(11*kScale);
    _timeLabel.text = [EMUtil getTimeToNow:_boardcastObj.updateTime];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [backView addSubview:_timeLabel];
    
    
    _nameLabel.text = [NSString stringWithFormat:@"%@:%@",[user identityName],[user nickName]];
    
    _collectLabel.text = [NSString stringWithFormat:@"%@:%@ USD",Local(@"ThisAiringCollect"),_boardcastObj.profit];
//    NSString *str = [[[FileAccessData sharedInstance] objectForEMKey:@"isChecking"] lastObject];
//    if ([str isEqualToString:@"0"]) {
        _collectLabel.hidden = NO;
//    }else{
//        _collectLabel.hidden = YES;
//        
//    }
    _timeLabel.text = [EMUtil getTimeToNow:_boardcastObj.updateTime];

    _backImgView = [[UIImageView alloc] initWithFrame:Rect(0, PositionY(_timeLabel)+8*kScale, kScreenW, 221*kScale)];
    [_backImgView yy_setImageWithURL:[NSURL URLWithString:_boardcastObj.backImgURL] placeholder:[UIImage imageNamed:@"answer_no_photo"]];
    [backView addSubview:_backImgView];
    
    EMView *titleBackView = [[EMView alloc] initWithFrame:Rect(0, PositionY(_timeLabel)+24*kScale, 216*kScale, 45*kScale)];
    titleBackView.backgroundColor = RGBA(0,0,0,0.3);
    [backView addSubview:titleBackView];
    
    EMLabel *titleLabel =[[EMLabel alloc] initWithFrame:Rect(23*kScale, PositionY(_timeLabel)+24*kScale, 193*kScale, 45*kScale)];
    titleLabel.textColor = RGB(51,51,51);
    titleLabel.text = _boardcastObj.title;
    titleLabel.font = ComFont(13*kScale);
    [backView addSubview:titleLabel];
    
    CGFloat x = 26*kScale;
    CGFloat width = 43 *kScale;
    CGFloat space = (kScreenW - 2 * x - 4 * width) / 3.f;
    
    _playBtn = [[EMButton alloc] initWithFrame:Rect(x, PositionY(headImgView) + 179 * kScale, width, width) isRdius:YES];
    [_playBtn setImage:[UIImage imageNamed:@"enjoyPlay"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"enjoyStop"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:_playBtn];
    
    
    _sayGoodBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_playBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_sayGoodBtn setImage:[UIImage imageNamed:@"enjoyGood"] forState:UIControlStateNormal];
    [_sayGoodBtn setImage:[UIImage imageNamed:@"enjoyGood_d"] forState:UIControlStateSelected];

    [backView addSubview:_sayGoodBtn];
    
    
    _rateBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_sayGoodBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_rateBtn setImage:[UIImage imageNamed:@"enjoyMessage"] forState:UIControlStateNormal];
    [_rateBtn setImage:[UIImage imageNamed:@"enjoyMessage_d"] forState:UIControlStateSelected];
    [_rateBtn addTarget:self action:@selector(rateAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_rateBtn];
    
    _deleteBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_rateBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_deleteBtn setImage:[UIImage imageNamed:@"enjoy_delete"] forState:UIControlStateNormal];
    [_deleteBtn setImage:[UIImage imageNamed:@"enjoy_delete_d"] forState:UIControlStateHighlighted];
    [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_deleteBtn];
    
    
    EMView *lableBack = [[EMView alloc] initWithFrame:Rect(0, PositionY(_playBtn)+3*kScale, kScreenW, 21*kScale)];
    lableBack.backgroundColor = RGBA(0x0, 0x0, 0x0,0.3);
    [backView addSubview:lableBack];
    
     _playLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_playBtn)+3*kScale, 42*kScale, 21*kScale)];
    _playLabel.textAlignment = NSTextAlignmentCenter;
    _playLabel.textColor = RGB(0xff, 0xff, 0xff);
    _playLabel.font = ComFont(11*kScale);
    _playLabel.text = Local(@"Play");
    [backView addSubview:_playLabel];
    
    _sayGoodLabel = [[EMLabel alloc] initWithFrame:Rect(_sayGoodBtn.frame.origin.x, PositionY(_sayGoodBtn)+3*kScale, 42*kScale, 21*kScale)];
    _sayGoodLabel.textAlignment = NSTextAlignmentCenter;
    _sayGoodLabel.text = _boardcastObj.likes;
    _sayGoodLabel.textColor = RGB(0xff, 0xff, 0xff);
    _sayGoodLabel.font = ComFont(11*kScale);
    [backView addSubview:_sayGoodLabel];
    
    _rateLabel = [[EMLabel alloc] initWithFrame:Rect(_rateBtn.frame.origin.x, PositionY(_rateBtn)+3*kScale, 42*kScale, 21*kScale)];
    _rateLabel.textAlignment = NSTextAlignmentCenter;
    _rateLabel.text = _boardcastObj.comments;
    _rateLabel.textColor = RGB(0xff, 0xff, 0xff);
    _rateLabel.font = ComFont(11*kScale);
    [backView addSubview:_rateLabel];
    
    _deleteLabel = [[EMLabel alloc] initWithFrame:Rect(_deleteBtn.frame.origin.x, PositionY(_deleteBtn)+3*kScale, 42*kScale, 21*kScale)];
    _deleteLabel.textAlignment = NSTextAlignmentCenter;
    _deleteLabel.textColor = RGB(0xff, 0xff, 0xff);
    _deleteLabel.text = Local(@"Delete");
    _deleteLabel.font = ComFont(11*kScale);
    [backView addSubview:_deleteLabel];
    
    
    _audioPlayerView = [[AudioRemotePlayView alloc] initWithFrame:Rect(26*kScale, PositionY(_deleteLabel), kScreenW - 52*kScale, 52 * kScale)];
    WS(weakSelf);
    _audioPlayerView.audioBok = ^(float currentTime,float allTime,BOOL isStop){
        if (isStop) {
            [weakSelf.playBtn setSelected:NO];
        }else {
            [weakSelf.playBtn setSelected:YES];
        }
    };
    _audioPlayerView.isShowLabel = YES;
    [backView addSubview:_audioPlayerView];
    _audioPlayerView.allTime = [EMUtil getAudioSecWithURL:_boardcastObj.audioURL];
    _audioPlayerView.isShowLabel = YES;
    [self.view addSubview:backView];
    
    
    //评论tableView
    CGFloat height = backView.bounds.size.height + (-1) * PositionY(_audioPlayerView) - 10  - 64;
    _rateTableView = [[EMTableView alloc] initWithFrame:Rect(0, PositionY(_audioPlayerView) + 10, kScreenW, height) style:UITableViewStyleGrouped];
    _rateTableView.delegate = self;
    _rateTableView.dataSource = self;
    _rateTableView.estimatedRowHeight = 50*kScale;
    [backView addSubview:_rateTableView];
    _rateTableView.hidden = NO;
    _rateTableView.backgroundColor = [UIColor clearColor];
}


- (void)switchAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    NSString *isCharge = @"N";
    if (btn.selected) {
        if (btn.selected) {
            if ([_boardcastObjDetail.duration intValue] < 300) {
                [self.view makeToast:Local(@"CantSetCharge") duration:ERRORTime position:[CSToastManager defaultPosition]];
                btn.selected = NO;
                return;
            }
        }
        isCharge = @"Y";
    }
    [UIUtil showHUD:self.view];
    WS(weakSelf)
    [_mainViewVM setRecordisCharge:_boardcastObj.recordId isCharge:isCharge andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:weakSelf.view];
        if (dict && ret) {
            [weakSelf.navigationController.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];

        }else {
            btn.selected = !btn.selected;
            [weakSelf.navigationController.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    RateCell *cell = (RateCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[RateCell alloc] initWithSize:Size(kScreenW, 60*kScale) reuseIdentifier:cellIdentifier];
        
    }
    cell.user = (LonelyStationUser*)[ViewModelCommom getCuttentUser];
    RateObj *obj = _dataArray[indexPath.row];
    cell.rateObj = obj;
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50*kScale;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    EMView *view = [[EMView alloc] initWithFrame:Rect(0, 0, kScreenW, 50*kScale)];
    UICycleImgView *imgView = [[UICycleImgView alloc] initWithFrame:Rect(11*kScale, 10*kScale, 30*kScale, 30*kScale)];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [imgView yy_setImageWithURL:[NSURL URLWithString:user.file] placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:user.gender]]];
    [view addSubview:imgView];
    
    CGFloat x = PositionX(imgView)+11*kScale;
    CGFloat width = kScreenW - x - 11 - 33*kScale;
    if (!_commentTextView) {
        _commentTextView = [[EMTextView alloc] initWithFrame:Rect(x, 5, width, 50*kScale - 10)];
        _commentTextView.text = Local(@"IWantRate");
    }
    _commentTextView.frame = Rect(x, 11*kScale, width, 50*kScale - 22*kScale);
    _commentTextView.textColor = RGB(51,51,51);
    _commentTextView.layer.backgroundColor = RGB(200, 200, 200).CGColor;
    _commentTextView.font = ComFont(11);
    _commentTextView.layer.cornerRadius = 14*kScale;
    
    _commentTextView.delegate = self;
    [view addSubview:_commentTextView];
    
    EMButton *btn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 11 - 28*kScale, 13*kScale, 24*kScale, 24*kScale)];
    [btn setImage:[UIImage imageNamed:@"enjoy_send"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sendRate:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    view.backgroundColor = RGB(0xff, 0xff, 0xff);
    [UIUtil addLineWithSuperView:view andRect:Rect(0, 50*kScale-0.5, kScreenW, 0.5) andColor:RGB(200,200,200)];

    return view;
    
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 50*kScale;
//}

- (void)deleteAction:(EMButton*)btn {
    EMAlertView *alert = [[EMAlertView alloc] initWithTitle:Local(@"Warning") message: Local(@"MakeSureDeleteAiring") clickedBlock:^(EMAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [_recordAiringVM deleteRecordWithRecordId:_boardcastObj.recordId andBlock:^(NSDictionary *dict, BOOL ret) {
                if (dict && ret) {
                    if ([dict[@"code"] isEqualToString:@"1"]) {
                        [self.view.window makeToast:Local(@"DeleteSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                        [self.navigationController popViewControllerAnimated:YES];
                    }else {
                        [self.view makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                    }
                }else {
                    [self.view makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
            }];
        }
    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
    [alert show];
}


- (void)playAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        NSArray *fileArray = nil;
        NSArray *timeArray = nil;
        if (_boardcastObj.effectFile1URL && _boardcastObj.effectFile2URL) {
            fileArray = @[_boardcastObj.effectFile1URL,_boardcastObj.effectFile2URL];
            timeArray = @[_boardcastObj.effectFile1StartTime,_boardcastObj.effectFile2StartTime];
        }else if (_boardcastObj.effectFile1URL){
            fileArray = @[_boardcastObj.effectFile1URL];
            timeArray = @[_boardcastObj.effectFile1StartTime];
        }
        [_audioPlayerView playRemoteAudios:_boardcastObj.audioURL isBackRemote:YES andOthers:fileArray andTimeArray:timeArray];
    }else {
        [_audioPlayerView stopRemoteAudio];
    }
}


//发送留言
- (void)sendRate:(EMButton*)btn {
    [self.view endEditing:YES];
    if (_commentTextView.text.length >= 3 && _commentTextView.text.length <= 100) {
        [_mainViewVM sendRate:_boardcastObj.recordId andComment:_commentTextView.text andBlock:^(NSDictionary *dict, BOOL ret) {
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    [self.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                    _commentTextView.text = @"";
                    [self getBasicInfo:_boardcastObj.recordId];
                }else {
                    [self.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                    
                }
            }else {
                [self.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
            }
        }];
    }else {
        [self.view makeToast:Local(@"PlsInputWords3to100") duration:1 position:[CSToastManager defaultPosition]];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
