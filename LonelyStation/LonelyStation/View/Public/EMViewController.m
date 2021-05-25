//
//  EMViewController.m
//  emeNew
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import "EMViewController.h"
//#import "UIUtil.h"
#import "YYImage.h"
#import "UIImageView+LBBlurredImage.h"


@implementation EMViewController

@synthesize viewNaviBar = _viewNaviBar;

-(void)viewDidLoad{
    [super viewDidLoad];
//    [self.navigationController setNavigationBarHidden:YES];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:RGB(0xff, 0xff, 0xff)];
//    [self.view setBackgroundColor:RGB(0,0,0)];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
//    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
//    [self.view addSubview:backgroundImageView];
    //禁止滑动返回
    self.fd_interactivePopDisabled = YES;
    [self initNavBar];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return AppBarStyle;
}

-(void)setUpBarWithColor:(NSString*)color{
    if ([color isEqualToString:@"white"]) {
        [self.viewNaviBar setBarColor:RGB(0xfa, 0xfa, 0xfa)];
        [self.view setBackgroundColor:RGB(0xf4,0xf4,0xf4)];
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[YYImage imageNamed:@"back2"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewNaviBar setLeftBtn:btn];
        [self.viewNaviBar setBarLayer:RGB(0, 0, 0)];
        isWhiteBar = YES;
        [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];
    }else if ([color isEqualToString:@"black"]) {
        [self.viewNaviBar setBarColor:RGB(0x0d, 0x0d, 0x0d)];
        [self.view setBackgroundColor:RGB(0xff, 0xff, 0xff)];
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[YYImage imageNamed:@"back"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewNaviBar setLeftBtn:btn];
        [self.viewNaviBar setBarLayer:RGB(0, 0, 0)];
        isWhiteBar = NO;
        [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];
    }else{
        _viewNaviBar.userInteractionEnabled = YES;
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[YYImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [_viewNaviBar setLeftBtn:btn];
        isWhiteBar = NO;
        [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];
    }
}

-(void)initNavBar{
    _viewNaviBar = [[CustomNaviBarView alloc] initWithFrame:Rect(0.0f, 0.0f, [CustomNaviBarView barSize].width, [CustomNaviBarView barSize].height)];
    _viewNaviBar.m_viewCtrlParent = self;
    [_viewNaviBar setBackgroundColor:[UIColor clearColor]];
    _viewNaviBar.userInteractionEnabled = YES;
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"back_d"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [_viewNaviBar setLeftBtn:btn];
    [_viewNaviBar setTitle:self.titleStr];
    [self.view addSubview:_viewNaviBar];
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    if (self.isHiddenNavigationBar) {
        [_viewNaviBar setHidden:YES];
    }else{
        [_viewNaviBar setHidden:NO];
        [self.view bringSubviewToFront:_viewNaviBar];
    }
    if (isWhiteBar) {
        [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];

    }else{
        [[UIApplication sharedApplication] setStatusBarStyle: AppBarStyle];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];//即使没有显示在window上，也不会自动的将self.view释放。
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载 ，在WWDC视频也忽视这一点。
        if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
        {
            self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
        }
    }
}

@end
