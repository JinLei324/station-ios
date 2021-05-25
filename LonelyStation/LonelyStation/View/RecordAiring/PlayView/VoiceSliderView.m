//
//  VoiceSliderView.m
//  dexotrip
//
//  Created by kevin on 16/8/8.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import "VoiceSliderView.h"
#import "Masonry.h"
@implementation VoiceSliderView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        //进度条
        CGFloat leftRightMargin = 0;
        CGFloat topMargin = 0;
        CGFloat progressSliderH = 56/2.0f;
        CGFloat currentDurationLabelW = 100;
        CGFloat currentDurationLabelH = 20;
        
        self.progressView = [[UIProgressView alloc] init];
        [self addSubview:self.progressView];
        self.progressView.trackTintColor = RGB(145,90,173);
        self.progressView.progressTintColor = RGB(145,90,173);
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).with.offset(leftRightMargin);
            make.right.mas_equalTo(self).with.offset(-leftRightMargin);
            make.top.mas_equalTo(self.mas_topMargin).offset(topMargin+progressSliderH/2);
            make.height.mas_equalTo(2);
        }];
        
        self.progressSlider = [[UISlider alloc] init];
        self.progressSlider.minimumValue = .0f;
        self.progressSlider.maximumValue = 1.0f;
        UIImage *image = [UIImage imageNamed:@"cut_dot"];
        [self.progressSlider setThumbImage:image forState:UIControlStateNormal];
        [self.progressSlider setThumbImage:image forState:UIControlStateHighlighted];
        //        [self.progressSlider setThumbImage:[UIImage imageNamed:@"PlayerSlider"] forState:UIControlStateNormal];
        self.progressSlider.minimumTrackTintColor = [UIColor whiteColor];
        self.progressSlider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.8];
        self.progressSlider.thumbTintColor = [UIColor redColor];
        //        self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.5];
        //        self.progressSlider.backgroundColor = [UIColor yellowColor];
        [self addSubview:self.progressSlider];
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).with.offset(leftRightMargin);
            make.right.mas_equalTo(self).with.offset(-leftRightMargin);
            make.top.mas_equalTo(self.mas_topMargin).offset(topMargin);
            make.height.mas_equalTo(progressSliderH);
        }];
        
        
        
        UIFont *LabelFont = [UIFont systemFontOfSize:10.0f];
        self.crruentLabel = [[UILabel alloc] init];
        self.crruentLabel.font = LabelFont;
        self.crruentLabel.text = @"00:00";
        //        self.crruentLabel.backgroundColor = [UIColor redColor];
        self.crruentLabel.textColor = RGB(145,90,173);
        [self addSubview:self.crruentLabel];
        [self.crruentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.progressSlider.mas_left);
            make.top.mas_equalTo(self.progressSlider.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(currentDurationLabelW, currentDurationLabelH));
        }];
        
        self.durationLabel = [[UILabel alloc] init];
        self.durationLabel.font = LabelFont;
        self.durationLabel.text = @"00:00";
        self.durationLabel.textColor = RGB(145,90,173);
        
        [self.durationLabel setTextAlignment:NSTextAlignmentRight];
        //        self.durationLabel.backgroundColor = [UIColor purpleColor];
        [self addSubview:self.durationLabel];
        [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.progressSlider.mas_right);
            make.top.mas_equalTo(self.progressSlider.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(currentDurationLabelW, currentDurationLabelH));
        }];
        
    }
    return self;
}

@end
