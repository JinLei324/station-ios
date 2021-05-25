//
//  BgAudioObj.m
//  LonelyStation
//
//  Created by zk on 16/8/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "BgAudioObj.h"

@implementation BgAudioObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _effectId = dict[@"effect_id"][@"text"];
        _fileURL = dict[@"filename"][@"text"];
        _desc = dict[@"desc"][@"text"];
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    BgAudioObj* copy = [[[self class]allocWithZone:zone]init];
    copy.effectId = [_effectId copyWithZone:zone];
    copy.fileURL = [_fileURL copyWithZone:zone];
    copy.desc = [_desc copyWithZone:zone];
    return copy;
}

@end
