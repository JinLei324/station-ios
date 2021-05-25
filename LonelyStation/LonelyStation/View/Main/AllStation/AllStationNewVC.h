//
//  AllStationNewVC.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/9.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "EMViewController.h"
#import "MainTabBarController.h"
#import "WYPopoverController.h"

@interface AllStationNewVC : EMViewController<WYPopoverControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>{
    WYPopoverController* popoverController;
}

@property(nonatomic,assign)BOOL isAdVanceSearch;
@property(nonatomic,copy)NSString *fromAge;
@property(nonatomic,copy)NSString *endAge;
@property(nonatomic,copy)NSString *onLineStr;
@property(nonatomic,copy)NSString *identityStr;
@property(nonatomic,copy)NSString *spkLangStr;
@property(nonatomic,copy)NSString *cityStr;
@property(nonatomic,copy)NSString *jobStr;
@property(nonatomic,copy)NSString *nickStr;
@property(nonatomic,copy)NSString *chargeStr;


@property(nonatomic,weak)MainTabBarController *tabViewController;
@property(nonatomic,strong)UILabel *bridgeLabel;//提醒的label
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)NSMutableArray *currentImageArray;


- (void)iKnowAction:(UITapGestureRecognizer*)tapGesture;

- (void)shouldLoadData;

@end
