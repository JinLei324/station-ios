//
//  WeightObj.m
//  LonelyStation
//
//  Created by zk on 2016/10/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "WeightObj.h"

@implementation WeightObj

- (instancetype)initWithJSONDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _weightId = NOTNULLObj(dict[@"id"]);
        _weightName = NOTNULLObj(dict[@"name"]);
    }
    return self;
}

@end
