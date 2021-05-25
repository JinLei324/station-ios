//
//  innerRecBgImgObj.m
//  LonelyStation
//
//  Created by zk on 16/8/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "InnerRecBgImgObj.h"

@implementation InnerRecBgImgObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _desc = dict[@"desc"][@"text"];
        _fileUrl = dict[@"filename"][@"text"];
        _recorderPicId = dict[@"recorder_pic_id"][@"text"];
    }
    return self;
}
@end
