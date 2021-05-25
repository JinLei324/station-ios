//
//  LonelyCity.m
//  LonelyStation
//
//  Created by zk on 16/5/27.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelyCity.h"

@implementation LonelyCity

- (instancetype)initWithDict:(NSDictionary*)dict{
    if (self = [super init]) {
        _cityId = [dict objectForKey:@"id"];
        _cityName = [dict objectForKey:GETCountryCode];
    }
    return self;
}

- (instancetype)initWithJSONDict:(NSDictionary*)dict{
    if (self = [super init]) {
        _cityId = NOTNULLObj(dict[@"id"]);
        _cityName = NOTNULLObj(dict[@"cityname"]);
    }
    return self;
}

@end
