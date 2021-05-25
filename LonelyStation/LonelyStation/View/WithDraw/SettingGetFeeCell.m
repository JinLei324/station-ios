//
//  SettingGetFeeCell.m
//  LonelyStation
//
//  Created by zk on 2016/12/10.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "SettingGetFeeCell.h"
#import "UIUtil.h"

@implementation SettingGetFeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [_radioBtn setSelected:selected];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _cellImageView = [[UIImageView alloc] initWithFrame:Rect(58*kScale, 22*kScale, 150*kScale, 44*kScale)];
    _cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_cellImageView];
    CGFloat y = 31*kScale;
    CGFloat width = 27*kScale;
    CGFloat height = 27*kScale;
    CGFloat x = kScreenW - width - 30*kScale;
    _radioBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, height)];
    [_radioBtn setImage:[UIImage imageNamed:@"singlenoButton"] forState:UIControlStateNormal];
    [_radioBtn setImage:[UIImage imageNamed:@"singleyesButton"] forState:UIControlStateSelected];
    [self.contentView addSubview:_radioBtn];
    _radioBtn.userInteractionEnabled = NO;
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 88*kScale - 1, kScreenW, 1)];
    line.backgroundColor = RGB(0xff, 0xff, 0xff);
    [self.contentView addSubview:line];
    
    EMView *selectView = [[EMView alloc] initWithFrame:Rect(0, 0, kScreenW, 88*kScale)];
    selectView.backgroundColor = RGBA(80,27,104,0.3);
    EMView *line1 = [[EMView alloc] initWithFrame:Rect(0, 88*kScale - 1, kScreenW, 1)];
    line1.backgroundColor = RGB(0xff, 0xff, 0xff);
    [selectView addSubview:line1];
    
    self.selectedBackgroundView = selectView;
    
    return self;
}

@end
