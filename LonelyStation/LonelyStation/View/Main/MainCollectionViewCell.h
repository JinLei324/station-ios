//
//  MainCollectionViewCell.h
//  LonelyStation
//
//  Created by zk on 16/7/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StationOnlineStatus) {
    StationStatusOffline = 0, //离线  灰底
    StationStatusOnline = 1, //在线   紫底
    StationStatusBusy, //通话中  //粉红底
    StationLoverOnline  //电台情人在线 显示黄底
};

@protocol MainCollectionViewCellDelegate

- (void)talkAction:(EMButton*)sender;

- (void)listenAction:(EMButton*)sender;

- (void)listenSelfAction:(EMButton*)sender;

@end

@interface MainCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)UIImageView *imageView;//头像

@property (nonatomic,strong)UILabel *roleAndNickLable;//角色 神秘客之类

@property (nonatomic,strong)UILabel *personalDesLabel;//个人说明

@property (nonatomic,assign)StationOnlineStatus status;

//通话btn
@property (nonatomic,strong)EMButton *talkBtn;

//听作品
@property (nonatomic,strong)EMButton *listenBtn;

//听自介
@property (nonatomic,strong)EMButton *listenSelfBtn;


- (void)setModel:(LonelyStationUser*)lonelyUser andTarget:(id<MainCollectionViewCellDelegate>)target andIndexPath:(NSIndexPath*)indexPath;

- (void)setBlurPhoto:(BOOL)ret;

- (void)setTalkAction:(SEL)selector andTarget:(id<MainCollectionViewCellDelegate>)target;

- (void)setListenAction:(SEL)selector andTarget:(id<MainCollectionViewCellDelegate>)target;

- (void)setListenSelfAction:(SEL)selector andTarget:(id<MainCollectionViewCellDelegate>)target;


@end
