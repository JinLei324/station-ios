//
//  UILabel+countDown.m
//  emeNew
//
//  Created by zk on 16/1/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UILabel+countDown.h"
#import "EMUtil.h"

@implementation UILabel(countDown)

- (void)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color andBlock:(void(^)(BOOL ret))countDownBlock {
    
    //倒计时时间
    __block int timeOut = (int)timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
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
