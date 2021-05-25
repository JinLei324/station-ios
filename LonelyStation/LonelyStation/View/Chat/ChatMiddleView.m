//
//  ChatMiddleView.m
//  LonelyStation
//
//  Created by zk on 2016/12/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ChatMiddleView.h"

@implementation ChatMiddleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_delegate) {
        [_delegate didClickMain];
    }
    return nil;
}




@end
