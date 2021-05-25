//
//  RateObj.m
//  LonelyStation
//
//  Created by zk on 16/9/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RateObj.h"

@implementation RateObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _userId = NOTNULLObj(dict[@"member_id"]);
        _rateId = NOTNULLObj(dict[@"id"]);
        _rateNote = NOTNULLObj(dict[@"comment"]);
        _userIdentifier = NOTNULLObj(dict[@"identity"]);
        _file = NOTNULLObj(dict[@"file"]);
        _nickName = NOTNULLObj(dict[@"nickname"]);
    }
    return self;
}

@end
