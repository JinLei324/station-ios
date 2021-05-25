//
//  LonelySpkLang.m
//  LonelyStation
//
//  Created by zk on 16/6/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelySpkLang.h"

@implementation LonelySpkLang

- (instancetype)initWithDict:(NSDictionary*)dict{
    if (self = [super init]) {
        _langId = [[dict objectForKey:@"id"] objectForKey:@"text"];
        _langName = [[dict objectForKey:GETCountryCode] objectForKey:@"text"];
    }
    return self;
}

@end
