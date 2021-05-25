//
//  RateCell.h
//  LonelyStation
//
//  Created by zk on 16/9/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateObj.h"
#import "LonelyStationUser.h"

@interface RateCell : UITableViewCell

@property(nonatomic,strong)RateObj *rateObj;
@property(nonatomic,strong)LonelyStationUser *user;

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;


@end
