//
//  EMWebViewController.h
//  emi
//
//  Created by zk on 15-3-3.
//  Copyright (c) 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMViewController.h"
#import "NJKWebViewProgress.h"



@interface EMWebViewController : EMViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>

@property(nonatomic,strong)NSString *viewtitle;
@property(nonatomic,strong)NSString *weburl;
@property(nonatomic,strong)NSString *imgurl;
@property(nonatomic,strong)NSString *wxsharetitle;
@property(nonatomic,strong)UIWebView *webview;

@end
