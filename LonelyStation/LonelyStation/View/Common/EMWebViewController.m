//
//  EMWebViewController.m
//  emi
//
//  Created by zk on 15-3-3.
//  Copyright (c) 2015年 zk. All rights reserved.
//

#import "EMWebViewController.h"
#import "NJKWebViewProgressView.h"
#import "EMButton.h"

//#import "UIImageView+WebCache.h"

@interface EMWebViewController (){
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    NSArray *activity;
}

@end

@implementation EMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"bounds==%@",NSStringFromCGRect(self.view.frame));
    self.webview = [[UIWebView alloc] initWithFrame:Rect(0, NaviBarHeight+21, kScreenW, kScreenH-NaviBarHeight-21)];
    _progressProxy = [[NJKWebViewProgress alloc] init];
    self.webview.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;

    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.viewNaviBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webview];
}




-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.viewNaviBar addSubview:_progressView];
    NSURL *url = [[NSURL alloc] initWithString:self.weburl];
    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
}


-(void)viewWillDisappear:(BOOL)animated{
//    [_progressView removeFromSuperview];
    [super viewWillDisappear:animated];
}

-(void)dealloc{
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
