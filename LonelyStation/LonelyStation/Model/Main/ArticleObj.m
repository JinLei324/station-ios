//
//  ArticleObj.m
//  LonelyStation
//
//  Created by zk on 16/10/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ArticleObj.h"

@implementation ArticleObj

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    _productId = NOTNULLObj(dict[@"product_id"]);
    _productNo = NOTNULLObj(dict[@"product_no"]);
    _productMsg = NOTNULLObj(dict[@"product_msg"]);
    _productName = NOTNULLObj(dict[@"product_name"]);
    _productImgName = NOTNULLObj(dict[@"product_image_name"]);
    _productImgName0 = NOTNULLObj(dict[@"product_image_name0"]);
    _productImgName2 = NOTNULLObj(dict[@"product_image_name2"]);
    _productImgName3 = NOTNULLObj(dict[@"product_image_name3"]);
    _productDateAdd = NOTNULLObj(dict[@"product_date_added"]);
    _product18Ban = NOTNULLObj(dict[@"product_18ban"]);
    _productClick = NOTNULLObj(dict[@"product_click"]);
    _isFavorite = NOTNULLObj(dict[@"isFavorite"]);
    _productContent = NOTNULLObj(dict[@"product_content"]);
    return self;
}


@end
