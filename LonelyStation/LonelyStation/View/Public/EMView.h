//
//  EMView.h
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMView : UIView

@property(nonatomic,assign)CGFloat borderWidth;

@property(nonatomic,strong)UIColor *borderColor;

-(id)initWithFrame:(CGRect)frame andConners:(int)conner;

@end
