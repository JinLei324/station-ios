//
//  SignalRecordShowVC.m
//  LonelyStation
//
//  Created by zk on 16/8/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "PersonalStationDetailVC.h"
#import "UICycleImgView.h"
#import "ViewModelCommom.h"
#import "EMLabel.h"
#import "EMView.h"
#import "EMAlertView.h"
#import "RecordAiringVM.h"
#import "EMUtil.h"
#import "VoiceSliderView.h"
//#import "AudioPlayView.h"
#import "AudioRemotePlayView.h"
#import "UIUtil.h"
#import "MainViewVM.h"
#import "MainViewController.h"
#import "AllStationsCell.h"
#import "RateCell.h"
#import "EMTextView.h"
#import "UIImage+Blur.h"
#import "ChatViewController.h"
#import "AddMoneyMainVC.h"
#import "AppDelegate.h"
#import <IQKeyboardManager.h>
#define CellHeight 50

@interface PersonalStationDetailVC ()<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource> {
    RecordAiringVM *_recordAiringVM;
    
    EMButton *_maskBtnView;
    EMLabel *_reportLabel;
    EMView *_reportView;
    UITextView *_reportTextView;
    EMButton *_cancelReportBtn;
    EMButton *_sendReportBtn;
    
    EMButton *_careStationBtn;
    EMButton *_chatBtn;
    EMButton *_callBtn;


    EMTableView *_rateTableView;
    
    NSMutableArray *_dataArray;
    EMTextView *_commentTextView;
    
    BoardcastObj *_boardcastObjDetail;
    
    BOOL isSeen;
    int lastTime;
}

@property (nonatomic,strong)AudioRemotePlayView *audioPlayerView;


@property (nonatomic,assign)int listestenTime;

@property (nonatomic,strong)MainViewVM *mainViewVM;

@property (nonatomic,strong)UIScrollView *imgScrollView;

@property (nonatomic,strong)UIPageControl *imgPageControl;

@property (nonatomic,strong)EMLabel *nameLabel;

@property (nonatomic,strong)EMLabel *collectLabel;

@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)EMLabel *titleLabel;

@property (nonatomic,strong)UIImageView *backImgView;

@property (nonatomic,strong)EMButton *playBtn;

@property (nonatomic,strong)EMLabel *playLabel;

@property (nonatomic,strong)EMButton *sayGoodBtn;

@property (nonatomic,strong)EMLabel *sayGoodLabel;

@property (nonatomic,strong)EMButton *rateBtn;

@property (nonatomic,strong)EMLabel *rateLabel;

@property (nonatomic,strong)EMButton *moreBtn;

@property (nonatomic,strong)EMLabel *moreLabel;

@property (nonatomic,strong)VoiceSliderView *slideView;

@property (nonatomic,strong)UIImageView *stationStatusView;

@property (nonatomic,strong)UIImageView *storyView;

@property (nonatomic,strong)UICycleImgView *headImgView;

//检举
@property (nonatomic,strong)EMButton *reportBtn;

//关注
@property (nonatomic,strong)EMButton *careBtn;

@end

@implementation PersonalStationDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self.viewNaviBar setTitle:Local(@"AiringLook") andColor:RGB(145,90,173)];
    [self initView];
    
    _dataArray = [NSMutableArray array];
    _recordAiringVM = [[RecordAiringVM alloc] init];
    
    _mainViewVM = [[MainViewVM alloc] init];
    
    [self loadData];
    [self getBasicInfo:_boardcastObj.recordId andUserId:_lonelyUser.userID];
    
    if (_shouldPlay) {
        [self playAction:_playBtn];
    }
    // Do any additional setup after loading the view.
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)applicationBecomeActive:(NSNotification *)notification {
    DLog(@"回来\n");
    if (_playBtn && _playBtn.isSelected){
        
    }
}





- (void)applicationWillResignActive:(NSNotification *)notification{
    DLog(@"按理说是触发home按下\n");
    if (_playBtn && _playBtn.isSelected){
//        [self playAction:_playBtn];
        
    }

}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}


//显示当前页面的广播
- (void)loadData {
    if (_stationDataArray && _stationDataArray.count > 0) {
        [_imgScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (int i = 0; i < _stationDataArray.count; i++) {
            BoardcastObj *boardObj = _stationDataArray[i];
            DLog(@"boardObj ==%@",boardObj.backImgURL);
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(kScreenW*i, 0, kScreenW, _imgScrollView.frame.size.height)];
            [imgView yy_setImageWithURL:[NSURL URLWithString:boardObj.backImgURL] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                if (_lonelyUser.seenTime.length > 0){
                    [imgView yy_setImageWithURL:[NSURL URLWithString:boardObj.backImgURL] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]]];
                }else{
                    imgView.image = [imgView.image blurredImage:BlurAlpha];
                }
            }];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            [_imgScrollView addSubview:imgView];
        }
        _imgScrollView.contentSize = Size(kScreenW*_stationDataArray.count, 0);
        _imgPageControl.numberOfPages = _stationDataArray.count;
        _imgPageControl.currentPage = 0;
        _imgPageControl.hidden = NO;
        [_imgScrollView setScrollEnabled:YES];
        _timeLabel.hidden = NO;
        _imgPageControl.currentPage = _index;
        [_imgScrollView setContentOffset:Point(kScreenW*_index, 0)];
    }else {
        [_imgScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        BoardcastObj *boardObj = _boardcastObj;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(kScreenW*0, 0, kScreenW, _imgScrollView.frame.size.height)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        [imgView yy_setImageWithURL:[NSURL URLWithString:boardObj.backImgURL] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]]];
        [_imgScrollView addSubview:imgView];
        [_imgScrollView setScrollEnabled:NO];
        _imgPageControl.hidden = YES;
        [_imgScrollView setContentOffset:Point(0, 0)];
    }
    
    
    //获取user详情
    WS(weakSelf);
    [_mainViewVM getPersonalInfo:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyStationUser *user = [[LonelyStationUser alloc] initWithDictory:dict[@"data"]];
                weakSelf.lonelyUser = user;
                //判断按钮状态
                if ([@"Y" isEqualToString:_lonelyUser.msgCharge]) {
                    [_chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_pay"] forState:UIControlStateNormal];
                    [_chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_pay"] forState:UIControlStateHighlighted];
                }
                
                //先判断允不允许打电话
                if ([weakSelf.lonelyUser.allowTalk intValue] == 1) {
                    if (_lonelyUser.isOnLine && [_lonelyUser.identity isEqualToString:@"3"] && [_lonelyUser.optState isEqualToString:@"Y"] && [_lonelyUser.connectStat isEqualToString:@"N"]) {
                        [_callBtn setEnabled:YES];
                        //如果msgCharge为Y,设置为红色
                        if([@"Y" isEqualToString:_lonelyUser.talkCharge]) {
                            [_callBtn setImage:[UIImage imageNamed:@"enjoy_call_pay"] forState:UIControlStateNormal];
                            [_callBtn setImage:[UIImage imageNamed:@"enjoy_call_pay"] forState:UIControlStateNormal];
                        }else {
                            [_callBtn setImage:[UIImage imageNamed:@"chat_call"] forState:UIControlStateNormal];
                            [_callBtn setImage:[UIImage imageNamed:@"chat_call"] forState:UIControlStateNormal];
                        }
                    }else {
                        [_callBtn setEnabled:NO];
                    }
                }else{
                    [_callBtn setEnabled:NO];
                }
            }
        }
    }];

  
    
}


//判断这个用户是否是自己关注的和这则广播是否被收藏
- (void)getBasicInfo:(NSString*)recordId andUserId:(NSString*)userId {
    //获取剩余时间
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_mainViewVM getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict) {
            if ([dict[@"code"] intValue] == 1) {
                user.talkSecond = dict[@"data"][@"talk_second"];
                user.radioSecond = dict[@"data"][@"radio_second"];
                user.vipStartSecond = dict[@"data"][@"vip_start_time"];
                user.vipEndSecond = dict[@"data"][@"vip_end_time"];
                user.chat_point = dict[@"data"][@"chat_point"];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
            }
        }
    }];
    
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
                _timeLabel.text = [EMUtil getTimeToNow:_boardcastObjDetail.updateTime];

                if (_boardcastObjDetail.favoriteTime && _boardcastObjDetail.favoriteTime.length > 0) {
                    _careStationBtn.selected = YES;
                }else {
                    _careStationBtn.selected = NO;
                }
                if (_boardcastObjDetail.collectTime && _boardcastObjDetail.collectTime.length > 0) {
                    _careBtn.selected = YES;
                }else {
                    _careBtn.selected = NO;
                }
                [_audioPlayerView stopRemoteAudio];
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
                if (_boardcastObjDetail.isCharge && [_boardcastObjDetail.isCharge isEqualToString:@"Y"]) {
                    [_playBtn setImage:[UIImage imageNamed:@"formplay_r"] forState:UIControlStateNormal];
                }else {
//                    [_playBtn setImage:[UIImage imageNamed:@"formplay_r"] forState:UIControlStateNormal];
                    [_playBtn setImage:[UIImage imageNamed:@"enjoyPlay"] forState:UIControlStateNormal];
                }
              
            }
        }
    }];
}

//显示检举的view
- (void)showReportAction:(EMButton*)btn {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 1;
        CGFloat height = 209*kScale;
        CGFloat y = (kScreenH - height)/2.f-100;
        _reportView.frame = Rect(0, y, kScreenW, height);
        _reportLabel.alpha = 1;
        _reportTextView.alpha = 1;
        _cancelReportBtn.alpha = 1;
        _sendReportBtn.alpha = 1;
        
    } completion:NULL];
}

//隐藏检举
- (void)hiddenMask:(EMButton*)btn {
    [_reportTextView resignFirstResponder];
    _reportLabel.alpha = 0;
    _reportTextView.alpha = 0;
    _cancelReportBtn.alpha = 0;
    _sendReportBtn.alpha = 0;
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 0;
        CGRect frame = _maskBtnView.frame;
        _reportView.frame = Rect(frame.size.width/2, frame.size.height/2, 0, 0);
    } completion:NULL];
}


//送出检举的事件
- (void)reportAction:(EMButton*)btn {
    NSString *str = _reportTextView.text;
    [_reportTextView resignFirstResponder];
    if ([str isEqualToString:Local(@"PlsInputWords3to50")]) {
        str = @"";
    }
    if (str.length >= 3 && str.length <= 50) {
        [_reportTextView resignFirstResponder];
        [self.view endEditing:YES];
        [UIUtil showHUD:self.navigationController.view];
        [_mainViewVM reportActionWithOtherId:_lonelyUser.userID andReason:_reportTextView.text andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:self.navigationController.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1){
                    [self hiddenMask:nil];
                    [self.view makeToast:Local(@"ReportSuccess") duration:3 position:[CSToastManager defaultPosition]];
                }else {
                    [_maskBtnView makeToast:dict[@"msg"] duration:3 position:[CSToastManager defaultPosition]];
                }
            }else {
                [_maskBtnView makeToast:Local(@"HandleFailed") duration:3 position:[CSToastManager defaultPosition]];
            }
        }];
    }else {
        [_maskBtnView makeToast:Local(@"PlsmakesureyourWords") duration:3 position:[CSToastManager defaultPosition]];
    }
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
    if (textView == _reportTextView) {
        if ([textView.text isEqualToString:Local(@"PlsInputWords3to50")]) {
            textView.text = @"";
        }
    }else {
        if ([textView.text isEqualToString:Local(@"IWantRate")]) {
            textView.text = @"";
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == _reportTextView) {
        if ([textView.text isEqualToString:@""]) {
            textView.text = Local(@"PlsInputWords3to50");
        }
    }else{
        if ([textView.text isEqualToString:@""]) {
            textView.text = Local(@"IWantRate");
        }
    }
    
}

//收藏和取消收藏
- (void)collectAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    WS(weakSelf);
    if (btn.selected) {
        //收藏
        [UIUtil showHUD:self.navigationController.view];
        [_mainViewVM addCollectWithRecordId:_boardcastObj.recordId andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:weakSelf.navigationController.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    [weakSelf.navigationController.view makeToast:Local(@"CollectSuccess") duration:1 position:[CSToastManager defaultPosition]];
                }else {
                    btn.selected = NO;
                    [weakSelf.navigationController.view  makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                }
            }else {
                btn.selected = NO;
                [weakSelf.navigationController.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
            }
        }];
    }else{
        //取消收藏
        [UIUtil showHUD:self.navigationController.view];
        [_mainViewVM deleteCollectWithRecordId:_boardcastObj.recordId andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:self.navigationController.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    [weakSelf.navigationController.view makeToast:Local(@"CollectCancelSuccess") duration:1 position:[CSToastManager defaultPosition]];
                }else {
                    btn.selected = YES;
                    [weakSelf.navigationController.view  makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                }
            }else {
                btn.selected = YES;
                [weakSelf.navigationController.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
            }
        }];
    }
}


//关注和取关
- (void)careAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    WS(weakSelf);

    if (btn.selected) {
        //关注
        [UIUtil showHUD:self.navigationController.view];
        [_mainViewVM careActionWithOtherId:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:self.navigationController.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    [weakSelf.navigationController.view makeToast:Local(@"CareSuccess") duration:1 position:[CSToastManager defaultPosition]];
                }else {
                    btn.selected = NO;
                    [weakSelf.navigationController.view  makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                }
            }else {
                btn.selected = NO;
                [weakSelf.navigationController.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
            }
        }];
    }else{
        //取关
        [UIUtil showHUD:self.navigationController.view];
        [_mainViewVM deleteCareActionWithOtherId:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:weakSelf.navigationController.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    [weakSelf.navigationController.view makeToast:Local(@"CareCancelSuccess") duration:1 position:[CSToastManager defaultPosition]];
                }else {
                    btn.selected = YES;
                    [weakSelf.navigationController.view  makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                }
            }else {
                btn.selected = YES;
                [weakSelf.navigationController.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
            }
        }];
    }
   
}

- (void)changeRadioTime {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    int radioSecond = [user.radioSecond intValue];
    if (_listestenTime != 0) {
        radioSecond -= _listestenTime;
        if (radioSecond < 0) {
            radioSecond = 0;
        }
        user.radioSecond = [NSString stringWithFormat:@"%d",radioSecond];
        [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
    }
}

- (void)back:(id)sender {
    [_audioPlayerView stopRemoteAudio];
    DLog(@"aaa==%d",_listestenTime);
    //记录到服务器
    if (_listestenTime != 0) {
        [self changeRadioTime];
        if (!isSeen) {
            isSeen = YES;
            [_mainViewVM setRecordSeen:_boardcastObj.recordId andTime:[NSString stringWithFormat:@"%d",_listestenTime] andBlock:^(NSDictionary *dict, BOOL ret) {
                if (dict && ret) {
                    _listestenTime = 0;
                }else{
                    isSeen = NO;
                }
            }];
        }
       
    }

    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"MainViewController"]) {
            MainViewController *main = self.navigationController.viewControllers[i];
            [main shouldLoadData];
            break;
        }
    }
    
    [super back:sender];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _imgScrollView) {
        int page = scrollView.contentOffsetX / kScreenW;
        _imgPageControl.currentPage = page;
        if (_stationDataArray && _stationDataArray.count >= page + 1) {
            if (_listestenTime != 0) {
                NSString *recordId = _boardcastObj.recordId;
                //判断是不是免费，免费的不减时间
                if (_boardcastObj.isCharge && [_boardcastObj.isCharge isEqualToString:@"Y"]) {
                    [self changeRadioTime];
                }
                [_mainViewVM setRecordSeen:recordId andTime:[NSString stringWithFormat:@"%d",_listestenTime] andBlock:^(NSDictionary *dict, BOOL ret) {
                    _listestenTime = 0;
                }];
            }
            self.boardcastObj = _stationDataArray[page];
            [_playBtn setSelected:NO];
            [_audioPlayerView reallyStop];
        }
    }
   
}

- (void)setBoardcastObj:(BoardcastObj *)boardcastObj {
    _lonelyUser = nil;
    _boardcastObj = nil;
    _boardcastObj = boardcastObj;
    _lonelyUser = _boardcastObj.user;
    [self setBoardcastValue];
}

- (void)setBoardcastValue {
    if (_boardcastObj) {
        [_headImgView yy_setImageWithURL:[NSURL URLWithString:_lonelyUser.file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if (_lonelyUser.seenTime.length > 0){
                [_headImgView yy_setImageWithURL:[NSURL URLWithString:_lonelyUser.file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]]];
            }else{
                _headImgView.image = [_headImgView.image blurredImage:BlurAlpha];
            }
        }];
        _nameLabel.text = [NSString stringWithFormat:@"%@:%@",_lonelyUser.identityName,_lonelyUser.nickName];
        _collectLabel.text = [NSString stringWithFormat:@"%@:%@",_boardcastObj.category,_boardcastObj.title];
        _timeLabel.text = [EMUtil getTimeToNow:_boardcastObj.updateTime];
        _titleLabel.text = _boardcastObj.title;
        _audioPlayerView.allTime = [_boardcastObj.duration intValue];
        [self getBasicInfo:_boardcastObj.recordId andUserId:_lonelyUser.userID];
    }
}


- (void)initView {
    UIScrollView *backView = [[UIScrollView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64 - 49)];
    
    _headImgView = [[UICycleImgView alloc] initWithFrame:Rect(11*kScale, 10*kScale, 42*kScale, 42*kScale)];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_headImgView yy_setImageWithURL:[NSURL URLWithString:_lonelyUser.file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgNameUseSelfGender:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (_lonelyUser.seenTime.length > 0){
            [_headImgView yy_setImageWithURL:[NSURL URLWithString:_lonelyUser.file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgNameUseSelfGender:user.gender]]];
        }else{
            _headImgView.image = [_headImgView.image blurredImage:BlurAlpha];
        }
    }];
    [backView addSubview:_headImgView];
    
    _stationStatusView = [[UIImageView alloc] initWithFrame:Rect(PositionX(_headImgView) + 14*kScale, _headImgView.frame.origin.y, 20*kScale, 20*kScale)];
    _stationStatusView.image = [UIImage imageNamed:@"icon_user_lover"];
    [backView addSubview:_stationStatusView];
    
    _nameLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_stationStatusView) + 8*kScale, _headImgView.frame.origin.y + 5*kScale, 150, 12*kScale)];
    _nameLabel.text = [NSString stringWithFormat:@"%@",_lonelyUser.nickName];
    _nameLabel.textColor = RGB(51,51,51);
    _nameLabel.font = ComFont(11*kScale);
    [backView addSubview:_nameLabel];
    
    
    _storyView = [[UIImageView alloc] initWithFrame:Rect(PositionX(_headImgView) + 14*kScale, PositionY(_nameLabel)+12*kScale, 10*kScale, 10*kScale)];
    _storyView.image = [UIImage imageNamed:@"enjoyClass"];
    [backView addSubview:_storyView];
    _collectLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_stationStatusView) + 8*kScale, PositionY(_nameLabel)+10*kScale, 180, 12*kScale)];
    _collectLabel.textColor = RGB(51,51,51);
    _collectLabel.font = ComFont(11*kScale);
    _collectLabel.text = [NSString stringWithFormat:@"%@",_boardcastObj.title];
    
    [backView addSubview:_collectLabel];
    
    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW-110*kScale, _headImgView.frame.origin.y + 5*kScale, 100*kScale, 12*kScale)];
    _timeLabel.textColor = RGB(145,90,173);
    _timeLabel.font = ComFont(11*kScale);
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [backView addSubview:_timeLabel];
    
    //滑动的图片
    _imgScrollView = [[UIScrollView alloc] initWithFrame:Rect(0, PositionY(_collectLabel)+8*kScale, kScreenW, 221*kScale)];
    _imgScrollView.bounces = NO;
    _imgScrollView.pagingEnabled = YES;
    _imgScrollView.delegate = self;
    [backView addSubview:_imgScrollView];
    
    
    _imgPageControl = [[UIPageControl alloc] initWithFrame:Rect(kScreenW - 110 - 12*kScale - 19 - 100, 5*kScale, 200, 21*kScale)];
    _imgPageControl.currentPageIndicatorTintColor = RGBA(152,79,166,0.9);
//    [backView addSubview:_imgPageControl];
    
    EMView *titleBackView = [[EMView alloc] initWithFrame:Rect(0, PositionY(_collectLabel)+24*kScale, 216*kScale, 45*kScale)];
    titleBackView.backgroundColor = RGBA(0,0,0,0.3);
    [backView addSubview:titleBackView];

    _titleLabel =[[EMLabel alloc] initWithFrame:Rect(23*kScale, PositionY(_collectLabel)+24*kScale, 193*kScale, 45*kScale)];
    _titleLabel.textColor = RGB(255,255,255);
    _titleLabel.text = _boardcastObj.title;
    _titleLabel.font = ComFont(13*kScale);
    [backView addSubview:_titleLabel];

    if (_isFromAllStation) {
        _imgScrollView.frame = Rect(0, PositionY(_collectLabel)+8*kScale, kScreenW, 221*kScale);
        titleBackView.frame = Rect(0, PositionY(_timeLabel)+74*kScale, 216*kScale, 45*kScale);
        _titleLabel.frame = Rect(23*kScale, PositionY(_timeLabel)+74*kScale, 193*kScale, 45*kScale);
    }
    
    CGFloat x = 26*kScale;
    CGFloat width = 43 *kScale;
    CGFloat space = (kScreenW - 2 * x - 4 * width) / 3.f;
    
    _playBtn = [[EMButton alloc] initWithFrame:Rect(x, PositionY(_headImgView) + 179 * kScale, width, width) isRdius:YES];
    [_playBtn setImage:[UIImage imageNamed:@"enjoyPlay"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"enjoyStop"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:_playBtn];
    
    
    _sayGoodBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_playBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_sayGoodBtn setImage:[UIImage imageNamed:@"enjoyGood"] forState:UIControlStateNormal];
    [_sayGoodBtn setImage:[UIImage imageNamed:@"enjoyGood_d"] forState:UIControlStateSelected];
    [_sayGoodBtn addTarget:self action:@selector(sayGoodAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_sayGoodBtn];
    
    
    _rateBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_sayGoodBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_rateBtn setImage:[UIImage imageNamed:@"enjoyMessage"] forState:UIControlStateNormal];
    [_rateBtn setImage:[UIImage imageNamed:@"enjoyMessage_d"] forState:UIControlStateSelected];
    [_rateBtn addTarget:self action:@selector(rateAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_rateBtn];
    
    _moreBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_rateBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_moreBtn setImage:[UIImage imageNamed:@"enjoyMore"] forState:UIControlStateNormal];
    [_moreBtn setImage:[UIImage imageNamed:@"enjoyMore_d"] forState:UIControlStateHighlighted];
    [_moreBtn setImage:[UIImage imageNamed:@"enjoyMore_d"] forState:UIControlStateSelected];

    [_moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_moreBtn];
    
    _reportBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_rateBtn)+space, _playBtn.frame.origin.y - width*2 - 14*kScale, width, width) isRdius:YES];
    [_reportBtn setImage:[UIImage imageNamed:@"enjoyReport"] forState:UIControlStateNormal];
    [_reportBtn setImage:[UIImage imageNamed:@"enjoyReport_d"] forState:UIControlStateHighlighted];
    _reportBtn.hidden = YES;
    [_reportBtn addTarget:self action:@selector(showReportAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_reportBtn];

    
    _careBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_rateBtn)+space, _playBtn.frame.origin.y - width - 7*kScale, width, width) isRdius:YES];
    [_careBtn setImage:[UIImage imageNamed:@"enjoyCollect"] forState:UIControlStateNormal];
    [_careBtn setImage:[UIImage imageNamed:@"enjoyCollect_d"] forState:UIControlStateHighlighted];
    [_careBtn setImage:[UIImage imageNamed:@"enjoyCollect_d"] forState:UIControlStateSelected];
    _careBtn.hidden = YES;
    [_careBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];

    [backView addSubview:_careBtn];
    
    
    EMView *lableBack = [[EMView alloc] initWithFrame:Rect(0, PositionY(_playBtn)+3*kScale, kScreenW, 21*kScale)];
    lableBack.backgroundColor = RGB(145,90,173);
    [backView addSubview:lableBack];
    
    _playLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_playBtn)+3*kScale, 42*kScale, 21*kScale)];
    _playLabel.textAlignment = NSTextAlignmentCenter;
    _playLabel.textColor = RGB(0xff, 0xff, 0xff);
    _playLabel.font = ComFont(11*kScale);
    _playLabel.text = Local(@"ListenMe");
    [backView addSubview:_playLabel];
    
    _sayGoodLabel = [[EMLabel alloc] initWithFrame:Rect(_sayGoodBtn.frame.origin.x, PositionY(_sayGoodBtn)+3*kScale, 42*kScale, 21*kScale)];
    _sayGoodLabel.textAlignment = NSTextAlignmentCenter;
    _sayGoodLabel.text = @"0";
    _sayGoodLabel.textColor = RGB(0xff, 0xff, 0xff);
    _sayGoodLabel.font = ComFont(11*kScale);
    [backView addSubview:_sayGoodLabel];
    
    _rateLabel = [[EMLabel alloc] initWithFrame:Rect(_rateBtn.frame.origin.x, PositionY(_rateBtn)+3*kScale, 42*kScale, 21*kScale)];
    _rateLabel.textAlignment = NSTextAlignmentCenter;
    _rateLabel.text = @"0";
    _rateLabel.textColor = RGB(0xff, 0xff, 0xff);
    _rateLabel.font = ComFont(11*kScale);
    [backView addSubview:_rateLabel];
    
    _moreLabel = [[EMLabel alloc] initWithFrame:Rect(_moreBtn.frame.origin.x, PositionY(_moreBtn)+3*kScale, 42*kScale, 21*kScale)];
    _moreLabel.textAlignment = NSTextAlignmentCenter;
    _moreLabel.textColor = RGB(0xff, 0xff, 0xff);
    _moreLabel.text = Local(@"More");
    _moreLabel.font = ComFont(11*kScale);
    [backView addSubview:_moreLabel];
    
    
    _audioPlayerView = [[AudioRemotePlayView alloc] initWithFrame:Rect(26*kScale, PositionY(_moreLabel), kScreenW - 52*kScale, 52 * kScale)];
    [backView addSubview:_audioPlayerView];
    _audioPlayerView.allTime = [_boardcastObj.duration intValue];
    _audioPlayerView.isShowLabel = YES;
    WS(weakSelf);
    _audioPlayerView.audioBok = ^(float currentTime,float allTime,BOOL isStop){
        if (isStop) {
            [weakSelf.playBtn setSelected:NO];
            
        }else {
            [weakSelf.playBtn setSelected:YES];
        }
        if (lastTime != (int)currentTime) {
            weakSelf.listestenTime = weakSelf.listestenTime + 1;
            lastTime = (int)currentTime;
            //判断时间够不够，够的话继续，不够了暂停，
            LonelyUser *user = [ViewModelCommom getCuttentUser];
            if ([user.chat_point intValue] > 170) {
                //如果时间不够，判断是不是免费的，免费的话啥都不动
                if (weakSelf.boardcastObj.isCharge && [weakSelf.boardcastObj.isCharge isEqualToString:@"Y"] && !isSeen) {
                    [weakSelf changeRadioTime];
                    isSeen = YES;
                    [weakSelf.mainViewVM setRecordSeen:weakSelf.boardcastObj.recordId andTime:[NSString stringWithFormat:@"%d",weakSelf.listestenTime] andBlock:^(NSDictionary *dict, BOOL ret) {
                        if (dict && ret) {
                            
                        }else{
                            isSeen = NO;
                        }
                    }];
                }
              
            }else if(weakSelf.boardcastObj.isCharge && [weakSelf.boardcastObj.isCharge isEqualToString:@"Y"]){
                weakSelf.listestenTime = 0;
                
                [weakSelf.playBtn setSelected:NO];
                //关掉
                [weakSelf.audioPlayerView stopRemoteAudio];
                //提示要充钱
                [weakSelf alertAddMoney];
            }
        }
        if(currentTime > 5 || isStop) {
            if (_lonelyUser.seenTime && _lonelyUser.seenTime.length == 0) {
                [weakSelf.mainViewVM getRecordEvenSeen:weakSelf.lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
                    if ([dict[@"code"] intValue] == 1) {
                        weakSelf.lonelyUser.seenTime = [EMUtil GetCurrentTime];
                        [weakSelf updateInfo];
                    }
                }];
            }
        }
    };
    [self.view addSubview:backView];
    
    
    //检举区域
    _maskBtnView = [[EMButton alloc] initWithFrame:Rect(0, 0, ScreenWidth, ScreenHeight)];
    _maskBtnView.alpha = 0;
    _maskBtnView.backgroundColor = RGBA(0, 0, 0,0.6);
    [_maskBtnView addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_maskBtnView];
    
    CGFloat height = 189*kScale;
    CGFloat y = (kScreenH - height)/2.f;
    _reportView = [[EMView alloc] initWithFrame:Rect(30*kScale, y, kScreenW-60*kScale, height)];
    _reportView.layer.backgroundColor = RGB(0xff, 0xff, 0xff).CGColor;
    _reportView.layer.cornerRadius = 10;
    _reportView.layer.masksToBounds = YES;
    [_maskBtnView addSubview:_reportView];
    
    _reportLabel = [UIUtil createLabel:Local(@"PlsInputReportReason") andRect:Rect(15*kScale, 26*kScale, kScreenW-60*kScale, 14*kScale) andTextColor:RGB(64,0,88) andFont:ComFont(13*kScale) andAlpha:1];
    _reportLabel.textAlignment = NSTextAlignmentCenter;
    [_reportView addSubview:_reportLabel];
    
    _reportTextView = [[UITextView alloc] initWithFrame:Rect(15*kScale, PositionY(_reportLabel)+14*kScale, kScreenW - 60*kScale, 80*kScale)];
    _reportTextView.text = Local(@"PlsInputWords3to50");
    _reportTextView.delegate = self;
    _reportTextView.layer.borderWidth = 1;
    _reportTextView.layer.borderColor = [UIColor colorWithRed:0.5686274509803921 green:0.35294117647058826 blue:0.6784313725490196 alpha:1.00].CGColor;
    [_reportView addSubview:_reportTextView];
    
    CGFloat reportWidth = (kScreenW - 30 * kScale * 2 - 35 *kScale)*0.5;
    _cancelReportBtn = [UIUtil buttonWithName:Local(@"CancelReport") andFrame:Rect(15*kScale, PositionY(_reportTextView) + 18*kScale, reportWidth, 40) andSelector:@selector(hiddenMask:) andTarget:self isEnable:YES];
    [_cancelReportBtn.titleLabel setFont:ComFont(14)];
    [_cancelReportBtn setTitleColor:RGB(0xff,0xff,0xff) forState:UIControlStateNormal];
    [_cancelReportBtn setBackgroundColor:[UIColor colorWithRed:0.6784313725490196 green:0.5215686274509804 blue:0.7647058823529411 alpha:1.00]];
    _cancelReportBtn.layer.cornerRadius = 13;
    _cancelReportBtn.layer.masksToBounds = YES;
    [_reportView addSubview:_cancelReportBtn];
    
    _sendReportBtn = [UIUtil buttonWithName:Local(@"SendReport") andFrame:Rect(PositionX(_cancelReportBtn) + 35*kScale, PositionY(_reportTextView) + 18*kScale, reportWidth, 40) andSelector:@selector(reportAction:) andTarget:self isEnable:YES];
    [_sendReportBtn.titleLabel setFont:ComFont(14)];
    [_sendReportBtn setTitleColor:RGB(0xff,0xff,0xff) forState:UIControlStateNormal];
    _sendReportBtn.layer.cornerRadius = 13;
    _sendReportBtn.layer.masksToBounds = YES;
    [_sendReportBtn setBackgroundColor:[UIColor colorWithRed:0.5686274509803921 green:0.35294117647058826 blue:0.6784313725490196 alpha:1.00]];
    [_reportView addSubview:_sendReportBtn];
    
    //首页，关注此人和语音聊天
    EMView *backTabView = [[EMView alloc] initWithFrame:Rect(0, kScreenH - 49, kScreenW, 49)];
    backTabView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backTabView];
    
    x = 50*kScale;
    width = 49;
    space = (kScreenW - width * 3 - 2*x)*0.5;
   
    
    _careStationBtn = [[EMButton alloc] initWithFrame:Rect(x, 0, width, width)];
    [_careStationBtn setImage:[UIImage imageNamed:@"enjoy_attention_d1"] forState:UIControlStateNormal];
    [_careStationBtn setImage:[UIImage imageNamed:@"enjoy_attention"] forState:UIControlStateHighlighted];
    [_careStationBtn setImage:[UIImage imageNamed:@"enjoy_attention"] forState:UIControlStateSelected];

    [_careStationBtn addTarget:self action:@selector(careAction:) forControlEvents:UIControlEventTouchUpInside];

    [backTabView addSubview:_careStationBtn];
    
    
    EMButton *backHomeBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_careStationBtn) + space, 0, width, width)];
    [backHomeBtn setImage:[UIImage imageNamed:@"enjoy_call_d"] forState:UIControlStateNormal];
    [backHomeBtn setImage:[UIImage imageNamed:@"enjoy_call_off"] forState:UIControlStateDisabled];
    [backHomeBtn addTarget:self action:@selector(chatCallUser) forControlEvents:UIControlEventTouchUpInside];
    [backTabView addSubview:backHomeBtn];
    
    _callBtn = backHomeBtn;
    
    
    EMButton *chatBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_callBtn)+space, 0, width, width)];
    [chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_d"] forState:UIControlStateNormal];
    [chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_d"] forState:UIControlStateHighlighted];
    _chatBtn = chatBtn;
    
    [chatBtn addTarget:self action:@selector(chatAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [backTabView addSubview:chatBtn];
    
    //评论tableView
    height = backView.bounds.size.height + (-1) * PositionY(_audioPlayerView) - 10 - 49 - 64;
    _rateTableView = [[EMTableView alloc] initWithFrame:Rect(0, PositionY(_audioPlayerView) + 10, kScreenW, height) style:UITableViewStyleGrouped];
    _rateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _rateTableView.delegate = self;
    _rateTableView.dataSource = self;
    [backView addSubview:_rateTableView];
    _rateTableView.hidden = NO;
    _rateTableView.backgroundColor = [UIColor clearColor];
}


- (void)chatCallUser {
    //拨打电话
    [EMUtil chatCallUser:_lonelyUser andController:self];
}


- (void)backHomeAction:(EMButton*)btn {
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LeftSlideViewController"]) {
            LeftSlideViewController *mainVC = self.navigationController.viewControllers[i];
            [self.navigationController popToViewController:mainVC animated:YES];
            break;
        }
    }
}

- (void)chatAction:(EMButton*)btn {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.gender isEqualToString:@"M"]) {
        //做判断，1.如果对方是收费，自己有秒数，弹提示1
        //2.如果聊天卡用完，弹购买提示
        //3.如果对方免费，谈提示无限畅聊卡，如果有聊天卡，使用聊天卡
        //4.如果无限畅聊卡都没有，谈提示
        WS(weakSelf)
        [EMUtil chatWithUser:_lonelyUser andFirstBlock:^{
            SS(weakSelf, strongSelf);
            [EMUtil pushToChat:_lonelyUser andViewController:strongSelf];
        } andSecondBlock:^{
            SS(weakSelf, strongSelf);
            AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
            [strongSelf.navigationController pushViewController:addMoneyMainVC animated:YES];
        }];
    }else {
        [EMUtil pushToChat:_lonelyUser andViewController:self];
    }
}


- (void)rateAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    _rateTableView.hidden = btn.selected;
}


- (void)updateInfo {
    [self loadData];
}


- (void)moreAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    _careBtn.hidden = !btn.selected;
    _reportBtn.hidden = !btn.selected;
}


- (void)alertAddMoney {
    AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"StationTimeNotEnough") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
            [self.navigationController pushViewController:addMoneyMainVC animated:YES];
        }
    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"AddMoney"), nil];
    [alert show];
    alert = nil;
}

- (void)playAction:(EMButton*)btn {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    //判断是否是收费的
    if (_boardcastObj.isCharge && [_boardcastObj.isCharge isEqualToString:@"Y"] && !isSeen){
        
        if (btn.selected) {
            btn.selected = NO;
            [_audioPlayerView stopRemoteAudio];
            return;
        }
        
        //提示
        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"WillSubSecond") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                //获取剩余时间
                WS(weakSelf)
                [_mainViewVM  getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
                    if (dict) {
                        if ([dict[@"code"] intValue] == 1) {
                            user.talkSecond = dict[@"data"][@"talk_second"];
                            user.radioSecond = dict[@"data"][@"radio_second"];
                            user.vipStartSecond = dict[@"data"][@"vip_start_time"];
                            user.vipEndSecond = dict[@"data"][@"vip_end_time"];
                            user.chat_point = dict[@"data"][@"chat_point"];
                            [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                            if ([user.chat_point intValue] <= 170) {
                                
                                [weakSelf alertAddMoney];
                                return;
                            }else {
                                btn.selected = !btn.selected;
                                if (btn.selected) {
                                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setSpeakerEnabled:YES];
                                    if (_boardcastObj.audioURL && _boardcastObj.audioURL.length > 0) {
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
                                        btn.selected = NO;
                                        [self.navigationController.view makeToast:Local(@"ThereisNoAiring") duration:1 position:[CSToastManager defaultPosition]];
                                    }
                                }else {
                                    [_audioPlayerView stopRemoteAudio];
                                }
                            }
                        }else{
                            [weakSelf.view.window makeToast:dict[@"msg"] duration:3 position:[CSToastManager defaultPosition]];
                            
                        }
                    }else {
                        [weakSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:3 position:[CSToastManager defaultPosition]];
                        
                    }
                }];

            }
            
        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
        [alert show];
    }else {
        //如果是免费
        btn.selected = !btn.selected;
        if (btn.selected) {
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] setSpeakerEnabled:YES];
            if (_boardcastObj.audioURL && _boardcastObj.audioURL.length > 0) {
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
                btn.selected = NO;
                [self.navigationController.view makeToast:Local(@"ThereisNoAiring") duration:1 position:[CSToastManager defaultPosition]];
            }
        }else {
            [_audioPlayerView stopRemoteAudio];
        }

    }
}


- (void)sayGoodAction:(EMButton*)btn {
    WS(weakSelf);
    [UIUtil showHUD:self.navigationController.view];
    [_mainViewVM sayGood:_boardcastObj.recordId andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.navigationController.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                [weakSelf.navigationController.view makeToast:Local(@"SayGoodSuccess") duration:1 position:[CSToastManager defaultPosition]];
                [weakSelf getBasicInfo:_boardcastObj.recordId andUserId:_lonelyUser.userID];
            }else {
                [weakSelf.navigationController.view  makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
            }
        }else {
            [weakSelf.navigationController.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    RateCell *cell = (RateCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[RateCell alloc] initWithSize:Size(kScreenW, CellHeight*kScale) reuseIdentifier:cellIdentifier];
    }
    cell.user = _lonelyUser;
    RateObj *obj = _dataArray[indexPath.row];
    cell.rateObj = obj;
    cell.backgroundColor = RGB(0xff, 0xff, 0xff);
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CellHeight*kScale;
}




- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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

//- (CGFloat)cacluRowHight {
//    CGFloat hight = CellHeight*kScale;
//    return hight;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return [self cacluRowHight];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//发送留言
- (void)sendRate:(EMButton*)btn {
    [self.view endEditing:YES];
    if (_commentTextView.text.length >= 3 && _commentTextView.text.length <= 100) {
        [_mainViewVM sendRate:_boardcastObj.recordId andComment:_commentTextView.text andBlock:^(NSDictionary *dict, BOOL ret) {
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    [self.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                    [self getBasicInfo:_boardcastObj.recordId andUserId:_lonelyUser.userID];
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
