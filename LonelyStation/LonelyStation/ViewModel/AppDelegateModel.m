//
//  AppUpdateModel.m
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  
//

#import "AppDelegateModel.h"
#import "Harpy.h"
#import "HarpyConstants.h"
#import "AFNetworking.h"
#import "EMAlertView.h"
#import "ViewModelCommom.h"
#import "AppDelegate.h"
#import "UMessage.h"
#import "ChatViewController.h"
#import "LeftSlideViewController.h"
#import "MainViewController.h"
#import "MainTabBarController.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif


#define UMKEY @"5810099d310c932d2b001a64"
#define RONGCLOUD_IM_APPKEY @"kj7swf8o77dg2" //请换成您的appkey

@interface AppDelegateModel()<UNUserNotificationCenterDelegate>

@end


@implementation AppDelegateModel

static AppDelegateModel  *appModel;

+ (AppDelegateModel *)sharedInstance{
    static dispatch_once_t onceman;
    dispatch_once(&onceman, ^{
        appModel = [[self alloc]init];
    });
    return appModel;
}

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    //设置红外感应
    
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    [[RCIM sharedRCIM] setEnablePersistentUserInfoCache:YES];
    [[RCIM sharedRCIM] setEnableMessageAttachUserInfo:YES];

    application.applicationIconBadgeNumber=0;
    
    
    [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];
    [self notifyWeb];
    //友盟
    [UMessage startWithAppkey:@"5810099d310c932d2b001a64" launchOptions:launchOptions];
    //注册通知
    [UMessage registerForRemoteNotifications];
    [UMessage setLogEnabled:YES];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

    //iOS10必须加下面这段代码。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    UNAuthorizationOptions types10=UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
            dispatch_async(dispatch_get_main_queue(), ^{
                [application registerForRemoteNotifications];
                [UMessage registerForRemoteNotifications];
            });
        } else {
            //点击不允许
            
        }
    }];
    
    
    //如果要在iOS10显示交互式的通知，必须注意实现以下代码
    if ([[[UIDevice currentDevice] systemVersion]intValue]>=10) {
        UNNotificationAction *action1_ios10 = [UNNotificationAction actionWithIdentifier:@"action1_ios10_identifier" title:@"打开应用" options:UNNotificationActionOptionForeground];
        UNNotificationAction *action2_ios10 = [UNNotificationAction actionWithIdentifier:@"action2_ios10_identifier" title:@"忽略" options:UNNotificationActionOptionForeground];
        
        //UNNotificationCategoryOptionNone
        //UNNotificationCategoryOptionCustomDismissAction  清除通知被触发会走通知的代理方法
        //UNNotificationCategoryOptionAllowInCarPlay       适用于行车模式
        UNNotificationCategory *category1_ios10 = [UNNotificationCategory categoryWithIdentifier:@"category101" actions:@[action1_ios10,action2_ios10]   intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        NSSet *categories_ios10 = [NSSet setWithObjects:category1_ios10, nil];
        [center setNotificationCategories:categories_ios10];
    }
#endif
    //for log
    
    //注册远程通知
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)
    {
        UIRemoteNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        
        [application registerForRemoteNotificationTypes:type];
        [UMessage registerForRemoteNotifications];

    }else{
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [application registerUserNotificationSettings:setting];
        [UMessage registerForRemoteNotifications];

    }
    
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    NSLog(@"didFinishLaunchingWithOptions=%@",launchOptions);
    
    if (launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"]) {
        RongNotifyObj *obj = [[RongNotifyObj alloc] initWithDict:launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"][@"rc"]];
        [[AppDelegateModel sharedInstance] setRongNotifyObj:obj];
    }

 
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"didReceiveRemoteNotification=%@",userInfo);
    //关闭友盟自带的弹出框
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    if (userInfo[@"rc"]) {
        RongNotifyObj *obj = [[RongNotifyObj alloc] initWithDict:userInfo[@"rc"]];
        [self dealWithNotify:obj];
    }
}


- (void)didReceiveMessageNotification:(NSNotification *)notification {
    [UIApplication sharedApplication].applicationIconBadgeNumber =
    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
}

- (void)application:(UIApplication*)application
didReceiveLocalNotification:(UILocalNotification*)notification{
    NSLog(@"didReceiveLocalNotification=%@",notification);

//    dispatch_async(dispatch_get_main_queue(), ^{
//        isUpdateing = YES;
//        NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@", kHarpyAppID];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    });
}



- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"提示"
//                              message:@"您"
//                              @"的帐号在别的设备上登录，您被迫下线！"
//                              delegate:nil
//                              cancelButtonTitle:@"知道了"
//                              otherButtonTitles:nil, nil];
//        [alert show];
        AllPopView *popView = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"AccountHasLogined") clickedBlock:^(AllPopView * _Nonnull alertView, BOOL cancelled, NSInteger buttonIndex) {
            AppDelegate *dele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            UINavigationController *nav = (UINavigationController*)dele.window.rootViewController;
            UIViewController *topViewController = [nav topViewController];
            if ([topViewController isKindOfClass:NSClassFromString(@"LeftSlideViewController")]) {
                MainViewController *mainViewCtl = (MainViewController*)[[(MainTabBarController*)[(LeftSlideViewController*)topViewController mainVC] viewControllers] objectAtIndex:0];
                [mainViewCtl iKnowAction:nil];
            }
            [nav popToRootViewControllerAnimated:YES];
            if (!cancelled) {
                
            }
        } cancelButtonTitle:Local(@"Logout") otherButtonTitles:Local(@"ReLogin"), nil];
        [popView show];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    if ([[Harpy sharedInstance] shouldUpdateVersion]) {
//        if (isUpdateing) {
//            NSLog(@"isupdateing");
//            return;
//        }
        //版本升级
//        [UIApplication sharedApplication].applicationIconBadgeNumber
//        = 1;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UILocalNotification * localNotification = [[UILocalNotification alloc] init];
//            if (localNotification) {
//                localNotification.fireDate= [[[NSDate alloc] init] dateByAddingTimeInterval:3];
//                localNotification.timeZone=[NSTimeZone defaultTimeZone];
//                localNotification.alertBody = [NSString stringWithFormat:@"%@有新的版本，点击到App Store升级。",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]];
//                localNotification.alertAction = @"升级";
//                localNotification.soundName = @"";
//                [application scheduleLocalNotification:localNotification];
//            }
//        });
//    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    double delayInSeconds = 5.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [Harpy checkVersion];
//    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

-(void)notifyWeb{
    dispatch_async(dispatch_get_main_queue(), ^{
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown: {
                    NSLog(@"AFNetworkReachabilityStatusUnknown");
                    break;
                }
                case AFNetworkReachabilityStatusNotReachable: {
                    NSLog(@"AFNetworkReachabilityStatusNotReachable");
                    if (isNetAlert == NO) {
                        isNetAlert = YES;
                        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"NetWorkTitle") message:Local(@"NetWorkMsg") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex){
                            if (buttonIndex == 0) {
                                isNetAlert = NO;
                            }
                        }
                                                            cancelButtonTitle:Local(@"Sure") otherButtonTitles: nil];
                        [alert show];
                    }
                    
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWWAN: {
                    NSLog(@"AFNetworkReachabilityStatusReachableViaWWAN");
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] callViewController] offLineAction];
                        LonelyUser *user = [ViewModelCommom getCuttentUser];
                        if (user) {
                            [[(AppDelegate*)[[UIApplication sharedApplication] delegate] callViewController] onLineAction:user.sipid displayName:user.sipid andAuthName:@"" andPassword:user.password  andDomain:@""  andSIPServer:user.sipHost andSIPServerPort:[user.sipPort intValue]];
                        }
                    });
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    NSLog(@"AFNetworkReachabilityStatusReachableViaWiFi");
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] callViewController] offLineAction];
                        LonelyUser *user = [ViewModelCommom getCuttentUser];
                        if (user) {
                            [[(AppDelegate*)[[UIApplication sharedApplication] delegate] callViewController] onLineAction:user.sipid displayName:user.sipid andAuthName:@"" andPassword:user.password  andDomain:@""  andSIPServer:user.sipHost andSIPServerPort:[user.sipPort intValue]];
                        }
                    });
                    
                    break;
                }
                default: {
                    break;
                }
            }
        }];
        [manager startMonitoring];
    });
}


- (void)dealWithNotify:(RongNotifyObj*)obj {
    if (![obj.cType isEqualToString:@"PR"]) {
        return;
    }
    NSString *msgType = Local(@"GetAMsg");
    if (obj.oName && [obj.oName hasPrefix:@"RC:TxtMsg"]) {
        //文字消息
        msgType = [NSString stringWithFormat:@"%@%@",Local(@"GetA"),Local(@"TextMsg")];
    }else if(obj.oName && [obj.oName hasPrefix:@"RC:VcMsg"]){
        //语音消息
        msgType = [NSString stringWithFormat:@"%@%@",Local(@"GetA"),Local(@"VoiceMsg")];
        
    }else if(obj.oName && [obj.oName hasPrefix:@"RC:ImgMsg"]){
        //图片消息
        msgType = [NSString stringWithFormat:@"%@%@",Local(@"GetA"),Local(@"ImageMsg")];
        
    }
    
    AppDelegate *dele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //判断是不是聊天页
    UINavigationController *nav = (UINavigationController*)dele.window.rootViewController;
    NSLog(@"nav==%@",nav);
    if (![nav.topViewController isKindOfClass:[ChatViewController class]]){
        ChatViewController *chatVC = [[ChatViewController alloc] init];
        chatVC.conversationType = ConversationType_PRIVATE;
        chatVC.targetId = obj.fromId;
        chatVC.defaultInputType = RCChatSessionInputBarInputVoice;
        [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
        [(UINavigationController*)dele.window.rootViewController pushViewController:chatVC animated:YES];
    }
}


//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //必须加这句代码
        NSLog(@"User==%@",userInfo);
        if (userInfo[@"rc"]) {
            RongNotifyObj *obj = [[RongNotifyObj alloc] initWithDict:userInfo[@"rc"]];
            [self dealWithNotify:obj];
        }else{
            [UMessage didReceiveRemoteNotification:userInfo];
        }
        
        
        
    }else{
        //应用处于前台时的本地推送接受
        
        NSLog(@"应用处于前台时的本地推送接受User==%@",userInfo);
       if (userInfo[@"rc"]) {
           RongNotifyObj *obj = [[RongNotifyObj alloc] initWithDict:userInfo[@"rc"]];
           [self dealWithNotify:obj];
       }else{
           [UMessage didReceiveRemoteNotification:userInfo];
       }
    }
    
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        
        NSLog(@"User==%@",userInfo);
        if (userInfo[@"rc"]) {
            RongNotifyObj *obj = [[RongNotifyObj alloc] initWithDict:userInfo[@"rc"]];
            self.rongNotifyObj = obj;
            obj = nil;
        }else{
            [UMessage didReceiveRemoteNotification:userInfo];

        }
    }else{
        //应用处于后台时的本地推送接受
        //应用处于前台时的本地推送接受
        NSLog(@"应用处于后台时的本地推送接受User==%@",userInfo);
        if (userInfo[@"rc"]) {
            RongNotifyObj *obj = [[RongNotifyObj alloc] initWithDict:userInfo[@"rc"]];
            [self dealWithNotify:obj];
        }else {
            [UMessage didReceiveRemoteNotification:userInfo];
        }
    }
    
}


- (void)setEverSeen:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))serverBlock{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess setEvenSeen:user.userName andPassword:user.password andUserId:userId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serverBlock(dict,ret);
    }];
}


- (void)getUserInfoBySipId:(NSString*)sipId andBlock:(void(^)(NSDictionary *dict,BOOL ret))serverBlock {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getUserBySipId:user.userName andPassword:user.password andSipId:sipId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serverBlock(dict,ret);
    }];
}

@end
