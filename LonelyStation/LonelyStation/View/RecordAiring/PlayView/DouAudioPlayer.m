//
//  DouAudioPlayer.m
//  PlayerTest
//
//  Created by zk on 2016/10/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "DouAudioPlayer.h"
#import "DOUAudioStreamer.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;


@interface DouAudioPlayer() {
    DOUAudioStreamer *_streamer;
    BOOL _isAddOberserver;
    NSTimer *_timer;
    double lastPlayTime;
    DouTrackObj *_douTrackObj;
 
    NSString *_urlPath;
}

@end


@implementation DouAudioPlayer


- (void)setVolume:(double)volume {
    _volume = volume;
    if (_streamer) {
        [_streamer setVolume:volume];
    }
}

//开始播放
- (void)startPlay:(NSString*)url {
    if (_streamer) {
        if ([_streamer status] == DOUAudioStreamerFinished){
            if (_isAddOberserver) {
                [self removeOber];
                _isAddOberserver = NO;
            }
        }
        [_streamer stop];
        _streamer = nil;
        _douTrackObj = nil;
    }
    _isPlayFinish = NO;
    _urlPath = url;
    _douTrackObj = [[DouTrackObj alloc] init];
    _douTrackObj.audioFileURL = [NSURL URLWithString:url];
    _streamer = [DOUAudioStreamer streamerWithAudioFile:_douTrackObj];
    [self addPlayOber];
    [self removeAudioTimer];
    [self createAudioTimer];
    [_streamer play];
    
}

- (void)startPlayValue:(double)value {
    if (_streamer) {
        if ([_streamer status] == DOUAudioStreamerFinished){
            if (_isAddOberserver) {
                [self removeOber];
                _isAddOberserver = NO;
            }
            _streamer = nil;
            _douTrackObj = nil;
            _douTrackObj = [[DouTrackObj alloc] init];
            _douTrackObj.audioFileURL = [NSURL URLWithString:_urlPath];
            _streamer = [DOUAudioStreamer streamerWithAudioFile:_douTrackObj];
            [self addPlayOber];
            [self removeAudioTimer];
            [self createAudioTimer];
            [_streamer setCurrentTime:value * _streamer.duration];
            [_streamer play];
        }else{
            [_streamer setCurrentTime:value * _streamer.duration];
            [self createAudioTimer];
            [_streamer play];
        }
    }
}


//创建定时器
- (void)createAudioTimer {
    if (!_timer) { // 定时器
        _timer = [[NSTimer alloc] init];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}


- (void)removeAudioTimer {
    if (_timer) {
        [_timer invalidate];
    }
    _timer = nil;
}


//添加播放观察者
- (void)addPlayOber {
    if (_isAddOberserver) {
        [self removeOber];
    }
    [self addOber];
}

//添加观察者
- (void)addOber {
    _isAddOberserver = YES;
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
}

//移除观察者
- (void)removeOber {
    @try {
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"duration"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];    }
    @catch (NSException *exception) {
        NSLog(@"多次删除了");
    }
    _isAddOberserver = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(_timerAction)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)_updateStatus {
    if ([_streamer status] == DOUAudioStreamerFinished) {
        _isPlayFinish = YES;
        _currentValue = 0;
        if (_delegate && [_delegate respondsToSelector:@selector(didPlayFinished)]) {
            [_delegate didPlayFinished];
        }
    }
}

- (void)_timerAction{
    if (_allTime == 0) {
        _allTime = [_streamer duration];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didPlayingCurrentTime:andAllTime:)]) {
        [_delegate didPlayingCurrentTime:[_streamer currentTime] andAllTime:_allTime];
    }
    double currentTime = [_streamer currentTime];
    _currentValue = currentTime;
    if (currentTime >= _allTime-0.5) {
        [self removeAudioTimer];
    }
    
}

- (void)_updateBufferingStatus {
    if (_delegate && [_delegate respondsToSelector:@selector(didBuffering:andAllLength:andBufferRatio:andBufferSpeed:)]) {
        double recieve = (double)[_streamer receivedLength] / 1024 / 1024;
        double all = (double)[_streamer expectedLength] / 1024 / 1024;
        double buffering = (double)[_streamer bufferingRatio] / 1024 / 1024;
        double downLoadSpeed = (double)[_streamer downloadSpeed] / 1024 / 1024;
        [_delegate didBuffering:recieve andAllLength:all andBufferRatio:buffering andBufferSpeed:downLoadSpeed];
    }
}


- (void)startPlayTime:(double)time andURL:(NSString*)url{
    if ([url isEqualToString:_urlPath]) {
        //是同一个，如果没播完，就暂停，然后播放；
        if (_streamer) {
            if ([_streamer status] == DOUAudioStreamerFinished){
                if (_isAddOberserver) {
                    [self removeOber];
                    _isAddOberserver = NO;
                }
                _streamer = nil;
                _douTrackObj = nil;
                _isPlayFinish = NO;
                _douTrackObj = [[DouTrackObj alloc] init];
                _douTrackObj.audioFileURL = [NSURL URLWithString:_urlPath];
                _streamer = [DOUAudioStreamer streamerWithAudioFile:_douTrackObj];
                [self addPlayOber];
                [self removeAudioTimer];
                [self createAudioTimer];
                [_streamer setCurrentTime:time];
                [_streamer play];
            }else{
                _isPlayFinish = NO;
                [_streamer setCurrentTime:time];
                [self createAudioTimer];
                [_streamer play];
            }
        }else {
           [self startPlay:url];
        }
    }else {
        //不是同一个，直接播放
        [self stop];
        [self startPlay:url];
    }
}


//暂停
- (void)pause {
    if (_streamer) {
        [_streamer pause];
    }
    [self removeAudioTimer];
}

//停止
- (void)stop {
    if (_streamer) {
        [_streamer stop];
        _allTime = 0;
    }
    [self removeAudioTimer];
    if (_isAddOberserver) {
        [self removeOber];
    }
}

- (void)dealloc {
    if (_streamer) {
        [_streamer stop];
        _streamer = nil;
    }
    if (_isAddOberserver) {
        [self removeOber];
    }
    [self removeAudioTimer];
}


@end
