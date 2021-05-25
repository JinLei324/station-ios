//
//  SignalRecordShowVC.m
//  LonelyStation
//  个人电台页
//  Created by zk on 16/8/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "PersonalDetailInfoVC.h"
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
#import "MainDynamicCell.h"
#import "BoardcastObj.h"
#import "PersonalStationDetailVC.h"

@interface PersonalDetailInfoVC ()<UITextViewDelegate,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource> {
    AudioRemotePlayView *_audioPlayerView;
    RecordAiringVM *_recordAiringVM;
    
    EMButton *_maskBtnView;
    EMLabel *_reportLabel;
    EMView *_reportView;
    UITextView *_reportTextView;
    EMButton *_cancelReportBtn;
    EMButton *_sendReportBtn;
    
    EMButton *_careStationBtn;
    
    NSMutableArray *_dataArray;
    EMTextView *_commentTextView;
    
    BoardcastObj *_boardcastObjDetail;
    EMLabel *_titleLabel;
    CallViewVM *_callViewVM;
    
    EMView *backView;
    NSMutableArray *_productArray;

    
    BOOL isFirstIn;
    int _cnt;
    int _from;
}

@property (nonatomic,assign)int listestenTime;
@property (nonatomic,strong) MainViewVM *mainViewVM;
@property (nonatomic,strong)UIScrollView *imgScrollView;

@property (nonatomic,strong)UIPageControl *imgPageControl;

@property (nonatomic,strong)EMLabel *nameLabel;

@property (nonatomic,strong)EMLabel *collectLabel;

@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)EMLabel *fansLabel;

@property (nonatomic,strong)EMLabel *playNumLabel;

@property (nonatomic,strong)EMButton *leftButton;

@property (nonatomic,strong)EMView *lineViewBottom;

@property (nonatomic,strong)EMView *lineView;

@property (nonatomic,strong)EMButton *rightButton;

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


@property (nonatomic,strong)UIScrollView *bottomScrollView;

@property (nonatomic,strong)UIScrollView *bottomLeftView;

@property (nonatomic,strong)UICollectionView *bottomrightCollectionView;

@property (nonatomic,strong)EMLabel *nameWall;

@property (nonatomic,assign)BOOL isLastPage;

//检举
//@property (nonatomic,strong)EMButton *reportBtn;

//关注
//@property (nonatomic,strong)EMButton *careBtn;

@end

@implementation PersonalDetailInfoVC


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isFirstIn = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.viewNaviBar setHidden:YES];
    [self initView];
    
    _callViewVM = [[CallViewVM alloc] init];
    
    _dataArray = [NSMutableArray array];
    _productArray = [NSMutableArray array];
    
    _recordAiringVM = [[RecordAiringVM alloc] init];
    
    _mainViewVM = [[MainViewVM alloc] init];
    
    [_bottomrightCollectionView registerClass:[MainDynamicCell class] forCellWithReuseIdentifier:@"MainDynamicCell"];
    
    
    // Do any additional setup after loading the view.
    [self loadData:YES];
    
    
    if (_shouldPlay) {
        [self playAction:_playBtn];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _bottomScrollView) {
        int page = scrollView.contentOffsetX / kScreenW;
        if (page == 0) {
            [self buttonAction:_leftBtn];
        }else {
            [self buttonAction:_rightBtn];
        }
    }
//    _imgPageControl.currentPage = page;
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
    WS(weakSelf)
    [_mainViewVM getPersonalInfo:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
        SS(weakSelf, strongSelf)
        if (showHUD) {
            [UIUtil hideHUD:strongSelf.view];
        }
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                _lonelyUser = nil;
                _lonelyUser = [[LonelyStationUser alloc] initWithDictory:dict[@"data"]];
                DLog(@"_lonelyUser.city==%@",_lonelyUser.city);
                [strongSelf updateInfo];
                [strongSelf loadProductData:YES];
            }
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
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    //把照片放上去
    if (imgArray && imgArray.count > 0) {
        [_imgScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (int i = 0; i < imgArray.count; i++) {
            NSString *str = imgArray[i];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(kScreenW*i, 0, kScreenW, _imgScrollView.frame.size.height)];
            
            [imgView yy_setImageWithURL:[NSURL URLWithString:str] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgNameUseSelfGender:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                //最新版把模糊先去掉
//                if (_lonelyUser.seenTime.length > 0){
                    [imgView yy_setImageWithURL:[NSURL URLWithString:str] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyUser.gender]]];
//                }else{
//                    imgView.image = [imgView.image blurredImage:0.3];
//                }
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
//        _imgScrollView.contentSize = Size(kScreenW*count, 0);
        _imgScrollView.contentSize = Size(0, 0);
        _imgPageControl.numberOfPages = count;
        _imgPageControl.currentPage = 0;
        _imgPageControl.hidden = NO;
//        [_imgScrollView setScrollEnabled:YES];
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
                [_callBtn setImage:[UIImage imageNamed:@"enjoy_call_pay"] forState:UIControlStateNormal];
            }else {
                [_callBtn setImage:[UIImage imageNamed:@"enjoy_call_d"] forState:UIControlStateNormal];
            }
        }else {
            [_callBtn setEnabled:NO];
        }
    }else{
        [_callBtn setEnabled:NO];
    }
    

    //如果msgCharge为Y,设置为红色
    if([@"Y" isEqualToString:_lonelyUser.msgCharge]) {
        [_chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_pay"] forState:UIControlStateNormal];
    }else {
        [_chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_d"] forState:UIControlStateNormal];
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
    
    _stationLabel.text = _lonelyUser.nickName;
    _fansLabel.text = _lonelyUser.favorite_num;
    _playNumLabel.text = _lonelyUser.seen_num;
    
    NSArray *labelArray = @[Local(@"Age"), Local(@"Country"),Local(@"City"),Local(@"Height"),Local(@"Slogan")];
    NSArray *labelValue = @[[NSString stringWithFormat:@"%@%@",_lonelyUser.age,Local(@"Year")],_lonelyUser.country,_lonelyUser.city,_lonelyUser.height,_lonelyUser.slogan];
    for (int i = 0; i < labelValue.count+1; i++) {
        UILabel *label = [backView viewWithTag:1000+i];
        if (i == 0) {
            label.text = [NSString stringWithFormat:@"%@:%@",_lonelyUser.identityName,_lonelyUser.nickName];
        }else {
            label.text = [NSString stringWithFormat:@"%@:%@",labelArray[i-1],labelValue[i-1]];
        }
    }
    CGFloat y = CGRectGetMaxY(_nameWall.frame) + 20*kScale;
    for (int i = 0 ; i < _lonelyUser.tagArray.count; i++) {
        UIImageView *imageLeft = [_bottomLeftView viewWithTag:2000+i];
        if (!imageLeft) {
            imageLeft = [[UIImageView alloc] initWithFrame:Rect(22*kScale, y, 25*kScale, 25*kScale)];
        }
        [_bottomLeftView addSubview:imageLeft];
        imageLeft.image = [UIImage imageNamed:@"medal_multicolor"];
        imageLeft.tag = 2000 + i;
        
        EMLabel *label = [_bottomLeftView viewWithTag:3000+i];
        if (!label) {
            label = [[EMLabel alloc] initWithFrame:Rect(CGRectGetMaxX(imageLeft.frame)+17*kScale, y, kScreenW - CGRectGetMaxX(imageLeft.frame), 25*kScale)];
        }
        [_bottomLeftView addSubview:label];

        NSDictionary *dict = _lonelyUser.tagArray[i];
        label.tag = 3000 + i;
        label.text = dict[@"name"];
        label.font = ComFont(14*kScale);
        label.textColor = RGB(51, 51, 51);
        y += 25*kScale + 12*kScale;

    }
    
    _bottomLeftView.contentSize = Size(0, y);
    //设置声音长度
    _audioPlayerView.allTime = [_lonelyUser.voiceDurion intValue];

}

//判断这个用户是否是自己关注的和这则广播是否被收藏
- (void)getBasicInfo:(NSString*)recordId andUserId:(NSString*)userId {
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
        _reportView.frame = Rect(0, y, kScreenW, height);
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
    //注释掉
//    if (_listestenTime > 5 ||(_lonelyUser.seenTime && _lonelyUser.seenTime.length > 0)) {
//        if (_delegate && [_delegate respondsToSelector:@selector(shouldReload:)]) {
//            [_delegate shouldReload:_lonelyUser];
//        }
//    }
    [super back:sender];
}

- (void)initView {
    backView = [EMView new];
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.left.and.right.mas_equalTo(0);
    }];
    
    
    //可滑动的图片
    _imgScrollView = [[UIScrollView alloc] initWithFrame:Rect(0, -20, kScreenW, 218*kScale)];
    if (IsIPhoneX) {
        _imgScrollView.frame = Rect(0, 0, kScreenW, 218*kScale);
    }
    
    _imgScrollView.bounces = NO;
    _imgScrollView.delegate = self;
    [backView addSubview:_imgScrollView];
    
    EMView *basicView = [EMView new];
    [backView addSubview:basicView];
    [basicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        if (IsIPhoneX) {
            make.top.mas_equalTo(218*kScale);
        }else{
            make.top.mas_equalTo(218*kScale-20);
        }
        make.height.mas_equalTo(74*kScale);
    }];
    [basicView setBackgroundColor:[UIColor clearColor]];
    EMLabel *stationNameLabel = [EMUtil createLabelWithFont:ComFont(15*kScale) andColor:RGB(51, 51, 51)];
    [basicView addSubview:stationNameLabel];
    [stationNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(basicView.mas_top).offset(16*kScale);
        make.left.mas_equalTo(20*kScale);
        make.height.mas_greaterThanOrEqualTo(16*kScale);
    }];
    stationNameLabel.text =  [NSString stringWithFormat:@"%@:",Local(@"StationName")];
    //电台名称
    _stationLabel = [EMUtil createLabelWithFont:ComFont(15*kScale) andColor:RGB(51, 51, 51)];
    [basicView addSubview:_stationLabel];
    [_stationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stationNameLabel.mas_top);
        make.left.equalTo(stationNameLabel.mas_right).offset(2);
        make.height.mas_greaterThanOrEqualTo(16*kScale);
    }];

    EMLabel *fansNameLabel = [EMUtil createLabelWithFont:ComFont(12*kScale) andColor:RGB(51, 51, 51)];
    [basicView addSubview:fansNameLabel];
    [fansNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stationNameLabel.mas_bottom).offset(11*kScale);
        make.left.equalTo(stationNameLabel.mas_left);
        make.height.mas_greaterThanOrEqualTo(12*kScale);
    }];
    fansNameLabel.text = [NSString stringWithFormat:@"%@:",Local(@"Fans")];
    
    //粉丝数量
    _fansLabel = [EMUtil createLabelWithFont:ComFont(12*kScale) andColor:RGB(51, 51, 51)];
    [basicView addSubview:_fansLabel];
    [_fansLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stationNameLabel.mas_bottom).offset(11*kScale);
        make.left.equalTo(fansNameLabel.mas_right).offset(2);
        make.height.mas_greaterThanOrEqualTo(12*kScale);
        make.width.mas_greaterThanOrEqualTo(20*kScale);
    }];
    _fansLabel.text = @"0";
    //播放量标签
    EMLabel *playNameLabel = [EMUtil createLabelWithFont:ComFont(12*kScale) andColor:RGB(51, 51, 51)];
    [basicView addSubview:playNameLabel];
    [playNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stationNameLabel.mas_bottom).offset(11*kScale);
        make.left.equalTo(_fansLabel.mas_right).offset(2);
        make.height.mas_greaterThanOrEqualTo(12*kScale);
    }];
    playNameLabel.text = [NSString stringWithFormat:@"%@:",Local(@"PlayNum")];
    
    _playNumLabel = [EMUtil createLabelWithFont:ComFont(12*kScale) andColor:RGB(51, 51, 51)];
    [basicView addSubview:_playNumLabel];
    [_playNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stationNameLabel.mas_bottom).offset(11*kScale);
        make.left.equalTo(playNameLabel.mas_right).offset(2);
        make.height.mas_greaterThanOrEqualTo(12*kScale);
        make.width.mas_greaterThanOrEqualTo(20*kScale);
    }];
    [basicView addSubview:_playNumLabel];
    _playNumLabel.text = @"0";
    
    _chatBtn = [EMButton new] ;
    [basicView addSubview:_chatBtn];
    [_chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(basicView.mas_top).offset(16*kScale);
        make.right.mas_equalTo(-10*kScale);
        make.size.mas_equalTo(Size(37*kScale, 37*kScale));
    }];
    [_chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_d"] forState:UIControlStateNormal];
    [_chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_d"] forState:UIControlStateHighlighted];
    [_chatBtn setImage:[UIImage imageNamed:@"enjoy_chat_pay"] forState:UIControlStateSelected];
    [_chatBtn addTarget:self action:@selector(chatAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _callBtn = [EMButton new];
    [basicView addSubview:_callBtn];
    [_callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_chatBtn.mas_top);
        make.right.equalTo(_chatBtn.mas_left).offset(-10*kScale);
        make.size.mas_equalTo(Size(37*kScale, 37*kScale));
    }];
    [_callBtn setImage:[UIImage imageNamed:@"enjoy_call_d"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"enjoy_call_pay"] forState:UIControlStateSelected];
    [_callBtn setImage:[UIImage imageNamed:@"enjoy_call_off"] forState:UIControlStateDisabled];
    [_callBtn addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _careBtn = [EMButton new];
    [basicView addSubview:_careBtn];
    [_careBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_chatBtn.mas_top);
        make.right.equalTo(_callBtn.mas_left).offset(-10*kScale);
        make.size.mas_equalTo(Size(37*kScale, 37*kScale));
    }];
    [_careBtn setImage:[UIImage imageNamed:@"enjoy_attention_d"] forState:UIControlStateNormal];
    [_careBtn setImage:[UIImage imageNamed:@"enjoy_attention"] forState:UIControlStateHighlighted];
    [_careBtn setImage:[UIImage imageNamed:@"enjoy_attention"] forState:UIControlStateSelected];
    [_careBtn addTarget:self action:@selector(careAction:) forControlEvents:UIControlEventTouchUpInside];
    
    EMView *detailView = [EMView new];
    [backView addSubview:detailView];
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(basicView.mas_bottom);
        make.left.and.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    
    EMView *lineViewTop = [EMView new];
    [detailView addSubview:lineViewTop];
    lineViewTop.backgroundColor = RGB(171, 171, 171);
    [lineViewTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    EMView *lineViewMiddle = [EMView new];
    [detailView addSubview:lineViewMiddle];
    [lineViewMiddle setBackgroundColor:RGB(231,218,233)];
    [lineViewMiddle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(44*kScale);
    }];
    
    _lineViewBottom = [EMView new];
    [detailView addSubview:_lineViewBottom];
    _lineViewBottom.backgroundColor = RGB(171, 171, 171);
    [_lineViewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineViewTop.mas_bottom).offset(42*kScale);
        make.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    
    _leftBtn = [EMButton new];
    [detailView addSubview:_leftBtn];
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(ScreenWidth/2);
        make.bottom.equalTo(_lineViewBottom.mas_bottom);
    }];
    [_leftBtn setTitle:Local(@"StationIntro") forState:UIControlStateNormal];
    [_leftBtn.titleLabel setFont:ComFont(14*kScale)];
    [_leftBtn setTitleColor:RGB(209,172,255) forState:UIControlStateNormal];
    [_leftBtn setTitleColor:RGB(145,90,173) forState:UIControlStateSelected];
    _leftBtn.selected = YES;
    [_leftBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _lineView = [EMView new];
    [detailView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_lineViewBottom.mas_bottom);
        make.width.mas_equalTo(61*kScale);
        make.height.mas_equalTo(3*kScale);
        make.centerX.equalTo(_leftBtn);
    }];
    _lineView.backgroundColor = RGB(145,90,173);
    
    _rightBtn = [EMButton new];
    [detailView addSubview:_rightBtn];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(ScreenWidth/2);
        make.bottom.equalTo(_lineViewBottom.mas_bottom);
    }];
    [_rightBtn setTitle:Local(@"ProductGift") forState:UIControlStateNormal];
    [_rightBtn.titleLabel setFont:ComFont(14*kScale)];
    [_rightBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn setTitleColor:RGB(209,172,255) forState:UIControlStateNormal];
    [_rightBtn setTitleColor:RGB(145,90,173) forState:UIControlStateSelected];
    
    _bottomScrollView = [UIScrollView new];
    [detailView addSubview:_bottomScrollView];
    [_bottomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineViewBottom.mas_bottom);
        make.bottom.and.left.and.right.mas_equalTo(0);
    }];
    _bottomScrollView.pagingEnabled = YES;
    _bottomScrollView.delegate = self;
    
    UIView *bottomContainer = [UIView new];
    [_bottomScrollView addSubview:bottomContainer];
    [bottomContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_bottomScrollView);
        make.height.equalTo(_bottomScrollView);
    }];

    
    _bottomLeftView = [UIScrollView new];
    [bottomContainer addSubview:_bottomLeftView];
    [_bottomLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.mas_equalTo(0);
        make.width.mas_equalTo(kScreenW);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(0.f, 5, 9.f, 0);
    _bottomrightCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [bottomContainer addSubview:_bottomrightCollectionView];
    [_bottomrightCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(0);
        make.left.equalTo(_bottomLeftView.mas_right);
        make.width.mas_equalTo(kScreenW);
    }];
    
    _bottomrightCollectionView.delegate = self;
    _bottomrightCollectionView.dataSource =self;
    _bottomrightCollectionView.alwaysBounceVertical = YES;
    _bottomrightCollectionView.backgroundColor = [UIColor clearColor];
    _bottomrightCollectionView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
    _bottomrightCollectionView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];
      _cnt = 30;
    
    [bottomContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bottomrightCollectionView.mas_right);
    }];
    
    //基本信息栏
    NSArray *labelArray = @[Local(@"Age"), Local(@"Country"),Local(@"City"),Local(@"Height"),Local(@"Slogan")];

    NSString *age = _lonelyUser.age != nil?_lonelyUser.age :@"";
    NSString *country = _lonelyUser.country != nil?_lonelyUser.country :@"";
    NSString *city = _lonelyUser.city != nil?_lonelyUser.city :@"";
    NSString *aHeight = _lonelyUser.height != nil?_lonelyUser.height :@"";
    NSString *type = _lonelyUser.type != nil?_lonelyUser.type :@"";
    NSString *job = _lonelyUser.job != nil?_lonelyUser.job :@"";
    NSString *slogan = _lonelyUser.slogan != nil?_lonelyUser.slogan :@"";


    NSArray *labelValue = @[[NSString stringWithFormat:@"%@%@", age,Local(@"Year")],country,city,aHeight,type,job,slogan];

    NSArray *imgArray = @[[UIImage imageNamed:@"PERyear"],[UIImage imageNamed:@"PERcountry"],[UIImage imageNamed:@"PERcity"],[UIImage imageNamed:@"PERheight"],[UIImage imageNamed:@"PERmood"]];
    double y =  18*kScale;
    for (int i = 0; i<imgArray.count; i++) {
        UIImage *image = imgArray[i];
        UIImageView *labelImageView = [[UIImageView alloc] initWithFrame:Rect(15*kScale, y, image.size.width, image.size.height)];
        [_bottomLeftView addSubview:labelImageView];
        labelImageView.image = imgArray[i];

        EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(52*kScale, y,200*kScale, 25*kScale)];
        label.textColor = RGB(51, 51, 51);
        label.font = ComFont(13);
        [_bottomLeftView addSubview:label];
        label.tag = 1001+i;
        label.text = [NSString stringWithFormat:@"%@:%@",labelArray[i],labelValue[i]];
        y += 14 * kScale + 25*kScale;
    }
    
    EMView *lineLast = [[EMView alloc] initWithFrame:Rect(0, y, kScreenW, 1)];
    lineLast.backgroundColor = RGB(145,90,173);
    [_bottomLeftView addSubview:lineLast];
    
    y += 14*kScale;
    //荣誉墙
    _nameWall = [[EMLabel alloc] initWithFrame:Rect(15*kScale, y, kScreenW-15*kScale, 17*kScale)];
    _nameWall.textColor = RGB(51,51,51);
    _nameWall.font = ComFont(16*kScale);
    _nameWall.text = Local(@"NameWall");
    [_bottomLeftView addSubview:_nameWall];
    
    y += 14*kScale;
    _bottomLeftView.contentSize = Size(0, y);
}

/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    if (!_isLastPage) {
        _from += _cnt;
        [self loadProductData:NO];
    }else{
        _bottomrightCollectionView.mj_footer.state = MJRefreshStateNoMoreData;
    }
}

/**
 *  下拉刷新
 */
-(void)pushDownLoad{
    _from = 0;
    [self loadProductData:NO];
}

-(void)loadProductData:(BOOL)showHUD{
    if (showHUD) {
        [UIUtil showHUD:self.bottomrightCollectionView];
    }
    WS(weakSelf)
    //加载作品
    [_mainViewVM getPersonalInfoWithMember:_lonelyUser andBlock:^(NSArray<BoardcastObj *> *arr, BOOL ret) {
        SS(weakSelf, strongSelf)
        if (showHUD) {
            [UIUtil hideHUD:strongSelf.bottomrightCollectionView];
        }
        if (arr && ret) {
            if (_from == 0) {
                [_productArray removeAllObjects];
            }
            [_productArray addObjectsFromArray:arr];
            if (_productArray.count == _from + _cnt) {
                _isLastPage = NO;
            }else{
                _isLastPage = YES;
            }
            [_bottomrightCollectionView reloadData];
            if (_productArray.count == 0){
                [strongSelf.view.window makeToast:Local(@"ThereisNoAiring") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else {
            [_bottomrightCollectionView reloadData];
            [strongSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        [strongSelf endRefesh];
    } andFrom:[NSString stringWithFormat:@"%d",_from] andCnt:[NSString stringWithFormat:@"%d",_cnt]];
}

#pragma mark -- UICollectionViewDelegate
//设置每个 UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width-33)/3, (self.view.frame.size.width-33)/3 + 5);
}

//cell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _productArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"MainDynamicCell";
    MainDynamicCell * dynamicCell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    BoardcastObj *obj = _productArray[indexPath.row];
    [dynamicCell setValueWithObj:obj];
    return dynamicCell;
}


//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 13,10);
}

//定义每个UICollectionView 的纵向间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}


-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BoardcastObj *obj = _productArray[indexPath.row];
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.index =(int)indexPath.row;
    personalRecord.lonelyUser = _lonelyUser;
    personalRecord.shouldPlay = YES;
    personalRecord.stationDataArray = _productArray;
    [self.navigationController pushViewController:personalRecord animated:YES];
}

-(void)endRefesh{
    [_bottomrightCollectionView.mj_header endRefreshing];
    [_bottomrightCollectionView.mj_footer endRefreshing];
}


- (void)buttonAction:(UIButton*)btn {
    if (btn == _leftBtn) {
        [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_lineViewBottom.mas_bottom);
            make.width.mas_equalTo(61*kScale);
            make.height.mas_equalTo(3*kScale);
            make.centerX.equalTo(_leftBtn);
        }];
        [_bottomScrollView setContentOffset:Point(0, 0)];
        _leftBtn.selected = YES;
        _rightBtn.selected = NO;
    }else {
        [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_lineViewBottom.mas_bottom);
            make.width.mas_equalTo(61*kScale);
            make.height.mas_equalTo(3*kScale);
            make.centerX.equalTo(_rightBtn);
        }];
        [_bottomScrollView setContentOffset:Point(ScreenWidth, 0)];
        _leftBtn.selected = NO;
        _rightBtn.selected = YES;
    }
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
        _sendView.frame = Rect(0, y, kScreenW, height);
        
        
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


- (void)callAction:(EMButton*)btn {
    if (![UIUtil checkLogin]) {
        return;
    }
    [EMUtil chatCallUser:_lonelyUser andController:self];
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
                _audioPlayerView.allTime = [_lonelyUser.voiceDurion intValue];
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
    if (user.talkSecond.intValue >= 360){
        [UIUtil showHUD:[[UIApplication sharedApplication] keyWindow]];
        [_callViewVM sendGift:userId andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:[[UIApplication sharedApplication] keyWindow]];
            if (dict && ret) {
                DLog(@"dict==%@",dict);
                if ([dict[@"code"] intValue] == 1) {
                    [self hiddenMask:nil];
                    //成功了
                    user.talkSecond = [NSString stringWithFormat:@"%d",[user.talkSecond intValue] - 180];
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


@end
