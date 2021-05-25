//
//  UserSettingViewModel.m
//  LonelyStation
//
//  Created by zk on 2016/11/28.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UserSettingViewModel.h"
#import "ViewModelCommom.h"
#import "MessageObj.h"
#import "LonelyStationUser.h"
#import "ProgramObj.h"
#import "BuyListObj.h"
#import "WithDrawObj.h"

@implementation UserSettingViewModel


- (instancetype)init {
    self = [super init];
    _netAccess = [[NetAccess alloc] init];
    return self;
}


- (void)getQuestionAndAnswerWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getQuestAndAnswer:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSMutableArray *retArray = [NSMutableArray array];
                NSArray *msgArr = [dict objectForKey:@"data"];
                for (int i = 0; i < msgArr.count; i++) {
                    MessageObj *obj = [[MessageObj alloc] initWithDict:msgArr[i]];
                    if (obj.title.length!=0 && obj.content.length!=0) {
                        [retArray addObject:obj];
                    }
                }
                block(retArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

- (void)getMyAuthorListWithStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMyAuthorList:user.userName andPassword:user.password andStart:start andNumbers:numbers andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    LonelyStationUser *listenUser = [[LonelyStationUser alloc] initWithDictory:dataDict];
                    [stationArray addObject:listenUser];
                }
                block(stationArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

- (void)deleteAuthorWithId:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteAuthorUser:user.userName andPassword:user.password andUserId:userId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


- (void)deleteLockWithId:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteLockUser:user.userName andPassword:user.password andUserId:userId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


- (void)getMyLockListWithStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMyLockList:user.userName andPassword:user.password andStart:start andNumbers:numbers andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    LonelyStationUser *listenUser = [[LonelyStationUser alloc] initWithDictory:dataDict];
                    [stationArray addObject:listenUser];
                }
                block(stationArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//注销账号
- (void)deleteSelfWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteSelf:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}


- (void)getMySettingWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getNotifySetting:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}

- (void)updateChargeNotifySetting:(NSString*)field andValue:(NSString*)value andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess updateNotifyChargeSetting:user.userName andPassword:user.password andField:field andValue:value andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}


- (void)updateMySettingWithField:(NSString*)field andValue:(NSString*)value andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess updateNotifySetting:user.userName andPassword:user.password andField:field andValue:value andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}



- (void)changePwdWithNewPwd:(NSString*)newPwd andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess changePwd:user.userName andPassword:user.password andNewPwd:newPwd andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                user.password = newPwd;
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                block(dict,YES);
            }else{
                block(dict,YES);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//获取收益内容
- (void)getMyProfitWithBlock:(void(^)(ProfitObj *profit,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getProfit:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                ProfitObj *profit = [[ProfitObj alloc] initWithDict:dict[@"data"]];
                block(profit,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }

    }];
}

//获取聊天卡方案
- (void)getChatProgramWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getTalkProgram:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    ProgramObj *program = [[ProgramObj alloc] initWithDict:dataDict];
                    [stationArray addObject:program];
                }
                block(stationArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}


//获取电台劵方案
- (void)getStationProgramWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getRadioProgram:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    ProgramObj *program = [[ProgramObj alloc] initWithDict:dataDict];
                    [stationArray addObject:program];
                }
                block(stationArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//获取套餐方案
- (void)getVIPProgramWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getComboProgram:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    ProgramObj *program = [[ProgramObj alloc] initWithDict:dataDict];
                    [stationArray addObject:program];
                }
                block(stationArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//获取无限畅聊方案
- (void)getLimitProgramWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getLimitProgram:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                if ([dataArray isKindOfClass:[NSArray class]]) {
                    for (int i = 0; i < dataArray.count; i++) {
                        NSDictionary *dataDict = dataArray[i];
                        ProgramObj *program = [[ProgramObj alloc] initWithDict:dataDict];
                        [stationArray addObject:program];
                    }
                }
                block(stationArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//获取订单信息
- (void)getOrderInfoWithPrice:(NSString*)price andBuyTalkSecond:(NSString*)talkSeconds andRaidoSecond:(NSString*)radioSeconds andBuyPoint:(NSString*)chatPoint andSubject:(NSString*)subject andBody:(NSString*)body andPayType:(NSString*)payType andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getOrderDetail:user.userName andPassword:user.password andPrice:price andBuyTalkSecond:talkSeconds andRaidoSecond:radioSeconds andChatPoint:chatPoint andSubject:subject andBody:body andPayType:payType andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                block(dict[@"data"],YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

- (void)getAllOrdersWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getAllOrders:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    BuyListObj *program = [[BuyListObj alloc] initWithDict:dataDict];
                    [stationArray addObject:program];
                }
                block(stationArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//获取收益详情
- (void)getMyProfitDetailWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess getProfitDetail:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                block(dict[@"data"],YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//更新提领设置
- (void)updateWithDrawSettingWithAccount:(NSString*)account andCurrent:(NSString*)current andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess updateWithDrawSetting:user.userName andPassword:user.password andCurrent:current andAccount:account andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
                block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}

//执行提领
- (void)doWithDrawWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess doWithDraw:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}


- (void)getTradeStatus:(NSString*)orderId andReceipt:(NSString*)receipt andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getTradeStatus:user.userName andPassword:user.password andOrderId:orderId andReceipt:receipt andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}


- (void)getWithDrawListWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess withDrawList:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    WithDrawObj *program = [[WithDrawObj alloc] initWithDict:dataDict];
                    [stationArray addObject:program];
                }
                block(stationArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}


- (void)doExchange:(NSString*)talkSecond andRadioSecond:(NSString*)radioSecond andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess doExchange:user.userName andPassword:user.password andChangeTalkSecond:talkSecond andRadioSecond:radioSecond andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}

- (void)getChangeDetailWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getChangeDetail:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,YES);
        }else {
            block(nil,NO);
        }
    }];
}

- (void)getConfig:(void(^)(NSDictionary *dict,BOOL ret))block {
    [_netAccess getCheckingStatusWithBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


//获取当天收益
- (void)getMyProfileTodayDetail:(void(^)(NSDictionary *dict,BOOL ret))block {
    [_netAccess getMyProfileTodayDetail:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}

//获取当月收益
- (void)getMyProfileMonthDetail:(void(^)(NSDictionary *dict,BOOL ret))block {
    [_netAccess getMyProfileMonthDetail:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


@end
