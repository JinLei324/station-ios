//
//  ProfitObj.h
//  LonelyStation
//
//  Created by zk on 2016/11/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface ProfitObj : EMObject

@property (nonatomic,copy)NSString *talk;
@property (nonatomic,copy)NSString *radio;
@property (nonatomic,copy)NSString *gift;
@property (nonatomic,copy)NSString *message;
@property (nonatomic,copy)NSString *total;
@property (nonatomic,copy)NSString *listenMeNums;
@property (nonatomic,copy)NSString *favoriteMeNums;
@property (nonatomic,copy)NSString *unreadNotesNums;
@property (nonatomic,copy)NSString *notesNums;
@property (nonatomic,copy)NSString *giftNums;
@property (nonatomic,copy)NSString *talkChatpoint;
@property (nonatomic,copy)NSString *radioChatpoint;
@property (nonatomic,copy)NSString *giftChatpoint;


- (instancetype)initWithDict:(NSDictionary*)dict;

@end
