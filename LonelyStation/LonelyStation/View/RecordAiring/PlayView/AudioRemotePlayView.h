//
//  AudioRemotePlayView.h
//  PlayerTest
//
//  Created by zk on 2016/10/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^audioBlock)(float currentTime,float allTime,BOOL isStop);

@interface AudioRemotePlayView : UIView

@property (nonatomic,assign)BOOL isAudioPlaying;//是否在播放

@property (nonatomic,assign)BOOL isShowLabel;//是否显示左右的时间

@property (nonatomic,assign)int allTime;

@property (nonatomic,copy)NSString *leftValue;

@property (nonatomic,copy)NSString *rightValue;

@property (nonatomic,copy)audioBlock audioBok;


@property (nonatomic,assign)float effectVolume;

- (void)playRemoteAudio:(NSString*)urlPath;

- (void)pauseRemoteAudio;

- (void)reallyStop;

- (void)stopRemoteAudio;

- (void)playRemoteAudios:(NSString*)urlPath isBackRemote:(BOOL)isRemote andOthers:(NSArray*)urlArray andTimeArray:(NSArray*)timeArr;

- (void)resetAll;



@end
