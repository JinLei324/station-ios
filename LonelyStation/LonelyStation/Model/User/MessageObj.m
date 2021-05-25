//
//  MessageObj.m
//  LonelyStation
//
//  Created by zk on 2016/11/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MessageObj.h"

@implementation MessageObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    _nid = NOTNULLObj(dict[@"nid"]);
    _title = NOTNULLObj(dict[@"title"]);
    _content = NOTNULLObj(dict[@"content"]);
    _nType = NOTNULLObj(dict[@"ntype"]);
    _isRead = NOTNULLObj(dict[@"is_read"]);
    _createTime = NOTNULLObj(dict[@"create_time"]);
    _npType = NOTNULLObj(dict[@"nptype"]);
    if ([_nType isEqualToString:@"ARTICLE"]) {
        NSArray *arr = [_npType componentsSeparatedByString:@"id="];
        if (arr && arr.count == 2) {
            _articleId = arr[1];
        }else{
            _articleId = @"";
        }
    }else{
        _articleId = @"";
    }
    
    return self;
}


@end
