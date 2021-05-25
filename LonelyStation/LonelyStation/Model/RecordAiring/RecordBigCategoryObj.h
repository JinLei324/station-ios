//
//  RecordBigCategoryObj.h
//  LonelyStation
//
//  Created by zk on 16/8/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import "RecordCategoryObj.h"

@interface RecordBigCategoryObj : EMObject
//大类Id
@property(nonatomic,copy)NSString *categoryId;
//大类名称
@property(nonatomic,copy)NSString *categoryName;

//分类arr
@property(nonatomic,strong)NSMutableArray<RecordCategoryObj*> *categoryArr;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
