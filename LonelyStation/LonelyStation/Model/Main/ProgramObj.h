//
//  ProgramObj.h
//  LonelyStation
//
//  Created by zk on 2016/12/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface ProgramObj : EMObject

@property (nonatomic,copy)NSString *howToPlay;
@property (nonatomic,copy)NSString *memo;
@property (nonatomic,copy)NSString *money;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *radio_second;
@property (nonatomic,copy)NSString *talk_second;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *productId;
@property (nonatomic,copy)NSString *chatPoint;


- (instancetype)initWithDict:(NSDictionary*)dict;

@end
