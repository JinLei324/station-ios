//
//  PersonalStationDetailVC.h
//  LonelyStation
//
//  Created by zk on 16/9/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMViewController.h"
#import "BoardcastObj.h"
#import "LonelyStationUser.h"
#import "PersonalDetailInfoVC.h"

@class PersonalStationDetailVC;

@protocol PersonalStationDetailVCDelegate <NSObject>

- (void)setHaveSeen:(NSString*)time andPersonalStationDetail:(PersonalStationDetailVC*)sender;

@end


@interface PersonalStationDetailVC : EMViewController

@property (nonatomic,strong)BoardcastObj *boardcastObj;

@property (nonatomic,strong)LonelyStationUser *lonelyUser;

@property (nonatomic,assign)int index;


@property (nonatomic,assign)BOOL shouldPlay;


@property (nonatomic,assign)BOOL isFromAllStation; //是不是从全部电台里来的

@property (nonatomic,assign)id<PersonalStationDetailVCDelegate> delegate;

//所有电台资讯做翻页用的
@property (nonatomic,strong)NSArray *stationDataArray;

@end
