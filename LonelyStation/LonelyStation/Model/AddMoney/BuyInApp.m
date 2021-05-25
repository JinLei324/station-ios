//
//  BuyInApp.m
//  LonelyStation
//
//  Created by zk on 2017/2/16.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "BuyInApp.h"
#import "UserSettingViewModel.h"
#import "UIUtil.h"
#import "ViewModelCommom.h"
#define IAPKEY @"88953584d4014db7af0eb80b74512472"

@implementation BuyInApp

- (void)buyInApp:(PayTypeObj*)obj andProgramObj:(ProgramObj*)programObj andView:(UIView*)view andNavController:(UINavigationController*)nav{
    _settingViewModel = [[UserSettingViewModel alloc] init];
    [UIUtil showHUD:view];
    [_settingViewModel getOrderInfoWithPrice:programObj.money andBuyTalkSecond:programObj.talk_second andRaidoSecond:programObj.radio_second  andBuyPoint:programObj.chatPoint andSubject:programObj.title andBody:[NSString stringWithFormat:@"%@+%@",programObj.title,programObj.memo] andPayType:obj.payType andBlock:^(NSDictionary *dict, BOOL ret) {
        [UIUtil hideHUD:view];
        if (dict && ret) {
            if([obj.payType isEqualToString:@"In-App"]){
                _tradeCode = dict[@"MerchantTradeNo"];
                NSSet* dataSet = [[NSSet alloc] initWithObjects:programObj.productId, nil];
                [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
                //No为沙盒，YES为正式
                [IAPShare sharedHelper].iap.production = YES;
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
                                                            
                                                            [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:IAPKEY onCompletion:^(NSString *response, NSError *error) {
                                                                
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
                                                                    [self getTradeStatus:view andNav:nav];
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
         
        }
    }];
}



- (void)getTradeStatus:(UIView*)view andNav:(UINavigationController*)nav{
    if (_tradeCode && _tradeCode.length > 0) {
        [UIUtil showHUD:view];
        [_settingViewModel getTradeStatus:_tradeCode andReceipt:_receipt andBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:view];
            if (dict && ret) {
                if ([dict[@"code"] intValue] == 1) {
                    LonelyUser *user = [ViewModelCommom getCuttentUser];
                    int talkSec = user.talkSecond.intValue + [dict[@"buy_talk_second"] intValue];
                    int radioSec = user.radioSecond.intValue + [dict[@"buy_radio_second"] intValue];
                    int chat_point = user.chat_point.intValue + [dict[@"buy_chat_point"] intValue];
                    user.talkSecond = [NSString stringWithFormat:@"%d",talkSec];
                    user.radioSecond = [NSString stringWithFormat:@"%d",radioSec];
                    user.chat_point = [NSString stringWithFormat:@"%d",chat_point];
                    [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                    [nav popViewControllerAnimated:YES];
                }
                if ([dict objectForKey:@"msg"]) {
                    [view.window makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                }else{
                    [view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
            }else {
                [view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }];
    }
    
    
}

@end
