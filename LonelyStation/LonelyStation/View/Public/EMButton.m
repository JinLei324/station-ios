//
//  EMButton.m
//  emeNew
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import "EMButton.h"
@interface EMButton()
{
    UIRectCorner _corners;
    CAShapeLayer *_maskLayer;
    int aConner;
    CAShapeLayer *_borderLayer;
}
@end

@implementation EMButton

-(id)initWithFrame:(CGRect)frame isRdius:(BOOL)isRadio{
    if(self = [super initWithFrame:frame]){
        if (isRadio && frame.size.width == frame.size.height) {
            UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.size.width/2, frame.size.height/2) radius:frame.size.width/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
            CAShapeLayer* shape = [CAShapeLayer layer];
            shape.path = path.CGPath;
            self.layer.mask = shape;
        }
    }
    return self;
}


-(void)setDefaultHightlightedImage{
    [self setBackgroundImage:[self imageWithColor:RGBA(0, 0, 0, 0.03) andSize:self.frame.size] forState:UIControlStateHighlighted];
}



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




-(void)dealloc{
    _titStr = nil;
}

- (void)setTopLeft:(BOOL)topLeft {
    _topLeft = topLeft;
    _corners |= UIRectCornerTopLeft;
}

- (void)setTopRigth:(BOOL)topRigth {
    _topRigth = topRigth;
    _corners |= UIRectCornerTopRight;
}

- (void)setBottomLeft:(BOOL)bottomLeft {
    _bottomLeft = bottomLeft;
    _corners |= UIRectCornerBottomLeft;
}

- (void)setBottomRigth:(BOOL)bottomRigth {
    _bottomRigth = bottomRigth;
    _corners |= UIRectCornerBottomRight;
}


- (void)setCornerRadius:(int)cornerRadius {
    _cornerRadius = cornerRadius;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    UIBezierPath *maskPath =
//    [UIBezierPath bezierPathWithRoundedRect:self.bounds
//                          byRoundingCorners:_corners
//                                cornerRadii:CGSizeMake(_cornerRadius, _cornerRadius)];
//    
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame         = self.bounds;
//    maskLayer.path          = maskPath.CGPath;
//    self.layer.mask         = maskLayer;
//}


- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size{
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
