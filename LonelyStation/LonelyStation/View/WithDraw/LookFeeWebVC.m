//
//  LookFeeWebVC.m
//  LonelyStation
//
//  Created by zk on 2016/12/10.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LookFeeWebVC.h"
#import "UIUtil.h"

@interface LookFeeWebVC ()<UIWebViewDelegate>

@end

@implementation LookFeeWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    
    [self.viewNaviBar setTitle:_navTitle];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH-64)];
    [webView setOpaque:NO];
    [webView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:webView];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
    // Do any additional setup after loading the view.
    [UIUtil showHUD:self.view];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIUtil hideHUD:self.view];
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width];
    [webView stringByEvaluatingJavaScriptFromString:meta];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
