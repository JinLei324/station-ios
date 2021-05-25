//
//  RecordAiringNextStepViewController.m
//  LonelyStation
//
//  Created by 钟铿 on 2019/2/14.
//  Copyright © 2019 zk. All rights reserved.
//

#import "RecordAiringNextStepViewController.h"
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

@interface RecordAiringNextStepViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,CameraSessionViewControllerDelegate,PECropViewControllerDelegate,UINavigationControllerDelegate,InnerImgSelectProtocol,CategoryViewSelectProtocol> {
    RecordAiringVM *_recordVM;
    EMLabel        *_headImageDesLabel;
    
    EMView         *_topHeadContainerView;
    EMImageView    *_topHeadBackgroundImageView;
    EMImageView    *_defaultImageView;
    EMButton       *_addHeadButton;
    
    
    
    
    EMLabel        *shareRecordTitleLabel;
    EMLabel        *shareRecordCatagoryLabel;
    EMTextField    *shareRecordTitleField;
    EMTextField    *shareRecordCatagoryField;
    
    
    //上传button
    EMButton *_publicBtn;
    //是否收费
    EMButton *_aSwitchBtn;
    
     UIScrollView   *_scrollView;
    
//    EMLabel        *startRecord;
//    EMLabel        *recordStartTime;
//    EMLabel        *recordEndTime;
   
//    //记录波形的view
//    RecordWaveView *_waveView;
//    //上传button
//    EMButton *publicBtn;
//    
//    //录音播放按钮
//    EMButton* playButton;
//    //删除按钮
//    EMButton *deleteBtn;
//    //裁剪按钮
//    EMButton *clipBtn;
//    //录音按钮
//    EMButton *recordBtn;
    AudioRecordVM *_audioRecordVM;
//
//    AudioPlayerVM *_audioPlayerVM;
//    
//    NSString *_audioPath;
//    //用来记录录音总长多少秒，裁剪的总长多少秒
//    long long _totalTime;
//    
//    BgAudioObj *_leftEffectObj;
//    
//    BgAudioObj *_rightEffectObj;
//    
//    UIZKRangeView *_effectRangeView;
//    NSMutableArray *_urlArray;
//    NSMutableArray *_timeArray;
//    
//    BOOL _shouldAddVolume;
//    EMButton *_currentPlayBtn;
//    
//    
//    AudioPlayView *_recordAudioPlayView;
//    
//    NMRangeSlider *_nmSlider;
//    EMView *_nmline;
//    EMLabel *_cutWarningLabel;
//    
//    //播放音效
//    EMButton *addEffect;
//    EMView *_volumeAreaView;
//    EMLabel *_volumeValueLabel;
//    
//    
    
}

@end

@implementation RecordAiringNextStepViewController

- (void)didSelectCategory:(RecordCategoryObj*)obj andController:(id)controller {
    shareRecordCatagoryField.text = obj.categoryName;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self.viewNaviBar setTitle:Local(@"RecordBoardcast") andColor:RGB(145,90,173)];
    
    _recordVM = [[RecordAiringVM alloc] init];
    
    _audioRecordVM = [[AudioRecordVM alloc] init];
//    _audioRecordVM.delegate = self;
//
//    _audioPlayerVM = [[AudioPlayerVM alloc] init];
//    _audioPlayerVM.delegate = self;
}

- (void)didSelectInnerImg:(InnerRecBgImgObj *)obj andController:(id)controller {
    _addHeadButton.hidden = YES;
    _defaultImageView.hidden = YES;
    [_topHeadBackgroundImageView yy_setImageWithURL:[NSURL URLWithString:obj.fileUrl] options:YYWebImageOptionShowNetworkActivity];
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
//    [_nmSlider removeObserver:self forKeyPath:@"lowerValue"];
//    [_nmSlider removeObserver:self forKeyPath:@"upperValue"];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ConfigUI Methods

- (void)initViews {
    [self initView];
}

- (void)publicAction:(id)sender {
    //测试用
    //    NSData *audioData1 = [_audioRecordVM getData:@"20160903080047868"];
    
    //没有背景图要选背景图
    if (_addHeadButton.hidden == NO){
        [self.view makeToast:Local(@"PlsInputBackImg") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    
    //没有标题要输入标题
    NSString *title = [shareRecordTitleField text];
    //去掉首尾空格
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([title isEqualToString:@""]) {
        [self.view makeToast:Local(@"PlsInputTitle") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if (title.length > 8) {
        [self.view makeToast:Local(@"TitleCannotBeyond8") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    //没有类别要写类别
    NSString *category = shareRecordCatagoryField.text;
    if ([category isEqualToString:@""]) {
        [self.view makeToast:Local(@"PlsSelectCategory") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    
    //判断有没有录音，没有录音不能添加
    if (!_audioPath) {
        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    [UIUtil showHUD:self.view];
    NSData *imgData = UIImagePNGRepresentation(_topHeadBackgroundImageView.image);
    NSData *audioData = [_audioRecordVM getData:_audioPath];
    
    NSString *leftEffectId = @"";
    NSString *rightEffectId = @"";
    NSString *leftTime = @"";
    NSString *rightTime = @"";
//    //有点加上音效才能发布
//    if (addEffect.isSelected){
//        if (_leftEffectObj) {
//            leftEffectId = _leftEffectObj.effectId;
//            int value = _effectRangeView.leftRangeValue-3 > 0 ? _effectRangeView.leftRangeValue-3 :_effectRangeView.leftRangeValue;
//            leftTime = [NSString stringWithFormat:@"%d",value];
//        }
//        if (_rightEffectObj) {
//            rightEffectId = _rightEffectObj.effectId;
//            int value = _effectRangeView.rightRangeValue - 3 > 0 ? _effectRangeView.rightRangeValue-3 :_effectRangeView.rightRangeValue;
//
//            rightTime = [NSString stringWithFormat:@"%d",value];
//        }
//    }
    NSString *isCharge = @"N";
    if (_aSwitchBtn.isSelected) {
        isCharge = @"Y";
    }
    
    [_recordVM publicRecordAiring:title andImage:imgData andImgType:@"png" andAudio:audioData category:category andEffectFile1:leftEffectId andEffectFile1StartTime:leftTime andEffectFile2:rightEffectId andEffectFile2StartTime:rightTime andDuration:(int)_totalTime andIsCharge:isCharge andBlock:^(NSDictionary *dict) {
        [UIUtil hideHUD:self.view];
        if (dict) {
            if ([dict[@"code"] isEqualToString:@"1"]) {
                [self.view.window makeToast:Local(@"PublicSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                //上传成功，删掉文件夹
                NSString *documentPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Downloads",@"zk"]];
                [[NSFileManager defaultManager] removeItemAtPath:documentPath error:nil];
                for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
                    if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LeftSlideViewController"]) {
                        [self.navigationController popToViewController:self.navigationController.viewControllers[i] animated:YES];
                        break;
                    }
                }
            }else {
                [self.view makeToast:Local(@"PublicFailed") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else {
            [self.view makeToast:Local(@"PublicFailed") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
    
}

- (void)initView {
    
    CGFloat x = 21*kScale;
    CGFloat y = 0; //初始高度不能变
    CGFloat height = 20*kScale;
    CGFloat width = 100*kScale;
    _scrollView = [[UIScrollView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH-64)];
    
    //    _headImageDesLabel = [[EMLabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    //    _headImageDesLabel.text = Local(@"RecordImageDes");
    //    _headImageDesLabel.textColor = RGB(51,51,51);
    //    _headImageDesLabel.font = ComFont(11*kScale);
    //    [_scrollView addSubview:_headImageDesLabel];
    y = _headImageDesLabel.frame.origin.y+_headImageDesLabel.frame.size.height + 3*kScale;
    height = 221*kScale;
    width = kScreenW;
    
    _topHeadContainerView = [[EMView alloc] initWithFrame:Rect(0, y, width, height)];
    _topHeadContainerView.backgroundColor = RGBA(209,172,255,0.4);
    [_scrollView addSubview:_topHeadContainerView];
    
    _topHeadBackgroundImageView = [[EMImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    //    _topHeadBackgroundImageView.backgroundColor = [UIColor redColor];
    [_topHeadContainerView addSubview:_topHeadBackgroundImageView];
    
    CGFloat space = 35.f * kScale;
    width = 56 * kScale;
    x = (kScreenW - 2 * width - space)/2.f;
    y = 81*kScale;
    height = 56 * kScale;
    
    _defaultImageView = [[EMImageView alloc] initWithFrame:Rect(x, y, width,height)];
    _defaultImageView.image = [UIImage imageNamed:@"record_image"];
    [_topHeadContainerView addSubview:_defaultImageView];
    
    //添加图片的button
    _addHeadButton = [[EMButton alloc] initWithFrame:CGRectMake(PositionX(_defaultImageView)+space, y, width, height)];
    [_addHeadButton setImage:[UIImage imageNamed:@"cover_add"] forState:UIControlStateNormal];
    _addHeadButton.userInteractionEnabled = NO;
    [_topHeadContainerView addSubview:_addHeadButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImageAction:)];
    [_topHeadContainerView addGestureRecognizer:tapGesture];
    CGFloat ySpace = 14 * kScale;
    x = 21 * kScale;
    y = PositionY(_topHeadContainerView) +ySpace;
    height = 11;
    width = 70;
    shareRecordTitleLabel = [UIUtil createLabel:Local(@"RecordShareTitle") andRect:Rect(x, y, width, height) andTextColor:RGB(51,51,51) andFont:ComFont(11*kScale) andAlpha:1];
    [_scrollView addSubview:shareRecordTitleLabel];
    
    CGFloat textFieldX = 26 * kScale;
    CGFloat textFieldWidth = kScreenW - (26 * kScale) * 2;
    CGFloat textFieldHight = 31 * kScale;
    shareRecordTitleField = [self textFieldWithPlaceHolder:Local(@"RecordShareTitlePlace") andName:@"shareRecordTitle" andFrame:CGRectMake(textFieldX, PositionY(shareRecordTitleLabel) + 12 * kScale, textFieldWidth, textFieldHight) andSuperView:_scrollView];
    shareRecordTitleField.textMaxLength = 8;
    
    [_scrollView addSubview:shareRecordTitleField];
    
    shareRecordCatagoryLabel = [UIUtil createLabel:Local(@"RecordShareCatagory") andRect:Rect(x, PositionY(shareRecordTitleField) + 15 * kScale, width, height) andTextColor:RGB(51,51,51) andFont:ComFont(11*kScale) andAlpha:1];
    [_scrollView addSubview:shareRecordCatagoryLabel];
    
    shareRecordCatagoryField = [self textFieldWithPlaceHolder:Local(@"RecordShareCatagoryPlace") andName:@"shareRecordCatagory" andFrame:CGRectMake(textFieldX, PositionY(shareRecordCatagoryLabel) + 12 * kScale, textFieldWidth, textFieldHight) andSuperView:_scrollView];
    [_scrollView addSubview:shareRecordCatagoryField];
    
    
    //是否收费
    EMLabel *isChargeTitle = [UIUtil createLabel:[NSString stringWithFormat:@"%@:",Local(@"IsCharge")] andRect:Rect(x, PositionY(shareRecordCatagoryField)+25*kScale, 55 * kScale, 14 * kScale) andTextColor:RGB(51,51,51) andFont:ComFont(11*kScale) andAlpha:1];
    [_scrollView addSubview:isChargeTitle];
    
    
    _aSwitchBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(isChargeTitle), PositionY(shareRecordCatagoryField)+22*kScale, 43*kScale, 21*kScale)];
    [_aSwitchBtn setImage:[UIImage imageNamed:@"set_off"] forState:UIControlStateNormal];
    [_aSwitchBtn setImage:[UIImage imageNamed:@"set_on"] forState:UIControlStateSelected];
    [_aSwitchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_aSwitchBtn];
    
    //下一步
    x = (kScreenW - 100)/2.f;
    y = PositionY(_aSwitchBtn)+40*kScale;
    _publicBtn = [[EMButton alloc] initWithFrame:Rect(x, y, 100, 30) andConners:15];
    [_publicBtn setBackgroundImage:[UIUtil imageWithColor:RGB(145,90,173) andSize:CGSizeMake(100, 30)] forState:UIControlStateNormal];
    [_publicBtn setTitle:Local(@"Public")  forState:UIControlStateNormal];
    [_publicBtn addTarget:self action:@selector(publicAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_publicBtn];
    
//    //音效编辑区域
//    EMView *effectArea = [[EMView alloc] initWithFrame:Rect(0, PositionY(addEffect)+8*kScale, kScreenW, 177*kScale)];
//    effectArea.backgroundColor = RGBA(0, 0, 0, 0.5);
//    [_scrollView addSubview:effectArea];
//
//    _effectRangeView = [[UIZKRangeView alloc] initWithFrame:Rect(textFieldX, effectArea.frame.origin.y + 7, kScreenW - 2 * textFieldX, 48*kScale)];
//    _effectRangeView.backgroundColor = [UIColor clearColor];
//    _effectRangeView.leftRangeView.image = [UIImage imageNamed:@"icon_note"];
//    _effectRangeView.rightRangeView.image = [UIImage imageNamed:@"icon_note"];
//    [_effectRangeView setLeftHidden:YES];
//    [_effectRangeView setRightHidden:YES];
//    _effectRangeView.delegate = self;
//    [_scrollView addSubview:_effectRangeView];
//
//    //添加音量按钮
//    EMButton *volumeBtn =  [[EMButton alloc] initWithFrame:Rect(clipBtn.frame.origin.x, PositionY(_effectRangeView) + 32*kScale, 30*kScale, 24*kScale)];
//    [volumeBtn setImage:[UIImage imageNamed:@"bt_record_volume"] forState:UIControlStateNormal];
//    [volumeBtn setImage:[UIImage imageNamed:@"bt_record_volume_d"] forState:UIControlStateHighlighted];
//    [volumeBtn addTarget:self action:@selector(volumeAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_scrollView addSubview:volumeBtn];
//
//    //添加总的播放按钮
//    EMButton *playAllBtn =  [[EMButton alloc] initWithFrame:Rect(playButton.frame.origin.x, PositionY(_effectRangeView) + 32*kScale, playButton.frame.size.width, playButton.frame.size.height)];
//    [playAllBtn setImage:[UIImage imageNamed:@"record_play"] forState:UIControlStateNormal];
//    [playAllBtn setImage:[UIImage imageNamed:@"record_stop"] forState:UIControlStateSelected];
//    [playAllBtn addTarget:self action:@selector(playAllAction:) forControlEvents:UIControlEventTouchUpInside];
//
//    [_scrollView addSubview:playAllBtn];
//
//
//    //添加音效的按钮
//    EMButton *addEffectBtn =  [[EMButton alloc] initWithFrame:Rect(recordBtn.frame.origin.x, PositionY(_effectRangeView) + 21*kScale, 47*kScale,47 *kScale)];
//    [addEffectBtn setImage:[UIImage imageNamed:@"btn_add_music_p"] forState:UIControlStateNormal];
//    [addEffectBtn addTarget:self action:@selector(selectEffectAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_scrollView addSubview:addEffectBtn];
//
//    //删除全部音效
//    EMButton *deleteEffectBtn = [[EMButton alloc] initWithFrame:Rect(deleteBtn.frame.origin.x, PositionY(_effectRangeView) + 32*kScale, 22*kScale,22 *kScale)];
//    [deleteEffectBtn setImage:[UIImage imageNamed:@"record_trash"] forState:UIControlStateNormal];
//    [deleteEffectBtn addTarget:self action:@selector(deleteAllEffectAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_scrollView addSubview:deleteEffectBtn];
//
//
//    //音量处理view
//    _volumeAreaView = [[EMView alloc] initWithFrame:Rect(clipBtn.frame.origin.x, PositionY(deleteEffectBtn) + 31*kScale, kScreenW - 2*clipBtn.frame.origin.x, 26*kScale)];
//    _volumeAreaView.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.3);
//    [_scrollView addSubview:_volumeAreaView];
//    //音量大小
//    _volumeValueLabel = [[EMLabel alloc] initWithFrame:Rect(16*kScale, 0, 20*kScale, 26*kScale)];
//    _volumeValueLabel.font = ComFont(9);
//    _volumeValueLabel.text = @"50";
//    _volumeValueLabel.textColor = RGB(0xff,0xff,0xff);
//    [_volumeAreaView addSubview:_volumeValueLabel];
//    //    slider
//    UISlider *slider = [[UISlider alloc] initWithFrame:Rect(44*kScale, 0, _volumeAreaView.frame.size.width - 44*kScale - 18*kScale, 26*kScale)];
//    UIImage *cicleImage = [UIUtil circleImage:[UIColor colorWithWhite:1 alpha:0.8] andSize:CGSizeMake(13*kScale, 13*kScale)];
//    slider.minimumValue = 0;
//    slider.maximumValue = 100;
//    slider.value = 50;
//    [slider setThumbImage:cicleImage forState:UIControlStateNormal];
//    [slider setThumbImage:cicleImage forState:UIControlStateHighlighted];
//    [slider setMinimumTrackTintColor:RGB(235,173,255)];
//    [slider setMaximumTrackTintColor:RGBA(0xff, 0xff, 0xff,0.3)];
//
//    [slider addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
//
//    [_volumeAreaView addSubview:slider];
//    _volumeAreaView.hidden = YES;
//
    //添加scrollview
    [self.view addSubview:_scrollView];
    
//    [self setRecording:YES];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//    int currentTime = _nmSlider.lowerValue * _totalTime;
//    int seconds = (int)currentTime % 60;
//    int minutes = ((int)currentTime / 60) % 60;
//    NSString *leftText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
//    recordStartTime.text = leftText;
//    recordStartTime.labelId = [NSString stringWithFormat:@"%d",currentTime];
//
//    currentTime = _nmSlider.upperValue * _totalTime;
//    seconds = (int)currentTime % 60;
//    minutes = ((int)currentTime / 60) % 60;
//    NSString *rightText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
//    recordEndTime.text = rightText;
//    recordEndTime.labelId = [NSString stringWithFormat:@"%d",currentTime];
//
//}


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
    if ([name isEqualToString:@"shareRecordCatagory"]) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(catagoryAction)];
        filedBack.userInteractionEnabled = YES;
        [filedBack addGestureRecognizer:tapGesture];
        field.enabled = NO;
    }
    
    return field;
}

#pragma mark - UIAction

//删除全部音效
//- (void)deleteAllEffectAction:(EMButton*)btn {
//    AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"MakeSureDeleteAllRecord") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
//        if (buttonIndex == 1) {
//            _leftEffectObj = nil;
//            _rightEffectObj = nil;
//            [_effectRangeView setLeftHidden:YES];
//            [_effectRangeView setRightHidden:YES];
//        }
//    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
//    [alert show];
//}

//- (void)zkDidMoveRange:(int)leftStr andRightRange:(int)rightStr {
//
//}


//选择音效
//- (void)selectEffectAction:(EMButton*)btn {
//    //判断有没有录音，没有录音不能添加
//    if (!_audioPath) {
//        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
//        return;
//    }
//    _effectRangeView.totalCount = (int)_totalTime;
//    EffectSelectViewController *effectSelect = [[EffectSelectViewController alloc] init];
//    effectSelect.delegate = self;
//    [self.navigationController pushViewController:effectSelect animated:YES];
//
//}

////选择音效委托
//- (void)didSelectEffect:(BgAudioObj*)obj andController:(id)controller {
//    if (!_leftEffectObj) {
//        _leftEffectObj = [obj copy];
//    }else if (!_rightEffectObj) {
//        _rightEffectObj = [obj copy];
//    }
//    if (_effectRangeView.leftRangeView.hidden) {
//        [_effectRangeView setLeftHidden:NO];
//    }else if (_effectRangeView.rightRangeView.hidden) {
//        [_effectRangeView setRightHidden:NO];
//    }
//
//}

////播放总的音频
//- (void)playAllAction:(EMButton*)btn {
//    //判断有没有录音，有录音就播放
//    if (!_audioPath) {
//        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
//        return;
//    }
//
//    btn.selected = !btn.selected;
//    if (!_urlArray) {
//        _urlArray = [NSMutableArray array];
//    }
//    if (!_timeArray) {
//        _timeArray = [NSMutableArray array];
//    }
//    [_urlArray removeAllObjects];
//    [_timeArray removeAllObjects];
//    //播放全部音乐
//    if (btn.selected) {
//        _currentPlayBtn = btn;
//        if (_leftEffectObj) {
//            [_urlArray addObject:_leftEffectObj.fileURL];
//            int value = _effectRangeView.leftRangeValue-3 > 0 ? _effectRangeView.leftRangeValue-3 :_effectRangeView.leftRangeValue;
//            [_timeArray addObject:[NSNumber numberWithInt:value]];
//        }
//        if (_rightEffectObj) {
//            [_urlArray addObject:_rightEffectObj.fileURL];
//            int value = _effectRangeView.rightRangeValue-3 > 0 ? _effectRangeView.rightRangeValue-3 :_effectRangeView.rightRangeValue;
//            [_timeArray addObject:[NSNumber numberWithInt:value]];
//        }
//        NSString *path = [AudioPublicMethod getPathByFileName:_audioPath ofType:@"wav"];
//        float volume = [_volumeValueLabel.text intValue]/100.f;
//        _effectRangeView.audioPlayView.effectVolume = volume;
//        [_effectRangeView.audioPlayView playAudios:path andBlock:^(float currentTime, float allTime, BOOL isStop) {
//            if (isStop) {
//                [_effectRangeView.audioPlayView stopRemoteAudio];
//                btn.selected = NO;
//            }
//            btn.selected = _effectRangeView.audioPlayView.isAudioPlaying;
//            _effectRangeView.leftRangeView.userInteractionEnabled = !btn.selected;
//            _effectRangeView.rightRangeView.userInteractionEnabled = !btn.selected;
//        } isBackRemote:NO andOthers:_urlArray andTimeArray:_timeArray andAllTime:[NSString stringWithFormat:@"%lld",_totalTime]];
//    }else {
//        //关闭全部音乐
//        [_effectRangeView.audioPlayView stopRemoteAudio];
//        _currentPlayBtn = nil;
//        _effectRangeView.leftRangeView.userInteractionEnabled = !btn.selected;
//        _effectRangeView.rightRangeView.userInteractionEnabled = !btn.selected;
//    }
//
//
//
//}
//
////音量调整
//- (void)volumeAction:(EMButton*)btn {
//    btn.selected = !btn.selected;
//    _volumeAreaView.hidden = !btn.selected;
//}
//
////加上音效
//- (void)addEffectAction:(EMButton*)btn {
//    addEffect.selected = !addEffect.selected;
//    if (addEffect.selected) {
//        if (iphone4x_3_5) {
//            CGFloat y = PositionY(clipBtn) + 36;
//            _scrollView.contentSize = Size(0, y+14*kScale + 177*kScale + 4);
//            _scrollView.contentOffset = Point(0, _scrollView.contentSize.height - _scrollView.frame.size.height);
//
//        }else {
//            _scrollView.contentSize = Size(0, kScreenH - 64 + 177*kScale + 4);
//            _scrollView.contentOffset = Point(0, 177*kScale + 4);
//        }
//
//    }else {
//        if (iphone4x_3_5) {
//            CGFloat y = PositionY(clipBtn) + 36;
//            _scrollView.contentSize = Size(0, y+14*kScale);
//            _scrollView.contentOffset = Point(0, y+14*kScale-_scrollView.frame.size.height);
//        }else {
//            _scrollView.contentSize = Size(0,0);
//            _scrollView.contentOffset = Point(0, 0);
//        }
//
//    }
//}
//
//- (void)setRecording:(BOOL)ret {
//    playButton.enabled = !ret;
//    deleteBtn.enabled = !ret;
//    clipBtn.enabled = !ret;
//    _effectRangeView.userInteractionEnabled = !ret;
//
//}
//
//
//- (void)setPlaying:(BOOL)ret {
//    deleteBtn.enabled = !ret;
//    clipBtn.enabled = !ret;
//    recordBtn.enabled = !ret;
//}
//
//
//- (void)setCliping:(BOOL)ret {
//    deleteBtn.enabled = !ret;
//    playButton.enabled = !ret;
//    recordBtn.enabled = !ret;
//}


////录音点击
//- (void)recordAction:(EMButton*)btn {
//    //先判断有没有权限
//    //    if (![UIUtil haveDeviceAuthorization]){
//    //        [UIUtil showDeviceWarning];
//    //        return;
//    //    }
//    [btn setSelected:!btn.selected];
//    //如果在录音，其他按钮先屏蔽掉，反之，打开
//    [self setRecording:btn.selected];
//    if (btn.selected) {
//        [_waveView stopPlay];
//    }
//    _recordAudioPlayView.hidden = YES;
//    _waveView.hidden = NO;
//    [_waveView startRecord];
//    [_audioRecordVM recordButtonClick];
//}
//
////播放点击
//- (void)playAction:(EMButton*)btn {
//    //判断有没有录音，有录音就播放
//    if (!_audioPath) {
//        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
//        return;
//    }
//
//    [btn setSelected:!btn.selected];
//    //如果在播放，其他按钮先屏蔽掉，反之，打开
//    [self setPlaying:btn.selected];
//
//    if(btn.selected){
//        //播放
//        //把总长传过去
//        _currentPlayBtn = btn;
//        [_recordAudioPlayView setHidden:NO];
//        [_waveView setHidden:YES];
//        NSString *path = [AudioPublicMethod getPathByFileName:_audioPath ofType:@"wav"];
//        [_recordAudioPlayView playLocalAudio:path andBlock:^(float currentTime, float allTime, BOOL isStop) {
//            int seconds = (int)currentTime % 60;
//            int minutes = ((int)currentTime / 60) % 60;
//            NSString *leftText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
//            recordStartTime.text = leftText;
//            if (isStop) {
//                [_recordAudioPlayView stopLocalAudio];
//                btn.selected = NO;
//                [self setPlaying:btn.selected];
//            }else {
//                btn.selected = YES;
//                [self setPlaying:btn.selected];
//            }
//        }];
//    }else{
//        [_recordAudioPlayView stopLocalAudio];
//        _currentPlayBtn = nil;
//    }
//}
//
////删除点击
//- (void)deleteAction:(EMButton*)btn {
//    if (_audioPath) {
//        //        弹出确认删除的对话框
//        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"MakeSureDeleteRecord") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                //        先完成
//                [UIUtil showHUD:self.view];
//                [_audioRecordVM actionButtonClick];
//                [self performSelector:@selector(audioDelete) withObject:nil afterDelay:1];
//            }
//        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
//        [alert show];
//    }else {
//        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
//
//    }
//}
//
//- (void)audioDelete {
//    [_audioRecordVM deleteVedioNamed:_audioPath];
//
//    [_waveView clearSample];
//    [_waveView resetRightOrgin];
//    recordStartTime.text = @"00:00";
//    _audioRecordVM.totalSeconds = 0;
//    _audioPath = nil;
//    [_recordAudioPlayView stopLocalAudio];
//    _recordAudioPlayView.hidden = YES;
//    _waveView.hidden = NO;
//    [self setRecording:YES];
//    [UIUtil hideHUD:self.view];
//    [self.view makeToast:Local(@"DeleteSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
//}
//
//
////裁剪点击
//- (void)cutAction:(EMButton*)btn {
//    //判断有没有录音，有录音才能裁剪
//    if (!_audioPath) {
//        [self.view makeToast:Local(@"PlsRecordFirst") duration:ERRORTime position:[CSToastManager defaultPosition]];
//        return;
//    }
//
//    btn.selected = !btn.selected;
//
//
//    //如果在裁剪，其他按钮先屏蔽掉，反之，打开
//    [self setCliping:btn.selected];
//    if (btn.selected) {
//        //剪切
//        [UIUtil showHUD:self.view];
//        [_audioRecordVM actionButtonClick];
//        _waveView.hidden = YES;
//        _recordAudioPlayView.hidden = YES;
//        _nmSlider.hidden = NO;
//        _nmline.hidden = NO;
//        _cutWarningLabel.hidden = NO;
//        [self performSelector:@selector(audioCut) withObject:nil afterDelay:1];
//    }else {
//        //如果左右相等，不裁
//        if ([recordEndTime.labelId intValue] == [recordStartTime.labelId intValue]){
//            [self.view makeToast:Local(@"CutAlert") duration:ERRORTime position:[CSToastManager defaultPosition]];
//            btn.selected = YES;
//            [self setCliping:btn.selected];
//            return;
//        }
//        [UIUtil showHUD:self.view];
//        [_audioRecordVM cropActionWithAudioPath:_audioPath andLeftDuration:(double)[recordStartTime.labelId intValue] andRightDuration:(double)[recordEndTime.labelId intValue] andBlock:^(NSString *newPath) {
//            [UIUtil hideHUD:self.view];
//            _audioPath = newPath;
//            //把录音的关掉
//            [_waveView clearSample];
//            recordStartTime.text = @"00:00";
//            //显示左边的时间
//            int totalTime = [recordEndTime.labelId intValue] - [recordStartTime.labelId intValue];
//            _totalTime = totalTime;
//            _audioRecordVM.totalSeconds = totalTime;
//
//            //设置waveview总长度
//            _waveView.accountValue = totalTime;
//            int seconds = totalTime % 60;
//            int minutes = (totalTime / 60) % 60;
//            NSString *timeText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
//            recordStartTime.text = timeText;
//            recordEndTime.hidden = YES;
//            [self.view makeToast:Local(@"ClipSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
//            _effectRangeView.totalCount = (int)_totalTime;
//            _waveView.hidden = YES;
//            _recordAudioPlayView.hidden = NO;
//            _nmSlider.hidden = YES;
//            _nmline.hidden = YES;
//            _cutWarningLabel.hidden = YES;
//
//        }];
//    }
//}
//
//- (void)audioCut {
//    [UIUtil hideHUD:self.view];
//    //    把总长传给waveview
//    _waveView.accountValue =  _audioRecordVM.totalSeconds;
//    int seconds = _waveView.accountValue % 60;
//    int minutes = (_waveView.accountValue / 60) % 60;
//    NSString *leftTimeText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
//    recordStartTime.text = leftTimeText;
//    recordStartTime.labelId = [NSString stringWithFormat:@"%d",0];
//
//    recordEndTime.text = recordStartTime.text;
//    recordEndTime.labelId = [NSString stringWithFormat:@"%lld",_audioRecordVM.totalSeconds];
//    recordStartTime.text = @"00:00";
//    recordEndTime.hidden = NO;
//    [_waveView showClipView];
//}

//分类点击
- (void)catagoryAction{
    CategoryViewController *category = [[CategoryViewController alloc] init];
    category.delegate = self;
    [self.navigationController pushViewController:category animated:YES];
}


//添加图片
- (void)addImageAction:(id)sender {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"ChoosePhoto") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            InnerImgViewController *innerImgSelect = [[InnerImgViewController alloc] init];
            innerImgSelect.delegate = self;
            [self.navigationController pushViewController:innerImgSelect animated:YES];
        }else if (buttonIndex == 2) {
            CameraSessionViewController *controller = [[CameraSessionViewController alloc] init];
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:NULL];
            controller = nil;
        }else if(buttonIndex == 3){
            UIImagePickerController *ipc=[[UIImagePickerController alloc] init];
            [ipc.navigationBar setBackgroundImage:[UIUtil imageWithColor:RGBA(0x98, 0x4a, 0xa6,1) andSize:Size(kScreenW, 64)] forBarMetrics:UIBarMetricsDefault];
            [ipc.navigationBar setTintColor:ColorFF];
            [ipc.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
            
            ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            ipc.delegate=self;
            [self presentViewController:ipc animated:YES completion:nil];
        }
        
        
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Local(@"InnerImg"),Local(@"Camra"),Local(@"ChooseFromAblue"),nil];
    [sheet showInView:self.view];;
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info{
    UIImage *img=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self cropImage:img];
}

//调用编辑图片
- (void)cropImage:(UIImage*)image{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length*10/17);
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
    navigationController = nil;
    controller = nil;
    
}


//拍照完成后的回调，去编辑图片
- (void)didCaptureImageWithImage:(UIImage*)image {
    [self cropImage:image];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    //    [self uploadImgToService:croppedImage];
    _topHeadBackgroundImageView.image = croppedImage;
    _addHeadButton.hidden = YES;
    _defaultImageView.hidden = YES;
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark AudioRecordVM Delegate
//- (void)didUpdateTime:(NSString*)time {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        recordStartTime.text = time;
//    });
//}
//
//- (void)didUpdateTimePower:(float)power {
//    // TODO: 更新音量波动大小view
//    //    DLog(@"powver==%f",power);
//    [_waveView updateView:power];
//}
//
////转换完成的委托
//- (void)didRecordMixComplete:(NSString*)path {
//    //保存录音总长度
//    _totalTime = _audioRecordVM.totalSeconds;
//    _audioPath = path;
//    DLog(@"保存完成path=%@",_audioPath);
//}

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


////完成录音
//- (void)recodeComplete:(NSString*)path {
//    DLog(@"path==%@",path);
//    //保存录音总长度
//    _totalTime = _audioRecordVM.totalSeconds;
//    _audioPath = path;
//}

#pragma mark AudioPlayerRecordVM Delegate
//-(void)didStopAudio {
//    if (_currentPlayBtn) {
//        [_currentPlayBtn setSelected:NO];
//        if (_currentPlayBtn != playButton) {
//            CGRect rect = _effectRangeView.cursorView.frame;
//            rect.origin.x = 0;
//            _effectRangeView.cursorView.frame = rect;
//            [_audioPlayerVM stopRemoteAudio];
//        }else {
//            //播放完成要把游标指到底
//            [_waveView updateSet:0];
//        }
//        [self setPlaying:NO];
//        _currentPlayBtn = nil;
//    }
//}

//- (void)didUpdateAudio:(float)time andValue:(NSString*)value {
//    //播放本地音频
//    if (_currentPlayBtn != playButton) {
//        if (_totalTime!=0) {
//            float currentWidth = ((time/40.f)/_totalTime)*_effectRangeView.frame.size.width;
//            CGRect rect = _effectRangeView.cursorView.frame;
//            if (currentWidth > _effectRangeView.frame.size.width - rect.size.width) {
//                currentWidth = _effectRangeView.frame.size.width;
//            }
//            rect.origin.x = currentWidth;
//            _effectRangeView.cursorView.frame = rect;
//        }
//    }else {
//        DLog(@"time===%f",time);
//
//        [_waveView updateSet:time];
//        recordStartTime.text = value;
//    }
//}


#pragma mark RecordWaveDelegate

//- (void)willUpdateLeftValue:(int)value andLeftText:(NSString*)leftText andRightValue:(int)rightValue andRightText:(NSString*)rightText {
//    recordStartTime.text = leftText;
//    //用labelID临时保存当前的时间，好用来裁剪
//    recordStartTime.labelId = [NSString stringWithFormat:@"%d",value];
//    recordEndTime.text = rightText;
//    //用labelID临时保存当前的时间，好用来裁剪
//    recordEndTime.labelId = [NSString stringWithFormat:@"%d",rightValue];
//}
//
//- (void)didStartLocalPan {
//    [_audioPlayerVM slideStartToChange];
//}
//
//- (void)didEndLocalPan:(int)value {
//    [_audioPlayerVM slideToEnd:value];
//
//}

//
//- (void)localUpdateLeftValue:(int)value andLeftText:(NSString*)leftText {
//    recordStartTime.text = leftText;
//    //用labelID临时保存当前的时间，好用来裁剪
//    recordStartTime.labelId = [NSString stringWithFormat:@"%d",value];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
