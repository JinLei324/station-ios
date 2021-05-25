//
//  LeftSortsViewController.h
//  LGDeckViewController
//
//  Created by jamie on 15/3/31.
//  Copyright (c) 2015年 Jamie-Ling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftSortsViewController : UIViewController
@property (nonatomic,strong) UITableView *tableview;

//总得到的收益
@property (nonatomic,strong)EMLabel *currentCollect; //总收益
@property (nonatomic,strong)EMLabel *chatCollect; //聊天收益
@property (nonatomic,strong)EMLabel *stationCollect;//电台收益
@property (nonatomic,strong)EMLabel *giftCollect;//收礼收益
@property (nonatomic,strong)EMLabel *msgCollect;//消息收益


@property (nonatomic,strong)EMLabel *alarmLabel;

@end
