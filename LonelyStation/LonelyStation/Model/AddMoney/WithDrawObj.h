//
//  WithDrawObj.h
//  LonelyStation
//
//  Created by zk on 2016/12/11.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface WithDrawObj : EMObject

@property (nonatomic,copy)NSString *memberId;
@property (nonatomic,copy)NSString *bookAmount;
@property (nonatomic,copy)NSString *current;
@property (nonatomic,copy)NSString *isDone;
@property (nonatomic,copy)NSString *updateTime;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
