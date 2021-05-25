//
//  RecordBigCategoryObj.m
//  LonelyStation
//
//  Created by zk on 16/8/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RecordBigCategoryObj.h"

//大类
@implementation RecordBigCategoryObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
        for (int i = 0; i < dict.allKeys.count; i++) {
            _categoryId = dict.allKeys[i];
            _categoryName = dict[_categoryId];
        }
    }
    return self;
}


@end
