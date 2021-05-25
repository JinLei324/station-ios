//
//  BuyListObj.h
//  LonelyStation
//
//  Created by zk on 2016/10/19.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface BuyListObj : EMObject

@property (nonatomic,copy)NSString *buyTime; //购买日期
@property (nonatomic,copy)NSString *productName;
@property (nonatomic,copy)NSString *productDesp;
@property (nonatomic,copy)NSString *paid;

- (id)initWithDict:(NSDictionary*)dict;

@end
