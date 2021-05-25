//
//  LonelyCountry.m
//  LonelyStation
//
//  Created by zk on 16/5/26.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelyCountry.h"

@implementation LonelyCountry

- (instancetype)initWithJSONDict:(NSDictionary*)dict{
    if (self = [super init]) {
        _countryId = NOTNULLObj(dict[@"id"]);
        _countryName = NOTNULLObj(dict[@"countryname"]);
    }
    return self;
}


- (instancetype)initWithAJSONDict:(NSDictionary*)dict{
    if (self = [super init]) {
        _countryId = NOTNULLObj(dict[@"code"]);
        _countryName = NOTNULLObj(dict[@"country"]);
    }
    return self;
}


- (instancetype)initWithDict:(NSDictionary*)dict{
    if (self = [super init]) {
        _countryId = [dict objectForKey:@"id"];
        _countryName = [dict objectForKey:GETCountryCode];
    }
    return self;
}
@end
