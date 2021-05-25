//
//  AudioRemotePlayView.m
//  PlayerTest
//
//  Created by zk on 2016/10/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AudioRemotePlayView.h"
#import "VoiceSliderView.h"
#import "DouAudioPlayer.h"
#import "VIMediaCache.h"




@interface ZKAudioObj1 : NSObject

@property (nonatomic,copy)NSString *shouldPlaytime;

@property (nonatomic,copy)NSString *fileURL;

//是否是本地的
@property (nonatomic,assign)BOOL isLocal;

@end

@implementation ZKAudioObj1
@end

@interface AudioRemotePlayView ()<DouAudioPlayerDelegate> {
    DouAudioPlayer *_player;
    
    VIResourceLoaderManager *leftResourceLoaderManager;
    VIResourceLoaderManager *rightResourceLoaderManager;
    BOOL _isLeftPlay;
    BOOL _isRightPlay;
    NSString *_urlPath;
    BOOL isFinish;
}

@property (nonatomic, strong) VoiceSliderView *sliderView;

//左边远程的player和Item
@property(nonatomic,strong)AVPlayer *leftPlayer;

@property(nonatomic,strong)AVPlayerItem *leftPlayerItem;

//右边远程的player和Item
@property(nonatomic,strong)AVPlayer *rightPlayer;

@property(nonatomic,strong)AVPlayerItem *rightPlayerItem;


@property (nonatomic,strong)ZKAudioObj1 *leftObj;

@property (nonatomic,strong)ZKAudioObj1 *rightObj;


@end

@implementation AudioRemotePlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _sliderView = [[VoiceSliderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, frame.size.height)];
    [self addSubview:_sliderView];
    UIImage *image = [UIImage imageNamed:@"cut_dot"];
    [_sliderView.progressSlider setThumbImage:image forState:UIControlStateNormal];
    [_sliderView.progressSlider setThumbImage:image forState:UIControlStateHighlighted];
    //    [_sliderView.progressSlider setMinimumTrackTintColor:RGBA(0xff, 0xff, 0xff,0.3)];
    [_sliderView.progressSlider setMinimumTrackTintColor:RGB(145,90,173)];
    
    [_sliderView.progressSlider setMaximumTrackTintColor:RGBA(242, 242, 242,1)];
    
    _sliderView.crruentLabel.hidden = YES;
    _sliderView.durationLabel.hidden = YES;
    
    [self.sliderView.progressSlider addTarget:self action:@selector(slideStartToChange:) forControlEvents:UIControlEventTouchDown];
    [self.sliderView.progressSlider addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.sliderView.progressSlider addTarget:self action:@selector(slideToEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    _effectVolume = -1;
    return self;
}

- (void)slideToEnd:(UISlider *) slide {
    // 1.拿到当前 slider 的值
    float value = slide.value;
    //3.播放
    [self slidePlay:value];
}

- (void)setAllTime:(int)allTime {
    _allTime = allTime;
    _sliderView.durationLabel.text = [self stringWithCheckCoderTime:(int)allTime];
}



- (void)setIsShowLabel:(BOOL)isShowLabel {
    _isShowLabel = isShowLabel;
    _sliderView.crruentLabel.hidden = !isShowLabel;
    _sliderView.durationLabel.hidden = !isShowLabel;
}


- (void)slidePlay:(float)value {
    isFinish = NO;
    [_player startPlayValue:value];
}


- (void)slideStartToChange:(UISlider *) slide {
    [self pauseRemoteAudio];
}

- (void)sliderChangeValue:(UISlider *)slider {
    
}


- (void)didBuffering:(double)recievedLength andAllLength:(double)allLength andBufferRatio:(double)bufferingRatio andBufferSpeed:(double)downloadSpeed {
    _sliderView.progressView.progress = recievedLength/allLength;
}

- (void)didPlayingCurrentTime:(double)currentTime andAllTime:(double)allTime{
    NSLog(@"currentTime===%f,alltime=%f",currentTime,allTime);
    _sliderView.progressSlider.value = currentTime/allTime;
    _sliderView.crruentLabel.text = [self stringWithCheckCoderTime:(int)currentTime];
    _sliderView.durationLabel.text = [self stringWithCheckCoderTime:(int)allTime];
    [self playLeftAndRight:currentTime];
    if (_audioBok) {
        _audioBok(currentTime,allTime,isFinish);
    }
}


- (void)didPlayFinished {
    _sliderView.crruentLabel.text = @"00:00";
    _sliderView.progressSlider.value = 0;
    isFinish = YES;
    if (_leftObj) {
        if (_isLeftPlay) {
            [_leftPlayer pause];
            _isLeftPlay = NO;
        }
    }
    if (_rightObj) {
        if (_isRightPlay) {
            [_rightPlayer pause];
            _isRightPlay = NO;
        }
    }
    if (_audioBok) {
        _audioBok(0,0,isFinish);
    }
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

- (void)playRemoteAudios:(NSString*)urlPath isBackRemote:(BOOL)isRemote andOthers:(NSArray*)urlArray andTimeArray:(NSArray*)timeArr  {
    _isLeftPlay = NO;
    _isRightPlay = NO;
    _leftObj = nil;
    _rightObj = nil;
    isFinish = NO;
    for (int i = 0; i < urlArray.count; i++) {
        NSString *aURL = [urlArray objectAtIndex:i];
        NSString *time = [timeArr objectAtIndex:i];
        if (i == 0) {
            if (!_leftObj) {
                _leftObj = [[ZKAudioObj1 alloc] init];
            }
            _leftObj.fileURL = aURL;
            _leftObj.shouldPlaytime = time;
        }else if(i == 1) {
            if (!_rightObj) {
                _rightObj = [[ZKAudioObj1 alloc] init];
            }
            _rightObj.fileURL = aURL;
            _rightObj.shouldPlaytime = time;
        }
    }
    if (isRemote) {
        if (_sliderView.progressSlider.value != 0) {
            [self slidePlay:_sliderView.progressSlider.value];
        }else{
            [self playRemoteAudio:urlPath];
        }
    }
    
}


- (void)playLeftAndRight:(double)currentTime {
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


- (void)playRemoteAudio:(NSString*)urlPath{
    if (!_player) {
        _player = [[DouAudioPlayer alloc] init];
    }
    if (_allTime != 0) {
        _player.allTime = _allTime;
    }
    _urlPath = urlPath;
    _player.delegate = self;
    isFinish = NO;
    [_player startPlay:urlPath];
    
}

- (void)resetAll {
    if (_player) {
        [_player pause];
        _sliderView.progressSlider.value = 0;
        _allTime = 0;
        _sliderView.crruentLabel.text = @"00:00";
        _sliderView.durationLabel.text = @"00:00";
    }
    if (_leftPlayer) {
        _isLeftPlay = NO;
        [_leftPlayer pause];
    }
    if (_rightPlayer) {
        _isRightPlay = NO;
        [_rightPlayer pause];
    }
}


- (void)reallyStop {
    if (_player) {
        [_player stop];
        _sliderView.progressSlider.value = 0;
        _allTime = 0;
        _sliderView.crruentLabel.text = @"00:00";
        _sliderView.durationLabel.text = @"00:00";
    }
    if (_leftPlayer) {
        _isLeftPlay = NO;
        [_leftPlayer pause];
    }
    if (_rightPlayer) {
        _isRightPlay = NO;
        [_rightPlayer pause];
    }
}

- (void)stopRemoteAudio {
    if (_player) {
        [_player pause];
    }
    if (_leftPlayer) {
        _isLeftPlay = NO;
        [_leftPlayer pause];
    }
    if (_rightPlayer) {
        _isRightPlay = NO;
        [_rightPlayer pause];
    }
}

- (void)pauseRemoteAudio {
    if (_player) {
        [_player pause];
    }
    if (_isLeftPlay) {
        [_leftPlayer pause];
    }
    if (_isRightPlay) {
        [_rightPlayer pause];
    }
    _isLeftPlay = NO;
    _isRightPlay = NO;
}


- (void)resetRemoteAudio {
    [self stopRemoteAudio];
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


- (void)dealloc {
    if (_player) {
        [_player stop];
    }
}

@end
