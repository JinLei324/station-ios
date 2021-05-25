//
//  UserSettingView.m
//  LonelyStation
//
//  Created by zk on 2016/11/27.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UserSettingView.h"
#import "UIUtil.h"
#import "ViewModelCommom.h"

@implementation UserSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initWithSize:frame.size];
    return self;
}

- (void)initWithSize:(CGSize)size {
    _label = [[EMLabel alloc] initWithFrame:Rect(26*kScale, 0, 150*kScale, 40*kScale)];
    _label.textColor = RGB(51, 51, 51);
    _label.font = ComFont(14*kScale);
    _label.text = Local(@"AllowCall");
    [self addSubview:_label];
    _aSwitchBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 64 *kScale, 9*kScale, 43*kScale, 21*kScale)];
    [_aSwitchBtn setImage:[UIImage imageNamed:@"set_on"] forState:UIControlStateNormal];
    [_aSwitchBtn setImage:[UIImage imageNamed:@"set_off"] forState:UIControlStateSelected];
    [_aSwitchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_aSwitchBtn];
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 40*kScale, kScreenW, 1)];
    line.backgroundColor = RGB(172, 172, 172);
    [self addSubview:line];
    
    EMLabel *desLabel = [[EMLabel alloc] initWithFrame:Rect(_label.frame.origin.x, PositionY(line), 130*kScale, 44)];
    desLabel.textColor = RGB(51, 51, 51);
    desLabel.font = ComFont(14*kScale);
    desLabel.text = Local(@"AnswerTime");
    [self addSubview:desLabel];
    
    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 115*kScale, PositionY(desLabel)+3*kScale, 100, 10*kScale)];
    _timeLabel.textColor = RGB(145,90,173);
    _timeLabel.font = ComFont(9*kScale);
    _timeLabel.text = @"00:00~24:00";
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_timeLabel];
    
    CGFloat x = 26*kScale;
    CGFloat y = PositionY(_timeLabel);
    CGFloat width = kScreenW - 2*26*kScale;
    CGFloat height = 30*kScale;
    
    _nmSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(x,y,width,height)];
    _nmSlider.lowerValue = 0;
    _nmSlider.upperValue = 1;
    
    UIImage *image = [UIImage imageNamed:@"cut_dot"];
    _nmSlider.lowerHandleImageNormal = image;
    _nmSlider.upperHandleImageNormal = image;
    
    _nmSlider.trackImage =  [UIUtil imageWithColor:RGB(253,125,255) andSize:CGSizeMake(5, 3)];
    EMView *_nmline = [[EMView alloc] initWithFrame:CGRectMake(x, _nmSlider.frame.origin.y + height/2.f - 0.5, width, 2)];
    _nmline.backgroundColor = RGB(171,171,171);
    [self addSubview:_nmline];
    [self addSubview:_nmSlider];
    
    [_nmSlider addObserver:self forKeyPath:@"lowerValue" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_nmSlider addObserver:self forKeyPath:@"upperValue" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if([user.identity intValue] != 3){
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = RGBA(0xff, 0xff, 0xff,0.3);
        [self addSubview:view];
    }
}

- (void)dealloc {
    [_nmSlider removeObserver:self forKeyPath:@"lowerValue"];
    [_nmSlider removeObserver:self forKeyPath:@"upperValue"];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"lowerValue"]||[keyPath isEqualToString:@"upperValue"]) {
        int startTime =  _nmSlider.lowerValue * 24;
        int endTime = _nmSlider.upperValue * 24;
        _timeLabel.text = [NSString stringWithFormat:@"%02d:00-%02d:00",startTime,endTime];
        if (_aDelegate && [_aDelegate respondsToSelector:@selector(didChangeSlider:)]) {
            [_aDelegate didChangeSlider:_timeLabel.text];
        }
    }
}


- (void)switchAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    if (_aDelegate && [_aDelegate respondsToSelector:@selector(didSelectAction:)]) {
        [_aDelegate didSelectAction:btn.isSelected];
    }
}

@end
