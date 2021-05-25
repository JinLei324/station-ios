//
//  UserViewModel.m
//  LonelyStation
//
//  Created by zk on 2016/10/23.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UserViewModel.h"
#import "ViewModelCommom.h"

@interface UserViewModel (){
    NetAccess *_netAccess;
}

@end

@implementation UserViewModel

- (instancetype)init {
    self = [super init];
    _netAccess = [[NetAccess alloc] init];
    return self;
}

- (void)sendMsg:(NSString*)toUserId andMsgType:(NSString*)type andBlock:(void(^)(NSDictionary* dict,BOOL ret))blcok {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess insertMessage:user.userName andPassword:user.password andToMember:toUserId andMsgType:type andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        blcok(dict,ret);
    }];
}


- (void)sendGift:(NSString*)recieveUserId andTime:(NSString*)time andBlock:(void(^)(NSDictionary *dict, BOOL ret))serverBlock{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess sendGift:user.userName andPassword:user.password andRecieveUserId:recieveUserId andAmount:time andServerBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serverBlock(dict,ret);
    }];
}

- (void)getMyVoicesWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMyVoices:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict && ret){
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *retArray = [NSMutableArray array];
                if (dataArray && [dataArray isKindOfClass:[NSArray class]]) {
                    for (int i = 0; i<dataArray.count; i++) {
                        NSDictionary *adict = [dataArray objectAtIndex:i];
                        VoiceObj *voiceObj = [[VoiceObj alloc] initWithDict:adict];
                        [retArray addObject:voiceObj];
                    }
                }else if (dataArray && [dataArray isKindOfClass:[NSDictionary class]]){
                    NSDictionary *adict = (NSDictionary*)dataArray;
                    VoiceObj *voiceObj = [[VoiceObj alloc] initWithDict:adict];
                    [retArray addObject:voiceObj];
                }
                block(retArray,YES);
            }else{
                block(nil,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}


- (void)uploadVoice:(NSData*)data andSeq:(NSString*)seq andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess uploadVoice:user.userName andPassword:user.password andAudio:data andSeq:seq andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict && ret){
            if ([dict[@"code"] intValue] == 1) {
                block(dict,YES);
            }else {
                block(nil,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}

@end
