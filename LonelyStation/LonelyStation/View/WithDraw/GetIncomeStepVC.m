//
//  GetIncomeStepVC.m
//  LonelyStation
//
//  Created by zk on 2016/12/9.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "GetIncomeStepVC.h"

@interface GetIncomeStepVC ()

@end

@implementation GetIncomeStepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"HowGetFee")];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH-64)];
    [webView setOpaque:NO];
    [webView setBackgroundColor:[UIColor clearColor]];
    NSString *htmlStr = [NSString stringWithFormat:@"%@%@",self.subject,self.content];
    [self.view addSubview:webView];
    NSString *str1 = [self htmlEntityDecode:htmlStr];
    [webView loadHTMLString:str1 baseURL:nil];
    // Do any additional setup after loading the view.
}


//将 &lt 等类似的字符转化为HTML中的“<”等
- (NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]; // Do this last so that, e.g. @"&amp;lt;" goes to @"&lt;" not @"<"
    
    return string;
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
