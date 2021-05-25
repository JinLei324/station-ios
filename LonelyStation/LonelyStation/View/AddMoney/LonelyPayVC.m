//
//  LonelyPayVC.m
//  LonelyStation
//
//  Created by zk on 2016/12/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelyPayVC.h"
#import "UIUtil.h"
#import "PayTypeObj.h"
#import "LonelyPayCell.h"
#import "UserSettingViewModel.h"
#import "LonelyUser.h"
#import "ViewModelCommom.h"
#import "IAPHelper.h"
#import "IAPShare.h"
#import <StoreKit/StoreKit.h>
#import "NSString+Base64.h"


@interface LonelyPayVC ()<UITableViewDelegate,UITableViewDataSource>{
    EMTableView *_tableView;
    NSInteger payCount;
    NSMutableArray *payObjArr;
    int selectIndex;
    UserSettingViewModel *_settingViewModel;
    NSString *_tradeCode;
    NSString *_receipt;
}

@end

@implementation LonelyPayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //设定运行环境,上线时要记得更新
    _settingViewModel = [[UserSettingViewModel alloc] init];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    selectIndex = -1;
    _receipt = @"";
    [self.viewNaviBar setTitle:Local(@"PayWay")];
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 70*kScale, 30)];
    buyBtn.layer.borderColor = RGB(0xff, 0xff, 0xff).CGColor;
    buyBtn.layer.borderWidth = 1;
    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    
    [buyBtn setTitleColor:RGB(0xff, 0xff, 0xff) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Pay") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    if (_programObj) {
        NSString *payWay = _programObj.howToPlay;
        payObjArr = [NSMutableArray array];
        NSArray *payArr = [payWay componentsSeparatedByString:@","];
        if (payArr && payArr.count > 0) {
            payCount = payArr.count;
            for (int i = 0; i < payArr.count; i++) {
                PayTypeObj *payTypeObj = [[PayTypeObj alloc] initWithType:payArr[i]];
                [payObjArr addObject:payTypeObj];
            }
        }
        
    }
    
    _tableView = [[EMTableView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    EMLabel *label = [UIUtil createLabel:Local(@"PlsSelectYourPayWay") andRect:Rect(0, 0, kScreenW, 88*kScale) andTextColor:RGB(0xff,0xff,0xff) andFont:ComFont(14) andAlpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = Local(@"PayTips");
    label.numberOfLines = 3;
    _tableView.tableFooterView = label;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getTradeStatus];
}


- (void)getTradeStatus {
    if (_tradeCode && _tradeCode.length > 0) {
        [UIUtil showHUD:self.view];
        [_settingViewModel getTradeStatus:_tradeCode andReceipt:_receipt andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:self.view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    LonelyUser *user = [ViewModelCommom getCuttentUser];
                    int talkSec = user.talkSecond.intValue + [dict[@"buy_talk_second"] intValue];
                    int radioSec = user.radioSecond.intValue + [dict[@"buy_radio_second"] intValue];
                    user.talkSecond = [NSString stringWithFormat:@"%d",talkSec];
                    user.radioSecond = [NSString stringWithFormat:@"%d",radioSec];
                    [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [self.view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
            }else {
                [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }];
    }
    

}


- (void)buyAction:(EMButton*)btn {
    if (selectIndex < 0) {
        [self.view.window makeToast:Local(@"PlsSelectYourPayWay") duration:ERRORTime position:[CSToastManager defaultPosition]];
    }else {
        [UIUtil showHUD:self.view];
        PayTypeObj *obj = payObjArr[selectIndex];
        [_settingViewModel getOrderInfoWithPrice:_programObj.money andBuyTalkSecond:_programObj.talk_second andRaidoSecond:_programObj.radio_second andSubject:_programObj.title andBody:[NSString stringWithFormat:@"%@+%@",_programObj.title,_programObj.memo] andPayType:obj.payType andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:self.view];
            if (dict && ret) {
                    if([obj.payType isEqualToString:@"In-App"]){
                        _tradeCode = dict[@"MerchantTradeNo"];
                        //判断有没有内购权限
//                        if(![IAPShare sharedHelper].iap) {
                            NSSet* dataSet = [[NSSet alloc] initWithObjects:_programObj.productId, nil];
                            [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
//                        }
                        //设置是否为沙盒路径
                        [IAPShare sharedHelper].iap.production = YES;
                        
                        //进行内购以及相关回调,请注意,这一步的时候一定要退出真机的apple账号!不然没法登陆测试账号
                        [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
                         {
                             if(response > 0 ) {
                                 SKProduct* product =[[IAPShare sharedHelper].iap.products objectAtIndex:0];
                                 //             product.mj_JSONString
                                 [[IAPShare sharedHelper].iap buyProduct:product
                                                            onCompletion:^(SKPaymentTransaction* trans){
                                                                
                                                                if(trans.error)
                                                                {
                                                                    NSLog(@"此处错误");
                                                                    NSLog(@"Fail %@",[trans.error localizedDescription]);
                                                                    
                                                                }
                                                                else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                                                    
                                                                    NSString *receiptBase64 = [NSString base64StringFromData:trans.transactionReceipt length:[trans.transactionReceipt length]];

                                                                    [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:@"acf6231954534931a39dcbdd05ea9bfb" onCompletion:^(NSString *response, NSError *error) {
                                                                        
                                                                        //Convert JSON String to NSDictionary
                                                                        NSDictionary* rec = [IAPShare toJSON:response];
                                                                        
                                                                        if([rec[@"status"] integerValue]==0)
                                                                        {
                                                                            NSLog(@"购买成功");
                                                                            [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                                                                            NSLog(@"SUCCESS %@",response);
                                                                            NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
                                                                            _receipt = receiptBase64;
                                                               
                                                                            NSLog(@"_receipt==%@",_receipt);
                                                                            //发送recipt到服务器
                                                        [self getTradeStatus];
                                                                        }
                                                                        else {
                                                                            NSLog(@"Fail");
                                                                        }
                                                                    }];
#pragma GCC diagnostic pop
                                                                }
                                                                else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                                                    NSLog(@"Fail");
                                                                }
                                                            }];//end of buy product
                             }
                         }];
                    }
                  
                
            }else {
                [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectIndex = (int)indexPath.row;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return payCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22*kScale;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenW, 22*kScale)];
    view.backgroundColor = RGBA(0x0, 0x0, 0x0, 0.3);
    EMLabel *label = [UIUtil createLabel:Local(@"PlsSelectYourPayWay") andRect:Rect(0, 0, kScreenW, 22*kScale) andTextColor:RGB(255,252,0) andFont:ComFont(14) andAlpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify = @"Cell";
    LonelyPayCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[LonelyPayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    PayTypeObj *obj = [payObjArr objectAtIndex:indexPath.row];
    cell.cellImageView.image = [UIImage imageNamed:obj.payImgURL];
    cell.titleLabel.text = obj.payTitle;
    if (obj.isLimitTW) {
        cell.twLimitLabel.text = Local(@"LimitTW");
        cell.titleLabel.frame = Rect(cell.titleLabel.frame.origin.x, 22*kScale, 120*kScale, 17*kScale);
    }else {
        cell.twLimitLabel.text = @"";
        cell.titleLabel.frame = Rect(cell.titleLabel.frame.origin.x, (88*kScale - cell.titleLabel.frame.size.height)/2.f, 120*kScale, 17*kScale);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88*kScale;
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
