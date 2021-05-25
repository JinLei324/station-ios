//
//  CallRecordCell.h
//  LonelyStation
//
//  Created by zk on 2016/11/12.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LonelyStationUser.h"
#import "BoardcastObj.h"
#import "CallRecordObj.h"

@interface CallRecordCell : UITableViewCell

@property (nonatomic,strong)LonelyStationUser *lonelyStationUser;
@property (nonatomic,strong)CallRecordObj *callRecordObj;
@property (nonatomic,assign)BOOL *isShowHeadLine;
@property (nonatomic,strong) EMLabel *lastOnlineLabel;
@property (nonatomic,assign)BOOL isCallOut;

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;

- (void)hideOther;

@end
