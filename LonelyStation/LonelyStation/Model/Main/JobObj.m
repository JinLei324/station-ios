//
//  JobObj.m
//  LonelyStation
//
//  Created by zk on 16/10/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "JobObj.h"

@implementation JobObj

- (instancetype)initWithJSONDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _jobId = NOTNULLObj(dict[@"id"]);
        _jobName = NOTNULLObj(dict[@"name"]);
    }
    return self;
}

@end
