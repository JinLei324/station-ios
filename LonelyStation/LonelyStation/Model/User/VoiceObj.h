//
//  VoiceObj.h
//  LonelyStation
//
//  Created by zk on 2016/10/23.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface VoiceObj : EMObject

@property (nonatomic,copy)NSString *voiceURL;
@property (nonatomic,copy)NSString *voiceStatus;
@property (nonatomic,copy)NSString *voiceStatusNum;
@property (nonatomic,copy)NSString *voiceSeq;
@property (nonatomic,copy)NSString *duration;
@property (nonatomic,copy)NSString *addTime;

- (instancetype)initWithDict:(NSDictionary*)dict;


@end
