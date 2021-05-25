//
//  UserSettingView.h
//  LonelyStation
//
//  Created by zk on 2016/11/27.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMView.h"
#import "NMRangeSlider.h"

@protocol UserSettingViewDelegate <NSObject>

- (void)didSelectAction:(BOOL)ret;


- (void)didChangeSlider:(NSString*)start;

@end


@interface UserSettingView : EMView

@property (nonatomic,strong)EMButton *aSwitchBtn;

@property (nonatomic,strong)EMLabel *label;

@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)NMRangeSlider *nmSlider;

@property (nonatomic,copy)NSString *startTime;

@property (nonatomic,copy)NSString *endTIme;


@property (nonatomic,assign)id<UserSettingViewDelegate> aDelegate;


@end
