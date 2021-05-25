//
//  MainTabBarController.m
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "MainTabBarController.h"
#import "MainViewController.h"
#import "UserMainController.h"
#import "EMNavigationController.h"
#import "RecordAiringController.h"
#import "MyFocousVC.h"
#import "AllStationsVC.h"
#import "ChatListViewController.h"
#import "AppDelegate.h"
#import "ViewModelCommom.h"
#import "AddMoneyMainVC.h"
#import "EMAlertView.h"
#import "UIUtil.h"
#import "AllStationNewVC.h"
#import "MainViewVM.h"
#import "DynamicVC.h"
#import "MainRecordMenuView.h"
#import "RecordIntroduceVC.h"
#import "LiveMallVC.h"

#define kExploreTabItemFrame CGRectMake(2, 22, (kScreenW-69)/4, 49)
#define kPublishTabItemFrame CGRectMake(kScreenW/2.f-69/2.f, 1.0, 69, 69)
#define kProfileTabItemFrame CGRectMake(199, 22, 119, 49)

@interface MainTabBarController()

@property(nonatomic, strong) NSMutableArray *tabbarButtons;


@end

const NSInteger SKTabBarButtonTagOffset = 100;
#define centerWidth 100

@implementation MainTabBarController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return AppBarStyle;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarHeight = 70;
        
        self.actualTabBarHeight = 50;
    }
    return self;
}


-(void)viewDidLoad{
    DLog(@"hello");
//    self.view.backgroundColor = [UIColor yellowColor];
    [self setUpAllChildViewController];
    self.tabBar.customizable = YES;
    self.tabBar.separatorView.hidden = YES;
    self.tabBar.barTintColor = [UIColor clearColor];
    UIView *backView = [[UIView alloc] initWithFrame:Rect(0, 22, kScreenW, 49)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:backView];
    
    self.tabBar.backgroundColor = [UIColor clearColor];
    self.tabBar.translucent = NO;
//    self.tabBar.backgroundImage = [UIImage imageNamed:@"main"];
    
    CGPoint publishCenterPoint = CGPointMake(CGRectGetMidX(kPublishTabItemFrame), CGRectGetMidY(kPublishTabItemFrame));
    self.tabBar.hitTestBlock = ^(CGPoint point, UIEvent *event, BOOL *returnSuper) {
        /// 按钮的点击区域距离圆心的距离
        CGFloat distance = STDistanceBetweenPoints(point, publishCenterPoint);
        /// 如果不在圆形内，则不响应点击事件，让下一层去响应
        if (distance < CGRectGetHeight(kPublishTabItemFrame) / 2) {
            *returnSuper = YES;
        }
        if (point.y >= 20) {
            *returnSuper = YES;
        }
        return (UIView *)nil;
    };
    UIView *view = [UIView new];
    [self.tabBar addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(1);
    }];
    view.backgroundColor = RGB(171, 171, 171);
    self.tabbarButtons = [[NSMutableArray alloc] initWithCapacity:2];
    
    [self setChildButton:@"focus-off" andSelectedPath:@"focus-on" andTag:SKTabBarButtonTagOffset andSelector:@selector(onSelectTabIndexChanged:) andFrame:Rect(0, 22, (kScreenW-centerWidth)/4, 49) andTitle:Local(@"MyCare")];
    
    [self setChildButton:@"live-off" andSelectedPath:@"live-on" andTag:SKTabBarButtonTagOffset+1 andSelector:@selector(onSelectTabIndexChanged:) andFrame:Rect((kScreenW-centerWidth)/4, 22, (kScreenW-centerWidth)/4, 49) andTitle:Local(@"Blindness")];

    [self setChildButton:@"Random call" andSelectedPath:@"Random call" andTag:SKTabBarButtonTagOffset+2 andSelector:@selector(onSelectTabIndexChanged:) andFrame:kPublishTabItemFrame andTitle:nil];
    
    [self setChildButton:@"broadcast-off" andSelectedPath:@"broadcast-on" andTag:SKTabBarButtonTagOffset+3 andSelector:@selector(onSelectTabIndexChanged:) andFrame:Rect((kScreenW-centerWidth)/2+centerWidth, 22, (kScreenW-centerWidth)/4, 49) andTitle:Local(@"AllStation")];
    
    [self setChildButton:@"message-off" andSelectedPath:@"message-on" andTag:SKTabBarButtonTagOffset+4 andSelector:@selector(onSelectTabIndexChanged:) andFrame:Rect((kScreenW-centerWidth)*3/4+centerWidth, 22, (kScreenW-centerWidth)/4, 49) andTitle:Local(@"VoiceChat")];
    
    self.selectedIndex = 0;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)setChildButton:(NSString*)imagePath andSelectedPath:(NSString*)highlightPath andTag:(NSInteger)tag andSelector:(SEL)selector andFrame:(CGRect)rect andTitle:(NSString*)title{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = rect;
    btn.tag = tag;
    [btn setImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:imagePath] forState:UIControlStateHighlighted];
//    [btn setImage:[UIImage imageNamed:highlightPath] forState: UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:highlightPath] forState: UIControlStateSelected];

    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    //去掉title
//    if (title) {
//        [btn setImageEdgeInsets:UIEdgeInsetsMake(-14, 0, 0, 0)];
//        UILabel *label = [[UILabel alloc] initWithFrame:Rect((rect.size.width - 42)/2.f, 33, 42, 11)];
//        label.font = ComFont(10);
//        label.text = title;
//        label.textAlignment = NSTextAlignmentCenter;
//        label.textColor = [UIColor whiteColor];
//        [btn addSubview:label];
//    }
    [self.tabBar addSubview:btn];
    [self.tabbarButtons addObject:btn];
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    for (int i = 0; i < self.tabbarButtons.count; i++) {
        UIButton *selectedButton = [self.tabbarButtons objectAtIndex:i];
        NSInteger tag = selectedButton.tag - SKTabBarButtonTagOffset;
        if (tag == selectedIndex) {
            selectedButton.selected = YES;
        } else {
            selectedButton.selected = NO;
        }
    }
    UIButton *centerBtn = [self.tabbarButtons objectAtIndex:2];
    if (selectedIndex == 0){
        [centerBtn setImage:[UIImage imageNamed:@"Random call"] forState:UIControlStateNormal];
    }else if(selectedIndex == 1){
        [centerBtn setImage:[UIImage imageNamed:@"live-btn"] forState:UIControlStateNormal];
    }else if(selectedIndex == 3){
        [centerBtn setImage:[UIImage imageNamed:@"mic_btn"] forState:UIControlStateNormal];
    }else if(selectedIndex == 4){
        [centerBtn setImage:[UIImage imageNamed:@"say_hi_btn"] forState:UIControlStateNormal];
    }
    
    [super setSelectedIndex:selectedIndex];
}

- (void)onSelectTabIndexChanged:(id)sender {
 
    UIButton *button = (UIButton *)sender;
    NSInteger toId = button.tag - SKTabBarButtonTagOffset;
    if (![UIUtil checkLogin]) {
            return;
    }
    if (toId == 2) {
        if(self.selectedIndex == 0){
            [self blendChat];
        }else if(self.selectedIndex == 2){
//            RecordIntroduceVC *voices = [[RecordIntroduceVC alloc] init];
//            voices.seq = 1;
//            [self.navigationController pushViewController:voices animated:YES];
            //录制广播
            RecordAiringController *recordAiringCtl = [[RecordAiringController alloc] init];
            [self.navigationController pushViewController:recordAiringCtl animated:YES];
        }else{
            [self.view makeToast:Local(@"OntheWay") duration:ERRORTime position:[CSToastManager defaultPosition]];

        }
        
//        //广播录制
//        MainRecordMenuView *mainRecordMenu = [[MainRecordMenuView alloc] initWithFrame:Rect(0, 0, kScreenW, kScreenH)];
//        [[UIApplication sharedApplication].keyWindow addSubview:mainRecordMenu];
//        [mainRecordMenu show];
//
        
        return;
    }
//    else if (toId == 0) {
//        MyFocousVC *focusVC = [[MyFocousVC alloc] init];
//        [self.navigationController pushViewController:focusVC animated:YES];
//    }else if (toId == 1) {
//        [self blendChat];
//    }else if (toId == 3) {
//        DynamicVC *allStationNewVC = [[DynamicVC alloc] init];
//        [self.navigationController pushViewController:allStationNewVC animated:YES];
//    }else if (toId == 4) {
//        if ([UIUtil alertProfileWarning:self andMsg:Local(@"YOUMUSTCOMPLETEINFO")]) {
//            return;
//        }
//        ChatListViewController *voiceChatVC = [[ChatListViewController alloc] init];
//        [self.navigationController pushViewController:voiceChatVC animated:YES];
//    }
    button.selected = !button.selected;
    self.selectedIndex = toId;
}

///盲目通话
- (void)blendChat {
    //盲目通话
    //提示
    AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"WillConnect") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelyUser *user = [ViewModelCommom getCuttentUser];
            //判断还有多少时长，只有大于0的时候才能去打电话
            //        user.talkSecond = @"0";
            if (user.gender && [user.gender isEqualToString:@"M"]) {
                if ([user.talkSecond intValue] <= 0 && [user.vipEndSecond longLongValue] - [user.vipStartSecond longLongValue] <=0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        EMAlertView *alert = [[EMAlertView alloc] initWithTitle:Local(@"Warning") message:Local(@"SorryTimeNotEnough") clickedBlock:^(EMAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
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
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            
            appDelegate.callViewController.fromUser = [ViewModelCommom getCuttentUser];
            
            
            MainViewVM *mainVM = [[MainViewVM alloc] init];
            NSMutableArray *onlineArray = [NSMutableArray array];
            NSMutableArray *onlineImgArray = [NSMutableArray array];
            BOOL isGetAllCharge = NO;
            if ([user.talkSecond intValue] > 0 && [user.vipEndSecond longLongValue] - [user.vipStartSecond longLongValue] <=0) {
                isGetAllCharge = YES;
            }
            BOOL isGetAllFree = NO;
            if ([user.talkSecond intValue] <= 0 && [user.vipEndSecond longLongValue] - [user.vipStartSecond longLongValue] > 0) {
                isGetAllFree = YES;
            }
            [UIUtil showHUD:self.view];
            [mainVM getMainInfoWithBlock:^(NSArray<LonelyStationUser *> *arr, BOOL ret) {
                [UIUtil hideHUD:self.view];
                int index = -1;
                
                if (arr && ret && arr.count > 0) {
                    //取出在线的能接电话的用户
                    for (int i = 0;i<arr.count;i++) {
                        LonelyStationUser *lonelyUser = arr[i];
                        if ([lonelyUser.allowTalk intValue] == 1) {
                            if (lonelyUser.isOnLine && [lonelyUser.identity isEqualToString:@"3"] && [lonelyUser.optState isEqualToString:@"Y"] && [lonelyUser.connectStat isEqualToString:@"N"]) {
                                if (isGetAllCharge) {
                                    if ([lonelyUser.talkCharge isEqualToString:@"Y"]) {
                                        [onlineArray addObject:lonelyUser];
                                        if(lonelyUser.file && lonelyUser.file.length>0){
                                            [onlineImgArray addObject:lonelyUser.file];
                                        }else {
                                            [onlineImgArray addObject:lonelyUser.file2];
                                        }
                                    }
                                }else if (isGetAllFree) {
                                    if ([lonelyUser.talkCharge isEqualToString:@"N"]) {
                                        [onlineArray addObject:lonelyUser];
                                        if(lonelyUser.file && lonelyUser.file.length>0){
                                            [onlineImgArray addObject:lonelyUser.file];
                                        }else {
                                            [onlineImgArray addObject:lonelyUser.file2];
                                        }
                                    }
                                }else {
                                    [onlineArray addObject:lonelyUser];
                                    if(lonelyUser.file && lonelyUser.file.length>0){
                                        [onlineImgArray addObject:lonelyUser.file];
                                    }else {
                                        [onlineImgArray addObject:lonelyUser.file2];
                                    }
                                }
                            }
                        }
                    }
                    
                }
                if (onlineArray.count > 1) {
                    index = rand() % ((int)onlineArray.count - 1);
                }else if(onlineArray.count == 1){
                    index = 0;
                }
                if (index >= 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        LonelyUser *user = onlineArray[index];
                        appDelegate.callViewController.toUser = user;
                        appDelegate.callViewController.blindUserArray = onlineImgArray;
                        //                    appDelegate.callViewController.isBlind = YES;
                        appDelegate.callViewController.callStatus = CallOut;
                        [self.navigationController pushViewController:appDelegate.callViewController animated:YES];
                    });
                    
                }else {
                    [self.view.window makeToast:Local(@"ThereHaveNoUserOnline") duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
                
            } andFrom:@"0" andCnt:@"30"];
        }
    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
    [alert show];
}


- (void)setUpAllChildViewController{
    MainViewController *mainView = [[MainViewController alloc] init];
    mainView.isHiddenNavigationBar = NO;
    mainView.tabViewController = self;
    
    LiveMallVC *live = [[LiveMallVC alloc] init];
    live.tabViewController = self;
        
    DynamicVC *dynmaicVC = [DynamicVC new];
    dynmaicVC.tabViewController = self;
    
    ChatListViewController *voiceChatVC = [[ChatListViewController alloc] init];
    voiceChatVC.tabViewController = self;

    self.viewControllers = @[mainView, live,dynmaicVC,dynmaicVC,voiceChatVC];
}


-(void)sliderLeftController{
    if(self.slideViewCtl){
        if (self.slideViewCtl.closed) {
            [self.slideViewCtl openLeftView];
        }else{
            [self.slideViewCtl closeLeftView];
        }
    }
}

/**
 *  添加一个子控制器的方法
 */
- (void)setUpOneChildViewController:(UIViewController *)viewController image:(UIImage *)image title:(NSString *)title{
//    EMNavigationController *navC = [[EMNavigationController alloc]initWithRootViewController:viewController];
//    navC.title = title;
//    navC.tabBarItem.image = image;
//    [navC.navigationBar setBackgroundImage:[UIImage imageNamed:@"commentary_num_bg"] forBarMetrics:UIBarMetricsDefault];
//    viewController.navigationItem.title = title;
//    [navC setNavigationBarHidden:YES];
    viewController.tabBarItem.image = image;
    viewController.tabBarItem.title = title;
    [self addChildViewController:viewController];
}


@end
