//
//  LonelyStationUser.h
//  LonelyStation
//
//  Created by zk on 16/9/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelyUser.h"
#import "BoardcastObj.h"
//这个也是当成User的子类来写
@interface LonelyStationUser : LonelyUser


@property(nonatomic,copy)NSString *connectStat;//通话状态
@property(nonatomic,copy)NSString *seenTime; //曾經看過或是聽過此電台的時間
@property(nonatomic,copy)NSString *authTime; //授權觀看私人照的時間
@property(nonatomic,copy)NSString *allowTalk;//允許通話否(身別別為電台情人才有意義)
@property(nonatomic,copy)NSString *allowTalkPeriod;//允许通话的时间
@property(nonatomic,copy)NSString *lastOnlineTime;//最后上线时间
@property(nonatomic,assign)BOOL isOnLine; //是否在线
@property(nonatomic,copy)NSString *listenTime; //聆听时间
@property(nonatomic,copy)NSString *addTime; //关注我的时间
@property(nonatomic,copy)NSString *isUse; //0是注销，1是正在使用

@property(nonatomic,copy)NSString *recordsSum;//广播数量

@property(nonatomic,copy)NSString *optState;

@property(nonatomic,copy)NSString *blockByMeTime;//我封锁的时间

@property(nonatomic,copy)NSString *favoriteTime;//我关注的时间

@property(nonatomic,copy)NSString *authBymeTime;//我授权的时间

@property(nonatomic,copy)NSString *amount;//送我的礼物




//当前的广播对象
@property(nonatomic,strong)BoardcastObj *currentBoardcastObj;


- (instancetype)initWithDictory:(NSDictionary*)dict;

- (instancetype)initWithMainDictory:(NSDictionary*)dict;

@end
