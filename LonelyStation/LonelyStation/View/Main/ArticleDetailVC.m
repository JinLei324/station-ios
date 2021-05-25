//
//  ArticleDetailVC.m
//  LonelyStation
//
//  Created by zk on 16/10/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ArticleDetailVC.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "EMUtil.h"
#import "EMWebViewController.h"

@interface ArticleDetailVC ()<UIWebViewDelegate>{
    MainViewVM *_mainViewVM;
    EMButton *_likeBtn;
    EMLabel *_fromLabel;
    EMLabel *_clickLabel;
    EMLabel *_titleLabel;
    UIWebView *_webView;
    UIScrollView *_scroll;
    EMButton *_fromPageBtn;
    EMLabel *_explanLabel;
}

@property (nonatomic,strong)GADBannerView *bannerView;


@end

@implementation ArticleDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:_category.categoriesName andColor:RGB(145,90,173)];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)initViews {
    _mainViewVM = [[MainViewVM alloc] init];
    _likeBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 33, 24, 24)];
    [_likeBtn setImage:[UIImage imageNamed:@"Profile_attention"] forState:UIControlStateNormal];
    [_likeBtn setImage:[UIImage imageNamed:@"Profile_two_heart"] forState:UIControlStateSelected];
    [_likeBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:_likeBtn];
    [self setLike];
    
    UIImageView *fromImgView = [[UIImageView alloc] initWithFrame:Rect(16*kScale, 64 + 13*kScale, 13*kScale, 12*kScale)];
    fromImgView.image = [UIImage imageNamed:@"BTmoreTopic"];
    [self.view addSubview:fromImgView];
    
    _fromLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(fromImgView)+7*kScale, 64 + 12*kScale, kScreenW - (PositionX(fromImgView)+7*kScale + 50*kScale), 13*kScale)];
    _fromLabel.textColor = RGB(51,51,51);
    _fromLabel.font = ComFont(12*kScale);
    
    _fromLabel.text = [NSString stringWithFormat:@"%@:%@/%@",Local(@"From"),_article.productNo,[EMUtil getYearAndMonthAndDayWithString:_article.productDateAdd]];
    [self.view addSubview:_fromLabel];
    
    _clickLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW - 80*kScale, _fromLabel.frame.origin.y, 70*kScale, 13*kScale)];
    _clickLabel.textColor = RGB(51,51,51);
    _clickLabel.font = ComFont(12*kScale);
    _clickLabel.text = [NSString stringWithFormat:@"%@%@",_article.productClick,Local(@"Seen")];
    _clickLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_clickLabel];
    
    _titleLabel = [[EMLabel alloc] initWithFrame:Rect(16*kScale, PositionY(_fromLabel) + 10*kScale, kScreenW - 2 * 16*kScale, 14*kScale)];
    _titleLabel.textColor = RGB(51,51,51);
    _titleLabel.font = ComFont(13*kScale);
    _titleLabel.text = _article.productName;
    [self.view addSubview:_titleLabel];
    
    _scroll = [[UIScrollView alloc] initWithFrame:Rect(0, PositionY(_titleLabel)+9*kScale, kScreenW, kScreenH - PositionY(_titleLabel))];

    _bannerView = [[GADBannerView alloc] initWithFrame:Rect(18*kScale, 0, kScreenW - 36*kScale, 145*kScale)];
    [_scroll addSubview:_bannerView];
    self.bannerView.adUnitID = @"ca-app-pub-6788219854713465/9938524234";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    _webView = [[UIWebView alloc] initWithFrame:Rect(18*kScale, PositionY(_bannerView)+7*kScale, kScreenW - 36*kScale, 300*kScale)];
    _webView.delegate = self;
    [_webView setOpaque:NO];
    _webView.backgroundColor = [UIColor clearColor];
    [_scroll addSubview:_webView];
    UIScrollView *tempView = (UIScrollView *)[_webView.subviews objectAtIndex:0];
    tempView.scrollEnabled = NO;
    
    _fromPageBtn = [[EMButton alloc] initWithFrame:Rect(18*kScale, PositionY(_webView)+6*kScale, kScreenW - 36*kScale, 14*kScale)];
    [_fromPageBtn setTitle:[NSString stringWithFormat:@"%@:%@",Local(@"FromSource"),_article.productMsg] forState:UIControlStateNormal];
    [_fromPageBtn setTitleColor:RGB(253,125,255) forState:UIControlStateNormal];
    [_fromPageBtn.titleLabel setFont:ComFont(13*kScale)];
    [_fromPageBtn addTarget:self action:@selector(toHtmlAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scroll addSubview:_fromPageBtn];
    
    
    _explanLabel = [[EMLabel alloc] initWithFrame:Rect(18*kScale, PositionY(_fromPageBtn)+10*kScale, kScreenW - 36*kScale, 45*kScale)];
    _explanLabel.backgroundColor = RGB(255,252,0);
    _explanLabel.textColor = RGB(0,0,0);
    _explanLabel.font = ComFont(12*kScale);
    _explanLabel.text = Local(@"Explan");
    _explanLabel.numberOfLines = 3;
    [_scroll addSubview:_explanLabel];
    [self.view addSubview:_scroll];
}

- (void)uploadInfo {
    _fromLabel.text = [NSString stringWithFormat:@"%@:%@/%@",Local(@"From"),_article.productNo,[EMUtil getYearAndMonthAndDayWithString:_article.productDateAdd]];
    [_fromPageBtn setTitle:[NSString stringWithFormat:@"%@:%@",Local(@"FromSource"),_article.productMsg] forState:UIControlStateNormal];
    _titleLabel.text = _article.productName;
    _clickLabel.text = [NSString stringWithFormat:@"%@%@",_article.productClick,Local(@"Seen")];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGFloat height = [[_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    _webView.frame = Rect(18*kScale, PositionY(_bannerView)+7*kScale, kScreenW - 36*kScale, height);
    
    _fromPageBtn.frame = Rect(18*kScale, height + PositionY(_bannerView)+ 14*kScale, kScreenW - 36*kScale, 13*kScale);
    _explanLabel.frame = Rect(18*kScale, height + PositionY(_bannerView)+ 32*kScale, kScreenW - 36*kScale, 45*kScale);
    
    _scroll.contentSize = Size(kScreenW, PositionY(_explanLabel) + 50*kScale);
    
}



- (void)toHtmlAction:(EMButton*)btn {
    if (_article.productMsg && [_article.productMsg hasPrefix:@"http"]){
        EMWebViewController *webCtrl = [[EMWebViewController alloc] init];
        NSString *url = [_article.productMsg stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        webCtrl.weburl = url;
        [self.navigationController pushViewController:webCtrl animated:YES];
    }
}

- (void)setLike {
    if ([_article.isFavorite isEqualToString:@"Y"]) {
        [_likeBtn setSelected:YES];
    }else {
        [_likeBtn setSelected:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDetail];
}


- (void)loadDetail {
    [UIUtil showHUD:self.view];
    NSString *articID = @"";
    if (_article == nil) {
        articID = _articleID;
    }else{
        articID = _article.productId;
    }
    [_mainViewVM geArticleDetailWithId:articID andBlock:^(ArticleObj *article, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (article && ret) {
            _article = nil;
            _article = article;
            [self setLike];
            [self uploadInfo];
            _webView.backgroundColor = [UIColor clearColor];
            if (_article.productMsg && _article.productMsg.length > 0) {
                //如果有来源，直接把来源放上去
                NSURL *url = [[NSURL alloc] initWithString:_article.productMsg];
                [_webView loadRequest:[NSURLRequest requestWithURL:url]];
            }else{
                //没来源，加载html string
                NSString *htmls = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-size:15px;}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>"
                                   "%@"
                                   "</body>"
                                   "<script type='text/javascript'>"
                                   "a();\n"
                                   "function a(){\n"
                                   "var $img = document.getElementsByTagName('img');\n"
                                   "for(var p in  $img){\n"
                                   " $img[p].style.width = '100%%';\n"
                                   "$img[p].style.height ='auto'\n"
                                   "}\n"
                                   "}"
                                   "</script>"
                                   "</html>",_article.productContent];
                
                NSString *str1 = [self htmlEntityDecode:htmls];
                [_webView loadHTMLString:str1 baseURL:[NSURL URLWithString:_article.productMsg]];
            }
        }
    }];
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

//将HTML字符串转化为NSAttributedString富文本字符串
- (NSAttributedString *)attributedStringWithHTMLString:(NSString *)htmlString
{
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                               NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding) };
    
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    return [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
}

- (void)likeAction:(EMButton*)btn {
    WS(weakSelf);
    if (btn.selected) {
        //取消收藏
        [UIUtil showHUD:self.view];
        [_mainViewVM deleteArticleFavorate:_article.productId andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:weakSelf.view];
            if (ret && dict) {
                if ([[dict objectForKey:@"code"] intValue] == 1) {
                    btn.selected = !btn.selected;
                    [weakSelf.view.window makeToast:Local(@"CollectCancelSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                }else {
                    [weakSelf.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
            }else {
                [weakSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }];

    }else {
        //添加收藏
        [UIUtil showHUD:self.view];
        [_mainViewVM addArticleFavorate:_article.productId andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:weakSelf.view];
            if (ret && dict) {
                if ([[dict objectForKey:@"code"] intValue] == 1) {
                    btn.selected = !btn.selected;
                    [weakSelf.view.window makeToast:Local(@"CollectSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                }else {
                    [weakSelf.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
            }else {
                [weakSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }];
    }
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
