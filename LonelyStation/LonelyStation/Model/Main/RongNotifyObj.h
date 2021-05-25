//
//  RongNotifyObj.h
//  LonelyStation
//
//  Created by zk on 2016/12/23.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface RongNotifyObj : EMObject

@property (nonatomic,copy)NSString *cType;//单聊是PR
@property (nonatomic,copy)NSString *fromId;//谁传来的
@property (nonatomic,copy)NSString *toId;
@property (nonatomic,copy)NSString *oName;//RC:TxtMsg

- (instancetype)initWithDict:(NSDictionary*)dict;


@end
