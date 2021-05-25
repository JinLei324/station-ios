//
//  AllStationsCell.m
//  LonelyStation
//
//  Created by zk on 16/9/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AllStationsCell.h"
#import "UICycleImgView.h"
#import "UIUtil.h"
#import "EMUtil.h"
#import "UIImage+Blur.h"

@interface AllStationsCell()

//头像
@property (nonatomic,strong)UICycleImgView *headImgView;

//时间
@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)EMView *headLine;

//角色昵称
@property (nonatomic,strong)EMLabel *nickLabel;

//电台名称 故事，我的一天
@property (nonatomic,strong)EMLabel *storyLabel;



//播放按钮
@property (nonatomic,strong)EMButton *playBtn;

//line
@property (nonatomic,strong)EMView *line;


@end


@implementation AllStationsCell

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
    _headLine.backgroundColor = RGB(171,171, 171);
    _headLine.hidden = YES;
    [self.contentView addSubview:_headLine];
    
    _headImgView = [[UICycleImgView alloc] initWithFrame:Rect(x, 17*kScale, fImgWH, fImgWH)];
    _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_headImgView];
    
    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_headImgView) + 20*kScale, y, _categoryLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textColor = RGB(51,51,51);
    _timeLabel.text = @"5分钟前";
    _timeLabel.font = ComFont(14*kScale);
    
    y = 7*kScale;
    _nickLabel = [[EMLabel alloc] initWithFrame:Rect(_timeLabel.frame.origin.x, PositionY(_timeLabel) + y, _categoryLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_nickLabel];
    _nickLabel.textColor = RGB(51,51,51);
    _nickLabel.text = @"电台情人:aaaa";
    _nickLabel.font = ComFont(14*kScale);
    
    _storyLabel = [[EMLabel alloc] initWithFrame:Rect(_timeLabel.frame.origin.x, PositionY(_nickLabel) + y, _timeLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_storyLabel];
    _storyLabel.textColor = RGB(51,51,51);
    _storyLabel.text = @"故事：我的一天";
    _storyLabel.font = ComFont(14*kScale);
    
    _durationLabel = [[EMLabel alloc] initWithFrame:Rect(size.width - _timeLabelWidth - 13*kScale, _timeLabel.frame.origin.y, _timeLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_durationLabel];
    _durationLabel.textColor = RGBA(51, 51, 51, 1);
    _durationLabel.text = @"长度 16:22";
    _durationLabel.font = ComFont(14*kScale);
    _durationLabel.textAlignment = NSTextAlignmentRight;
    
    
    _playBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - (14 + 25 )*kScale, PositionY(_durationLabel)+14*kScale, 25*kScale, 25*kScale)];
    [_playBtn setImage:[UIImage imageNamed:@"formPlay"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"record_stop"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_playBtn];

    
    //线
    _line = [[EMView alloc] initWithFrame:Rect(0, size.height - 0.5, size.width, 0.5)];
    _line.backgroundColor = RGBA(171,171,171,0.7);
    [self.contentView addSubview:_line];
    
    CGFloat width = 80;
     _lastOnlineLabel = [UIUtil createLabel:@"" andRect:Rect(kScreenW - 11-width , 0, width, 76*kScale) andTextColor:RGB(145,90,173)
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
    if (_delegate) {
        [_delegate didClickPlayBtn:self];
    }
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
    [_headImgView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgNameSelfGender:user.gender]]];
    
    _nickLabel.text = [NSString stringWithFormat:@"%@:%@",lonelyStationUser.identityName,lonelyStationUser.nickName];
    _lastOnlineLabel.text = [EMUtil getTimeToNow:lonelyStationUser.lastOnlineTime];
}

-(void)setBoardcastObj:(BoardcastObj *)boardcastObj {
    _boardcastObj = boardcastObj;
    //用户当前头像
    if (_lonelyStationUser) {
        NSString *file = _lonelyStationUser.file;
        if (file == nil || file.length == 0) {
            file = _lonelyStationUser.file2;
            if (file == nil || file.length == 0) {
                file = @"";
            }
        }
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        [_headImgView yy_setImageWithURL:[NSURL URLWithString:file]placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgNameSelfGender:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            //判断是否曾经看过，没看过就是蒙蒙的
            if (_lonelyStationUser.seenTime && _lonelyStationUser.seenTime.length > 0) {
                
            }else {
                _headImgView.image = [_headImgView.image blurredImage:BlurAlpha];
            }

        }];
    }
    _timeLabel.text = [EMUtil getTimeToNow:boardcastObj.updateTime];
    _storyLabel.text = [NSString stringWithFormat:@"%@:%@",boardcastObj.category,boardcastObj.title];
    _durationLabel.text = [EMUtil getAlltimeString:_boardcastObj.duration];
    if (boardcastObj.isCharge && [boardcastObj.isCharge isEqualToString:@"Y"]) {
        [_playBtn setImage:[UIImage imageNamed:@"formplay_r"] forState:UIControlStateNormal];

    }else {
        [_playBtn setImage:[UIImage imageNamed:@"formPlay"] forState:UIControlStateNormal];

    }
}



@end
