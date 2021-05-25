//
//  WithDrawObj.m
//  LonelyStation
//
//  Created by zk on 2016/12/11.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "WithDrawObj.h"

@implementation WithDrawObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    _memberId = NOTNULLObj(dict[@"member_id"]);
    _bookAmount = NOTNULLObj(dict[@"book_amount"]);
    _current = NOTNULLObj(dict[@"cashflow_company"]);
    _isDone = NOTNULLObj(dict[@"done"]);
    _updateTime = NOTNULLObj(dict[@"updatetime"]);
    return self;
}

@end
