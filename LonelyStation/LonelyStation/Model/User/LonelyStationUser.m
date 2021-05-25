//
//  LonelyStationUser.m
//  LonelyStation
//
//  Created by zk on 16/9/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelyStationUser.h"
#import "EMUtil.h"


@implementation LonelyStationUser

- (instancetype)initWithMainDictory:(NSDictionary*)dict {
    self = [self initWithDictory:dict];
//    if (![NOTNULLObj(dict[@"zh_tw"]) isEqualToString:@""]) {
//        self.city = NOTNULLObj(dict[@"zh_tw"]);
//    }else if (![NOTNULLObj(dict[@"zh_cn"]) isEqualToString:@""]) {
//        self.city = NOTNULLObj(dict[@"zh_cn"]);
//    }else {
//        self.city = NOTNULLObj(dict[@"en"]);
//    }
    
    return self;
}



- (instancetype)initWithDictory:(NSDictionary*)dict {
    self = [super init];
    if (dict) {
        self.userName = NOTNULLObj(dict[@"email"]);
        self.userID = NOTNULLObj(dict[@"userid"]);
        self.allowTalk = NOTNULLObj(dict[@"allow_talk"]);
        self.allowTalkPeriod = NOTNULLObj(dict[@"allow_talk_period"]);
        self.authTime = NOTNULLObj(dict[@"auth_time"]);
        self.country = NOTNULLObj(dict[@"country"]);
        self.city = NOTNULLObj(dict[@"city"]);
        self.gender = NOTNULLObj(dict[@"gender"]);
        self.file = NOTNULLObj(dict[@"file"]);
        self.file2 = NOTNULLObj(dict[@"file2"]);
        self.identity = NOTNULLObj(dict[@"identity"]);
        self.identityName = NOTNULLObj(dict[@"identity_name"]);
        self.nickName = NOTNULLObj(dict[@"nickname"]);
        self.isOnLine = [NOTNULLObj(dict[@"online"]) isEqualToString:@"Y"] ? YES : NO;
        self.sipid = NOTNULLObj(dict[@"sipid"]);
        self.slogan = NOTNULLObj(dict[@"slogan"]);
        self.seenTime = NOTNULLObj(dict[@"seen_time"]);
        self.voice = NOTNULLObj(dict[@"voice"]);
        self.voiceDurion = NOTNULLObj(dict[@"duration"]);
        self.recordsSum = NOTNULLObj(dict[@"records_sum"]);
        self.optState = NOTNULLObj(dict[@"OpStat"]);
        self.connectStat = NOTNULLObj(dict[@"ConnectStat"]);
        self.job = NOTNULLObj(dict[@"occupation"]);
        self.height = NOTNULLObj(dict[@"height"]);
        self.weight = NOTNULLObj(dict[@"weight"]);
        self.type =  NOTNULLObj(dict[@"type"]);
        self.listenTime = NOTNULLObj(dict[@"listen_time"]);
        self.seen_num =  [NSString stringWithFormat:@"%d",[dict[@"seen_num"] intValue]];
        self.favorite_num = [NSString stringWithFormat:@"%d",[dict[@"favorite_num"] intValue]];
        NSString *currentYear = [EMUtil getCurrentYear];
        NSString *birth = NOTNULLObj(dict[@"birth_year"]);
        self.age = @"0";
        int age = [currentYear intValue] - [birth intValue];
        if (age >= 0 && age <= 100) {
            self.age = [NSString stringWithFormat:@"%d",age];
        }
        
        self.file3 = NOTNULLObj(dict[@"file3"]);
        self.file4 = NOTNULLObj(dict[@"file4"]);
        self.file5 = NOTNULLObj(dict[@"file5"]);
        self.lastOnlineTime = NOTNULLObj(dict[@"last_online_time"]);
        self.blockByMeTime = NOTNULLObj(dict[@"block_byme_time"]);
        if (self.blockByMeTime.length == 0) {
            self.blockByMeTime = NOTNULLObj(dict[@"block_time"]);
        }
        self.favoriteTime = NOTNULLObj(dict[@"favorite_time"]);
        self.addTime = NOTNULLObj(dict[@"add_time"]);
        self.authBymeTime = NOTNULLObj(dict[@"auth_byme_time"]);
        self.amount = NOTNULLObj(dict[@"amount"]);
        self.msgCharge = NOTNULLObj(dict[@"msg_charge"]);
        self.talkCharge = NOTNULLObj(dict[@"talk_charge"]);
        self.msgChargeRate = NOTNULLObj(dict[@"msg_charge_rate"]);
        self.talkChargeRate = NOTNULLObj(dict[@"talk_charge_rate"]);
        self.chat_point = NOTNULLObj(dict[@"chat_point"]);

        self.tagArray = (dict[@"tags_list"] == nil || [dict[@"tags_list"] isEqual:[NSNull null]]) ? @[] : dict[@"tags_list"];
        
    }
    return self;
}



@end
