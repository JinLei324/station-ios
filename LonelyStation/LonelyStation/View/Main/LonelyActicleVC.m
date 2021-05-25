//
//  LonelyActicleVC.m
//  LonelyStation
//
//  Created by zk on 16/10/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelyActicleVC.h"
#import "UIUtil.h"
#import "MainViewVM.h"
#import "LonelyArticleCell.h"
#import "ArticleCateVC.h"
#import "InfiniteScrollView.h"
#import "ArticleCateView.h"

@interface LonelyActicleVC ()<CellBtnClick1Delegate,UIScrollViewDelegate>{
    NSTimer *timer;
    BOOL shouldGo;
}

@property(nonatomic,strong)MainViewVM *mainViewVM;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)InfiniteScrollView *infiniteScroll1;
@property(nonatomic,strong)InfiniteScrollView *infiniteScroll2;

@end

@implementation LonelyActicleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainViewVM = [[MainViewVM alloc] init];
    [self.viewNaviBar setTitle:Local(@"ARTICLE") andColor:RGB(145,90,173)];
    _dataArray = [NSMutableArray array];
    
    
    [self initViews];
}

- (void)initViews {
    EMButton *headLiveBtn = [[EMButton alloc] initWithFrame:Rect(0, 64, kScreenW, 53*kScale)];
    [headLiveBtn setBackgroundImage:[UIImage imageNamed:@"topic_live_e"] forState:UIControlStateNormal];
    [headLiveBtn setBackgroundImage:[UIImage imageNamed:@"topic_live"] forState:UIControlStateHighlighted];
    [headLiveBtn addTarget:self action:@selector(LiveAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headLiveBtn];
    
    CGFloat width = kScreenW;
    CGFloat height = kScreenH - 64 - 53*kScale;
    _infiniteScroll1 = [[InfiniteScrollView alloc] initWithFrame:CGRectMake(0, PositionY(headLiveBtn), width/2.f, height)];
    _infiniteScroll1.backgroundColor = [UIColor clearColor];
    _infiniteScroll2 = [[InfiniteScrollView alloc] initWithFrame:CGRectMake(width/2.f, PositionY(headLiveBtn), width/2.f, height)];
    _infiniteScroll2.backgroundColor = [UIColor clearColor];
    _infiniteScroll1.delegate = self;
    _infiniteScroll2.delegate = self;
    [_infiniteScroll1 setDecelerationRate:UIScrollViewDecelerationRateFast];
    _infiniteScroll1.contentSize = Size(0, kScreenH*8);
    _infiniteScroll1.showsVerticalScrollIndicator = NO;
    _infiniteScroll2.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_infiniteScroll1];
    [self.view addSubview:_infiniteScroll2];
    
    [self setUpLayout];
}


- (void)LiveAction:(EMButton*)btn {
    EMWebViewController *webViewVC = [[EMWebViewController alloc] init];
    webViewVC.weburl = @"http://tw.pikolive.com/";
    [self.navigationController pushViewController:webViewVC animated:YES];
}

- (void)autoscroll {
    if (shouldGo) {
        CGFloat y = _infiniteScroll1.contentOffset.y;
        y = y + 0.25;
        [_infiniteScroll1 setContentOffset:CGPointMake(_infiniteScroll1.contentOffset.x, y)];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    shouldGo = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        shouldGo = NO;
    }
}

- (void)dealloc {
    shouldGo = NO;
    if (timer) {
        [timer invalidate];
    }
    timer = nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView

{
    UIScrollView *s1 = _infiniteScroll1;
    UIScrollView *s2 = _infiniteScroll2;
    if(scrollView == s1)
        
    {
        s2.delegate =nil;
        CGPoint p = CGPointMake(s1.contentOffset.x, s1.contentOffset.y*1.2);
        [s2 setContentOffset:p];
        
        s2.delegate =self;
        
    }else {
        
        s1.delegate =nil;
        
        CGPoint p = CGPointMake(s2.contentOffset.x, s2.contentOffset.y/1.2f);
        
        [s1 setContentOffset:p];
        
        s1.delegate =self;
    }
}

- (void)setUpLayout {
    [UIUtil showHUD:self.view];
    [_mainViewVM getArticleCatWithBlock:^(NSArray<Categories *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            [_dataArray addObjectsFromArray:arr];
            //设置两个scrollView的子view
            CGFloat leftY = 0;
            CGFloat rightY = 0;
            for (int j = 0;j<9; j++) {
                for (int i = 0; i<_dataArray.count; i++) {
                    Categories *cate = [_dataArray objectAtIndex:i];
                    if ([cate.side isEqualToString:@"left"]) {
                        ArticleCateView *articleCateView = [[ArticleCateView alloc] initWithFrame:Rect(0, leftY, kScreenW/2, kScreenW/3)];
                        articleCateView.category = cate;
                        articleCateView.index = i;
                        articleCateView.delegate = self;
                        [_infiniteScroll1 addSubview:articleCateView];
                        leftY += kScreenW/3;
                    }else {
                        ArticleCateView *articleCateView = [[ArticleCateView alloc] initWithFrame:Rect(0, rightY, kScreenW/2, kScreenW/2)];
                        articleCateView.category = cate;
                        articleCateView.index = i;
                        articleCateView.delegate = self;
                        [_infiniteScroll2 addSubview:articleCateView];
                        rightY += kScreenW/2;
                        
                    }
                }
            }
            if (_dataArray.count > 0) {
                shouldGo = YES;
                timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(autoscroll) userInfo:nil repeats:YES];
            }
        }
    }];
}

- (void)didClickCellBtn:(EMButton*)btn andIndex:(NSInteger)index {
    ArticleCateVC *articleCateVC = [[ArticleCateVC alloc] init];
    articleCateVC.category = self.dataArray[index];
    [self.navigationController pushViewController:articleCateVC animated:YES];
    
}





@end
