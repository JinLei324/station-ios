//
//  ProgramObj.m
//  LonelyStation
//
//  Created by zk on 2016/12/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ProgramObj.h"

@implementation ProgramObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    _howToPlay = NOTNULLObj(dict[@"howtopay"]);
    _memo = NOTNULLObj(dict[@"memo"]);
    _money = [NSString stringWithFormat:@"%d",[dict[@"money"] intValue]];
    _name = NOTNULLObj(dict[@"name"]);
    _radio_second = [NSString stringWithFormat:@"%d",[dict[@"radio_second"] intValue]];
    _talk_second = [NSString stringWithFormat:@"%d",[dict[@"talk_second"] intValue]];
    _title = NOTNULLObj(dict[@"title"]);
    _productId = NOTNULLObj(dict[@"PID"]);
    _chatPoint = NOTNULLObj(dict[@"chat_point"]);
    return self;
}


@end
