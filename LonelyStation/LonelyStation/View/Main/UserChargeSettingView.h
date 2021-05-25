//
//  UserChargeSettingView.h
//  LonelyStation
//
//  Created by 钟铿 on 2017/12/25.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "EMView.h"
@protocol UserChargeSettingViewDelegate <NSObject>

- (void)didSelectCallChargeAction:(BOOL)ret;

- (void)didSelectmsgChargeAction:(BOOL)ret;

- (void)didSelectchatChargeChildAction:(NSString*)charge;

- (void)didSelectmsgChargeChildAction:(NSString*)charge;

@end

@interface UserChargeSettingView : EMView

@property (nonatomic,strong)EMButton *chatSwitchBtn;

@property (nonatomic,strong)EMLabel *chatlabel;

@property (nonatomic,strong)EMButton *msgSwitchBtn;

@property (nonatomic,strong)EMLabel *msglabel;

@property (nonatomic,assign)id<UserChargeSettingViewDelegate> aDelegate;

- (void)setChatSwithchOn:(BOOL)isOn;

- (void)setChatChildSelect:(NSString*)chatCharge;

- (void)setMsgSwithchOn:(BOOL)isOn;

- (void)setMsgChildSelect:(NSString*)chatCharge;


@end
