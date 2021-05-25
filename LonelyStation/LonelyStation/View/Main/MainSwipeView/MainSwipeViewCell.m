//
//  MainSwipeViewCell.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/5/1.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "MainSwipeViewCell.h"
#import "EMLabel.h"
#import "Masonry.h"
#import "UIImage+Blur.h"
#import "LonelyStationUser.h"



@interface MainSwipeViewCell()

@property (nonatomic,strong)UIImageView *headImageView;

@property (nonatomic,strong)EMLabel *sloganLabel;

@property (nonatomic,strong)EMLabel *nameLabel;

@property (nonatomic,strong)EMLabel *ageAndCity;

@property (nonatomic,strong)EMButton *callBtn;

@property (nonatomic,strong)EMButton *chatBtn;

@property (nonatomic,strong)EMButton *listenBtn;


@end

@implementation MainSwipeViewCell

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
    _headImageView = [UIImageView new];
    [self.contentView addSubview:_headImageView];
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(275*kScale);
    }];
    _headImageView.layer.cornerRadius = 10;
    _headImageView.layer.masksToBounds = YES;
    
    _sloganLabel = [EMLabel new];
    [self.contentView addSubview:_sloganLabel];
    [_sloganLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_headImageView.mas_bottom).offset(-12*kScale);
        make.height.mas_equalTo(16*kScale);
        make.left.and.right.mas_equalTo(0);
    }];
    _sloganLabel.textColor = [UIColor whiteColor];
    _sloganLabel.font = BoldFont(16*kScale);
    _sloganLabel.textAlignment = NSTextAlignmentCenter;

    _nameLabel = [EMLabel new];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_headImageView.mas_bottom).offset(19*kScale);
        make.height.mas_equalTo(20*kScale);
        make.left.and.right.mas_equalTo(0);
    }];
    _nameLabel.font = BoldFont(20*kScale);
    _nameLabel.textColor = RGB(27, 27, 27);
    _nameLabel.textAlignment = NSTextAlignmentCenter;

    
    _ageAndCity = [EMLabel new];
    [self.contentView addSubview:_ageAndCity];
    [_ageAndCity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom).offset(9*kScale);
        make.height.mas_equalTo(15*kScale);
        make.left.and.right.mas_equalTo(0);
    }];
    _ageAndCity.font = ComFont(15*kScale);
    _ageAndCity.textColor = RGB(149, 149, 149);
    _ageAndCity.textAlignment = NSTextAlignmentCenter;
    
    EMLabel *label = [EMLabel new];
    [self.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_ageAndCity.mas_bottom).offset(18*kScale);
        make.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(15*kScale);
    }];
    label.textColor = RGB(143,211,244);
    label.font = ComFont(15*kScale);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = Local(@"OnlineDesp");
    
  
    
    _listenBtn = [EMButton new];
    [self.contentView addSubview:_listenBtn];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe"] forState:UIControlStateNormal];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe_d"] forState:UIControlStateHighlighted];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe_off"] forState:UIControlStateDisabled];
    [_listenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(60*kScale);
        make.top.equalTo(label.mas_bottom).offset(17*kScale);
        make.size.mas_equalTo(Size(39*kScale, 39*kScale));
    }];
    
    
    _chatBtn = [EMButton new];
    [self.contentView addSubview:_chatBtn];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateNormal];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat_d"] forState:UIControlStateHighlighted];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateDisabled];
    [_chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_callBtn.mas_right).offset(37*kScale);
        make.size.mas_equalTo(Size(39*kScale, 39*kScale));
        make.centerY.equalTo(_listenBtn.mas_centerY);
    }];
    
    _callBtn = [EMButton new];
    [self.contentView addSubview:_callBtn];
    [_callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_chatBtn.mas_right).offset(37*kScale);
        make.size.mas_equalTo(Size(39*kScale, 39*kScale));
        make.centerY.equalTo(_callBtn.mas_centerY);
    }];
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall_d"] forState:UIControlStateHighlighted];
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall_off"] forState:UIControlStateDisabled];
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


- (void)setModel:(LonelyStationUser*)lonelyUser andTarget:(id<MainCollectionViewCellDelegate>)target andIndexPath:(NSIndexPath*)indexPath {
    NSString *file = [EMUtil getFileWithUser:lonelyUser];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [self.headImageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgName:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (lonelyUser.seenTime.length > 0){
            [self.headImageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgName:lonelyUser.gender]]];
        }else{
            [self setBlurPhoto:YES];
        }
    }];
    
    self.ageAndCity.text = [NSString stringWithFormat:@"%@  %@ - %@",lonelyUser.age,lonelyUser.country,lonelyUser.city];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@",lonelyUser.nickName];
    self.callBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setTalkAction:@selector(talkAction:) andTarget:target];
    self.chatBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setListenAction:@selector(listenAction:) andTarget:target];
    
    self.listenBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setListenSelfAction:@selector(listenSelfAction:) andTarget:target];
    
    self.sloganLabel.text = [lonelyUser.slogan isEqualToString:@""]?Local(@"HaveNoSlogan"):lonelyUser.slogan;
    
    //如果msgCharge为Y,设置为红色
    if([@"Y" isEqualToString:lonelyUser.msgCharge]) {
        [self.chatBtn setImage:[UIImage imageNamed:@"SBTChat_pay"] forState:UIControlStateNormal];
    }else {
        [self.chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateNormal];
    }
    //判断广播数量是否为0，为0就不能点
    //    if (lonelyUser.recordsSum.intValue == 0) {
    //        [cell.listenBtn setEnabled:NO];
    //    }else {
    //        [cell.listenBtn setEnabled:YES];
    //    }
    
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
