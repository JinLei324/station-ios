//
//  innerRecBgImgObj.h
//  LonelyStation
//
//  Created by zk on 16/8/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface InnerRecBgImgObj : EMObject

@property(nonatomic,copy)NSString *desc;   //说明
@property(nonatomic,copy)NSString *fileUrl; //url
@property(nonatomic,copy)NSString *recorderPicId;

- (instancetype)initWithDict:(NSDictionary*)dict;


@end
