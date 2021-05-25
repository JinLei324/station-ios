//
//  UserViewModel.h
//  LonelyStation
//
//  Created by zk on 2016/10/23.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetAccess.h"
#import "VoiceObj.h"

@interface UserViewModel : NSObject

- (void)getMyVoicesWithBlock:(void(^)(NSArray *array,BOOL ret))block;

- (void)uploadVoice:(NSData*)data andSeq:(NSString*)seq andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


- (void)sendMsg:(NSString*)toUserId andMsgType:(NSString*)type andBlock:(void(^)(NSDictionary* dict,BOOL ret))blcok;

- (void)sendGift:(NSString*)recieveUserId andTime:(NSString*)time andBlock:(void(^)(NSDictionary *dict, BOOL ret))serverBlock;

@end
