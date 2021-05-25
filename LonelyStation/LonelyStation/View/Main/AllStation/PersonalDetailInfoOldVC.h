//
//  PersonalDetailInfoOldVC.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/11.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "EMViewController.h"
#import "BoardcastObj.h"
#import "LonelyStationUser.h"


@protocol PersonalDetailInfoOldVCDelegate <NSObject>

- (void)shouldReload:(LonelyStationUser*)aLoneyUser;

@end

@interface PersonalDetailInfoOldVC : EMViewController

@property (nonatomic,strong)LonelyStationUser *lonelyUser;


@property (nonatomic,assign)id<PersonalDetailInfoOldVCDelegate> delegate;

@property (nonatomic,assign)BOOL shouldPlay;

//所有电台资讯做翻页用的
@property (nonatomic,strong)NSArray *stationDataArray;


@end
