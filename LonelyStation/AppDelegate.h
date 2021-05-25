//
//  AppDelegate.h
//  LonelyStation
//
//  Created by zk on 15/4/27.
//  Copyright (c) 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import <PortSIPLib/PortSIPSDK.h>
#import "CallViewController.h"
//#import "AppCallKitManager.h"

//@interface AppDelegate : UIResponder <UIApplicationDelegate>
@interface AppDelegate : UIResponder <UIApplicationDelegate,PortSIPEventDelegate>
{
    PortSIPSDK *portSIPSDK;
    BOOL        sipRegistered;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CallViewController *callViewController;
@property (nonatomic, assign) BOOL isConference;
@property (nonatomic,assign)    BOOL isReceieveCall;
@property (nonatomic,assign)    BOOL isRecording;


- (void)answerCallCompletion:(void (^)(void))completion failblock:(void (^)(void))failblock;
- (void)rejectCallCompletion:(void (^)(void))completion;
- (void)makeCall:(NSString*)callee videoCall:(BOOL)videoCall;
- (void)muteCall:(BOOL)mute;
- (void)setLoudspeakerStatus:(BOOL)enable;

-(BOOL) setSpeakerEnabled:(BOOL)enabled;
- (void)hungupCall:(void (^)(void))completion;


@end

