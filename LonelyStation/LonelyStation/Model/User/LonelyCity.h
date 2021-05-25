//
//  LonelyCity.h
//  LonelyStation
//
//  Created by zk on 16/5/27.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface LonelyCity : EMObject

@property(nonatomic,copy)NSString *cityId;
@property(nonatomic,copy)NSString *cityName;
@property(nonatomic,copy)NSString *countryId;


- (instancetype)initWithDict:(NSDictionary*)dict;

- (instancetype)initWithJSONDict:(NSDictionary*)dict;

@end
