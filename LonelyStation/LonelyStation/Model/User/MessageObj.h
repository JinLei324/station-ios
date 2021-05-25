//
//  MessageObj.h
//  LonelyStation
//
//  Created by zk on 2016/11/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface MessageObj : EMObject

@property (nonatomic,copy)NSString *nid;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *nType;
@property (nonatomic,copy)NSString *npType;//url，要截取文章id的
@property (nonatomic,copy)NSString *isRead;
@property (nonatomic,copy)NSString *createTime;
@property (nonatomic,copy)NSString *articleId;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
