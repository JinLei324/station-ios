//
//  JobObj.h
//  LonelyStation
//
//  Created by zk on 16/10/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface JobObj : EMObject

@property (nonatomic,copy)NSString *jobId;
@property (nonatomic,copy)NSString *jobName;


- (instancetype)initWithJSONDict:(NSDictionary*)dict;

@end
