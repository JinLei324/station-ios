//
//  AllStationsCell.m
//  LonelyStation
//
//  Created by zk on 16/9/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "CallRecordCell.h"
#import "UICycleImgView.h"
#import "UIUtil.h"
#import "EMUtil.h"
#import "UIImage+Blur.h"

@interface CallRecordCell()

//头像
@property (nonatomic,strong)UICycleImgView *headImgView;

//时间
@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)EMView *headLine;

//角色昵称
@property (nonatomic,strong)EMLabel *nickLabel;

//电台名称 故事，我的一天
@property (nonatomic,strong)EMLabel *storyLabel;

//电台长度
@property (nonatomic,strong)EMLabel *durationLabel;

@property (nonatomic,strong)UIImageView *callImageView;

//播放按钮
@property (nonatomic,strong)EMButton *playBtn;

//line
@property (nonatomic,strong)EMView *line;


@end


@implementation CallRecordCell

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier {
    //自定义
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        //生成视图，根据样式是否需要创建背景
        [self initViewsWithSize:size];
    }
    
    return self;
}

- (void)initViewsWithSize:(CGSize)size {
    //tag图片
    CGFloat fImgWH = 42.0f*kScale;
    CGFloat x = 11.f*kScale;
    CGFloat y = 7.f*kScale;
    CGFloat _categoryLabelWidth = 180 * kScale;
    CGFloat _categoryLabelHight = 15 * kScale;
    CGFloat _timeLabelWidth = 180*kScale;
    
    _headLine = [[EMView alloc] initWithFrame:Rect(0, 0, kScreenW, 2)];
    _headLine.backgroundColor = RGB(171, 171, 171);
    _headLine.hidden = YES;
    [self.contentView addSubview:_headLine];
    
    _headImgView = [[UICycleImgView alloc] initWithFrame:Rect(x, 17*kScale, fImgWH, fImgWH)];
    
    [self.contentView addSubview:_headImgView];
    

    
    y = 17*kScale;
    _nickLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_headImgView) + 20*kScale, y, _categoryLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_nickLabel];
    _nickLabel.textColor = RGB(51, 51, 51);
    _nickLabel.text = @"电台情人:aaaa";
    _nickLabel.font = ComFont(14*kScale);
    
    
    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_headImgView) + 20*kScale, PositionY(_nickLabel)+14*kScale, _categoryLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textColor =RGB(51, 51, 51);
    _timeLabel.text = @"5分钟前";
    _timeLabel.font = ComFont(14*kScale);
    
    
    _durationLabel = [[EMLabel alloc] initWithFrame:Rect(size.width - _timeLabelWidth - 13*kScale, _nickLabel.frame.origin.y, _timeLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_durationLabel];
    _durationLabel.textColor = RGB(51, 51, 51);
    _durationLabel.text = @"长度 16:22";
    _durationLabel.font = ComFont(14*kScale);
    _durationLabel.textAlignment = NSTextAlignmentRight;
    
    
     _callImageView = [[UIImageView alloc] initWithFrame:Rect(kScreenW - (14 + 25 )*kScale, PositionY(_durationLabel)+14*kScale, 25*kScale, 25*kScale)];
    
    _callImageView.image = [UIImage imageNamed:@"callout"];
    [self.contentView addSubview:_callImageView];
    _callImageView.hidden = YES;
//    _playBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - (14 + 25 )*kScale, PositionY(_durationLabel)+14*kScale, 25*kScale, 25*kScale)];
//    [_playBtn setImage:[UIImage imageNamed:@"formPlay"] forState:UIControlStateNormal];
//    [_playBtn setImage:[UIImage imageNamed:@"record_stop"] forState:UIControlStateSelected];
//    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:_playBtn];
    
    
    //线
    _line = [[EMView alloc] initWithFrame:Rect(0, size.height - 0.5, size.width, 0.5)];
    _line.backgroundColor = RGB(171, 171, 171);
    [self.contentView addSubview:_line];
    
    CGFloat width = 80;
    _lastOnlineLabel = [UIUtil createLabel:@"" andRect:Rect(kScreenW - 11-width , 0, width, 76*kScale) andTextColor:RGB(51, 51, 51)
                                   andFont:ComFont(11) andAlpha:1];
    [self.contentView addSubview:_lastOnlineLabel];
    _lastOnlineLabel.hidden = YES;
}


- (void)hideOther {
    _durationLabel.hidden = YES;
    _playBtn.hidden = YES;
    _storyLabel.hidden = YES;
    _timeLabel.hidden = YES;
    _lastOnlineLabel.hidden = NO;
    
}

- (void)playAction:(EMButton*)btn {
}

- (void)setIsShowHeadLine:(BOOL *)isShowHeadLine {
    _isShowHeadLine = isShowHeadLine;
    _headLine.hidden = !isShowHeadLine;
}

- (void)setLonelyStationUser:(LonelyStationUser *)lonelyStationUser {
    _lonelyStationUser = lonelyStationUser;
    
    NSString *file = _lonelyStationUser.file;
    if (file == nil || file.length == 0) {
        file = _lonelyStationUser.file2;
        if (file == nil || file.length == 0) {
            file = @"";
        }
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_headImgView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgNameUseSelfGender:user.gender]]];
    
    NSString *identityName = lonelyStationUser.identityName;
    NSString *nickName = lonelyStationUser.nickName;

    if (lonelyStationUser == nil || [lonelyStationUser.identityName isEqual:[NSNull null]]) {
        identityName = @"";
    }
    if (lonelyStationUser == nil || [lonelyStationUser.nickName isEqual:[NSNull null]]){
        nickName = @"";
    }
    if (lonelyStationUser == nil) {
        _nickLabel.text = @"";
    }else{
        _nickLabel.text = [NSString stringWithFormat:@"%@:%@",identityName,nickName];
    }
}

- (void)setCallRecordObj:(CallRecordObj *)callRecordObj {
    _callRecordObj = callRecordObj;
    _timeLabel.text = [NSString stringWithFormat:@"%@:%@",Local(@"CallTime"),[EMUtil getAlltimeString:[NSString stringWithFormat:@"%d",callRecordObj.duration]]];
    _durationLabel.text = [EMUtil getTimeToNow:callRecordObj.callDate];
    _callImageView.hidden = !self.isCallOut;
    
}



@end
