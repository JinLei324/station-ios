//
//  PersonalStationNewVC.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/22.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "PersonalStationNewVC.h"
#import "MainViewVM.h"
#import "UIUtil.h"
#import "AllDynamicCell.h"
#import "PersonalStationDetailVC.h"

@interface PersonalStationNewVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *loverCollectionView;
@property (nonatomic,assign) BOOL isLastPage;
@property (nonatomic,assign) int from;
@property (nonatomic,assign) int cnt;
@property (nonatomic,strong) MainViewVM  *mainViewVM;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation PersonalStationNewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"PersonalAirPort") andColor:RGB(145,90,173)];
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
    //注册全部广播
    [_loverCollectionView registerClass:[AllDynamicCell class] forCellWithReuseIdentifier:@"AllDynamicCell"];
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
    //加载作品
    [_mainViewVM getPersonalInfoWithMember:_lonelyUser andBlock:^(NSArray<BoardcastObj *> *arr, BOOL ret) {
        SS(weakSelf, strongSelf)
        if (showHUD) {
            [UIUtil hideHUD:strongSelf.loverCollectionView];
        }
        if (arr && ret) {
            if (_from == 0) {
                [strongSelf.dataArray removeAllObjects];
            }
            [strongSelf.dataArray addObjectsFromArray:arr];
            if (strongSelf.dataArray.count == _from + _cnt) {
                _isLastPage = NO;
            }else{
                _isLastPage = YES;
            }
            [_loverCollectionView reloadData];
            if (strongSelf.dataArray.count == 0){
                [strongSelf.view.window makeToast:Local(@"ThereisNoAiring") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else {
            [_loverCollectionView reloadData];
            [strongSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        [strongSelf endRefesh];
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
    static NSString *identify = @"AllDynamicCell";
    AllDynamicCell * boutiqueCell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    BoardcastObj *boardcastObj = self.dataArray[indexPath.row];
    [boutiqueCell setValueWithObj:boardcastObj];
    boutiqueCell.nickNameStr = self.lonelyUser.nickName;
    return boutiqueCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    BoardcastObj *obj = self.dataArray[indexPath.row];
    obj.backImgURL = obj.imageURL;
    PersonalStationDetailVC *personalRecord = [[PersonalStationDetailVC alloc] init];
    personalRecord.boardcastObj = obj;
    personalRecord.index =(int)indexPath.row;
    personalRecord.lonelyUser = self.lonelyUser;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
