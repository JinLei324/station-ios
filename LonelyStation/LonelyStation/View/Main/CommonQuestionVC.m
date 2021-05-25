//
//  MyFocousVC.m
//  LonelyStation
//
//  Created by zk on 16/9/5.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "CommonQuestionVC.h"
#import "UserSettingViewModel.h"
#import "UIUtil.h"
#import "CallRecordCell.h"
#import "EMUtil.h"
#import "PersonalStationVC.h"
#import "MyFocousCell.h"
#import "EMAlertView.h"
#import "ViewModelCommom.h"
#import "PersonalDetailInfoVC.h"
#import "NotifyCell.h"
#import "WYPopoverController.h"
#import "ArticleDetailVC.h"
#import "MessageObj.h"

@interface CommonQuestionVC()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,WYPopoverControllerDelegate,JPLabelDelegate>{
    EMTableView *_tableView;
    UserSettingViewModel *_userSettingViewModel;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
    BOOL _isLastPage;
    NSMutableDictionary *_cellStatusDictory;
    WYPopoverController *popoverController;
    
}
@property (nonatomic,strong)NSMutableDictionary *cellReadDictory;


@end

@implementation CommonQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"CommonQuestion") andColor:RGB(145,90,173)];
    _userSettingViewModel = [[UserSettingViewModel alloc] init];
    [self initView];
    _dataArray = [NSMutableArray array];
    _cellStatusDictory = [NSMutableDictionary dictionary];
    _cellReadDictory = [NSMutableDictionary dictionary];
    _from = 0;
    _cnt = 30;
}

- (void)initView {
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.mj_header = [UIUtil createTableHeaderWithSel:@selector(pushDownLoad) andTarget:self];
    _tableView.mj_footer = [UIUtil createTableFooterWithSel:@selector(pushUpLoad) andTarget:self];
    _tableView.rowHeight = 76*kScale;
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 63, kScreenW, 1)];
    line.backgroundColor = RGBA(171, 171, 171, 1);
    [self.viewNaviBar addSubview:line];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cacluUnread];
    [[UIButton appearance] setTitleColor:nil forState:UIControlStateNormal];
}

/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
//    _from += _cnt;
    _from = 0;
    [self loadData:NO];
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
        [UIUtil showHUD:self.view];
    }
    [_userSettingViewModel getQuestionAndAnswerWithBlock:^(NSArray *arr, BOOL ret) {
        if (showHUD) {
            [UIUtil hideHUD:self.view];
        }
        if (arr && ret) {
            if (_from == 0) {
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:arr];
            if (_dataArray.count > _from + _cnt) {
                _isLastPage = NO;
            }else{
                _isLastPage = YES;
            }
            for (int i = 0; i < _dataArray.count; i++) {
                [_cellStatusDictory setObject:@"0" forKey:[NSString stringWithFormat:@"%d",i]];
                MessageObj *msgObj = (MessageObj*)_dataArray[i];
                [_cellReadDictory setObject:msgObj.isRead forKey:msgObj.nid];
            }
            
            [_tableView reloadData];
        }else {
            [_tableView reloadData];
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        [self endRefesh];
        
    }];
}

-(void)endRefesh{
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}

-(void)jp_label:(JPLabel *)label didSelectedString:(NSString *)selectedStr forStyle:(HandleStyle)style inRange:(NSRange)range {
    if (style == HandleStyleLink) {
        if ([selectedStr hasPrefix:@"www"]) {
            selectedStr = [NSString stringWithFormat:@"http://%@",selectedStr];
        }
        [EMUtil pushToWebViewController:@"" requestURL:selectedStr];
    }
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    NotifyCell *cell = (NotifyCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[NotifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    MessageObj *msg = _dataArray[indexPath.section];
    CGFloat height = [self cacluWithText:msg.content];
    cell.height = height;
    cell.contentLabel.text = msg.content;
    cell.contentLabel.jp_commonTextColor = RGB(51, 51, 51);
    cell.contentLabel.textColor = RGB(51, 51, 51);
    cell.contentLabel.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    NSString *str = [_cellStatusDictory objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]];
    if ([str isEqualToString:@"0"]) {
        cell.contentLabel.hidden = YES;
        cell.goImageView.hidden = YES;
    }else{
        cell.contentLabel.hidden = NO;
        cell.goImageView.hidden = NO;
    }
    
    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 42*kScale;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = [_cellStatusDictory objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]];
    if ([str isEqualToString:@"0"]) {
        return 0.001;
    }else {
        MessageObj *msgObj = _dataArray[indexPath.section];
        CGFloat height = [self cacluWithText:msgObj.content];
        return height;
    }
    
}

- (CGFloat)cacluWithText:(NSString*)text {
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    NSDictionary* attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:14*kScale],NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize labelSize = [text boundingRectWithSize: CGSizeMake(kScreenW - 56*kScale, 8888)
                                          options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine
                                       attributes:attributes
                                          context:nil].size;
    labelSize.height=ceil(labelSize.height);
    
    return labelSize.height + 57*kScale;
}



- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    EMView *view = [[EMView alloc] initWithFrame:Rect(0, 0, kScreenW, 42*kScale)];
    view.backgroundColor = [UIColor whiteColor];
    EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(27*kScale, 0, kScreenW - 54*kScale , 42*kScale)];
    label.font = ComFont(14*kScale);
    label.textColor = RGB(51,51,51);
    MessageObj *message = _dataArray[section];
    label.text = message.title;
    view.tag = section;
    [view addSubview:label];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:Rect(kScreenW - 27*kScale, 16*kScale, 14*kScale, 9*kScale)];
    arrowImageView.tag = 101;
    arrowImageView.image = [UIImage imageNamed:@"set_up"];
    [view addSubview:arrowImageView];
    NSString *status = [_cellStatusDictory objectForKey:[NSString stringWithFormat:@"%d",(int)section]];
    if ([status intValue] == 1) {
        arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 42*kScale - 0.5, kScreenW, 0.5)];
    line.backgroundColor = RGBA(171, 171, 171,1);
    [view addSubview:line];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClick:)];
    [view addGestureRecognizer:tapGesture];
    return view;
}



- (void)cacluUnread {
    int count = 0;
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    for (int i = 0; i<_cellReadDictory.allValues.count; i++) {
        int value = [_cellReadDictory.allValues[i] intValue];
        if (value == 0) {
            count++;
        }
    }
    user.unread = [NSString stringWithFormat:@"%d",count];
    [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageObj *msg = _dataArray[indexPath.section];
    if ([msg.nType isEqualToString:@"MESSAGE"]) {
        //啥都不干
    }else{
        //判断是不是升级，是升级，直接跳转
        if ([msg.nType isEqualToString:@"MESSAGE"]) {
            //系统升级
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:msg.npType]];
        }else if ([msg.nType isEqualToString:@"ARTICLE"]) {
            //跳到文章
            ArticleDetailVC *detail = [[ArticleDetailVC alloc] init];
            detail.articleID = msg.articleId;
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
    
}

- (void)cellClick:(UITapGestureRecognizer*)tapGesture {
    EMView *view = (EMView*)[tapGesture view];
    NSInteger tag = view.tag;
    NSString *str = [_cellStatusDictory objectForKey:[NSString stringWithFormat:@"%d",(int)tag]];
    UIImageView *imageView = [view viewWithTag:101];
    imageView.hidden = YES;
    if ([str isEqualToString:@"0"]) {
        [_cellStatusDictory setObject:@"1" forKey:[NSString stringWithFormat:@"%d",(int)tag]];
    }else {
        [_cellStatusDictory setObject:@"0" forKey:[NSString stringWithFormat:@"%d",(int)tag]];
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:tag] withRowAnimation:UITableViewRowAnimationNone];
}




@end
