//
//  MyFocousVC.m
//  LonelyStation
//
//  Created by zk on 16/9/5.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "NotifyVC.h"
#import "MainViewVM.h"
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

@interface NotifyVC()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,WYPopoverControllerDelegate>{
    EMTableView *_tableView;
    MainViewVM *_mainViewVM;
    NSMutableArray *_dataArray;
    int _from;
    int _cnt;
    BOOL _isLastPage;
    NSMutableDictionary *_cellStatusDictory;
    WYPopoverController *popoverController;
    
}
@property (nonatomic,strong)NSMutableDictionary *cellReadDictory;


@end

@implementation NotifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"SystemNotify") andColor:RGB(145,90,173)];
    [self initView];
    _mainViewVM = [[MainViewVM alloc] init];
    _dataArray = [NSMutableArray array];
    _cellStatusDictory = [NSMutableDictionary dictionary];
    _cellReadDictory = [NSMutableDictionary dictionary];
    _from = 0;
    _cnt = 30;
}

- (void)initView {
    _mainViewVM = [[MainViewVM alloc] init];
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
    line.backgroundColor = RGB(171,171,171);
    [self.viewNaviBar addSubview:line];
    
    EMButton *moreBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 40 - 15 , 20, 40, 40)];
    [moreBtn setImage:[UIImage imageNamed:@"BTmore"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar addSubview:moreBtn];
    moreBtn = nil;
}


- (void)more:(UIButton*)sender {
    UIViewController *controller = [[UIViewController alloc] init];
    controller.preferredContentSize = CGSizeMake(88, 94);
    controller.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = Rect(0, 0, 88, 44);
    EMButton *searchBtn = [[EMButton alloc] initWithFrame: frame isRdius:NO];
    [searchBtn setTitle:Local(@"AllRead") forState:UIControlStateNormal];
    [searchBtn.titleLabel setFont:ComFont(14)];
//    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn addTarget:self action:@selector(allRead:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitleColor:RGB(128,128,128) forState:UIControlStateSelected];
    [searchBtn setTitleColor:RGB(145,90,173) forState:UIControlStateNormal];
    [controller.view addSubview:searchBtn];
    EMView *line1 = [[EMView alloc] initWithFrame:Rect(0, 44, 80, 1)];
    line1.backgroundColor = RGB(171,171,171);
    [controller.view addSubview:line1];
    
    frame.origin.y = 45;
    EMButton *articleBtn = [[EMButton alloc] initWithFrame: frame isRdius:NO];
    [articleBtn addTarget:self action:@selector(allDelete:) forControlEvents:UIControlEventTouchUpInside];
    [articleBtn setTitle:Local(@"AllDelete") forState:UIControlStateNormal];
//    articleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [articleBtn.titleLabel setFont:ComFont(14)];
    [articleBtn setTitleColor:RGB(128,128,128) forState:UIControlStateSelected];
    [articleBtn setTitleColor:RGB(145,90,173) forState:UIControlStateNormal];
    [controller.view addSubview:articleBtn];
    popoverController = [[WYPopoverController alloc] initWithContentViewController:controller];
    popoverController.delegate = self;
    [popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}


- (void)allRead:(EMButton*)btn {
    WS(weakSelf);
    [_mainViewVM setAllNoticeReadWithBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1){
                [weakSelf.view.window makeToast:Local(@"OperateSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                [weakSelf pushDownLoad];

            }else{
                [weakSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else{
            [weakSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

- (void)allDelete:(EMButton*)btn {
    WS(weakSelf);
    EMAlertView *alert = [[EMAlertView alloc] initWithTitle:Local(@"Warning") message:Local(@"SureDeleteAllMsg") clickedBlock:^(EMAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            [_mainViewVM deleteAllNoticeWithBlock:^(NSDictionary *dict, BOOL ret) {
                if (dict && ret) {
                    if ([dict[@"code"] intValue] == 1){
                        [weakSelf.view.window makeToast:Local(@"OperateSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                        [weakSelf pushDownLoad];
                    }else{
                        [weakSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                    }
                }else{
                    [weakSelf.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
            }];
        }
    } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
    [alert show];

    
   
}


- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    popoverController.delegate = nil;
    popoverController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cacluUnread];
    [[UIButton appearance] setTitleColor:nil forState:UIControlStateNormal];}

/**
 *
 上拉加载更多
 */
-(void)pushUpLoad{
    _from += _cnt;
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
    [_mainViewVM getMyNoticeFrom:[NSString stringWithFormat:@"%d",_from] andCount:[NSString stringWithFormat:@"%d",_cnt] andBlock:^(NSArray *arr, BOOL ret) {
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
    cell.backgroundColor =RGB(171,171, 171);
    cell.goImageView.image = [UIImage imageNamed:@"center_button_go"];
    if ([msg.nType isEqualToString:@"MESSAGE"]) {
        cell.goImageView.alpha = 0;
    }else{
        cell.goImageView.alpha = 1;
    }
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Local(@"Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        MessageObj *msg = _dataArray[indexPath.section];
                                        //删除通知
                                        EMAlertView *alert = [[EMAlertView alloc] initWithTitle:Local(@"Warning") message:Local(@"SureDeleteMsg") clickedBlock:^(EMAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                                            if (!cancelled) {
                                                [_mainViewVM deleteANotice:msg.nid andBlock:^(NSDictionary *dict, BOOL ret) {
                                                    if (dict && ret) {
                                                        if ([dict[@"code"] intValue] == 1) {
                                                            [self.view.window makeToast:Local(@"DeleteSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                                                            [self loadData:YES];
                                                        }else {
                                                            [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                                                            
                                                        }
                                                    }else {
                                                        [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                                                        
                                                    }
                                                }];
                                            }
                                        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
                                        [alert show];
                                        
                                    }];
    button.backgroundColor = RGB(238,238,238);
    [[UIButton appearance] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    return @[button];
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
    view.backgroundColor = RGB(255,255,255);
    EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(27*kScale, 0, kScreenW - 123*kScale , 42*kScale)];
    label.font = ComFont(14*kScale);
    label.textColor = RGB(51,51,51);
    MessageObj *message = _dataArray[section];
    label.text = message.title;
    view.tag = section;
    [view addSubview:label];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:Rect(kScreenW - 96*kScale, 10*kScale, 48*kScale, 22*kScale)];
    imageView.tag = 100;
    imageView.image = [UIImage imageNamed:@"center_button_new"];
    [view addSubview:imageView];
    NSString *isRead = [_cellReadDictory objectForKey:message.nid];
    if ([isRead intValue] == 0) {
        imageView.hidden = NO;
        label.frame = Rect(27*kScale, 0, kScreenW - 123*kScale , 42*kScale);
    }else{
        imageView.hidden = YES;
        label.frame = Rect(27*kScale, 0, kScreenW - 80*kScale , 42*kScale);
    }
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:Rect(PositionX(imageView), 16*kScale, 14*kScale, 9*kScale)];
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
        if ([msg.nType isEqualToString:@"SYSTEM"]) {
            //系统升级
            if (msg.npType && ![msg.npType isEqual:[NSNull null]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:msg.npType]];
            }
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
    MessageObj *msgObj = (MessageObj*)_dataArray[tag];
    UIImageView *imageView = [view viewWithTag:101];
    imageView.hidden = YES;
    if ([str isEqualToString:@"0"]) {
        [_cellStatusDictory setObject:@"1" forKey:[NSString stringWithFormat:@"%d",(int)tag]];
        WS(weakSelf);
        if ([[_cellReadDictory objectForKey:msgObj.nid] intValue] == 0) {
            [weakSelf.cellReadDictory setObject:@"1" forKey:msgObj.nid];
            //设为已读
            [_mainViewVM setReadNotice:msgObj.nid andBlock:^(NSDictionary *dict, BOOL ret) {
                if (dict && ret) {
                    if ([dict[@"code"] intValue] == 1) {
                    }
                }
            }];
        }
    }else {
        [_cellStatusDictory setObject:@"0" forKey:[NSString stringWithFormat:@"%d",(int)tag]];
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:tag] withRowAnimation:UITableViewRowAnimationNone];
}




@end
