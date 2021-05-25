//
//  BoardcastObj.m
//  LonelyStation
//
//  Created by zk on 16/8/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "BoardcastObj.h"
#import "LonelyStationUser.h"

@implementation BoardcastObj


- (instancetype)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _audioURL = dict[@"audio"][@"text"];
        _category = dict[@"category"][@"text"];
        _duration = dict[@"duration"][@"text"];
        _effectFile1URL = dict[@"effect_file_1"][@"text"];
        _effectFile1StartTime = dict[@"effect_file_1_start_timing"][@"text"];
        _effectFile2URL = dict[@"effect_file_2"][@"text"];
        _effectFile2StartTime = dict[@"effect_file_2_start_timing"][@"text"];
        _backImgURL = dict[@"image"][@"text"];
        _userId = dict[@"member_id"][@"text"];
        _recordId = dict[@"rid"][@"text"];
        _status = dict[@"status"][@"text"];
        _title = dict[@"title"][@"text"];
        _updateTime = dict[@"updatetime"][@"text"];
        _isCharge = dict[@"is_charge"][@"text"];
        _imageURL = dict[@"image"][@"text"];
        if ([_imageURL isEqual:[NSNull null]]) {
            _imageURL = @"";
        }
        _likes = dict[@"likes"][@"text"];
        _seenNum = dict[@"seen_num"][@"text"];
        _comments = dict[@"comments"][@"text"];

    }
    return self;
}


- (instancetype)initWithJSONDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _audioURL = NOTNULLObj(dict[@"audio"]);
        _category = NOTNULLObj(dict[@"category"]);
        _duration = NOTNULLObj(dict[@"duration"]);
        _effectFile1URL = NOTNULLObj(dict[@"effect_file_1"]);
        _effectFile1StartTime = NOTNULLObj(dict[@"effect_file_1_start_timing"]);
        _effectFile2URL = NOTNULLObj(dict[@"effect_file_2"]);
        _effectFile2StartTime = NOTNULLObj(dict[@"effect_file_2_start_timing"]);
        _backImgURL = NOTNULLObj(dict[@"image"]);
        _userId = dict[@"userid"];
        _recordId = dict[@"r_record_id"];
        _status = dict[@"status"];
        _title = dict[@"title"];
        _updateTime = dict[@"updatetime"];
        _favoriteTime = NOTNULLObj(dict[@"member_favorite_time"]) ;
        _likes = dict[@"likes"];
        _blockTime = NOTNULLObj(dict[@"block_time"]);
        _comments = dict[@"comments"];
        _collectTime = NOTNULLObj(dict[@"record_favorite_time"]);
        _nickName = NOTNULLObj(dict[@"nickname"]);
        _sipId = NOTNULLObj(dict[@"sipid"]);
        _seenTime = NOTNULLObj(dict[@"seen_time"]);
        _identity = NOTNULLObj(dict[@"identity"]);
        _identityName = NOTNULLObj(dict[@"identity_name"]);
        _userName = NOTNULLObj(dict[@"email"]);
        _profit = NOTNULLObj(dict[@"profit"]);
        _isCharge = NOTNULLObj(dict[@"is_charge"]);
        _imageURL = NOTNULLObj(dict[@"image"]);
        if ([_imageURL isEqual:[NSNull null]]) {
            _imageURL = @"";
        }
        _seenNum = NOTNULLObj(dict[@"seen_num"]);

        
        _user = [[LonelyStationUser alloc] init];
        _user.userID = _userId;
        _user.userName = _userName;
        _user.identity = _identity;
        _user.identityName = _identityName;
        _user.sipid = _sipId;
        _user.nickName = _nickName;
        _user.file = NOTNULLObj(dict[@"file"]);
        _user.file2 = NOTNULLObj(dict[@"file2"]);
        _user.seenTime = _seenTime;
        

    }
    return self;
}


@end
