//
//  HightObj.h
//  LonelyStation
//
//  Created by zk on 2016/10/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface HightObj : EMObject

@property (nonatomic,copy)NSString *hightId;
@property (nonatomic,copy)NSString *hightName;

- (instancetype)initWithJSONDict:(NSDictionary*)dict;

@end
