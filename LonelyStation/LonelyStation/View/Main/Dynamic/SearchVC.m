//
//  SearchVC.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/4.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "SearchVC.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AllDynamicCell.h"
#import "PersonalStationDetailVC.h"


@interface SearchVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate>

@property (nonatomic,strong) UICollectionView *loverCollectionView;
@property (nonatomic,assign) int from;
@property (nonatomic,assign) int cnt;
@property (nonatomic,strong) MainViewVM  *mainViewVM;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,copy) NSString *currentTitle;
@property (nonatomic,strong) UISearchBar *searchBar;



@end

@implementation SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData:YES];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self pushDownLoadAnimate];
}

- (void)initViews {
    _currentTitle = @"";
    
    _searchBar = [[UISearchBar alloc] initWithFrame:[[self.viewNaviBar class] titleViewFrame]];
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.backgroundImage = [[UIImage alloc] init];
    _searchBar.delegate = self;
    // 设置SearchBar的颜色主题为白色
    _searchBar.barTintColor = [UIColor whiteColor];
    [self.viewNaviBar addSubview:_searchBar];
    
    
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 50*kScale, 30)];
    [buyBtn setTitleColor:RGB(0xdd, 0xdd, 0xdd) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Search") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(pushDownLoadAnimate) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    
    
    
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
    [_loverCollectionView registerClass:[AllDynamicCell class] forCellWithReuseIdentifier:@"MainBoutiqueCell"];
}



/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    if (_dataArray.count == _from + _cnt) {
        _from += _cnt;
        [self loadData:NO];
    }else{
        _loverCollectionView.mj_footer.state = MJRefreshStateNoMoreData;
    }
}

-(void)back:(id)sender {
    [self.view endEditing:YES];
    [super back:sender];
}

- (void)pushDownLoadAnimate{
    _currentTitle = _searchBar.text;
    [self.view endEditing:YES];
    _from = 0;
    [self.dataArray removeAllObjects];
    [self.loverCollectionView reloadData];

    [self loadData:YES];
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
    [_mainViewVM getAirportListWithBlock:^(NSArray *arr, BOOL ret, NSString *msg) {
        SS(weakSelf, strongSelf);
        if (showHUD) {
            [UIUtil hideHUD:strongSelf.loverCollectionView];
        }
        [strongSelf endRefesh];
        if (ret && arr && ![arr isEqual:[NSNull null]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.from == 0) {
                    [strongSelf.dataArray removeAllObjects];
                }
                [strongSelf.dataArray addObjectsFromArray:arr];
                [strongSelf.loverCollectionView reloadData];
            });
        }else {
            [strongSelf.view.window makeToast:msg duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    } andFrom:[NSString stringWithFormat:@"%d",_from] andCnt:[NSString stringWithFormat:@"%d",_cnt] andTitle:_currentTitle];
}


-(void)endRefesh{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loverCollectionView.mj_header endRefreshing];
        [_loverCollectionView.mj_footer endRefreshing];
    });
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.dataArray[indexPath.row];
    BoardcastObj *obj = [[BoardcastObj alloc] initWithJSONDict:dict];
    obj.backImgURL = obj.imageURL;
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.index =(int)indexPath.row;
    personalRecord.lonelyUser = obj.user;
    [self.navigationController pushViewController:personalRecord animated:YES];
}


#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"MainBoutiqueCell";
    AllDynamicCell * boutiqueCell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    NSDictionary *dict = self.dataArray[indexPath.row];
    [boutiqueCell setValueWithDict:dict];
    return boutiqueCell;
}

- (void)shouldReload:(LonelyStationUser*)aLoneyUser {
    
}

#pragma mark -- UICollectionViewDelegate
//设置每个 UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width-48)/2, 182*kScale);
}

//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 16, 13,16);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
