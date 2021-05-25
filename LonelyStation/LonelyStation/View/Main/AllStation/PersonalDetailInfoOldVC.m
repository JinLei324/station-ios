//
//  SignalRecordShowVC.m
//  LonelyStation
//
//  Created by zk on 16/8/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "PersonalDetailInfoOldVC.h"
#import "UICycleImgView.h"
#import "ViewModelCommom.h"
#import "EMLabel.h"
#import "EMView.h"
#import "EMAlertView.h"
#import "RecordAiringVM.h"
#import "EMUtil.h"
#import "VoiceSliderView.h"
#import "AudioRemotePlayView.h"
#import "UIUtil.h"
#import "MainViewVM.h"
#import "MainViewController.h"
#import "AllStationsCell.h"
#import "RateCell.h"
#import "EMTextView.h"
#import "PersonalStationVC.h"
#import "AppDelegate.h"
#import "CallViewVM.h"
#import "UIImage+Blur.h"
#import "MyVoicesVC.h"
#import "ChatViewController.h"
#import "AddMoneyMainVC.h"
#import "RecordIntroduceVC.h"
#import "PersonalStationNewVC.h"
#import "IQKeyboardManager.h"

@interface PersonalDetailInfoOldVC ()<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate> {
    AudioRemotePlayView *_audioPlayerView;
    RecordAiringVM *_recordAiringVM;
    
    EMButton *_maskBtnView;
    EMLabel *_reportLabel;
    EMView *_reportView;
    UITextView *_reportTextView;
    EMButton *_cancelReportBtn;
    EMButton *_sendReportBtn;
    
    EMButton *_careStationBtn;
    
    EMTableView *_rateTableView;
    
    NSMutableArray *_dataArray;
    EMTextView *_commentTextView;
    
    BoardcastObj *_boardcastObjDetail;
    EMLabel *_titleLabel;
    CallViewVM *_callViewVM;
    
    UIScrollView *backView;
    
    BOOL isFirstIn;
}

@property (nonatomic,assign)int listestenTime;
@property (nonatomic,strong) MainViewVM *mainViewVM;
@property (nonatomic,strong)UIScrollView *imgScrollView;

@property (nonatomic,strong)UIPageControl *imgPageControl;

@property (nonatomic,strong)EMLabel *nameLabel;

@property (nonatomic,strong)EMLabel *collectLabel;

@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)UIImageView *backImgView;

@property (nonatomic,strong)EMButton *playBtn;

@property (nonatomic,strong)EMLabel *playLabel;

@property (nonatomic,strong)EMButton *stationBtn;

@property (nonatomic,strong)EMLabel *stationLabel;

@property (nonatomic,strong)EMButton *callBtn;

@property (nonatomic,strong)EMLabel *callLabel;

@property (nonatomic,strong)EMButton *rightBtn;

@property (nonatomic,strong)EMButton *leftBtn;

@property (nonatomic,strong)EMButton *chatBtn;

@property (nonatomic,strong)EMLabel *chatLabel;

@property (nonatomic,strong)EMButton *sendGift;

@property (nonatomic,strong)EMLabel *sendGiftLabel;

@property (nonatomic,strong)EMButton *careBtn;

@property (nonatomic,strong)EMLabel *careLabel;

@property (nonatomic,strong)EMButton *reportBtn;

@property (nonatomic,strong)EMLabel *reportLabel;

@property (nonatomic,strong)EMButton *lockBtn;

@property (nonatomic,strong)EMLabel *lockLabel;

@property (nonatomic,strong)VoiceSliderView *slideView;

@property (nonatomic,strong)UIImageView *stationStatusView;

@property (nonatomic,strong)UIImageView *storyView;

@property (nonatomic,strong)UIScrollView *btnScrollView;

@property (nonatomic,strong)UIImageView *notAuthorimageView;

@property (nonatomic,strong)EMButton *maskGiftBtnView;
@property (nonatomic,strong)EMView *sendView;

//检举
//@property (nonatomic,strong)EMButton *reportBtn;

//关注
//@property (nonatomic,strong)EMButton *careBtn;

@end

@implementation PersonalDetailInfoOldVC


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isFirstIn = NO;
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;

}

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
//    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
//    [self.view addSubview:backgroundImageView];
    
    [self.viewNaviBar setHidden:YES];
    [self initView];
    
    _callViewVM = [[CallViewVM alloc] init];
    
    _dataArray = [NSMutableArray array];
    _recordAiringVM = [[RecordAiringVM alloc] init];
    
    _mainViewVM = [[MainViewVM alloc] init];
    
    // Do any additional setup after loading the view.
    [self loadData:YES];
    
    if (_shouldPlay) {
        [self playAction:_playBtn];
    }
    
    
    
    //    if (_lonelyUser.authTime.length > 0) {
    //        _notAuthorimageView.hidden = YES;
    //    }else {
    //        _notAuthorimageView.hidden = NO;
    //    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = scrollView.contentOffsetX / kScreenW;
    _imgPageControl.currentPage = page;
    //    if (_dataArray && _dataArray.count >= page + 1) {
    //        self.boardcastObj = _dataArray[page];
    //    }
}

- (void)loadData:(BOOL)showHUD {
    //获取剩余时间
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_mainViewVM  getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict) {
            if ([dict[@"code"] intValue] == 1) {
                user.talkSecond = dict[@"data"][@"talk_second"];
                user.radioSecond = dict[@"data"][@"radio_second"];
                user.vipStartSecond = dict[@"data"][@"vip_start_time"];
                user.vipEndSecond = dict[@"data"][@"vip_end_time"];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
            }
        }
    }];
    
    if (showHUD) {
        [UIUtil showHUD:self.view];
    }
    //获取该人物的基本信息
    [_mainViewVM getPersonalInfo:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
        if (showHUD) {
            [UIUtil hideHUD:self.view];
        }
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                _lonelyUser = nil;
                _lonelyUser = [[LonelyStationUser alloc] initWithDictory:dict[@"data"]];
                DLog(@"_lonelyUser.city==%@",_lonelyUser.city);
                [self updateInfo];
            }
        }else {
            
        }
    }];
}

-(void)updateInfo {
    //更新可以滑动的公开照，私人照
    NSMutableArray *imgArray = [NSMutableArray array];
    if (_lonelyUser.file.length > 0) {
        [imgArray addObject:_lonelyUser.file];
    }
    
    if (_lonelyUser.file2.length > 0) {
        [imgArray addObject:_lonelyUser.file2];
    }
    BOOL isNotOpenPrivate = YES;
    //是否公开私人照
    if (_lonelyUser.authTime.length > 0) {
        isNotOpenPrivate = NO;
        if (_lonelyUser.file3.length > 0) {
            [imgArray addObject:_lonelyUser.file3];
        }
        if (_lonelyUser.file4.length > 0) {
            [imgArray addObject:_lonelyUser.file4];
        }
        if (_lonelyUser.file5.length > 0) {
            [imgArray addObject:_lonelyUser.file5];
        }
    }
    //把照片放上去
    if (imgArray && imgArray.count > 0) {
        [_imgScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (int i = 0; i < imgArray.count; i++) {
            NSString *str = imgArray[i];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(kScreenW*i, 0, kScreenW, _imgScrollView.frame.size.height)];
            [imgView yy_setImageWithURL:[NSURL URLWithString:str] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                if (_lonelyUser.seenTime.length > 0){
                    [imgView yy_setImageWithURL:[NSURL URLWithString:str] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]]];
                }else{
                    imgView.image = [imgView.image blurredImage:BlurAlpha];
                }
            }];
            //            [imgView yy_setImageWithURL:[NSURL URLWithString:str] placeholder:[UIImage imageNamed:@"answer_no_photo"]];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            [_imgScrollView addSubview:imgView];
        }
        NSInteger count = imgArray.count;
        //判断有没有公开私人照，没有的话，加上一张不能看的图
        if (isNotOpenPrivate) {
            _notAuthorimageView = [[UIImageView alloc] initWithFrame:Rect(kScreenW*(count), 0, kScreenW, _imgScrollView.frame.size.height)];
            _notAuthorimageView.image = [UIImage imageNamed:@"PERnotSeePhoto"];
            [_imgScrollView addSubview:_notAuthorimageView];
            
            EMLabel *infoLabel = [[EMLabel alloc] initWithFrame:Rect(40*kScale, 70*kScale, kScreenW-80*kScale, 59*kScale)];
            infoLabel.backgroundColor = RGBA(0, 0, 0, 0.5);
            [_notAuthorimageView addSubview:infoLabel];
            infoLabel.text = Local(@"YouHaveNotAuthor");
            infoLabel.textAlignment = NSTextAlignmentCenter;
            infoLabel.textColor = RGB(0xff, 0xff, 0xff);
            infoLabel.font = ComFont(14*kScale);
            
            UIImageView *imageLock = [[UIImageView alloc] initWithFrame:Rect(15*kScale, 14*kScale, 24*kScale, 31*kScale)];
            imageLock.image = [UIImage imageNamed:@"PERblockade"];
            [infoLabel addSubview:imageLock];
            count += 1;
        }
        _imgScrollView.contentSize = Size(kScreenW*count, 0);
        _imgPageControl.numberOfPages = count;
        _imgPageControl.currentPage = 0;
        _imgPageControl.hidden = NO;
        [_imgScrollView setScrollEnabled:YES];
        _timeLabel.hidden = NO;
        _timeLabel.text = [EMUtil getTimeToNowWithSec:_lonelyUser.lastOnlineTime];
        _imgScrollView.hidden = NO;
    }else {
        [_imgScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(0, 0, kScreenW, _imgScrollView.frame.size.height)];
        [imgView yy_setImageWithURL:[NSURL URLWithString:@""] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]]];
        [_imgScrollView addSubview:imgView];
        [_imgScrollView setScrollEnabled:NO];
    }
    
    //判断是否在线，是否能打电话，听广播
    //判断是否有自介，有的话就能点，没有就不能点
    if (_lonelyUser.voice.length == 0) {
        [_playBtn setEnabled:NO];
    }else {
        [_playBtn setEnabled:YES];
    }
    
    //判断广播数量是否为0，为0就不能点
    if (_lonelyUser.recordsSum.intValue == 0) {
        [_stationBtn setEnabled:NO];
    }else {
        [_stationBtn setEnabled:YES];
    }
    
    //判断是否离线，离线的话就不能点，如果在线但接听时间不在允许范围之内，不能接，弹出相应的提示，只有在线而且接听时间在允许范围之内，才能接
    //        如果online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’N’，   紅框處顯示亮的話筒。
    //        如果 online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’Y’，紅框處顯示暗的話筒。
    //        如果 online=’Y’，identity=’1’ or ‘2’，不管OpStat和ConnectStat，紅框處一律顯示暗的話筒。
    //        如果online=’N’，紅框處一律都顯示暗的話筒。
    
    //先判断允不允许打电话
    if ([_lonelyUser.allowTalk intValue] == 1) {
        if (_lonelyUser.isOnLine && [_lonelyUser.identity isEqualToString:@"3"] && [_lonelyUser.optState isEqualToString:@"Y"] && [_lonelyUser.connectStat isEqualToString:@"N"]) {
            [_callBtn setEnabled:YES];
            //如果msgCharge为Y,设置为红色
            if([@"Y" isEqualToString:_lonelyUser.talkCharge]) {
                [_callBtn setImage:[UIImage imageNamed:@"PEcall_pay"] forState:UIControlStateNormal];
            }else {
                [_callBtn setImage:[UIImage imageNamed:@"PEcall_free"] forState:UIControlStateNormal];
            }
        }else {
            [_callBtn setEnabled:NO];
        }
    }else{
        [_callBtn setEnabled:NO];
    }
    
    
    //如果msgCharge为Y,设置为红色
    if([@"Y" isEqualToString:_lonelyUser.msgCharge]) {
        [_chatBtn setImage:[UIImage imageNamed:@"PEchat_pay"] forState:UIControlStateNormal];
    }else {
        [_chatBtn setImage:[UIImage imageNamed:@"PEchat"] forState:UIControlStateNormal];
    }
    //判断手否有封锁过，如果有，封锁不能点
    if (_lonelyUser.blockByMeTime.length > 0){
        [_lockBtn setEnabled:NO];
    }else {
        [_lockBtn setEnabled:YES];
    }
    //判断是否有关注过
    if (_lonelyUser.favoriteTime.length > 0){
        [_careBtn setSelected:YES];
    }else{
        [_careBtn setSelected:NO];
    }
    
    //判断是否还有剩余时间，如果剩余时间不够，不能送礼
    
    
    NSArray *labelArray = @[Local(@"Age"), Local(@"Country"),Local(@"City"),Local(@"Height"),Local(@"Weight"),Local(@"Job"),Local(@"Slogan")];
    NSArray *labelValue = @[[NSString stringWithFormat:@"%@%@",_lonelyUser.age,Local(@"Year")],_lonelyUser.country,_lonelyUser.city,_lonelyUser.height,_lonelyUser.weight,_lonelyUser.job,_lonelyUser.slogan];
    for (int i = 0; i < labelValue.count; i++) {
        UILabel *label = [backView viewWithTag:1000+i];
        if (i == 0) {
            label.text = [NSString stringWithFormat:@"%@:%@",_lonelyUser.identityName,_lonelyUser.nickName];
        }else {
            label.text = [NSString stringWithFormat:@"%@:%@",labelArray[i-1],labelValue[i-1]];
        }
    }
    
    //设置声音长度
//    int voiceTime = [_lonelyUser.voiceDurion intValue];
    float time = [EMUtil getAudioSecWithURL:_lonelyUser.voice];
//    if (time < voiceTime) {
//        time = voiceTime;
//    }
    _audioPlayerView.allTime = time;
}

//判断这个用户是否是自己关注的和这则广播是否被收藏
- (void)getBasicInfo:(NSString*)recordId andUserId:(NSString*)userId {
    
    
    
    [UIUtil showHUD:self.navigationController.view];
    //获取该广播的基本信息
    //    [_mainViewVM getRecordInfo:_boardcastObj.recordId andBlock:^(NSDictionary *dict, BOOL ret) {
    //        [UIUtil hideHUD:self.navigationController.view];
    //        if (dict && ret) {
    //            if ([dict[@"code"] intValue] == 1) {
    //                _boardcastObjDetail = nil;
    //                _boardcastObjDetail = [[BoardcastObj alloc] initWithJSONDict:dict[@"data"]];
    //                if (_boardcastObjDetail.favoriteTime && _boardcastObjDetail.favoriteTime.length > 0) {
    //                    _careBtn.selected = YES;
    //                }else {
    //                    _careBtn.selected = NO;
    //                }
    //                if (_boardcastObjDetail.blockTime && _boardcastObjDetail.blockTime.length > 0) {
    //                    _lockBtn.selected = YES;
    //                }else {
    //                    _lockBtn.selected = NO;
    //                }
    //            }
    //        }
    //    }];
}

//显示检举的view
- (void)showReportAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 1;
        CGFloat height = 209*kScale;
        CGFloat y = (kScreenH - height)/2.f-100;
        _reportView.frame = Rect(15*kScale, y, kScreenW-30*kScale, height);
        _reportLabel.alpha = 1;
        _reportTextView.alpha = 1;
        _cancelReportBtn.alpha = 1;
        _sendReportBtn.alpha = 1;
        
    } completion:NULL];
}

//隐藏检举
- (void)hiddenMask:(EMButton*)btn {
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
    if (![UIUtil checkLogin]) {
        return;
    }
    btn.selected = !btn.selected;
    WS(weakSelf);
    if (btn.selected) {
        //收藏
        [UIUtil showHUD:self.navigationController.view];
        [_mainViewVM careActionWithOtherId:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
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
        [_mainViewVM deleteCareActionWithOtherId:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
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
    if (![UIUtil checkLogin]) {
        return;
    }
    btn.selected = !btn.selected;
    WS(weakSelf);
    
    if (btn.selected) {
        //关注
        if ([UIUtil alertProfileWarning:self andMsg:Local(@"YOUMUSTCOMPLETEINFO")]) {
            btn.selected = !btn.selected;
            return;
        }
        
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
- (void)back:(id)sender {
    [_audioPlayerView stopRemoteAudio];
    if (_listestenTime > 5 ||(_lonelyUser.seenTime && _lonelyUser.seenTime.length > 0)) {
        if (_delegate && [_delegate respondsToSelector:@selector(shouldReload:)]) {
            [_delegate shouldReload:_lonelyUser];
        }
    }
    [super back:sender];
    
}

- (void)initView {
    backView = [[UIScrollView alloc] initWithFrame:Rect(0, 0, kScreenW, kScreenH)];
    
    //可滑动的图片
    _imgScrollView = [[UIScrollView alloc] initWithFrame:Rect(0, 20, kScreenW, 280*kScale)];
    _imgScrollView.bounces = NO;
    _imgScrollView.pagingEnabled = YES;
    _imgScrollView.delegate = self;
    [backView addSubview:_imgScrollView];
    
    
    _imgPageControl = [[UIPageControl alloc] initWithFrame:Rect(kScreenW - 110 - 12*kScale - 19 - 100, 32*kScale, 100, 21*kScale)];
    _imgPageControl.currentPageIndicatorTintColor = RGB(145,90,173);
    [backView addSubview:_imgPageControl];
    
    
    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 90 - 12*kScale, 32*kScale, 90, 21*kScale)];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = RGB(0xff, 0xff, 0xff);
    _timeLabel.backgroundColor = RGB(145,90,173);
    _timeLabel.font = ComFont(11*kScale);
    _timeLabel.layer.cornerRadius = 10*kScale;
    _timeLabel.layer.masksToBounds = YES;
    _timeLabel.text = [EMUtil getTimeToNow:_lonelyUser.lastOnlineTime];
    [backView addSubview:_timeLabel];
    
    
    _btnScrollView = [[UIScrollView alloc] init];
    _btnScrollView.bounces = NO;
    
    CGFloat x = 26*kScale;
    CGFloat width = 43 *kScale;
    CGFloat space = (kScreenW - 2 * x - 5 * width) / 4.f;
    
    _playBtn = [[EMButton alloc] initWithFrame:Rect(x,0, width, width) isRdius:YES];
    [_playBtn setImage:[UIImage imageNamed:@"PEme"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"enjoyStop"] forState:UIControlStateSelected];
    [_playBtn setImage:[UIImage imageNamed:@"PEmeOff"] forState:UIControlStateDisabled];
    
    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _btnScrollView.frame = Rect(0, 20 + 234 * kScale, kScreenW, width+25*kScale);
    [_btnScrollView addSubview:_playBtn];
    [_btnScrollView setContentSize:Size(kScreenW*2, 0)];
    [_btnScrollView setPagingEnabled:YES];
    
    [backView addSubview:_btnScrollView];
    
    _stationBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_playBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_stationBtn setImage:[UIImage imageNamed:@"PEbroadcast"] forState:UIControlStateNormal];
    [_stationBtn addTarget:self action:@selector(stationAction:) forControlEvents:UIControlEventTouchUpInside];
    [_stationBtn setImage:[UIImage imageNamed:@"PEbroadcast_off"] forState:UIControlStateDisabled];
    
    [_btnScrollView addSubview:_stationBtn];
    
    
    _callBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_stationBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_callBtn setImage:[UIImage imageNamed:@"PEcall_free"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"PEcall_pay"] forState:UIControlStateSelected];
    [_callBtn setImage:[UIImage imageNamed:@"PEcall_off"] forState:UIControlStateDisabled];
    
    [_callBtn addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScrollView addSubview:_callBtn];
    
    
    _chatBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_callBtn) + space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_chatBtn setImage:[UIImage imageNamed:@"PEchat"] forState:UIControlStateNormal];
    [_chatBtn setImage:[UIImage imageNamed:@"PEchat_pay"] forState:UIControlStateSelected];
    [_chatBtn addTarget:self action:@selector(chatAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScrollView addSubview:_chatBtn];
    
    
    _rightBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_chatBtn)+space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_rightBtn setImage:[UIImage imageNamed:@"SBTright"] forState:UIControlStateNormal];
    [_rightBtn setImage:[UIImage imageNamed:@"SBTright_d"] forState:UIControlStateHighlighted];
    [_rightBtn setImage:[UIImage imageNamed:@"SBTright_d"] forState:UIControlStateSelected];
    
    [_rightBtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScrollView addSubview:_rightBtn];
    
    _leftBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW + x, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_leftBtn setImage:[UIImage imageNamed:@"SBTleft"] forState:UIControlStateNormal];
    [_leftBtn setImage:[UIImage imageNamed:@"SBTleft_d"] forState:UIControlStateHighlighted];
    [_leftBtn setImage:[UIImage imageNamed:@"SBTleft_d"] forState:UIControlStateSelected];
    [_leftBtn addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScrollView addSubview:_leftBtn];
    
//    space = (kScreenW - 10 - 5 * width)/5.f;
  
    
    _sendGift = [[EMButton alloc] initWithFrame:Rect(PositionX(_leftBtn) + space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_sendGift setImage:[UIImage imageNamed:@"PEgift"] forState:UIControlStateNormal];
    [_sendGift addTarget:self action:@selector(sendGiftAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScrollView addSubview:_sendGift];
    
    
    _careBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_sendGift) + space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_careBtn setImage:[UIImage imageNamed:@"PEheart_add"] forState:UIControlStateNormal];
    [_careBtn setImage:[UIImage imageNamed:@"PEheart_added"] forState:UIControlStateHighlighted];
    [_careBtn setImage:[UIImage imageNamed:@"PEheart_added"] forState:UIControlStateSelected];
    [_careBtn addTarget:self action:@selector(careAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScrollView addSubview:_careBtn];
    
    _reportBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_careBtn) + space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_reportBtn setImage:[UIImage imageNamed:@"enjoyReport"] forState:UIControlStateNormal];
    [_reportBtn setImage:[UIImage imageNamed:@"enjoyReport"] forState:UIControlStateHighlighted];
    [_reportBtn setImage:[UIImage imageNamed:@"enjoyReport"] forState:UIControlStateSelected];
    [_reportBtn addTarget:self action:@selector(showReportAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScrollView addSubview:_reportBtn];
    
    _lockBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_reportBtn) + space, _playBtn.frame.origin.y, width, width) isRdius:YES];
    [_lockBtn setImage:[UIImage imageNamed:@"PEblockade"] forState:UIControlStateNormal];
    [_lockBtn setImage:[UIImage imageNamed:@"PEblockade"] forState:UIControlStateHighlighted];
    [_lockBtn setImage:[UIImage imageNamed:@"PEblockade"] forState:UIControlStateSelected];
    [_lockBtn addTarget:self action:@selector(lockAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnScrollView addSubview:_lockBtn];
    
    EMView *lableBack = [[EMView alloc] initWithFrame:Rect(0, PositionY(_playBtn)+3*kScale, kScreenW*2, 21*kScale)];
    lableBack.backgroundColor = RGB(145,90,173);
    [_btnScrollView addSubview:lableBack];
    
    _playLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_playBtn)+3*kScale, 42*kScale, 21*kScale)];
    _playLabel.textAlignment = NSTextAlignmentCenter;
    _playLabel.textColor = RGB(0xff, 0xff, 0xff);
    _playLabel.font = ComFont(11*kScale);
    _playLabel.text = Local(@"ListenMe");
    [_btnScrollView addSubview:_playLabel];
    
    _stationLabel = [[EMLabel alloc] initWithFrame:Rect(_stationBtn.frame.origin.x, PositionY(_stationBtn)+3*kScale, 42*kScale, 21*kScale)];
    _stationLabel.textAlignment = NSTextAlignmentCenter;
    _stationLabel.text = Local(@"Station");
    _stationLabel.textColor = RGB(0xff, 0xff, 0xff);
    _stationLabel.font = ComFont(11*kScale);
    [_btnScrollView addSubview:_stationLabel];
    
    _callLabel = [[EMLabel alloc] initWithFrame:Rect(_callBtn.frame.origin.x, PositionY(_callBtn)+3*kScale, 42*kScale, 21*kScale)];
    _callLabel.textAlignment = NSTextAlignmentCenter;
    _callLabel.text = Local(@"Call");
    _callLabel.textColor = RGB(0xff, 0xff, 0xff);
    _callLabel.font = ComFont(11*kScale);
    [_btnScrollView addSubview:_callLabel];
    
    
    _chatLabel = [[EMLabel alloc] initWithFrame:Rect(_chatBtn.frame.origin.x, PositionY(_chatBtn)+3*kScale, 42*kScale, 21*kScale)];
    _chatLabel.textAlignment = NSTextAlignmentCenter;
    _chatLabel.text = Local(@"Chat");
    _chatLabel.textColor = RGB(0xff, 0xff, 0xff);
    _chatLabel.font = ComFont(11*kScale);
    [_btnScrollView addSubview:_chatLabel];
    
    
    _sendGiftLabel = [[EMLabel alloc] initWithFrame:Rect(_sendGift.frame.origin.x, PositionY(_sendGift)+3*kScale, 42*kScale, 21*kScale)];
    _sendGiftLabel.textAlignment = NSTextAlignmentCenter;
    _sendGiftLabel.text = Local(@"SendGift");
    _sendGiftLabel.textColor = RGB(0xff, 0xff, 0xff);
    _sendGiftLabel.font = ComFont(11*kScale);
    [_btnScrollView addSubview:_sendGiftLabel];
    
    _careLabel = [[EMLabel alloc] initWithFrame:Rect(_careBtn.frame.origin.x, PositionY(_careBtn)+3*kScale, 42*kScale, 21*kScale)];
    _careLabel.textAlignment = NSTextAlignmentCenter;
    _careLabel.text = Local(@"Care");
    _careLabel.textColor = RGB(0xff, 0xff, 0xff);
    _careLabel.font = ComFont(11*kScale);
    [_btnScrollView addSubview:_careLabel];
    
    _reportLabel = [[EMLabel alloc] initWithFrame:Rect(_reportBtn.frame.origin.x, PositionY(_reportBtn)+3*kScale, 42*kScale, 21*kScale)];
    _reportLabel.textAlignment = NSTextAlignmentCenter;
    _reportLabel.text = Local(@"Report");
    _reportLabel.textColor = RGB(0xff, 0xff, 0xff);
    _reportLabel.font = ComFont(11*kScale);
    [_btnScrollView addSubview:_reportLabel];
    
    _lockLabel = [[EMLabel alloc] initWithFrame:Rect(_lockBtn.frame.origin.x, PositionY(_lockBtn)+3*kScale, 42*kScale, 21*kScale)];
    _lockLabel.textAlignment = NSTextAlignmentCenter;
    _lockLabel.text = Local(@"Lock");
    _lockLabel.textColor = RGB(0xff, 0xff, 0xff);
    _lockLabel.font = ComFont(11*kScale);
    [_btnScrollView addSubview:_lockLabel];
    
    _audioPlayerView = [[AudioRemotePlayView alloc] initWithFrame:Rect(26*kScale, PositionY(_btnScrollView), kScreenW - 52*kScale, 52 * kScale)];
    WS(weakSelf);
    _audioPlayerView.audioBok = ^(float currentTime,float allTime,BOOL isStop){
        if (isStop) {
            [weakSelf.playBtn setSelected:NO];
            
        }else {
            [weakSelf.playBtn setSelected:YES];
        }
        weakSelf.listestenTime++;
        if(currentTime > 4.5 || isStop) {
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
    
    [backView addSubview:_audioPlayerView];
    int voiceTime = [_lonelyUser.voiceDurion intValue];
    _audioPlayerView.allTime = voiceTime;
    _audioPlayerView.isShowLabel = YES;
    [self.view addSubview:backView];
    
    
    //检举区域
    _maskBtnView = [[EMButton alloc] initWithFrame:Rect(0, 0, ScreenWidth, ScreenHeight)];
    _maskBtnView.alpha = 0;
    _maskBtnView.backgroundColor = RGBA(0, 0, 0,0.6);
    [_maskBtnView addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_maskBtnView];
    
    CGFloat height = 169*kScale;
    CGFloat y = (kScreenH - height)/2.f-20;
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
    
    
    //送礼区域
    _maskGiftBtnView = [[EMButton alloc] initWithFrame:Rect(0, 0, ScreenWidth, ScreenHeight)];
    _maskGiftBtnView.alpha = 0;
    _maskGiftBtnView.backgroundColor = RGBA(0, 0, 0,0.6);
    [_maskGiftBtnView addTarget:self action:@selector(hiddenGiftMask:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_maskGiftBtnView];
    
    height = 239*kScale;
    y = (kScreenH - height)/2.f;
    _sendView = [[EMView alloc] initWithFrame:Rect(15*kScale, y, kScreenW-30*kScale, height)];
    _sendView.layer.backgroundColor = RGB(0xff, 0xff, 0xff).CGColor;
    _sendView.layer.cornerRadius = 10;
    [_maskGiftBtnView addSubview:_sendView];
    
    width = 91;
    height = 91;
    x = (kScreenW-30*kScale - width)/2.f;
    y = 52*kScale;
    UIImageView *giftImgView = [[UIImageView alloc] initWithFrame:Rect(x, y, width, height)];
    giftImgView.image = [UIImage imageNamed:@"paste_littlemind_l"];
    [_sendView addSubview:giftImgView];
    
    EMLabel *giftLabel = [[EMLabel alloc] initWithFrame:Rect(60*kScale, PositionY(giftImgView)+15*kScale, kScreenW-150*kScale, 17*kScale)];
    giftLabel.font = ComFont(16*kScale);
    giftLabel.textColor = RGB(239,162,249);
    giftLabel.text = Local(@"WillSend3Min");
    giftLabel.textAlignment = NSTextAlignmentCenter;
    [_sendView addSubview:giftLabel];
    
    width = 92*kScale;
    height = 35*kScale;
    x = (kScreenW-30*kScale - width)/2.f;
    y = PositionY(giftLabel)+ 26*kScale;
    EMButton *sendBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, height) andConners:5];
    sendBtn.borderColor = RGB(0,0,0);
    sendBtn.borderWidth = 1;
    [sendBtn setTitle:Local(@"SendMin") forState:UIControlStateNormal];
    [sendBtn setTitleColor:RGB(0xff,0xff,0xff) forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:RGB(145,90,173)];

    [sendBtn addTarget:self action:@selector(sendGift:) forControlEvents:UIControlEventTouchUpInside];
    [_sendView addSubview:sendBtn];
    
    EMButton *closeBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 40*kScale - 20, 6*kScale, 25*kScale, 25*kScale)];
    
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"close_d"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(hiddenGiftMask:) forControlEvents:UIControlEventTouchUpInside];
    [_sendView addSubview:closeBtn];
    
    //基本信息栏
    NSArray *labelArray = @[Local(@"Age"), Local(@"Country"),Local(@"City"),Local(@"Height"),Local(@"Weight"),Local(@"Job"),Local(@"Slogan")];
    
    NSString *age = _lonelyUser.age != nil?_lonelyUser.age :@"";
    NSString *country = _lonelyUser.country != nil?_lonelyUser.country :@"";
    NSString *city = _lonelyUser.city != nil?_lonelyUser.city :@"";
    NSString *aHeight = _lonelyUser.height != nil?_lonelyUser.height :@"";
    NSString *type = _lonelyUser.type != nil?_lonelyUser.type :@"";
    NSString *job = _lonelyUser.job != nil?_lonelyUser.job :@"";
    NSString *slogan = _lonelyUser.slogan != nil?_lonelyUser.slogan :@"";
    
    
    NSArray *labelValue = @[[NSString stringWithFormat:@"%@%@", age,Local(@"Year")],country,city,aHeight,type,job,slogan];
    
    NSArray *imgArray = @[[UIImage imageNamed:@"icon_user_lover"],[UIImage imageNamed:@"PERyear"],[UIImage imageNamed:@"PERcountry"],[UIImage imageNamed:@"PERcity"],[UIImage imageNamed:@"PERheight"],[UIImage imageNamed:@"PERtype"],[UIImage imageNamed:@"PERjob"],[UIImage imageNamed:@"PERmood"]];
    y = PositionY(_audioPlayerView) + 18*kScale;
    for (int i = 0; i<imgArray.count; i++) {
        UIImage *image = imgArray[i];
        UIImageView *labelImageView = [[UIImageView alloc] initWithFrame:Rect(15*kScale, y, image.size.width, image.size.height)];
        [backView addSubview:labelImageView];
        labelImageView.image = imgArray[i];
        
        EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(52*kScale, y,200*kScale, 25*kScale)];
        label.textColor = RGB(51, 51, 51);
        label.font = ComFont(13);
        [backView addSubview:label];
        label.tag = 1000+i;
        if (i == 0) {
            CGRect frame = labelImageView.frame;
            frame.origin.x -= 5;
            frame.origin.y -= 5;
            labelImageView.frame = frame;
            label.text = [NSString stringWithFormat:@"%@:%@",_lonelyUser.identityName,_lonelyUser.nickName];
        }else {
            label.text = [NSString stringWithFormat:@"%@:%@",labelArray[i-1],labelValue[i-1]];
        }
        
        y += 18 * kScale + 25*kScale;
        
        
    }
    
    backView.contentSize = Size(0, y);
}


- (void)lockAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    if (btn.selected) {
        [self.view makeToast:Local(@"AlreadyLocked") duration:1 position:[CSToastManager defaultPosition]];
        return;
    }
    [UIUtil showHUD:self.navigationController.view];
    [_mainViewVM addlock:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.navigationController.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                [self.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                btn.selected = YES;
            }else {
                [self.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
                btn.selected = NO;
                
            }
        }else {
            [self.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
            btn.selected = NO;
            
        }
    }];
    
}

//显示送礼
- (void)sendGiftAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskGiftBtnView.alpha = 1;
        CGFloat height = 239*kScale;
        CGFloat y = (kScreenH - height)/2.f;
        _sendView.frame = Rect(15*kScale, y, kScreenW-30*kScale, height);
        
        
    } completion:NULL];
}


- (void)chatAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    LonelyStationUser *lonelyUser = _lonelyUser;
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.gender isEqualToString:@"M"]) {
        //做判断，1.如果对方是收费，自己有秒数，弹提示1
        //2.如果聊天卡用完，弹购买提示
        //3.如果对方免费，谈提示无限畅聊卡，如果有聊天卡，使用聊天卡
        //4.如果无限畅聊卡都没有，谈提示
        WS(weakSelf)
        [EMUtil chatWithUser:lonelyUser andFirstBlock:^{
            SS(weakSelf, strongSelf);
            [EMUtil pushToChat:lonelyUser andViewController:strongSelf];
        } andSecondBlock:^{
            SS(weakSelf, strongSelf);
            AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
            [strongSelf.navigationController pushViewController:addMoneyMainVC animated:YES];
        }];
    }else {
        [EMUtil pushToChat:lonelyUser andViewController:self];
    }
    
}



- (void)leftAction:(EMButton*)btn {
    [_btnScrollView setContentOffset:Point(0, 0) animated:YES];
}


- (void)rightAction:(EMButton*)btn {
    [_btnScrollView setContentOffset:Point(kScreenW, 0) animated:YES];
}

- (void)callAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    [EMUtil chatCallUser:_lonelyUser andController:self];
}

- (void)setBoardcastValue {
    //    if (_boardcastObj) {
    //        _collectLabel.text = [NSString stringWithFormat:@"%@:%@",_boardcastObj.category,_boardcastObj.title];
    //        _timeLabel.text = [EMUtil getTimeToNow:_boardcastObj.updateTime];
    //        _titleLabel.text = _boardcastObj.title;
    //        _audioPlayerView.allTime = [_boardcastObj.duration intValue];
    //    }
}



//- (void)setBoardcastObj:(BoardcastObj *)boardcastObj {
//    _boardcastObj = nil;
//    _boardcastObj = boardcastObj;
//    [self setBoardcastValue];
//}


- (void)backHomeAction:(EMButton*)btn {
    
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"MainViewController"]) {
            MainViewController *main = self.navigationController.viewControllers[i];
            [main shouldLoadData];
            break;
        }
    }
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LeftSlideViewController"]) {
            LeftSlideViewController *mainVC = self.navigationController.viewControllers[i];
            [self.navigationController popToViewController:mainVC animated:YES];
            break;
        }
    }
}

- (void)rateAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    btn.selected = !btn.selected;
    _rateTableView.hidden = btn.selected;
}


- (void)stationAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
//    PersonalStationVC *personalStation = [[PersonalStationVC alloc] init];
//    personalStation.currentStionUser = _lonelyUser;
    PersonalStationNewVC *personalStation = [[PersonalStationNewVC alloc] init];
    personalStation.lonelyUser = _lonelyUser;
    [self.navigationController pushViewController:personalStation animated:YES];
}


- (void)playAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    btn.selected = !btn.selected;
    if (btn.selected) {
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        if (user.voice == nil || [user.voice isEqualToString:@""]) {
            btn.selected = NO;
            AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"TheyIntroduceThem") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                if (!cancelled) {
                    RecordIntroduceVC *recordIntVC = [[RecordIntroduceVC alloc] init];
                    recordIntVC.seq = 1;
                    [self.navigationController pushViewController:recordIntVC animated:YES];
                }
            } cancelButtonTitle:Local(@"NextTime") otherButtonTitles:Local(@"GoToRecord"), nil];
            [alert show];
            alert = nil;
        }else {
            WS(weakSelf)
            if (_lonelyUser.voice && _lonelyUser.voice.length > 0) {
//                int voiceTime = [_lonelyUser.voiceDurion intValue];
                float time = [EMUtil getAudioSecWithURL:_lonelyUser.voice];
//                if (time < voiceTime) {
//                    time = voiceTime;
//                }
                _audioPlayerView.allTime = time;
                [_audioPlayerView playRemoteAudio:_lonelyUser.voice];
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] setSpeakerEnabled:YES];
                if (isFirstIn == NO) {
                    isFirstIn = YES;
                    [_mainViewVM getRecordEvenSeen:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
                        weakSelf.lonelyUser.seenTime = [EMUtil GetCurrentTime];
                        [weakSelf updateInfo];
                    }];
                }
            }else {
                btn.selected = NO;
                [self.navigationController.view makeToast:Local(@"ThereisNoAiring") duration:1 position:[CSToastManager defaultPosition]];
            }
        }
    }else {
        [_audioPlayerView stopRemoteAudio];
    }
}


- (void)sendGift:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    NSString *userId = _lonelyUser.userID;
    //判断是否有6分钟以上的时间先
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if (user.chat_point.intValue >= 360){
        [UIUtil showHUD:[[UIApplication sharedApplication] keyWindow]];
        [_callViewVM sendGift:userId andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:[[UIApplication sharedApplication] keyWindow]];
            if (dict && ret) {
                DLog(@"dict==%@",dict);
                if ([dict[@"code"] intValue] == 1) {
                    [self hiddenMask:nil];
                    //成功了
                    user.chat_point = [NSString stringWithFormat:@"%d",[user.chat_point intValue] - 180];
                    [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                    [self.view makeToast:Local(@"HandleSuccess") duration:3 position:[CSToastManager defaultPosition]];
                    
                }else {
                    [_maskGiftBtnView makeToast:Local(@"HandleFailed") duration:3 position:[CSToastManager defaultPosition]];
                }
            }else{
                [_maskGiftBtnView makeToast:Local(@"HandleFailed") duration:3 position:[CSToastManager defaultPosition]];
            }
        }];
    }else {
        [_maskGiftBtnView makeToast:Local(@"MinNotEnough") duration:3 position:[CSToastManager defaultPosition]];
    }
    
}

//隐藏送礼
- (void)hiddenGiftMask:(EMButton*)btn {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskGiftBtnView.alpha = 0;
        CGRect frame = _maskGiftBtnView.frame;
        _sendView.frame = Rect(frame.size.width/2, frame.size.height/2, 0, 0);
    } completion:NULL];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    RateCell *cell = (RateCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[RateCell alloc] initWithSize:Size(kScreenW, 60*kScale) reuseIdentifier:cellIdentifier];
        
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
    return 60*kScale;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    EMView *view = [[EMView alloc] initWithFrame:Rect(0, 0, kScreenW, 60*kScale)];
    UICycleImgView *imgView = [[UICycleImgView alloc] initWithFrame:Rect(11*kScale, 7*kScale, 42*kScale, 42*kScale)];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [imgView yy_setImageWithURL:[NSURL URLWithString:user.file] placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:user.gender]]];
    [view addSubview:imgView];
    
    CGFloat x = PositionX(imgView)+20*kScale;
    CGFloat width = kScreenW - x - 11 - 28*kScale;
    if (!_commentTextView) {
        _commentTextView = [[EMTextView alloc] initWithFrame:Rect(x, 5, width, 60*kScale - 10)];
        _commentTextView.text = Local(@"IWantRate");
    }
    _commentTextView.frame = Rect(x, 11*kScale, width, 60*kScale - 22*kScale);
    _commentTextView.textColor = RGB(68,68,68);
    _commentTextView.font = ComFont(11);
    _commentTextView.delegate = self;
    [view addSubview:_commentTextView];
    
    EMButton *btn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 11 - 28*kScale, 18*kScale, 28*kScale, 23*kScale)];
    [btn setImage:[UIImage imageNamed:@"enjoy_send"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sendRate:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    view.backgroundColor = RGB(0xff, 0xff, 0xff);
    return view;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60*kScale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//发送留言
- (void)sendRate:(EMButton*)btn {
    if (_commentTextView.text.length >= 3 && _commentTextView.text.length <= 100) {
        //        [_mainViewVM sendRate:_boardcastObj.recordId andComment:_commentTextView.text andBlock:^(NSDictionary *dict, BOOL ret) {
        //            if (dict && ret) {
        //                if ([dict[@"code"] intValue] == 1) {
        //                    [self.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
        //                    [self getBasicInfo:_boardcastObj.recordId andUserId:_lonelyUser.userID];
        //                }else {
        //                    [self.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
        //
        //                }
        //            }else {
        //                [self.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
        //            }
        //        }];
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

