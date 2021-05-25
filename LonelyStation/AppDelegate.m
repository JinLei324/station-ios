//
//  AppDelegate.m
//  LonelyStation
//
//  Created by zk on 15/4/27.
//  Copyright (c) 2015年 zk. All rights reserved.
//


#import "AppDelegate.h"
#import "LonelyStation.h"
#import "CALayer+Transition.h"
#import "AppDelegateModel.h"
#import "EMNavigationController.h"
#import "LoginStatusObj.h"
#import "LoginViewController.h"
#import "MainTabBarController.h"
#import "LeftSortsViewController.h"
#import "CallViewController.h"
#import "Session.h"
#import "SoundService.h"
#import "ViewModelCommom.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>
#import "LoginViewModel.h"
#import <UserNotifications/UserNotifications.h>

//#import "AppCallKitManager.h"
#import "UIUtil.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
{
    SoundService *_mSoundService;
    Session      *sessionSipSDk;
    LoginViewModel *_loginViewModel;
    BOOL isSelfSystemCall;
    
}

@property (nonatomic, assign) BOOL inForeground;
@end

@implementation AppDelegate

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController *rootVC = window.rootViewController;
    if ([rootVC.presentedViewController
         isKindOfClass:NSClassFromString(@"AVFullScreenViewController")] ||
        [rootVC isKindOfClass:NSClassFromString(@"AVPlayerViewController")]) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        
        if (granted) {
            
            // 用户同意获取麦克风
            
        } else {
            
            // 用户不同意获取麦克风
            [UIUtil showDeviceWarning];
        }
    }];
    
    
    [[AppDelegateModel sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    self.inForeground = true;
    _loginViewModel = [[LoginViewModel alloc] init];
    
    //SIP SDK init
    _mSoundService = [[SoundService alloc] init];
    portSIPSDK = [[PortSIPSDK alloc] init];
    portSIPSDK.delegate = self;
    
    sessionSipSDk = [[Session alloc] init];
    self.callViewController = [[CallViewController alloc] init];
    self.callViewController->mPortSIPSDK = portSIPSDK;
    
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
    [cache.diskCache removeAllObjects];
    
//    [[AppCallKitManager sharedInstance] setDelegate:self.callViewController];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window = window;
    
    //判断是否需要显示：（内部已经考虑版本及本地版本缓存）
//    BOOL canShow = [LonelyStation canShowNewFeature];
    
    //测试代码，正式版本应该删除
//        canShow = YES;
    
//    if(canShow){
//
//        NewFeatureModel *m1 = [NewFeatureModel model:[UIImage imageNamed:Local(@"F1")]];
//
//        NewFeatureModel *m2 = [NewFeatureModel model:[UIImage imageNamed:Local(@"F2")]];
//
//        NewFeatureModel *m3 = [NewFeatureModel model:[UIImage imageNamed:Local(@"F3")]];
//        window.rootViewController = [LonelyStation newFeatureVCWithModels:@[m1,m2,m3] enterBlock:^{
//            DLog(@"进入主页面,%@",NSLocalizedStringFromTable(@"HomePage", @"Localization", nil));
//            [self enter];
//        }];
//    }
//    else{
        [self enter];
//    }
    
    
    
    [window makeKeyAndVisible];
    return YES;
}


-(void)enter {
    //    LoginStatusObj *loginStatus = [[LoginStatusObj alloc] init];
    //    loginStatus.isLogined = NO;
    //    loginStatus.shouldGetUserMsg = YES;
    //    [[FileAccessData sharedInstance] setAObject:loginStatus forEMKey:@"LoginStatus"];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus && loginStatus.isLogined) {
        //show main
        LoginViewController *loginViewCtl = [[LoginViewController alloc] init];
        loginViewCtl.isHiddenNavigationBar = YES;
        
        EMNavigationController *nav = [[EMNavigationController alloc] initWithRootViewController:loginViewCtl];
        self.window.rootViewController = nav;
        
        MainTabBarController *mainTab = [[MainTabBarController alloc] init];
        mainTab.isShowAnimation = YES;
        mainTab.isHiddenNavigationBar = YES;
        
        LeftSortsViewController *leftVC = [[LeftSortsViewController alloc] init];
        LeftSlideViewController *leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:mainTab];
        mainTab.slideViewCtl = leftSlideVC;
        [nav pushViewController:leftSlideVC animated:NO];
        mainTab = nil;
        
        
    }else{
        //show login
        LoginViewController *loginViewCtl = [[LoginViewController alloc] init];
        loginViewCtl.isHiddenNavigationBar = YES;
        EMNavigationController *nav = [[EMNavigationController alloc] initWithRootViewController:loginViewCtl];
        self.window.rootViewController = nav;
    }
    
    //    [self.window.layer transitionWithAnimType:TransitionAnimTypeRamdom subType:TransitionSubtypesFromRamdom curve:TransitionCurveRamdom duration:2.0f];
}


- (void)handleInterruption: (NSNotification*) notification
{
    if(notification.name != AVAudioSessionInterruptionNotification
       || notification.userInfo == nil){
        return;
    }
    
    UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    NSLog(@"Session interrupted > --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
    
    if (theInterruptionType == AVAudioSessionInterruptionTypeBegan && isSelfSystemCall) {
        [self.callViewController setTouchMuteTrue];
    }
}


- (void)holdAllCall
{
    [portSIPSDK hold:sessionSipSDk.sessionId];
    NSLog(@"holdAllCall...");
}


- (void)unholdCall
{
    [portSIPSDK unHold:sessionSipSDk.sessionId];
    NSLog(@"unholdAllCall...");
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification");
    [[AppDelegateModel sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification {
    NSLog(@"didReceiveLocalNotification");
    [[AppDelegateModel sharedInstance] application:application didReceiveLocalNotification:notification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    [[AppDelegateModel sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //如果正在录音，不能用这句代码，否则不能后台录音
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSLog(@"AVAudioSession===%@",session);

    if (!self.isRecording) {
        [portSIPSDK startKeepAwake];
    }
    NSLog(@"applicationDidEnterBackground");
    [[AppDelegateModel sharedInstance] applicationDidEnterBackground:application];
    self.inForeground = false;
    
//    //start background task
//    __block UIBackgroundTaskIdentifier background_task;
//    
//    //background task running time differs on different iOS versions.
//    //about 10 mins on early iOS, but only 3 mins on iOS7.
//    background_task = [application beginBackgroundTaskWithExpirationHandler: ^{
//        
//        [application endBackgroundTask:background_task];
//        background_task = UIBackgroundTaskInvalid;
//        //end.
//    }];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (true) {
//            float remainingTime = [application backgroundTimeRemaining];
//            if (remainingTime <= 3*60) {
//                NSLog(@"remaining background time:%f", remainingTime);
//                [NSThread sleepForTimeInterval:1.0];
//                if (remainingTime <= 3.0 || self.inForeground) {
//                    break;
//                }
//            }
//            else
//            {
//                break;
//            }
//        }
//        
//        [application endBackgroundTask:background_task];
//        background_task = UIBackgroundTaskInvalid;
//    });

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    self.inForeground = true;
    [portSIPSDK stopKeepAwake];
    //判断有没有在通话
    if (!_isReceieveCall) {
        //先下线，再上线
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            LonelyUser *user = [ViewModelCommom getCuttentUser];
            //下线sip
            [[self callViewController] offLineAction];
            //下线融云
            [[RCIM sharedRCIM] disconnect];
            if (user) {
                [[self callViewController] onLineAction:user.sipid displayName:user.sipid andAuthName:@"" andPassword:user.password  andDomain:@""  andSIPServer:user.sipHost andSIPServerPort:[user.sipPort intValue]];
                //上线融云
                [[RCIM sharedRCIM] connectWithToken:user.imtoken success:^(NSString *userId) {
                   //通知服务器
                    [_loginViewModel login:user.userName andPwd:user.password andFlag:@"1" andBlock:^(NSDictionary *dict, BOOL ret) {
                        NSLog(@"applicationWillEnterForeground dict=%@",dict);
                    }];
                } error:^(RCConnectErrorCode status) {
                    
                } tokenIncorrect:^{
                    
                }];
                
            }
        });
    }
    [[AppDelegateModel sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setSpeakerEnabled:YES];
    [[AppDelegateModel sharedInstance] applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[AppDelegateModel sharedInstance] applicationWillTerminate:application];
}

#pragma mark - SIPSDK Custom Methods



- (void)makeCall:(NSString*)callee videoCall:(BOOL)videoCall {
    if(sessionSipSDk.sessionState || sessionSipSDk.recvCallState) {
        NSLog(@"Current line is busy now, please switch a line");
        return;
    }
    portSIPSDK.delegate = self;
    long sessionId = [portSIPSDK call:callee sendSdp:YES videoCall:videoCall];
    if(sessionId >= 0) {
        sessionSipSDk.sessionId = sessionId;
        sessionSipSDk.sessionState = YES;
        sessionSipSDk.videoState = videoCall;
//        [self setSpeakerEnabled:NO];
        [_mSoundService playRingTone];
        [self performSelector:@selector(setQuite) withObject:nil afterDelay:1];
        NSLog(@"Calling:%@", callee);
    }
    else {
        NSLog(@"make call failure ErrorCode =%ld", sessionId);
    }
    
    if (sessionSipSDk.isReferCall)
    {
        
        sessionSipSDk.isReferCall = NO;
        sessionSipSDk.originCallSessionId = -1;
    }
    
}


- (void)setQuite {
    [self setLoudspeakerStatus:NO];
    [self setLoudspeakerStatus:YES];
    [self setLoudspeakerStatus:NO];
}

-(BOOL) setSpeakerEnabled:(BOOL)enabled{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    AVAudioSessionCategoryOptions options = session.categoryOptions;
    
    if (enabled) {
        options |= AVAudioSessionCategoryOptionDefaultToSpeaker;
    } else {
        options &= ~AVAudioSessionCategoryOptionDefaultToSpeaker;
    }
    
    NSError* error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:options
                   error:&error];
    [session setActive:YES error:&error];

    if (error != nil) {
        return NO;
    }
    return YES;
}


- (void)muteCall:(BOOL)mute {
    if(sessionSipSDk.sessionState){
        if(mute) {
            [portSIPSDK muteSession:sessionSipSDk.sessionId
                  muteIncomingAudio:YES
                  muteOutgoingAudio:YES
                  muteIncomingVideo:YES
                  muteOutgoingVideo:YES];
        }
        else {
            [portSIPSDK muteSession:sessionSipSDk.sessionId
                  muteIncomingAudio:NO
                  muteOutgoingAudio:NO
                  muteIncomingVideo:NO
                  muteOutgoingVideo:NO];
        }
    }
}

- (void)setLoudspeakerStatus:(BOOL)enable {
    [portSIPSDK setLoudspeakerStatus:enable];
}

- (void)answerCallCompletion:(void (^)(void))completion failblock:(void (^)(void))failblock{
    [_mSoundService stopRingTone];
    int nRet = [portSIPSDK answerCall:sessionSipSDk.sessionId videoCall:NO];
    if (nRet == 0) {
        sessionSipSDk.sessionState = YES;
        sessionSipSDk.videoState = NO;
        if (completion) {
            completion();
        }
    }
    else {
        [sessionSipSDk reset];
        if (failblock) {
            failblock();
        }
    }
}

- (void)rejectCallCompletion:(void (^)(void))completion {
    [_mSoundService stopRingTone];
    [portSIPSDK rejectCall:sessionSipSDk.sessionId code:486];
    [sessionSipSDk reset];
    if (completion) {
        completion();
    }
}

- (void)hungupCall:(void (^)(void))completion {
    [_mSoundService stopRingTone];
    [portSIPSDK hangUp:sessionSipSDk.sessionId];
    [sessionSipSDk reset];
    if (completion) {
        completion();
    }
}


#pragma mark - SIPSDK Delegate Methods

/*!
 *  When successfully register to server, this event will be triggered.
 *
 *  @param statusText The status text.
 *  @param statusCode The status code.
 */

- (void)onRegisterSuccess:(char*) statusText statusCode:(int)statusCode {
    NSLog(@"onRegisterSuccess==%@",[NSString stringWithCString:statusText encoding:NSASCIIStringEncoding]);
    sipRegistered = YES;
}

/*!
 *  If register to SIP server is fail, this event will be triggered.
 *
 *  @param statusText The status text.
 *  @param statusCode The status code.
 */
- (void)onRegisterFailure:(char*) statusText statusCode:(int)statusCode {
    NSLog(@"onRegisterFailure===%@",[NSString stringWithCString:statusText encoding:NSASCIIStringEncoding]);
    sipRegistered = NO;
}




/** @} */ // end of group21

/** @defgroup group22 Call events
 * @{
 */

/*!
 *  When the call is coming, this event was triggered.
 *
 *  @param sessionId         The session ID of the call.
 *  @param callerDisplayName The display name of caller
 *  @param caller            The caller.
 *  @param calleeDisplayName The display name of callee.
 *  @param callee            The callee.
 *  @param audioCodecs       The matched audio codecs, it's separated by "#" if have more than one codec.
 *  @param videoCodecs       The matched video codecs, it's separated by "#" if have more than one codec.
 *  @param existsAudio       If it's true means this call include the audio.
 *  @param existsVideo       If it's true means this call include the video.
 */
- (void)onInviteIncoming:(long)sessionId
       callerDisplayName:(char*)callerDisplayName
                  caller:(char*)caller
       calleeDisplayName:(char*)calleeDisplayName
                  callee:(char*)callee
             audioCodecs:(char*)audioCodecs
             videoCodecs:(char*)videoCodecs
             existsAudio:(BOOL)existsAudio
             existsVideo:(BOOL)existsVideo {
    
    NSLog(@"callerDisplayName = %s caller = %s calleeDisplayName = %s callee = %s ",callerDisplayName,caller,calleeDisplayName,callee);
    
    if(!sessionSipSDk.sessionState && !sessionSipSDk.recvCallState) {
        sessionSipSDk.recvCallState = YES;
    }
    else {
        [portSIPSDK rejectCall:sessionId code:486];
        return ;
    }
    _isReceieveCall = YES;
    NSString *sipId = [NSString stringWithFormat:@"%s",callerDisplayName];
    [[AppDelegateModel sharedInstance] getUserInfoBySipId:sipId andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            sessionSipSDk.sessionId = sessionId;
            sessionSipSDk.sessionState = existsVideo;
            
            NSLog(@"Incoming call:%s",caller );
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//            [_mSoundService playRingTone];
            NSString *name = @"";
            if (![dict[@"data"] isEqual:[NSNull null]]) {
                name = dict[@"data"][@"nickname"];
            }
            [_mSoundService playRingTone];
            if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
                if (!IsiOS10Later) {
                    UILocalNotification* localNotif = [[UILocalNotification alloc] init];
                    if (localNotif){
                        localNotif.alertBody =[NSString  stringWithFormat:@"%@ calling", name];
                        localNotif.soundName = @"ringlong.mp3";
                        localNotif.applicationIconBadgeNumber = 1;
                        
                        // In iOS 8.0 and later, your application must register for user notifications using -[UIApplication registerUserNotificationSettings:] before being able to schedule and present UILocalNotifications
                        [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
                    }
                }
            }
            
            if(existsVideo) {//video call
                NSLog(@"Video call incoming ");
            }else {
                self.callViewController.callStatus = CallIncoming;
                LonelyUser *user = [[LonelyUser alloc] init];
                if (![dict[@"data"] isEqual:[NSNull null]]) {
                    user.nickName = NOTNULLObj(dict[@"data"][@"nickname"]);
                    user.userID = NOTNULLObj(dict[@"data"][@"userid"]);
                    user.file = NOTNULLObj(dict[@"data"][@"file"]);
                }
               
                self.callViewController.toUser = [ViewModelCommom getCuttentUser];
                self.callViewController.fromUser = user;
                [self.window.rootViewController presentViewController:self.callViewController animated:YES completion:^{
                    // TODO: something
                }];
            }
            if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground){
                //发一个本地通知
                [self addlocalNotificationForNewVersion:NOTNULLObj(dict[@"data"][@"nickname"])];
                
//                if (IsiOS10Later) {
//                    NSLog(@"callerDisplayName==%@",sipId);
//                    isSelfSystemCall = YES;
//                    NSString *aSipId = sipId;
//                    if (aSipId.length > 7) {
//                       aSipId = [sipId substringWithRange:NSMakeRange(aSipId.length-7, 7)];
//                    }
//                    [[AppCallKitManager sharedInstance] showCallInComingWithName:name andPhoneNumber:@"voicelover" isVideoCall:false];
//                }
            }
        }else {
            [portSIPSDK rejectCall:sessionId code:486];
            [sessionSipSDk reset];
        }
    }];
}


- (void)addlocalNotificationForNewVersion:(NSString*)name {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.body = [NSString  stringWithFormat:@"%@ calling", name];;
    content.sound = [UNNotificationSound soundNamed:@"ringlong.mp3"];
    
    //    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alertTime repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"OXNotification" content:content trigger:nil];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"成功添加推送");
    }];
}

#pragma mark - UNUserNotificationCenterDelegate
// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", body);
        
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
      
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}


- (void)onInviteFailure:(long)sessionId
                 reason:(char*)reason
                   code:(int)code {
    DLog(@"asdasd");
    _isReceieveCall = NO;
    if (isSelfSystemCall) {
        isSelfSystemCall = NO;
//        [[AppCallKitManager sharedInstance] finshCallWithReason:CXCallEndedReasonRemoteEnded];
    }
    [self.callViewController back:nil];
}


- (void)onInviteAnswered:(long)sessionId
       callerDisplayName:(char*)callerDisplayName
                  caller:(char*)caller
       calleeDisplayName:(char*)calleeDisplayName
                  callee:(char*)callee
             audioCodecs:(char*)audioCodecs
             videoCodecs:(char*)videoCodecs
             existsAudio:(BOOL)existsAudio
             existsVideo:(BOOL)existsVideo  {
    DLog(@"onInviteAnswered");
    _isReceieveCall = YES;
    [_mSoundService stopRingTone];
    [self.callViewController setConnecting:YES];
    //加上曾经听过
    NSString *sipId = [NSString stringWithFormat:@"%s",callerDisplayName];
    [[AppDelegateModel sharedInstance] getUserInfoBySipId:sipId andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            NSString *userId = NOTNULLObj(dict[@"data"][@"userid"]);
            [[AppDelegateModel sharedInstance] setEverSeen:userId andBlock:^(NSDictionary *dict, BOOL ret) {
                
            }];
        }
    }];
}
- (void)onInviteTrying:(long)sessionId
{
    DLog(@"onInviteTrying");
    
}

- (void)onInviteRinging:(long)sessionId
             statusText:(char*)statusText
             statusCode:(int)statusCode {
    DLog(@"onInviteRinging");
    
}


- (void)onInviteSessionProgress:(long)sessionId
                    audioCodecs:(char*)audioCodecs
                    videoCodecs:(char*)videoCodecs
               existsEarlyMedia:(BOOL)existsEarlyMedia
                    existsAudio:(BOOL)existsAudio
                    existsVideo:(BOOL)existsVideo {
    DLog(@"onInviteSessionProgress");
    
}


- (void)onRemoteHold:(long)sessionId {
    NSLog(@"onRemoteHold");
    _isReceieveCall = NO;

}

- (void)onRemoteUnHold:(long)sessionId
           audioCodecs:(char*)audioCodecs
           videoCodecs:(char*)videoCodecs
           existsAudio:(BOOL)existsAudio
           existsVideo:(BOOL)existsVideo {
    NSLog(@"onRemoteUnHold");

}

- (void)onInviteClosed:(long)sessionId {
    NSLog(@"onInviteClosed===%d",isSelfSystemCall);
    _isReceieveCall = NO;
    if (isSelfSystemCall) {
        isSelfSystemCall = NO;
//        [[AppCallKitManager sharedInstance] finshCallWithReason:CXCallEndedReasonRemoteEnded];
    }
    [self.callViewController back:nil];
}

- (void)onInviteConnected:(long)sessionId {
    DLog(@"onInviteConnected");
    _isReceieveCall = YES;
    
}

- (void)onReferRejected:(long)sessionId reason:(char*)reason code:(int)code {
    NSLog(@"onReferRejected");
    if (isSelfSystemCall) {
        isSelfSystemCall = NO;
//        [[AppCallKitManager sharedInstance] finshCallWithReason:CXCallEndedReasonRemoteEnded];
    }
    _isReceieveCall = NO;
    [self.callViewController back:nil];
}

@end
