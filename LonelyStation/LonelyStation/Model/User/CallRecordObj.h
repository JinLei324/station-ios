//
//  CallRecordObj.h
//  LonelyStation
//
//  Created by zk on 2016/11/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import "LonelyStationUser.h"

@interface CallRecordObj : EMObject

@property(nonatomic,strong)LonelyStationUser *srcUser;
@property(nonatomic,strong)LonelyStationUser *dstUser;
@property(nonatomic,assign)int duration;//通话时长
@property(nonatomic,copy)NSString *callDate;//通话时间

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
