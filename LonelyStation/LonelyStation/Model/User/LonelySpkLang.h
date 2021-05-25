//
//  LonelySpkLang.h
//  LonelyStation
//
//  Created by zk on 16/6/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface LonelySpkLang : EMObject

@property(nonatomic,copy)NSString *langId;
@property(nonatomic,copy)NSString *langName;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
