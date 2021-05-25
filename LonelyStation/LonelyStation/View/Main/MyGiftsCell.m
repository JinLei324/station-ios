//
//  MyGiftsCell.m
//  LonelyStation
//
//  Created by zk on 2017/5/5.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "MyGiftsCell.h"
#import "UICycleImgView.h"
#import "EMView.h"
#import "UIUtil.h"
#import "UIImage+Blur.h"

@interface MyGiftsCell ()

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

@implementation MyGiftsCell

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
    _headLine.backgroundColor = RGB(171,171,171);
    _headLine.hidden = YES;
    [self.contentView addSubview:_headLine];
    
    _headImgView = [[UICycleImgView alloc] initWithFrame:Rect(x, 17*kScale, fImgWH, fImgWH)];
    
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
    
    _playBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - (14 + 50 )*kScale, _headImgView.frame.origin.y, 50*kScale, 50*kScale)];
    [_playBtn setImage:[UIImage imageNamed:@"enjoy_chat_pay1"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_playBtn];
    
    
    //线
    _line = [[EMView alloc] initWithFrame:Rect(0, size.height - 0.5, size.width, 0.5)];
    _line.backgroundColor = RGB(171,171,171);
    [self.contentView addSubview:_line];
    
}


- (void)playAction:(EMButton*)btn {
    if (_delegate) {
        [_delegate didClickPlayBtn:self];
    }
}

- (void)setLonelyStationUser:(LonelyStationUser *)lonelyStationUser {
    _lonelyStationUser = lonelyStationUser;
    if (_lonelyStationUser) {
        NSString *file = _lonelyStationUser.file;
        if (file == nil || file.length == 0) {
            file = _lonelyStationUser.file2;
            if (file == nil || file.length == 0) {
                file = @"";
            }
        }
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        [_headImgView yy_setImageWithURL:[NSURL URLWithString:file]placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgNameUseSelfGender:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            //判断是否曾经看过，没看过就是蒙蒙的
            if (_lonelyStationUser.seenTime && _lonelyStationUser.seenTime.length > 0) {
                
            }else {
                _headImgView.image = [_headImgView.image blurredImage:BlurAlpha];
            }
            
        }];
        _nickLabel.text = [NSString stringWithFormat:@"%@:%@",_lonelyStationUser.identity,_lonelyStationUser.nickName];
        _timeLabel.text = [EMUtil getTimeToNow:_lonelyStationUser.addTime];
        if ([_lonelyStationUser.amount intValue] == 0) {
            _storyLabel.text = [NSString stringWithFormat:@"%@%@%@",Local(@"Get"), _lonelyStationUser.chat_point,Local(@"ChatMoney")];
        }else{
            int stationmin = [_lonelyStationUser.amount intValue]/60;
            _storyLabel.text = [NSString stringWithFormat:@"%@%d%@",Local(@"Get"), stationmin,Local(@"ATime")];
        }
    }

}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
