//
//  AllStationsCell.h
//  LonelyStation
//
//  Created by zk on 16/9/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LonelyStationUser.h"
#import "BoardcastObj.h"

@protocol AllStationsCellDelegate <NSObject>

- (void)didClickPlayBtn:(UITableViewCell*)cell;

@end

@interface AllStationsCell : UITableViewCell

@property (nonatomic,strong)LonelyStationUser *lonelyStationUser;
@property (nonatomic,assign)BOOL *isShowHeadLine;
@property (nonatomic,strong)BoardcastObj *boardcastObj;

@property (nonatomic,assign)id<AllStationsCellDelegate> delegate;

@property (nonatomic,strong) EMLabel *lastOnlineLabel;

//电台长度
@property (nonatomic,strong)EMLabel *durationLabel;

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;

- (void)hideOther;

@end
