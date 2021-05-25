//
//  EMLabel.m
//  emeNew
//
//  Created by zk on 15/12/9.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "EMLabel.h"
#import "EMUtil.h"
@interface EMLabel()
{
    UIRectCorner _corners;
    CAShapeLayer *_maskLayer;
    int aConner;
    CAShapeLayer *_borderLayer;

}
@end

@implementation EMLabel

-(void)dealloc{
    _labelId = nil;
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




- (CGSize)contentSize {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.alignment = self.textAlignment;
    
    NSDictionary * attributes = @{NSFontAttributeName : self.font,
                                  NSParagraphStyleAttributeName : paragraphStyle};
    
    CGSize contentSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:attributes
                                                 context:nil].size;
    return contentSize;
}

- (void)startWithTimer:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color andBlock:(void(^)(BOOL ret))countDownBlock{
    __block int timeOut = (int)timeLine;
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;

    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        //倒计时结束，关闭
        if(timeOut<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self setTextColor:mColor];
                self.text = title;
                DLog(@"到了111===%d",(int)timeOut);
                countDownBlock(YES);
            });
        }else{
            int min = [EMUtil getMiniterWithTime:(int)timeOut];
            int sec = [EMUtil getSecWithTime:(int)timeOut];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.text = [NSString stringWithFormat:@"%.2d:%.2d%@",min,sec,subTitle];
                [self setTextColor:color];
            });
            timeOut--;
            
        }
    });
    dispatch_resume(_timer);
}

@end
