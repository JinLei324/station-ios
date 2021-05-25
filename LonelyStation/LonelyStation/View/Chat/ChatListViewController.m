//
//  ChatListViewController.m
//  RongCloudDemo
//
//  Created by 杜立召 on 15/4/18.
//  Copyright (c) 2015年 dlz. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AddMoneyMainVC.h"
#import "LoginStatusObj.h"
#import "MainViewController.h"

@interface ChatListViewController ()<UITableViewDelegate>{
    NSMutableArray *_lockArray;
    NSMutableArray *_lockMeArray;
}
@property(nonatomic,strong)MainViewVM *mainViewVM;
@property (nonatomic,strong)UILabel *bridgeLabel;


@end

@implementation ChatListViewController


- (void)didReceiveMessageNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super didReceiveMessageNotification:notification];
    });
}

- (void)userInfo:(id)sender {
    [self.tabViewController sliderLeftController];
}

-(void)viewDidLoad
{
    [self setConversationAvatarStyle:RC_USER_AVATAR_CYCLE];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _mainViewVM = [[MainViewVM alloc] init];
    _lockArray = [NSMutableArray array];
    _lockMeArray = [NSMutableArray array];
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;
    
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION)]];
    
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.gender isEqualToString:@"F"]) {
        UIView *headView = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenW, 25)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:Rect(15, 2, 18, 18)];
        imageView.image = [UIImage imageNamed:@"icon_notice"];
        [headView addSubview:imageView];
        headView.backgroundColor = RGB(200, 200, 200);
        UILabel *label = [[UILabel alloc] initWithFrame:Rect(40, 0, kScreenW-40, 25)];
        label.textColor = RGB(0xff, 0xff, 0xff);
        label.font = ComFont(14);
        if ([user.msgCharge isEqualToString:@"Y"]) {
            NSMutableAttributedString *str = [UIUtil getAttrStr:Local(@"ChatDes") andAllColor:RGB(51, 51, 51) andDstStr:Local(@"NotFree") andDstColor:RGB(145,90,173)];
            NSRange range = [Local(@"ChatDes") rangeOfString:Local(@"FreeSetting")];
            if (range.location != NSNotFound ) {
                [str
                 addAttribute:NSForegroundColorAttributeName value:RGB(145,90,173) range:range];
            }
            label.attributedText = str;
            [headView addSubview:label];
        }else {
            NSMutableAttributedString *str = [UIUtil getAttrStr:Local(@"ChatFreeDes") andAllColor:RGB(51, 51, 51) andDstStr:Local(@"Free") andDstColor:RGB(145,90,173)];
            NSRange range = [Local(@"ChatFreeDes") rangeOfString:Local(@"Free")];
            if (range.location != NSNotFound ) {
                [str
                 addAttribute:NSForegroundColorAttributeName value:RGB(145,90,173) range:range];
            }
            label.attributedText = str;
            [headView addSubview:label];
        }
        self.conversationListTableView.tableHeaderView = headView;

    }else {
        self.conversationListTableView.tableHeaderView = [UIView new];
        
    }
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    
    NSLog(@"%@",self.displayConversationTypeArray);
    
    [self.conversationListTableView setFrame:CGRectMake(0, 80, kScreenW, kScreenH-80-49)];
    [self.conversationListTableView setBackgroundColor:[UIColor clearColor]];
    self.conversationListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view bringSubviewToFront:self.conversationListTableView];
    [self initNavBar];
    
    //查询信息

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return AppBarStyle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];
    [self setNeedsStatusBarAppearanceUpdate];
    [self initData];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    self.bridgeLabel.text = [NSString stringWithFormat:@"%@",user.unread];
    [(MainViewController*)self.tabViewController.viewControllers[0] showOrNotRed];
}


- (void)setLeftAndTitle {
    EMButton *userInfoBtn = [[EMButton alloc] initWithFrame:Rect(15, 33, 40, 40) isRdius:YES];
    //    [userInfoBtn setImage:[UIImage imageNamed:@"answer_no_photo"] forState:UIControlStateNormal];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined) {
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        [userInfoBtn yy_setImageWithURL:[NSURL URLWithString:user.file] forState:UIControlStateNormal placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:user.gender]]];
    }else {
        if ([loginStatus.gender isEqualToString:@"M"]) {
            [userInfoBtn setImage:[UIImage imageNamed:@"gender_M"] forState:UIControlStateNormal];
        }else{
            [userInfoBtn setImage:[UIImage imageNamed:@"gender_F"] forState:UIControlStateNormal];
        }
    }
    
    [userInfoBtn addTarget:self action:@selector(userInfo:) forControlEvents:UIControlEventTouchUpInside];
    [_viewNaviBar setLeftBtn:nil];
    [_viewNaviBar addSubview:userInfoBtn];
    
    //添加提示的文字
    _bridgeLabel = [[UILabel alloc] initWithFrame:Rect(PositionX(userInfoBtn) - 5, 33, 19, 13)];
    _bridgeLabel.layer.cornerRadius = 5;
    _bridgeLabel.layer.masksToBounds = YES;
    _bridgeLabel.backgroundColor = RGB(255,252,0);
    _bridgeLabel.textAlignment = NSTextAlignmentCenter;
    _bridgeLabel.text = @"0";
    _bridgeLabel.textColor = RGB(51,51,51);
    _bridgeLabel.font = ComFont(8);
    [_viewNaviBar addSubview:_bridgeLabel];
    
    EMLabel *infoLabel = [[EMLabel alloc] initWithFrame:Rect((kScreenW - 200)/2, 33, 200, 44)];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = RGB(145,90,173);
    infoLabel.font = ComFont(19.f);
    infoLabel.text = Local(@"VoiceChat");
    [_viewNaviBar addSubview:infoLabel];
    
    UIView *view = [UIView new];
    view.backgroundColor = RGB(171, 171, 171);
    [_viewNaviBar addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
}



- (void)initData {
    //查封锁我的和我封锁的人
    [UIUtil showHUD:self.conversationListTableView];
    WS(weakSelf)
    [_mainViewVM getLockListWithBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:weakSelf.conversationListTableView];
        if (ret && dict) {
            [_lockArray removeAllObjects];
            [_lockArray addObjectsFromArray:dict[@"MyLock"]];
            [_lockMeArray removeAllObjects];
            [_lockMeArray addObjectsFromArray:dict[@"LockMe"]];
        }
    }];
    NSLog(@"%@",self.conversationListDataSource);
    
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.conversationListTableView reloadData];
}



-(void)initNavBar{
    _viewNaviBar = [[CustomNaviBarView alloc] initWithFrame:Rect(0.0f, 0.0f, [CustomNaviBarView barSize].width,80)];
    _viewNaviBar.m_viewCtrlParent = self;
    [_viewNaviBar setBackgroundColor:[UIColor whiteColor]];
    _viewNaviBar.userInteractionEnabled = YES;
    [self.view addSubview:_viewNaviBar];
    [self setLeftAndTitle];
}


-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/**
 *重写RCConversationListViewController的onSelectedTableRow事件
 *
 *  @param conversationModelType 数据模型类型
 *  @param model                 数据模型
 *  @param indexPath             索引
 */
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    [self.conversationListTableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_lockArray containsObject:model.targetId]) {
        //你已封锁对方
        dispatch_async(dispatch_get_main_queue(), ^{
            WS(weakSelf)
            AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"YouLockedTa") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                if (!cancelled) {
                    //解除封锁
                    [weakSelf.mainViewVM deleteLock:model.targetId andBlock:^(NSDictionary *dict, BOOL ret) {
                        if (ret && dict) {
                            if ([dict[@"code"] intValue] == 1) {
                                [weakSelf pushToChatView:model];
                            }else {
                                [weakSelf.view makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                            }
                        }else{
                            [weakSelf.view makeToast:dict[@"FailedAndPlsRetry"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                        }
                    }];
                }
            } cancelButtonTitle:Local(@"KeepLock") otherButtonTitles:Local(@"UnLock"), nil];
            [alert show];
            alert = nil;
        });
    }else if([_lockMeArray containsObject:model.targetId]){
        //对方已经封锁你
        EMAlertView *alert = [[EMAlertView alloc] initWithTitle:Local(@"Warning") message:Local(@"TaLockedYou") clickedBlock:^(EMAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        } cancelButtonTitle:Local(@"IKnowRecordIsTooShort") otherButtonTitles:nil];
        [alert show];
        alert = nil;
    }else {
        [self pushToChatView:model];
    }
    
}


- (void)pushToChatView:(RCConversationModel *)model {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if (model.extend && [model.extend isKindOfClass:[LonelyUser class]] && [user.gender isEqualToString:@"M"]) {
        //做判断，1.如果对方是收费，自己有秒数，弹提示1
        //2.如果聊天卡用完，弹购买提示
        //3.如果对方免费，谈提示无限畅聊卡，如果有聊天卡，使用聊天卡
        //4.如果无限畅聊卡都没有，谈提示
        LonelyUser *extend = (LonelyUser*)model.extend;
        WS(weakSelf)
        [EMUtil chatWithUser:extend andFirstBlock:^{
            SS(weakSelf, strongSelf);
            [strongSelf justPushToChatView:model];
        } andSecondBlock:^{
            SS(weakSelf, strongSelf);
            AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
            [strongSelf.navigationController pushViewController:addMoneyMainVC animated:YES];
        }];
    }else {
        [self justPushToChatView:model];
    }
}

- (void)justPushToChatView:(RCConversationModel *)model {
    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:model.targetId];
    ChatViewController *conversationVC = [[ChatViewController alloc]init];
    conversationVC.conversationType =model.conversationType;
    conversationVC.targetId = model.targetId;
    conversationVC.defaultInputType = RCChatSessionInputBarInputVoice;
    conversationVC.title = model.conversationTitle;
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    [self.navigationController pushViewController:conversationVC animated:YES];
}


-(void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RCConversationCell *conversCell = (RCConversationCell*)cell;
    conversCell.contentView.backgroundColor = [UIColor clearColor];
    conversCell.backgroundColor = [UIColor clearColor];
    [(UIView*)conversCell.headerImageView setFrame:CGRectMake(0, 0, 46, 46)];
    RCConversationModel *model = [self.conversationListDataSource objectAtIndex:indexPath.row];
    
    RCUserInfo *info = [[RCIM sharedRCIM] getUserInfoCache:model.targetId];
    [self displayCell:conversCell andInfo:info andModel:model];
    cell.alpha = 0;
}

- (void)displayCell:(RCConversationCell*)conversCell andInfo:(RCUserInfo*)info andModel:(RCConversationModel*)model{
    conversCell.conversationTitle.hidden = YES;
    conversCell.messageContentLabel.hidden = YES;
    conversCell.messageCreatedTimeLabel.hidden = YES;
    conversCell.bubbleTipView.alpha = 0;
    NSArray *array = [[FileAccessData sharedInstance] objectForMemKey:@"chatListUser"];
    LonelyUser *dstUser = nil;
    for (int i = 0; i < array.count; i++) {
        LonelyUser *userInfo = array[i];
        if ([userInfo.userID isEqualToString:info.userId]) {
            dstUser = userInfo;
            break;
        }
    }
    
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSString *fileName = @"";
    if ([user.gender isEqualToString:@"M"]) {
        fileName = @"gender_F";
    }else{
        fileName = @"gender_M";
    }
    [(UIImageView*)conversCell.headerImageView yy_setImageWithURL:[NSURL URLWithString:info.portraitUri] placeholder:[UIImage imageNamed:fileName]];
    
    UILabel *nameLabel = [conversCell.contentView viewWithTag:100];
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(conversCell.headerImageViewBackgroundView.frame.size.width +20, 0, 150, 75)];
        [conversCell.contentView addSubview:nameLabel];
    }
    nameLabel.tag = 100;
    nameLabel.font = [UIFont systemFontOfSize:15];
    if (![info.name isEqual:[NSNull null]]) {
        nameLabel.text = [NSString stringWithFormat:@"%@",info.name];
    }
    if (dstUser) {
        nameLabel.text = [NSString stringWithFormat:@"%@",dstUser.nickName];
    }
    
    nameLabel.textColor = RGB(51, 51, 51);
    NSLog(@"unreadMsg=%d",(int)model.unreadMessageCount);
    UIImageView *newImageView = [conversCell.contentView viewWithTag:101];
    if (!newImageView) {
        newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenW - 143, 27, 45, 21)];
        [conversCell.contentView addSubview:newImageView];
    }
    newImageView.tag = 101;
    newImageView.image= [UIImage imageNamed:@"center_button_new.png"];
    if (model.unreadMessageCount > 0) {
        newImageView.hidden = NO;
    }else {
        newImageView.hidden = YES;
    }
    
    UILabel *lastTimeLabel = [conversCell.contentView viewWithTag:102];
    if (!lastTimeLabel) {
        CGFloat x = newImageView.frame.size.width + newImageView.frame.origin.x;
        lastTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, kScreenW - x - 31, 75)];
        [conversCell.contentView addSubview:lastTimeLabel];
    }
    lastTimeLabel.tag = 102;
    lastTimeLabel.font = [UIFont systemFontOfSize:12];
    NSDate *nd = [NSDate dateWithTimeIntervalSince1970:model.sentTime/1000];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:nd];
    NSLog(@"date: %@", dateString);
    dateFormat = nil;
    
    lastTimeLabel.text = [EMUtil getTimeToNow:dateString];
    lastTimeLabel.textAlignment = NSTextAlignmentRight;
    lastTimeLabel.textColor = RGB(51, 51, 51);
    [UIUtil addLineWithSuperView:conversCell.contentView andRect:Rect(0, 74, kScreenW, 1)];
    
    CGSize size = [nameLabel sizeThatFits:CGSizeZero];
    UIImageView *chargeImageView = [conversCell.contentView viewWithTag:103];
    if (!chargeImageView) {
        chargeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + size.width +5, 27, 28, 26)];
        [conversCell.contentView addSubview:chargeImageView];
        chargeImageView.hidden = YES;
    }
    chargeImageView.tag = 103;
    chargeImageView.image= [UIImage imageNamed:@"icon_coin"];
    if ([user.gender isEqualToString:@"F"]) {
        chargeImageView.hidden = YES;
    }else{
        if (dstUser) {
            if ([dstUser.msgCharge isEqualToString:@"Y"]) {
                chargeImageView.hidden = NO;
            }else {
                chargeImageView.hidden = YES;
            }
        }else {
            if (model.extend && [model.extend isKindOfClass:[LonelyUser class]]) {
                LonelyUser *userInfo = (LonelyUser*)model.extend;
                if ([userInfo.msgCharge isEqualToString:@"Y"]) {
                    chargeImageView.hidden = NO;
                }else {
                    chargeImageView.hidden = YES;
                }
            }else {
                
                [self getUserInfoWithUserId:info.userId completion:^(LonelyUser *userInfo) {
                    model.extend = userInfo;
                    if ([userInfo.msgCharge isEqualToString:@"Y"]) {
                        chargeImageView.hidden = NO;
                    }else{
                        chargeImageView.hidden = YES;
                    }
                }];
            }
        }
    }
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = [super tableView:tableView numberOfRowsInSection:section];
    return number;
}



/**
 *  退出登录
 *
 *  @param sender <#sender description#>
 */
- (void)leftBarButtonItemPressed:(id)sender {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
//    [alertView show];
    AllPopView *popView = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:@"确定要退出？" clickedBlock:^(AllPopView * _Nonnull alertView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Logout"), nil];
    [popView show];
}



- (void)getUserInfoWithUserId:(NSString *)userId completion:(void(^)(LonelyStationUser* userInfo))completion{
    MainViewVM *mainViewVM = [MainViewVM new];
    [UIUtil showHUD:self.conversationListTableView];
    WS(weakSelf)
    [mainViewVM getPersonalInfo:userId andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:weakSelf.conversationListTableView];
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyStationUser *user = [[LonelyStationUser alloc] initWithDictory:dict[@"data"]];
                completion(user);
            }
        }
    }];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
