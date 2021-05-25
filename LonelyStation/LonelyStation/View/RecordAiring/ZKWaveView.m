//
//  ZKWaveView.m
//  LonelyStation
//
//  Created by zk on 16/8/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ZKWaveView.h"

@implementation ZKWaveView

@synthesize samples,intervalTime;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 14*kScale, 21*kScale)];
//        _imgView.backgroundColor = RGBA(0xff, 0, 0, 0.8);
        _imgView.image = [UIImage imageNamed:@"cut_dot"];
//        _imgView.layer.cornerRadius = _imgView.frame.size.width/2;
//        _imgView.layer.masksToBounds = YES;
        [self addSubview:_imgView];
    }
    return self;
}


- (void)clearSamples {
    if (self.samples) {
        [self.samples removeAllObjects];
        [self setNeedsDisplay];
        _imgView.frame = CGRectMake(0, 5, 14*kScale, 21*kScale);
    }
}

- (void)setup{
    _sampleWidth = 0.5;
    intervalTime = 0.015;
    self.backgroundColor = [UIColor clearColor];
}

- (void)addSamples:(NSNumber *)value{
    if (self.samples == nil) {
        self.samples = [[NSMutableArray alloc] init];
    }
    [self.samples addObject:value];
    [self setNeedsDisplay];
    //移动游标
    if (_imgView) {
        _imgView.frame = CGRectMake(samples.count*_sampleWidth + 0.15, _imgView.frame.origin.y, 14*kScale, 21*kScale);
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    [[UIColor clearColor] set];
    UIRectFill(self.bounds);

    [RGB(235,173,255) set];
    for (u_int16_t i = 0; i<samples.count; i++) {
        float sample = [samples[i] floatValue];
        
        u_int16_t height = 0;
        if (sample >= -10) {
            if (sample >= 0) {
                sample = 0;
            }
            height = ((sample + 11.0) / 18.0)*(self.bounds.size.height);
        }else{
            height = (-10.0 /sample) * (self.bounds.size.height)/18;
        }
        height += 3;
        CGRect rect = CGRectMake(i*_sampleWidth + 0.15, (self.bounds.size.height-height)/2 , _sampleWidth - 0.3, height);
        UIRectFill(rect);
    }
    [RGB(171,171,171) setFill];
    UIBezierPath *centerLine = [UIBezierPath bezierPathWithRect:CGRectMake(0, round(((self.bounds.size.height)/2)-1), self.bounds.size.width, 2)];
    [centerLine fill];
    
}

@end
