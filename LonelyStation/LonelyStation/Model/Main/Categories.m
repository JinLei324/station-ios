//
//  Categories.m
//  LonelyStation
//
//  Created by zk on 16/10/9.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "Categories.h"

@implementation Categories

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    _categoriesId = NOTNULLObj(dict[@"categories_id"]);
    _categoriesName = NOTNULLObj(dict[@"categories_name"]);
    _productImageName = NOTNULLObj(dict[@"product_image_name"]);
    _productImageNameBig = NOTNULLObj(dict[@"product_image_name0"]);
    _side = NOTNULLObj(dict[@"side"]);
    return self;
}

@end
