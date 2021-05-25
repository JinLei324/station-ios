//
//  CallRecordObj.m
//  LonelyStation
//
//  Created by zk on 2016/11/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "CallRecordObj.h"

@implementation CallRecordObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    self.callDate = NOTNULLObj(dict[@"calldate"]);
    self.duration = [NOTNULLObj(dict[@"billsec"]) intValue];
    NSDictionary *srcDict = dict[@"src"];
    if (srcDict && ![srcDict isEqual:[NSNull null]]) {
        LonelyStationUser *stationUser = [[LonelyStationUser alloc] init];
        stationUser.userID = NOTNULLObj(srcDict[@"mid"]);
        stationUser.isUse = NOTNULLObj(srcDict[@"m_status"]);
        stationUser.nickName = NOTNULLObj(srcDict[@"nickname"]);
        stationUser.identity = NOTNULLObj(srcDict[@"identity"]);
        stationUser.identityName = NOTNULLObj(srcDict[@"identity_name"]);
        stationUser.file = NOTNULLObj(srcDict[@"file"]);
        stationUser.file2 = NOTNULLObj(srcDict[@"file2"]);
        _srcUser = stationUser;
    }
  
    
    NSDictionary *dstDict = dict[@"dst"];
    if (dstDict && ![dstDict isEqual:[NSNull null]]) {
        LonelyStationUser *stationUserDst = [[LonelyStationUser alloc] init];
        stationUserDst.userID = NOTNULLObj(dstDict[@"mid"]);
        stationUserDst.isUse = NOTNULLObj(dstDict[@"m_status"]);
        stationUserDst.nickName = NOTNULLObj(dstDict[@"nickname"]);
        stationUserDst.identity = NOTNULLObj(dstDict[@"identity"]);
        stationUserDst.identityName = NOTNULLObj(dstDict[@"identity_name"]);
        stationUserDst.file = NOTNULLObj(dstDict[@"file"]);
        stationUserDst.file2 = NOTNULLObj(dstDict[@"file2"]);
        _dstUser = stationUserDst;
    }
  
    return self;
}

@end
