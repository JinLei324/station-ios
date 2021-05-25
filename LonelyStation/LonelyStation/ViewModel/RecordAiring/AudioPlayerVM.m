//
//  AudioPlayerVM.m
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AudioPlayerVM.h"
#import <AudioToolbox/AudioFile.h>
#import "AudioPublicMethod.h"
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "VIMediaCache.h"



@interface AudioPlayerVM() {
    AVAudioPlayer *_tempPlayer;
    NSTimer *_playerTimer;
    NSTimer *_moveSetTimer;
    int timerIndex;
    int countIndex;
    
    VIResourceLoaderManager *resourceLoaderManager;
    VIResourceLoaderManager *leftResourceLoaderManager;
    VIResourceLoaderManager *rightResourceLoaderManager;
    
    AVPlayer *leftPlayer;
    AVPlayerItem *leftPlayerItem;
    AVPlayer *rightPlayer;
    AVPlayerItem *rightPlayerItem;
    
    
    //重写的本地播放器
    id mTimeObserver;
    CGFloat sliderDragBeginTime;
    BOOL isAudioPlaying;
    NSString *localPath;
}

@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayerItem *playerItem;


//重写的本地播放器
@property (nonatomic, strong) NSTimer  *audioTimer; // 播放定时器

@end
@implementation AudioPlayerVM


//播放录音
- (void)playAudio:(NSString*)path andTime:(int)time{
    if (path!=nil) {
        if (_playerTimer) {
            [_playerTimer invalidate];
            _playerTimer=nil;
        }
        if (_moveSetTimer) {
            [_moveSetTimer invalidate];
            _moveSetTimer = nil;
        }
        
        NSString *currPath = [[AudioPublicMethod getPathByFileName:path ofType:@"wav"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *tempUrl = [NSURL URLWithString:currPath];
        
        
        _tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tempUrl error:nil];
        _tempPlayer.currentTime = time;
        [_tempPlayer play];
        NSTimeInterval vedioTime = _tempPlayer.duration+0.1;
        //播放完成时 停止
        _playerTimer=[NSTimer scheduledTimerWithTimeInterval:vedioTime target:self selector:@selector(stopPlay) userInfo:nil repeats:NO];
        _moveSetTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(updateSet) userInfo:nil repeats:YES];
        _isPlaying = YES;
        timerIndex = 0;
        countIndex = 0;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
}

- (void)updateSet {
    if (_isPlaying) {
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateAudio:andValue:)]) {
            countIndex ++;
            //当有40次的时候，时间加1;
            if (countIndex%40 == 0) {
                timerIndex++;
            }
            int seconds = timerIndex % 60;
            int minutes = (timerIndex / 60) % 60;
            NSString *timeValue = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
            [_delegate didUpdateAudio:countIndex andValue:timeValue];
        }
    }
}


//自动停止播放
-(void)stopPlay
{
    [self stopAudioPlay];
    if (_delegate && [_delegate respondsToSelector:@selector(didStopAudio)]) {
        [_delegate didStopAudio];
    }
}

//手动停止播放
- (void)stopAudioPlay {
    if (_isPlaying) {
        [_tempPlayer stop];
    }
    if (_playerTimer) {
        [_playerTimer invalidate];
        _playerTimer=nil;
    }
    _isPlaying = NO;
    timerIndex = 0;
    countIndex = 0;
    if (_moveSetTimer) {
        [_moveSetTimer invalidate];
        _moveSetTimer=nil;
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)playRemoteAudio:(NSString*)urlStr andBlock:(void(^)(float currentTime,float allTime,BOOL isStop))audioBlock andAllTime:(NSString*)allTime{
    NSURL *url = [NSURL URLWithString:urlStr];
    if (!resourceLoaderManager) {
        resourceLoaderManager = [VIResourceLoaderManager new];
    }
    if (_playerItem) {
        _playerItem = nil;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _playerItem = [resourceLoaderManager playerItemWithURL:url];
    if (self.player) {
        _player = nil;
    }
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    __weak typeof(self)weakSelf = self;
    const char *queueStr = [[NSString stringWithFormat:@"player.time.queue%d",rand()%100000] UTF8String];
    __block BOOL isPlay = _isPlaying;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10)
                                              queue:dispatch_queue_create(queueStr, NULL)
                                         usingBlock:^(CMTime time) {
                                             dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                 CGFloat durantion = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
                                                 if (![allTime isEqualToString:@""]) {
                                                     durantion = [allTime intValue];
                                                 }
                                                 CGFloat currentDuration = CMTimeGetSeconds(time);
                                                 if (audioBlock) {
                                                     if (currentDuration >= durantion) {
                                                         NSLog(@"停止");
                                                         isPlay = NO;
                                                         audioBlock(currentDuration,durantion,YES);
                                                     }else {
                                                         audioBlock(currentDuration,durantion,NO);
                                                         
                                                     }
                                                 }
                                                 
                                             });
                                         }];
    
    //    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_player play];
    _isPlaying = YES;
}

//这里需要加个block来传递播放的秒数
- (void)playAudios:(NSString*)urlBack andBlock:(void(^)(float currentTime,float allTime,BOOL isStop))audioBlock isBackRemote:(BOOL)isRemote andOthers:(NSArray*)urlArray andTimeArray:(NSArray*)timeArr andAllTime:(NSString*)allTime {
    //背景音乐是远程
    if (isRemote) {
        [self playRemoteAudio:urlBack andBlock:audioBlock andAllTime:allTime];
    }else{
        
        [self playAudio:urlBack andTime:0];
    }
    for (int i = 0; i<urlArray.count; i++) {
        NSString *aURL = [urlArray objectAtIndex:i];
        NSURL *url = [NSURL URLWithString:aURL];
        int time = [[timeArr objectAtIndex:i] intValue];
        if (i == 0) {
            if (!leftResourceLoaderManager) {
                leftResourceLoaderManager = [VIResourceLoaderManager new];
            }
            if (leftPlayerItem) {
                leftPlayerItem = nil;
            }
            if (leftPlayer) {
                leftPlayer = nil;
            }
            leftPlayerItem = [leftResourceLoaderManager playerItemWithURL:url];
            leftPlayer = [AVPlayer playerWithPlayerItem:leftPlayerItem];
            [leftPlayer performSelector:@selector(play) withObject:nil afterDelay:time];
        }else if(i == 1){
            if (!rightResourceLoaderManager) {
                rightResourceLoaderManager = [VIResourceLoaderManager new];
            }
            if (rightPlayerItem) {
                rightPlayerItem = nil;
            }
            if (rightPlayer) {
                rightPlayer = nil;
            }
            rightPlayerItem = [rightResourceLoaderManager playerItemWithURL:url];
            rightPlayer = [AVPlayer playerWithPlayerItem:rightPlayerItem];
            [rightPlayer performSelector:@selector(play) withObject:nil afterDelay:time];
        }
    }
    
}

- (void)stopRemoteAudio {
    if (_isPlaying) {
        [_tempPlayer stop];
        
    }
    
    if (self.player) {
        //        [playerItem removeObserver:self forKeyPath:@"status"];
        [self.player pause];
        _isPlaying = NO;
    }
    
    if (leftPlayer) {
        [NSObject cancelPreviousPerformRequestsWithTarget:leftPlayer];
        [leftPlayer pause];
    }
    if (rightPlayer) {
        [NSObject cancelPreviousPerformRequestsWithTarget:rightPlayer];
        [rightPlayer pause];
    }
    
    if (_playerTimer) {
        [_playerTimer invalidate];
        _playerTimer=nil;
    }
    if (_moveSetTimer) {
        [_moveSetTimer invalidate];
        _moveSetTimer = nil;
    }
}

#pragma mark Actions

//创建定时器
- (void)createAudioTimer {
    if (!self.audioTimer) { // 定时器
        self.audioTimer = [[NSTimer alloc] init];
        self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(autoChangeProgress) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.audioTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)removeAudioTimer {
    [self.audioTimer invalidate];
    self.audioTimer = nil;
}




- (NSString *) stringWithCheckCoderTime:(int) time {
    int m = (int) time/60;
    int s = (int) time%60;
    
    return [NSString stringWithFormat:@"%@:%@",
            [self zeroPrefix:m],
            [self zeroPrefix:s]
            ];
}
-(NSString *) zeroPrefix:(int) time {
    if (time<10) {
        return [NSString stringWithFormat:@"0%d", time];
    } else {
        return [NSString stringWithFormat:@"%d", time];
    }
}



- (void)autoChangeProgress {
    int ct = (int)[_tempPlayer currentTime];
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdateAudio:andValue:)]) {
        countIndex ++;
        //当有40次的时候，时间加1;
        if (countIndex%10 == 0) {
            timerIndex++;
        }
        NSString *timeValue = [self stringWithCheckCoderTime:ct];
        [_delegate didUpdateAudio:countIndex andValue:timeValue];
    }
    if ((int)ct == (int)[_tempPlayer duration]) {
        [self removeAudioTimer];
        countIndex = 0;
        timerIndex = 0;
        [_tempPlayer stop];
       
    }
}


- (void)slideStartToChange {
    [_tempPlayer pause];
    [self removeAudioTimer];
}

//value 时间
- (void)slideToEnd:(int)value {
    // 2.转化成即将要准备播放的时间
    isAudioPlaying = YES;
    _tempPlayer.currentTime = value;
    countIndex = value * 10;
    timerIndex = value;
    [_tempPlayer play];
    [self createAudioTimer];

}


- (void)playNewAudio:(NSString *)path {
    localPath = nil;
    localPath = path;
    NSString *currPath = [[AudioPublicMethod getPathByFileName:path ofType:@"wav"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *tempUrl = [NSURL URLWithString:currPath];
    _tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tempUrl error:nil];
    [_tempPlayer play];
    [self createAudioTimer];
}


@end
