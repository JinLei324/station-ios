//
//  DouAudioPlayer.h
//  PlayerTest
//
//  Created by zk on 2016/10/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DouTrackObj.h"


@protocol DouAudioPlayerDelegate <NSObject>

- (void)didBuffering:(double)recievedLength andAllLength:(double)allLength andBufferRatio:(double)bufferingRatio andBufferSpeed:(double)downloadSpeed;

- (void)didPlayingCurrentTime:(double)currentTime andAllTime:(double)allTime;

- (void)didPlayFinished;

@end

@interface DouAudioPlayer : NSObject


@property (nonatomic,assign)id<DouAudioPlayerDelegate> delegate;

@property (nonatomic,assign)double volume;

@property (nonatomic,assign)double currentValue;

@property (nonatomic,assign)NSTimeInterval allTime;

@property (nonatomic,assign)BOOL   isPlayFinish;

- (void)startPlayTime:(double)time andURL:(NSString*)url;

- (void)startPlay:(NSString*)url;

- (void)pause;

- (void)stop;

- (void)startPlayValue:(double)value;

@end
