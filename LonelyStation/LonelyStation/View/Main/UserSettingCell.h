//
//  UserSettingCell.h
//  LonelyStation
//
//  Created by zk on 2016/11/28.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSettingView.h"
#import "UserChargeSettingView.h"

@interface UserSettingCell : UITableViewCell

@property(nonatomic,strong)UserSettingView *settingView;
@property(nonatomic,strong)UserChargeSettingView *chartSettingView;


- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier ;

- (void)setLabelHidden:(BOOL)ret;

- (void)setChartHidden:(BOOL)ret;

-(void)setSettingHidden:(BOOL)ret;

- (void)setMaskOn:(BOOL)ret;

@end
