//
//  LonelyCountry.h
//  LonelyStation
//
//  Created by zk on 16/5/26.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMObject.h"

@interface LonelyCountry : EMObject

@property(nonatomic,copy)NSString *countryId;
@property(nonatomic,copy)NSString *countryName;

- (instancetype)initWithDict:(NSDictionary*)dict;

- (instancetype)initWithJSONDict:(NSDictionary*)dict;

- (instancetype)initWithAJSONDict:(NSDictionary*)dict;

@end
