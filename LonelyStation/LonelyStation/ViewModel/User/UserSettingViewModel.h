//
//  UserSettingViewModel.h
//  LonelyStation
//
//  Created by zk on 2016/11/28.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import "NetAccess.h"
#import "ProfitObj.h"

@interface UserSettingViewModel : EMObject{
    NetAccess *_netAccess;
}

- (void)getLimitProgramWithBlock:(void(^)(NSArray *array,BOOL ret))block;

- (void)getQuestionAndAnswerWithBlock:(void(^)(NSArray *array,BOOL ret))block;

- (void)getMyAuthorListWithStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NSArray *array,BOOL ret))block;

- (void)deleteAuthorWithId:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


- (void)deleteLockWithId:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


- (void)getMyLockListWithStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NSArray *array,BOOL ret))block;

- (void)changePwdWithNewPwd:(NSString*)newPwd andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

- (void)deleteSelfWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


- (void)getMySettingWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

- (void)updateChargeNotifySetting:(NSString*)field andValue:(NSString*)value andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


- (void)updateMySettingWithField:(NSString*)field andValue:(NSString*)value andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//取得收益内容
- (void)getMyProfitWithBlock:(void(^)(ProfitObj *profit,BOOL ret))block;

//获取聊天卡方案
- (void)getChatProgramWithBlock:(void(^)(NSArray *array,BOOL ret))block;

//获取电台劵方案
- (void)getStationProgramWithBlock:(void(^)(NSArray *array,BOOL ret))block;

//获取套餐方案
- (void)getVIPProgramWithBlock:(void(^)(NSArray *array,BOOL ret))block;

//获取订单信息
- (void)getOrderInfoWithPrice:(NSString*)price andBuyTalkSecond:(NSString*)talkSeconds andRaidoSecond:(NSString*)radioSeconds andBuyPoint:(NSString*)chatPoint andSubject:(NSString*)subject andBody:(NSString*)body andPayType:(NSString*)payType andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

- (void)getAllOrdersWithBlock:(void(^)(NSArray *array,BOOL ret))block;


//获取收益详情
- (void)getMyProfitDetailWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


//更新提领设置
- (void)updateWithDrawSettingWithAccount:(NSString*)account andCurrent:(NSString*)current andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//执行提领
- (void)doWithDrawWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


- (void)getTradeStatus:(NSString*)orderId andReceipt:(NSString*)receipt andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

- (void)getWithDrawListWithBlock:(void(^)(NSArray *array,BOOL ret))block;

- (void)doExchange:(NSString*)talkSecond andRadioSecond:(NSString*)radioSecond andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

- (void)getChangeDetailWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//获取审核状态
- (void)getConfig:(void(^)(NSDictionary *dict,BOOL ret))block;

//获取当天收益
- (void)getMyProfileTodayDetail:(void(^)(NSDictionary *dict,BOOL ret))block;

//获取当月收益
- (void)getMyProfileMonthDetail:(void(^)(NSDictionary *dict,BOOL ret))block;

@end
