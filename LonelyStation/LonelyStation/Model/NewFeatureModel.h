//
//  NewFeatureModel.h
//  LonelyStation
//
//  Created by zk on 15/4/27.
//  Copyright (c) 2015年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NewFeatureModel : NSObject

@property (nonatomic,strong) UIImage *image;


/*
 *  初始化
 */
+(instancetype)model:(UIImage *)image;

@end
