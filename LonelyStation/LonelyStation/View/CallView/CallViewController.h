//
//  CallViewController.h
//  LonelyStation
//
//  Created by mac on 16/7/3.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PortSIPLib/PortSIPSDK.h>
#import "EMViewController.h"
#import "LonelyStationUser.h"
#import "CallViewVM.h"
//#import "AppCallKitManager.h"

typedef NS_ENUM(NSInteger,CallViewStatus) {
    CallIncoming = 0,
    CallOut
};

@interface CallViewController : EMViewController {
@public
    PortSIPSDK *mPortSIPSDK;
}


@property (nonatomic,strong)LonelyUser *fromUser;  //打出人
@property (nonatomic,strong)LonelyUser *toUser;    //接电话的人
@property (nonatomic,assign)CallViewStatus callStatus;

@property (nonatomic,strong)NSMutableArray *blindUserArray;
@property (nonatomic,assign)BOOL isBlind;//是否为盲目通话


// touch button action
- (void)touchRejectButton:(id)sender;
- (void)touchAnswerButton:(id)sender;
- (void)touchMuteButton:(id)sender;
- (void)touchSpeakerBUtton:(id)sender;
- (void)touchVideoInviteButton:(id)sender;
- (void)setTouchMuteTrue;


//上线
- (BOOL)onLineAction:(NSString*)kUserName displayName:(NSString*)kDisplayName andAuthName:(NSString*)kAuthName andPassword:(NSString*)kPassword andDomain:(NSString*)kUserDomain andSIPServer:(NSString*)kSIPServer andSIPServerPort:(int)kSIPServerPort;

//下线
- (void)offLineAction;

- (void)setConnecting:(BOOL)ret;

@end
