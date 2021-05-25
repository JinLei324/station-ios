//
//  HightObj.m
//  LonelyStation
//
//  Created by zk on 2016/10/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "HightObj.h"

@implementation HightObj

- (instancetype)initWithJSONDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _hightId = NOTNULLObj(dict[@"id"]);
        _hightName = NOTNULLObj(dict[@"name"]);
    }
    return self;
}

@end
