//
//  ArticleCateVC.m
//  LonelyStation
//
//  Created by zk on 16/10/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ArticleCateVC.h"
#import "MainViewVM.h"
#import "EMImageView.h"
#import "LeftSlideViewController.h"
#import "EMTableView.h"
#import "ArticleCateCell.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "ArticleDetailVC.h"

@interface ArticleCateVC ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate> {
    EMButton *_maskBtnView;
    EMView *_warnView;
    EMButton *_noLongerWarn;
    NSInteger _currentRow;
}

@property(nonatomic,strong)MainViewVM *mainViewVM;

@property(nonatomic,strong)EMImageView *topicImageView;

@property(nonatomic,strong)UIScrollView *articleScrollView;

@property(nonatomic,strong)NSMutableArray *tableViewArray;

@property(nonatomic,strong)NSMutableArray *dataArray;

@property(nonatomic,strong)NSMutableArray *fromArray;

@property(nonatomic,assign)int cnt;

@property(nonatomic,assign)int currentIndex;

@property(nonatomic,strong)UISegmentedControl *seg;



@end

@implementation ArticleCateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainViewVM = [[MainViewVM alloc] init];
    [self.viewNaviBar setTitle:_category.categoriesName andColor:RGB(145,90,173)];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)initViews {
    CGFloat x = 42*kScale;
    CGFloat y = 80*kScale;
    CGFloat width = kScreenW - 2*x;
    CGFloat height = 24*kScale;
//    _topicImageView = [[EMImageView alloc] initWithFrame:Rect(x, y, width, height)];
//    _topicImageView.image = [UIImage imageNamed:@"topic_all_left"];
//    [self.view addSubview:_topicImageView];
    
    
    EMButton *homeBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 33, 24, 24)];
    [homeBtn setImage:[UIImage imageNamed:@"enjoyHome_d"] forState:UIControlStateNormal];
    [homeBtn addTarget:self action:@selector(homeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:homeBtn];
    
    
    NSArray *insurArry = @[[NSString stringWithFormat:@"%@%@",Local(@"All"),_category.categoriesName],[NSString stringWithFormat:@"%@%@",Local(@"Myfavorate"),_category.categoriesName]];
    UISegmentedControl *SEG = [[UISegmentedControl alloc]initWithItems:insurArry];
    SEG.frame = Rect(x, y, width, height);
    SEG.tintColor = RGB(145,90,173);
    SEG.selectedSegmentIndex = 0;
    UIFont *font = ComFont(13*kScale);   // 设置字体大小
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [SEG setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [SEG addTarget:self action:@selector(segmentValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:SEG];
    self.seg = SEG;
    
//    EMLabel *leftLabel = [[EMLabel alloc] initWithFrame:Rect(0, 0, width/2.f, height)];
//    leftLabel.text = [NSString stringWithFormat:@"%@%@",Local(@"All"),_category.categoriesName];
//    leftLabel.textColor = RGB(255, 255, 255);
//    leftLabel.font = ComFont(13*kScale);
//    leftLabel.textAlignment = NSTextAlignmentCenter;
//    [_topicImageView addSubview:leftLabel];
//
//    EMLabel *rightLabel = [[EMLabel alloc] initWithFrame:Rect(width/2, 0, width/2.f, height)];
//    rightLabel.text = [NSString stringWithFormat:@"%@%@",Local(@"Myfavorate"),_category.categoriesName];
//    rightLabel.textColor = RGB(255, 255, 255);
//    rightLabel.font = ComFont(13*kScale);
//    rightLabel.textAlignment = NSTextAlignmentCenter;
//    [_topicImageView addSubview:rightLabel];
//    [_topicImageView setUserInteractionEnabled:YES];
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//    [_topicImageView addGestureRecognizer:gesture];
    
    x = 0;
    y = PositionY(SEG) + 7*kScale;
    height = kScreenH - y;
    _articleScrollView = [[UIScrollView alloc] initWithFrame:Rect(x, y, kScreenW, height)];
    [_articleScrollView setContentSize:Size(kScreenW*2, 0)];
    _articleScrollView.pagingEnabled = YES;
    _articleScrollView.directionalLockEnabled = YES;
    _articleScrollView.delegate = self;
    [self.view addSubview:_articleScrollView];
    _tableViewArray = [NSMutableArray array];
    _dataArray = [NSMutableArray array];
    _fromArray = [NSMutableArray arrayWithObjects:@"0",@"0",nil];
    _currentIndex = 0;
    _cnt = 20;
    _mainViewVM = [[MainViewVM alloc] init];
    
    for (int i = 0; i<2; i++) {
        NSMutableArray *arr = [NSMutableArray array];
        [_dataArray addObject:arr];
        EMTableView *tableView = [[EMTableView alloc] initWithFrame:Rect(kScreenW * i, 0, kScreenW, height)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.tableHeaderView = [[UIView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
        tableView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];
        
        [_articleScrollView addSubview:tableView];
        [_tableViewArray addObject:tableView];
    }
    [self loadAll:YES];
    
    _maskBtnView = [[EMButton alloc] initWithFrame:Rect(0, 0, ScreenWidth, ScreenHeight)];
    _maskBtnView.alpha = 0;
    _maskBtnView.backgroundColor = RGBA(0, 0, 0,0.6);
    [_maskBtnView addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_maskBtnView];
    
    height = 239*kScale;
    y = (kScreenH - height)/2.f;
    _warnView = [[EMView alloc] initWithFrame:Rect(0, y, kScreenW, height)];
    _warnView.backgroundColor = RGB(0xff, 0xff, 0xff);
    [_maskBtnView addSubview:_warnView];
    
    x = 58;
    y = 58;
    width = kScreenW - 2.f * x;
    height = 17*kScale;
    EMLabel *warnLabel = [[EMLabel alloc] initWithFrame:Rect(x, y, width, height)];
    warnLabel.textColor = RGB(78,78,78);
    warnLabel.font = ComFont(16*kScale);
    warnLabel.text = Local(@"Warn18Ban");
    [_warnView addSubview:warnLabel];
    
    _noLongerWarn = [[EMButton alloc] initWithFrame:Rect(x, PositionY(warnLabel)+25*kScale, 18*kScale, 18*kScale)];
    [_noLongerWarn setImage:[UIImage imageNamed:@"topic_check_no"] forState:UIControlStateNormal];
    [_noLongerWarn addTarget:self action:@selector(notShowAction:) forControlEvents:UIControlEventTouchUpInside];
    [_noLongerWarn setImage:[UIImage imageNamed:@"topic_check"] forState:UIControlStateSelected];
    [_warnView addSubview:_noLongerWarn];
    
    EMLabel *notShowLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_noLongerWarn)+7*kScale, PositionY(warnLabel)+26*kScale, kScreenW-120*kScale, 17*kScale)];
    notShowLabel.font = ComFont(16*kScale);
    notShowLabel.textColor = RGB(78,78,78);
    notShowLabel.text = Local(@"NotShow");
    [_warnView addSubview:notShowLabel];
    
    x = 53;
    y = PositionY(notShowLabel)+49*kScale;
    width = 92*kScale;
    height = 35*kScale;
    EMButton *cancelBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, height) andConners:5];
    cancelBtn.borderColor = RGB(0,0,0);
    cancelBtn.borderWidth = 1;
    [cancelBtn setTitle:Local(@"Leave") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:RGB(78,78,78) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [_warnView addSubview:cancelBtn];
    
    x = PositionX(cancelBtn) + 29*kScale;
    width = 145*kScale;
    EMButton *IM18Btn = [[EMButton alloc] initWithFrame:Rect(x, y, width, height) andConners:5];
    IM18Btn.borderColor = RGB(0,0,0);
    IM18Btn.borderWidth = 1;
    [IM18Btn setTitle:Local(@"IM18Older") forState:UIControlStateNormal];
    [IM18Btn setTitleColor:RGB(78,78,78) forState:UIControlStateNormal];
    [IM18Btn addTarget:self action:@selector(IM18BtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_warnView addSubview:IM18Btn];
}

- (void)notShowAction:(EMButton*)btn {
    btn.selected = !btn.selected;
}


- (void)IM18BtnAction:(EMButton*)btn {
    [self hiddenMask:btn];
    if (_noLongerWarn.selected) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isWarn18"];
    }
    ArticleObj *article = [_dataArray[_currentIndex] objectAtIndex:_currentRow];
    if (article) {
        ArticleDetailVC *detail = [[ArticleDetailVC alloc] init];
        detail.article = article;
        detail.category = _category;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)hiddenMask:(EMButton*)btn {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 0;
        CGRect frame = _maskBtnView.frame;
        _warnView.frame = Rect(frame.size.width/2, frame.size.height/2, 0, 0);
    } completion:NULL];
}

//显示送礼
- (void)sendGiftAction:(EMButton*)btn {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 1;
        CGFloat height = 239*kScale;
        CGFloat y = (kScreenH - height)/2.f;
        _warnView.frame = Rect(0, y, kScreenW, height);
        
        
    } completion:NULL];
}


/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    NSString *from = _fromArray[_currentIndex];
    int _from = [from intValue];
    _from += _cnt;
    _fromArray[_currentIndex] = [NSString stringWithFormat:@"%d",_from];
    if (_currentIndex == 0) {
        [self loadAll:NO];
    }else {
        [self loadMyFavorate:NO];
    }
}

/**
 *  下拉刷新
 */
-(void)pushDownLoad{
    _fromArray[_currentIndex] = [NSString stringWithFormat:@"%d",0];
    if (_currentIndex == 0) {
        [self loadAll:NO];
    }else {
        [self loadMyFavorate:NO];
    }
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _articleScrollView) {
        CGFloat x = scrollView.contentOffset.x;
        if (x == kScreenW) {
            self.seg.selectedSegmentIndex = 1;
            _currentIndex = 1;
            [self loadMyFavorate:YES];
        }else {
            self.seg.selectedSegmentIndex = 0;
            _currentIndex = 0;
            [self loadAll:YES];

        }
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = _dataArray[_currentIndex];
    return arr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cell";
    ArticleCateCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ArticleCateCell alloc] initWithSize:Size(kScreenW, 70*kScale) reuseIdentifier:identifier];
    }
    ArticleObj *article = [_dataArray[_currentIndex] objectAtIndex:indexPath.row];
    cell.articleObj = article;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70*kScale;
}

- (void)homeAction:(EMButton*)btn {
    for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
        if ([NSStringFromClass([self.navigationController.viewControllers[i] class]) isEqualToString:@"LeftSlideViewController"]) {
            LeftSlideViewController *mainVC = self.navigationController.viewControllers[i];
            [self.navigationController popToViewController:mainVC animated:YES];
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _currentRow = indexPath.row;
    ArticleObj *article = [_dataArray[_currentIndex] objectAtIndex:indexPath.row];
    BOOL isWarning = [[NSUserDefaults standardUserDefaults] boolForKey:@"isWarn18"];
    if (!isWarning && [article.product18Ban isEqualToString:@"Y"]) {
        [self sendGiftAction:nil];
    }else {
        ArticleDetailVC *detail = [[ArticleDetailVC alloc] init];
        detail.article = article;
        detail.category = _category;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)segmentValueChange:(UISegmentedControl*)seg {
    if (seg.selectedSegmentIndex == 0) {
        _currentIndex = 0;
        [self loadAll:YES];
        [_articleScrollView setContentOffset:Point(0, 0)];
    }else{
        _currentIndex = 1;
        [self loadMyFavorate:YES];
        [_articleScrollView setContentOffset:Point(kScreenW, 0)];
    }
}




-(void)endRefesh{
    UITableView *tableView = _tableViewArray[_currentIndex];
    [tableView.mj_header endRefreshing];
    [tableView.mj_footer endRefreshing];
}


//加载全部
- (void)loadAll:(BOOL)isAnimate {
    if (isAnimate) {
        [UIUtil showHUD:self.view];
    }
    NSMutableArray *aDataArr = _dataArray[_currentIndex];
    [_mainViewVM getAllArticleWithCateId:_category.categoriesId andStart:_fromArray[_currentIndex] andEnd:[NSString stringWithFormat:@"%d",_cnt] andBlock:^(NSArray<ArticleObj *> *arr, BOOL ret) {
        if (isAnimate) {
            [UIUtil hideHUD:self.view];
        }
        if (ret && arr) {
            if ([_fromArray[_currentIndex] intValue] == 0) {
                [aDataArr removeAllObjects];
            }
            [aDataArr addObjectsFromArray:arr];
            [_tableViewArray[_currentIndex] reloadData];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        [self endRefesh];
    }];
}

//加载我喜欢的
- (void)loadMyFavorate:(BOOL)isAnimate {
    NSMutableArray *aDataArr = _dataArray[_currentIndex];
    if (isAnimate) {
        [UIUtil showHUD:self.view];
    }
    [_mainViewVM getMyCollectionArticleWithCateId:_category.categoriesId andStart:_fromArray[_currentIndex] andEnd:[NSString stringWithFormat:@"%d",_cnt] andBlock:^(NSArray<ArticleObj *> *arr, BOOL ret) {
        if (isAnimate) {
            [UIUtil hideHUD:self.view];
        }
        if (ret && arr) {
            if ([_fromArray[_currentIndex] intValue] == 0) {
                [aDataArr removeAllObjects];
            }
            [aDataArr addObjectsFromArray:arr];
            [_tableViewArray[_currentIndex] reloadData];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        [self endRefesh];

    }];

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
