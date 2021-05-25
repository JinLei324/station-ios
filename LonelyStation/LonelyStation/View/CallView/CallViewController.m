//
//  CallViewController.m
//  LonelyStation
//
//  Created by mac on 16/7/3.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "CallViewController.h"
#import "AppDelegate.h"
#import "UIUtil.h"
#import "UICycleImgView.h"
#import "CallImgView.h"
#import "EMUtil.h"
#import "ViewModelCommom.h"
#import <CommonCrypto/CommonDigest.h>
#import "WTImageScroll.h"
#import "AddMoneyMainVC.h"
#import "MainViewVM.h"


@interface CallViewController ()<CallImgViewDelegate> {
    BOOL mute; //静音
    BOOL speaker;
    BOOL videoInvite;
    BOOL sipInitialized;
    
    AppDelegate *appDelegate;
    //头像
    UICycleImgView *_headUserImgView;
    //昵称
    EMLabel *_nickLabel;

    //接通动画img
    YYAnimatedImageView *_animationView;
    
    //时间Label
    EMLabel *_timeLabel;
    //接听Label
    EMLabel *_applyLabel;
    //提示 Label
    EMLabel *_warningLabel;
    
    //喇叭，送礼，静音
    EMButton *_loudlyBtn;
    EMButton *_sendGiftBtn;
    EMButton *_quiteBtn;
    EMLabel *_sendGiftBtnDes;
    
    CallImgView *_rejectBtn;
    CallImgView *_applyBtn;
    
    YYAnimatedImageView *_rejectAnimationView;
    YYAnimatedImageView *_applyAnimationView;

    //挂断按钮
    EMButton *_applyEndBtn;
    
    //送礼view
    EMButton *_maskBtnView;
    EMView *_sendView;
    
    NSTimer *_connectTimer;
    int allTime;
    CallViewVM *callViewVM;
    NSString *_startDate;
    UIView *_imgScroll;
    
    //从系统通话而来
    BOOL isSystemTalk;
    
    BOOL isOnTalking;//是否在通话界面
}

@property(nonatomic,strong)MainViewVM *mainViewVM;

@end

@implementation CallViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    self.viewNaviBar.hidden = YES;
    [self initViews];
    [self setStatus];
    [self.viewNaviBar setLeftBtn:nil];
    callViewVM = [[CallViewVM alloc] init];
}

- (MainViewVM*)mainViewVM {
    if (!_mainViewVM) {
        _mainViewVM = [MainViewVM new];
    }
    return _mainViewVM;
}


- (void)callUser {
    [appDelegate makeCall:_toUser.sipid videoCall:NO];
    
//    [appDelegate makeCall:@"8861680000001" videoCall:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isOnTalking = YES;
    //设置红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if (_isBlind) {
        if (_imgScroll) {
            [(WTImageScroll*)_imgScroll stopTimer];
            [_imgScroll removeFromSuperview];
             _imgScroll = nil;
        }
        _nickLabel.hidden = YES;
        //盲目通话的动画
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self blindAnimation];
            });
        });
        _isBlind = NO;
    }else {
        [self reloadFromUser];
    }
     NSString *str = [[[FileAccessData sharedInstance] objectForEMKey:@"isChecking"] lastObject];
    if ([str isEqualToString:@"1"]) {
        _sendGiftBtnDes.hidden = YES;
        _sendGiftBtn.hidden = YES;
    }else {
        _sendGiftBtnDes.hidden = NO;
        _sendGiftBtn.hidden = NO;
    }
    //获取最新的聊币
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [self.mainViewVM  getMyTime:YES andBlock:^(NSDictionary *dict, BOOL ret) {
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
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isOnTalking = NO;

     //取消红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setIsReceieveCall:NO];
    
}

//重新加载头像名字数据，第一次的时候没有的
- (void)reloadFromUser {
    if (_callStatus == CallIncoming) {
        [_headUserImgView yy_setImageWithURL:[NSURL URLWithString:_fromUser.file] placeholder:[UIImage imageNamed:[EMUtil getCallInHeader]]];
        _nickLabel.text = _fromUser.nickName;
    }else {
        [_headUserImgView yy_setImageWithURL:[NSURL URLWithString:_toUser.file] placeholder:[UIImage imageNamed:[EMUtil getCallInHeader]]];
        _nickLabel.text = _toUser.nickName;
    }
}

//盲目通话动画
- (void)blindAnimation{
    _headUserImgView.hidden = YES;
    _imgScroll = [WTImageScroll ShowNetWorkImageScrollWithFream:_headUserImgView.frame andImageArray:_blindUserArray andBtnClick:^(NSInteger tagValue) {

    }];
    _imgScroll.layer.cornerRadius = _imgScroll.bounds.size.width/2.f;
    _imgScroll.layer.masksToBounds = YES;
    [self.view addSubview:_imgScroll];
    [self performSelector:@selector(stop) withObject:nil afterDelay:2];
//    _headUserImgView
}

- (void)stop {
    _headUserImgView.hidden = NO;
    [(WTImageScroll*)_imgScroll stopTimer];
    [_imgScroll removeFromSuperview];
    _imgScroll = nil;
    _nickLabel.hidden = NO;
    //这里才去打电话
    if (isOnTalking) {
        [self callUser];
    }
}

- (void)changeImage {
    [_headUserImgView yy_setImageWithURL:[NSURL URLWithString:_toUser.file] placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:_toUser.gender]]];
}

//修改本地拨打时间
- (void)changeTalkTime:(int)time {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    int talkSecond = [user.talkSecond intValue];
    if (time != 0) {
        talkSecond -= time;
        if (talkSecond < 0) {
            talkSecond = 0;
        }
        user.talkSecond = [NSString stringWithFormat:@"%d",talkSecond];
        [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
    }
}

//设为接通状态，把动画去掉
- (void)setConnecting:(BOOL)ret {
    DLog(@"ret=+%d",ret);
    _animationView.hidden = ret;
    _timeLabel.hidden = !ret;
    speaker = NO;
    [appDelegate setLoudspeakerStatus:NO];
    [appDelegate setLoudspeakerStatus:YES];
    [appDelegate setLoudspeakerStatus:NO];
    if (ret) {
        [self clearTimer];
        [self createTimmer];
        _startDate = [EMUtil GetCurrentTime];

    }else {
        int time = allTime;
        [self clearTimer];
        mute = NO;
        [_quiteBtn setSelected:mute];
        if (time > 3) {
            //3秒之后更新时间
            //如果是自己打出的才更新
            if ([_fromUser.userID isEqualToString: [[ViewModelCommom getCuttentUser] userID]]) {
                //获取通话时间
//                _toUser.sipid = @"8868180000112";//测试id
                
                [callViewVM getTalkTimeWithSipId1:_fromUser.sipid andSipId2:_toUser.sipid andBlock:^(NSDictionary *dict, BOOL ret) {
                    if (dict && ret) {
                        _startDate = dict[@"calldate"];
                        NSString *time = [NSString stringWithFormat:@"%d",[dict[@"billsec"] intValue]];
                        if (_fromUser.gender && [_fromUser.gender isEqualToString:@"M"]) {
                            [self changeTalkTime:[time intValue]];
                        }
                        [callViewVM updateTime:time andDate:_startDate andSipId1:_fromUser.sipid andsipID2:_toUser.sipid andBlock:^(NSDictionary *dict, BOOL ret) {
                            DLog(@"%@",dict);
                        }];
                    }
                }];
                
                
            }
        }
    }
}


- (void)createTimmer {
    _connectTimer = [[NSTimer alloc] init];
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerUp) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_connectTimer forMode:NSRunLoopCommonModes];
}

- (void)timerUp {
    //计算时间
    allTime++;
    NSString *time = [EMUtil getAlltimeString:[NSString stringWithFormat:@"%d",allTime]];
    _timeLabel.text = time;
    //判断如果是打出去的，而且alltime大于剩下的长度的时候，强制关掉电话,给出提示
    if (_callStatus == CallOut) {
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        if (user.gender && [user.gender isEqualToString:@"M"]) {
            //判断是否为收费
            if([@"Y" isEqualToString:_toUser.talkCharge]){
                int rate = [_toUser.talkChargeRate intValue];
                if (rate != 0 && (allTime/60) * rate > [user.chat_point intValue]) {
                    //强制关掉，给出提示
                    [self back:nil];
                    AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"TalkTimeNotEnough") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                        if (!cancelled) {
                            AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
                            UIViewController *topController = [[(AppDelegate*)ApplicationDelegate window] rootViewController];
                            [(UINavigationController*)topController pushViewController:addMoneyMainVC animated:YES];
                        }
                    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"OKQuickBuy"), nil];
                    [alert show];
                    alert = nil;
                }
            }
        }
    }

    
    
}


- (void)clearTimer {
    if (_connectTimer) {
        if ([_connectTimer isValid]) {
            [_connectTimer invalidate];
        }
        _connectTimer = nil;
    }
    allTime = 0;
    _timeLabel.text = @"00:00";
}

- (void)setStatus {
    BOOL ret = YES;
    if (_callStatus == CallIncoming) {
        ret = NO;
    }else {
        ret = YES;
    }
    //接电话时不可用
    [_sendGiftBtn setEnabled:ret];

    _rejectBtn.hidden = ret;
    _applyBtn.hidden = ret;
    _applyEndBtn.hidden = !ret;
    _applyAnimationView.hidden = ret;
    _rejectAnimationView.hidden = ret;
    if (_callStatus == CallOut && self.isBlind == NO) {
        [self callUser];
    }
}


- (void)setCallStatus:(CallViewStatus)callStatus {
    _callStatus = callStatus;
    [self setStatus];
}

- (NSString *)md5:(NSString *)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];//
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
//上线
- (BOOL)onLineAction:(NSString*)kUserName displayName:(NSString*)kDisplayName andAuthName:(NSString*)kAuthName andPassword:(NSString*)kPassword andDomain:(NSString*)kUserDomain andSIPServer:(NSString*)kSIPServer andSIPServerPort:(int)kSIPServerPort {
    if (sipInitialized) {
        return YES;
    }
    TRANSPORT_TYPE transport = TRANSPORT_UDP;//TRANSPORT_TCP
    //When you need background, TCP and TLS SIP transport is save battery, UDP takes more battery
    
    //先用测试用的id和密码
//    kUserName = @"8868180000006";
//    kDisplayName = @"8868180000006";
//    kPassword = @"1qaz2wsx";
    
    kPassword = [self md5:kPassword];
    
    int ret = [mPortSIPSDK initialize:transport loglevel:PORTSIP_LOG_NONE logPath:@"" maxLine:8 agent:@"PortSIP SDK for IOS" audioDeviceLayer:0 videoDeviceLayer:0];
    
    if(ret != 0)
    {
        NSLog(@"initialize failure ErrorCode = %d",ret);
        return NO;
    }
    
    int localPort = 10000 + arc4random()%1000;
    NSString* loaclIPaddress = @"0.0.0.0";//Auto select IP address
//    if(transport == TRANSPORT_TCP ||
//       transport == TRANSPORT_TLS){
//        //TCP must use the specified IP
//        int nicNumber = [mPortSIPSDK getNICNums];
//        for(int i = 0 ; i < nicNumber; i++){
//            NSLog(@"loaclIP %d = %@",i,[mPortSIPSDK getLocalIpAddress:i]);
//        }
//        
//        loaclIPaddress = [mPortSIPSDK getLocalIpAddress:0];
//    }

    
     [mPortSIPSDK setUser:kUserName displayName:kDisplayName authName:kAuthName password:kPassword localIP:loaclIPaddress localSIPPort:localPort userDomain:kUserDomain SIPServer:kSIPServer SIPServerPort:kSIPServerPort STUNServer:@"" STUNServerPort:0 outboundServer:@"" outboundServerPort:0];
    int rt = [mPortSIPSDK setLicenseKey:@"1nx02RUZCQjUzRjlENjk4REU4OEE2N0ZDQkUyM0ZENUMxMkAxMjVERTZBQzA5OUMzRDBEMTZFMDc2RDA0NTU0MUZBREBDMjI0NDg3REEyOEUxNkQwODYzMjcwMDQ4NDAxMTMwOEBEQTdFRUQwMDdBNEVEQzMzNTI1QTAzRDFBOUE2RjE0NA"];
    NSLog(@"rt==%d",rt);
    [mPortSIPSDK addAudioCodec:AUDIOCODEC_PCMA];
    [mPortSIPSDK addAudioCodec:AUDIOCODEC_PCMU];
    [mPortSIPSDK addAudioCodec:AUDIOCODEC_SPEEX];
    [mPortSIPSDK addAudioCodec:AUDIOCODEC_G729];
    [mPortSIPSDK addVideoCodec:VIDEO_CODEC_H264];
    [mPortSIPSDK setVideoBitrate:300];//video send bitrate,300kbps
    [mPortSIPSDK setVideoFrameRate:10];
    [mPortSIPSDK setVideoResolution:352 height:288];
    [mPortSIPSDK setAudioSamples:20 maxPtime:60];//ptime 20
    [mPortSIPSDK setVideoDeviceId:1];
    [mPortSIPSDK setVideoNackStatus:YES];
    [mPortSIPSDK enableVideoDecoderCallback:YES];
    ret = [mPortSIPSDK registerServer:90 retryTimes:0];
    if(ret != 0){
        [mPortSIPSDK unInitialize];
        sipInitialized = NO;
        DLog(@"registerServer failure ErrorCode = %d",ret);
    }else {
        sipInitialized = YES;
    }
    return sipInitialized;
}

//离线
- (void)offLineAction {
    if(sipInitialized)
    {
        [mPortSIPSDK unRegisterServer];
        [mPortSIPSDK unInitialize];
        sipInitialized = NO;
    }
}


- (void)initViews {
    //back Image
    UIImageView *userBackView = [[UIImageView alloc] initWithFrame:Rect(0, 0, kScreenW, 318*kScale)];
    userBackView.backgroundColor = [UIColor colorWithRed:0.9137254901960784 green:0.8509803921568627 blue:0.996078431372549 alpha:1.00];
    [self.view addSubview:userBackView];
    
    //头像
    CGFloat headWidth = 126*kScale;
    CGFloat headX = (kScreenW - headWidth)/2.f;
    CGFloat headY = 88*kScale;
    _headUserImgView = [[UICycleImgView alloc] initWithFrame:Rect(headX, headY, headWidth, headWidth)];
    [self.view addSubview:_headUserImgView];
    
    //名字
    _nickLabel = [[EMLabel alloc] initWithFrame:Rect(50, PositionY(_headUserImgView)+19*kScale, kScreenW - 100, 22)];
    _nickLabel.textColor = [UIColor whiteColor];
    _nickLabel.font = ComFont(21);
    _nickLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_nickLabel];
    
    CGFloat animationWidth = 42 * kScale;
    CGFloat animationX = (kScreenW - animationWidth)/2.f;
    CGFloat animationY = PositionY(_nickLabel) + 37*kScale;
    //接听动画
    _animationView = [[YYAnimatedImageView alloc] initWithFrame:Rect(animationX, animationY, animationWidth, 12*kScale)];
    _animationView.image = [YYImage imageNamed:@"wait.gif"];
    [self.view addSubview:_animationView];
    
    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(animationX, animationY, animationWidth, 12*kScale)];
    _timeLabel.textColor = RGB(255, 255, 255);
    _timeLabel.font = ComFont(11*kScale);
    _timeLabel.hidden = YES;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timeLabel];
    
    _warningLabel = [[EMLabel alloc] initWithFrame:Rect(0, PositionY(userBackView) + 10, kScreenW, 12)];
    _warningLabel.text = Local(@"WarningWIFI");
    _warningLabel.textColor = RGB(69,61,125);
    _warningLabel.font = ComFont(11);
    _warningLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_warningLabel];
    
    //喇叭，送礼，静音
    CGFloat loadlyX = 61*kScale;
    CGFloat loadlyY = PositionY(userBackView) + 77*kScale;
    CGFloat loadlyWidth = 30*kScale;
    CGFloat loadlySpace = (kScreenW - loadlyX * 2 - 3*loadlyWidth)/2.f;
    _loudlyBtn = [[EMButton alloc] initWithFrame:Rect(loadlyX, loadlyY, loadlyWidth, loadlyWidth)];
    [_loudlyBtn setImage:[UIImage imageNamed:@"answerVolume"] forState:UIControlStateNormal];
    [_loudlyBtn setImage:[UIImage imageNamed:@"answerVolumeOff"] forState:UIControlStateSelected];
    [_loudlyBtn addTarget:self action:@selector(touchSpeakerBUtton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loudlyBtn];
    
    EMLabel *loudlyBtnDes = [[EMLabel alloc] initWithFrame:Rect(loadlyX, PositionY(_loudlyBtn) + 10*kScale, loadlyWidth, 10)];
    loudlyBtnDes.font = ComFont(9);
    loudlyBtnDes.textColor = RGB(143,143,143);
    loudlyBtnDes.textAlignment = NSTextAlignmentCenter;
    loudlyBtnDes.text = Local(@"Horn");
    [self.view addSubview:loudlyBtnDes];
    
    _sendGiftBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_loudlyBtn) + loadlySpace, _loudlyBtn.frame.origin.y, loadlyWidth, loadlyWidth)];
    [_sendGiftBtn setImage:[UIImage imageNamed:@"answerGift"] forState:UIControlStateNormal];
    [_sendGiftBtn setImage:[UIImage imageNamed:@"answerGiftOff"] forState:UIControlStateDisabled];
    
    [_sendGiftBtn addTarget:self action:@selector(sendGiftAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_sendGiftBtn];
    _sendGiftBtn.hidden = YES;
    
    _sendGiftBtnDes = [[EMLabel alloc] initWithFrame:Rect(_sendGiftBtn.frame.origin.x, PositionY(_loudlyBtn) + 10*kScale, loadlyWidth*2, 10)];
    _sendGiftBtnDes.font = ComFont(9);
    _sendGiftBtnDes.textColor = RGB(143,143,143);
    _sendGiftBtnDes.textAlignment = NSTextAlignmentCenter;
    _sendGiftBtnDes.text = Local(@"SendGift");
    _sendGiftBtnDes.center = Point(_sendGiftBtn.center.x, _sendGiftBtnDes.center.y);
    [self.view addSubview:_sendGiftBtnDes];
    _sendGiftBtnDes.hidden = YES;
    

    _quiteBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_sendGiftBtn) + loadlySpace, _loudlyBtn.frame.origin.y, loadlyWidth, loadlyWidth)];
    [_quiteBtn setImage:[UIImage imageNamed:@"answerMic"] forState:UIControlStateNormal];
    [_quiteBtn setImage:[UIImage imageNamed:@"answerMicOff"] forState:UIControlStateSelected];
    [_quiteBtn addTarget:self action:@selector(touchMuteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_quiteBtn];
    
    EMLabel *quiteBtnDes = [[EMLabel alloc] initWithFrame:Rect(_quiteBtn.frame.origin.x, PositionY(_loudlyBtn) + 10*kScale, loadlyWidth, 10)];
    quiteBtnDes.font = ComFont(9);
    quiteBtnDes.textColor = RGB(143,143,143);
    quiteBtnDes.textAlignment = NSTextAlignmentCenter;
    quiteBtnDes.text = Local(@"Quiet");
    [self.view addSubview:quiteBtnDes];

    
    
    if (_toUser) {
        [_headUserImgView yy_setImageWithURL:[NSURL URLWithString:_toUser.file] placeholder:[UIImage imageNamed:[EMUtil getCallInHeader]]];
        _nickLabel.text = _toUser.nickName;
    }else {
        [_headUserImgView setImage:[UIImage imageNamed:[EMUtil getCallInHeader]]];
        _nickLabel.text = @"";
    }
    //接听区域
    
    _applyAnimationView = [[YYAnimatedImageView alloc] initWithFrame:Rect(70*kScale, kScreenH - 44*kScale - 53*kScale, 58*kScale, 44*kScale)];
    _applyAnimationView.image = [YYImage imageNamed:@"callOn.gif"];
    [self.view addSubview:_applyAnimationView];
    
    _rejectAnimationView = [[YYAnimatedImageView alloc] initWithFrame:Rect(kScreenW - 73*kScale - 58*kScale, kScreenH - 44*kScale - 53*kScale, 58*kScale, 44*kScale)];
    _rejectAnimationView.image = [YYImage imageNamed:@"callOff.gif"];
    [self.view addSubview:_rejectAnimationView];
    
    
    CGFloat x = 7*kScale;
    CGFloat width = 81*kScale;
    CGFloat y = kScreenH-width + x;
    _applyBtn = [[CallImgView alloc] initWithFrame:Rect(-x, y, width, width)];
    [_applyBtn setImage:[UIImage imageNamed:@"answerStart"]];
    [self.view addSubview:_applyBtn];
    _applyBtn.minPointY = y - 50;
    _applyBtn.delegate = self;


    
    x = kScreenW - width + x;
    _rejectBtn = [[CallImgView alloc] initWithFrame:Rect(x, y, width, width)];
    [_rejectBtn setImage:[UIImage imageNamed:@"answerEnd"]];
//    [_rejectBtn addTarget:self action:@selector(touchRejectButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rejectBtn];
    _rejectBtn.minPointY = y - 50;
    _rejectBtn.isRight = YES;
    _rejectBtn.delegate = self;
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:(id)kCFRunLoopCommonModes];

    width = 94 * kScale;
    y = PositionY(userBackView) + 194*kScale;
    
    if (IsIPhone4) {
        y = PositionY(userBackView) + 140*kScale;
    }
    x = (kScreenW - width)/2.f;
    _applyEndBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, width)];
    [_applyEndBtn setImage:[UIImage imageNamed:@"answerEnd"] forState:UIControlStateNormal];
    [_applyEndBtn addTarget:self action:@selector(hungUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_applyEndBtn];
    
    
    
    
    _maskBtnView = [[EMButton alloc] initWithFrame:Rect(0, 0, ScreenWidth, ScreenHeight)];
    _maskBtnView.alpha = 0;
    _maskBtnView.backgroundColor = RGBA(0, 0, 0,0.6);
    [_maskBtnView addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_maskBtnView];
    
    CGFloat height = 239*kScale;
    y = (kScreenH - height)/2.f;
    _sendView = [[EMView alloc] initWithFrame:Rect(15*kScale, y, kScreenW-30*kScale, height)];
    _sendView.layer.backgroundColor = RGB(0xff, 0xff, 0xff).CGColor;
    _sendView.layer.cornerRadius = 10;
    [_maskBtnView addSubview:_sendView];
    
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
    [closeBtn addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [_sendView addSubview:closeBtn];
    
    
    
    
//    _maskBtnView = [[EMButton alloc] initWithFrame:Rect(0, 0, ScreenWidth, ScreenHeight)];
//    _maskBtnView.alpha = 0;
//    _maskBtnView.backgroundColor = RGBA(0, 0, 0,0.6);
//    [_maskBtnView addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.view addSubview:_maskBtnView];
//
//    CGFloat height = 239*kScale;
//    y = (kScreenH - height)/2.f;
//    _sendView = [[EMView alloc] initWithFrame:Rect(0, y, kScreenW, height)];
//    _sendView.backgroundColor = RGB(0xff, 0xff, 0xff);
//    [_maskBtnView addSubview:_sendView];
//
//    width = 35;
//    height = 38;
//    x = (kScreenW - width)/2.f;
//    y = 52*kScale;
//    UIImageView *giftImgView = [[UIImageView alloc] initWithFrame:Rect(x, y, width, height)];
//    giftImgView.image = [UIImage imageNamed:@"answerGift"];
//    [_sendView addSubview:giftImgView];
//
//    EMLabel *giftLabel = [[EMLabel alloc] initWithFrame:Rect(60*kScale, PositionY(giftImgView)+35*kScale, kScreenW-120*kScale, 17*kScale)];
//    giftLabel.font = ComFont(16*kScale);
//    giftLabel.textColor = RGB(78,78,78);
//    giftLabel.text = Local(@"WillSend3Min");
//    giftLabel.textAlignment = NSTextAlignmentCenter;
//    [_sendView addSubview:giftLabel];
//
//    width = 92*kScale;
//    height = 35*kScale;
//    x = (kScreenW - width)/2.f;
//    y = PositionY(giftLabel)+ 36*kScale;
//    EMButton *sendBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, height) andConners:5];
//    sendBtn.borderColor = RGB(0,0,0);
//    sendBtn.borderWidth = 1;
//    [sendBtn setTitle:Local(@"SendMin") forState:UIControlStateNormal];
//    [sendBtn setTitleColor:RGB(78,78,78) forState:UIControlStateNormal];
//    [sendBtn addTarget:self action:@selector(sendGift:) forControlEvents:UIControlEventTouchUpInside];
//    [_sendView addSubview:sendBtn];
//
//    EMButton *closeBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 25*kScale - 20, 20*kScale, 25*kScale, 25*kScale)];
//
//    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
//    [closeBtn setImage:[UIImage imageNamed:@"close_d"] forState:UIControlStateHighlighted];
//    [closeBtn addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
//    [_sendView addSubview:closeBtn];
}

- (void)sendGift:(EMButton*)btn {
    NSString *userId = @"";
    if (_callStatus == CallIncoming) {
        userId = _fromUser.userID;
    }else {
        userId = _toUser.userID;
    }
    //判断是否有6分钟以上的时间先
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if (user.chat_point.intValue >= 180){
        [UIUtil showHUD:[[UIApplication sharedApplication] keyWindow]];
        [callViewVM sendGift:userId andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:[[UIApplication sharedApplication] keyWindow]];
            if (dict && ret) {
                DLog(@"dict==%@",dict);
                if ([dict[@"code"]intValue] == 1) {
                    [self hiddenMask:nil];
                    //成功了
                    user.chat_point = [NSString stringWithFormat:@"%d",[user.chat_point intValue] - 180];
                    [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                    [self.view makeToast:Local(@"HandleSuccess") duration:3 position:[CSToastManager defaultPosition]];
                    
                }else {
                      [_maskBtnView makeToast:Local(@"HandleFailed") duration:3 position:[CSToastManager defaultPosition]];
                }
            }else{
                [_maskBtnView makeToast:Local(@"HandleFailed") duration:3 position:[CSToastManager defaultPosition]];
            }
        }];
    }else {
        [_maskBtnView makeToast:Local(@"MinNotEnough") duration:3 position:[CSToastManager defaultPosition]];
    }
   
}

//隐藏送礼
- (void)hiddenMask:(EMButton*)btn {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 0;
        CGRect frame = _maskBtnView.frame;
        _sendView.frame = Rect(frame.size.width/2, frame.size.height/2, 0, 0);
    } completion:NULL];
}

//显示送礼
- (void)sendGiftAction:(EMButton*)btn {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 1;
        CGFloat height = 239*kScale;
        CGFloat y = (kScreenH - height)/2.f;
        _sendView.frame = Rect(15*kScale, y, kScreenW-30*kScale, height);
        
        
    } completion:NULL];
}



- (void)displayLinkTick:(CADisplayLink *)link {
    [_rejectBtn simulateSpringWithDisplayLink:link];
    [_applyBtn simulateSpringWithDisplayLink:link];
}

//接听电话UI
-(void)acceptUI {
    BOOL ret = YES;
    _applyEndBtn.hidden = !ret;
    _applyBtn.hidden = ret;
    _rejectBtn.hidden = ret;
    _timeLabel.hidden = !ret;
    _animationView.hidden = ret;
    _applyAnimationView.hidden = ret;
    _rejectAnimationView.hidden = ret;
}


//接听电话
- (void)acceptSIP {
    //非系统通话
    isSystemTalk = NO;
    [self acceptUI];
    [self touchAnswerButton:nil];
}

- (void)didReachTheMinPoint:(CallImgView*)imgView {
    if (imgView == _applyBtn) {
        [self acceptSIP];
    }else {
        [self touchRejectButton:nil];
    }
}

- (void)didStartPan:(CallImgView*)imgView {
    
}

- (void)setFromUser:(LonelyUser *)fromUser {
    _fromUser = nil;
    _fromUser = fromUser;
    if (_callStatus == CallIncoming) {
        [_headUserImgView yy_setImageWithURL:[NSURL URLWithString:_fromUser.file] placeholder:[UIImage imageNamed:[EMUtil getCallInHeader]]];
        _nickLabel.text = _fromUser.nickName;
    }

}

- (void)setToUser:(LonelyUser *)toUser {
    _toUser = nil;
    _toUser = toUser;
    if (_callStatus == CallOut) {
        [_headUserImgView yy_setImageWithURL:[NSURL URLWithString:_toUser.file] placeholder:[UIImage imageNamed:[EMUtil getCallInHeader]]];
        _nickLabel.text = _toUser.nickName;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - mark Button Action

- (void)back:(id)sender {
    [appDelegate hungupCall:^{
        [self setConnecting:NO];
        [self dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

- (void)hungUp:(id)sender {
    if (isSystemTalk) {
//        [[AppCallKitManager sharedInstance] finshCallWithReason:CXCallEndedReasonRemoteEnded];
    }
    [appDelegate hungupCall:^{
        [self setConnecting:NO];
        [self dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)touchRejectButton:(id)sender {
    [appDelegate rejectCallCompletion:^{
        [self setConnecting:NO];
        [self dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)touchAnswerButton:(id)sender {
	[appDelegate answerCallCompletion:^{
        //TODO:接听成功block
        [self setConnecting:YES];
        //加上曾经看过的api
        
    } failblock:^{
        //TODO:接听失败block
        [self setConnecting:NO];

    }];
}



- (void)setTouchMuteTrue {
    mute = YES;
    [_quiteBtn setSelected:mute];
    [appDelegate muteCall:mute];
}

- (void)touchMuteButton:(EMButton*)sender {
    mute = !mute;
    [sender setSelected:mute];
    [appDelegate muteCall:mute];
}

- (void)touchSpeakerBUtton:(EMButton*)sender {
    speaker = !speaker;
    [sender setSelected:speaker];
    [appDelegate setLoudspeakerStatus:speaker];
}

- (void)touchVideoInviteButton:(id)sender {
    videoInvite = !videoInvite;
    //TODO:待实现
}

@end
