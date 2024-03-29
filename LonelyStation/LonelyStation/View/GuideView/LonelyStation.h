//
//  LonelyStation.h
//  LonelyStation
//
//  Created by zk on 15/4/27.
//  Copyright (c) 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewFeatureModel.h"


@interface LonelyStation : UIViewController

@property (nonatomic,strong) NSArray *images;



/*
 *  初始化
 */
+(instancetype)newFeatureVCWithModels:(NSArray *)models enterBlock:(void(^)())enterBlock;



/*
 *  是否应该显示版本新特性界面
 */
+(BOOL)canShowNewFeature;




@end
