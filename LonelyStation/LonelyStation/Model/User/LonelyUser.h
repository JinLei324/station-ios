//
//  LonelyUser.h
//  LonelyStation
//
//  Created by zk on 16/5/21.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMObject.h"

@interface LonelyUser : EMObject

@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *userID;
@property(nonatomic,copy)NSString *currentHeadImage;//当前头像
@property(nonatomic,copy)NSString *nickName;//昵称
@property(nonatomic,copy)NSString *birthday;//生日 yyyy/MM/dd
@property(nonatomic,copy)NSString *gender;//性别 M/F
@property(nonatomic,copy)NSString *currentLang;//当前系统语言 zh_tw,zh_cn,en
@property(nonatomic,copy)NSString *country;//国家
@property(nonatomic,copy)NSString *countryId;//国家
@property(nonatomic,copy)NSString *city; //城市
@property(nonatomic,copy)NSString *cityId; //城市

@property(nonatomic,copy)NSString *tooday_frist_login;//是否为第一次登入
@property(nonatomic,copy)NSString *upload_record_rewards;//要奖励的金币数
@property(nonatomic,copy)NSString *password;
@property(nonatomic,strong)NSMutableDictionary *imagesDict;//获取当前存放的5张照片地址
@property(nonatomic,copy)NSString *file; //公开头像
@property(nonatomic,copy)NSString *fileStatus; //公开头像状态

@property(nonatomic,copy)NSString *file2; //公开头像
@property(nonatomic,copy)NSString *file2Status; //公开头像状态


@property(nonatomic,copy)NSString *file3; //私人头像
@property(nonatomic,copy)NSString *file3Status; //公开头像状态

@property(nonatomic,copy)NSString *file4; //私人头像
@property(nonatomic,copy)NSString *file4Status; //公开头像状态

@property(nonatomic,copy)NSString *file5; //私人头像
@property(nonatomic,copy)NSString *file5Status; //公开头像状态



@property(nonatomic,copy)NSString *birth_day;//生日日期
@property(nonatomic,copy)NSString *birth_month;//生日月份
@property(nonatomic,copy)NSString *birth_year;//生日年份
@property(nonatomic,copy)NSString *sipid; //電台主的通話號
@property(nonatomic,copy)NSString *sipHost;//sip主机
@property(nonatomic,copy)NSString *sipPort;//sip port

@property(nonatomic,copy)NSString *imtoken;//融云token
@property(nonatomic,copy)NSString *imei;//当前登录的imei

@property(nonatomic,copy)NSString *unread;

@property(nonatomic,copy)NSString *talkSecond;//剩余时间

@property(nonatomic,copy)NSString *radioSecond;//剩余时间

@property(nonatomic,copy)NSString *vipStartSecond;//vip开始时间

@property(nonatomic,copy)NSString *vipEndSecond;//vip结束时间

@property(nonatomic,copy)NSString *seen_time;//是否雾化，如果有值就是不雾化


@property(nonatomic,copy)NSString *height;//身高
@property(nonatomic,copy)NSString *heightId;

@property(nonatomic,copy)NSString *weight;//体重
@property(nonatomic,copy)NSString *weightId;

@property(nonatomic,copy)NSString *type;//体型

@property(nonatomic,copy)NSString *job;//职业
@property(nonatomic,copy)NSString *jobId;//职业

@property(nonatomic,copy)NSString *age;

@property(nonatomic,copy)NSString *slogan;//心情语录

@property(nonatomic,copy)NSString *identityName; //身分別名稱

@property(nonatomic,copy)NSString *identity;//角色编号(1:神秘客、2:留聲者、3:電台情人)

@property(nonatomic,copy)NSString *voice; //自介URL地址，如果有就是有自介，没有就是没有自介

@property(nonatomic,copy)NSString *voiceDurion;//自介的长度

@property(nonatomic,copy)NSString *voiceStatus; //自介URL地址，如果有就是有自介，没有就是没有自介

@property(nonatomic,copy)NSString *talkCharge;//聊天收费

@property(nonatomic,copy)NSString *talkChargeRate;//聊天收费


@property(nonatomic,copy)NSString *msgCharge;//消息收费

@property(nonatomic,copy)NSString *msgChargeRate;//聊天收费

@property(nonatomic,copy)NSString *seen_num;//播放量

@property(nonatomic,copy)NSString *favorite_num;//粉丝数


@property(nonatomic,copy)NSString *chat_point;//chatPoint
@property(nonatomic,copy)NSString *chat_point_profit;

@property(nonatomic,strong)NSArray *tagArray;

- (NSString*)getRealFile;

@end
