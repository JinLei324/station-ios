//
//  BuyListObj.m
//  LonelyStation
//
//  Created by zk on 2016/10/19.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "BuyListObj.h"

@implementation BuyListObj

- (id)initWithDict:(NSDictionary*)dict {
    self = [super init];
    _productName = NOTNULLObj(dict[@"body"]);
    _paid = NOTNULLObj(dict[@"paid"]);
    _buyTime = NOTNULLObj(dict[@"gmt_create"]);
    return self;
}

@end
