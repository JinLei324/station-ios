//
//  LonelyPayCell.m
//  LonelyStation
//
//  Created by zk on 2016/12/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelyPayCell.h"

@implementation LonelyPayCell

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
    _cellImageView = [[UIImageView alloc] initWithFrame:Rect(22*kScale, 22*kScale, 120*kScale, 44*kScale)];
    _cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_cellImageView];
    _titleLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_cellImageView) + 20*kScale, 22*kScale, 120*kScale, 17*kScale)];
    _titleLabel.textColor = RGB(0xff, 0xff, 0xff);
    _titleLabel.font = ComFont(16*kScale);
    [self.contentView addSubview:_titleLabel];
    _twLimitLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_cellImageView) + 20*kScale, PositionY(_titleLabel) + 5*kScale, 120*kScale, 15*kScale)];
    _twLimitLabel.font = ComFont(14*kScale);
    [self.contentView addSubview:_twLimitLabel];
    _twLimitLabel.textColor = RGB(253,125,255);
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
