//
//  UILabel+countDown.h
//  emeNew
//
//  Created by zk on 16/1/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CommonProtocol.h"

@interface UILabel(countDown)

- (void)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color andBlock:(void(^)(BOOL ret))countDownBlock;


@end
