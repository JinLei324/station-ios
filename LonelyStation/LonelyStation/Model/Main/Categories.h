//
//  Categories.h
//  LonelyStation
//
//  Created by zk on 16/10/9.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface Categories : EMObject

@property (nonatomic,copy)NSString *categoriesId;
@property (nonatomic,copy)NSString *productImageName;
@property (nonatomic,copy)NSString *productImageNameBig;
@property (nonatomic,copy)NSString *categoriesName;
@property (nonatomic,copy)NSString *side;




- (instancetype)initWithDict:(NSDictionary*)dict;

@end
