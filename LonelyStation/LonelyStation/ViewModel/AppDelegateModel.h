//
//  AppUpdateModel.h
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetAccess.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>
#import "RongNotifyObj.h"
#import "EMAlertView.h"

/**
 *  这里要写更新代码,默认是益米app
 */

@interface AppDelegateModel : NSObject<RCIMConnectionStatusDelegate>{
    BOOL isUpdateing;
    BOOL isNetAlert;
    NetAccess *_netAccess;
    EMAlertView *alertView;
}

@property (nonatomic,strong) RongNotifyObj *rongNotifyObj;

+ (AppDelegateModel *)sharedInstance;

- (void)dealWithNotify:(RongNotifyObj*)obj;

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)application:(UIApplication*)application
didReceiveLocalNotification:(UILocalNotification*)notification;

- (void)applicationWillResignActive:(UIApplication *)application;

- (void)applicationDidEnterBackground:(UIApplication *)application;

- (void)applicationWillEnterForeground:(UIApplication *)application;

- (void)applicationDidBecomeActive:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

- (void)getUserInfoBySipId:(NSString*)sipId andBlock:(void(^)(NSDictionary *dict,BOOL ret))serverBlock;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)setEverSeen:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))serverBlock;
@end
