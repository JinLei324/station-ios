//
//  WeightObj.h
//  LonelyStation
//
//  Created by zk on 2016/10/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface WeightObj : EMObject

@property (nonatomic,copy)NSString *weightId;
@property (nonatomic,copy)NSString *weightName;


- (instancetype)initWithJSONDict:(NSDictionary*)dict;

@end
