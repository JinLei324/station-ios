//
//  RecordAiringController.m
//  LonelyStation
//
//  Created by zk on 16/8/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RecordAiringController.h"
#import "RecordAiringVM.h"
#import "UIUtil.h"
#import <AVFoundation/AVFoundation.h>
#import "EMActionSheet.h"
#import "CameraSessionViewController.h"
#import "PECropViewController.h"
#import "InnerImgViewController.h"
#import "CategoryViewController.h"
#import "AudioRecordVM.h"
#import "AudioPlayerVM.h"
#import "RecordWaveView.h"
#import "EffectSelectViewController.h"
#import "UIZKRangeView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AudioPlayView.h"
#import "AudioPublicMethod.h"
#import "NMRangeSlider.h"
#import "RecordAiringNextStepViewController.h"
#import "UIImage+Color.h"

@interface RecordAiringController ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate,EMAudioRecordDelegate,EMAudioPlayerDelegate,RecordWaveDelegate,UIZKRangeViewDelegate> {
    RecordAiringVM *_recordVM;
//    EMLabel        *_headImageDesLabel;
//
//    EMView         *_topHeadContainerView;
//    EMImageView    *_topHeadBackgroundImageView;
//    EMImageView    *_defaultImageView;
//    EMButton       *_addHeadButton;
//
//    EMLabel        *shareRecordTitleLabel;
//    EMLabel        *shareRecordCatagoryLabel;
//    EMTextField    *shareRecordTitleField;
//    EMTextField    *shareRecordCatagoryField;
    
    
    EMLabel        *startRecord;
    EMLabel        *recordStartTime;
    EMLabel        *recordEndTime;
    UIScrollView   *_scrollView;
    //记录波形的view
    RecordWaveView *_waveView;
    //上传button
    EMButton *publicBtn;
    
    //录音播放按钮
    EMButton* playButton;
    //删除按钮
    EMButton *deleteBtn;
//    //确认按钮
//    EMButton *okBtn;
//    //替换按钮
//    EMButton *replaceBtn;
    //裁剪按钮
    EMButton *clipBtn;
    //录音按钮
    EMButton *recordBtn;
    AudioRecordVM *_audioRecordVM;
    AudioRecordVM *_audioRecordReplaceVM;
    AudioPlayerVM *_audioPlayerVM;
    
    NSString *_audioPath;
    //用来记录录音总长多少秒，裁剪的总长多少秒
    long long _totalTime;
    
    BgAudioObj *_leftEffectObj;
    
    BgAudioObj *_rightEffectObj;
    
    UIZKRangeView *_effectRangeView;
    NSMutableArray *_urlArray;
    NSMutableArray *_timeArray;
    
    BOOL _shouldAddVolume;
    EMButton *_currentPlayBtn;
    
    
    AudioPlayView *_recordAudioPlayView;
    
    NMRangeSlider *_nmSlider;
    EMView *_nmline;
    EMLabel *_cutWarningLabel;
    
    //播放音效
//    EMButton *addEffect;
//    EMView *_volumeAreaView;
//    EMLabel *_volumeValueLabel;
//
//
//    EMButton *_aSwitchBtn;
    int leftTime;
    int rightTime;
    BOOL isPlayed;
    
}


@property(nonatomic,strong)YYAnimatedImageView *animationImgView;

@property(nonatomic,strong)EMButton *nextBtn;

@property(nonatomic,strong)EMLabel *desLabel;

@property(nonatomic,assign)BOOL cliping;


@end

@implementation RecordAiringController



-(void)back:(id)sender{
    if (_audioPath == nil) {
        [_audioRecordVM endToRecordAudio];
        [_audioPlayerVM stopAudioPlay];
        [super back:sender];
        return;
    }

    AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message: Local(@"LeaveWarning") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (_audioPath) {
                [_audioRecordVM endToRecordAudio];
                [_audioPlayerVM stopAudioPlay];
                [_audioRecordVM deleteVedioNamed:_audioPath];
            }
            _leftEffectObj = nil;
            _rightEffectObj = nil;
            
            //删掉文件夹
            NSString *documentPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Downloads",@"zk"]];
            [[NSFileManager defaultManager] removeItemAtPath:documentPath error:nil];
            [super back:sender];
        }
    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
    [alert show];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self.viewNaviBar setTitle:Local(@"RecordBoardcast") andColor:RGB(145,90,173)];
    
    _recordVM = [[RecordAiringVM alloc] init];
    
    _audioRecordVM = [[AudioRecordVM alloc] init];
    _audioRecordVM.delegate = self;
    
    _audioRecordReplaceVM = [[AudioRecordVM alloc] init];
    _audioRecordReplaceVM.delegate = self;
    
    _audioPlayerVM = [[AudioPlayerVM alloc] init];
    _audioPlayerVM.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

- (void)dealloc {
    [_nmSlider removeObserver:self forKeyPath:@"lowerValue"];
    [_nmSlider removeObserver:self forKeyPath:@"upperValue"];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ConfigUI Methods

- (void)initViews {
    [self initView];
}



- (void)animationImg:(BOOL)animated {
    if (animated) {
        self.animationImgView.image = [YYImage imageNamed:@"recordAnimate.gif"];
        [self.animationImgView startAnimating];
    }else{
        [self.animationImgView stopAnimating];
        self.animationImgView.image = [YYImage imageNamed:@"recording_1.png"];
    }
}

- (void)initView {
    
    CGFloat x = 21*kScale;
    CGFloat y = 0; //初始高度不能变
    CGFloat height = 20*kScale;
    CGFloat width = 100*kScale;
    _scrollView = [[UIScrollView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH-64)];
    width = 160 * kScale;
    x = (kScreenW - width)/2.f;
    y = 95*kScale;
    
    _animationImgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
    [self.view  addSubview:_animationImgView];
    
    YYImage* yyImage = [YYImage imageNamed:@"recording_1.png"];
    _animationImgView.image= yyImage;
    
    CGFloat ySpace = 210 * kScale;
    x = 21 * kScale;
    y = ySpace;
    height = 11;
    width = 70;
    CGFloat textFieldX = 26 * kScale;
    CGFloat textFieldWidth = kScreenW - (26 * kScale) * 2;
    CGFloat textFieldHight = 31 * kScale;
    //录音区域
    startRecord = [UIUtil createLabel:[NSString stringWithFormat:@"%@:",Local(@"RecordBeginTitle")] andRect:Rect(x, y, width, height) andTextColor:RGB(51,51,51) andFont:ComFont(11*kScale) andAlpha:1];
    [_scrollView addSubview:startRecord];
    
    //录音时间记录
    recordStartTime = [UIUtil createLabel:@"00:00" andRect:Rect(x, PositionY(startRecord) + 18 * kScale, width, height) andTextColor:RGB(51,51,51) andFont:ComFont(11*kScale) andAlpha:0.6];
    [_scrollView addSubview:recordStartTime];
    
    _cutWarningLabel = [UIUtil createLabel:Local(@"CutWarning") andRect:Rect(x, PositionY(recordStartTime) + 7 * kScale, 200, height) andTextColor:RGB(51,51,51) andFont:ComFont(11*kScale) andAlpha:0.6];
    [_scrollView addSubview:_cutWarningLabel];
    _cutWarningLabel.hidden = YES;

    
    recordEndTime = [UIUtil createLabel:@"00:00" andRect:Rect(kScreenW- x - width, PositionY(startRecord) + 18 * kScale, width, height) andTextColor:RGB(51,51,51) andFont:ComFont(11*kScale) andAlpha:0.6];
    recordEndTime.textAlignment = NSTextAlignmentRight;
    recordEndTime.hidden = YES;
    [_scrollView addSubview:recordEndTime];
    
    //录音显示区域
    _waveView = [[RecordWaveView alloc] initWithFrame:Rect(x, PositionY(recordStartTime) + 33 * kScale, textFieldWidth, textFieldHight)];
    _waveView.delegate = self;
    _waveView.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_waveView];
    
    
    //播放显示区域，和录音显示区域一起，切换来操作会比较好点
    _recordAudioPlayView = [[AudioPlayView alloc] initWithFrame:Rect(textFieldX, PositionY(recordStartTime) + 27 * kScale, textFieldWidth, textFieldHight)];
    [_scrollView addSubview:_recordAudioPlayView];
    _recordAudioPlayView.hidden = YES;
    
    
    //裁剪的view，也单独提取出来
    _nmSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(textFieldX, PositionY(recordStartTime) + 33 * kScale, textFieldWidth, textFieldHight)];
    _nmSlider.lowerValue = 0;
    _nmSlider.upperValue = 1;
    _nmSlider.trackImage = [UIImage yy_imageWithColor:RGB(145, 90, 173)];
    UIImage *image = [UIImage imageNamed:@"cut_dot"];
    _nmSlider.lowerHandleImageNormal = image;
    _nmSlider.upperHandleImageNormal = image;
    
    
    _nmline = [[EMView alloc] initWithFrame:CGRectMake(textFieldX, _nmSlider.frame.origin.y + textFieldHight/2.f - 0.5, textFieldWidth, 2)];
    _nmline.backgroundColor = RGB(171, 171, 171);
    [_scrollView addSubview:_nmline];
    [_scrollView addSubview:_nmSlider];
    [_nmSlider addObserver:self forKeyPath:@"lowerValue" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_nmSlider addObserver:self forKeyPath:@"upperValue" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    _nmSlider.hidden = YES;
    _nmline.hidden = YES;
    
    //录音键
    CGFloat btnWidth = 57 * kScale;
    CGFloat btnHight = 57 * kScale;
    
    CGFloat aSpace = 24*kScale;
    
    recordBtn = [[EMButton alloc] initWithFrame:Rect((kScreenW)*0.5+5, PositionY(_waveView) + aSpace, btnWidth, btnHight)];
    [recordBtn setBackgroundImage:[UIImage imageNamed:@"Introduction_recording"] forState:UIControlStateNormal];
    [recordBtn setBackgroundImage:[UIImage imageNamed:@"Introduction_record_stop"] forState:UIControlStateSelected];
    [recordBtn addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:recordBtn];
    
    
    

    CGFloat btnX = 48*kScale;
    CGFloat btnY = PositionY(_waveView) + aSpace;
    //播放键
    //播放键的x＝录音键x - 播放键宽 - 裁剪键x
//    btnWidth = 47 * kScale;
//    btnHight = 47 * kScale;
    btnX = recordBtn.frame.origin.x - btnWidth - 15;
    playButton = [[EMButton alloc] initWithFrame:Rect(btnX, btnY, btnWidth, btnHight)];
    [playButton setBackgroundImage:[UIImage imageNamed:@"Introduction_play"] forState:UIControlStateNormal];
    [playButton setBackgroundImage:[UIImage imageNamed:@"btn_playstop"] forState:UIControlStateSelected];
//    [playButton setImageEdgeInsets:UIEdgeInsetsMake(-2.5, 2.5, 0, 0)];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:playButton];
    

    
    //裁剪键 36,38,21,19

    btnWidth = 47 * kScale;
    btnHight = 47 * kScale;
    btnY = PositionY(_waveView) +30*kScale;
    btnX = playButton.frame.origin.x - btnWidth - 20;
    clipBtn = [[EMButton alloc] initWithFrame:Rect(btnX, btnY, btnWidth, btnHight)];
    [clipBtn setBackgroundImage:[UIImage imageNamed:@"record_cut"] forState:UIControlStateNormal];
    [clipBtn setBackgroundImage:[UIImage imageNamed:@"record_cut_d"] forState:UIControlStateSelected];
//    [clipBtn setImageEdgeInsets:UIEdgeInsetsMake(-2.5, 2.5, 0, 0)];
    [clipBtn addTarget:self action:@selector(cutAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:clipBtn];
    //删除键
    btnWidth = 47 * kScale;
    btnHight = 47 * kScale;
    btnX = PositionX(recordBtn) + 20;
    deleteBtn = [[EMButton alloc] initWithFrame:Rect(btnX, btnY, btnWidth, btnHight)];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"Introduction_delete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:deleteBtn];
    //下一步
    x = (kScreenW - 100)/2.f;
    y = PositionY(playButton)+20*kScale;
    _nextBtn = [[EMButton alloc] initWithFrame:Rect(x, y, 100, 30) andConners:15];
    [_nextBtn setBackgroundImage:[UIUtil imageWithColor:RGB(145,90,173) andSize:CGSizeMake(100, 30)] forState:UIControlStateNormal];
    [_nextBtn setTitle:Local(@"NextStep")  forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_nextBtn];
    x = 10*kScale;
    _desLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_nextBtn)+20*kScale, kScreenW - 2*x, 30*kScale)];
    _desLabel.textColor = RGB(145,90,173);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:Local(@"CheckPassDes")];
    NSRange strRange = {0,[str length]-[Local(@"TwoHunCoin") length]};
    [str addAttribute:NSForegroundColorAttributeName value:RGB(51, 51, 51) range:strRange];
    _desLabel.font = ComFont(14);
    _desLabel.attributedText = str;
    _desLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_desLabel];
    //添加scrollview
    [self.view addSubview:_scrollView];
    
    [self setRecording:YES];
}




- (void)nextStep:(EMButton*)btn {
    if (!_audioPath) {
        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    RecordAiringNextStepViewController *nextStep = [[RecordAiringNextStepViewController alloc] init];
    nextStep.audioPath = _audioPath;
    nextStep.totalTime = _totalTime;
    [self.navigationController pushViewController:nextStep animated:YES];
}
//
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    int currentTime = _nmSlider.lowerValue * _totalTime;
    int seconds = (int)currentTime % 60;
    int minutes = ((int)currentTime / 60) % 60;
    NSString *leftText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    recordStartTime.text = leftText;
    recordStartTime.labelId = [NSString stringWithFormat:@"%d",currentTime];
    leftTime = currentTime;
    
    
    currentTime = _nmSlider.upperValue * _totalTime;
    rightTime = currentTime;
    seconds = (int)currentTime % 60;
    minutes = ((int)currentTime / 60) % 60;
    NSString *rightText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    recordEndTime.text = rightText;
    recordEndTime.labelId = [NSString stringWithFormat:@"%d",currentTime];

}


//- (void)sliderChangeValue:(UISlider*)slider {
//    int value = slider.value;
//    _volumeValueLabel.text = [NSString stringWithFormat:@"%d",value];
//}


- (EMTextField*)textFieldWithPlaceHolder:(NSString*)placeHolder andName:(NSString*)name andFrame:(CGRect)rect andSuperView:(UIView*)superView{
    EMImageView *filedBack = [[EMImageView alloc] initWithFrame:rect];
    filedBack.alpha = 0.15;
    filedBack.backgroundColor = RGB(171, 171, 171);
    filedBack.layer.cornerRadius = rect.size.height/2.f;
    filedBack.layer.masksToBounds = YES;
    rect.origin.x = rect.origin.x + 20;
    rect.size.width = rect.size.width-40;
    [superView addSubview:filedBack];
    EMTextField *field = [[EMTextField alloc] initWithFrame:rect];
    field.placeholder = placeHolder;
    field.font = ComFont(13);
//    [field setTintColor:RGB(51,51,51)];
    field.textColor = RGB(51,51,51);
//    [field setValue:RGBA(51, 51, 51,1) forKeyPath:@"_placeholderLabel.textColor"];
    field.titStr = name;
    //添加分类点击事件
//    if ([name isEqualToString:@"shareRecordCatagory"]) {
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(catagoryAction)];
//        filedBack.userInteractionEnabled = YES;
//        [filedBack addGestureRecognizer:tapGesture];
//        field.enabled = NO;
//    }
    
    return field;
}

#pragma mark - UIAction

//删除全部音效
- (void)deleteAllEffectAction:(EMButton*)btn {
    AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"MakeSureDeleteAllRecord") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            _leftEffectObj = nil;
            _rightEffectObj = nil;
            [_effectRangeView setLeftHidden:YES];
            [_effectRangeView setRightHidden:YES];
        }
    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
    [alert show];
}

- (void)zkDidMoveRange:(int)leftStr andRightRange:(int)rightStr {
    
}


- (void)setRecording:(BOOL)ret {
    playButton.enabled = !ret;
    deleteBtn.enabled = !ret;
    clipBtn.enabled = !ret;
    _effectRangeView.userInteractionEnabled = !ret;
    
}


- (void)setPlaying:(BOOL)ret {
    deleteBtn.enabled = !ret;
    clipBtn.enabled = !ret;
    recordBtn.enabled = !ret;
}


- (void)setCliping:(BOOL)ret {
//    deleteBtn.hidden = !ret;
//    playButton.enabled = !ret;
//    recordBtn.enabled = !ret;
    _cliping = ret;
    if (ret) {
         [recordBtn setBackgroundImage:[UIImage imageNamed:@"radio_re"] forState:UIControlStateNormal];
        [deleteBtn  setBackgroundImage:[UIImage imageNamed:@"radio_ok"] forState:UIControlStateNormal];
    }else{
        [recordBtn setBackgroundImage:[UIImage imageNamed:@"Introduction_recording"] forState:UIControlStateNormal];
        [deleteBtn  setBackgroundImage:[UIImage imageNamed:@"Introduction_delete"] forState:UIControlStateNormal];

    }
}


- (void)replaceAction:(UIButton*)btn {
    //会录制一段，然后插入到选中的左右之间
    NSLog(@"replaceAction");
    if (!btn.selected) {
        //如果在录音，其他按钮先屏蔽掉，反之，打开
        [self setRecording:btn.selected];
        if (btn.selected) {
            [_waveView stopPlay];
        }
        _recordAudioPlayView.hidden = YES;
        _waveView.hidden = NO;
        _nmSlider.hidden = YES;
        _nmline.hidden = YES;
        _cutWarningLabel.hidden = YES;
        recordStartTime.text = @"00:00";
        [_waveView startRecord];
        [_audioRecordReplaceVM recordButtonClick];
        [self animationImg:btn.selected];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self mergeAction];
            _audioRecordVM.isNotMixPreRecord = NO;

        });
    }else{
        AllPopView *popView =  [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"ReRecordWillUponRange") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex){
            if (!cancelled) {
                _audioRecordVM.isNotMixPreRecord = YES;
                leftTime = [recordStartTime.labelId intValue];
                rightTime = [recordEndTime.labelId intValue];
                //如果在录音，其他按钮先屏蔽掉，反之，打开
                [self setRecording:btn.selected];
                if (btn.selected) {
                    [_waveView stopPlay];
                }
                _recordAudioPlayView.hidden = YES;
                _waveView.hidden = NO;
                _nmSlider.hidden = YES;
                _nmline.hidden = YES;
                _cutWarningLabel.hidden = YES;
                recordStartTime.text = @"00:00";
                recordEndTime.hidden = YES;
                
                [_waveView startRecord];
                [_audioRecordReplaceVM recordButtonClick];
                [self animationImg:btn.selected];
            }
        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"RecordBeginTitle"), nil];
        [popView show];
    }

  
}

///合并
- (void)mergeAction {
    if (_audioRecordVM.isNotMixPreRecord) {
        //说明这哥们是要合并三个
        [UIUtil showHUD:self.view];
        [_audioRecordVM cropActionWithAudioPathForThree:_audioPath andMiddlePath:_audioRecordReplaceVM.vedioPath andLeftDuration:(double)leftTime andRightDuration:(double)rightTime andAllDuration:_audioRecordVM.totalSeconds andBlock:^(NSString *newPath) {
            [UIUtil hideHUD:self.view];
            _audioPath = newPath;
            //把录音的关掉
            [_waveView clearSample];
            recordStartTime.text = @"00:00";
            //显示左边的时间
            float time = [EMUtil getAudioSecWithFilePath:[AudioPublicMethod getPathByFileName:_audioPath ofType:@"wav"]];
            int totalTime = ceil(time);
            _totalTime = totalTime;
            _audioRecordVM.totalSeconds = totalTime;
            
            //设置waveview总长度
            _waveView.accountValue = totalTime;
            int seconds = totalTime % 60;
            int minutes = (totalTime / 60) % 60;
            NSString *timeText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
            recordStartTime.text = @"00:00";
            recordEndTime.text = timeText;
            recordEndTime.hidden = NO;
            [self.view makeToast:Local(@"ClipSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
            _effectRangeView.totalCount = (int)_totalTime;
            _waveView.hidden = YES;
            _recordAudioPlayView.hidden = YES;
            _nmSlider.hidden = NO;
            _nmline.hidden = NO;
            _cutWarningLabel.hidden = YES;
            _nmSlider.lowerValue = 0;
            _nmSlider.upperValue = 1;
            [_recordAudioPlayView stopLocalAudio];
            leftTime = 0;
            rightTime = totalTime;
        }];
    }
}


- (void)okAction:(UIButton*)btn {
    AllPopView *popView =  [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"AllReadyEdit") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex){
        if (!cancelled) {
//            [self cutAudio:btn];
            [self setCliping:NO];
            _audioRecordVM.isNotMixPreRecord = NO;
            clipBtn.selected = NO;
            _nextBtn.hidden = NO;
            
            recordEndTime.hidden = YES;
            _waveView.hidden = YES;
            _recordAudioPlayView.hidden = NO;
            _nmSlider.hidden = YES;
            _nmline.hidden = YES;
            _cutWarningLabel.hidden = YES;
            
        }
    } cancelButtonTitle:Local(@"EditGoOn") otherButtonTitles:Local(@"Sure"), nil];
    [popView show];

}


//录音点击
- (void)recordAction:(EMButton*)btn {
    //先判断有没有权限
//    if (![UIUtil haveDeviceAuthorization]){
//        [UIUtil showDeviceWarning];
//        return;
//    }
    [btn setSelected:!btn.selected];
    
    if (self.cliping) {
        //如果是编辑中的录音
        [self replaceAction:btn];
    }else{
        
        _audioRecordVM.isNotMixPreRecord = NO;
        //如果在录音，其他按钮先屏蔽掉，反之，打开
        [self setRecording:btn.selected];
        if (btn.selected) {
            [_waveView stopPlay];
        }
        _recordAudioPlayView.hidden = YES;
        _waveView.hidden = NO;
        [_waveView startRecord];
        [_audioRecordVM recordButtonClick];
        
        [self animationImg:btn.selected];
    }
    
   
}

//播放点击
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
        _currentPlayBtn = btn;
        [_recordAudioPlayView setHidden:NO];
        [_waveView setHidden:YES];
        _nmSlider.hidden = YES;
        NSString *path = [AudioPublicMethod getPathByFileName:_audioPath ofType:@"wav"];
        if (_cliping) {
            if (!isPlayed) {
                _recordAudioPlayView.currentPlayTime = leftTime;
            }
        }
        
        [_recordAudioPlayView playLocalAudio:path andBlock:^(float currentTime, float allTime, BOOL isStop) {
            int seconds = (int)currentTime % 60;
            int minutes = ((int)currentTime / 60) % 60;
            NSString *leftText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
            recordStartTime.text = leftText;
            if (isStop || (currentTime >= rightTime && rightTime!=0)) {
                [_recordAudioPlayView stopLocalAudio];
                btn.selected = NO;
                int seconds = (int)leftTime % 60;
                int minutes = ((int)leftTime / 60) % 60;
                NSString *leftText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
                recordStartTime.text = leftText;
                [self setPlaying:btn.selected];
                [self animationImg:btn.selected];
                [_recordAudioPlayView setHidden:NO];
                if (_cliping) {
                    _nmSlider.hidden = NO;
                    [_recordAudioPlayView setHidden:YES];
                    [self setPlaying:btn.selected];
                    recordBtn.selected = NO;
                }
            }else {
                btn.selected = YES;
                [self setPlaying:btn.selected];
                
            }
        }];
        isPlayed = NO;
    }else{
        [_recordAudioPlayView stopLocalAudio];
        if (_cliping) {
            _nmSlider.hidden = NO;
            [_recordAudioPlayView setHidden:YES];
            [self setPlaying:btn.selected];
            recordBtn.selected = NO;
            isPlayed = YES;
        }
        _currentPlayBtn = nil;
    }
    [self animationImg:btn.selected];
}

//删除点击
- (void)deleteAction:(EMButton*)btn {
    if (self.cliping) {
        [self okAction:btn];
    }else{
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
}

- (void)audioDelete {
    [_audioRecordVM deleteVedioNamed:_audioPath];

    [_waveView clearSample];
    [_waveView resetRightOrgin];
    recordStartTime.text = @"00:00";
    _audioRecordVM.totalSeconds = 0;
    _audioPath = nil;
    [_recordAudioPlayView stopLocalAudio];
    _recordAudioPlayView.hidden = YES;
    _waveView.hidden = NO;
    [self setRecording:YES];
    [UIUtil hideHUD:self.view];
    [self.view makeToast:Local(@"DeleteSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
}


//裁剪点击
- (void)cutAction:(EMButton*)btn {
    //判断有没有录音，有录音才能裁剪
    if (!_audioPath) {
        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if (!btn.selected) {
        btn.selected = !btn.selected;
        if (btn.selected) {
            [self.viewNaviBar setTitle:Local(@"EditAir") andColor:RGB(145,90,173)];
        }else{
            [self.viewNaviBar setTitle:Local(@"RecordBoardcast") andColor:RGB(145,90,173)];
            
        }
        
        //如果在裁剪，其他按钮先屏蔽掉，反之，打开
        [self setCliping:btn.selected];
        //剪切
        [UIUtil showHUD:self.view];
        [_audioRecordVM actionButtonClick];
        _waveView.hidden = YES;
        _recordAudioPlayView.hidden = YES;
        _nmSlider.hidden = NO;
        _nmline.hidden = NO;
        _nmSlider.lowerValue = 0;
        _nmSlider.upperValue = 1;
        _cutWarningLabel.hidden = YES;
        rightTime = (int)_audioRecordVM.totalSeconds;
        [self performSelector:@selector(audioCut) withObject:nil afterDelay:1];
        _nextBtn.hidden = YES;
    }else{
        //裁剪
        [self cutAudio:btn];
//        clipBtn.selected = NO;
//        _nextBtn.hidden = NO;
//        [self setCliping:NO];
    }
 
}

- (void)cutAudio:(UIButton*)btn {
    //如果左右相等，不裁
    if ([recordEndTime.labelId intValue] == [recordStartTime.labelId intValue]){
        [self.view makeToast:Local(@"CutAlert") duration:ERRORTime position:[CSToastManager defaultPosition]];
        btn.selected = YES;
        [self setCliping:btn.selected];
        return;
    }
    [UIUtil showHUD:self.view];
    [_audioRecordVM cropActionWithAudioPath:_audioPath andLeftDuration:(double)leftTime andRightDuration:(double)rightTime andAllDuration:_audioRecordVM.totalSeconds andBlock:^(NSString *newPath) {
        [UIUtil hideHUD:self.view];
        _audioPath = newPath;
        //把录音的关掉
        [_waveView clearSample];
        recordStartTime.text = @"00:00";
        //显示左边的时间
        int totalTime = leftTime + ((int)_audioRecordVM.totalSeconds - rightTime);
        _totalTime = totalTime;
        _audioRecordVM.totalSeconds = totalTime;
        
        //设置waveview总长度
        _waveView.accountValue = totalTime;
        int seconds = totalTime % 60;
        int minutes = (totalTime / 60) % 60;
        NSString *timeText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
        recordStartTime.text = @"00:00";
        leftTime = 0;
        recordEndTime.text = timeText;
        rightTime = totalTime;
        [self.view makeToast:Local(@"ClipSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
        _effectRangeView.totalCount = (int)_totalTime;
        _waveView.hidden = YES;
        _recordAudioPlayView.hidden = YES;
        _nmSlider.hidden = NO;
        _nmline.hidden = NO;
        _cutWarningLabel.hidden = YES;
        _nmSlider.lowerValue = 0;
        _nmSlider.upperValue = 1;
        [_recordAudioPlayView stopLocalAudio];
        leftTime = 0;
        rightTime = totalTime;
        
    }];
}


- (void)audioCut {
    [UIUtil hideHUD:self.view];
//    把总长传给waveview
    _waveView.accountValue =  _audioRecordVM.totalSeconds;
    int seconds = _waveView.accountValue % 60;
    int minutes = (_waveView.accountValue / 60) % 60;
    NSString *leftTimeText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    recordStartTime.text = leftTimeText;
    recordStartTime.labelId = [NSString stringWithFormat:@"%d",0];

    recordEndTime.text = recordStartTime.text;
    recordEndTime.labelId = [NSString stringWithFormat:@"%lld",_audioRecordVM.totalSeconds];
    recordStartTime.text = @"00:00";
    recordEndTime.hidden = NO;
    [_waveView showClipView];
}

////分类点击
//- (void)catagoryAction{
//    CategoryViewController *category = [[CategoryViewController alloc] init];
//    category.delegate = self;
//    [self.navigationController pushViewController:category animated:YES];
//}


//添加图片
//- (void)addImageAction:(id)sender {
//    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"ChoosePhoto") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
//        if (buttonIndex == 1) {
//            InnerImgViewController *innerImgSelect = [[InnerImgViewController alloc] init];
//            innerImgSelect.delegate = self;
//            [self.navigationController pushViewController:innerImgSelect animated:YES];
//        }else if (buttonIndex == 2) {
//            CameraSessionViewController *controller = [[CameraSessionViewController alloc] init];
//            controller.delegate = self;
//            [self presentViewController:controller animated:YES completion:NULL];
//            controller = nil;
//        }else if(buttonIndex == 3){
//            UIImagePickerController *ipc=[[UIImagePickerController alloc] init];
//            [ipc.navigationBar setBackgroundImage:[UIUtil imageWithColor:RGBA(0x98, 0x4a, 0xa6,1) andSize:Size(kScreenW, 64)] forBarMetrics:UIBarMetricsDefault];
//            [ipc.navigationBar setTintColor:ColorFF];
//            [ipc.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
//
//            ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
//            ipc.delegate=self;
//            [self presentViewController:ipc animated:YES completion:nil];
//        }
//
//
//    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Local(@"InnerImg"),Local(@"Camra"),Local(@"ChooseFromAblue"),nil];
//    [sheet showInView:self.view];;
//}
//
//-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info{
//    UIImage *img=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    [self dismissViewControllerAnimated:NO completion:nil];
//    [self cropImage:img];
//}
//
////调用编辑图片
//- (void)cropImage:(UIImage*)image{
//    PECropViewController *controller = [[PECropViewController alloc] init];
//    controller.delegate = self;
//    controller.image = image;
//    CGFloat width = image.size.width;
//    CGFloat height = image.size.height;
//    CGFloat length = MIN(width, height);
//    controller.imageCropRect = CGRectMake((width - length) / 2,
//                                          (height - length) / 2,
//                                          length,
//                                          length*10/17);
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//
//    [self presentViewController:navigationController animated:YES completion:NULL];
//    navigationController = nil;
//    controller = nil;
//
//}
//
//
////拍照完成后的回调，去编辑图片
//- (void)didCaptureImageWithImage:(UIImage*)image {
//    [self cropImage:image];
//}
//
//#pragma mark - PECropViewControllerDelegate methods
//
//- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
//{
////    [self uploadImgToService:croppedImage];
//    _topHeadBackgroundImageView.image = croppedImage;
//    _addHeadButton.hidden = YES;
//    _defaultImageView.hidden = YES;
//    [controller dismissViewControllerAnimated:YES completion:NULL];
//
//}
//
//- (void)cropViewControllerDidCancel:(PECropViewController *)controller
//{
//    [controller dismissViewControllerAnimated:YES completion:NULL];
//}

#pragma mark AudioRecordVM Delegate
- (void)didUpdateTime:(NSString*)time {
    dispatch_async(dispatch_get_main_queue(), ^{
        recordStartTime.text = time;
    });
}

- (void)didUpdateTimePower:(float)power {
    // TODO: 更新音量波动大小view
//    DLog(@"powver==%f",power);
    [_waveView updateView:power];
}

//转换完成的委托
- (void)didRecordMixComplete:(NSString*)path {
    if (path) {
        if (_audioRecordVM.isNotMixPreRecord == NO) {
            //保存录音总长度
            _totalTime = _audioRecordVM.totalSeconds;
            _audioPath = path;
            float time = [EMUtil getAudioSecWithFilePath:[AudioPublicMethod getPathByFileName:_audioPath ofType:@"wav"]];
            rightTime = ceil(time);
        }
    }
  
    DLog(@"保存完成path=%@",_audioPath);
}

//是否收费
- (void)switchAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        if (_totalTime < 300) {
            [self.view makeToast:Local(@"CantSetCharge") duration:ERRORTime position:[CSToastManager defaultPosition]];
            btn.selected = NO;
        }
    }
}


//完成录音
- (void)recodeComplete:(NSString*)path {
    DLog(@"path==%@",path);
    //保存录音总长度
    if (path) {
        if (_audioRecordVM.isNotMixPreRecord == NO) {
            
            _audioPath = path;
            _totalTime = _audioRecordVM.totalSeconds;
            float time = [EMUtil getAudioSecWithFilePath:[AudioPublicMethod getPathByFileName:_audioPath ofType:@"wav"]];
            rightTime =  ceil(time);

        }
    }
  
}

#pragma mark AudioPlayerRecordVM Delegate
-(void)didStopAudio {
    if (_audioRecordVM.isNotMixPreRecord == NO) {

    if (_currentPlayBtn) {
        [_currentPlayBtn setSelected:NO];
        if (_currentPlayBtn != playButton) {
            CGRect rect = _effectRangeView.cursorView.frame;
            rect.origin.x = 0;
            _effectRangeView.cursorView.frame = rect;
            [_audioPlayerVM stopRemoteAudio];
        }else {
            //播放完成要把游标指到底
            [_waveView updateSet:0];
        }
        [self setPlaying:NO];
        _currentPlayBtn = nil;
    }
    }
}

- (void)didUpdateAudio:(float)time andValue:(NSString*)value {
    //播放本地音频
    if (_currentPlayBtn != playButton) {
        if (_totalTime!=0) {
            float currentWidth = ((time/40.f)/_totalTime)*_effectRangeView.frame.size.width;
            CGRect rect = _effectRangeView.cursorView.frame;
            if (currentWidth > _effectRangeView.frame.size.width - rect.size.width) {
                currentWidth = _effectRangeView.frame.size.width;
            }
            rect.origin.x = currentWidth;
            _effectRangeView.cursorView.frame = rect;
        }
    }else {
        DLog(@"time===%f",time);
        
        [_waveView updateSet:time];
        recordStartTime.text = value;
    }
}


#pragma mark RecordWaveDelegate

- (void)willUpdateLeftValue:(int)value andLeftText:(NSString*)leftText andRightValue:(int)rightValue andRightText:(NSString*)rightText {
    recordStartTime.text = leftText;
    //用labelID临时保存当前的时间，好用来裁剪
    recordStartTime.labelId = [NSString stringWithFormat:@"%d",value];
    recordEndTime.text = rightText;
    //用labelID临时保存当前的时间，好用来裁剪
    recordEndTime.labelId = [NSString stringWithFormat:@"%d",rightValue];
    leftTime = value;
    rightTime = value;
}

- (void)didStartLocalPan {
    [_audioPlayerVM slideStartToChange];
}

- (void)didEndLocalPan:(int)value {
    [_audioPlayerVM slideToEnd:value];

}


- (void)localUpdateLeftValue:(int)value andLeftText:(NSString*)leftText {
    recordStartTime.text = leftText;
    //用labelID临时保存当前的时间，好用来裁剪
    recordStartTime.labelId = [NSString stringWithFormat:@"%d",value];
}


@end
