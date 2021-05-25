//
//  RecordCategoryObj.h
//  LonelyStation
//
//  Created by zk on 16/8/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface RecordCategoryObj : EMObject

//分类Id
@property(nonatomic,copy)NSString *categoryId;
//分类名称
@property(nonatomic,copy)NSString *categoryName;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
