//
//  RecordWaveView.m
//  LonelyStation
//
//  Created by zk on 16/8/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RecordWaveView.h"
#import "ZKWaveView.h"
#import "AudioPublicMethod.h"
#import "EMImageView.h"

@interface RecordWaveView (){
    UIScrollView *scrollview;
    //录音的view
    ZKWaveView *waveView;
    
    //裁剪的view
    EMImageView *waveImgView;
    EMView *leftSetView;
    EMView *leftMaskView;
    EMView *rightMaskView;
    EMView *rightSetView;
    CGRect leftOriginFrame;
    CGRect rightOriginFrame;
    //录音的那个头最后的位置
    CGRect recordLastFrame;
    //播放录音的头
    EMView *recordSetView;
    EMView *centerLine;
    
    BOOL isPlaying;
}
@end

@implementation RecordWaveView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)resetRightOrgin {
    recordLastFrame.origin.x = 0;
}

- (void)setup {
    scrollview = [[UIScrollView alloc] init];
    [scrollview setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [scrollview setContentSize:scrollview.bounds.size];
    scrollview.backgroundColor = [UIColor clearColor];
    scrollview.pagingEnabled = NO;
    scrollview.scrollEnabled = YES;
    scrollview.showsHorizontalScrollIndicator = NO;
     [self addSubview:scrollview];
    waveView = [[ZKWaveView alloc] initWithFrame:CGRectMake(0, 0, scrollview.bounds.size.width, scrollview.bounds.size.height)];
    waveView.intervalTime = 0.025;
    waveView.sampleWidth = 0.5;
    [scrollview addSubview:waveView];
    
    //裁剪操作的背景view
    //实际是13
    CGFloat setWidth = 40 * kScale;
    CGFloat setHight = 40 * kScale;
    waveImgView = [[EMImageView alloc] initWithFrame:CGRectMake(setWidth, 0, self.bounds.size.width - 2 * setWidth, self.bounds.size.height)];
    [self addSubview:waveImgView];
    
    CGFloat smallWidth = 13*kScale;
    leftOriginFrame =CGRectMake(0, round(((self.bounds.size.height - setWidth)/2)),setWidth, setHight);
    leftSetView = [[EMView alloc] initWithFrame:CGRectMake(0, round(((self.bounds.size.height - setHight)/2)),setWidth, setHight)];
    rightOriginFrame = CGRectMake(self.bounds.size.width - setWidth, round(((self.bounds.size.height - setHight)/2)), setWidth, setHight);
    rightSetView = [[EMView alloc] initWithFrame:rightOriginFrame];
    
    UIImageView *leftImgView = [[UIImageView alloc] initWithFrame:Rect(0, (setWidth-smallWidth)/2.f+1, smallWidth, smallWidth)];
//    leftImgView.backgroundColor =RGB(171, 171, 171);
    leftImgView.image = [UIImage imageNamed:@"cut_dot"];
    leftImgView.layer.cornerRadius = leftImgView.frame.size.width/2;
    leftImgView.layer.masksToBounds = YES;
    [leftSetView addSubview:leftImgView];
    
    UIImageView *rightImgView = [[UIImageView alloc] initWithFrame:Rect(setWidth-smallWidth, (setWidth-smallWidth)/2.f+1, smallWidth, smallWidth)];
//    rightImgView.backgroundColor = RGB(171, 171, 171);
    rightImgView.image = [UIImage imageNamed:@"cut_dot"];
    rightImgView.layer.cornerRadius = leftImgView.frame.size.width/2;
    rightImgView.layer.masksToBounds = YES;
    [rightSetView addSubview:rightImgView];
    
    UIPanGestureRecognizer *leftpan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    UIPanGestureRecognizer *rightpan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];

    [leftSetView addGestureRecognizer:leftpan];
    [rightSetView addGestureRecognizer:rightpan];
    [self addSubview:leftSetView];
    [self addSubview:rightSetView];
    [self addSubview:leftMaskView];
    [self addSubview:rightMaskView];
    
    //播放区域
    centerLine = [[EMView alloc] initWithFrame:Rect(0, self.frame.size.height/2, self.frame.size.width, 2)];
    centerLine.backgroundColor =RGB(171, 171, 171);;
    [self addSubview:centerLine];
    
    
    recordSetView = [[EMView alloc] initWithFrame:leftOriginFrame];
    recordSetView.backgroundColor = [UIColor redColor];
    recordSetView.layer.cornerRadius = leftSetView.frame.size.width/2;
    recordSetView.layer.masksToBounds = YES;
    [self addSubview:recordSetView];
    
    UIPanGestureRecognizer *recordSetPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cursorPanAction:)];
    [recordSetView addGestureRecognizer:recordSetPan];
    recordLastFrame = CGRectMake(0, round(((self.bounds.size.height - 21*kScale)/2)),14*kScale, 21*kScale);
    [self showRecord:RecordStatusRecord];
}


- (void)cursorPanAction:(UIPanGestureRecognizer*)pan {
    if (_delegate && [_delegate respondsToSelector:@selector(didStartLocalPan)] && pan.state == UIGestureRecognizerStateBegan) {
        [_delegate didStartLocalPan];
    }
    
    UIView *view = pan.view;
    CGRect rect = view.frame;
    CGPoint point = [pan locationInView:self];
    CGFloat width = recordSetView.frame.size.width;
    CGFloat leftMaxX = self.bounds.size.width;
    //计算位置
    if (point.x > leftMaxX) {
        point.x = leftMaxX;
    }else if (point.x < width/2){
        point.x = width/2;
    }
    rect.origin.x = point.x - width / 2;
    view.frame = rect;
    //计算移动的时间
    
    if (_delegate && [_delegate respondsToSelector:@selector(localUpdateLeftValue:andLeftText:)]) {
     
        int leftValue = [self x2Value:recordSetView.frame.origin.x andAllValue:_accountValue andWidth:self.bounds.size.width - recordSetView.frame.size.width*2];
        _currentValue = leftValue;
        if (_currentValue < 0) {
            _currentValue = 0;
        }else if (_currentValue > _accountValue){
            _currentValue = _accountValue;
        }
        int seconds = _currentValue % 60;
        int minutes = (_currentValue / 60) % 60;
        NSString *leftText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
        [_delegate localUpdateLeftValue:(int)_currentValue andLeftText:leftText];
        
        if (_delegate && [_delegate respondsToSelector:@selector(didEndLocalPan:)] && pan.state == UIGestureRecognizerStateEnded) {
            [_delegate didEndLocalPan:leftValue];
        }
        
    }
}

- (void)updateView:(CGFloat)peakPowerForChannel{
    [waveView  addSamples:[NSNumber numberWithFloat:peakPowerForChannel]];
    //记录游标最后的位置
    recordLastFrame = waveView.imgView.frame;
    //游标宽度
    CGFloat retWidth = 13*kScale;
    if (floor(waveView.samples.count * waveView.sampleWidth + retWidth) >= ceil(waveView.bounds.size.width)){
        CGRect rectWave = waveView.frame;
        rectWave.size.width = (waveView.samples.count + 1)* waveView.sampleWidth + retWidth;
        waveView.frame = rectWave;
        
        [scrollview setContentSize:rectWave.size];
        [scrollview scrollRectToVisible:CGRectMake((waveView.samples.count - 1)*waveView.sampleWidth+retWidth, 0, waveView.sampleWidth, rectWave.size.height) animated:NO];
    }

}


- (void)startRecord {
    [self showRecord:RecordStatusRecord];

}


- (void)showClipView {
//    UIImage *image = [AudioPublicMethod soundImgWithSamples:waveView.samples andWidth:waveView.frame.size.width - 26 *kScale andHight:waveView.frame.size.height andBackColor:[UIColor clearColor] andWaveColor:RGB(235,173,255)];
//    waveImgView.image = image;
    [self showRecord:RecordStatusClip];
}

- (void)showRecord:(RecordStatus)status {
    BOOL ret = NO;
    if (status == RecordStatusRecord) {
        waveView.imgView.frame = recordLastFrame;
        ret = YES;
    }else if (status == RecordStatusPlay){
        ret = YES;
    }
    recordSetView.hidden = YES;
    waveImgView.hidden = ret;
    leftSetView.hidden = ret;
    leftMaskView.hidden = ret;
    rightSetView.hidden = ret;
    rightMaskView.hidden = ret;
    scrollview.hidden = !ret;
    waveView.hidden = !ret;
    centerLine.hidden = ret;
    waveView.imgView.hidden = !ret;
    if (status == RecordStatusPlay) {
        scrollview.hidden = NO;
        waveView.hidden = YES;
        centerLine.hidden = NO;
        recordSetView.hidden = NO;
        waveView.imgView.hidden = YES;
        waveView.imgView.frame = CGRectMake(0, round(((waveView.bounds.size.height - 21*kScale)/2)), 14*kScale, 21*kScale);
    }
    
}

- (void)clearSample{
    [scrollview setContentSize:self.frame.size];
    waveView.frame = self.bounds;
    [waveView clearSamples];
    leftSetView.frame = leftOriginFrame;
    rightSetView.frame = rightOriginFrame;
    [self showRecord:RecordStatusRecord];
    waveView.imgView.frame = CGRectMake(0, round(((waveView.bounds.size.height - 21*kScale)/2)), 14*kScale, 21*kScale);
}

- (void)panAction:(UIPanGestureRecognizer*)pan {
    UIView *view = pan.view;
    CGRect rect = view.frame;
    CGPoint point = [pan locationInView:self];
    CGFloat width = 40 * kScale;
    CGFloat absoloutWidth = 40 * kScale;
    CGFloat leftMaxX = self.bounds.size.width - width * 3/2;
    CGFloat rightMaxX = self.bounds.size.width - absoloutWidth/2;
    
    CGFloat superViewWidth = self.bounds.size.width;
    
    UIView *leftView = leftSetView;
    UIView *rightView = rightSetView;
//    UIView *leftMask = leftMaskView;
//    UIView *rightMask = rightMaskView;
    UIView *leftMask = nil;
    UIView *rightMask = nil;
    
    //计算位置
    if (view == leftView) {
        if (point.x > leftMaxX) {
            point.x = leftMaxX;
        }else if (point.x < width/2){
            point.x = width/2;
        }
        if (point.x > rightView.frame.origin.x - width / 2 ) {
            rect.origin.x = point.x + width/2;
            rightView.frame = rect;
            point.x = rightView.frame.origin.x - width / 2;
            //设置mask
            CGRect frame =  rightMask.frame;
            frame.size.width = superViewWidth -  rect.origin.x - width;
            frame.origin.x = rect.origin.x + width;
            rightMask.frame = frame;
            
            
        }
        rect.origin.x = point.x - width / 2;
        view.frame = rect;
        CGRect frame =  leftMask.frame;
        frame.size.width = rect.origin.x;
        leftMask.frame = frame;
        
        
    }else {
        if (point.x > rightMaxX) {
            point.x = rightMaxX;
        }else if (point.x < width * 3 / 2) {
            point.x = width * 3 / 2;
        }
        rect.origin.x = point.x - width / 2;
        view.frame = rect;
        CGRect frame =  rightMask.frame;
        frame.size.width = superViewWidth -  rect.origin.x - width;
        frame.origin.x = rect.origin.x + width;
        rightMask.frame = frame;
        
        if (rect.origin.x < leftView.frame.origin.x + width) {
            rect.origin.x = point.x - width * 3/ 2;
            leftView.frame = rect;
            point.x = leftView.frame.origin.x + width / 2;
            //设置mask
            CGRect frame =  leftMask.frame;
            frame.size.width = rect.origin.x;
            leftMask.frame = frame;
        }
    }

    
    //更新状态
    if (_delegate && [_delegate respondsToSelector:@selector(willUpdateLeftValue:andLeftText:andRightValue:andRightText:)]) {
        int leftValue = [self x2Value:leftView.frame.origin.x andAllValue:_accountValue andWidth:self.bounds.size.width - leftView.frame.size.width*2];
        int seconds = leftValue % 60;
        int minutes = (leftValue / 60) % 60;
        NSString *leftText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
        
        int rightValue = [self x2Value:rightView.frame.origin.x - rightView.frame.size.width  andAllValue:_accountValue andWidth:self.bounds.size.width - rightView.frame.size.width * 2];
        seconds = rightValue % 60;
        minutes = (rightValue / 60) % 60;
        NSString *rightText = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
        [_delegate willUpdateLeftValue:leftValue andLeftText:leftText andRightValue:rightValue andRightText:rightText];
    }
    
}


//开始播放，把游标置到为0的地方
- (void)startPlay {
    [self showRecord:RecordStatusPlay];
    isPlaying = YES;
    [scrollview setContentOffset:CGPointMake(0, 0)];
}

- (void)stopPlay {
    isPlaying = NO;
    //当前的时间置为0
    _currentValue = 0;
    CGRect frame = recordSetView.frame;
    frame.origin.x = 0;
    recordSetView.frame = frame;
}


//更新播放游标
- (void)updateSet:(float)value {
    CGFloat x = [self value2x:value andAllValue:_accountValue andWidth:self.bounds.size.width - leftSetView.frame.size.width];
    if (x > self.bounds.size.width - 13*kScale) {
        x = self.bounds.size.width - 13*kScale;
    }
    recordSetView.frame = CGRectMake(x, round(((waveView.bounds.size.height - 13*kScale)/2)), 13*kScale, 13*kScale);
}

//秒->坐标
-(CGFloat)value2x:(float)value andAllValue:(CGFloat)allValue andWidth:(CGFloat)width{
    CGFloat x = 0;
    
    CGFloat perX = width / allValue ;
    //1s钟10次，所以要除10
    x = value * perX/10;
    
    return x;
}


//坐标->秒
-(int)x2Value:(CGFloat)x andAllValue:(CGFloat)allValue andWidth:(CGFloat)width{
    
    int value = 0.f;
    
    CGFloat perValue =  allValue / width;
    
    value = x * perValue;
    
    return value;
}



@end
