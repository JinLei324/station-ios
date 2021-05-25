//
//  MainViewCell.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/30.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "MainViewCell.h"
#import "Masonry.h"
#import "EMLabel.h"
#import "UICycleImgView.h"
#import "EMUtil.h"
#import "LonelyStationUser.h"
#import "UIImage+Blur.h"


@interface MainViewCell()

@property (nonatomic,strong)NSArray *colorArray;

///头像，参考main
@property (nonatomic,strong)UICycleImgView *headImageView;

///留声者，神秘客，电台情人的图标
@property (nonatomic,strong)UIImageView *statusImage;

///名字和省份
@property (nonatomic,strong)EMLabel *nameAndProvinceName;


@property (nonatomic,strong)EMLabel *ageLabel;

///在线-粉，忙-黄色，离线-灰
@property (nonatomic,strong)UICycleImgView *statusView;

///心情语录
@property (nonatomic,strong)EMLabel *sloganLabel;

///打电话
@property (nonatomic,strong)EMButton *callBtn;

///聊天
@property (nonatomic,strong)EMButton *chatBtn;

///听我
@property (nonatomic,strong)EMButton *listenBtn;

@property (nonatomic,assign)StationOnlineStatus status;

@end


@implementation MainViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self initViews];
    return self;
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _headImageView = [[UICycleImgView alloc] initWithFrame:Rect(0, 0, 73*kScale, 73*kScale)];
    [self.contentView addSubview:_headImageView];
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(73*kScale, 73*kScale));
    }];
    _statusImage = [UIImageView new];
    [self.contentView addSubview:_statusImage];
    [_statusImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(-9*kScale);
        make.size.mas_equalTo(CGSizeMake(20*kScale, 20*kScale));
    }];
    _colorArray = @[RGB(137,146,147),RGB(125,201,58),RGB(253,60,34),RGB(142,137,9)];

    _nameAndProvinceName = [EMLabel new];
    [self.contentView addSubview:_nameAndProvinceName];
    _nameAndProvinceName.font = BoldFont(17*kScale);
    _nameAndProvinceName.textColor = RGB(51, 51, 51);
    [_nameAndProvinceName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headImageView.mas_right).offset(19*kScale);
        make.top.mas_equalTo(10*kScale);
        make.height.mas_equalTo(18*kScale);
    }];
    
    _statusView = [[UICycleImgView alloc] initWithFrame:Rect(0, 0, 8, 8)];
    [self.contentView addSubview:_statusView];
    [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_nameAndProvinceName.mas_centerY);
        make.left.equalTo(_nameAndProvinceName.mas_right).offset(8*kScale);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    _statusView.backgroundColor = RGB(165, 165, 165);
    
    _ageLabel = [EMLabel new];
    [self.contentView addSubview:_ageLabel];
    [_ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameAndProvinceName.mas_left);
        make.height.mas_equalTo(15*kScale);
        make.top.equalTo(_nameAndProvinceName.mas_bottom).offset(10*kScale);
    }];
    _ageLabel.font = ComFont(15*kScale);
    _ageLabel.textColor = RGB(224,81,255);
    
    _sloganLabel = [EMLabel new];
    [self.contentView addSubview:_sloganLabel];
    [_sloganLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameAndProvinceName.mas_left);
        make.width.mas_equalTo(110*kScale);
        make.height.mas_equalTo(18*kScale);
        make.top.equalTo(_ageLabel.mas_bottom).offset(10*kScale);
    }];
    _sloganLabel.font = ComFont(15*kScale);
    _sloganLabel.textColor = RGB(145,90,173);
    
    _callBtn = [EMButton new];
    [self.contentView addSubview:_callBtn];
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall_d"] forState:UIControlStateHighlighted];
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall_off"] forState:UIControlStateDisabled];
    [_callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_sloganLabel.mas_right).offset(24*kScale);
        make.size.mas_equalTo(Size(34*kScale, 34*kScale));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    _chatBtn = [EMButton new];
    [self.contentView addSubview:_chatBtn];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateNormal];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat_d"] forState:UIControlStateHighlighted];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateDisabled];
    [_chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_callBtn.mas_right).offset(15*kScale);
        make.size.mas_equalTo(Size(34*kScale, 34*kScale));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    _listenBtn = [EMButton new];
    [self.contentView addSubview:_listenBtn];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe"] forState:UIControlStateNormal];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe_d"] forState:UIControlStateHighlighted];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe_off"] forState:UIControlStateDisabled];
    [_listenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_chatBtn.mas_right).offset(15*kScale);
        make.size.mas_equalTo(Size(34*kScale, 34*kScale));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    UIView *line = [UIView new];
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    line.backgroundColor = RGB(171, 171, 171);
}


- (void)setTalkAction:(SEL)selector andTarget:(id)target {
    [_callBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_callBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}


- (void)setListenAction:(SEL)selector andTarget:(id)target {
    [_chatBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_chatBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setListenSelfAction:(SEL)selector andTarget:(id)target {
    [_listenBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_listenBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setBlurPhoto:(BOOL)ret {
    if (ret) {
        _headImageView.image = [_headImageView.image blurredImage:BlurAlpha];
    }else {
        _headImageView.image = [_headImageView.image blurredImage:0];
    }
}


- (void)setModel:(LonelyStationUser*)lonelyUser andTarget:(id<MainCollectionViewCellDelegate>)target andIndexPath:(NSIndexPath*)indexPath{
    NSString *file = [EMUtil getFileWithUser:lonelyUser];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [self.headImageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (lonelyUser.seenTime.length > 0){
            [self.headImageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]]];
        }else{
            [self setBlurPhoto:YES];
        }
    }];
    self.status = lonelyUser.isOnLine;
    
    if ([@"1" isEqualToString:lonelyUser.identity]) {
        //神秘客
        self.statusImage.image = [UIImage imageNamed:@"icon_user_secret"];
    }else if([@"2" isEqualToString:lonelyUser.identity]) {
        //留声者
        self.statusImage.image = [UIImage imageNamed:@"icon_user_voice"];
    }else if([@"3" isEqualToString:lonelyUser.identity]) {
        //电台情人
        self.statusImage.image = [UIImage imageNamed:@"icon_user_lover"];
    }
    
    self.ageLabel.text = [NSString stringWithFormat:@"%@%@",lonelyUser.age,Local(@"Year")];
    
    self.nameAndProvinceName.text = [NSString stringWithFormat:@"%@",lonelyUser.nickName];
    self.callBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setTalkAction:@selector(talkAction:) andTarget:target];
    self.chatBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setListenAction:@selector(listenAction:) andTarget:target];
    
    self.listenBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setListenSelfAction:@selector(listenSelfAction:) andTarget:target];
    
    self.sloganLabel.text = [lonelyUser.slogan isEqualToString:@""]?Local(@"HaveNoSlogan"):lonelyUser.slogan;
    
    if ([lonelyUser.identity isEqualToString:@"2"]) {
        if (lonelyUser.isOnLine && [lonelyUser.connectStat isEqualToString:@"N"]) {
            self.status = StationLoverOnline;
        }else if (lonelyUser.isOnLine && ![lonelyUser.connectStat isEqualToString:@"N"]){
            self.status = StationStatusBusy;
        }else {
            self.status = StationStatusOffline;
        }
    }else {
        if (lonelyUser.isOnLine && [lonelyUser.connectStat isEqualToString:@"N"]) {
            self.status = StationStatusOnline;
        }else if (lonelyUser.isOnLine && ![lonelyUser.connectStat isEqualToString:@"N"]){
            self.status = StationStatusBusy;
        }else {
            self.status = StationStatusOffline;
        }
    }
    
    //如果msgCharge为Y,设置为红色
    if([@"Y" isEqualToString:lonelyUser.msgCharge]) {
        [self.chatBtn setImage:[UIImage imageNamed:@"SBTChat_pay"] forState:UIControlStateNormal];
    }else {
        [self.chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateNormal];
    }
    //判断是否有自介
    if (lonelyUser.voice.length == 0) {
        [self.listenBtn setEnabled:NO];
    }else {
        [self.listenBtn setEnabled:YES];
    }
    
    //判断是否离线，离线的话就不能点，如果在线但接听时间不在允许范围之内，不能接，弹出相应的提示，只有在线而且接听时间在允许范围之内，才能接
    //        如果online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’N’，   紅框處顯示亮的話筒。
    //        如果 online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’Y’，紅框處顯示暗的話筒。
    //        如果 online=’Y’，identity=’1’ or ‘2’，不管OpStat和ConnectStat，紅框處一律顯示暗的話筒。
    //        如果online=’N’，紅框處一律都顯示暗的話筒。
    if ([lonelyUser.allowTalk intValue] == 1) {
        if (lonelyUser.isOnLine && [lonelyUser.identity isEqualToString:@"3"] && [lonelyUser.optState isEqualToString:@"Y"] && [lonelyUser.connectStat isEqualToString:@"N"]) {
            [self.callBtn setEnabled:YES];
            //如果talkcharge为Y,设置为红色
            if([@"Y" isEqualToString:lonelyUser.talkCharge]) {
                [self.callBtn setImage:[UIImage imageNamed:@"SBTCall_pag"] forState:UIControlStateNormal];
            }else {
                [self.callBtn setImage:[UIImage imageNamed:@"SBTcall"] forState:UIControlStateNormal];
            }
        }else {
            [self.callBtn setEnabled:NO];
        }
    }else {
        [self.callBtn setEnabled:NO];
    }
}


- (void)setStatus:(StationOnlineStatus)status {
    _status = status;
    //设置上线下线状态和背景颜色
    _statusView.backgroundColor = _colorArray[status];
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
