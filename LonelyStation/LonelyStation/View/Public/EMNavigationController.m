//
//  EMNavigationController.m
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import "EMNavigationController.h"

@implementation EMNavigationController

-(void)viewDidLoad{
//    UIBarButtonItem *barbutton =[[UIBarButtonItem alloc] init];
//    barbutton.title = @"";
//    [barbutton setTarget:self];
//    [barbutton setAction:@selector(back:)];
//    self.navigationBar.barStyle = UIStatusBarStyleDefault;
//    [self.navigationBar setTintColor:[UIColor whiteColor]];
//    self.navigationItem.leftBarButtonItem = barbutton;
//    barbutton = nil;
    [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];
    self.navigationBar.barStyle = UIBarStyleBlack;

//    self.navigationBar.barStyle = UIBarStyleBlack;
    [super viewDidLoad];
 
}

-(UIStatusBarStyle)preferredStatusBarStyle

{
    
//    UIViewController* topVC = self.topViewController;
    
    return AppBarStyle;
    
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden{
    return self.topViewController;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

//-(void)back:(id)sender{
//    [self popViewControllerAnimated:YES];
//}

@end
