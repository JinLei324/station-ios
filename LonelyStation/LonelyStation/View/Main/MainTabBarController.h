//
//  MainTabBarController.h
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "EMTabBarController.h"
#import "LeftSlideViewController.h"

@interface MainTabBarController : EMTabBarController

@property(weak,nonatomic)LeftSlideViewController *slideViewCtl;
@property(assign,nonatomic)BOOL isShowAnimation; //自动登录的时候用
@property(assign,nonatomic)BOOL shouldLogin3rd; //要第三方登录

-(void)sliderLeftController;



@end
