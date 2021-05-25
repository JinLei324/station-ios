//
//  GetFeeRecordCell.m
//  LonelyStation
//
//  Created by zk on 2016/12/11.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "GetFeeRecordCell.h"
#import "UIUtil.h"

@implementation GetFeeRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _timeLabel = [UIUtil createLabel:@"" andRect:Rect(11, 0, 70*kScale, 44*kScale) andTextColor:RGB(255,252,0) andFont:ComFont(14*kScale) andAlpha:1];
    [self.contentView addSubview:_timeLabel];
    
    _isDoneLabel = [UIUtil createLabel:@"" andRect:Rect(PositionX(_timeLabel)+22*kScale, 0, 50*kScale, 44*kScale) andTextColor:RGB(255,255,255) andFont:ComFont(14*kScale) andAlpha:1];
    [self.contentView addSubview:_isDoneLabel];
    
    _countLabel = [UIUtil createLabel:@"" andRect:Rect(PositionX(_isDoneLabel)+20*kScale, 0, 70*kScale, 44*kScale) andTextColor:RGB(255,252,0) andFont:ComFont(14*kScale) andAlpha:1];
    [self.contentView addSubview:_countLabel];
    
    _currentLabel = [UIUtil createLabel:@"" andRect:Rect(kScreenW-70*kScale, 0, 50*kScale, 44*kScale) andTextColor:RGB(255,255,255) andFont:ComFont(14*kScale) andAlpha:1];
    [self.contentView addSubview:_currentLabel];
    
    [UIUtil addLineWithSuperView:self.contentView andRect:Rect(0, 44*kScale-1, kScreenW, 1)];
    
    return self;
}


@end
