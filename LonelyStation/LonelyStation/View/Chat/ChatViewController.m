//
//  ChatViewController.m
//  RongCloudDemo
//
//  Created by zk on 2016/10/21.
//  Copyright © 2016年 dlz. All rights reserved.
//
#import "ChatViewController.h"
#import "MJChatBarToolView.h"
#import "ChatMiddleView.h"
#import "IQKeyboardManager.h"
#import "AppDelegate.h"
#import "EMAlertView.h"
#import "ViewModelCommom.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "CameraSessionViewController.h"
#import "PECropViewController.h"
#import "EMActionSheet.h"
#import "UserViewModel.h"
#import "WYPopoverController.h"
#import "ExtAudioConverter.h"
#import "AddMoneyMainVC.h"
#import "GTMBase64.h"
#import "PersonalDetailInfoVC.h"
#import "PersonalDetailInfoOldVC.h"

static void *kFrameKVOKey = &kFrameKVOKey;

@interface ChatViewController ()<MJChatBarToolViewDelegate,ChatMiddleViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CameraSessionViewControllerDelegate,PECropViewControllerDelegate,WYPopoverControllerDelegate,UITextViewDelegate,PersonalDetailInfoVCDelegate,PersonalDetailInfoOldVCDelegate>{
    EMLabel *titleLabel;
    MainViewVM *_mainViewVM;
    UserViewModel *_userViewModel;
    NSMutableArray *_dataArray;
    WYPopoverController *popoverController;
    
    //检举区域
    EMButton *_maskBtnView;
    EMLabel *_reportLabel;
    EMView *_reportView;
    UITextView *_reportTextView;
    EMButton *_cancelReportBtn;
    EMButton *_sendReportBtn;
    
    UIViewController *_reportViewController;
}

@property(nonatomic,strong)MJChatBarToolView *chatBarToolView;
@property(nonatomic,copy)NSString *currentMsgCharge;
@property(nonatomic,copy)NSString *currentTalkCharge;

@end

@implementation ChatViewController

- (void)didClickMain {
    [_chatBarToolView cancleInputState];
}

- (void)didTapCellPortrait:(NSString *)userId {
//    PersonalDetailInfoVC *personalVC = [[PersonalDetailInfoVC alloc] init];
//    personalVC.lonelyUser = _lonelyUser;
//    personalVC.delegate = self;
//    [self.navigationController pushViewController:personalVC animated:YES];
    LonelyStationUser *lonelyUser = _lonelyUser;
    PersonalDetailInfoOldVC *personalVC = [[PersonalDetailInfoOldVC alloc] init];
    personalVC.lonelyUser = lonelyUser;
    personalVC.delegate = self;
    [self.navigationController pushViewController:personalVC animated:YES];
}

- (void)shouldReload:(LonelyStationUser*)aLoneyUser {
    
}


- (void)viewDidLoad {
    //设置圆形头像
        [super viewDidLoad];
        //设置自己的用户信息
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        
        RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:user.userID name:user.nickName portrait:user.file];
        [[RCIM sharedRCIM] setCurrentUserInfo:userInfo];
    

    self.chatSessionInputBarControl.alpha = 0;
    [self.chatSessionInputBarControl removeFromSuperview];
    //监听下chatSessionInputBarControl的高度变化
    UIScrollView *scroll = [self getScrollView];
    [scroll addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:kFrameKVOKey];
    // Do any additional setup after loading the view.
    self.fd_interactivePopDisabled = YES;
    
    
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
//    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
//    [self.view addSubview:backgroundImageView];
    [self.conversationMessageCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view bringSubviewToFront:self.conversationMessageCollectionView];
    [self.conversationMessageCollectionView setFrame:Rect(0, 64, kScreenW, kScreenH-64-self.chatSessionInputBarControl.frame.size.height)];
    // 设置导航栏
    
    ChatMiddleView *middleView = [[ChatMiddleView alloc] initWithFrame:self.view.bounds];
    middleView.delegate = self;
    [self.view addSubview:middleView];
    
    [self setupNav];
    _chatBarToolView = [[MJChatBarToolView alloc] init];
    _chatBarToolView.frame = (CGRect){0,GJCFSystemScreenHeight - _chatBarToolView.barToolHeight + EMOJIHEIGHT,GJCFSystemScreenWidth,_chatBarToolView.barToolHeight};
    _chatBarToolView.delegate = self;
    [self.view addSubview:_chatBarToolView];
    
    [_chatBarToolView changeAudioType];
    
    _mainViewVM = [[MainViewVM alloc] init];
    
    [UIUtil showHUD:self.view];
  
    
    
    //获取user信息
    WS(weakSelf)
    [_mainViewVM getPersonalInfo:self.targetId andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyStationUser *user = [[LonelyStationUser alloc] initWithDictory:dict[@"data"]];
                weakSelf.lonelyUser = user;
                weakSelf.currentMsgCharge = user.msgCharge;
                weakSelf.currentTalkCharge = user.talkCharge;
                dispatch_async(dispatch_get_main_queue(), ^{
                    titleLabel.text = weakSelf.lonelyUser.nickName;
                    [self.conversationMessageCollectionView reloadData];
                });
                user = nil;
                if ([weakSelf.lonelyUser.allowTalk intValue] == 1) {
                    if (weakSelf.lonelyUser.isOnLine && [weakSelf.lonelyUser.identity isEqualToString:@"3"] && [weakSelf.lonelyUser.optState isEqualToString:@"Y"] && [weakSelf.lonelyUser.connectStat isEqualToString:@"N"]) {
                        [_chatBarToolView setCallEnable:YES];
                        if ([@"Y" isEqualToString: weakSelf.lonelyUser.talkCharge]) {
                            [_chatBarToolView changeCallImage:YES];
                        }else {
                            [_chatBarToolView changeCallImage:NO];
                        }
                    }else {
                        [_chatBarToolView setCallEnable:NO];
                    }
                }else {
                    [_chatBarToolView setCallEnable:NO];
                }
            }
        }
        //获取自己的状态
        [self getMyTime];
    }];
    
    _userViewModel = [[UserViewModel alloc] init];
    _dataArray = [NSMutableArray array];
    [_userViewModel getMyVoicesWithBlock:^(NSArray *array, BOOL ret) {
        if (array && ret) {
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:array];
            _chatBarToolView.fileArray = _dataArray;
        }
    }];
    
    //检举区域
    _reportViewController = [[UIViewController alloc] init];
    _reportViewController.view.frame = self.view.bounds;
    _reportViewController.view.backgroundColor = [UIColor whiteColor];
    _maskBtnView = [[EMButton alloc] initWithFrame:Rect(0, 0, ScreenWidth, ScreenHeight)];
    _maskBtnView.alpha = 0;
    _maskBtnView.backgroundColor = RGBA(0, 0, 0,0.6);
    [_maskBtnView addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [_reportViewController.view addSubview:_maskBtnView];
    
    
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
    
}


//显示检举的view
- (void)showReportAction:(EMButton*)btn {
    [popoverController dismissPopoverAnimated:YES];
    [self presentViewController:_reportViewController animated:YES completion:^{
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _maskBtnView.alpha = 1;
            CGFloat height = 209*kScale;
            CGFloat y = (kScreenH - height)/2.f-100;
            _reportView.frame = Rect(0, y, kScreenW, height);
            _reportLabel.alpha = 1;
            _reportTextView.alpha = 1;
            [_reportTextView becomeFirstResponder];
            _cancelReportBtn.alpha = 1;
            _sendReportBtn.alpha = 1;
            
        } completion:NULL];
    }];
    
}





//隐藏检举
- (void)hiddenMask:(EMButton*)btn {
    [self.view endEditing:YES];
    [_reportViewController dismissViewControllerAnimated:NO completion:^{
        _reportLabel.alpha = 0;
        _reportTextView.alpha = 0;
        _cancelReportBtn.alpha = 0;
        _sendReportBtn.alpha = 0;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _maskBtnView.alpha = 0;
            CGRect frame = _maskBtnView.frame;
            _reportView.frame = Rect(frame.size.width/2, frame.size.height/2, 0, 0);
            [_chatBarToolView cancleInputState];
        } completion:NULL];
    }];
    
}


//送出检举的事件
- (void)reportAction:(EMButton*)btn {
    NSString *str = _reportTextView.text;
    [_reportTextView resignFirstResponder];
    if ([str isEqualToString:Local(@"PlsInputWords3to50")]) {
        str = @"";
    }
    [self.view endEditing:YES];
    if (str.length >= 3 && str.length <= 50) {
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


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return AppBarStyle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];
    [self setNeedsStatusBarAppearanceUpdate];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    
}

- (void) viewWillDisappear: (BOOL)animated {
    
    //关闭键盘事件相应
//    [super viewWillDisappear:animated];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
}

- (void)setupNav {
    // 设置返回按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:Rect(11, 20, 40, 40)];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    titleLabel = [[EMLabel alloc] initWithFrame:Rect(55, 20, kScreenW - 110, 44)];
    titleLabel.text = self.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = RGB(0x51, 0x51, 0x51);
    titleLabel.font = ComFont(19);
    [self.view addSubview:titleLabel];
    
    EMButton *moreBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 40 - 15 , 20, 40, 40)];
    [moreBtn setImage:[UIImage imageNamed:@"BTmore"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreBtn];
    moreBtn = nil;
}


- (void)more:(UIButton*)sender {
    UIViewController *controller = [[UIViewController alloc] init];
    controller.preferredContentSize = CGSizeMake(100, 183);
    controller.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = Rect(13, 0, 84, 44);
    
    EMButton *careBtn = [self createBtnWithFrame:frame andSelector:@selector(careAction:) andTitle:Local(@"Care") andNomalTitleColor:RGB(145,90,173) andSelectTitleColor:RGB(128,128,128) andFont:ComFont(14) andNomalImage:@"chat_attention" andSelectImage:@"chat_attention_d"];
    [controller.view addSubview:careBtn];
    
    //判断是否关注
    if (_lonelyUser.favoriteTime && _lonelyUser.favoriteTime.length > 0) {
        careBtn.selected = YES;
    }else {
        careBtn.selected = NO;
    }
    [self updateBtnEdge:careBtn];

    
    [UIUtil addLineWithSuperView:controller.view andRect:Rect(11, 44, 78, 1) andColor:RGB(145,90,173)];
    
    frame.origin.y = 45;
    
    EMButton *reportBtn = [self createBtnWithFrame:frame andSelector:@selector(showReportAction:) andTitle:Local(@"Report") andNomalTitleColor:RGB(145,90,173) andSelectTitleColor:RGB(128,128,128) andFont:ComFont(14) andNomalImage:@"chat_report" andSelectImage:@"chat_report_d"];
    [controller.view addSubview:reportBtn];
    
    
    
    [UIUtil addLineWithSuperView:controller.view andRect:Rect(11, 88, 78, 1) andColor:RGB(145,90,173)];
    frame.origin.y = 89;
    
    EMButton *lockBtn = [self createBtnWithFrame:frame andSelector:@selector(lockAction:) andTitle:Local(@"Lock") andNomalTitleColor:RGB(145,90,173) andSelectTitleColor:RGB(128,128,128) andFont:ComFont(14) andNomalImage:@"chat_blockade" andSelectImage:@"chat_blockade_d"];
    [controller.view addSubview:lockBtn];
    
    //判断是否封锁
    if (_lonelyUser.blockByMeTime && _lonelyUser.blockByMeTime.length > 0) {
        lockBtn.selected = YES;
    }else {
        lockBtn.selected = NO;
    }
    [self updateBtnEdge:lockBtn];

    
    [UIUtil addLineWithSuperView:controller.view andRect:Rect(11, 132, 78, 1) andColor:RGB(145,90,173)];
    
    
    frame.origin.y = 133;
    
    EMButton *authBtn = [self createBtnWithFrame:frame andSelector:@selector(authAction:) andTitle:Local(@"Auth") andNomalTitleColor:RGB(145,90,173) andSelectTitleColor:RGB(128,128,128) andFont:ComFont(14) andNomalImage:@"chat_authorize" andSelectImage:@"chat_authorize_d"];
    [controller.view addSubview:authBtn];
    
    //判断是否授权
    if (_lonelyUser.authBymeTime && _lonelyUser.authBymeTime.length > 0) {
        authBtn.selected = YES;
    }else {
        authBtn.selected = NO;
    }
    
    [self updateBtnEdge:authBtn];

    
    popoverController = [[WYPopoverController alloc] initWithContentViewController:controller];
    popoverController.delegate = self;
    [popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

- (void)updateBtnEdge:(UIButton*)btn {
    if(btn.selected) {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    }else{
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    }
}

- (void)authAction:(EMButton*)btn {
    if (btn.selected) {
        [self.navigationController.view makeToast:Local(@"CancelAuthMustGoMyAccount") duration:1 position:[CSToastManager defaultPosition]];
        return;
    }
    btn.selected = !btn.selected;
    WS(weakSelf);
    [UIUtil showHUD:self.navigationController.view];
    [_mainViewVM setAuthUser:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:weakSelf.navigationController.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                weakSelf.lonelyUser.authBymeTime = @"1";
                [weakSelf.navigationController.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
            }else {
                btn.selected = NO;
                [weakSelf.navigationController.view  makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
            }
        }else {
            btn.selected = NO;
            [weakSelf.navigationController.view makeToast:Local(@"HandleFailed") duration:1 position:[CSToastManager defaultPosition]];
        }
    }];
    [self updateBtnEdge:btn];
    
}

- (void)careAction:(EMButton*)btn {
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
                    weakSelf.lonelyUser.favoriteTime = @"1";
                    [weakSelf.navigationController.view makeToast:Local(@"CareSuccess") duration:1 position:[CSToastManager defaultPosition]];
//                    RCInformationNotificationMessage *msg = [RCInformationNotificationMessage notificationWithMessage:Local(@"CareSuccess") extra:@""];
//                    [weakSelf sendMessage:msg pushContent:nil];
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
                    weakSelf.lonelyUser.favoriteTime = @"";
                    [weakSelf.navigationController.view makeToast:Local(@"CareCancelSuccess") duration:1 position:[CSToastManager defaultPosition]];
//                    RCInformationNotificationMessage *msg = [RCInformationNotificationMessage notificationWithMessage:Local(@"CareCancelSuccess") extra:@""];
//                    [weakSelf sendMessage:msg pushContent:nil];
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
    
    [self updateBtnEdge:btn];

}


- (void)lockAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    WS(weakSelf);
    if (btn.selected) {
        //封锁
        [UIUtil showHUD:self.navigationController.view];
        [_mainViewVM addlock:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:self.navigationController.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    weakSelf.lonelyUser.blockByMeTime = @"1";
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
    }else{
        //取消封锁
        [UIUtil showHUD:self.navigationController.view];
        [_mainViewVM deleteLock:_lonelyUser.userID andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:weakSelf.navigationController.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    weakSelf.lonelyUser.blockByMeTime = @"";
                    [weakSelf.navigationController.view makeToast:dict[@"msg"] duration:1 position:[CSToastManager defaultPosition]];
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
    [self updateBtnEdge:btn];

}



- (EMButton*)createBtnWithFrame:(CGRect)frame andSelector:(SEL)selector andTitle:(NSString*)title andNomalTitleColor:(UIColor*)nomalColor andSelectTitleColor:(UIColor*)selectColor andFont:(UIFont*)font andNomalImage:(NSString*)nomalImg andSelectImage:(NSString*)selectImg{
    EMButton *retBtn = [[EMButton alloc] initWithFrame: frame isRdius:NO];
    [retBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [retBtn setTitle:title forState:UIControlStateNormal];
    [retBtn setTitle:[NSString stringWithFormat:@"已%@",title] forState:UIControlStateSelected];
    [retBtn.titleLabel setFont:font];
    [retBtn setImage:[UIImage imageNamed:nomalImg] forState:UIControlStateNormal];
    [retBtn setImage:[UIImage imageNamed:selectImg] forState:UIControlStateSelected];
    [retBtn setTitleColor:selectColor forState:UIControlStateSelected];
    [retBtn setTitleColor:nomalColor forState:UIControlStateNormal];
    [retBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    return retBtn;
}


- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    popoverController.delegate = nil;
    popoverController = nil;
}





- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//发送系统消息
- (void)testSendTipMsg {
    RCInformationNotificationMessage *msg = [RCInformationNotificationMessage notificationWithMessage:@"我靠萨达 dasd" extra:@""];
    [self sendMessage:msg pushContent:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //    if (context == kFrameKVOKey) {
    //        UIScrollView *scroll = [self getScrollView];
    //        if (scroll.frame.size.height == GJCFSystemScreenHeight - 64 - 50) {
    //            [self.view endEditing:YES];
    //        }
    //    }
}

- (void)dealloc {
    UIScrollView *scroll = [self getScrollView];
    [scroll removeObserver:self forKeyPath:@"frame"];
}



- (UIScrollView*)getScrollView {
    return self.conversationMessageCollectionView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell
                   atIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = cell.model;
    model.isDisplayNickname = NO;
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSLog(@"cell===%@",cell);
    //判断是不是自己，是自己，改到最左边，不是，改到最右边
    if (![cell isKindOfClass:[RCTipMessageCell class]]) {
        UIImageView *headImgView = [cell valueForKey:@"_portraitImageView"];
        if (![self.targetId isEqualToString:model.userInfo.userId]) {
            //是自己
            NSString *path = [EMUtil getHeaderDefaultImgName:user.gender];
            model.userInfo.portraitUri = user.getRealFile?user.getRealFile:path;
            [headImgView setValue:[NSURL URLWithString:user.getRealFile] forKey:@"imageURL"];
            [headImgView setValue:[UIImage imageNamed:path] forKey:@"placeholderImage"];
            headImgView.hidden = YES;
            RCContentView *view = [cell valueForKey:@"_messageContentView"];
//            NSLog(@"view====%@",view);
            [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-11);
                make.height.mas_equalTo(view.frame.size.height);
                make.width.mas_equalTo(view.frame.size.width);
                make.top.mas_equalTo(11);
            }];
            [view setNeedsLayout];
            NSLog(@"view222====%@",view);

        }else {
            //别人
            NSString *path = [EMUtil getHeaderDefaultImgNameSelfGender:user.gender];
            model.userInfo.portraitUri = _lonelyUser.getRealFile?:path;
            [headImgView setValue:[NSURL URLWithString:_lonelyUser.getRealFile] forKey:@"imageURL"];
            [headImgView setValue:[UIImage imageNamed:path] forKey:@"placeholderImage"];
            headImgView.hidden = NO;
            RCContentView *view = [cell valueForKey:@"_messageContentView"];
            [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(55);
                make.height.mas_equalTo(view.frame.size.height);
                make.width.mas_equalTo(view.frame.size.width);
                make.top.mas_equalTo(11);
            }];
            [view setNeedsLayout];
        }
    }
 
    [cell setDataModel:model];
    
    if ([cell isKindOfClass:[RCVoiceMessageCell class]]) {
        RCVoiceMessageCell *voiceCell = (RCVoiceMessageCell*)cell;
        voiceCell.messageTimeLabel.textColor = RGB(51, 51, 51);
        voiceCell.messageTimeLabel.layer.cornerRadius = 10;
        //判断是不是mp3
        RCVoiceMessage *msg = (RCVoiceMessage*)model.content;
        if (![msg.extra isEqualToString:@"wav"]) {
            //转换成wav
            NSString *amrDataStr = [msg valueForKey:@"_amrBase64Content"];
            NSData *data = [GTMBase64 decodeData:[amrDataStr dataUsingEncoding:NSUTF8StringEncoding]];
            //保存到沙盒
            NSMutableString *newPath = [NSMutableString string];
            [newPath appendFormat:@"%@/%@.amr",[[self class] cachesDirectoryPath],model.messageUId];
            
            NSString *newOutPutPath = [newPath stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
            //如果不存在wav
            if (![[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
                NSError *error;
                BOOL success = [data writeToFile:newPath options:0 error:&error];
                if (!success) {
                    NSLog(@"writeToFile failed with error %@", error);
                }
                //转换mp3成wav
                ExtAudioConverter* converter = [[ExtAudioConverter alloc] init];
                converter.inputFile =  newPath;
                converter.outputFile = newOutPutPath;
                converter.outputSampleRate = 8000;
                converter.outputNumberChannels = 1;
                converter.outputBitDepth = BitDepth_16;
                converter.outputFormatID = kAudioFormatLinearPCM;
                converter.outputFileType = kAudioFileWAVEType;
                [converter convert];
            }
            NSData *fileData = [NSData dataWithContentsOfFile:newOutPutPath];
            msg.wavAudioData = fileData;
            model.content = msg;
            [cell setDataModel:model];
        }
        
        
        CGRect frame = voiceCell.playVoiceView.frame;
        //判断是不是自己，是自己，改到最左边，不是，改到最右边
        if (![self.targetId isEqualToString:model.userInfo.userId]) {
            voiceCell.voiceDurationLabel.center =  Point(voiceCell.bubbleBackgroundView.center.x-5, voiceCell.bubbleBackgroundView.center.y) ;
            frame.origin.x = voiceCell.bubbleBackgroundView.frame.origin.x + voiceCell.bubbleBackgroundView.frame.size.width - frame.size.width - 7;
        }else {
            voiceCell.voiceDurationLabel.center =  Point(voiceCell.bubbleBackgroundView.center.x - 5, voiceCell.bubbleBackgroundView.center.y) ;
            CGRect unreadFrame = voiceCell.voiceUnreadTagView.frame;
            unreadFrame.origin.y = frame.origin.y - unreadFrame.size.height - 2;
            voiceCell.voiceUnreadTagView.frame = unreadFrame;
            frame.origin.x = voiceCell.bubbleBackgroundView.frame.origin.x + voiceCell.bubbleBackgroundView.frame.size.width- frame.size.width - 4;
        }
        voiceCell.voiceDurationLabel.textAlignment = NSTextAlignmentCenter;
        voiceCell.playVoiceView.frame = frame;
    }else if([cell isKindOfClass:[RCTipMessageCell class]]) {
        RCTipMessageCell *tipCell = (RCTipMessageCell*)cell;
        RCInformationNotificationMessage *msg = (RCInformationNotificationMessage*)model.content;
        NSString *msgStr = msg.message;
        NSLog(@"msg===%@",msg.message);
        if (![model.senderUserId isEqualToString:self.targetId]) {
            if ([msg.message isEqualToString:@"msg_type_gift_3"]) {
                msgStr = Local(@"Send3MinYouHeart");
            }else if ([msg.message isEqualToString:@"msg_type_gift_5"]){
                msgStr = Local(@"Send5MinYouHeart");
            }else if ([msg.message isEqualToString:@"msg_type_gift_10"]){
                msgStr = Local(@"Send10MinYouHeart");
            }else if ([msg.message isEqualToString:@"msg_type_gift_20"]){
                msgStr = Local(@"Send20MinYouHeart");
            }else if ([msg.message isEqualToString:@"msg_type_gift_50"]){
                msgStr = Local(@"Send50MinYouHeart");
            }
        }else {
            if ([msg.message isEqualToString:@"msg_type_gift_3"]) {
                msgStr = Local(@"Get3MinYouHeart");
                [self addImgView:tipCell];
            }else if ([msg.message isEqualToString:@"msg_type_gift_5"]){
                msgStr = Local(@"Get5MinYouHeart");
                [self addImgView:tipCell];
            }else if ([msg.message isEqualToString:@"msg_type_gift_10"]){
                msgStr = Local(@"Get10MinYouHeart");
                [self addImgView:tipCell];
            }else if ([msg.message isEqualToString:@"msg_type_gift_20"]){
                msgStr = Local(@"Get20MinYouHeart");
                [self addImgView:tipCell];
            }else if ([msg.message isEqualToString:@"msg_type_gift_50"]){
                msgStr = Local(@"Get50MinYouHeart");
                [self addImgView:tipCell];
            }
            
            
        }
        tipCell.tipMessageLabel.text = msgStr;
        CGSize sizeName = [msgStr sizeWithFont:tipCell.tipMessageLabel.font
                             constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        tipCell.tipMessageLabel.textColor = RGB(51, 51, 51);
        tipCell.messageTimeLabel.textColor = RGB(51, 51, 51);
        tipCell.messageTimeLabel.layer.cornerRadius = 10;
        tipCell.tipMessageLabel.layer.cornerRadius = 10;
        CGRect frame = tipCell.tipMessageLabel.frame;
        frame.size.width = sizeName.width + 10;
        frame.origin.x = (kScreenW-sizeName.width)/2.f;
        tipCell.tipMessageLabel.frame = frame;
        tipCell.tipMessageLabel.textAlignment = NSTextAlignmentCenter;
        
    }else if([cell isKindOfClass:[RCTextMessageCell class]]){
        cell.messageTimeLabel.textColor = RGB(51, 51, 51);
        cell.messageTimeLabel.layer.cornerRadius = 10;
    }else if ([cell isKindOfClass:[RCImageMessageCell class]]){
        RCImageMessageCell *picCell = (RCImageMessageCell*)cell;
        picCell.pictureView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)addImgView:(RCTipMessageCell*)cell {
//    UIImageView *imgView =[cell viewWithTag:100];
//    if (!imgView) {
//        imgView = [UIImageView new];
//        [cell.contentView addSubview:imgView];
//        imgView.tag = 100;
//        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(0);
//            make.top.equalTo(cell.tipMessageLabel.mas_bottom).offset(10);
//            make.width.mas_equalTo(50);
//            make.height.mas_equalTo(50);
//        }];
//    }
//    imgView.backgroundColor = [UIColor redColor];
//    [cell.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.and.left.and.right.mas_equalTo(0);
//        make.bottom.equalTo(imgView.mas_bottom).offset(20);
//       
//    }];
}

//设置每个 UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    return size;
}


#define APPLICATION_DATA_DIRECTORY @"Application Data"
+ (NSString *)cachesDirectoryPath {
    NSString *      result;
    NSArray *       paths;
    
    result = nil;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ( (paths != nil) && ([paths count] != 0) ) {
        assert([[paths objectAtIndex:0] isKindOfClass:[NSString class]]);
        result = [paths objectAtIndex:0];
    }
    result = [result stringByAppendingPathComponent:APPLICATION_DATA_DIRECTORY];
    if (![[NSFileManager defaultManager] fileExistsAtPath:result]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return result;
}

- (void)chatCallUser {
    [EMUtil chatCallUser:_lonelyUser andController:self];
}

- (float)audioSoundDuration:(NSURL *)fileUrl{
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:fileUrl options:options];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

- (void)getChargeWithBlock:(void(^)())block{
    WS(weakSelf)
//    [UIUtil showHUD:self.view];
    [_mainViewVM getPersonalInfo:self.targetId andBlock:^(NSDictionary *dict, BOOL ret) {
//        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyStationUser *user = [[LonelyStationUser alloc] initWithDictory:dict[@"data"]];
                if (![user.msgCharge isEqualToString:weakSelf.currentMsgCharge] || ![user.talkCharge isEqualToString:weakSelf.currentTalkCharge]) {
                    [EMUtil alertMsg:Local(@"SheChangeChargeStatus") andTitle:Local(@"Warning") andCancelTitle:Local(@"IKnowRecordIsTooShort") andCancelBlock:^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    } andSureTitle:nil andSureBlock:NULL];
                }else{
                    block();
                }
            }
        }
    }];
}



- (void)needSendCan:(NSString*)path andDuration:(float)duration{
    //    重新修改
    //    女生：1.发送信息
    //         2.调用https://testapp.thevoicelover.com/index.php/api_me/getCreditNow更新剩余点数
    //         3.调用https://testapp.thevoicelover.com/index.php/api_talk/insertMessageHistory上传聊天记录
    //    男生：1.调用https://testapp.thevoicelover.com/index.php/api_member/getMsgChargeById获取收费状态发送信息，成功后发送
    //         2.调用https://testapp.thevoicelover.com/index.php/api_me/getCreditNow更新剩余点数
    //         3.调用https://testapp.thevoicelover.com/index.php/api_talk/insertMessageHistory上传聊天记录
    
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    
    
    if([@"F" isEqualToString:user.gender]) {
        RCVoiceMessage *message = [RCVoiceMessage messageWithAudio:[NSData dataWithContentsOfFile:path] duration:duration];
        message.extra = @"wav";
        //用客户指定的消息
        NSString *pushContentStr = [NSString stringWithFormat:@"%@",Local(@"VcMsg")];
        [self sendMessage:message pushContent:pushContentStr];
        //调用3
        [_userViewModel sendMsg:self.targetId andMsgType:@"voice" andBlock:^(NSDictionary *dict, BOOL ret) {
            
        }];
        //      调用2
        //获取自己的状态
        [self getMyTime];
    }else {
        if (![self checkSelfTime]) {
            return;
        }
        WS(weakSelf);
        [self getChargeWithBlock:^{
            RCVoiceMessage *message = [RCVoiceMessage messageWithAudio:[NSData dataWithContentsOfFile:path] duration:duration];
            message.extra = @"wav";
            //用客户指定的消息
            NSString *pushContentStr = [NSString stringWithFormat:@"%@",Local(@"VcMsg")];
            [self sendMessage:message pushContent:pushContentStr];
            //调用3
            [_userViewModel sendMsg:self.targetId andMsgType:@"voice" andBlock:^(NSDictionary *dict, BOOL ret) {
                if (ret && dict) {
                    [weakSelf changeMyTime:dict];
                }
            }];
            //      调用2
            //获取自己的状态
            [weakSelf getMyTime];
        }];
    }
    
}

- (void)changeMyTime:(NSDictionary*)dict{
    if ([[dict objectForKey:@"code"] intValue] == 1) {
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        user.chat_point = [NSString stringWithFormat:@"%d",[user.chat_point intValue] - [_lonelyUser.msgChargeRate intValue]];
        [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
    }
}

- (void)msgType:(MJChatBarMsgType)msgStyle msgBody:(id)context {
    //    重新修改
    //    女生：1.发送信息
    //         2.调用https://testapp.thevoicelover.com/index.php/api_me/getCreditNow更新剩余点数
    //         3.调用https://testapp.thevoicelover.com/index.php/api_talk/insertMessageHistory上传聊天记录
    //    男生：1.调用https://testapp.thevoicelover.com/index.php/api_member/getMsgChargeById获取收费状态发送信息，成功后发送
    //         2.调用https://testapp.thevoicelover.com/index.php/api_me/getCreditNow更新剩余点数
    //         3.调用https://testapp.thevoicelover.com/index.php/api_talk/insertMessageHistory上传聊天记录
    
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if([@"F" isEqualToString:user.gender]) {
        //如果自己是女的
//        1.发送消息
        if(msgStyle == MJChatInputBarActionType_Text) {
            [self sendTextMsg:context];
            //调用3
            [_userViewModel sendMsg:self.targetId andMsgType:@"text" andBlock:^(NSDictionary *dict, BOOL ret) {
                
            }];
        }else if(msgStyle == MJChatInputBarActionType_Audio){
            [self sendAudioMsg:context];
            //调用3
            [_userViewModel sendMsg:self.targetId andMsgType:@"voice" andBlock:^(NSDictionary *dict, BOOL ret) {
                
            }];
        }else if (msgStyle == MJChatBarMsgType_GIFEmoji) {
            if (![self checkSelfTime]) {
                return;
            }
            int sec = [self sendImgMsg:context];
            //调用3
            [_userViewModel sendGift:self.targetId andTime:[NSString stringWithFormat:@"%d",sec] andBlock:^(NSDictionary *dict, BOOL ret) {}];
        }
//      调用2
        //获取自己的状态
        [self getMyTime];
    }else {
        WS(weakSelf)
        [self getChargeWithBlock:^{
            if (![self checkSelfTime]) {
                return;
            }
            //        1.发送消息
            if(msgStyle == MJChatInputBarActionType_Text) {
                [self sendTextMsg:context];
                //调用3
                [_userViewModel sendMsg:self.targetId andMsgType:@"text" andBlock:^(NSDictionary *dict, BOOL ret) {
                    if (ret && dict) {
                        [weakSelf changeMyTime:dict];
                    }
                }];
            }else if(msgStyle == MJChatInputBarActionType_Audio){
                [self sendAudioMsg:context];
                //调用3
                [_userViewModel sendMsg:self.targetId andMsgType:@"voice" andBlock:^(NSDictionary *dict, BOOL ret) {
                    if (ret && dict) {
                        [weakSelf changeMyTime:dict];
                    }
                }];
            }else if (msgStyle == MJChatBarMsgType_GIFEmoji) {
                if (![self checkSelfTime]) {
                    return;
                }
                int sec = [self sendImgMsg:context];
                //调用3
                [_userViewModel sendGift:self.targetId andTime:[NSString stringWithFormat:@"%d",sec] andBlock:^(NSDictionary *dict, BOOL ret) {
                    
                }];
            }
            //      调用2
            //获取自己的状态
            [weakSelf getMyTime];
        }];
    }
}

- (void)getMyTime {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_mainViewVM  getMyTime:NO andBlock:^(NSDictionary *dict, BOOL ret) {
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



- (BOOL)checkSelfTime {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if (user.gender && [user.gender isEqualToString:@"M"]) {
        if ([user.chat_point intValue] < 0) {
            WS(weakSelf)
            dispatch_async(dispatch_get_main_queue(), ^{
                AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"TalkTimeNotEnough") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                    if (!cancelled) {
                        AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
                        [weakSelf.navigationController pushViewController:addMoneyMainVC animated:YES];
                    }else{
                        [weakSelf.chatBarToolView cancleInputState];
                    }
                } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"OKQuickBuy"), nil];
                [alert show];
                alert = nil;
            });
            return NO;
        }
    }
    return YES;
}


///发送文本消息
- (void)sendTextMsg:(id)context {
    RCTextMessage *message = [RCTextMessage messageWithContent:(NSString*)context];
    NSString *pushContentStr = [NSString stringWithFormat:@"%@",Local(@"TxtMsg")];
    [self sendMessage:message pushContent:pushContentStr];
}


///发送图片消息
- (int)sendImgMsg:(id)context {
    NSArray *arr = [(NSString*)context componentsSeparatedByString:@"##"];
    NSString *imageName = context;
    int sec = 0;
    if (arr && arr.count == 2) {
        imageName = [arr objectAtIndex:0];
        sec = [[arr objectAtIndex:1] intValue];
    }
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]];
    
    NSString *str = @"msg_type_gift_3";
    if (sec/60 == 5) {
        str = @"msg_type_gift_5";
    }else if (sec/60 == 10) {
        str = @"msg_type_gift_10";
    }else if (sec/60 == 20) {
        str = @"msg_type_gift_20";
    }else if (sec/60 == 50) {
        str = @"msg_type_gift_50";
    }
    RCInformationNotificationMessage *msg = [RCInformationNotificationMessage notificationWithMessage:str extra:imageName];
    [self sendMessage:msg pushContent:@""];
    
    RCImageMessage *rcImageMessage = [RCImageMessage messageWithImage:image];
    [rcImageMessage setExtra:[NSString stringWithFormat:@"gift:%d",sec]];
    NSString *pushContentStr = [NSString stringWithFormat:@"%@",Local(@"ImgMsg")];
    
    [self sendMediaMessage:rcImageMessage pushContent:pushContentStr];
    return sec;
}

///发送语音消息
- (BOOL)sendAudioMsg:(id)context {
    MJChatAudioRecordModel *model = (MJChatAudioRecordModel*)context;
    //判断录音时间是否超过3s，否则就是过小
    if (model.duartion < 3) {
        [self.view.window makeToast:Local(@"RecordIsTooShort") duration:1.2 position:[CSToastManager defaultPosition]];
        return NO;
    }
    RCVoiceMessage *message = [RCVoiceMessage messageWithAudio:[NSData dataWithContentsOfFile:model.localFilePath] duration:model.duartion];
    message.extra = @"wav";
    //用客户指定的消息
    NSString *pushContentStr = [NSString stringWithFormat:@"%@",Local(@"VcMsg")];
    [self sendMessage:message pushContent:pushContentStr];
    return YES;
}




- (void)chatBarToolViewChangeFrame:(CGRect)frame {
    UIScrollView *scroll = [self getScrollView];
    [scroll setFrame:CGRectMake(0, 64, GJCFSystemScreenWidth,GJCFSystemScreenHeight-frame.size.height - 64)];
    [self scrollToBottomAnimated:NO];
}



- (void)tapAction:(UITapGestureRecognizer *)tap
{
    [_chatBarToolView cancleInputState];
}

//拍照
- (void)photoAction {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"ChoosePhoto", @"Localization", nil) clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        DLog(@"----%d",(int)buttonIndex);
        if (buttonIndex == 1) {
            CameraSessionViewController *controller = [[CameraSessionViewController alloc] init];
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:NULL];
            controller = nil;
        }else if(buttonIndex == 2){
            UIImagePickerController *ipc=[[UIImagePickerController alloc] init];
            [ipc.navigationBar setBackgroundImage:[UIUtil imageWithColor:RGBA(0x98, 0x4a, 0xa6,1) andSize:Size(kScreenW, 64)] forBarMetrics:UIBarMetricsDefault];
            [ipc.navigationBar setTintColor:ColorFF];
            [ipc.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
            
            ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            ipc.delegate=self;
            [self presentViewController:ipc animated:YES completion:nil];
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Local(@"Camra"),Local(@"ChooseFromAblue"),nil];
    [sheet showInView:self.view];
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (navigationController.viewControllers.count == 1)
    {
        UIPageViewController *controller = (UIPageViewController*)navigationController.viewControllers[0];
        DLog(@"%@",controller.view.subviews);
    }
}


-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info{
    UIImage *img=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self cropImage:img];
}


//拍照完成后的回调，去编辑图片
- (void)didCaptureImageWithImage:(UIImage*)image {
    [self cropImage:image];
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
                                          length);
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
    navigationController = nil;
    controller = nil;
    
}


#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    //发送照片
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if (user.gender && [user.gender isEqualToString:@"M"]) {
        if ([user.talkSecond intValue] < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"TalkTimeNotEnough") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                    if (!cancelled) {
                        AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
                        [self.navigationController pushViewController:addMoneyMainVC animated:YES];
                    }
                } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"OKQuickBuy"), nil];
                [alert show];
                alert = nil;
            });
            return;
        }
    }
    
    [UIUtil showHUD:self.view];
    [_userViewModel sendMsg:self.targetId andMsgType:@"image" andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (dict && ret) {
            if ([[dict objectForKey:@"code"] intValue] == 1) {
                //成功了
                user.talkSecond = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"talk_second"] intValue]];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                RCImageMessage *rcImageMessage = [RCImageMessage messageWithImage:croppedImage];
                [rcImageMessage setExtra:@"(extra_text 扩展字段)"];
                [self sendMediaMessage:rcImageMessage pushContent:nil];
            }else {
                [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:3 position:[CSToastManager defaultPosition]];
            }
        }else{
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:3 position:[CSToastManager defaultPosition]];
            
        }
    }];
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}




@end
