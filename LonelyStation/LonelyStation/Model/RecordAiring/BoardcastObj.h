//
//  BoardcastObj.h
//  LonelyStation
//
// 记录录制的广播的信息
//  Created by zk on 16/8/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
@class LonelyStationUser;

@interface BoardcastObj : EMObject

@property (nonatomic,copy)NSString *audioURL; //audio URL
@property (nonatomic,copy)NSString *category; //分类名称
@property (nonatomic,copy)NSString *duration; //总时间
@property (nonatomic,copy)NSString *effectFile1URL; //背景音1
@property (nonatomic,copy)NSString *effectFile1StartTime;//背景音1开始播放时间
@property (nonatomic,copy)NSString *effectFile2URL;//背景音2
@property (nonatomic,copy)NSString *effectFile2StartTime;//背景音2开始播放时间
@property (nonatomic,copy)NSString *backImgURL; //背景图片url
@property (nonatomic,copy)NSString *userId;  //用户的userId
@property (nonatomic,copy)NSString *recordId; //recordId
@property (nonatomic,copy)NSString *status; //状态
@property (nonatomic,copy)NSString *title;  //广播标题
@property (nonatomic,copy)NSString *volume;  //声音大小
@property (nonatomic,copy)NSString *updateTime; //更新时间
@property (nonatomic,copy)NSString *profit;//收益

@property (nonatomic,copy)NSString *favoriteTime; //我加入关注的时间，没有就是没有关注
@property (nonatomic,copy)NSString *collectTime; //我加入收藏的时间，没有就是没有收藏
@property (nonatomic,copy)NSString *blockTime; //我检举的时间，没有就是没有检举


@property (nonatomic,copy)NSString *likes;//点赞数
@property (nonatomic,copy)NSString *comments;//评论数

@property (nonatomic,copy)NSString *seenNum;


@property (nonatomic,copy)NSString *nickName;
@property (nonatomic,copy)NSString *seenTime;
@property (nonatomic,copy)NSString *userName;//对应email字段
@property (nonatomic,copy)NSString *identity;
@property (nonatomic,copy)NSString *identityName;
@property (nonatomic,copy)NSString *sipId;//sipid
@property (nonatomic,copy)NSString *imageURL;

@property (nonatomic,copy)NSString *isCharge;//是否收费


@property (nonatomic,strong)LonelyStationUser *user;

- (instancetype)initWithJSONDict:(NSDictionary*)dict;


- (instancetype)initWithDict:(NSDictionary*)dict;

@end
