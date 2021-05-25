//
//  VoiceObj.m
//  LonelyStation
//
//  Created by zk on 2016/10/23.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "VoiceObj.h"

@implementation VoiceObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    self.voiceURL = NOTNULLObj(dict[@"audio"]);
    self.voiceSeq = NOTNULLObj(dict[@"seq"]);
    self.addTime = NOTNULLObj(dict[@"add_time"]);
    self.voiceStatusNum = NOTNULLObj(dict[@"status"]);
    self.duration = [NSString stringWithFormat:@"%f",[dict[@"duration"] floatValue]];
    if ([self.voiceStatusNum intValue] == 1) {
        _voiceStatus = Local(@"NoChecked");
    }else if([self.voiceStatusNum intValue] == 2){
        _voiceStatus = Local(@"PendingChecking");
    }else if ([self.voiceStatusNum intValue] == 3){
        _voiceStatus = Local(@"RefuseCheck");
    }else {
        _voiceStatus = Local(@"NoChecked");
    }
    return self;
}

@end
