//
//  UIView+Masony.h
//  Carpenter
//
//  Created by zk on 15/4/22.
//  Copyright (c) 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Masony)



/**
 *  视图添加约束，使之和父控件一样大
 *
 *  @param insets insets
 */
-(void)masViewAddConstraintMakeEqualSuperViewWithInsets:(UIEdgeInsets)insets;




@end
