//
//  CallViewVM.h
//  LonelyStation
//
//  Created by zk on 16/9/16.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import "NetAccess.h"

@interface CallViewVM : EMObject

- (void)updateTime:(NSString*)time andDate:(NSString*)date andSipId1:(NSString*)sipID1 andsipID2:(NSString*)sipID2 andBlock:(void(^)(NSDictionary *dict, BOOL ret))serverBlock;

- (void)sendGift:(NSString*)recieveUserId andBlock:(void(^)(NSDictionary *dict, BOOL ret))serverBlock;

//获取通话时间
- (void)getTalkTimeWithSipId1:(NSString*)sipId1 andSipId2:(NSString*)sipId2 andBlock:(void(^)(NSDictionary *dict, BOOL ret))serverBlock;

@end
