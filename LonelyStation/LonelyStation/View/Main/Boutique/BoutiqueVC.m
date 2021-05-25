//
//  BoutiqueVC.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/3/24.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "BoutiqueVC.h"
#import "UIUtil.h"
#import "MainViewVM.h"
#import "MainBoutiqueCell.h"
#import "PersonalStationDetailVC.h"

@interface BoutiqueVC ()<UICollectionViewDelegate,UICollectionViewDataSource,PersonalDetailInfoVCDelegate>

@property (nonatomic,strong) UICollectionView *loverCollectionView;
@property (nonatomic,assign) BOOL isLastPage;
@property (nonatomic,assign) int from;
@property (nonatomic,assign) int cnt;
@property (nonatomic,strong) MainViewVM  *mainViewVM;
@property (nonatomic,strong) NSMutableArray *dataArray;


@end

@implementation BoutiqueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"BoutiqueStation") andColor:RGB(145,90,173)];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData:YES];
}


- (void)initViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(0.f, 5, 9.f, 0);
    _loverCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, NaviBarHeight+StatusBarHeight, self.view.frame.size.width, self.view.frame.size.height - NaviBarHeight-StatusBarHeight) collectionViewLayout:layout];
    [self.view addSubview:_loverCollectionView];
    _loverCollectionView.delegate = self;
    _loverCollectionView.dataSource =self;
    _loverCollectionView.alwaysBounceVertical = YES;
    _loverCollectionView.backgroundColor = [UIColor clearColor];
    _loverCollectionView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
    _loverCollectionView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];
    _cnt = 30;
    _mainViewVM = [[MainViewVM alloc] init];
    _dataArray = [NSMutableArray array];
    //注册精品电台
    [_loverCollectionView registerClass:[MainBoutiqueCell class] forCellWithReuseIdentifier:@"MainBoutiqueCell"];
}


/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    if (!_isLastPage) {
        _from += _cnt;
        [self loadData:NO];
    }else{
        _loverCollectionView.mj_footer.state = MJRefreshStateNoMoreData;
    }
}

/**
 *  下拉刷新
 */
-(void)pushDownLoad{
    _from = 0;
    [self loadData:NO];
}

-(void)loadData:(BOOL)showHUD{
    if (showHUD) {
        [UIUtil showHUD:self.loverCollectionView];
    }
    WS(weakSelf);
    [_mainViewVM getMianInfoBoutiqueStationListWithBlock:^(NSArray *arr, BOOL ret, NSString *msg) {
        SS(weakSelf, strongSelf);
        if (showHUD) {
            [UIUtil hideHUD:strongSelf.loverCollectionView];
        }
        [strongSelf endRefesh];
        if (ret && arr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.from == 0) {
                    [strongSelf.dataArray removeAllObjects];
                }
                [strongSelf.dataArray addObjectsFromArray:arr];
                if (strongSelf.dataArray.count >= _from + _cnt) {
                    strongSelf.isLastPage = NO;
                }else{
                    strongSelf.isLastPage = YES;
                }
                [strongSelf.loverCollectionView reloadData];
            });
        }else {
            [strongSelf.view.window makeToast:msg duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    } andFrom:[NSString stringWithFormat:@"%d",_from] andCnt:[NSString stringWithFormat:@"%d",_cnt]];
}


-(void)endRefesh{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loverCollectionView.mj_header endRefreshing];
        [_loverCollectionView.mj_footer endRefreshing];
    });
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"MainBoutiqueCell";
    MainBoutiqueCell * boutiqueCell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    NSDictionary *dict = self.dataArray[indexPath.row];
    [boutiqueCell setValueWithDict:dict];
    WS(weakSelf)
    [boutiqueCell setCellClickBlock:^(NSDictionary *dict) {
        SS(weakSelf, strongSelf);
        LonelyStationUser *lonelyUser = [[LonelyStationUser alloc] init];
        lonelyUser.userID = dict[@"userid"];
        PersonalDetailInfoVC *personalVC = [[PersonalDetailInfoVC alloc] init];
        personalVC.lonelyUser = lonelyUser;
        personalVC.delegate = strongSelf;
        [strongSelf.navigationController pushViewController:personalVC animated:YES];
    }];
    return boutiqueCell;
}

- (void)shouldReload:(LonelyStationUser*)aLoneyUser {
    
}

#pragma mark -- UICollectionViewDelegate
//设置每个 UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width-33)/3, (self.view.frame.size.width-33)/3 + 50);
}

//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 13,10);
}

//定义每个UICollectionView 的纵向间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}


-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
