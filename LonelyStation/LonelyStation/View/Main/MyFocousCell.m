//
//  MyFocousCell.m
//  LonelyStation
//
//  Created by zk on 16/9/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyFocousCell.h"
#import "UICycleImgView.h"
#import "UIUtil.h"
#import "EMUtil.h"



@interface MyFocousCell()

//头像

@property (nonatomic,strong)UICycleImgView *headImgView;

@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)EMView *line;


//角色昵称
@property (nonatomic,strong)EMLabel *nickLabel;

@property (nonatomic,strong) EMLabel *lastOnlineLabel;


@end

@implementation MyFocousCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier containingTableView:containingTableView leftUtilityButtons:leftUtilityButtons rightUtilityButtons:rightUtilityButtons];
    CGFloat fImgWH = 42.0f*kScale;
    CGFloat x = 11.f*kScale;
    CGFloat y = 7.f*kScale;
    CGFloat _categoryLabelWidth = 180 * kScale;
    CGFloat _categoryLabelHight = 15 * kScale;
    
    _headImgView = [[UICycleImgView alloc] initWithFrame:Rect(x, 17*kScale, fImgWH, fImgWH)];
    
    [self.contentView addSubview:_headImgView];
    
    
    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_headImgView) + 20*kScale, y, _categoryLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textColor = RGB(255,252,0);
    _timeLabel.text = @"";
    _timeLabel.font = ComFont(14*kScale);
    
    y = 7*kScale;
    _nickLabel = [[EMLabel alloc] initWithFrame:Rect(_timeLabel.frame.origin.x, PositionY(_timeLabel) + y, _categoryLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_nickLabel];
    _nickLabel.textColor = RGB(253,125,255);
    _nickLabel.text = @"电台情人:aaaa";
    _nickLabel.font = ComFont(14*kScale);
    
    
    //线
    _line = [[EMView alloc] initWithFrame:Rect(0, 76*kScale - 0.5, kScreenW, 0.5)];
    _line.backgroundColor = RGBA(255,255,255,0.7);
    [self.contentView addSubview:_line];
    
    CGFloat width = 80;
    _lastOnlineLabel = [UIUtil createLabel:@"" andRect:Rect(kScreenW - 11-width , 0, width, 76*kScale) andTextColor:RGB(255,252,0)
                                   andFont:ComFont(11) andAlpha:1];
    [self.contentView addSubview:_lastOnlineLabel];
//    _lastOnlineLabel.hidden = YES;

    
    return self;
}

- (void)setLonelyStationUser:(LonelyStationUser *)lonelyStationUser {
    _lonelyStationUser = lonelyStationUser;
    NSString *file = lonelyStationUser.file;
    if (file == nil || file.length == 0) {
        file = lonelyStationUser.file2;
        if (file == nil || file.length == 0) {
            file = @"";
        }
    }
    [_headImgView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgName:_lonelyStationUser.gender]]];
    
    _nickLabel.text = [NSString stringWithFormat:@"%@:%@",lonelyStationUser.identityName,lonelyStationUser.nickName];
    _lastOnlineLabel.text = [EMUtil getTimeToNow:lonelyStationUser.lastOnlineTime];
}

@end
