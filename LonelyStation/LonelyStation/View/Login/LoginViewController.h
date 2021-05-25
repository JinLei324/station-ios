//
//  LoginViewController.h
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMViewController.h"
#import "LoginViewModel.h"

@interface LoginViewController :EMViewController

@property (nonatomic,assign)BOOL isHiddenAnimation;

- (void)setDefaultInfo;

- (void)scrollRight;

@end
