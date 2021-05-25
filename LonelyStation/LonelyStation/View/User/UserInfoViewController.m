//
//  UserInfoViewController.m
//  LonelyStation
//
//  Created by zk on 15/12/7.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "UserInfoViewController.h"

@implementation UserInfoViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor brownColor]];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [testBtn setBackgroundColor:[UIColor blueColor]];
    [testBtn setTitle:@"回登录" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];

}


-(void)test:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
