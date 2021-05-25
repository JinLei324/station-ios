//
//  CallImgView.m
//  Test
//
//  Created by zk on 16/9/3.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "CallImgView.h"
#import <QuartzCore/CADisplayLink.h>


@implementation CallImgView

@synthesize mass;
@synthesize springConstant;
@synthesize dampingCoefficient;
@synthesize panDragCoefficient;
@synthesize panDistanceLimits;
@synthesize restCenter;
@synthesize springEnabled;


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        springEnabled = YES;
        
        restCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        springConstant = 100;
        dampingCoefficient = 3;
        mass = 1;
        velocity = CGPointZero;
        self.userInteractionEnabled = YES;
        panDistanceLimits = UIEdgeInsetsMake(CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX);
        panDragCoefficient = 1.0;
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasPanned:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    
    return self;
    
}
- (BOOL)panning {
    return (panGestureRecognizer.state == UIGestureRecognizerStateChanged);
}

- (void)simulateSpringWithDisplayLink:(CADisplayLink *)displayLink {
    
    if (springEnabled && !self.panning){
        CGPoint displacement = CGPointMake(self.center.x - restCenter.x,
                                           self.center.y - restCenter.y);
        //控件收到的力
        CGPoint kx = CGPointMake(springConstant * displacement.x, springConstant * displacement.y);
        //控件受到的阻力
        CGPoint bv = CGPointMake(dampingCoefficient	* velocity.x, dampingCoefficient * velocity.y);
        //加速度
        CGPoint acceleration = CGPointMake((kx.x + bv.x) / mass, (kx.y + bv.y) / mass);
        
        velocity.x -= (acceleration.x * displayLink.duration);
        velocity.y -= (acceleration.y * displayLink.duration);
        
        //设置控件新位置
        CGPoint newCenter = self.center;
        newCenter.x += (velocity.x * displayLink.duration);
        newCenter.y += (velocity.y * displayLink.duration);
        [self setCenter:newCenter];
        
    }
}

#pragma mark - Panning
- (void)viewWasPanned:(UIPanGestureRecognizer *)sender {
    
    CGPoint translation = CGPointApplyAffineTransform([sender translationInView:self.superview], CGAffineTransformMakeScale(panDragCoefficient, panDragCoefficient));
    CGPoint translatedCenter = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    
    if (translation.x > 0 && (translatedCenter.x - restCenter.x) > panDistanceLimits.right){
        translation.x -= (translatedCenter.x - restCenter.x) - panDistanceLimits.right;
    }
    else if (translation.x < 0 && (restCenter.x - translatedCenter.x) > panDistanceLimits.left){
        translation.x += (restCenter.x - translatedCenter.x) - panDistanceLimits.left;
    }
    
    if (translation.y > 0 && (translatedCenter.y - restCenter.y) > panDistanceLimits.bottom){
        translation.y -= (translatedCenter.y - restCenter.y) - panDistanceLimits.bottom;
    }
    else if (translation.y < 0 && (restCenter.y - translatedCenter.y) > panDistanceLimits.top){
        translation.y += (restCenter.y - translatedCenter.y) - panDistanceLimits.top;
    }
    CGFloat x = self.center.x + translation.x;
    CGFloat y = -(250/kScreenW) * x + kScreenH;
    if (_isRight) {
        //限制x，y的取值
        y = (250/kScreenW) * x + kScreenH - 250;
        if (x < kScreenW/2.f) {
            x = kScreenW/2.f;
        }
        if (x > kScreenW) {
            x = kScreenW;
        }
    }else{
        if (x > kScreenW/2.f) {
            x = kScreenW/2.f;
        }
        if (x < 0) {
            x = 0;
        }
    }
    if (y < _minPointY) {
        y = _minPointY;
    }

    [self setCenter:CGPointMake(x, y)];
    [sender setTranslation:CGPointZero inView:self.superview];
    
    if (self.center.y < _minPointY+10 && sender.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(didReachTheMinPoint:)]) {
            [_delegate didReachTheMinPoint:self];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (_delegate && [_delegate respondsToSelector:@selector(didStartPan:)]) {
            [_delegate didStartPan:self];
        }
    }
}

@end
