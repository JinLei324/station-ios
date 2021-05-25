//
//  DynamicVC.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/3/24.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "DynamicVC.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AllDynamicCell.h"
#import "DynamicAllTitleView.h"
#import "DynamicNomalTitleView.h"
#import "PersonalStationDetailVC.h"
#import "SearchVC.h"
#import "LoginStatusObj.h"
#import "BoutiqueVC.h"

@interface DynamicVC ()<UICollectionViewDelegate,UICollectionViewDataSource,DynamicTitleDelegate,DynamicNomarlTitleDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) NSMutableArray *collectionViewsArray;//实体collectionView
@property (nonatomic,strong) UIScrollView *backScrollView;
@property (nonatomic,assign) BOOL isLastPage;
@property (nonatomic,assign) int cnt;
@property (nonatomic,strong) MainViewVM  *mainViewVM;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *fromArray;
@property (nonatomic,strong) NSMutableArray *keysArray;
@property (nonatomic,assign) int currentIndex;
@property (nonatomic,assign) int currentSort;
@property (nonatomic,strong) UIScrollView *topScrollView;
@property (nonatomic,strong) DynamicNomalTitleView *nomalTitleView;//第一层排序
@property (nonatomic,strong) DynamicNomalTitleView *nomalSecondView;//第二层排序
@property (nonatomic,strong) DynamicAllTitleView *titleView; //种类
@property (nonatomic,copy)NSString *currentCat;
@property (nonatomic,strong)UILabel *bridgeLabel;

@property (nonatomic,assign)BOOL isFirstIn;


@end

@implementation DynamicVC


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"AllRealStation")];
    [self initViews];
   
//    [self getAllCate];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    self.bridgeLabel.text = [NSString stringWithFormat:@"%@",user.unread];

    //1.获取全部分类
    //2.获取第一个分类下的全部
//    if(!_isFirstIn){
        [self getAllCate];
//        _isFirstIn = YES;
//    }
}


NSInteger customSort(id obj1, id obj2,void* context){
    return (NSComparisonResult)([(NSString*)obj1 intValue] > [(NSString*)obj2 intValue]);
}

- (void)getAllCate {
    WS(weakSelf)
    [_mainViewVM getAllCateWithBlock:^(NSDictionary *aDict, BOOL ret) {
        SS(weakSelf, strongSelf)
        if (ret && aDict) {
            NSArray *arr = (NSArray*)aDict;
            NSDictionary *dict = arr[0];
            NSArray *keys =  [dict.allKeys sortedArrayUsingFunction:customSort context:nil];
            NSMutableArray *titles = [NSMutableArray array];
            [titles addObject:Local(@"BoutiqueStation")];
            [strongSelf.keysArray addObject:@{Local(@"BoutiqueStation"):Local(@"BoutiqueStation")}];
            for (NSString *key in keys) {
                NSMutableDictionary *muDict = [NSMutableDictionary dictionary];
                [muDict setObject:dict[key] forKey:key];
                [titles addObject:dict[key]];
                [strongSelf.keysArray addObject:muDict];
            }
            [strongSelf.titleView setTitleWithArray:titles];
        }
    }];
}

- (void)dynamicDidSelectIndex:(NSInteger)index {
    if(index == 0) {
        //跳到精品电台
        if ([UIUtil checkLogin]) {
            BoutiqueVC *boutiqueVC = [[BoutiqueVC alloc] init];
            [self.navigationController pushViewController:boutiqueVC animated:YES];
        }
        return;
    }
    NSDictionary *dict = _keysArray[index];
    NSString *key = dict.allKeys[0];
    _currentCat = key;
    [self pushDownLoadWithAnimate];
}

- (void)dynamicNomalDidSelectIndex:(NSInteger)index andDynamicNomalTitleView:(DynamicNomalTitleView*)view {
    if (view == _nomalTitleView) {
        [_backScrollView setContentOffset:Point(index*kScreenW, 0)];
        _currentIndex = (int)index;
        if (_currentIndex == 1) {
            _currentSort = 4;
            [_nomalSecondView setSelectIndex:0];
        }else {
            _currentSort = (int)index;
        }
    }else {
        _currentSort = (int)index + 4;
    }
    [self pushDownLoadWithAnimate];
}

- (void)userInfo:(id)sender {
    [self.tabViewController sliderLeftController];
}


- (void)setLeftAndTitle {
    EMButton *userInfoBtn = [[EMButton alloc] initWithFrame:Rect(15, 33, 40, 40) isRdius:YES];
    //    [userInfoBtn setImage:[UIImage imageNamed:@"answer_no_photo"] forState:UIControlStateNormal];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined) {
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        [userInfoBtn yy_setImageWithURL:[NSURL URLWithString:user.file] forState:UIControlStateNormal placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:user.gender]]];
    }else {
        if ([loginStatus.gender isEqualToString:@"M"]) {
            [userInfoBtn setImage:[UIImage imageNamed:@"gender_M"] forState:UIControlStateNormal];
        }else{
            [userInfoBtn setImage:[UIImage imageNamed:@"gender_F"] forState:UIControlStateNormal];
        }
    }
    
    [userInfoBtn addTarget:self action:@selector(userInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setLeftBtn:nil];
    [self.viewNaviBar addSubview:userInfoBtn];
    
    //添加提示的文字
   _bridgeLabel = [[UILabel alloc] initWithFrame:Rect(PositionX(userInfoBtn) - 5, 33, 19, 13)];
    _bridgeLabel.layer.cornerRadius = 5;
    _bridgeLabel.layer.masksToBounds = YES;
    _bridgeLabel.backgroundColor = RGB(255,252,0);
    _bridgeLabel.textAlignment = NSTextAlignmentCenter;
    _bridgeLabel.text = @"0";
    _bridgeLabel.textColor = RGB(51,51,51);
    _bridgeLabel.font = ComFont(8);
    [self.viewNaviBar addSubview:_bridgeLabel];
    
    EMLabel *infoLabel = [[EMLabel alloc] initWithFrame:Rect((kScreenW - 200)/2, 33, 200, 44)];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = RGB(145,90,173);
    infoLabel.font = ComFont(19.f);
    infoLabel.text = Local(@"AllRealStation");
    [self.viewNaviBar addSubview:infoLabel];
    
    UIView *view = [UIView new];
    view.backgroundColor = RGB(171, 171, 171);
    [self.viewNaviBar addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.bottom.mas_equalTo(15);
        make.height.mas_equalTo(1);
    }];
}


- (void)initViews {
    [self setLeftAndTitle];
    EMButton *rightBtn = [[EMButton alloc] initWithFrame:Rect(0,35, 25, 25)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"BTmoreSearch"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"BTmoreSearch"] forState:UIControlStateHighlighted];
    [rightBtn.titleLabel setFont:ComFont(16)];
    
    [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,0.5) forState:UIControlStateNormal];
    [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,1) forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:rightBtn];
    
    
    _titleView = [[DynamicAllTitleView alloc] initWithFrame:Rect(0, NaviBarHeight+StatusBarHeight+20, ScreenWidth, 43*kScale)];
    [self.view addSubview:_titleView];
    _titleView.delegate = self;
    
    _nomalTitleView = [[DynamicNomalTitleView alloc] initWithFrame:Rect(43*kScale, CGRectGetMaxY(_titleView.frame), ScreenWidth-86*kScale, 55*kScale)];
    _nomalTitleView.delegate = self;
    NSArray *nomalTitleArray = @[Local(@"Newest"),Local(@"Smart"),Local(@"Hot"),Local(@"AllCat")];
    [self.view addSubview:_nomalTitleView];
    [_nomalTitleView setTitleWithArray:nomalTitleArray];
    
    _backScrollView = [[UIScrollView alloc] initWithFrame:Rect(0, CGRectGetMaxY(_nomalTitleView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_nomalTitleView.frame) - 49)];
    _backScrollView.delegate = self;
    [self.view addSubview:_backScrollView];
    [_backScrollView setContentSize:Size(kScreenW*4, 0)];
    [_backScrollView setPagingEnabled:YES];
    _collectionViewsArray = [NSMutableArray array];
    _fromArray = [NSMutableArray array];
    _dataArray = [NSMutableArray array];

    
    for (int i = 0; i < 4; i++) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(0.f, 5, 9.f, 0);
        UICollectionView *loverCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(i*kScreenW, 0, self.view.frame.size.width, _backScrollView.frame.size.height) collectionViewLayout:layout];
        if (i == 1) {
            _nomalSecondView = [[DynamicNomalTitleView alloc] initWithFrame:Rect(kScreenW, 0, ScreenWidth, 55*kScale)];
            _nomalSecondView.delegate = self;
            NSArray *nomalSecondTitleArray = @[Local(@"HearEver"),Local(@"ICare"),Local(@"IFavarate"),Local(@"IHeared"),Local(@"CareMe")];
            [_backScrollView addSubview:_nomalSecondView];
            [_nomalSecondView setTitleWithArray:nomalSecondTitleArray];
            loverCollectionView.frame = CGRectMake(i*kScreenW, 55*kScale, self.view.frame.size.width, _backScrollView.frame.size.height - 55*kScale);
        }
        [self.view addSubview:loverCollectionView];
        loverCollectionView.delegate = self;
        loverCollectionView.dataSource =self;
        loverCollectionView.alwaysBounceVertical = YES;
        loverCollectionView.backgroundColor = [UIColor clearColor];
        loverCollectionView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
        loverCollectionView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];
        //注册情人动态
        [loverCollectionView registerClass:[AllDynamicCell class] forCellWithReuseIdentifier:@"MainDynamicCell"];
        [_collectionViewsArray addObject:loverCollectionView];
        [_backScrollView addSubview:loverCollectionView];
        [_fromArray addObject:@"0"];
        NSMutableArray *array = [NSMutableArray array];
        [_dataArray addObject:array];
    }
    _cnt = 30;
    _mainViewVM = [[MainViewVM alloc] init];
    _currentIndex = 0;
    _currentSort = 0;
    _keysArray = [NSMutableArray array];

}

- (void)searchAction:(EMButton*)btn {
    SearchVC *searchVC = [[SearchVC alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _backScrollView) {
        int index = scrollView.contentOffset.x/kScreenW;
        _currentIndex = index;
        if (_currentIndex == 1) {
            _currentSort = 4;
        }else {
            _currentSort = _currentIndex;
        }
        [_nomalTitleView setSelectIndex:_currentIndex];
        //如果为空的时候，加上请求
        if ([_dataArray[_currentIndex] count] == 0) {
            [self pushDownLoadWithAnimate];
        }
    }

}


/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    //判断是否为最后一页
    if (((NSArray*)self.dataArray[_currentIndex]).count == [self.fromArray[_currentIndex] intValue] + _cnt) {
        int from = [_fromArray[_currentIndex] intValue];
        from += _cnt;
        _fromArray[_currentIndex] = [NSString stringWithFormat:@"%d",from];
        [self loadData:NO];
    }else{
        ((UICollectionView*)_collectionViewsArray[_currentIndex]).mj_footer.state = MJRefreshStateNoMoreData;
    }
}

/**
 *  下拉刷新
 */
-(void)pushDownLoad{
    _fromArray[_currentIndex] = @"0";
    [self loadData:NO];
}

-(void)pushDownLoadWithAnimate{
    _fromArray[_currentIndex] = @"0";
    [self loadData:YES];
}

-(void)loadData:(BOOL)showHUD{
    if ([self.fromArray[_currentIndex] intValue] == 0) {
        [self.dataArray[_currentIndex] removeAllObjects];
        [(UICollectionView*)(self.collectionViewsArray[self.currentIndex]) reloadData];
    }
    if (showHUD) {
        [UIUtil showHUD:_collectionViewsArray[_currentIndex]];
    }
    WS(weakSelf);
    [_mainViewVM getMainInfoByCat:_currentCat andSort:[NSString stringWithFormat:@"%d",_currentSort] andFrom:self.fromArray[_currentIndex]  andCnt:[NSString stringWithFormat:@"%d",_cnt] andBlock:^(NSArray *arr, BOOL ret, NSString *msg) {
        SS(weakSelf, strongSelf);
        if (showHUD) {
            [UIUtil hideHUD:strongSelf.collectionViewsArray[strongSelf.currentIndex]];
        }
        [strongSelf endRefesh];
        if (ret && arr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([strongSelf.fromArray[_currentIndex] intValue] == 0) {
                    [strongSelf.dataArray[_currentIndex] removeAllObjects];
                }
                [strongSelf.dataArray[_currentIndex] addObjectsFromArray:arr];
                [(UICollectionView*)(strongSelf.collectionViewsArray[strongSelf.currentIndex]) reloadData];
            });
        }else {
            [strongSelf.view.window makeToast:msg duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}


-(void)endRefesh{
    dispatch_async(dispatch_get_main_queue(), ^{
        [((UICollectionView*)_collectionViewsArray[_currentIndex]).mj_header endRefreshing];
        [((UICollectionView*)_collectionViewsArray[_currentIndex]).mj_footer endRefreshing];
    });
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSMutableArray*)self.dataArray[_currentIndex]).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"MainDynamicCell";
    AllDynamicCell * boutiqueCell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    NSDictionary *dict = self.dataArray[_currentIndex][indexPath.row];
    [boutiqueCell setValueWithDict:dict];
    return boutiqueCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.dataArray[_currentIndex][indexPath.row];
    BoardcastObj *obj = [[BoardcastObj alloc] initWithJSONDict:dict];
    obj.backImgURL = obj.imageURL;
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.index =(int)indexPath.row;
    personalRecord.lonelyUser = obj.user;
    [self.navigationController pushViewController:personalRecord animated:YES];
}

#pragma mark -- UICollectionViewDelegate
//设置每个 UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width-48)/2, 182*kScale );
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


@end
