//
//  PersonalDetailInfoVC.h
//  LonelyStation
//
//  Created by zk on 16/9/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMViewController.h"
#import "BoardcastObj.h"
#import "LonelyStationUser.h"

@protocol PersonalDetailInfoVCDelegate <NSObject>

- (void)shouldReload:(LonelyStationUser*)aLoneyUser;

@end


@interface PersonalDetailInfoVC : EMViewController

//@property (nonatomic,strong)BoardcastObj *boardcastObj;

@property (nonatomic,strong)LonelyStationUser *lonelyUser;


@property (nonatomic,assign)id<PersonalDetailInfoVCDelegate> delegate;

@property (nonatomic,assign)BOOL shouldPlay;

//所有电台资讯做翻页用的
@property (nonatomic,strong)NSArray *stationDataArray;

@end
