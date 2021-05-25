//
//  AudioPlayView.h
//  Test
//
//  Created by zk on 16/8/26.
//  Copyright © 2016年 zk. All rights reserved.
//  把本地播放和远程播放结合起来，用一个view来解决
//

#import <UIKit/UIKit.h>

@interface AudioPlayView : UIView

typedef void(^audioBlock)(float currentTime,float allTime,BOOL isStop);

typedef NS_ENUM(NSInteger, ZKAudioType) {
    ZKAudioTypeLocal = 10,
    ZKAudioTypeMixed,
    ZKAudioTypeRemote
};

@property (nonatomic,assign)ZKAudioType zkAudioType;

@property (nonatomic,assign)BOOL isAudioPlaying;//是否在播放

@property (nonatomic,assign)BOOL isShowLabel;//是否在播放

@property (nonatomic,assign)int allTime;

@property (nonatomic,copy)NSString *leftValue;

@property (nonatomic,copy)NSString *rightValue;

@property(nonatomic,assign)float currentPlayTime;


@property (nonatomic,assign)float effectVolume;

//播放本地Audio
- (void)playLocalAudio:(NSString*)path andBlock:(audioBlock)block;

- (void)stopLocalAudio;

- (void)resetLocalAudio;

//播放远程Audio
- (void)playRemoteAudio:(NSString*)urlPath andBlock:(void(^)(float currentTime,float allTime,BOOL isStop))audioBlock andAllTime:(NSString*)allTime;

//播放多个Audio,如果背景音是远程的，isRemote就是YES
- (void)playAudios:(NSString*)urlBack andBlock:(void(^)(float currentTime,float allTime,BOOL isStop))audioBlock isBackRemote:(BOOL)isRemote andOthers:(NSArray*)urlArray andTimeArray:(NSArray*)timeArr andAllTime:(NSString*)allTime;

//关闭远程Audio
- (void)stopRemoteAudio;

- (void)resetRemoteAudio;


@end
