//
//  EMView.m
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import "EMView.h"

@interface EMView() {
    UIRectCorner _corners;
    CAShapeLayer *_maskLayer;
    int aConner;
    CAShapeLayer *_borderLayer;
}

@end


@implementation EMView

-(id)initWithFrame:(CGRect)frame andConners:(int)conner{
    if (self = [super initWithFrame:frame]) {
        _maskLayer= [CAShapeLayer layer];
        _maskLayer.frame = self.bounds;
        aConner = conner;
        _maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:
                           CGRectMake(0, 0, frame.size.width, frame.size.height) cornerRadius:aConner].CGPath;
        self.layer.mask = _maskLayer;
        if (!_borderLayer) {
            if (!_borderColor) {
                _borderLayer=[CAShapeLayer layer];
                [self.layer addSublayer:_borderLayer];
            }
            _borderLayer.path = _maskLayer.path;
            _borderLayer.fillColor = [UIColor clearColor].CGColor;
            _borderLayer.strokeColor = [UIColor clearColor].CGColor;
            _borderLayer.lineWidth   = 1;
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _maskLayer.frame = self.bounds;
    _maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:
                       CGRectMake(0, 0, frame.size.width, frame.size.height) cornerRadius:aConner].CGPath;
    self.layer.mask = _maskLayer;
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
