//
//  UIZKRangeView.m
//  Test
//
//  Created by zk on 16/8/18.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UIZKRangeView.h"

@interface UIZKRangeView(){
    UILabel *_leftTextLabel;
    UILabel *_rightTextLabel;
}

@end


@implementation UIZKRangeView


- (void)setLeftHidden:(BOOL)isHidden {
    _leftRangeView.hidden = isHidden;
    _leftTextLabel.hidden = isHidden;
    _leftRangeView.frame = CGRectMake(0, (self.frame.size.height - 25)/2, 25, 25);
}

- (void)setRightHidden:(BOOL)isHidden {
    _rightTextLabel.text = [self getTimeWithCount:self.totalCount];
    _rightRangeValue = self.totalCount;
    _rightRangeView.hidden = isHidden;
    _rightTextLabel.hidden = isHidden;
    _rightRangeView.frame = CGRectMake(self.frame.size.width-25, (self.frame.size.height - 25)/2, 25, 25);
}



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initView];
    
    return self;
}


- (void)initView {
    
//    _line = [[UIView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 25)/2+25, self.frame.size.width, 2)];
//    _line.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.3);
//    [self addSubview:_line];
//    
//    _cursorView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 25)/2+20, 13*kScale, 13*kScale)];
//    
//    _cursorView.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.8);
//    _cursorView.layer.cornerRadius = _cursorView.frame.size.width/2;
//    _cursorView.layer.masksToBounds = YES;
//    _cursorView.center = Point(_cursorView.center.x, _line.center.y);
//    [self addSubview:_cursorView];
    
    
    _audioPlayView = [[AudioPlayView alloc] initWithFrame:Rect(0, 15*kScale, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_audioPlayView];
    
    
    
    _leftRangeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 25)/2, 25, 25)];
    
  
    _leftRangeView.userInteractionEnabled = YES;
    [self addSubview:_leftRangeView];
    _leftTextLabel = [[UILabel alloc] initWithFrame:Rect(0, 0, 25, 9)];
    _leftTextLabel.text = @"00:00";
    _leftTextLabel.textAlignment = NSTextAlignmentCenter;
    _leftTextLabel.textColor = RGB(0xff, 0xff, 0xff);
    _leftTextLabel.font = ComFont(8);
    [self addSubview:_leftTextLabel];

    
    _rightRangeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-25, (self.frame.size.height - 25)/2, 25, 25)];
    _rightRangeView.userInteractionEnabled = YES;
    [self addSubview:_rightRangeView];
    
    _rightTextLabel = [[UILabel alloc] initWithFrame:Rect(self.frame.size.width-25, 0, 25, 9)];
    _rightTextLabel.text = @"00:00";
    _rightTextLabel.textAlignment = NSTextAlignmentCenter;
    _rightTextLabel.textColor = RGB(0xff, 0xff, 0xff);
    _rightTextLabel.font = ComFont(8);
    [self addSubview:_rightTextLabel];
    
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_leftRangeView addGestureRecognizer:leftPan];
    [_rightRangeView addGestureRecognizer:rightPan];
    
}

- (NSString*)getTimeWithCount:(int)time {
    int seconds = time % 60;
    int minutes = (time / 60) % 60;
    NSString *str = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    return str;
}

//- (void)cursorAction:(UIPanGestureRecognizer*)pan {
//    UIView *view = pan.view;
//    CGRect rect = view.frame;
//    CGPoint point = [pan locationInView:self];
//    CGFloat width = _cursorView.frame.size.width;
//    CGFloat rightMaxX = self.bounds.size.width - width/2;
//    if (point.x > rightMaxX) {
//        point.x = rightMaxX;
//        rect.origin.x = point.x - width / 2;
//    }else if (point.x < 0){
//        point.x = 0;
//        rect.origin.x = 0;
//    }else {
//        rect.origin.x = point.x - width / 2;
//    }
//    view.frame = rect;
//    
//    [self updateCursorValue];
//}

- (void)setTotalCount:(int)totalCount {
    _totalCount = totalCount;
    [self updateValue];
}


- (void)updateCursorValue {
//    int leftValue = [self x2Value:_leftRangeView.frame.origin.x andAllValue:_totalCount andWidth:self.bounds.size.width - _leftRangeView.frame.size.width*2];
}

- (void)panAction:(UIPanGestureRecognizer*)pan {
    UIView *view = pan.view;
    CGRect rect = view.frame;
    CGPoint point = [pan locationInView:self];
    CGFloat width = _leftRangeView.frame.size.width;
    CGFloat leftMaxX = self.bounds.size.width - width * 3/2;
    CGFloat rightMaxX = self.bounds.size.width - width/2;
    CGFloat superViewWidth = self.bounds.size.width;
    
    UIView *leftView = _leftRangeView;
    UIView *rightView = _rightRangeView;
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
            
            CGRect aRect = _rightTextLabel.frame;
            aRect.origin.x = point.x + width / 2;
            _rightTextLabel.frame = aRect;
            
        }
        rect.origin.x = point.x - width / 2;
        view.frame = rect;
        CGRect frame =  leftMask.frame;
        frame.size.width = rect.origin.x;
        leftMask.frame = frame;
        
        rect = _leftTextLabel.frame;
        rect.origin.x = point.x - width / 2;
        _leftTextLabel.frame = rect;
        
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
            
            CGRect aRect = _leftTextLabel.frame;
            aRect.origin.x = leftView.frame.origin.x;
            _leftTextLabel.frame = aRect;
        }
        rect = _rightTextLabel.frame;
        rect.origin.x = rightView.frame.origin.x;
        _rightTextLabel.frame = rect;
    }
    //设置value
    [self updateValue];
}


- (void)updateValue {
    int leftValue = [self x2Value:_leftRangeView.frame.origin.x andAllValue:_totalCount andWidth:self.bounds.size.width - _leftRangeView.frame.size.width*2];
    _leftRangeValue = leftValue;
    _leftTextLabel.text =  [self getTimeWithCount:leftValue];
    
    leftValue = [self x2Value:_rightRangeView.frame.origin.x - _rightRangeView.frame.size.width  andAllValue:_totalCount andWidth:self.bounds.size.width - _rightRangeView.frame.size.width * 2];
    _rightRangeValue = leftValue;
    _rightTextLabel.text = [self getTimeWithCount:leftValue];

    if (_delegate && [_delegate respondsToSelector:@selector(zkDidMoveRange:andRightRange:)]) {
        [_delegate zkDidMoveRange:_leftRangeValue andRightRange:_rightRangeValue];
    }
    
}

-(int)x2Value:(CGFloat)x andAllValue:(CGFloat)allValue andWidth:(CGFloat)width{
    
    int value = 0.f;
    
    CGFloat perValue =  allValue / width;
    
    value = x * perValue;
    
    return value;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
