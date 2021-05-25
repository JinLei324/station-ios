//
//  IdentyObj.h
//  LonelyStation
//
//  Created by zk on 2016/10/30.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface IdentyObj : EMObject


@property (nonatomic,copy)NSString *identyId;
@property (nonatomic,copy)NSString *identyName;


- (instancetype)initWithJSONDict:(NSDictionary*)dict;

@end
