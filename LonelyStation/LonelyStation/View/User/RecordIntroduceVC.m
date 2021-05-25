//
//  RecordIntroduceVC.m
//  LonelyStation 录制自介，罐头音
//
//  Created by zk on 2016/10/21.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RecordIntroduceVC.h"
#import "UIUtil.h"
#import "RecordWaveView.h"
#import "AudioPlayView.h"
#import "AudioPublicMethod.h"
#import "AudioRecordVM.h"
#import "UserViewModel.h"
#import "ViewModelCommom.h"

@interface RecordIntroduceVC ()<EMAudioRecordDelegate>{
    long long _totalTime;
    NSString *_audioPath;
    UserViewModel *_userMainModel;
}

@property (nonatomic,strong)EMLabel *recordStartTime;

@property (nonatomic,strong)EMLabel *recordEndTime;

@property (nonatomic,strong)RecordWaveView *waveView;

@property (nonatomic,strong)AudioPlayView *recordAudioPlayView;

@property (nonatomic,strong)EMButton *recordBtn;

@property (nonatomic,strong)EMButton *playBtn;

@property (nonatomic,strong)EMButton *deleteBtn;

@property (nonatomic,strong)AudioRecordVM *audioRecordVM;




@end

@implementation RecordIntroduceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_seq == 1) {
        [self.viewNaviBar setTitle:Local(@"IntroduVoice") andColor:RGB(145,90,173)];
    }else{
        [self.viewNaviBar setTitle:Local(@"CanVoice") andColor:RGB(145,90,173)];
    }
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)back:(id)sender {
    [_audioRecordVM endToRecordAudio];
    if (_recordAudioPlayView) {
        [_recordAudioPlayView stopLocalAudio];
    }
    [super back:sender];
}

- (void)initViews {
    _userMainModel = [[UserViewModel alloc] init];
    
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 70*kScale, 30)];

    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    [buyBtn.layer setBackgroundColor:RGB(145,90,173).CGColor];
    [buyBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Complate") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(complateAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    
    EMLabel *infoLabel = [UIUtil createLabel:Local(@"IntroduceStr") andRect:Rect(22, 64+22, kScreenW-44, 40*kScale) andTextColor:RGB(51,51,51) andFont:ComFont(15*kScale) andAlpha:0.8];
    infoLabel.numberOfLines = 0 ;
    [self.view addSubview:infoLabel];
    
    //录音区域
    CGFloat x = 22;
    CGFloat y = 0.43*kScreenH;
    CGFloat width = kScreenW - 2*x;
    CGFloat height = 10*kScale;
    _recordStartTime = [UIUtil createLabel:@"00:00" andRect:Rect(x, y, width, height) andTextColor:RGB(145,90,173) andFont:ComFont(11*kScale) andAlpha:0.6];
    [self.view addSubview:_recordStartTime];
    
    
    _recordEndTime = [UIUtil createLabel:@"00:00" andRect:Rect(kScreenW-x -width, y, width, height) andTextColor:RGB(145,90,173) andFont:ComFont(11*kScale) andAlpha:0.6];
    _recordEndTime.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_recordEndTime];
    _recordEndTime.hidden = YES;
    
    height = 31*kScale;
    _waveView = [[RecordWaveView alloc] initWithFrame:Rect(x, PositionY(_recordStartTime) + 9 * kScale, width, height)];
    [self.view addSubview:_waveView];
    
    //播放录音的view 先隐藏
    _recordAudioPlayView = [[AudioPlayView alloc] initWithFrame:Rect(x, PositionY(_recordStartTime) + 9 * kScale, width, height)];
    [self.view addSubview:_recordAudioPlayView];
    _recordAudioPlayView.hidden = YES;
    
    //录音键
    CGFloat btnWidth = 47 * kScale;
    CGFloat btnHight = 47 * kScale;
    
    CGFloat aSpace = 24*kScale;
    if (iphone5x_4_0) {
        aSpace = 12 * kScale;
    }
    _recordBtn = [[EMButton alloc] initWithFrame:Rect((kScreenW-btnWidth)*0.5, PositionY(_waveView) + aSpace, btnWidth, btnHight)];
    [_recordBtn setImage:[UIImage imageNamed:@"Introduction_recording"] forState:UIControlStateNormal];
    [_recordBtn setImage:[UIImage imageNamed:@"Introduction_record_stop"] forState:UIControlStateSelected];
    [_recordBtn addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBtn];
    
    //播放键
    _playBtn = [[EMButton alloc] initWithFrame:Rect(_recordBtn.frame.origin.x - 57*kScale - btnWidth, PositionY(_waveView) + aSpace, btnWidth, btnHight)];;
    [_playBtn setImage:[UIImage imageNamed:@"Introduction_play"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"btn_playstop"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];

    x = PositionX(_recordBtn) + 57*kScale;
    _deleteBtn = [[EMButton alloc] initWithFrame:Rect(x, PositionY(_waveView) + aSpace, btnWidth, btnHight)];
    [_deleteBtn setImage:[UIImage imageNamed:@"Introduction_delete"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    
    
    _audioRecordVM = [[AudioRecordVM alloc] init];
    _audioRecordVM.delegate = self;
    [self setRecording:YES];
    
    
    //线
    y = kScreenH - 75*kScale;
    x = 20 * kScale;
    width = kScreenW - 2 * x;
    EMView *line = [[EMView alloc] initWithFrame:Rect(x, y, width, 1)];
    line.backgroundColor = RGB(171,171,171);
    [self.view addSubview:line];
    
    y = PositionY(line) + 29*kScale;
    EMLabel *despLabel = [[EMLabel alloc] initWithFrame:Rect(x, y, width, 15*kScale)];
    despLabel.attributedText = [EMUtil getAttributedStringWithAllStr:Local(@"AlarmDesp") andAllBackGroudColor:RGB(171,171,171) andSepcialStr:Local(@"Time") andSpecialColor:RGB(209,172,255)];
    despLabel.font = ComFont(15*kScale);
    despLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:despLabel];


}


- (void)deleteAction:(EMButton*)btn {
    if (_audioPath) {
        //        弹出确认删除的对话框
        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"MakeSureDeleteRecord") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                //        先完成
                [UIUtil showHUD:self.view];
                [_audioRecordVM actionButtonClick];
                [self performSelector:@selector(audioDelete) withObject:nil afterDelay:1];
            }
        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
        [alert show];
    }else {
        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
        
    }
}

- (void)audioDelete {
    [_audioRecordVM deleteVedioNamed:_audioPath];
    [_waveView clearSample];
    [_waveView resetRightOrgin];
    _recordStartTime.text = @"00:00";
    _recordEndTime.text = @"00:00";
    _audioRecordVM.totalSeconds = 0;
    _audioPath = nil;
    _recordAudioPlayView.hidden = YES;
    _waveView.hidden = NO;
    [UIUtil hideHUD:self.view];
    [self.view makeToast:Local(@"DeleteSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
}


- (void)setRecording:(BOOL)ret {
    _playBtn.enabled = !ret;
    _deleteBtn.enabled = !ret;
}

- (void)setPlaying:(BOOL)ret {
    _deleteBtn.enabled = !ret;
    _recordBtn.enabled = !ret;
}


- (void)playAction:(EMButton*)btn {
    //判断有没有录音，有录音就播放
    if (!_audioPath) {
        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    [btn setSelected:!btn.selected];
    //如果在播放，其他按钮先屏蔽掉，反之，打开
    [self setPlaying:btn.selected];
    
    if(btn.selected){
        //播放
        //把总长传过去
        [_recordAudioPlayView setHidden:NO];
        [_waveView setHidden:YES];
        NSString *path = [AudioPublicMethod getPathByFileName:_audioPath ofType:@"wav"];
        [_recordAudioPlayView playLocalAudio:path andBlock:^(float currentTime, float allTime, BOOL isStop) {
            int seconds = (int)currentTime % 60;
            int minutes = ((int)currentTime / 60) % 60;
            NSString *leftText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
            _recordStartTime.text = leftText;
            seconds = (int)allTime % 60;
            minutes = ((int)allTime / 60) % 60;
            if (seconds > 15) {
                seconds = 15;
            }
            NSString *rightText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
            _recordEndTime.text = rightText;
            _recordEndTime.hidden = NO;
            
            if (isStop) {
                [_recordAudioPlayView stopLocalAudio];
                btn.selected = NO;
                [self setPlaying:btn.selected];
            }else {
                btn.selected = YES;
                [self setPlaying:btn.selected];
            }
        }];
    }else{
        [_recordAudioPlayView stopLocalAudio];
    }

}


- (void)recordAction:(EMButton*)btn {
    //先判断有没有权限
    if (![UIUtil haveDeviceAuthorization]){
        [UIUtil showDeviceWarning];
        return;
    }
    //如果超过了15秒，不准录了
    NSArray *arr = [_recordStartTime.text componentsSeparatedByString:@":"];
    NSString *str = [arr objectAtIndex:1];
    NSArray *arr1 = [_recordEndTime.text componentsSeparatedByString:@":"];
    NSString *str1 = @"0";
    if (arr1 && arr1.count == 2) {
        str1 = [arr1 objectAtIndex:1];
    }
    if ([str intValue] >= 15 || [str1 intValue] >= 15) {
        btn.selected = NO;
        [self.view makeToast:Local(@"AlarmDesp") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    [self recordAct:btn];

}


- (void)recordAct:(EMButton*)btn {
    [btn setSelected:!btn.selected];
    //如果在录音，其他按钮先屏蔽掉，反之，打开
    [self setRecording:btn.selected];
    if (btn.selected) {
        [_waveView stopPlay];
    }
    _recordAudioPlayView.hidden = YES;
    _waveView.hidden = NO;
    [_waveView startRecord];
    [_audioRecordVM recordButtonClick];
}

- (void)complateAction:(EMButton*)btn {
    //判断有没有录音，没有录音不能添加
    if (!_audioPath) {
        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    NSData *audioData = [_audioRecordVM getData:_audioPath];
    [UIUtil showHUD:self.view];
    [_userMainModel uploadVoice:audioData andSeq:[NSString stringWithFormat:@"%d",_seq] andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                //更新user
                if (_seq == 1) {
                    LonelyUser *user = [ViewModelCommom getCuttentUser];
                    user.voice = @"1";
                    [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                }
                [self.view.window makeToast:Local(@"OperateSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                [self.view makeToast:Local(@"OperateFailed") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else {
            [self.view makeToast:Local(@"OperateFailed") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];

}

#pragma mark AudioRecordVM Delegate
- (void)didUpdateTime:(NSString*)time {
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        _recordStartTime.text = time;
        NSArray *arr = [time componentsSeparatedByString:@":"];
        NSString *str = [arr objectAtIndex:1];
        if ([str intValue] >= 15) {
            [self.view makeToast:Local(@"AlarmDesp") duration:ERRORTime position:[CSToastManager defaultPosition]];
            [weakSelf recordAct:_recordBtn];
        }
    });
}

- (void)didUpdateTimePower:(float)power {
    // TODO: 更新音量波动大小view
    [_waveView updateView:power];
}

//转换完成的委托
- (void)didRecordMixComplete:(NSString*)path {
    //保存录音总长度
    _totalTime = _audioRecordVM.totalSeconds;
    _audioPath = path;
    DLog(@"保存完成");
}

//完成录音
- (void)recodeComplete:(NSString*)path {
    DLog(@"path==%@",path);
    //保存录音总长度
    _totalTime = _audioRecordVM.totalSeconds;
    _audioPath = path;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
