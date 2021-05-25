//
//  UICycleImgView.m
//  FotonGratour
//
//  Created by zk on 16/7/19.
//  Copyright © 2016年 HeFahu. All rights reserved.
//

#import "UICycleImgView.h"

@interface UICycleImgView() {
    CAShapeLayer *_borderLayer;
}

@end

@implementation UICycleImgView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.size.width/2, frame.size.height/2) radius:frame.size.width/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
        CAShapeLayer* shape = [CAShapeLayer layer];
        shape.path = path.CGPath;
        self.layer.mask = shape;
        _borderLayer=[CAShapeLayer layer];
        _borderLayer.path = path.CGPath;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        _borderLayer.strokeColor = [UIColor clearColor].CGColor;
        _borderLayer.lineWidth   = 1;
        [self.layer addSublayer:_borderLayer];
        
    }
    return self;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    _borderLayer.strokeColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    _borderLayer.lineWidth = borderWidth;
}


@end
