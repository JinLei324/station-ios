//
//  AudioPlayerVM.h
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@protocol EMAudioPlayerDelegate <NSObject>

- (void)didStopAudio;

- (void)didUpdateAudio:(float)time andValue:(NSString*)value;

@end


//专用音频播放的类
@interface AudioPlayerVM : EMObject

@property(nonatomic,assign)id<EMAudioPlayerDelegate> delegate;

@property (nonatomic,assign)BOOL isPlaying;

- (void)playAudio:(NSString*)path andTime:(int)time;

- (void)stopAudioPlay;

- (void)playAudios:(NSString*)urlBack andBlock:(void(^)(float currentTime,float allTime,BOOL isStop))audioBlock isBackRemote:(BOOL)isRemote andOthers:(NSArray*)urlArray andTimeArray:(NSArray*)timeArr andAllTime:(NSString*)allTime;

- (void)playRemoteAudio:(NSString*)urlStr andBlock:(void(^)(float currentTime,float allTime,BOOL isStop))audioBlock andAllTime:(NSString*)allTime;

- (void)stopRemoteAudio;

- (void)slideStartToChange;

- (void)slideToEnd:(int)value;

- (void)playNewAudio:(NSString *)path;


@end
