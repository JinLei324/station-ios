//
//  BgAudioObj.h
//  LonelyStation
//
//  Created by zk on 16/8/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface BgAudioObj : EMObject

//音乐url
@property(nonatomic,copy)NSString *fileURL;

//音乐描述
@property(nonatomic,copy)NSString *desc;

//音乐id
@property(nonatomic,copy)NSString *effectId;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
