//
//  RCDCustomerServiceViewController.m
//  RCloudMessage
//
//  Created by litao on 16/2/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerServiceViewController.h"
#import "IQKeyboardManager.h"

@interface RCDCustomerServiceViewController ()
//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始1＊＊＊＊＊＊＊＊＊＊＊＊＊
//@property (nonatomic, strong)NSString *commentId;
//@property (nonatomic)RCCustomerServiceStatus serviceStatus;
//@property (nonatomic)BOOL quitAfterComment;
//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束1＊＊＊＊＊＊＊＊＊＊＊＊＊

@end

@implementation RCDCustomerServiceViewController

- (void)viewDidLoad {
//    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle: RC_USER_AVATAR_CYCLE];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //禁止滑动返回
    self.fd_interactivePopDisabled = YES;
    
    //设置输入类型
    [self.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType style:RC_CHAT_INPUT_BAR_STYLE_CONTAINER];
    
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
//    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
//    [self.view addSubview:backgroundImageView];
    [self.conversationMessageCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view bringSubviewToFront:self.conversationMessageCollectionView];
    [self.view bringSubviewToFront:self.chatSessionInputBarControl];
    [self.conversationMessageCollectionView setFrame:Rect(0, 64, kScreenW, kScreenH-64-self.chatSessionInputBarControl.frame.size.height)];
    // 设置导航栏
    [self setupNav];
}

- (void) viewWillDisappear: (BOOL)animated {
    
    //关闭键盘事件相应
//    [super viewWillDisappear:animated];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /******** 切换人工客服 *******/
//    [self deleteMessage:self.conversationDataRepository.lastObject];
//    [[RCIMClient sharedRCIMClient] switchToHumanMode:@"KEFU147783196148332"];
    
}

//客服VC左按键注册的selector是customerServiceLeftCurrentViewController，
//这个函数是基类的函数，他会根据当前服务时间来决定是否弹出评价，根据服务的类型来决定弹出评价类型。
//弹出评价的函数是commentCustomerServiceAndQuit，应用可以根据这个函数内的注释来自定义评价界面。
//等待用户评价结束后调用如下函数离开当前VC。
- (void)leftBarButtonItemPressed:(id)sender {
    //需要调用super的实现
    [super leftBarButtonItemPressed:sender];

    [self.navigationController popViewControllerAnimated:YES];
}

//评价客服，并离开当前会话
//如果您需要自定义客服评价界面，请把本函数注释掉，并打开“应用自定义评价界面开始1/2”到“应用自定义评价界面结束”部分的代码，然后根据您的需求进行修改。
//如果您需要去掉客服评价界面，请把本函数注释掉，并打开下面“应用去掉评价界面开始”到“应用去掉评价界面结束”部分的代码，然后根据您的需求进行修改。
- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
                               commentId:(NSString *)commentId
                        quitAfterComment:(BOOL)isQuit {
    [super commentCustomerServiceWithStatus:serviceStatus
                                  commentId:commentId
                           quitAfterComment:isQuit];
}

//＊＊＊＊＊＊＊＊＊应用去掉评价界面开始＊＊＊＊＊＊＊＊＊＊＊＊＊
//-
//(void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit {
//    if (isQuit) {
//        [self leftBarButtonItemPressed:nil];
//    }
//}
//＊＊＊＊＊＊＊＊＊应用去掉评价界面结束＊＊＊＊＊＊＊＊＊＊＊＊＊

//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始2＊＊＊＊＊＊＊＊＊＊＊＊＊
//-
//(void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit {
//    self.serviceStatus = serviceStatus;
//    self.commentId = commentId;
//    self.quitAfterComment = isQuit;
//    if (serviceStatus == 0) {
//        [self leftBarButtonItemPressed:nil];
//    } else if (serviceStatus == 1) {
//        UIAlertView *alert = [[UIAlertView alloc]
//        initWithTitle:@"请评价我们的人工服务"
//        message:@"如果您满意就按5，不满意就按1" delegate:self
//        cancelButtonTitle:@"5" otherButtonTitles:@"1", nil];
//        [alert show];
//    } else if (serviceStatus == 2) {
//        UIAlertView *alert = [[UIAlertView alloc]
//        initWithTitle:@"请评价我们的机器人服务"
//        message:@"如果您满意就按是，不满意就按否" delegate:self
//        cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
//        [alert show];
//    }
//}
//- (void)alertView:(UIAlertView *)alertView
//clickedButtonAtIndex:(NSInteger)buttonIndex {
//    //(1)调用evaluateCustomerService将评价结果传给融云sdk。
//    if (self.serviceStatus == RCCustomerService_HumanService) { //人工评价结果
//        if (buttonIndex == 0) {
//            [[RCIMClient sharedRCIMClient]
//            evaluateCustomerService:self.targetId dialogId:self.commentId
//            humanValue:5 suggest:nil];
//        } else if (buttonIndex == 1) {
//            [[RCIMClient sharedRCIMClient]
//            evaluateCustomerService:self.targetId dialogId:self.commentId
//            humanValue:0 suggest:nil];
//        }
//    } else if (self.serviceStatus == RCCustomerService_RobotService)
//    {//机器人评价结果
//        if (buttonIndex == 0) {
//            [[RCIMClient sharedRCIMClient]
//            evaluateCustomerService:self.targetId knownledgeId:self.commentId
//            robotValue:YES suggest:nil];
//        } else if (buttonIndex == 1) {
//            [[RCIMClient sharedRCIMClient]
//            evaluateCustomerService:self.targetId knownledgeId:self.commentId
//            robotValue:NO suggest:nil];
//        }
//    }
//    //(2)离开当前客服VC
//    if (self.quitAfterComment) {
//        [self leftBarButtonItemPressed:nil];
//    }
//}
//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束2＊＊＊＊＊＊＊＊＊＊＊＊＊

#pragma mark - 修改UI界面
- (void)setupNav {
    // 设置返回按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:Rect(11, 20, 40, 40)];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(customerServiceLeftCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    EMLabel *titleLabel = [[EMLabel alloc] initWithFrame:Rect(55, 20, kScreenW - 110, 44)];
    titleLabel.text = Local(@"FeedBack");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = RGB(145,90,173);
    titleLabel.font = ComFont(19);
    [self.view addSubview:titleLabel];
}

@end
