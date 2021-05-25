//
//  CallViewVM.m
//  LonelyStation
//
//  Created by zk on 16/9/16.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "CallViewVM.h"
#import "ViewModelCommom.h"

@interface CallViewVM (){
    NetAccess *_netAccess;
}

@end

@implementation CallViewVM

- (instancetype)init {
    self = [super init];
    _netAccess = [[NetAccess alloc] init];
    return self;
}

- (void)updateTime:(NSString*)time andDate:(NSString*)date andSipId1:(NSString*)sipID1 andsipID2:(NSString*)sipID2 andBlock:(void(^)(NSDictionary *dict, BOOL ret))serverBlock{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess transferTimeToServer:user.userName andPassword:user.password andSipId1:sipID1 andSipId2:sipID2 andCallDate:date andBillSec:time andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serverBlock(dict,ret);
    }];
}


- (void)getTalkTimeWithSipId1:(NSString*)sipId1 andSipId2:(NSString*)sipId2 andBlock:(void(^)(NSDictionary *dict, BOOL ret))serverBlock {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getTalkMinutesWithSipID1:sipId1 andHost:user.sipHost andPassword:user.password andSipId2:sipId2 andServerBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serverBlock(dict,ret);
    }];
}


- (void)sendGift:(NSString*)recieveUserId andBlock:(void(^)(NSDictionary *dict, BOOL ret))serverBlock{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess sendGift:user.userName andPassword:user.password andRecieveUserId:recieveUserId andAmount:@"180" andServerBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serverBlock(dict,ret);
    }];
}


@end
