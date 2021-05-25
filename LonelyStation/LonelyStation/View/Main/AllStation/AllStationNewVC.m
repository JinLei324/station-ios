#import "UserInfoViewController.h"
#import "EMButton.h"
#import "MainTabBarController.h"
#import "MainCollectionViewCell.h"
#import "EMView.h"
#import "ViewModelCommom.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "PersonalStationVC.h"
#import "LoginViewModel.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "PersonalDetailInfoOldVC.h"
#import "MyRecordsViewController.h"
#import "MyFocousVC.h"
#import "EMUtil.h"
#import "AdvancedSearchVC.h"
#import "VoiceEmotionVC.h"
#import "LonelyActicleVC.h"
#import "MyVoicesVC.h"
#import "DouAudioPlayer.h"
#import "AppDelegateModel.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>
#import "EBForeNotification.h"
#import "AddMoneyMainVC.h"
#import "RecordIntroduceVC.h"
#import "ChatViewController.h"
#import "LoginStatusObj.h"
#import "RegisterViewController.h"
#import "AllStationNewVC.h"

@interface AllStationNewVC()<PersonalDetailInfoOldVCDelegate,DouAudioPlayerDelegate> {
    EMView *_maskView;
    MainViewVM *_mainViewVM;
    int _from;
    int _cnt;
    BOOL _isLastPage;
    LoginViewModel  *_loginVM;
    EMButton *userInfoBtn;
    //    AudioPlayerVM *_audioPlayerVM;
    int _playIndex;
    DouAudioPlayer *douAudioPlayer;
    EMButton *selectedRiceBtn;
    int selectItemIndex;
    UIImageView *_redImg;
}

@property (nonatomic,strong)UICollectionView *momentCollectionView;

@end

@implementation AllStationNewVC

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return AppBarStyle;
}

//-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message {
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
//        //判断是不是在打电话
//        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        if (app.isReceieveCall) {
//            //如果是打电话，不发声音
//            return YES;
//        }
//    }
//    return NO;
//
//}
//
//
//-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message
//                      withSenderName:(NSString *)senderName {
//    if ([message.senderUserId isEqualToString:@"11957"]) {
//        RCTextMessage *textMsg = (RCTextMessage*)message.content;
//        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//        localNotif.alertBody = [NSString stringWithFormat:@"%@, %@",textMsg.content,textMsg.extra];
//        localNotif.soundName = UILocalNotificationDefaultSoundName;
//        localNotif.applicationIconBadgeNumber = 1;
//        [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
//        return YES;
//    }else {
//        NSString *str = @"";
//        if ([message.objectName isEqualToString:@"RC:TxtMsg"]) {
//            str = [NSString stringWithFormat:@"%@",Local(@"TxtMsg")];
//        }else if([message.objectName isEqualToString:@"RC:VcMsg"]) {
//            str = [NSString stringWithFormat:@"%@",Local(@"VcMsg")];
//        }else if([message.objectName isEqualToString:@"RC:ImgMsg"]) {
//            str = [NSString stringWithFormat:@"%@",Local(@"ImgMsg")];
//        }
//        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//        localNotif.alertBody = [NSString stringWithFormat:@"%@",str];
//        localNotif.soundName = UILocalNotificationDefaultSoundName;
//        localNotif.applicationIconBadgeNumber = 1;
//        [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
//        return YES;
//    }
//}
//
//
//- (void)onRCIMReceiveMessage:(RCMessage *)message
//                        left:(int)left {
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)//应用在前台
//    {
//
//        if ([message.content.senderUserInfo.name isEqual:[NSNull null]]) {
//            [self getUserInfoWithUserId:message.content.senderUserInfo.userId completion:^(RCUserInfo *userInfo) {
//                message.content.senderUserInfo.name = userInfo.name;
//            }];
//        }
//
//        if ([message.objectName isEqualToString:@"RC:TxtMsg"] && [message.senderUserId isEqualToString:@"11957"]) {
//            //判断是不是在打电话
//            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            if (app.isReceieveCall) {
//                //如果是打电话，不显示推送
//                return;
//            }
//            RCTextMessage *msg = (RCTextMessage*)message.content;
//            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//            //前台只显示content
//            AppDelegate *dele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            UINavigationController *nav = (UINavigationController*)dele.window.rootViewController;
//            if (![nav.topViewController isKindOfClass:NSClassFromString(@"ChatViewController")] && ![nav.topViewController isKindOfClass:NSClassFromString(@"RCDCustomerServiceViewController")]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [EBForeNotification handleRemoteNotification:@{@"aps":@{@"alert":[NSString stringWithFormat:@"%@, %@",msg.content,msg.extra]}} soundID:0 isIos10:NO];
//                    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:@"11957"];
//                });
//            }
//        }else{
//            [self showOrNotRed];
//            //判断是不是在打电话
//            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            if (app.isReceieveCall) {
//                //如果是打电话，不显示推送
//                return;
//            }
//
//            AppDelegate *dele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            //判断是不是聊天页
//            UINavigationController *nav = (UINavigationController*)dele.window.rootViewController;
//            NSLog(@"nav==%@",nav);
//            NSString *str = @"";
//            if ([message.objectName isEqualToString:@"RC:TxtMsg"]) {
//                str = [NSString stringWithFormat:@"%@",Local(@"TxtMsg")];
//            }else if([message.objectName isEqualToString:@"RC:VcMsg"]) {
//                str = [NSString stringWithFormat:@"%@",Local(@"VcMsg")];
//            }else if([message.objectName isEqualToString:@"RC:ImgMsg"]) {
//                str = [NSString stringWithFormat:@"%@",Local(@"ImgMsg")];
//            }
//            if (![nav.topViewController isKindOfClass:NSClassFromString(@"ChatViewController")]){
//                //如果不是，显示content
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [EBForeNotification handleRemoteNotification:@{@"aps":@{@"alert":[NSString stringWithFormat:@"%@",str]}} soundID:0 isIos10:NO];
//                    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:message.targetId];
//                });
//            }
//
//
//        }
//    }else//应用在后台
//    {
//        int allunread = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@1]];//获取消息数量
//        if(allunread > 0){
//            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:allunread];//修改应用图标上的数字
//        }
//    }
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    //    _audioPlayerVM = [[AudioPlayerVM alloc] init];
    douAudioPlayer = [[DouAudioPlayer alloc] init];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    _currentImageArray = [NSMutableArray array];
    if (!_isAdVanceSearch) {
//        userInfoBtn = [[EMButton alloc] initWithFrame:Rect(15, 33, 40, 40) isRdius:YES];
//        //    [userInfoBtn setImage:[UIImage imageNamed:@"answer_no_photo"] forState:UIControlStateNormal];
//        LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
//        if (loginStatus.isLogined) {
//            LonelyUser *user = [ViewModelCommom getCuttentUser];
//            [userInfoBtn yy_setImageWithURL:[NSURL URLWithString:user.file] forState:UIControlStateNormal placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:user.gender]]];
//        }else {
//            if ([loginStatus.gender isEqualToString:@"M"]) {
//                [userInfoBtn setImage:[UIImage imageNamed:@"gender_M"] forState:UIControlStateNormal];
//            }else{
//                [userInfoBtn setImage:[UIImage imageNamed:@"gender_F"] forState:UIControlStateNormal];
//            }
//        }
//
//        [userInfoBtn addTarget:self action:@selector(userInfo:) forControlEvents:UIControlEventTouchUpInside];
//        [self.viewNaviBar setLeftBtn:nil];
//        [self.viewNaviBar addSubview:userInfoBtn];
        
        //添加提示的文字
//        _bridgeLabel = [[UILabel alloc] initWithFrame:Rect(PositionX(userInfoBtn) - 5, 33, 19, 13)];
//        _bridgeLabel.layer.cornerRadius = 5;
//        _bridgeLabel.layer.masksToBounds = YES;
//        _bridgeLabel.backgroundColor = RGB(178,0,0);
//        _bridgeLabel.textAlignment = NSTextAlignmentCenter;
//        _bridgeLabel.text = @"0";
//        _bridgeLabel.textColor = RGB(255,255,255);
//        _bridgeLabel.font = ComFont(8);
//        [self.viewNaviBar addSubview:_bridgeLabel];
        
//        EMLabel *infoLabel = [[EMLabel alloc] initWithFrame:Rect((kScreenW - 200)/2, 33, 200, 44)];
//        infoLabel.textAlignment = NSTextAlignmentCenter;
//        infoLabel.textColor = [UIColor whiteColor];
//        infoLabel.font = ComFont(19.f);
//        infoLabel.text = Local(@"HomePage");
//        [self.viewNaviBar addSubview:infoLabel];
//        userInfoBtn = nil;
        [self.viewNaviBar setTitle:Local(@"AllStation")];
        
        LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
        if (loginStatus.isLogined) {
            EMButton *moreBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 40 - 15 , 22, 40, 40)];
            [moreBtn setImage:[UIImage imageNamed:@"BTmore"] forState:UIControlStateNormal];
            [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewNaviBar addSubview:moreBtn];
            moreBtn = nil;
        }
        [self initViews];
        if (!_isAdVanceSearch) {
            if (self.tabViewController.isShowAnimation) {
                [self showFirstAnimation];
                //3秒后执行
                [self performSelector:@selector(changeTableViewController) withObject:nil afterDelay:3];
            }else {
                //登录成功，获取数据
                [self loadData:YES];
                
                [self thirdLogin];
            }
        }
        
    }else {
        EMLabel *infoLabel = [[EMLabel alloc] initWithFrame:Rect((kScreenW - 200)/2, 20, 200, 44)];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.textColor = RGB(145,90,173);
        infoLabel.font = ComFont(19.f);
        infoLabel.text = Local(@"AdvancedSearch");
        [self.viewNaviBar addSubview:infoLabel];
        [self initViews];
        //进阶搜寻获取数据
        [self loadData:YES];
    }
    
    
//    _redImg = [[UIImageView alloc] initWithFrame:Rect(kScreenW - 22, kScreenH - 44, 10, 10)];
//    _redImg.backgroundColor = [UIColor redColor];
//    _redImg.layer.cornerRadius = 5;
//    _redImg.layer.masksToBounds = YES;
//    [self.tabViewController.view addSubview:_redImg];
//    _redImg.hidden = YES;
//    [RCIM sharedRCIM].receiveMessageDelegate = self;
}


- (void)thirdLogin {
//    //如果没有登录，return掉
//    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
//    if (loginStatus.isLogined == NO) {
//        return;
//    }
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        //SIP上线
//        LonelyUser *user = [ViewModelCommom getCuttentUser];
//        AppDelegate *appDele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        BOOL isOnline = [appDele.callViewController onLineAction:user.sipid displayName:user.sipid andAuthName:@"" andPassword:user.password  andDomain:@""  andSIPServer:user.sipHost andSIPServerPort:[user.sipPort intValue]];
//        if (isOnline) {
//
//            _bridgeLabel.text = [NSString stringWithFormat:@"%@",user.unread];
//            //登录融云
//            [[RCIM sharedRCIM] connectWithToken:user.imtoken success:^(NSString *userId) {
//
//                //设置用户信息提供者,页面展现的用户头像及昵称都会从此代理取
//                [[RCIM sharedRCIM] setUserInfoDataSource:self];
//                NSLog(@"Login successfully with userId: %@.", userId);
//                //登录成功，获取数据
//                //                        [self loadData:YES];
//
//            } error:^(RCConnectErrorCode status) {
//
//            } tokenIncorrect:^{
//
//            }];
//        }
//    });
}


- (void)changeTableViewController{
    self.tabViewController.isShowAnimation = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    selectedRiceBtn = nil;
    if (_maskView) {
        _maskView.hidden = YES;
    }
    [douAudioPlayer pause];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _playIndex = -1;
//    LonelyUser *user = [ViewModelCommom getCuttentUser];
//    _bridgeLabel.text = [NSString stringWithFormat:@"%@",user.unread];
//    if (user.unread.intValue == 0) {
//        _bridgeLabel.hidden = YES;
//    }else {
//        _bridgeLabel.hidden = NO;
//    }
//
//    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
//    if (loginStatus.isLogined == NO) {
//        _bridgeLabel.hidden = YES;
//    }
//    if (self.tabViewController.isShowAnimation == NO) {
//        [self showOrNotRed];
//    }
//    if (self.tabViewController.shouldLogin3rd) {
//        self.tabViewController.shouldLogin3rd = NO;
//        [self thirdLogin];
//    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)createMaskView {
    _maskView = [[EMView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _maskView.backgroundColor = RGBA(0, 0, 0, 0.6);
    CGFloat x = 49 *kScale;
    CGFloat y = 0.39 * kScreenH;
    CGFloat width = kScreenW - 2 * x;
    CGFloat height = 60;
    //文字
    EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(x, y, width, height)];
    label.textColor = RGB(51, 51, 51);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSString *theyVoice = [user.gender isEqualToString:@"F"]? Local(@"DidPictureBlur"):Local(@"DidPictureBlurWoman");
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:theyVoice];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:7];//调整行间距
    [paragraphStyle setAlignment:NSTextAlignmentCenter]; //居中
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:ComFont(20) range:NSMakeRange(0, attributedString.length)];
    label.attributedText = attributedString;
    [_maskView addSubview:label];
    label.clipsToBounds = YES;
    
    //指上的图片
    width = 42 * kScale;
    x =  17 * kScale;
    CGFloat space = (((kScreenW - 5)/2 - 3 * width - x * 2) / 2.f) * kScale;
    CGFloat hight = self.view.frame.size.height/3;
    if (iphone4x_3_5) {
        hight = self.view.frame.size.height/3 + 31;
    }
    y = _momentCollectionView.frame.origin.y + hight  + (kScreenW - 5)/2 + 8 * kScale - 69*kScale;
    if (!iphone4x_3_5) {
        y += 1 * kScale;
    }
    UIImageView *imageViewUp = [[UIImageView alloc] initWithFrame:Rect(x + width + space - 3, y, 50*kScale, 69*kScale)];
    imageViewUp.image = [UIImage imageNamed:@"guideShowUp"];
    [_maskView addSubview:imageViewUp];
    
    width = 132;
    hight = 44;
    EMLabel *listenAiring = [[EMLabel alloc] initWithFrame:Rect(PositionX(imageViewUp) - 10 , y - hight + 10, width, hight)];
    listenAiring.text = Local(@"ClickToListenStation");
    listenAiring.numberOfLines = 0;
    listenAiring.textColor = RGB(0,234,255);
    [_maskView addSubview:listenAiring];
    
    //指下的图片
    width = 42 * kScale;
    hight = self.view.frame.size.height/3;
    if (iphone4x_3_5) {
        hight = self.view.frame.size.height/3 +30;
        y = y + 17 *kScale;
    }else {
        y = y + 18 *kScale;
    }
    UIImageView *imageViewDown = [[UIImageView alloc] initWithFrame:Rect(x + (width + space)*2 - 2, y, 50*kScale, 69*kScale)];
    imageViewDown.image = [UIImage imageNamed:@"guideShowDown"];
    [_maskView addSubview:imageViewDown];
    
    //聆听电台自介
    width = 132;
    hight = 44;
    if (iphone4x_3_5) {
        y = PositionY(imageViewDown) - 20;
    }else {
        y = PositionY(imageViewDown) - 10;
    }
    EMLabel *listenIntroudce = [[EMLabel alloc] initWithFrame:Rect(PositionX(imageViewDown) - 15 , y, width, hight)];
    listenIntroudce.text = Local(@"ClickToListenIntroduce");
    listenIntroudce.numberOfLines = 0;
    listenIntroudce.textColor = RGB(0,234,255);
    [_maskView addSubview:listenIntroudce];
    
    //知道了
    width = 92*kScale;
    hight = 36*kScale;
    x = (kScreenW-width)/2.f;
    if (iphone4x_3_5) {
        x = kScreenW - width - 8;
    }
    
    EMLabel *iKnowLabel = [[EMLabel alloc] initWithFrame:Rect(x, kScreenH - hight -18*kScale, width, hight) andConners:12*kScale];
    iKnowLabel.textColor = RGB(51, 51, 51);
    iKnowLabel.text = Local(@"IKnowRecordIsTooShort");
    iKnowLabel.textAlignment = NSTextAlignmentCenter;
    iKnowLabel.layer.borderColor = [RGB(51, 51, 51) CGColor];
    iKnowLabel.borderWidth = 1;
    iKnowLabel.borderColor = RGB(51, 51, 51);
    [_maskView addSubview:iKnowLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iKnowAction:)];
    [iKnowLabel addGestureRecognizer:tapGesture];
    iKnowLabel.userInteractionEnabled = YES;
    [self.tabViewController.view.window addSubview:_maskView];
    
}

- (void)iKnowAction:(UITapGestureRecognizer*)tapGesture {
    _maskView.hidden = YES;
}

#pragma mark dataAccess

- (void)showOrNotRed {
    int allunread = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@1]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (allunread !=0 ){
            _redImg.hidden = NO;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        }else {
            _redImg.hidden = YES;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
    });
    
    NSLog(@"allunread == %d",allunread);
}


-(void)endRefesh{
    [_momentCollectionView.mj_header endRefreshing];
    [_momentCollectionView.mj_footer endRefreshing];
    [self showOrNotRed];
    AppDelegateModel *appdelegateModel = [AppDelegateModel sharedInstance];
    if (appdelegateModel.rongNotifyObj) {
        [appdelegateModel dealWithNotify:appdelegateModel.rongNotifyObj];
        appdelegateModel.rongNotifyObj = nil;
    }
}

/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    if (!_isLastPage) {
        _from += _cnt;
        [self loadData:NO];
    }else{
        _momentCollectionView.mj_footer.state = MJRefreshStateNoMoreData;
    }
    
}

/**
 *  下拉刷新
 */
-(void)pushDownLoad{
    _from = 0;
    [self loadData:NO];
}


-(void)loadData:(BOOL)showHUD{
    
    if (!_isAdVanceSearch) {
        if (showHUD) {
            [UIUtil showHUD:self.momentCollectionView];
        }
        WS(weakSelf)
        [_mainViewVM getMainInfoWithBlock:^(NSArray<LonelyStationUser *> *arr, BOOL ret) {
            SS(weakSelf, strongSelf)
            if (showHUD) {
                [UIUtil hideHUD:strongSelf.momentCollectionView];
            }
            if (arr && ret) {
                if (_from == 0) {
                    @synchronized (_dataArray) {
                        [_dataArray removeAllObjects];
                    }
                }
                [_dataArray addObjectsFromArray:arr];
                if (_dataArray.count == _from + _cnt) {
                    _isLastPage = NO;
                }else{
                    _isLastPage = YES;
                }
                [_momentCollectionView reloadData];
                NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
                BOOL isThisAccountFirstComing = (BOOL)[defaluts objectForKey:[NSString stringWithFormat:@"%@firstComing",[[ViewModelCommom getCuttentUser] userID]]];
                if (!isThisAccountFirstComing) {
                    [self createMaskView];
                    [defaluts setBool:YES forKey:[NSString stringWithFormat:@"%@firstComing",[[ViewModelCommom getCuttentUser] userID]]];
                }
            }else {
                [self.tabViewController.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
            [self endRefesh];
        } andFrom:[NSString stringWithFormat:@"%d",_from] andCnt:[NSString stringWithFormat:@"%d",_cnt]];
    }else {
        if (showHUD) {
            [UIUtil showHUD:self.view];
        }
        [_mainViewVM getMainListWithSearch:[NSString stringWithFormat:@"%d",_from] andNumbers:[NSString stringWithFormat:@"%d",_cnt] andFromAge:_fromAge andEndAge:_endAge andOnline:_onLineStr andIdentity:_identityStr andSpkLang:_spkLangStr andCityId:_cityStr andJob:_jobStr andNickName:_nickStr andCharge:_chargeStr andBlock:^(NSArray<LonelyStationUser *> *arr, BOOL ret) {
            if (showHUD) {
                [UIUtil hideHUD:self.view];
            }
            if (arr && ret) {
                if (_from == 0) {
                    @synchronized (_dataArray) {
                        [_dataArray removeAllObjects];
                    }
                }
                [_dataArray addObjectsFromArray:arr];
                if (_dataArray.count >= _from + _cnt) {
                    _isLastPage = NO;
                }else{
                    _isLastPage = YES;
                }
                [_momentCollectionView reloadData];
                NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
                BOOL isThisAccountFirstComing = (BOOL)[defaluts objectForKey:[NSString stringWithFormat:@"%@firstComing",[[ViewModelCommom getCuttentUser] userID]]];
                if (!isThisAccountFirstComing) {
                    [self createMaskView];
                    [defaluts setBool:YES forKey:[NSString stringWithFormat:@"%@firstComing",[[ViewModelCommom getCuttentUser] userID]]];
                }
            }else {
                [self.tabViewController.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
            [self endRefesh];
        }];
    }
    
}


#pragma mark showAnimation

- (void)showFirstAnimation {
//    UIImageView *backView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstPage1"]];
//    backView1.frame = self.view.bounds;
//    backView1.tag = 30000;
//    [self.tabViewController.view addSubview:backView1];
//    UIImageView *backView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstPage2"]];
//    backView2.tag = 30001;
//    backView2.frame = self.view.bounds;
//
//    [self.tabViewController.view addSubview:backView2];
//    backView2.alpha = 0;
//    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        backView2.alpha = 1;
//    } completion:^(BOOL finished) {
//        if(finished){
//            [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                backView1.alpha = 0;
//                backView2.alpha = 0;
//            } completion:^(BOOL finished) {
//                if (finished) {
//                    [backView1 removeFromSuperview];
//                    [backView2 removeFromSuperview];
//                    //自动登录，登录成功，获取数据，登录失败，提示需要重新登录
//                    LonelyUser *user = [ViewModelCommom getCuttentUser];
//                    [UIUtil showHUD:self.tabViewController.view];
//                    [_loginVM login:user.userName andPwd:user.password andFlag:@"" andBlock:^(NSDictionary *dict, BOOL ret) {
//                        [UIUtil hideHUD:self.tabViewController.view];
//                        void (^backBlock)(void) = ^(){
//
//                        };
//
//                        if (dict) {
//                            if (ret && [[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
//                                [userInfoBtn yy_setImageWithURL:[NSURL URLWithString:[[ViewModelCommom getCuttentUser] file]] forState:UIControlStateNormal placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:[[ViewModelCommom getCuttentUser] gender]]]];
//
//                                _bridgeLabel.text = [NSString stringWithFormat:@"%@",user.unread];
//                                //登录成功，登录sip服务器
//                                AppDelegate *appDele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//                                [UIUtil showHUD:self.tabViewController.view];
//                                BOOL isOnline = [appDele.callViewController onLineAction:user.sipid displayName:user.sipid andAuthName:@"" andPassword:user.password  andDomain:@""  andSIPServer:user.sipHost andSIPServerPort:[user.sipPort intValue]];
//                                [UIUtil hideHUD:self.tabViewController.view];
//                                if (isOnline) {
//                                    //登录融云
//                                    [UIUtil showHUD:self.tabViewController.view];
//                                    [[RCIM sharedRCIM] connectWithToken:user.imtoken success:^(NSString *userId) {
//                                        [UIUtil hideHUD:self.tabViewController.view];
//
//                                        //设置用户信息提供者,页面展现的用户头像及昵称都会从此代理取
//                                        [[RCIM sharedRCIM] setUserInfoDataSource:self];
//                                        NSLog(@"Login successfully with userId: %@.", userId);
//                                        //登录成功，获取数据
//                                        [self loadData:YES];
//
//
//                                    } error:^(RCConnectErrorCode status) {
//                                        [UIUtil hideHUD:self.tabViewController.view];
//
//                                        NSLog(@"login error status: %ld.", (long)status);
//                                        backBlock();
//                                    } tokenIncorrect:^{
//                                        [UIUtil hideHUD:self.tabViewController.view];
//
//                                        NSLog(@"token 无效 ，请确保生成token 使用的appkey 和初始化时的appkey 一致");
//                                        backBlock();
//                                    }];
//
//                                }else {
//                                    backBlock();
//                                }
//                            }else {
//                                //登录失败，返回登录界面
//                                backBlock();
//                            }
//                        }else {
//                            //登录失败，返回登录界面
//                            backBlock();
//                        }
//                    }];
//
//
//                }
//            }];
//        }
//    }];
}


- (void)getUserInfoWithUserId:(NSString *)userId completion:(void(^)(RCUserInfo* userInfo))completion{
    [_mainViewVM getPersonalInfo:userId andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyStationUser *user = [[LonelyStationUser alloc] initWithDictory:dict[@"data"]];
                RCUserInfo *rcUser = [[RCUserInfo alloc]init];
                rcUser.userId = userId;
                rcUser.name = user.nickName;
                if ([user.file length] == 0) {
                    rcUser.portraitUri = user.file2;
                }else{
                    rcUser.portraitUri = user.file;
                }
                return completion(rcUser);
            }else {
                return completion(nil);
            }
        }else{
            return completion(nil);
        }
    }];
}


- (void)backToLogin {
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LoginViewController"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LoginViewController *loginVC = self.navigationController.viewControllers[i];
                [loginVC setDefaultInfo];
                loginVC.isHiddenAnimation = YES;
                [self.navigationController popToViewController:loginVC animated:YES];
            });
        }
    }
}

- (void)initViews {
    _from = 0;
    _cnt = 20;
    _dataArray = [NSMutableArray array];
    _mainViewVM = [[MainViewVM alloc] init];
    _loginVM = [[LoginViewModel alloc] init];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(0.f, 5, 9.f, 0);
    _momentCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - 64) collectionViewLayout:layout];
    _momentCollectionView.delegate = self;
    _momentCollectionView.dataSource =self;
    _momentCollectionView.alwaysBounceVertical = YES;
    _momentCollectionView.backgroundColor = [UIColor clearColor];
    _momentCollectionView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
    _momentCollectionView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];
    [self.view addSubview:_momentCollectionView];
    [_momentCollectionView registerClass:[MainCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)more:(UIButton*)sender {
    UIViewController *controller = [[UIViewController alloc] init];
    //注释掉语音传情
    //    controller.preferredContentSize = CGSizeMake(100, 139);
    controller.preferredContentSize = CGSizeMake(100, 94);
    controller.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = Rect(0, 0, 88, 44);
    EMButton *searchBtn = [[EMButton alloc] initWithFrame: frame isRdius:NO];
    [searchBtn setTitle:Local(@"AdvancedSearch") forState:UIControlStateNormal];
    [searchBtn.titleLabel setFont:ComFont(14)];
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn addTarget:self action:@selector(advancedSearchAction:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitleColor:RGB(128,128,128) forState:UIControlStateSelected];
    [searchBtn setTitleColor:RGB(0x03,0x29,0xac) forState:UIControlStateNormal];
    [controller.view addSubview:searchBtn];
    UIImageView *searchImgView = [[UIImageView alloc] initWithFrame:Rect(5, frame.origin.y+ (44-21)/2.f , 21, 21)];
    searchImgView.image = [UIImage imageNamed:@"BTmoreSearch"];
    [controller.view addSubview:searchImgView];
    EMView *line1 = [[EMView alloc] initWithFrame:Rect(11, 44, 80, 1)];
    line1.backgroundColor = RGB(3,41,172);
    [controller.view addSubview:line1];
    
    frame.origin.y = 45;
    EMButton *articleBtn = [[EMButton alloc] initWithFrame: frame isRdius:NO];
    [articleBtn addTarget:self action:@selector(lonelyArticleAction:) forControlEvents:UIControlEventTouchUpInside];
    [articleBtn setTitle:Local(@"ARTICLE") forState:UIControlStateNormal];
    articleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [articleBtn.titleLabel setFont:ComFont(14)];
    [articleBtn setTitleColor:RGB(128,128,128) forState:UIControlStateSelected];
    [articleBtn setTitleColor:RGB(0x03,0x29,0xac) forState:UIControlStateNormal];
    [controller.view addSubview:articleBtn];
    
    UIImageView *articleImgView = [[UIImageView alloc] initWithFrame:Rect(5, frame.origin.y+ (44-21)/2.f , 21, 21)];
    articleImgView.image = [UIImage imageNamed:@"BTmoreTopic"];
    [controller.view addSubview:articleImgView];
    popoverController = [[WYPopoverController alloc] initWithContentViewController:controller];
    popoverController.delegate = self;
    [popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

//进阶搜寻
- (void)advancedSearchAction:(EMButton*)btn {
    [popoverController dismissPopoverAnimated:YES];
    AdvancedSearchVC *advancedSearchVC = [[AdvancedSearchVC alloc] init];
    [self.navigationController pushViewController:advancedSearchVC animated:YES];
}

//语音传情
- (void)voiceEmotionAction:(EMButton*)btn {
    [popoverController dismissPopoverAnimated:YES];
    VoiceEmotionVC *advancedSearchVC = [[VoiceEmotionVC alloc] init];
    [self.navigationController pushViewController:advancedSearchVC animated:YES];
}

//寂寞话题
- (void)lonelyArticleAction:(EMButton*)btn {
    [popoverController dismissPopoverAnimated:YES];
    LonelyActicleVC *advancedSearchVC = [[LonelyActicleVC alloc] init];
    [self.navigationController pushViewController:advancedSearchVC animated:YES];
}



- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    popoverController.delegate = nil;
    popoverController = nil;
}

- (void)userInfo:(id)sender {
    [self.tabViewController sliderLeftController];
}


- (void)test:(id)sender {
    UserInfoViewController *userInfo = [[UserInfoViewController alloc] init];
    userInfo.isHiddenNavigationBar = NO;
    [userInfo setHidesBottomBarWhenPushed:YES];//加上这句就可以把推出的ViewController
    [self.navigationController pushViewController:userInfo animated:YES];
}

- (void)MyCare:(id)sender {
    [popoverController dismissPopoverAnimated:YES];
    MyFocousVC *record = [[MyFocousVC alloc] init];
    [self.navigationController pushViewController:record animated:YES];
}


- (void)MyAir:(id)sender {
    [popoverController dismissPopoverAnimated:YES];
    MyRecordsViewController *record = [[MyRecordsViewController alloc] init];
    [self.navigationController pushViewController:record animated:YES];
}


#pragma mark UICollection dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}



//cell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //去掉原来的imageArray
    if (_currentImageArray) {
        [_currentImageArray removeAllObjects];
    }
    if (_dataArray) {
        @synchronized (_dataArray) {
            return _dataArray.count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    LonelyStationUser *lonelyUser = _dataArray[indexPath.row];
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    NSString *file = lonelyUser.file;
    if (file == nil || file.length == 0) {
        file = lonelyUser.file2;
        if (file == nil || file.length == 0) {
            file = @"";
        }
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [cell.imageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (lonelyUser.seenTime.length > 0){
            [cell.imageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]]];
        }else{
            [cell setBlurPhoto:YES];
        }
    }];
    cell.status = lonelyUser.isOnLine;
    cell.roleAndNickLable.text = [NSString stringWithFormat:@"%@:%@/%@",lonelyUser.identityName,lonelyUser.nickName,lonelyUser.city];
    cell.talkBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [cell setTalkAction:@selector(talkAction:) andTarget:self];
    cell.listenBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [cell setListenAction:@selector(listenAction:) andTarget:self];
    
    cell.listenSelfBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [cell setListenSelfAction:@selector(listenSelfAction:) andTarget:self];
    
    cell.personalDesLabel.text = [lonelyUser.slogan isEqualToString:@""]?Local(@"HaveNoSlogan"):lonelyUser.slogan;
    
    if ([lonelyUser.identity isEqualToString:@"2"]) {
        if (lonelyUser.isOnLine && [lonelyUser.connectStat isEqualToString:@"N"]) {
            cell.status = StationLoverOnline;
        }else if (lonelyUser.isOnLine && ![lonelyUser.connectStat isEqualToString:@"N"]){
            cell.status = StationStatusBusy;
        }else {
            cell.status = StationStatusOffline;
        }
    }else {
        if (lonelyUser.isOnLine && [lonelyUser.connectStat isEqualToString:@"N"]) {
            cell.status = StationStatusOnline;
        }else if (lonelyUser.isOnLine && ![lonelyUser.connectStat isEqualToString:@"N"]){
            cell.status = StationStatusBusy;
        }else {
            cell.status = StationStatusOffline;
        }
    }
    
    //判断是否有自介，有的话就能点，没有就不能点
    if (lonelyUser.voice.length == 0) {
        [cell.listenSelfBtn setEnabled:NO];
    }else {
        [cell.listenSelfBtn setEnabled:YES];
    }
    
    
    //如果msgCharge为Y,设置为红色
    if([@"Y" isEqualToString:lonelyUser.msgCharge]) {
        [cell.listenBtn setImage:[UIImage imageNamed:@"SBTChat_pay"] forState:UIControlStateNormal];
    }else {
        [cell.listenBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateNormal];
    }
    //判断广播数量是否为0，为0就不能点
    //    if (lonelyUser.recordsSum.intValue == 0) {
    //        [cell.listenBtn setEnabled:NO];
    //    }else {
    //        [cell.listenBtn setEnabled:YES];
    //    }
    
    //判断是否离线，离线的话就不能点，如果在线但接听时间不在允许范围之内，不能接，弹出相应的提示，只有在线而且接听时间在允许范围之内，才能接
    //        如果online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’N’，   紅框處顯示亮的話筒。
    //        如果 online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’Y’，紅框處顯示暗的話筒。
    //        如果 online=’Y’，identity=’1’ or ‘2’，不管OpStat和ConnectStat，紅框處一律顯示暗的話筒。
    //        如果online=’N’，紅框處一律都顯示暗的話筒。
    if ([lonelyUser.allowTalk intValue] == 1) {
        if (lonelyUser.isOnLine && [lonelyUser.identity isEqualToString:@"3"] && [lonelyUser.optState isEqualToString:@"Y"] && [lonelyUser.connectStat isEqualToString:@"N"]) {
            [cell.talkBtn setEnabled:YES];
            //如果talkcharge为Y,设置为红色
            if([@"Y" isEqualToString:lonelyUser.talkCharge]) {
                [cell.talkBtn setImage:[UIImage imageNamed:@"SBTCall_pag"] forState:UIControlStateNormal];
            }else {
                [cell.talkBtn setImage:[UIImage imageNamed:@"SBTcall"] forState:UIControlStateNormal];
            }
        }else {
            [cell.talkBtn setEnabled:NO];
        }
    }else {
        [cell.talkBtn setEnabled:NO];
    }
    return cell;
}


- (void)talkAction:(EMButton*)sender {
    if (![UIUtil checkLogin]) {
        return;
    }
    
    int row = [sender.titStr intValue];
    LonelyStationUser *lonelyUser = _dataArray[row];
    if (lonelyUser.allowTalkPeriod.length > 0) {
        NSArray *allowTalkArr = [lonelyUser.allowTalkPeriod componentsSeparatedByString:@"-"];
        if (allowTalkArr.count == 2) {
            NSString *startTime = allowTalkArr[0];
            NSString *endTime = allowTalkArr[1];
            if (![EMUtil isBetweenDate:startTime andDate:endTime]) {
                //如果不在这个范围内，不能打电话
                AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"NotAllowed") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                    
                } cancelButtonTitle:Local(@"IKnowRecordIsTooShort") otherButtonTitles:nil];
                [alert show];
                alert = nil;
                return;
            }
        }
    }
    
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    //获取我剩余的时间劵
    [_mainViewVM  getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict) {
            if ([dict[@"code"] intValue] == 1) {
                user.talkSecond = dict[@"data"][@"talk_second"];
                user.radioSecond = dict[@"data"][@"radio_second"];
                user.vipStartSecond = dict[@"data"][@"vip_start_time"];
                user.vipEndSecond = dict[@"data"][@"vip_end_time"];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                //判断还有多少时长，只有大于0的时候才能去打电话
                [EMUtil chatCallUser:lonelyUser andController:self];
            }else{
                [self.view.window makeToast:dict[@"msg"] duration:3 position:[CSToastManager defaultPosition]];
            }
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:3 position:[CSToastManager defaultPosition]];
            
        }
    }];
    
    
    
}


- (void)listenAction:(EMButton*)sender {
    if (![UIUtil checkLogin]) {
        return;
    }
    int row = [sender.titStr intValue];
    LonelyStationUser *lonelyUser = _dataArray[row];
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

- (void)didBuffering:(double)recievedLength andAllLength:(double)allLength andBufferRatio:(double)bufferingRatio andBufferSpeed:(double)downloadSpeed {
    
}

- (void)didPlayingCurrentTime:(double)currentTime andAllTime:(double)allTime{
    if (currentTime > 4.5) {
        if (_playIndex >= 0){
            LonelyStationUser *lonelyUser = _dataArray[_playIndex];
            if (lonelyUser.seenTime && lonelyUser.seenTime.length == 0) {
                [_mainViewVM getRecordEvenSeen:lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
                    if ([dict[@"code"] intValue] == 1) {
                        lonelyUser.seenTime = [EMUtil GetCurrentTime];
                        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:_playIndex inSection:0];
                        [_momentCollectionView reloadItemsAtIndexPaths:@[indexpath]];
                    }
                }];
            }
        }
        
        
    }
}

- (void)didPlayFinished {
    if (_playIndex >= 0){
        LonelyStationUser *lonelyUser = _dataArray[_playIndex];
        if (lonelyUser.seenTime && lonelyUser.seenTime.length == 0) {
            [_mainViewVM getRecordEvenSeen:lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
                if ([dict[@"code"] intValue] == 1) {
                    lonelyUser.seenTime = [EMUtil GetCurrentTime];
                    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:_playIndex inSection:0];
                    [_momentCollectionView reloadItemsAtIndexPaths:@[indexpath]];
                }
            }];
        }
    }
}




- (void)listenSelfAction:(EMButton*)sender {
    if (![UIUtil checkLogin]) {
        return;
    }
    //判断自己是否有voice，没有提示去录制
    LonelyUser *user = [ViewModelCommom  getCuttentUser];
    if (user.voice == nil || [user.voice isEqualToString:@""]) {
        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"TheyIntroduceThem") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                RecordIntroduceVC *voices = [[RecordIntroduceVC alloc] init];
                voices.seq = 1;
                [self.navigationController pushViewController:voices animated:YES];
            }
        } cancelButtonTitle:Local(@"NextTime") otherButtonTitles:Local(@"GoToRecord"), nil];
        [alert show];
        alert = nil;
    }else {
        int row = [sender.titStr intValue];
        LonelyStationUser *lonelyUser = _dataArray[row];
        douAudioPlayer.delegate = self;
        if (_playIndex == row) {
            
        }else{
            _playIndex = row;
            selectedRiceBtn = nil;
            douAudioPlayer.currentValue = 0;
        }
        if (selectedRiceBtn != sender) {
            if (!selectedRiceBtn) {
                selectedRiceBtn = sender;
            }else{
                selectedRiceBtn.selected = NO;
            }
            sender.selected = !sender.selected;
            selectedRiceBtn = sender;
        }else{
            selectedRiceBtn = nil;
            sender.selected = !sender.selected;
        }
        if (sender.selected) {
            douAudioPlayer.allTime = [lonelyUser.voiceDurion intValue];
            [douAudioPlayer startPlayTime:douAudioPlayer.currentValue andURL:lonelyUser.voice];
            //点击了，播放进度为0而且播放的时候就发推送
            if (douAudioPlayer.currentValue == 0) {
                [_mainViewVM getRecordEvenSeen:lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
                }];
            }
        }else {
            if (douAudioPlayer.isPlayFinish) {
                sender.selected = YES;
                [douAudioPlayer startPlayTime:douAudioPlayer.currentValue andURL:lonelyUser.voice];
            }else {
                [douAudioPlayer pause];
            }
        }
        
        
    }
}

- (void)shouldLoadData {
    [self loadData:YES];
}

- (void)shouldReload:(LonelyStationUser*)aLoneyUser {
    LonelyStationUser *lonelyUser = _dataArray[selectItemIndex];
    lonelyUser.seenTime = [EMUtil GetCurrentTime];
    lonelyUser.allowTalk = aLoneyUser.allowTalk;
    lonelyUser.isOnLine = aLoneyUser.isOnLine;
    lonelyUser.identity = aLoneyUser.identity;
    lonelyUser.identityName = aLoneyUser.identityName;
    lonelyUser.connectStat = aLoneyUser.connectStat;
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:selectItemIndex inSection:0];
    [_momentCollectionView reloadItemsAtIndexPaths:@[indexpath]];
    if (lonelyUser.seenTime && lonelyUser.seenTime.length == 0) {
        [_mainViewVM getRecordEvenSeen:lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
            if ([dict[@"code"] intValue] == 1) {
                lonelyUser.seenTime = [EMUtil GetCurrentTime];
                NSIndexPath *indexpath = [NSIndexPath indexPathForItem:selectItemIndex inSection:0];
                [_momentCollectionView reloadItemsAtIndexPaths:@[indexpath]];
            }
        }];
    }
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LonelyStationUser *lonelyUser = _dataArray[indexPath.row];
    selectItemIndex = (int)indexPath.row;
    PersonalDetailInfoOldVC *personalVC = [[PersonalDetailInfoOldVC alloc] init];
    personalVC.lonelyUser = lonelyUser;
    personalVC.delegate = self;
    [self.navigationController pushViewController:personalVC animated:YES];
}

#pragma mark -- UICollectionViewDelegate
//设置每个 UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (iphone4x_3_5) {
        return CGSizeMake((self.view.frame.size.width-3)/2, self.view.frame.size.height/3 + 30);
    }else {
        return CGSizeMake((self.view.frame.size.width-3)/2, self.view.frame.size.height/3);
    }
}
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 10,0);
}

//定义每个UICollectionView 的纵向间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}


-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
    
}
@end
