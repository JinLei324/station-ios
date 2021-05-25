//
//  ProfitObj.m
//  LonelyStation
//
//  Created by zk on 2016/11/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ProfitObj.h"

@implementation ProfitObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    _talk = NOTNULLObj(dict[@"talk"]);
    _radio = NOTNULLObj(dict[@"radio"]);
    _gift = NOTNULLObj(dict[@"gift"]);
    _message = NOTNULLObj(dict[@"message"]);
    _total = [NSString stringWithFormat:@"%f",[dict[@"total"] doubleValue]];
    _listenMeNums = [NSString stringWithFormat:@"%d",[dict[@"listen_to_me_nums"] intValue]];
    _favoriteMeNums = [NSString stringWithFormat:@"%d",[dict[@"favorite_me_nums"] intValue]];
    _unreadNotesNums = [NSString stringWithFormat:@"%d",[dict[@"unread_notes_nums"] intValue]];
    _notesNums = NOTNULLObj(dict[@"notes_nums"]);
    _giftNums = [NSString stringWithFormat:@"%d",[dict[@"gift_nums"] intValue]];
    _talkChatpoint = NOTNULLObj(dict[@"talk_chatpoint"]);
    _radioChatpoint = NOTNULLObj(dict[@"radio_chatpoint"]);
    _giftChatpoint = NOTNULLObj(dict[@"gift_chatpoint"]);
    return self;
}


@end
