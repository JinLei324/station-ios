//
//  IdentyObj.m
//  LonelyStation
//
//  Created by zk on 2016/10/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "IdentyObj.h"

@implementation IdentyObj

- (instancetype)initWithJSONDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _identyId = NOTNULLObj(dict[@"id"]);
        _identyName = NOTNULLObj(dict[@"name"]);
    }
    return self;
}

@end
