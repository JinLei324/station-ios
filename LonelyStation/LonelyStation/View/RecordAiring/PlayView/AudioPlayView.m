//
//  AudioPlayView.m
//  Test
//
//  Created by zk on 16/8/26.
//  Copyright © 2016年 zk. All rights reserved.
//
//

#import "AudioPlayView.h"
#import "VoiceSliderView.h"

#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "VIMediaCache.h"

@interface ZKAudioObj : NSObject

@property (nonatomic,copy)NSString *shouldPlaytime;

@property (nonatomic,copy)NSString *fileURL;

//是否是本地的
@property (nonatomic,assign)BOOL isLocal;

@end

@implementation ZKAudioObj
@end


@interface AudioPlayView () {
    AVAudioPlayer *_localPlayer;

    //远程播放的manager
    VIResourceLoaderManager *resourceLoaderManager;
    VIResourceLoaderManager *leftResourceLoaderManager;
    VIResourceLoaderManager *rightResourceLoaderManager;
}
//远程播放的player和Item
@property(nonatomic,strong)AVPlayer *remotePlayer;

@property(nonatomic,strong)AVPlayerItem *remotePlayerItem;


//左边远程的player和Item
@property(nonatomic,strong)AVPlayer *leftPlayer;

@property(nonatomic,strong)AVPlayerItem *leftPlayerItem;

//右边远程的player和Item
@property(nonatomic,strong)AVPlayer *rightPlayer;

@property(nonatomic,strong)AVPlayerItem *rightPlayerItem;


@property (nonatomic,assign)float remoteAllTime;

@property (nonatomic,assign)float remoteCurrentTime;

//用全局变量控制左右的player是否播放
@property (nonatomic,assign)BOOL isLeftPlay;

@property (nonatomic,assign)BOOL isRightPlay;


@property (nonatomic, copy) audioBlock localPlayerBlock;


@property (nonatomic, strong) VoiceSliderView *sliderView;

@property (nonatomic, strong) NSTimer  *audioTimer; // 播放定时器


@property (nonatomic,strong)ZKAudioObj *leftObj;

@property (nonatomic,strong)ZKAudioObj *rightObj;

@end


@implementation AudioPlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _sliderView = [[VoiceSliderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, frame.size.height)];
    [self addSubview:_sliderView];
    UIImage *image = [UIImage imageNamed:@"cut_dot"];
    [_sliderView.progressSlider setThumbImage:image forState:UIControlStateNormal];
    [_sliderView.progressSlider setThumbImage:image forState:UIControlStateHighlighted];
    [_sliderView.progressSlider setMinimumTrackTintColor:RGBA(0xff, 0xff, 0xff,0.3)];
    [_sliderView.progressSlider setMaximumTrackTintColor:RGBA(0xff, 0xff, 0xff,0.3)];

    _sliderView.crruentLabel.hidden = YES;
    _sliderView.durationLabel.hidden = YES;
    
    [self.sliderView.progressSlider addTarget:self action:@selector(slideStartToChange:) forControlEvents:UIControlEventTouchDown];
    [self.sliderView.progressSlider addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.sliderView.progressSlider addTarget:self action:@selector(slideToEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    _effectVolume = -1;
    return self;
}

- (void)setAllTime:(int)allTime {
    _allTime = allTime;
    _sliderView.durationLabel.text = [self stringWithCheckCoderTime:allTime];
}


- (void)setIsShowLabel:(BOOL)isShowLabel {
    _isShowLabel = isShowLabel;
    _sliderView.crruentLabel.hidden = !isShowLabel;
    _sliderView.durationLabel.hidden = !isShowLabel;
}


#pragma mark play and stop LocalAudio

- (void)playLocalAudio:(NSString*)path andBlock:(audioBlock)block{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    NSURL *tempUrl = [NSURL URLWithString:path];
    _localPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tempUrl error:nil];
    _isAudioPlaying = YES;
    _zkAudioType = ZKAudioTypeLocal;
    _localPlayerBlock = block;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    _localPlayer.currentTime = _currentPlayTime;
    [_localPlayer play];
    [self createAudioTimer];
#pragma GCC diagnostic pop

}

- (void)stopLocalAudio {
    _isAudioPlaying = NO;
    _currentPlayTime = _localPlayer.currentTime;
    [_localPlayer pause];
//    _sliderView.progressSlider.value = 0;
    [self removeAudioTimer];
}


- (void)resetLocalAudio {
    _isAudioPlaying = NO;
    _currentPlayTime = 0;
    [_localPlayer stop];
    _sliderView.progressSlider.value = 0;
    [self removeAudioTimer];
}



#pragma mark play RemoteAudio

- (void)playRemoteAudio:(NSString*)urlPath andBlock:(void(^)(float currentTime,float allTime,BOOL isStop))audioBlock andAllTime:(NSString*)allTime{
    NSURL *url = [NSURL URLWithString:urlPath];
    if (!resourceLoaderManager) {
        resourceLoaderManager = [VIResourceLoaderManager new];
    }
    if (_remotePlayerItem) {
        _remotePlayerItem = nil;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _remotePlayerItem = [resourceLoaderManager playerItemWithURL:url];
    if (self.remotePlayer) {
        _remotePlayer = nil;
    }
    _zkAudioType = ZKAudioTypeRemote;
    self.remotePlayer = [AVPlayer playerWithPlayerItem:_remotePlayerItem];
    _remoteAllTime = [allTime floatValue];
    __weak typeof(self)weakSelf = self;
    const char *queueStr = [[NSString stringWithFormat:@"player.time.queue%d",rand()%100000] UTF8String];
    [self.remotePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 10)
                                              queue:dispatch_queue_create(queueStr, NULL)
                                         usingBlock:^(CMTime time) {
                                             dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                CGFloat currentDuration = CMTimeGetSeconds(time);
                                                 weakSelf.remoteCurrentTime = currentDuration;
                                                 if (weakSelf.remoteAllTime == 0) {
                                                     weakSelf.remoteAllTime = CMTimeGetSeconds(weakSelf.remotePlayer.currentItem.duration);
                                                 }
                                                 if (audioBlock) {
                                                     if ((int)currentDuration >= (int)weakSelf.remoteAllTime) {
                                                         NSLog(@"停止");
                                                         _currentPlayTime = 0;
                                                         weakSelf.sliderView.progressSlider.value = 0;
                                                         audioBlock(currentDuration,weakSelf.remoteAllTime,YES);
                                                         [weakSelf stopRemoteAudio];
                                                     }else {
                                                         audioBlock(currentDuration,weakSelf.remoteAllTime,NO);
                                                         
                                                     }
                                                 }
                                                 
                                             });
                                         }];
    [_remotePlayer seekToTime:CMTimeMakeWithSeconds(_currentPlayTime, NSEC_PER_SEC)];
    [_remotePlayer play];
    _isAudioPlaying = YES;
    [self createAudioTimer];
}

- (void)resetRemoteAudio {
    [self removeAudioTimer];
 
    if (_localPlayer) {
        _currentPlayTime = _localPlayer.currentTime;
        [_localPlayer pause];
    }
    
    if (self.remotePlayer) {
        [self.remotePlayer pause];
    }
    
    if (_leftPlayer) {
        [_leftPlayer pause];
        _isLeftPlay = NO;
    }
    if (_rightPlayer) {
        [_rightPlayer pause];
        _isRightPlay = NO;
    }
    self.sliderView.progressSlider.value = 0;
    _sliderView.crruentLabel.text =@"00:00";
    _currentPlayTime = 0;
    _isAudioPlaying = NO;
}

- (void)stopRemoteAudio {
    [self removeAudioTimer];
    
//    self.sliderView.progressSlider.value = 0;
    if (_localPlayer) {
        _currentPlayTime = _localPlayer.currentTime;
        [_localPlayer pause];
    }
    
    if (self.remotePlayer) {
        [self.remotePlayer pause];
//        _sliderView.crruentLabel.text =@"00:00";
//        [self.remotePlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
    }
    
    if (_leftPlayer) {
        [_leftPlayer pause];
        _isLeftPlay = NO;
    }
    if (_rightPlayer) {
        [_rightPlayer pause];
        _isRightPlay = NO;
    }

    _isAudioPlaying = NO;
}


//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
//                        change:(NSDictionary *)change context:(void *)context {
//    if (object == _remotePlayerItem && [keyPath isEqualToString:@"status"]) {
//        DLog(@"player status %@, rate %@, error: %@", @(_remotePlayerItem.status), @(_remotePlayer.rate), _remotePlayerItem.error);
//        if (_remotePlayerItem.status == AVPlayerItemStatusReadyToPlay) {
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                CGFloat duration = CMTimeGetSeconds(_remotePlayerItem.duration);
//                _allTime = duration - 1;
//            });
//        } else if (_remotePlayerItem.status == AVPlayerItemStatusFailed) {
//            // something went wrong. player.error should contain some information
//            NSLog(@"player error %@", _remotePlayerItem.error);
//        }
//    }
//}


#pragma mark play mixedAudio localAudio And Remote Effect
- (void)playAudios:(NSString*)urlBack andBlock:(audioBlock)audioBlock isBackRemote:(BOOL)isRemote andOthers:(NSArray*)urlArray andTimeArray:(NSArray*)timeArr andAllTime:(NSString*)allTime {
    _leftObj = nil;
    _rightObj = nil;
    for (int i = 0; i < urlArray.count; i++) {
        NSString *aURL = [urlArray objectAtIndex:i];
        NSString *time = [timeArr objectAtIndex:i];
        if (i == 0) {
            if (!_leftObj) {
                _leftObj = [[ZKAudioObj alloc] init];
            }
            _leftObj.fileURL = aURL;
            _leftObj.shouldPlaytime = time;
        }else if(i == 1) {
            if (!_rightObj) {
                _rightObj = [[ZKAudioObj alloc] init];
            }
            _rightObj.fileURL = aURL;
            _rightObj.shouldPlaytime = time;
        }
    }
    if (isRemote) {
        _zkAudioType = ZKAudioTypeRemote;
        [self playRemoteAudio:urlBack andBlock:audioBlock andAllTime:allTime];
    }else {
        [self playLocalAudio:urlBack andBlock:audioBlock];
        _zkAudioType = ZKAudioTypeMixed;
    }
}


- (void)playLeftAndRight:(float)currentTime {
    if (_leftObj) {
        int time = [[_leftObj shouldPlaytime] intValue];
        if (!_isLeftPlay && (int)currentTime == time) {
            _isLeftPlay = YES;
            if (!leftResourceLoaderManager) {
                leftResourceLoaderManager = [VIResourceLoaderManager new];
            }
            if (_leftPlayerItem) {
                _leftPlayerItem = nil;
            }
            if (_leftPlayer) {
                _leftPlayer = nil;
            }
            NSURL *url = [NSURL URLWithString:_leftObj.fileURL];
            _leftPlayerItem = [leftResourceLoaderManager playerItemWithURL:url];
            _leftPlayer = [AVPlayer playerWithPlayerItem:_leftPlayerItem];
            if (_effectVolume != -1 && _effectVolume>= 0 &&_effectVolume<=1) {
                _leftPlayer.volume = _effectVolume;
            }
            
            [_leftPlayer play];
        }
    }
    if (_rightObj) {
        int time = [[_rightObj shouldPlaytime] intValue];
        if (!_isRightPlay && (int)currentTime >= time) {
            //先关掉左边的
            [_leftPlayer pause];
            _isLeftPlay = NO;
            //播放右边
            _isRightPlay = YES;
            
            if (!rightResourceLoaderManager) {
                rightResourceLoaderManager = [VIResourceLoaderManager new];
            }
            if (_rightPlayerItem) {
                _rightPlayerItem = nil;
            }
            if (_rightPlayer) {
                _rightPlayer = nil;
            }
            
            DLog(@"%@",_rightObj.fileURL);

            NSURL *url = [NSURL URLWithString:_rightObj.fileURL];
            _rightPlayerItem = [rightResourceLoaderManager playerItemWithURL:url];
            _rightPlayer = [AVPlayer playerWithPlayerItem:_rightPlayerItem];
            if (_effectVolume != -1 && _effectVolume>= 0 &&_effectVolume<=1) {
                _rightPlayer.volume = _effectVolume;
            }
            [_rightPlayer play];
        }
    }
}




#pragma mark slideAction
- (void)slideStartToChange:(UISlider *) slide {
    if (_zkAudioType == ZKAudioTypeLocal) {
        [_localPlayer pause];
    }else if (_zkAudioType == ZKAudioTypeRemote) {
        [_remotePlayer pause];
    }else {
        [_localPlayer pause];
    }
    
    if (_isLeftPlay) {
        [_leftPlayer pause];
    }
    if (_isRightPlay) {
        [_rightPlayer pause];
    }
    _isLeftPlay = NO;
    _isRightPlay = NO;
    
    [self removeAudioTimer];
}

- (void)sliderChangeValue:(UISlider *)slider {
    switch (_zkAudioType) {
        case ZKAudioTypeLocal:
        case ZKAudioTypeMixed:{
            float dt = _localPlayer.duration;
            self.sliderView.crruentLabel.text = [self stringWithCheckCoderTime:slider.value * dt];
            _localPlayerBlock(slider.value * dt,dt,NO);
            break;
        }
        case ZKAudioTypeRemote:{
            float durantion = CMTimeGetSeconds(_remotePlayer.currentItem.duration);
            float dt = durantion;
            self.sliderView.crruentLabel.text = [self stringWithCheckCoderTime:slider.value * dt];
            break;
        }
        default:
            break;
    }
}


-(void)dealloc {
    DLog(@"dealloc");
}

- (void)slideToEnd:(UISlider *) slide {
    // 1.拿到当前 slider 的值
    float value = slide.value;
    float totalTime = 0.f;
    if (_zkAudioType  == ZKAudioTypeLocal) {
        totalTime = [_localPlayer duration];
    }else if (_zkAudioType == ZKAudioTypeRemote){
        totalTime = CMTimeGetSeconds([_remotePlayer.currentItem duration]);
    }else {
        totalTime = [_localPlayer duration];
    }
    // 2.转化成即将要准备播放的时间
    value   *= totalTime;
   //3.播放
    [self slidePlay:value];
}


- (void)slidePlay:(float)value {
    _isAudioPlaying = YES;
    switch (_zkAudioType) {
        case ZKAudioTypeLocal:
        case ZKAudioTypeMixed:{
            _localPlayer.currentTime = value;
            [_localPlayer play];
            [self createAudioTimer];
            break;
        }
        case ZKAudioTypeRemote:{
            [_remotePlayer seekToTime:CMTimeMakeWithSeconds(value, NSEC_PER_SEC)];
            [_remotePlayer play];
            [self createAudioTimer];
            break;
        }
        default:
            break;
    }
}



#pragma mark otherAction

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


#pragma mark timerAction

//创建定时器
- (void)createAudioTimer {
    if (!self.audioTimer) { // 定时器
        self.audioTimer = [[NSTimer alloc] init];
        self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(autoChangeProgress) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.audioTimer forMode:NSRunLoopCommonModes];
    }
}


- (void)removeAudioTimer {
    [self.audioTimer invalidate];
    self.audioTimer = nil;
}


#pragma mark autoChangeProgress

- (void)autoChangeProgress {
    float ct = 0.f;
    float dt = 0.f;
    switch (_zkAudioType) {
        case ZKAudioTypeLocal:
        case ZKAudioTypeMixed:{
            ct = [_localPlayer currentTime];
            dt = [_localPlayer duration];
            break;
        }
        case ZKAudioTypeRemote:{
            ct = _remoteCurrentTime;
            dt = _allTime;
            break;
        }
        default:
            break;
    }
    if (dt == 0) {
        self.sliderView.progressSlider.value = 0;
    } else {
        [self playLeftAndRight:ct];
        _currentPlayTime = ct;
        self.sliderView.progressSlider.value = ct/dt;
        _leftValue = [self stringWithCheckCoderTime:ct];
        _rightValue = [self stringWithCheckCoderTime:dt];
        self.sliderView.crruentLabel.text = _leftValue;
        self.sliderView.durationLabel.text = _rightValue;
    }
    
    if (_zkAudioType == ZKAudioTypeMixed || _zkAudioType == ZKAudioTypeLocal) {
        if (!_localPlayer.isPlaying) {
            _currentPlayTime = 0;
            _localPlayerBlock(ct,dt,YES);
        }else {
            _localPlayerBlock(ct,dt,NO);
        }
    }

}


- (float)getPlayingItemDurationTime
{
    CMTime itemDurationTime = [self playerItemDuration];
    float duration = CMTimeGetSeconds(itemDurationTime);
    if (CMTIME_IS_INVALID(itemDurationTime) || !isfinite(duration))
        return 0.0f;
    else
        return duration;
}


- (CMTime)playerItemDuration
{
    NSError *err = nil;
    if ([self.remotePlayer.currentItem.asset statusOfValueForKey:@"duration" error:&err] == AVKeyValueStatusLoaded) {
        AVPlayerItem *playerItem = [self.remotePlayer currentItem];
        NSArray *loadedRanges = playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0)
        {
            CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
            //Float64 duration = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            return (range.duration);
        }else {
            return (kCMTimeInvalid);
        }
    } else {
        return (kCMTimeInvalid);
    }
}



#pragma mark createCycleImge

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    //新建一个图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    
    
    //绘制圆形路径
    CGContextAddEllipseInRect(ctx, rect);
    
    //剪裁上下文
    CGContextClip(ctx);
    
    
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    CGContextFillRect(ctx, rect);
    //绘制图片
    
    //取出图片
    UIImage *roundImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束上下文
    UIGraphicsEndImageContext();
    
    return roundImage;
}


- (UIImage *)imageWithLineColor:(UIColor *)color andSize:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
