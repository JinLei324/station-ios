//
//  EMLabel.h
//  emeNew
//
//  Created by zk on 15/12/9.
//  Copyright © 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+countDown.h"


@interface EMLabel : UILabel{
    dispatch_source_t _timer;
}

@property(nonatomic,copy)NSString *labelId;

@property(nonatomic,assign)CGFloat borderWidth;

@property(nonatomic,strong)UIColor *borderColor;

- (void)startWithTimer:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color andBlock:(void(^)(BOOL ret))countDownBlock;

- (CGSize)contentSize;

-(id)initWithFrame:(CGRect)frame andConners:(int)conner;

@end
