//
//  RongNotifyObj.m
//  LonelyStation
//
//  Created by zk on 2016/12/23.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RongNotifyObj.h"

@implementation RongNotifyObj

//                cType = PR;
//                fId = 1;
//                id = "";
//                oName = "RC:TxtMsg";
//                tId = 1;

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    _cType = NOTNULLObj(dict[@"cType"]);
    _fromId = NOTNULLObj(dict[@"fId"]);
    _toId = NOTNULLObj(dict[@"tId"]);
    _oName = NOTNULLObj(dict[@"oName"]);
    return self;
}

@end
