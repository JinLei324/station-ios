//
//  EMTabBarController.m
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "EMTabBarController.h"

@implementation EMTabBarController

-(void)viewWillAppear:(BOOL)animated{
    self.fd_interactivePopDisabled = YES;
    if (self.isHiddenNavigationBar) {
        [self.navigationController setNavigationBarHidden:YES];
    }else{
        [self.navigationController setNavigationBarHidden:NO];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return AppBarStyle;
}

@end
