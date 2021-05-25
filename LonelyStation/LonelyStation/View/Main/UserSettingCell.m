//
//  UserSettingCell.m
//  LonelyStation
//
//  Created by zk on 2016/11/28.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UserSettingCell.h"
#import "UserSettingView.h"

@interface UserSettingCell() {
    UILabel *_label;
    
    UIView *maskView;
    
}
@end

@implementation UserSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier {
    //自定义
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self initViewsWithSize:size];
    }
    return self;
}

- (void)initViewsWithSize:(CGSize)size {
    _label = [[UILabel alloc] initWithFrame:CGRectMake(26*kScale, 0, kScreenW - 52*kScale, 44)];
    _label.text = Local(@"NotifySettingMsg");
    _label.font = ComFont(14*kScale);
    _label.textColor = RGB(51,51,51);
    [self.contentView addSubview:_label];
    
    _settingView = [[UserSettingView alloc] initWithFrame:Rect(0, 0, kScreenW, 122*kScale)];
    [self.contentView addSubview:_settingView];
    
    _chartSettingView = [[UserChargeSettingView alloc] initWithFrame:Rect(0, 0, kScreenW, 88*kScale)];
    [self.contentView addSubview:_chartSettingView];
    
    
    maskView = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenW, 122*kScale)];
    maskView.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.3);
    [self.contentView addSubview:maskView];
    maskView.hidden = YES;
}


- (void)setMaskOn:(BOOL)ret {
    maskView.hidden = !ret;
}


- (void)setLabelHidden:(BOOL)ret {
    _label.hidden = ret;
}

- (void)setChartHidden:(BOOL)ret  {
    _chartSettingView.hidden = ret;
}

-(void)setSettingHidden:(BOOL)ret {
    _settingView.hidden = ret;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
