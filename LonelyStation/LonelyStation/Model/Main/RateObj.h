//
//  RateObj.h
//  LonelyStation
//
//  Created by zk on 16/9/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface RateObj : EMObject

@property (nonatomic,copy)NSString *userId;
@property (nonatomic,copy)NSString *userIdentifier;
@property (nonatomic,copy)NSString *nickName;
@property (nonatomic,copy)NSString *rateNote;
@property (nonatomic,copy)NSString *file;
@property (nonatomic,copy)NSString *rateTime;
@property (nonatomic,copy)NSString *rateId;



- (instancetype)initWithDict:(NSDictionary*)dict;

@end
